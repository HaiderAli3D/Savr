import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models.dart';
import '../services/receipt_service.dart';

class AppState extends ChangeNotifier {
  final ReceiptService _service = ReceiptService();
  
  // Data
  UserPreferences _preferences = UserPreferences();
  XFile? _selectedImage;
  SavingsReport? _report;
  
  // UI State
  bool _isAnalyzing = false;
  String? _error;

  // Getters
  UserPreferences get preferences => _preferences;
  XFile? get selectedImage => _selectedImage;
  SavingsReport? get report => _report;
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;

  void updatePreferences(UserPreferences newPrefs) {
    _preferences = newPrefs;
    notifyListeners();
  }

  void setImage(XFile? image) {
    _selectedImage = image;
    _report = null; // Reset report when new image is picked
    notifyListeners();
  }

  Future<void> analyzeReceipt() async {
    if (_selectedImage == null) return;
    
    try {
      _isAnalyzing = true;
      _error = null;
      notifyListeners();

      // Convert image to base64
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      _report = await _service.analyzeReceipt(base64Image, _preferences);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void reset() {
    _selectedImage = null;
    _report = null;
    _error = null;
    notifyListeners();
  }
}
