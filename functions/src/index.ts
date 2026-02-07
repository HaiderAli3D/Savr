import * as functions from 'firebase-functions';
import OpenAI from 'openai';

// Initialize OpenAI client with API key from environment variable
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || '',
});

// Load enhanced grocery data
let groceryData: any = {};

try {
  // Import the JSON data directly (this will be bundled with the function)
  groceryData = require('../assets/grocery_prices3_enhanced.json');
  functions.logger.info(`Loaded ${Object.keys(groceryData.items || {}).length} grocery items`);
} catch (error) {
  functions.logger.error('Failed to load grocery data:', error);
  // Fallback empty structure
  groceryData = { items: {} };
}

interface UserPreferences {
  sulfateFree: boolean;
  organicOnly: boolean;
  noBrandSwaps: boolean;
  vegetarian: boolean;
  glutenFree: boolean;
  budgetFocus: boolean;
}

interface AnalyzeReceiptRequest {
  imageBase64: string;
  preferences: UserPreferences;
}

interface ExtractedItem {
  name: string;
  price: number;
  quantity: string;
  category: string;
}

interface ProductMatch {
  itemKey: string;
  item: any;
  similarity: number;
  tokens: string[];
}

/**
 * Cloud Function to analyze receipt using OpenAI GPT-4o
 * Accepts POST requests with base64 image and user preferences
 */
export const analyzeReceipt = functions
  .runWith({
    secrets: ['OPENAI_API_KEY']
  })
  .https.onRequest(async (request, response) => {
  // Set CORS headers
  response.set('Access-Control-Allow-Origin', '*');
  response.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  response.set('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight request
  if (request.method === 'OPTIONS') {
    response.status(204).send('');
    return;
  }

  // Only accept POST requests
  if (request.method !== 'POST') {
    response.status(405).json({ error: 'Method not allowed. Use POST.' });
    return;
  }

  try {
    // Validate request body
    const { imageBase64, preferences } = request.body as AnalyzeReceiptRequest;

    if (!imageBase64) {
      response.status(400).json({ error: 'Missing imageBase64 in request body' });
      return;
    }

    if (!preferences) {
      response.status(400).json({ error: 'Missing preferences in request body' });
      return;
    }

    // Check if API key is configured
    if (!process.env.OPENAI_API_KEY) {
      functions.logger.error('OPENAI_API_KEY environment variable is not set');
      response.status(500).json({ error: 'API not configured' });
      return;
    }

    // Build the prompt
    const prompt = buildPrompt(preferences);

    // Call OpenAI API with GPT-4o - Only for item extraction
    functions.logger.info('Calling OpenAI API for item extraction');
    
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o',
      messages: [
        {
          role: 'system',
          content: 'You are a receipt text extraction assistant. Analyze the grocery receipt image and extract all purchased items with their prices and quantities. Do not suggest alternatives - only extract what was purchased. Return ONLY valid JSON.',
        },
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text: prompt,
            },
            {
              type: 'image_url',
              image_url: {
                url: `data:image/jpeg;base64,${imageBase64}`,
              },
            },
          ],
        },
      ],
      response_format: { type: 'json_object' },
      max_tokens: 1500,
    });

    // Extract and parse the response
    const content = completion.choices[0]?.message?.content;
    
    if (!content) {
      throw new Error('No content in OpenAI response');
    }

    const extractionResult = JSON.parse(content);
    
    // Now use local token matching to find alternatives
    functions.logger.info('Finding alternatives using token matching');
    
    const extractedItems: ExtractedItem[] = extractionResult.extractedItems || [];
    const allSubstitutions: any[] = [];
    let totalOriginal = 0;
    let totalSavings = 0;
    
    for (const item of extractedItems) {
      totalOriginal += item.price;
      const alternatives = findCheaperAlternatives(item, preferences);
      allSubstitutions.push(...alternatives);
    }
    
    // Calculate total savings
    totalSavings = allSubstitutions.reduce((sum, sub) => sum + sub.savings, 0);
    const percentageSaved = totalOriginal > 0 ? (totalSavings / totalOriginal) * 100 : 0;
    
    const jsonResult = {
      totalOriginal,
      totalSavings,
      percentageSaved: Math.round(percentageSaved * 100) / 100,
      substitutions: allSubstitutions
    };
    
    functions.logger.info('Successfully analyzed receipt');
    response.status(200).json(jsonResult);

  } catch (error: any) {
    functions.logger.error('Error analyzing receipt:', error);
    
    // Handle specific error types
    if (error.code === 'invalid_api_key') {
      response.status(401).json({ error: 'Invalid API key' });
    } else if (error.code === 'rate_limit_exceeded') {
      response.status(429).json({ error: 'Rate limit exceeded. Please try again later.' });
    } else if (error instanceof SyntaxError) {
      response.status(500).json({ error: 'Failed to parse AI response' });
    } else {
      response.status(500).json({ 
        error: 'An error occurred while analyzing the receipt',
        details: error.message 
      });
    }
  }
});

/**
 * Tokenize a product name for matching
 */
function tokenize(productName: string): string[] {
  return productName
    .toLowerCase()
    .replace(/[^\w\s]/g, ' ') // Replace non-word characters with spaces
    .replace(/\s+/g, ' ') // Replace multiple spaces with single space
    .trim()
    .split(' ')
    .filter(token => token.length > 0); // Remove empty tokens
}

