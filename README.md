# 💸 BudgetSU: Smart Campus Expense Tracker

### Developed by:
Sinan Nalbur (32369)  
Ozan Kaçmaz (32123)  
Berat Kumru (31906)  
Kaan Ispiroğlu (32010)  
Fatma Elif Öztoprak (32407)

---

## 📖 Project Overview

**BudgetSU** is a mobile application that empowers university students to track, analyze, and visualize their daily expenses. The app provides real-time expense tracking with automatic categorization, budget goal setting, and comprehensive analytics dashboards.

With instant analytics and a clean interface supporting both light and dark themes, BudgetSU encourages financial awareness and smarter daily decisions.

### 🎯 Motivation

Students often struggle to manage personal finances because they:
- Lack awareness of where their money is spent (especially small daily purchases)
- Don't have a quick visual summary of budget progress
- Need a simple, intuitive tool to track expenses and set savings goals

BudgetSU solves these problems by providing a **real-time expense tracking and visualization system** that helps users stay within their daily, weekly, or monthly budgets through interactive charts and dashboards.

---

## 🚀 Setup & Installation

### Prerequisites

- **Flutter SDK**: Version 3.24+ (Dart 3.9.2+)
- **Firebase Account**: A Firebase project with Authentication and Firestore enabled
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (for Android development)
- **Xcode** (for iOS development, macOS only)

### Step-by-Step Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd BudgetSU_2
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**

   **For Android:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or select an existing one
   - Add an Android app to your Firebase project
   - Download `google-services.json`
   - Place it in `android/app/google-services.json`
   - The file should already exist in the project, but if you're setting up a new Firebase project, replace it with your own

   **For iOS:**
   - In Firebase Console, add an iOS app to your project
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/GoogleService-Info.plist`
   - The file should already exist in the project, but if you're setting up a new Firebase project, replace it with your own

   **Generate Firebase Options:**
   ```bash
   flutter pub global activate flutterfire_cli
   flutterfire configure
   ```
   This will generate `lib/firebase_options.dart` with your Firebase configuration.

4. **Enable Firebase Services**
   - In Firebase Console, enable **Authentication** (Email/Password provider)
   - Enable **Cloud Firestore** database
   - Set up Firestore security rules (see `firestore.rules` in the project root)

5. **Run the Application**
   ```bash
   flutter run
   ```
   
   Or run on a specific device:
   ```bash
   flutter run -d <device-id>
   ```
   
   To see available devices:
   ```bash
   flutter devices
   ```

### 📱 Building for Release

**Android:**
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## 🧪 Testing

The project includes unit and widget tests. To run all tests:

```bash
flutter test
```

To run tests with coverage:
```bash
flutter test --coverage
```

### Test Files

The project includes the following test files with detailed test cases:

- **`test/goal_model_test.dart`** - Unit tests for the `GoalModel` class
  - **Test Case 1: "isCompleted and progress should calculate correctly"**
    - Tests that when `current >= target` (100.0/100.0), `isCompleted` returns `true` and `progress` is `1.0`
    - Tests that when `current < target` (50.0/100.0), `isCompleted` returns `false` and `progress` is `0.5`
  
  - **Test Case 2: "remaining should calculate correctly and not be negative"**
    - Tests that remaining amount is calculated correctly (target - current = 100.0 - 30.0 = 70.0)
    - Tests edge case where current exceeds target (150.0/100.0), ensuring `remaining` returns `0.0` instead of negative value

- **`test/transaction_model_test.dart`** - Unit tests for the `TransactionModel` class
  - **Test Case: "toFirestore should convert model to map correctly"**
    - Tests that all transaction fields (title, category, amount, isIncome, campusLocation, createdBy) are correctly serialized to Firestore format
    - Verifies that date fields are converted to `Timestamp` objects as required by Firestore
    - Ensures data integrity when converting model to Firestore document format

- **`test/widget_test.dart`** - Widget test for goal progress display
  - **Test Case: "GoalModel progress calculation displays correctly"**
    - Tests that goal model properties are correctly displayed in Flutter widgets
    - Verifies that goal title, progress percentage (75%), remaining amount ($25.00), and completion status are rendered correctly in the UI
    - Ensures UI correctly reflects the underlying model data (current: 75.0, target: 100.0)

---

## ⚙️ Core Features

1. **Expense Logging** – Record transactions with amount, category, note, and timestamp
2. **Budget Goal Setting** – Define spending limits and savings goals
3. **Visual Analytics Dashboard** – Interactive charts showing spending breakdowns by category
4. **Goal Tracking** – Set and track savings goals with progress visualization
5. **Theme Support** – Light and dark theme modes with persistent user preferences
6. **User Authentication** – Secure login and registration using Firebase Authentication
7. **Cloud Sync** – Real-time data synchronization with Firebase Firestore

---

## 🛠️ Tech Stack

| Category | Tools / Frameworks |
|:--|:--|
| Frontend | Flutter 3.24+ |
| Backend | Firebase Firestore |
| Authentication | Firebase Auth |
| State Management | Provider |
| Local Storage | SharedPreferences |
| Charts | fl_chart |
| Language | Dart 3.9.2+ |

---

## ⚠️ Known Limitations & Bugs

### Current Limitations

1. **Campus Location Feature Removed**
   - The on-campus/off-campus geofencing feature has been removed from the current version
   - Transactions no longer include automatic location-based categorization
   - This feature may be re-implemented in future versions

2. **Platform Support**
   - Primary development and testing focused on Android
   - iOS support is available but may have platform-specific issues
   - Web platform is not currently supported

3. **Offline Functionality**
   - App requires internet connection for authentication and data sync
   - Offline mode is limited; data is stored in Firestore and requires connectivity

4. **Firebase Configuration**
   - The `firebase_options.dart` file may need to be regenerated if using a different Firebase project
   - Ensure Firebase project has proper security rules configured

### Known Issues

- None currently reported. If you encounter any bugs, please report them via GitHub Issues.

---

## 📱 Example User Flow

1. User registers/logs in with email and password
2. Sets a daily budget limit in Settings
3. Logs expenses throughout the day with categories
4. Views real-time analytics and spending breakdowns
5. Sets savings goals and tracks progress
6. Reviews summary and adjusts spending habits

---

## 🚀 Future Work

- Budget Reminders & Notifications
- Enhanced offline mode with local caching
- CSV Export & Import functionality
- AI Spending Insights
- Gamified Saving Badges
- Re-implementation of campus location detection
- Multi-currency support

---

## 👥 Team Roles

| Member | Role | Responsibilities |
|:--|:--|:--|
| **Sinan Nalbur** | **Project Coordinator** | Oversees meetings, milestones, and progress tracking. |
| **Ozan Kaçmaz** | **Documentation & Submission Lead** | Prepares reports, proposals, and ensures timely submissions. |
| **Berat Kumru** | **Testing & Quality Assurance Lead** | Tests app functionality and maintains quality standards. |
| **Kaan Ispiroğlu** | **Learning & Research Lead** | Researches relevant Flutter libraries, APIs, and new tools. |
| **Elif Öztoprak** | **Presentation & Communication Lead** | Prepares presentations and communicates project updates. |
| *(Sinan Nalbur)* | **Integration & Repository Lead** | Manages Git/GitHub repository, merging, and version control. |

---

## 📄 License

This project is developed as part of the **CS310 Mobile App Development** course and intended for educational purposes only.

---

## 💚 Acknowledgements

We thank our CS310 instructors and TAs for their continuous guidance and feedback.

---

## 🧠 Summary

**BudgetSU = Awareness + Simplicity + Control**  
A smart and visual way to understand your spending — anytime, anywhere.
