class Constants {
  // App Info
  static const String appName = 'Fitness Trainer';
  static const String appVersion = '1.0.0';

  // Difficulty Levels
  static const List<String> difficultyLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  // Subscription Durations (in months)
  static const List<Map<String, dynamic>> subscriptionDurations = [
    {'label': '1 Month', 'months': 1},
    {'label': '3 Months', 'months': 3},
    {'label': '6 Months', 'months': 6},
    {'label': '1 Year', 'months': 12},
  ];

  // Days of the week (starting from Saturday)
  static const List<String> weekDays = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  static const List<String> weekDaysShort = [
    'Sat',
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
  ];

  // Muscle Groups
  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Legs',
    'Core',
    'Cardio',
    'Full Body',
    'Other',
  ];

  // Focus Areas for workout days
  static const List<String> focusAreas = [
    'Chest & Triceps',
    'Back & Biceps',
    'Shoulders & Arms',
    'Legs & Glutes',
    'Core & Abs',
    'Upper Body',
    'Lower Body',
    'Full Body',
    'Cardio & HIIT',
    'Stretching & Recovery',
  ];
}

// Subscription Status Enum
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
}

extension SubscriptionStatusExtension on SubscriptionStatus {
  String get label {
    return switch (this) {
      SubscriptionStatus.active => 'Active',
      SubscriptionStatus.expired => 'Expired',
      SubscriptionStatus.cancelled => 'Cancelled',
    };
  }
}
