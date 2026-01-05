# Perfect Supabase Setup Guide for WatchHub

Follow these steps exactly to ensure your images are stored correctly and accessible in the app.

## 1. Create a New Supabase Project
1. Go to [Supabase Dashboard](https://app.supabase.com/).
2. Click **New Project**.
3. Select your Organization and enter a project name (e.g., `WatchHub-Project`).
4. Set a strong Database Password (save it somewhere).
5. Choose the region closest to you.
6. Click **Create new project**. Wait for it to initialize (takes 1-2 minutes).

## 2. Get Your API Credentials
1. Once ready, go to **Project Settings** (gear icon) > **API**.
2. Copy the **Project URL** (under Project URL).
3. Copy the **anon public** key (under Project API keys).
4. Update these in your `main.dart` (for both `watchhub_app` and `watchhub_admin`).

## 3. Create Storage Buckets (CRITICAL)
Your app expects two specific buckets. They **MUST** be named exactly as shown below:

1. Go to **Storage** (folder icon) in the left sidebar.
2. Click **New bucket**.
3. Name it `product-images`.
4. **IMPORTANT**: Toggle the **Public bucket** switch to **ON**. (This allows everyone to view images).
5. Click **Create bucket**.
6. Repeat the process to create another bucket named `profile-images`.
7. **IMPORTANT**: Again, ensure it is set to **Public**.

## 4. Configure Security (RLS)
By default, Supabase blocks uploads even if the bucket is public. You need to allow the app to upload files.

### For simple testing (Disable RLS)
1. In the **Storage** section, click on a bucket (e.g., `product-images`).
2. Go to **Policies**.
3. If you see "RLS is enabled", you can click **Disable RLS** for that bucket to allow all uploads/downloads during development.
   > [!WARNING]
   > Disabling RLS is only recommended for development. For production, you should use the policies below.

### For production (Recommended Policies)
If you want to keep RLS enabled, add these policies for **BOTH** buckets:
1. Click **New Policy** > **For full customization**.
2. **Policy Name**: `Allow Public Uploads`
3. **Allowed Operations**: Check **INSERT** and **UPDATE**.
4. **Target Roles**: `anon`, `authenticated`.
5. **Policy Definition**: Leave as `true` (or use `role() = 'authenticated'` for more security).
6. Click **Save Policy**.

## 5. Summary Checklist
- [x] Project Created
- [x] URL and Anon Key copied to `main.dart`
- [x] Bucket `product-images` created as **PUBLIC**
- [x] Bucket `profile-images` created as **PUBLIC**
- [x] RLS Policies set to allow **INSERT** (Upload)

---
If you follow these steps, the "Failed to upload image" error should disappear!
