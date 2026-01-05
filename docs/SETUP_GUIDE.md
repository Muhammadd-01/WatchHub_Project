# WatchHub Complete Setup Guide

## Overview

This comprehensive guide covers the complete setup process for **Firebase** and **Supabase** integration with the WatchHub application. Follow each step carefully.

---

## Part 1: Firebase Project Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `watchhub-project`
4. Disable Google Analytics (optional)
5. Click **"Create project"** and wait for completion

### Step 2: Enable Authentication

1. In Firebase Console, go to **Build** → **Authentication**
2. Click **"Get started"**
3. Click on **Email/Password** under Sign-in providers
4. Enable the first toggle **"Email/Password"**
5. Click **"Save"**

### Step 3: Create Firestore Database

1. Go to **Build** → **Firestore Database**
2. Click **"Create database"**
3. Select your database edition (Enterprise works fine)
4. Choose **"Start in production mode"**
5. Select a Cloud Firestore location closest to your users
6. Click **"Create"** and wait for provisioning

---

## Part 2: Firestore Security Rules

> **Important**: Since you created an Enterprise Firestore database, you need to add security rules.

1. Go to **Firestore Database** → **Rules** tab
2. Delete the existing rules and paste the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // =========================================================
    // DEVELOPMENT RULES (Active)
    // Use these now to fix the "Permission Denied" errors
    // =========================================================
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // =========================================================
    // PRODUCTION RULES (Reference)
    // Use these later when you are ready to launch.
    // NOTE: These will BLOCK the "SeederService" unless you are Admin.
    // =========================================================
    /*
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if false; // Users cannot delete their account
    }
    
    match /products/{productId} {
      allow read: if true; // Anyone can browse products
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      
      // Reviews subcollection
      match /reviews/{reviewId} {
        allow read: if true;
        allow create: if request.auth != null;
        allow update, delete: if request.auth != null && 
          resource.data.userId == request.auth.uid;
      }
    }
    
    match /carts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /items/{itemId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    match /wishlists/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /items/{itemId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    match /orders/{orderId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
      // Only admins can update orders (status changes)
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /feedbacks/{feedbackId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    */
  }
}
```

3. Click **"Publish"** to save the rules

---

## Part 3: Supabase Setup (For Images ONLY)

We use Supabase **Storage** to host product and profile images. We store the *Image URL* in Firestore. We do NOT use Supabase Auth or Database.

### 1. Create a Supabase Project
1.  Go to [Supabase.com](https://supabase.com) and create a new project.
2.  Note down your `Project URL` and `Anon Key`.

### 2. Create Storage Buckets
1.  Go to **Storage** in the left sidebar.
2.  Create a new bucket named **`product-images`**:
    *   **Public bucket**: CHECKED (On) - *Crucial for displaying images in the app*
    *   **Allowed MIME types**: `image/*`
    *   **File size limit**: 5MB (recommended)
3.  Create another bucket named **`profile-images`** (same settings).

### 3. Set Storage Policies (Permissions)
Since we are using Firebase Auth, we will make the buckets "Publicly Readable" and allow anyone (or your specific backend logic) to upload. For development simplicity, we will allow public uploads.

1.  In the Storage dashboard, click **Configuration** or **Policies** for your bucket.
2.  Click **New Policy** -> **For full customization**.
3.  **Name**: `Allow Public Access`
4.  **Allowed Operations**: Select `SELECT` (Read), `INSERT` (Upload), `UPDATE`, `DELETE`.
5.  **Target roles**: Select `anon` (or all).
6.  **Review** and **Save**.

*Repeat for both `product-images` and `profile-images`.*

**Note:** In a production app with Firebase Auth + Supabase Storage, users would typically upload images via the app, and you might want to restrict `INSERT/UPDATE` operations to only authenticated users. However, since Supabase doesn't know about Firebase users easily, using an "Open" policy for development is the easiest path.

### 4. Code Usage
You don't need `flutter_supabase` auth plugins. You just need the `supabase_flutter` package initialized in `main.dart` (which we did).

To upload an image:
```dart
final supabase = Supabase.instance.client;
final fileBytes = ...; // Your image bytes
final fileName = 'user_123_profile.png';

await supabase.storage.from('profile-images').uploadBinary(
  fileName,
  fileBytes,
  fileOptions: const FileOptions(upsert: true),
);

// Get the Public URL to save in Firestore
final imageUrl = supabase.storage.from('profile-images').getPublicUrl(fileName);
```

---

## Part 4: Connect Android App to Firebase

### Step 4.1: Register Android App in Firebase

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **"Your apps"** section
3. Click the **Android icon** to add an Android app
4. Enter package name: `com.watchhub.watchhub_app`
   - This should match your `android/app/build.gradle` applicationId
5. Enter app nickname: `WatchHub Android`
6. Leave Debug signing certificate SHA-1 empty for now (optional)
7. Click **"Register app"**

### Step 3.2: Download google-services.json

1. Click **"Download google-services.json"**
2. **Place the file** at:
   ```
   watchhub_app/android/app/google-services.json
   ```
   
   Your folder structure should look like:
   ```
   watchhub_app/
   ├── android/
   │   ├── app/
   │   │   ├── build.gradle
   │   │   ├── google-services.json  ← PUT IT HERE
   │   │   └── src/
   │   ├── build.gradle
   │   └── settings.gradle
   └── lib/
   ```

### Step 3.3: Configure Android Build Files

**File 1: `android/build.gradle`** (Project-level)

Add the Google services classpath:

```gradle
buildscript {
    ext.kotlin_version = '1.8.22'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'  // ADD THIS LINE
    }
}
```

**File 2: `android/app/build.gradle`** (App-level)

At the bottom, add the plugin:

```gradle
// At the very end of the file, add:
apply plugin: 'com.google.gms.google-services'
```

Also ensure your `minSdkVersion` is at least 21:

```gradle
android {
    defaultConfig {
        applicationId "com.watchhub.watchhub_app"
        minSdkVersion 21  // Must be 21 or higher
        targetSdkVersion 34
        // ...
    }
}
```

---

## Part 4: Connect iOS App to Firebase

### Step 4.1: Register iOS App in Firebase

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Click the **iOS icon** to add an iOS app
3. Enter bundle ID: `com.watchhub.watchhubApp`
   - Check your `ios/Runner.xcodeproj/project.pbxproj` for actual bundle ID
4. Enter app nickname: `WatchHub iOS`
5. Leave App Store ID empty
6. Click **"Register app"**

### Step 4.2: Download GoogleService-Info.plist

1. Click **"Download GoogleService-Info.plist"**
2. **Place the file** at:
   ```
   watchhub_app/ios/Runner/GoogleService-Info.plist
   ```

   Your folder structure should look like:
   ```
   watchhub_app/
   ├── ios/
   │   ├── Runner/
   │   │   ├── AppDelegate.swift
   │   │   ├── GoogleService-Info.plist  ← PUT IT HERE
   │   │   ├── Info.plist
   │   │   └── Assets.xcassets/
   │   └── Runner.xcodeproj/
   └── lib/
   ```

### Step 4.3: Add to Xcode Project

1. Open the iOS project in Xcode:
   ```bash
   cd watchhub_app/ios
   open Runner.xcworkspace
   ```

2. Right-click on `Runner` folder in Xcode navigator
3. Select **"Add Files to Runner..."**
4. Select `GoogleService-Info.plist`
5. Make sure **"Copy items if needed"** is checked
6. Click **"Add"**

### Step 4.4: Update iOS Deployment Target

In `ios/Podfile`, ensure minimum iOS version:

```ruby
platform :ios, '12.0'  # Must be 12.0 or higher for Firebase
```

Then run:
```bash
cd ios
pod install
```

---

## Part 5: Update main.dart for Firebase

After FlutterFire configure generates `firebase_options.dart`, update your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  // This is generated by flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Rest of initialization...
  runApp(const WatchHubApp());
}
```

---

## Part 6: Supabase Setup for Image Storage

### Step 6.1: Create Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Sign in or create account
3. Click **"New project"**
4. Fill in:
   - **Organization**: Select or create one
   - **Project name**: `watchhub-storage`
   - **Database Password**: Generate a strong password (save it!)
   - **Region**: Choose closest to your users
5. Click **"Create new project"**
6. Wait 2-3 minutes for setup

### Step 6.2: Get API Credentials

1. In your Supabase project, go to **Settings** → **API**
2. Copy these two values:
   - **Project URL**: `https://xxxxxxxx.supabase.co`
   - **anon public** key: Long string starting with `eyJ...`

### Step 6.3: Create Storage Buckets

1. Go to **Storage** in left sidebar
2. Click **"New bucket"**

**Create Bucket 1: product-images**
- Name: `product-images`
- **Public bucket**: Toggle ON ✅
- Click **"Create bucket"**

**Create Bucket 2: profile-images**
- Name: `profile-images`
- **Public bucket**: Toggle ON ✅
- Click **"Create bucket"**

### Step 6.4: Configure Bucket Policies

For each bucket, you need to allow public read access:

1. Click on `product-images` bucket
2. Click **"Policies"** tab
3. Click **"New Policy"**
4. Select **"For full customization"**
5. Create policy:
   - **Policy name**: `Public Read Access`
   - **Allowed operation**: SELECT
   - **Target roles**: Leave empty (allows all)
   - **USING expression**: `true`
6. Click **"Review"** then **"Save policy"**

Repeat for upload policy:
1. Click **"New Policy"**
2. Select **"For full customization"**
3. Create policy:
   - **Policy name**: `Authenticated Upload`
   - **Allowed operation**: INSERT
   - **Target roles**: `authenticated`
   - **WITH CHECK expression**: `true`
4. Click **"Review"** then **"Save policy"**

### Step 6.5: Update main.dart for Supabase

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://YOUR_PROJECT_ID.supabase.co',  // Replace with your URL
    anonKey: 'YOUR_ANON_KEY',                     // Replace with your key
  );
  
  runApp(const WatchHubApp());
}
```

---

## Part 7: Firestore Collection Structure

Here's the complete database schema:

### `users/{uid}` - User profiles
```
{
  "uid": "firebase-auth-uid",      // Same as document ID
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "profileImageUrl": "https://...", // Supabase URL
  "role": "customer",               // "customer" or "admin"
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### `products/{productId}` - Product catalog
```
{
  "name": "Submariner Date",
  "brand": "Rolex",
  "description": "...",
  "price": 14500.00,
  "originalPrice": 15000.00,        // For sales
  "imageUrl": "https://...",        // Supabase URL
  "category": "Luxury",
  "stock": 5,
  "specifications": {
    "Movement": "Automatic",
    "Case Size": "41mm",
    "Water Resistance": "300m"
  },
  "rating": 4.8,
  "reviewCount": 24,
  "isFeatured": true,
  "isNewArrival": false,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### `carts/{uid}/items/{productId}` - Shopping cart
```
{
  "productId": "abc123",
  "quantity": 2,
  "addedAt": Timestamp
}
```

### `wishlists/{uid}/items/{productId}` - Wishlist
```
{
  "productId": "abc123",
  "addedAt": Timestamp
}
```

### `orders/{orderId}` - Orders
```
{
  "userId": "firebase-auth-uid",
  "orderNumber": "WH-2025-001234",
  "items": [...],
  "subtotal": 29000.00,
  "shippingCost": 0,
  "tax": 2610.00,
  "totalAmount": 31610.00,
  "status": "pending",
  "shippingAddress": {...},
  "paymentMethod": "card",
  "createdAt": Timestamp
}
```

---

## Part 8: Auth UID Flow (Critical)

### How It Works

```
User signs up
     ↓
Firebase Auth creates user with UID (e.g., "abc123xyz")
     ↓
AuthService.signUp() receives the UID
     ↓
Firestore document created at users/abc123xyz
     ↓
UID used for carts/abc123xyz, wishlists/abc123xyz, etc.
```

### Why This Matters

- **One source of truth**: Firebase Auth UID is the user identifier everywhere
- **Simple queries**: `carts/{uid}` means no complex user lookups
- **Security rules**: Easy to verify `request.auth.uid == userId`

---

## Part 9: Testing Your Setup

### Test 1: Firebase Connection

```bash
cd watchhub_app
flutter run
```

1. App should load without Firebase errors
2. Try signing up with a new email
3. Check Firebase Console → Authentication → Users
4. Your new user should appear

### Test 2: Firestore Connection

1. After successful signup, check Firestore
2. Go to Firebase Console → Firestore Database
3. A new `users` document should exist with your UID

### Test 3: Supabase Connection

1. Try uploading a profile image (when implemented)
2. Check Supabase → Storage → profile-images
3. The image should appear

---

## Part 10: Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"
- Ensure `Firebase.initializeApp()` is called before `runApp()`
- Check that `firebase_options.dart` exists in `lib/`

### Error: "PERMISSION_DENIED" in Firestore
- Check that security rules are published
- Ensure user is authenticated
- Verify the document path matches rules

### Error: "google-services.json not found"
- Verify file is in `android/app/` folder
- Check file name is exactly `google-services.json`

### Error: "GoogleService-Info.plist not found"
- Ensure file is added to Xcode project (not just copied)
- Right-click Runner → Add Files → Select the plist

### Products not loading
- Run the app once to trigger SeederService
- Check Firestore for `products` collection
- Verify you have 15 seeded products

---

## Quick Reference

| Service | Console URL |
|---------|-------------|
| Firebase Console | https://console.firebase.google.com |
| Supabase Dashboard | https://supabase.com/dashboard |

| File | Location |
|------|----------|
| google-services.json | `android/app/google-services.json` |
| GoogleService-Info.plist | `ios/Runner/GoogleService-Info.plist` |
| firebase_options.dart | `lib/firebase_options.dart` |

| Command | Purpose |
|---------|---------|
| `flutterfire configure` | Generate Firebase options |
| `flutter pub get` | Install dependencies |
| `cd ios && pod install` | Install iOS pods |
| `flutter run` | Run the app |

---

## Part 11: Google Sign-In Setup

To enable Google Sign-In for your Flutter app, you need to configure it in the Firebase Console and add your Android app's SHA-1 key.

### Step 11.1: Enable Google Provider in Firebase Console

1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Select your project (**WatchHub**).
3.  In the left sidebar, click on **Authentication**.
4.  Go to the **Sign-in method** tab.
5.  Click on **Add new provider** and select **Google**.
6.  Click the **Enable** toggle.
7.  Select a **Support email for project** from the dropdown.
8.  Click **Save**.

### Step 11.2: Add SHA-1 and SHA-256 Keys for Android

Google Sign-In on Android requires you to register your app's SHA-1 certificate fingerprint in Firebase.

#### 1. Generate the SHA-1 Key
Run the following command in your terminal (Windows):

```powershell
cd android
./gradlew signingReport
cd ..
```

Wait for the process to finish. It will output keys for different build variants (debug, release, etc.). Look for the section labeled **Task :app:signingReport** and find the **Variant: debug**.

Copy the **SHA1** and **SHA-256** keys. They look like `AA:BB:CC:...`.

#### 2. Add Key to Firebase
1.  In Firebase Console, click the **Settings (gear icon)** > **Project settings**.
2.  Scroll down to the **Your apps** section.
3.  Select your **Android app** (com.example.watchhub_app).
4.  Click **Add fingerprint**.
5.  Paste the **SHA-1** key you copied and click **Save**.
6.  (Optional but recommended) Add the **SHA-256** key as well.

#### 3. Update google-services.json
1.  After adding the fingerprint, download the updated `google-services.json` file.
2.  Replace the existing file in `android/app/google-services.json` with this new one.

### Step 11.3: Enable Developer Mode (Windows)

Note: If you encountered errors running commands or plugins, ensure **Developer Mode** is enabled on Windows.
1.  Open **Settings** > **Privacy & security** > **For developers**.
2.  Toggle **Developer Mode** to **On**.

---

## Part 12: Real-Time Push Notifications (FCM)

To ensure notifications appear on the device's lock screen/tray even when the app is closed, you must configure the FCM Server Key in the Admin Panel.

### 12.1: Get FCM Server Key
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (**WatchHub**)
3. Click the **Settings (gear icon)** > **Project settings**
4. Go to the **Cloud Messaging** tab
5. Look for **Cloud Messaging API (Legacy)**.
   - > [!IMPORTANT]
   - > If it says **Disabled**, click the **three vertical dots** (⋮) on the far right of that row.
   - > Select **Manage API in Google Cloud Console**.
   - > In the new tab, click the blue **ENABLE** button.
6. **CRITICAL**: Go back to the Firebase Console tab and **REFRESH the page**. 
7. You will now see a section called **Server key**. Copy the long string next to it.

### 12.2: Update Admin Panel
1. Open `watchhub_admin/lib/providers/admin_order_provider.dart`
2. Find the line: `const String serverKey = 'YOUR_FCM_SERVER_KEY';`
3. Replace `'YOUR_FCM_SERVER_KEY'` with the key you copied.

### 12.3: Verification
1. Open the WatchHub App on a real device or emulator.
2. Sign in or Sign up (this will save your device token).
3. Close the app completely.
4. Use the Admin Panel to update an order status for your user.
5. You should receive a push notification on your device tray!
---

## Part 13: Free Email Relay (Google Apps Script)

Since the Firebase "Trigger Email" extension requires a paid Blaze plan, we have implemented a **100% Free** way to send emails using your own Gmail account via Google Apps Script.

### 13.1: Create the Email Relay
1. Go to [script.google.com](https://script.google.com/) and click **"New Project"**.
2. Delete any existing code and paste this exact script:

```javascript
function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);
    var to = data.to;
    var subject = data.subject;
    var message = data.message;
    
    MailApp.sendEmail({
      to: to,
      subject: subject,
      htmlBody: message
    });
    
    return ContentService.createTextOutput(JSON.stringify({status: "success"}))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({status: "error", message: error.toString()}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
```

3. Click the **Save** icon and name it "WatchHub Email Relay".
4. Click **Deploy** > **New Deployment**.
5. Select type: **Web App**.
6. Set **Execute as**: **Me**.
7. Set **Who has access**: **Anyone** (This is safe as only your Admin Panel will know the URL).
8. Click **Deploy**.
9. **Copy the "Web App URL"** shown at the end.

### 13.2: Update Admin Panel
1. Open `watchhub_admin/lib/providers/admin_order_provider.dart`
2. Find the line: `static const String emailRelayUrl = 'YOUR_EMAIL_RELAY_URL';`
3. Replace `'YOUR_EMAIL_RELAY_URL'` with the URL you just copied.

### 13.3: Verification
1. Update an order status in the Admin Panel.
2. Check your debug console! You should see `Email sent via Relay successfully`.
3. The user will receive the updated status email instantly for free.


