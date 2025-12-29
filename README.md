# 💸 BudgetSU: Smart Campus Expense Tracker

### Developed by:
Sinan Nalbur (32369)  
Ozan Kaçmaz (32123)  
Berat Kumru (31906)  
Kaan Ispiroğlu (32010)  
Fatma Elif Öztoprak (32407)

---

## 📖 Project Overview
**BudgetSU** is a mobile application that empowers university students to track, analyze, and visualize their daily expenses — while distinguishing between **on-campus** and **off-campus** spending.

The app leverages geolocation and budget visualization to show users how their money flows across different contexts.  
With instant analytics and a clean interface, BudgetSU encourages financial awareness and smarter daily decisions.

---

## 🎯 Problem & Solution

### ❌ The Problem
Students often struggle to manage personal finances because they:
- Lack awareness of where their money is spent (especially small daily purchases),
- Don’t separate necessary (on-campus) and optional (off-campus) expenses,
- Have no quick visual summary of budget progress.

### ✅ The Solution
BudgetSU provides a **real-time expense tracking and visualization system**.  
It automatically detects if a transaction occurred inside or outside the campus using GPS geofencing, then categorizes and visualizes it instantly through charts and dashboards — helping users stay within their daily, weekly, or monthly budget.

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

## 🧍 Target Audience
- **University Students:** Managing tight budgets and daily expenses on campus.  
- **Young Professionals:** Tracking spending between work and personal life.  
- **Financial Beginners:** Looking for a lightweight, visual budgeting tool.

---

## ⚙️ Core Features
1. **Expense Logging** – Record transactions with amount, category, note, and time.  
2. **On-Campus vs Off-Campus Detection** – Automatic classification using GPS.  
3. **Budget Goal Setting & Alerts** – Define spending limits and get notifications.  
4. **Visual Analytics Dashboard** – Charts showing spending breakdowns.  
5. **Offline Mode** – Firebase DB for local data storage.  
6. **Multi-Language Support** – English/Turkish UI with Dark/Light themes.

---

## 🌟 Nice-to-Have Features (Future Enhancements)
- Budget Reminders & Notifications  
- Cloud Backup / Firebase Sync  
- CSV Export & Import History  
- AI Spending Insights  
- Gamified Saving Badges  

---

## 💾 Platform & Data Storage

### 🧩 Platform
Flutter 3.24+ using Dart 3.5 for Android & iOS.

### 🗄️ Data Storage
- **Database:** Firebase (NoSQL) local database for offline use.  
- **Stored Data:**  
  - Transaction Records: amount, category, time, location  
  - User Preferences: currency, theme, budget limit  
  - Campus Zones: lat/lng definitions in JSON  

---

## ⚠️ Potential Challenges
- Accurate Geofencing with minimal battery use  
- Privacy of local financial data  
- Consistency across iOS/Android  
- Chart performance with large data sets  

---

## 💎 Unique Selling Point (USP)
BudgetSU uniquely separates on-campus and off-campus spending, showing exactly where money goes.  
Its live geolocation integration and visual budget feedback system make it ideal for students managing small, frequent transactions.

---

## 🛠️ Tech Stack Summary
| Category | Tools / Frameworks |
|:--|:--|
| Frontend | Flutter 3.24 |
| Backend | Firebase Firestore (planned) |
| Database | Fireabse (NoSQL) |
| UI | Flutter Widgets, fl_chart |
| Location | geolocator / geofence_service |

---

## 📱 Example User Flow
1. User sets a daily budget.  
2. Logs expenses throughout the day.  
3. App auto-tags each as on/off-campus.  
4. Dashboard updates visually.  
5. User reviews summary and adjusts habits.

---

## 🚀 Future Work
- Firebase cloud backup  
- Gamified reports  
- Predictive alerts  
- Integration with campus payment systems

---

## 📄 License
This project is developed as part of the **CS310 Mobile App Development** course and intended for educational purposes only.

---

## 💚 Acknowledgements
We thank our CS310 instructors and TAs for their continuous guidance and feedback.

---

## 🧠 Summary
**BudgetSU = Awareness + Simplicity + Control**  
A smart and visual way to understand your spending — anytime, anywhere, on and off campus.

---

## 🧪 Testing Strategy 

### Test Coverage Details

* **1. Unit Test (Logic):**
  * **File:** `test/goals_test.dart`
  * **Purpose:** Verifies that the remaining amount calculation (Target - Saved) works correctly without UI dependencies.
  
* **2. Widget Test (Interaction):**
  * **File:** `test/goals_test.dart`
  * **Purpose:** Simulates a user tapping the "Add Money" button and verifies that the displayed balance updates correctly (e.g., from $0 to $100), ensuring State Management works as expected.

### How to Run Tests

To run the specific Unit and Widget tests for the Goals & State Management module, use the following command:

```bash
flutter test test/goals_test.dart
```

---

## ⚠️ Known Limitations & Design Choices

In accordance with the project requirements, we have identified the following limitations and intentional design decisions:

* **Savings Overflow (Intentional Design):**
  Users are allowed to add funds that exceed the set goal amount (e.g., saving $1400 for a $1000 target). This is a design choice to accommodate extra savings or price inflation. To prevent UI rendering errors, the visual progress bar is programmatically capped at 100% (1.0) while preserving the actual monetary value in the background.

* **Firebase Synchronization:**
  While the app supports local data entry, an active internet connection is required to synchronize data with the Cloud Firestore database and authenticate users via Firebase Auth.

* **Geofencing Accuracy:**
  The distinction between "On-Campus" and "Off-Campus" transactions relies on the device's GPS accuracy, which may vary depending on signal strength and environment (e.g., indoors).