/**
 * Calculate similarity between two token arrays
 */
function calculateTokenSimilarity(tokens1: string[], tokens2: string[]): number {
  if (tokens1.length === 0 || tokens2.length === 0) return 0;
  
  const set1 = new Set(tokens1);
  const set2 = new Set(tokens2);
  
  // Calculate intersection
  const intersection = new Set([...set1].filter(x => set2.has(x)));
  
  // Calculate union  
  const union = new Set([...set1, ...set2]);
  
  // Jaccard similarity
  return intersection.size / union.size;
}

/**
 * Find matching products based on token similarity
 */
function findMatchingProducts(inputTokens: string[], threshold: number = 0.3): ProductMatch[] {
  const matches: ProductMatch[] = [];
  
  if (!groceryData.items) return matches;
  
  for (const [itemKey, item] of Object.entries(groceryData.items)) {
    const itemData = item as any;
    if (!itemData.tokens) continue;
    
    const similarity = calculateTokenSimilarity(inputTokens, itemData.tokens);
    
    if (similarity >= threshold) {
      matches.push({
        itemKey,
        item: itemData,
        similarity,
        tokens: itemData.tokens
      });
    }
  }
  
  // Sort by similarity (highest first)
  return matches.sort((a, b) => b.similarity - a.similarity);
}

/**
 * Apply user preferences filter to product matches
 */
function applyPreferencesFilter(matches: ProductMatch[], preferences: UserPreferences): ProductMatch[] {
  return matches.filter(match => {
    const name = match.item.name.toLowerCase();
    
    // Organic only filter
    if (preferences.organicOnly && !name.includes('organic')) {
      return false;
    }
    
    // No brand swaps filter
    if (preferences.noBrandSwaps) {
      // For simplicity, assume brand swaps are value/generic brands
      if (name.includes('everyday value') || match.item.brand === 'value') {
        return false;
      }
    }
    
    // Gluten free filter (basic implementation)
    if (preferences.glutenFree) {
      // Skip items that commonly contain gluten
      if (name.includes('bread') || name.includes('flour') || name.includes('pasta')) {
        return false;
      }
    }
    
    return true;
  });
}

/**
 * Find cheaper alternatives for a given product
 */
function findCheaperAlternatives(extractedItem: ExtractedItem, preferences: UserPreferences): any[] {
  const inputTokens = tokenize(extractedItem.name);
  const matches = findMatchingProducts(inputTokens, 0.2); // Lower threshold for more matches
  
  // Apply user preferences
  const filteredMatches = applyPreferencesFilter(matches, preferences);
  
  // Group by similar products (same category and similar tokens)
  const alternatives: any[] = [];
  
  for (const match of filteredMatches) {
    // Find cheapest price among all stores for this product
    const prices = Object.values(match.item.prices) as Array<{price: number, currency: string}>;
    if (prices.length === 0) continue;
    
    const cheapestPrice = Math.min(...prices.map(p => p.price));
    
    // Only suggest if it's actually cheaper
    if (cheapestPrice < extractedItem.price) {
      const savings = extractedItem.price - cheapestPrice;
      const cheapestStore = Object.keys(match.item.prices).find(store => 
        (match.item.prices[store] as any).price === cheapestPrice
      );
      
      alternatives.push({
        original: {
          name: extractedItem.name,
          price: extractedItem.price,
          quantity: extractedItem.quantity,
          category: extractedItem.category
        },
        alternative: {
          name: match.item.name,
          price: cheapestPrice,
          quantity: match.item.unit || extractedItem.quantity,
          category: match.item.category
        },
        reason: `Token-based match (${Math.round(match.similarity * 100)}% similarity) - cheaper at ${cheapestStore}`,
        savings: savings,
        tags: [
          match.item.category,
          cheapestStore?.toLowerCase() || 'unknown',
          match.item.brand
        ].filter(tag => tag && tag !== 'generic')
      });
    }
  }
  
  // Sort by savings (highest first) and return top 3
  return alternatives
    .sort((a, b) => b.savings - a.savings)
    .slice(0, 3);
}

/**
 * Build the analysis prompt based on user preferences - Modified for extraction only
 */
function buildPrompt(prefs: UserPreferences): string {
  return `
Analyze this receipt and extract the purchased items. User preferences:
- Sulfate Free: ${prefs.sulfateFree}
- Organic Only: ${prefs.organicOnly}
- No Brand Swaps: ${prefs.noBrandSwaps}
- Vegetarian: ${prefs.vegetarian}
- Gluten Free: ${prefs.glutenFree}
- Budget Focus: ${prefs.budgetFocus}

Task:
1. Extract all items from the receipt with their prices and quantities.
2. Categorize each item (dairy, bakery, canned, etc.)
3. Do NOT suggest alternatives - just extract the items.

Output JSON structure:
{
  "extractedItems": [
    {"name": "Semi Skimmed Milk 2L", "price": 1.65, "quantity": "2L", "category": "dairy"},
    {"name": "White Bread 800g", "price": 0.75, "quantity": "800g", "category": "bakery"}
  ]
}
  `;
}
