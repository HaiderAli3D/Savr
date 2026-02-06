import * as functions from 'firebase-functions';
import OpenAI from 'openai';

// Initialize OpenAI client with API key from environment variable
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || '',
});

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

    // Call OpenAI API with GPT-4o
    functions.logger.info('Calling OpenAI API with GPT-4o');
    
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o',
      messages: [
        {
          role: 'system',
          content: 'You are a smart shopping assistant. Analyze the grocery receipt image and the user\'s preferences. Extract purchased items. Then, for each item that has a cheaper, comparative alternative (same category, similar size/quality but cheaper brand/bulk), suggest it. Ensure constraints (Vegan, Gluten-Free, Organic, etc.) are strictly followed. Return ONLY valid JSON.',
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
      max_tokens: 2000,
    });

    // Extract and parse the response
    const content = completion.choices[0]?.message?.content;
    
    if (!content) {
      throw new Error('No content in OpenAI response');
    }

    const jsonResult = JSON.parse(content);
    
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
 * Build the analysis prompt based on user preferences
 */
function buildPrompt(prefs: UserPreferences): string {
  return `
Analyze this receipt. User preferences:
- Sulfate Free: ${prefs.sulfateFree}
- Organic Only: ${prefs.organicOnly}
- No Brand Swaps: ${prefs.noBrandSwaps}
- Vegetarian: ${prefs.vegetarian}
- Gluten Free: ${prefs.glutenFree}
- Budget Focus: ${prefs.budgetFocus}

Task:
1. Extract items from receipt.
2. Identify cheaper alternatives for items where possible, respecting preferences.
3. Calculate savings.

Output JSON structure:
{
  "totalOriginal": 15.93,
  "totalSavings": 5.40,
  "percentageSaved": 28,
  "substitutions": [
    {
      "original": {"name": "Colgate Toothpaste", "price": 3.50, "quantity": "100ml", "category": "Hygiene"},
      "alternative": {"name": "Dentyl Active", "price": 1.99, "quantity": "100ml", "category": "Hygiene"},
      "reason": "Value-Brand Match",
      "savings": 1.51,
      "tags": ["Value-Frase"]
    }
  ]
}
  `;
}