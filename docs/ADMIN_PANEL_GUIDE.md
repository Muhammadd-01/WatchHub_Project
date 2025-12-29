# WatchHub Admin Panel Setup & Usage Guide

This guide explains how to set up, run, and usage the WatchHub Admin Panel.

## 1. Firebase Connection
The Admin Panel is already configured to use the same Firebase project as your mobile application (`watchhub-project-74e0d`).

- **Configuration File**: `firebase_options.dart` is present in `lib/`.
- **Initialization**: `main.dart` initializes Firebase using these options.

**No additional setup is required** if the file `lib/firebase_options.dart` exists and contains your project keys.

## 2. Running the Admin Panel
The Admin Panel is designed primarily for **Web** usage but can run on MacOS/Windows/Linux.

### Prerequisites
- Flutter SDK installed (3.6.0+)
- `flutter pub get` run in the `watchhub_admin` directory.

### Commands
To run the admin panel:
```bash
cd watchhub_admin
flutter run -d chrome
```

## 3. First Time Access (Creating an Admin)
The Admin Panel implements Role-Based Access Control (RBAC). You cannot simply sign up as an admin. You must promote an existing user or manually create an admin user in Firestore.

**How to create your first Admin:**
1. Sign Up a user in the **Mobile App** (e.g., `admin@watchhub.com`).
2. Go to the [Firebase Console](https://console.firebase.google.com/).
3. Navigate to **Firestore Database** -> `users` collection.
4. Find the document corresponding to your user (by UID).
5. Update the field `role` from `'customer'` to `'admin'`.
   - If the field doesn't exist, add it:
     - Field: `role`
     - Type: `string`
     - Value: `admin`

Now you can log in to the Admin Panel with email `admin@watchhub.com`.

## 4. Features
- **Dashboard**: View key metrics ( Revenue, Orders, Users).
- **Products**:
  - **List**: View all products with images, prices, and stock.
  - **Add/Edit**: Create or modify products. (Includes basic form; Image uploading requires Firebase Storage rules to be open or authenticated).
  - **Delete**: Remove products.
- **Orders**:
  - **List**: View all customer orders.
  - **Update Status**: Change order status (Pending -> Processing -> Shipped -> Delivered).
- **Users**: View registered users (Read-only list currently).

## 5. Troubleshooting
- **"Access Denied"**: Ensure your user document in Firestore has `role: 'admin'`.
- **Images not loading**: Check `firebase_storage` rules to allow reads.
- **Product Add Failed**: Check Firestore Rules.

```
// Recommended Basic Firestore Rules for Development
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // WARNING: Lock this down for production!
    }
  }
}
```
