# Auth0 Setup Guide for WatchHub

This guide explains how to configure Auth0 to work with the WatchHub application for Social Login (Google, Facebook, etc.).

## 1. Create Auth0 Application

1.  Log in to your [Auth0 Dashboard](https://manage.auth0.com/).
2.  Go to **Applications** > **Applications**.
3.  Click **Create Application**.
4.  Name: `WatchHub` (or your preferred name).
5.  Type: **Native**.
6.  Click **Create**.

## 2. Configure URLs

In your new Application's settings tab:

1.  Scroll down to **Application URIs**.
2.  **Allowed Callback URLs**:
    *   Add: `demo://dev-1eu3wfre6rt6kn2q.us.auth0.com/android/com.watchhub.watchhub_app/callback`
    *   **IMPORTANT**: Replace `YOUR_AUTH0_DOMAIN` with your actual Domain (e.g., `dev-xyz.us.auth0.com`).
    *   Example: `demo://dev-xyz.us.auth0.com/android/com.watchhub.watchhub_app/callback`
    *   *Note: Since we are using the `demo` scheme in this setup, ensure the scheme matches what is in `build.gradle`.*
3.  **Allowed Logout URLs**:
    *   Add: `demo://dev-1eu3wfre6rt6kn2q.us.auth0.com/android/com.watchhub.watchhub_app/callback`

4.  Scroll down and click **Save Changes**.

## 3. Configure Social Connections

1.  Go to **Authentication** > **Social**.
2.  **Google**: Usually enabled by default. Click on it to configure your Client ID/Secret if needed (Auth0 provides dev keys for testing).
3.  **Facebook**: Click **Create Connection** > **Facebook**. Follow instructions to add your Facebook App ID/Secret if you want to use your own, or use Auth0 dev keys for testing.

## 4. App Configuration (.env)

1.  In your project, open `watchhub_app/assets/.env`.
2.  Update the values with your Auth0 Application details:

```env
AUTH0_DOMAIN=your-tenant.region.auth0.com
AUTH0_CLIENT_ID=your-client-id
```

## 5. Android Configuration (Verification)

1.  Open `android/app/build.gradle.kts`.
2.  Verify `manifestPlaceholders`:

```kotlin
manifestPlaceholders["auth0Domain"] = "your-tenant.region.auth0.com"
manifestPlaceholders["auth0Scheme"] = "demo" 
```

**Note**: If you change the scheme from `demo`, you must update it in:
1. `build.gradle.kts`
2. `Auth0Service.dart` (login/logout calls)
3. Auth0 Dashboard Callbacks

## 6. Testing

1.  Run the app: `flutter run`.
2.  On Login Screen, click "Continue with Social Accounts".
3.  Auth0 Universal Login page should open.
4.   Sign in with Google.
5.  You should be redirected back to the app and logged in.
