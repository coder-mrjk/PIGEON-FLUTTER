class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }

    return null;
  }

  // Display name validation
  static String? displayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required';
    }

    if (value.trim().length < 2) {
      return 'Display name must be at least 2 characters';
    }

    if (value.trim().length > 30) {
      return 'Display name must be less than 30 characters';
    }

    // Check for invalid characters
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(value)) {
      return 'Display name contains invalid characters';
    }

    return null;
  }

  // Bio validation
  static String? bio(String? value) {
    if (value != null && value.length > 150) {
      return 'Bio must be less than 150 characters';
    }

    return null;
  }

  // Message validation
  static String? message(String? value) {
    if (value == null || value.isEmpty) {
      return 'Message is required';
    }

    if (value.trim().length > 4000) {
      return 'Message is too long (max 4000 characters)';
    }

    return null;
  }

  // Chat name validation
  static String? chatName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Chat name is required';
    }

    if (value.trim().length < 2) {
      return 'Chat name must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return 'Chat name must be less than 50 characters';
    }

    return null;
  }

  // Phone number validation
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // URL validation
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // File size validation
  static String? fileSize(int? sizeInBytes, int maxSizeInBytes) {
    if (sizeInBytes == null) {
      return null;
    }

    if (sizeInBytes > maxSizeInBytes) {
      final maxSizeMB = (maxSizeInBytes / (1024 * 1024)).toStringAsFixed(1);
      return 'File size must be less than ${maxSizeMB}MB';
    }

    return null;
  }

  // File type validation
  static String? fileType(String? fileName, List<String> allowedTypes) {
    if (fileName == null || fileName.isEmpty) {
      return null;
    }

    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedTypes.contains(extension)) {
      return 'File type not allowed. Allowed types: ${allowedTypes.join(', ')}';
    }

    return null;
  }

  // Age validation
  static String? age(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Age is optional
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }

    if (age < 13) {
      return 'You must be at least 13 years old';
    }

    if (age > 120) {
      return 'Please enter a valid age';
    }

    return null;
  }

  // Username validation
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  // Search query validation
  static String? searchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return 'Search query is required';
    }

    if (value.trim().length < 2) {
      return 'Search query must be at least 2 characters';
    }

    if (value.trim().length > 100) {
      return 'Search query must be less than 100 characters';
    }

    return null;
  }

  // Group member validation
  static String? groupMember(String? value) {
    if (value == null || value.isEmpty) {
      return 'Member email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // AI prompt validation
  static String? aiPrompt(String? value) {
    if (value == null || value.isEmpty) {
      return 'Prompt is required';
    }

    if (value.trim().length < 5) {
      return 'Prompt must be at least 5 characters';
    }

    if (value.trim().length > 2000) {
      return 'Prompt must be less than 2000 characters';
    }

    return null;
  }

  // Generic required field validation
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // Generic length validation
  static String? length(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }

    return null;
  }

  // Numeric validation
  static String? numeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  // Positive number validation
  static String? positiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }

    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }
}
