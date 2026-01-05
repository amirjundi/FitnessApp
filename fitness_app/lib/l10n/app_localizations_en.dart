// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fitness Trainer';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get startManaging => 'Start managing your fitness training';

  @override
  String get fullName => 'Full Name';

  @override
  String get phone => 'Phone';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get players => 'Players';

  @override
  String get workoutPlans => 'Workout Plans';

  @override
  String get exercises => 'Exercises';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get settings => 'Settings';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirmation => 'Are you sure you want to delete this?';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get remove => 'Remove';

  @override
  String get search => 'Search...';

  @override
  String get noPlayers => 'No Players Yet';

  @override
  String get addFirstPlayer => 'Add your first player to get started';

  @override
  String get addPlayer => 'Add Player';

  @override
  String get playerDetails => 'Player Details';

  @override
  String get editPlayer => 'Edit Player';

  @override
  String get activeSubscription => 'Active Subscription';

  @override
  String get subscriptionHistory => 'Subscription History';

  @override
  String get noActiveSubscription => 'No active subscription';

  @override
  String get expiringSoon => 'Expiring Soon';

  @override
  String get expired => 'Expired';

  @override
  String get active => 'Active';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get assignPlan => 'Assign Plan';

  @override
  String get noPlans => 'No Workout Plans';

  @override
  String get createFirstPlan => 'Create your first workout plan';

  @override
  String get createPlan => 'Create Plan';

  @override
  String get newPlan => 'New Plan';

  @override
  String get planDetails => 'Plan Details';

  @override
  String get weeklySchedule => 'Weekly Schedule';

  @override
  String get workoutDays => 'Workout Days';

  @override
  String get restDays => 'Rest Days';

  @override
  String get noWorkoutDays => 'No workout days configured';

  @override
  String get editPlan => 'Edit Plan';

  @override
  String get difficultyLevel => 'Difficulty Level';

  @override
  String get description => 'Description';

  @override
  String get focusArea => 'Focus Area';

  @override
  String get selectWorkoutDays => 'Select Workout Days';

  @override
  String get selectWorkoutDaysSubtitle => 'Choose which days are workout days';

  @override
  String get selectFocusAreas => 'Focus Areas (Optional)';

  @override
  String get setFocusArea => 'Set a focus for each workout day';

  @override
  String get dayEditor => 'Day Editor';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get noExercises => 'No Exercises';

  @override
  String get buildLibrary => 'Build your exercise library with YouTube videos';

  @override
  String get exerciseDetails => 'Exercise Details';

  @override
  String get muscleGroup => 'Muscle Group';

  @override
  String get youtubeUrl => 'YouTube Video URL';

  @override
  String get videoPreview => 'Video Preview';

  @override
  String get defaultValues => 'Default Values';

  @override
  String get sets => 'Sets';

  @override
  String get reps => 'Reps';

  @override
  String get duration => 'Duration (seconds)';

  @override
  String get durationOptional => 'Optional, for timed exercises';

  @override
  String get videoLink => 'Video Link';

  @override
  String get videoNotAvailable => 'Video not available';

  @override
  String get newSubscription => 'New Subscription';

  @override
  String get editSubscription => 'Edit Subscription';

  @override
  String get selectPlayer => 'Select Player';

  @override
  String get selectPlan => 'Select Workout Plan';

  @override
  String get subscriptionDuration => 'Subscription Duration';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get payment => 'Payment (Optional)';

  @override
  String get amount => 'Amount';

  @override
  String get paymentNotes => 'Payment Notes';

  @override
  String get requiredField => 'Required field';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get passwordLength => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get pleaseSelectPlayer => 'Please select a player';

  @override
  String get pleaseSelectPlan => 'Please select a workout plan';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String daysLeft(int days) {
    return '$days days left';
  }

  @override
  String get trainTrackTransform => 'Train. Track. Transform.';

  @override
  String get welcome => 'Welcome back,';

  @override
  String day(int number) {
    return 'Day $number';
  }

  @override
  String get restDay => 'Rest Day';

  @override
  String get addDay => 'Add Day';

  @override
  String get removeDay => 'Remove Day';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get setDetails => 'Set Details';

  @override
  String setLabel(int number) {
    return 'Set $number';
  }

  @override
  String get repsLabel => 'Reps';

  @override
  String get weightLabel => 'Weight';
}
