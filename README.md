# Lifelink – Admin Web Panel

This is the web-based admin interface for the Lifelink organ donation platform. It allows authorized administrators to manage users, approve organ matches, create events, and oversee platform activity. This panel works in coordination with the Lifelink mobile application.

## 🔧 Features

- Admin login and access control
- View and manage registered users (donors and recipients)
- Approve or deny organ match requests
- Create and publish organ donation events
- Assign roles to additional admin accounts
- Dashboard view of platform activity

## 🛠️ Technology Stack

- **Frontend**: (Specify here: Flutter Web / HTML+CSS+JS / React / etc.)
- **Backend**: Firebase (Firestore, Authentication, Storage)

## 🔐 Authentication

Only users with an `admin` role in Firestore are granted access. Role checks are enforced in the frontend and backend.

## 📄 License

This admin panel is for academic and research demonstration purposes only. Do not use in real healthcare settings without compliance validation.
