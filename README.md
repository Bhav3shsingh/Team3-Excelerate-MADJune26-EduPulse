[![Run App](https://img.shields.io/badge/EduPulse-Run%20Live%20App-brightgreen?style=for-the-badge&logo=flutter)](https://bhav3shsingh.github.io/Team3-Excelerate-MADJune26-EduPulse/)

# App Proposal: EduPulse
## ​1. Purpose of the App
​EduPulse is a dual-sided educational ecosystem designed to bridge the gap between event coordinators and participants. The application solves communication gaps, automates attendance tracking, and simplifies the feedback loop, creating a frictionless administrative experience while boosting learner engagement.

Wireframe Design Strategy (current app screens)

## Screen Name/Core Elements Include:
1. Welcome Screen (`WelcomePage`) - landing page with a full-width background image, centered welcome text, and buttons for learner and admin login flows.
2. Login Screen (`LoginPage`) - email/password fields, login button, forgot password link, and a create-account link that passes the selected user type.
3. Register Screen (`RegisterPage`) - registration form for new users, including user details and role selection for learners or admins.
4. Main Screen (`MainScreen`) - bottom navigation container with Dashboard, Programs, and Profile tabs for authenticated users.
5. Dashboard Screen (`DashboardPage`) - role-aware dashboard content, summary cards, and quick access to programs or notifications.
6. Program Listing Screen (`ProgramListingPage`, `ProgramListingPageAdmin`) - Firestore-backed program cards, filtered by user role with admin-specific management actions.
7. Program Details Screen (`ProgramDetails`) - detailed event/program information, schedule fields, participant management, and action buttons for join or edit.
8. Program Create/Edit Screen (`ProgramCreateScreen`, `ProgramEditScreen`) - admin forms for creating new programs or updating existing program data.
9. Pending Admin Approval Screen (`MasterAdminApprovalPage`) - admin review list for pending user approvals and role validation.
10. Notifications Screen (`NotificationScreen`) - view and browse app notifications and announcements.
11. New Notification Screen (`Notifier`) - admin notification creation interface for sending messages to users.
12. Feedback/Form Screen (`FormScreen`) - feedback and form submission screen for program responses.
13. Admin Review Screen (`AdminReview`) - admin review and moderation screen for feedback or program assessments.

<img height="510" alt="image" src="https://github.com/user-attachments/assets/07f452a9-fcad-4e8e-8350-94b8491af0ef" />
<img height="510" alt="image" src="https://github.com/user-attachments/assets/667788b8-ab5c-4865-bf30-1dc829048f93" />
<img height="510" alt="image" src="https://github.com/user-attachments/assets/3bd7aa99-2290-407c-b8d6-fd4e40c6b4fb" />
<img height="510" alt="image" src="https://github.com/user-attachments/assets/8ba34596-d25e-462d-b460-3d3a1fb9a8ea" />
<img height="510" alt="image" src="https://github.com/user-attachments/assets/a2c5edd6-f43c-4a47-be2a-383725b32e5e" />
<img height="510" alt="image" src="https://github.com/user-attachments/assets/aa1f38d9-a3d6-4867-bb9d-cbeccc81732c" />
<img height="510" alt="image" src="https://github.com/user-attachments/assets/ab7ce0f0-c180-4c28-b678-622f101403be" />
<img height="510"  alt="image" src="https://github.com/user-attachments/assets/99e186ac-4519-48e6-ad7b-05ce255a50b5" />
<img height="510" alt="image" src="https://github.com/user-attachments/assets/65427869-2bd9-4ab5-9496-f05808bff116" />

## ​2. Target Users & Key Features
###  ​A. Learners 
​Users looking to discover educational programs, register for events, and easily provide feedback.
​Personalized Program Feed: Browse upcoming workshops, bootcamps, or educational programs filtered by interest tags.
​One-Tap RSVP & Calendar Sync: Instantly register for events and automatically add them to Google or Outlook calendars.
​QR-Based Attendance: Scan a dynamic presentation QR code at the event venue to instantly check in and unlock digital materials.
​Micro-Feedback Forms: Submit quick evaluation surveys via targeted post-event push notifications.

### ​B. Admins
​Program coordinators, teachers, or HR managers who need to organize events and evaluate engagement.
​Live Broadcast Panel: Create and pin mandatory announcements or send push notifications for schedule changes.
​Attendance Tracker: Generate unique event QR codes and track live check-ins in real time.
​Data & Analytics Dashboard: View visual charts showing registration rates, actual attendance, and aggregated feedback scores.
## ​3. Short User Journeys
#### ​User Journey 1: The Learner (Event Registration & Feedback)
​Discovery: Sarah (Learner) opens the app and sees a pinned announcement on her Home Screen for an upcoming "AI Tools in Education" workshop.
​Registration: She clicks the banner, reads the Program Details, and taps "Register." The event instantly links to her calendar.
​Attendance: On the day of the event, she scans the presenter's QR code via the app to mark herself present.
​Feedback: Ten minutes after the workshop ends, she receives a push notification, opens a 3-question survey, drafts her feedback, and submits it in under 30 seconds.
### ​User Journey 2: The Admin (Event Management & Tracking)
​Creation: Alex (Admin) logs into his dashboard, inputs the details for a new training cohort, and hits "Publish."
​Broadcast: He uses the Live Broadcast Panel to send a push notification to all eligible learners.
​Monitoring: During the live session, Alex displays the automated check-in QR code on the main screen and watches his dashboard populate with real-time attendance numbers.
​Evaluation: The next morning, Alex checks the Analytics Dashboard to review the learner satisfaction metrics and exports the feedback report for his team.


# Other Documents
| Document | Description |
|-----------|-------------|
| [README.md](./README.md) | Project overview |
| [CHANGELOG.md](./CHANGELOG.md) | Weekly development history |
| [CONTRIBUTION.md](./CONTRIBUTION.md) | Contribution guidelines |
