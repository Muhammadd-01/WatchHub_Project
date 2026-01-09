# OneSignal Setup Guide for WatchHub

This guide explains how to configure OneSignal for Push Notifications using Firebase Cloud Messaging V1 API.

## 1. Create OneSignal Account & App

1.  Go to [OneSignal.com](https://onesignal.com/) and create a free account.
2.  Click **New App/Website**.
3.  Name: `WatchHub` (or your preferred name).
4.  Select Organization: Yours.
5.  Select Platform: **Google Android (FCM)**.
6.  Click **Next: Configure Your Platform**.

## 2. Get Firebase Service Account JSON

Instead of the legacy Server Key (which shows errors), we'll use FCM V1 API with a service account file.

1.  Open [Firebase Console](https://console.firebase.google.com/).
2.  Select your project: `watchhub-project`.
3.  Click the **gear icon** (Project Settings).
4.  Go to the **Service accounts** tab.
5.  Click **Generate new private key**.
6.  Click **Generate key** to download the JSON file.
7.  Save this file securely. **DO NOT commit it to Git.**

## 3. Configure OneSignal with FCM V1

1.  In OneSignal setup, select **Upload Firebase Service Account JSON**.
2.  Click **Upload** and select the JSON file you downloaded.
3.  OneSignal will automatically extract your credentials.
4.  Click **Save & Continue**.

## 4. Select SDK

1.  Select **Flutter** as the target SDK.
2.  Click **Save & Continue**.
3.  Copy your **App ID**. You will need this for the next step.
4.  Click **Done**.

## 5. App Configuration (.env)

1.  Open `watchhub_app/assets/.env`.
2.  Add your OneSignal App ID:

```env
ONESIGNAL_APP_ID=YOUR_ONESIGNAL_APP_ID
```
*(Replace `YOUR_ONESIGNAL_APP_ID` with the ID you copied in Step 4)*

## 6. Sending Test Notification

1.  Run the app on your device/emulator.
2.  Accept the Notification Permission prompt.
3.  In OneSignal Dashboard, go to **Messages** > **New Push**.
4.  Title: "Test Notification".
5.  Message: "It works!".
6.  Click **Review and Send** > **Send Message**.
7.  Check your device (even if app is closed).

## Troubleshooting

- **Service Account Tab Missing?** Make sure you're a project owner in Firebase.
- **JSON Upload Failed?** Ensure the JSON file is from the correct Firebase project.
- **No Notifications?** Check that you accepted permissions and OneSignal initialized successfully in logs.
