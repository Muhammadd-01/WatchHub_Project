<p align="center">
  <img src="watchhub_app/assets/images/watchhub_logo.png" alt="WatchHub Logo" width="120"/>
</p>

<h1 align="center">⌚ WatchHub</h1>
<p align="center">
  <strong>Premium Watch E-Commerce Platform</strong>
</p>

<p align="center">
  A luxury watch shopping experience built with Flutter featuring a cross-platform mobile application and web-based admin panel
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.6+-0175C2?style=for-the-badge&logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase"/>
</p>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Installation & Setup](#-installation--setup)
- [Database Schema](#-database-schema)
- [Screenshots](#-screenshots)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Overview

**WatchHub** is a comprehensive e-commerce platform designed for luxury watch retail. The platform delivers a premium shopping experience through two main components:

| Component | Description |
|-----------|-------------|
| **📱 Mobile App** | Cross-platform (iOS & Android) customer-facing application |
| **🖥️ Admin Panel** | Web-based management interface for store operations |

### 🎯 Key Objectives

- Deliver a premium, luxury shopping experience for watch enthusiasts
- Provide seamless cross-platform mobile experience
- Enable efficient business operations through comprehensive admin tools
- Ensure secure transactions and user data protection
- Support real-time notifications and order tracking

---

## ✨ Features

### 📱 Mobile Application

<table>
<tr>
<td width="50%">

**🔐 Authentication**
- Email/Password login & registration
- Google Sign-In integration
- Facebook Sign-In integration
- Password reset functionality

**🛒 Shopping**
- Product browsing with advanced filters
- Shopping cart management
- Secure checkout process
- Multiple payment options

**❤️ Engagement**
- Wishlist management
- Product reviews & ratings
- Customer feedback system
- Push notifications

</td>
<td width="50%">

**🏠 Home Experience**
- Hero banner promotions
- Auto-scrolling category carousel
- Featured products section
- New arrivals showcase
- Premium brands display

**📦 Order Management**
- Real-time order tracking
- Order history
- Status notifications
- Email confirmations

**👤 Profile**
- Profile customization
- Address management
- Order history access
- Settings & preferences

</td>
</tr>
</table>

### 🖥️ Admin Panel

| Feature | Description |
|---------|-------------|
| **📊 Dashboard** | Analytics overview with charts and key metrics |
| **📦 Products** | Full CRUD operations with multi-image support |
| **🏷️ Categories** | Category management for product organization |
| **🏢 Brands** | Brand catalog management |
| **📋 Orders** | Order processing and status updates |
| **👥 Users** | User management with role assignments |
| **⭐ Reviews** | Review moderation and admin replies |
| **💬 Feedback** | Customer feedback management |
| **🛒 Active Carts** | Monitor customer shopping carts |
| **❤️ Wishlists** | View customer wishlists |
| **🔔 Notifications** | Send push notifications to users |
| **❓ FAQs** | Manage frequently asked questions |
| **⚙️ Settings** | Application configuration |

---

## 🛠️ Tech Stack

### Frontend

| Technology | Version | Purpose |
|------------|---------|---------|
| [Flutter](https://flutter.dev/) | 3.x | Cross-platform UI framework |
| [Dart](https://dart.dev/) | 3.6.0+ | Programming language |
| [Provider](https://pub.dev/packages/provider) | 6.1.1 | State management |
| [Google Fonts](https://pub.dev/packages/google_fonts) | 6.1.0 | Premium typography |
| [Flutter Animate](https://pub.dev/packages/flutter_animate) | 4.3.0 | Smooth animations |
| [FL Chart](https://pub.dev/packages/fl_chart) | 1.1.1 | Dashboard charts |

### Backend Services

| Service | Purpose |
|---------|---------|
| [Firebase Auth](https://firebase.google.com/products/auth) | User authentication (Email, Google, Facebook) |
| [Cloud Firestore](https://firebase.google.com/products/firestore) | NoSQL real-time database |
| [Supabase Storage](https://supabase.com/storage) | Image hosting & CDN |
| [OneSignal](https://onesignal.com/) | Cross-platform push notifications |
| [Firebase Cloud Messaging](https://firebase.google.com/products/cloud-messaging) | Push notification delivery |

### Key Packages

```yaml
# Firebase Suite
firebase_core: ^4.3.0
firebase_auth: ^6.1.3
cloud_firestore: ^6.1.1
firebase_messaging: ^16.1.0

# Supabase Storage
supabase_flutter: ^2.3.0

# Authentication
google_sign_in: ^6.2.1
flutter_facebook_auth: ^7.1.1

# State Management
provider: ^6.1.1

# UI Components
cached_network_image: ^3.3.1
flutter_rating_bar: ^4.0.1
glassmorphism: ^3.0.0
lottie: ^3.1.0
shimmer: ^3.0.0

# Push Notifications
onesignal_flutter: ^5.3.5
```

---

## 🏗️ Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        WatchHub Platform                         │
├─────────────────────────────┬───────────────────────────────────┤
│     Mobile Application      │         Admin Panel               │
│     (Flutter - Dart)        │      (Flutter Web - Dart)         │
├─────────────────────────────┴───────────────────────────────────┤
│                      State Management                            │
│                    (Provider Pattern)                            │
├─────────────────────────────────────────────────────────────────┤
│                       Service Layer                              │
│    ┌─────────────┬─────────────┬─────────────┬────────────┐    │
│    │ Auth Service│ Firestore   │ Supabase    │ OneSignal  │    │
│    │             │ CRUD Service│ Storage     │ Push       │    │
│    └─────────────┴─────────────┴─────────────┴────────────┘    │
├─────────────────────────────────────────────────────────────────┤
│                      Backend Services                            │
│    ┌─────────────┬─────────────┬─────────────┬────────────┐    │
│    │ Firebase    │ Cloud       │ Supabase    │ OneSignal  │    │
│    │ Auth        │ Firestore   │ Storage     │ API        │    │
│    └─────────────┴─────────────┴─────────────┴────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action → Provider → Service → Firebase/Supabase → Response → Provider Update → UI Rebuild
```

### Layer Architecture

| Layer | Components | Responsibility |
|-------|------------|----------------|
| **Presentation** | Screens, Widgets, Themes | UI rendering & user interaction |
| **Business Logic** | Providers, Models, Utilities | State management & data processing |
| **Data** | Services, Repositories | API communication & data persistence |

---

## 📁 Project Structure

```
WatchHub_Project/
├── 📱 watchhub_app/                    # Mobile Application
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/              # App colors, text styles, constants
│   │   │   ├── routes/                 # Navigation configuration
│   │   │   ├── themes/                 # Dark/Light theme definitions
│   │   │   └── utils/                  # Helper functions
│   │   ├── models/                     # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── cart_model.dart
│   │   │   ├── wishlist_model.dart
│   │   │   ├── order_model.dart
│   │   │   ├── review_model.dart
│   │   │   ├── feedback_model.dart
│   │   │   ├── category_model.dart
│   │   │   ├── brand_model.dart
│   │   │   └── faq_model.dart
│   │   ├── providers/                  # State management
│   │   │   ├── auth_provider.dart
│   │   │   ├── cart_provider.dart
│   │   │   ├── product_provider.dart
│   │   │   ├── order_provider.dart
│   │   │   └── ...
│   │   ├── screens/                    # UI screens
│   │   │   ├── auth/                   # Login, Signup, Forgot Password
│   │   │   ├── home/                   # Home screen
│   │   │   ├── product/                # Product list & details
│   │   │   ├── cart/                   # Shopping cart
│   │   │   ├── checkout/               # Checkout flow
│   │   │   ├── orders/                 # Order history
│   │   │   ├── wishlist/               # Wishlisted items
│   │   │   ├── profile/                # User profile
│   │   │   ├── reviews/                # Product reviews
│   │   │   ├── search/                 # Product search
│   │   │   ├── feedback/               # Customer feedback
│   │   │   └── notifications/          # Push notifications
│   │   ├── services/                   # Backend services
│   │   │   ├── auth_service.dart
│   │   │   ├── firestore_crud_service.dart
│   │   │   ├── supabase_storage_service.dart
│   │   │   └── ...
│   │   └── widgets/                    # Reusable components
│   ├── assets/
│   │   └── images/                     # App images & icons
│   └── pubspec.yaml
│
├── 🖥️ watchhub_admin/                  # Admin Panel (Flutter Web)
│   ├── lib/
│   │   ├── core/                       # Constants & themes
│   │   ├── providers/                  # Admin state management
│   │   ├── screens/
│   │   │   ├── auth/                   # Admin login
│   │   │   ├── dashboard/              # Analytics dashboard
│   │   │   ├── products/               # Product management
│   │   │   ├── categories/             # Category management
│   │   │   ├── brands/                 # Brand management
│   │   │   ├── orders/                 # Order processing
│   │   │   ├── users/                  # User management
│   │   │   ├── reviews/                # Review moderation
│   │   │   ├── feedback/               # Feedback management
│   │   │   ├── carts/                  # Active carts view
│   │   │   ├── wishlists/              # Wishlists view
│   │   │   ├── notifications/          # Push notification sender
│   │   │   ├── faqs/                   # FAQ management
│   │   │   ├── profile/                # Admin profile
│   │   │   └── settings/               # App settings
│   │   ├── services/                   # Admin services
│   │   └── widgets/                    # Admin UI components
│   └── pubspec.yaml
│
└── 📚 docs/                            # Documentation
    ├── SETUP_GUIDE.md                  # Complete setup instructions
    ├── SUPABASE_SETUP_GUIDE.md         # Supabase configuration
    ├── ONESIGNAL_SETUP.md              # Push notification setup
    ├── AUTH0_SETUP.md                  # Auth0 integration guide
    └── ADMIN_PANEL_GUIDE.md            # Admin panel usage guide
```

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

| Requirement | Version | Check Command |
|-------------|---------|---------------|
| Flutter SDK | 3.x+ | `flutter --version` |
| Dart SDK | 3.6.0+ | `dart --version` |
| Git | Latest | `git --version` |
| Android Studio / VS Code | Latest | - |
| Xcode (macOS only) | Latest | `xcode-select --version` |

### Required Accounts

- [Firebase Console](https://console.firebase.google.com/) - Authentication & Database
- [Supabase](https://supabase.com/) - Image Storage
- [OneSignal](https://onesignal.com/) - Push Notifications

---

## 🚀 Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/WatchHub_Project.git
cd WatchHub_Project
```

### 2. Firebase Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for the mobile app
cd watchhub_app
flutterfire configure

# Configure Firebase for admin panel
cd ../watchhub_admin
flutterfire configure
```

> 📖 See [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md) for detailed Firebase configuration

### 3. Supabase Setup

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Create storage buckets:
   - `product-images` (Public)
   - `profile-images` (Public)
3. Configure storage policies for public access

> 📖 See [docs/SUPABASE_SETUP_GUIDE.md](docs/SUPABASE_SETUP_GUIDE.md) for detailed instructions

### 4. Environment Configuration

Create `.env` files in both `watchhub_app` and `watchhub_admin`:

```env
# watchhub_app/.env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
ONESIGNAL_APP_ID=your-onesignal-app-id
```

```env
# watchhub_admin/.env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 5. Install Dependencies

```bash
# Mobile App
cd watchhub_app
flutter pub get

# Admin Panel
cd ../watchhub_admin
flutter pub get
```

### 6. Run the Applications

```bash
# Run Mobile App
cd watchhub_app
flutter run

# Run Admin Panel (Web)
cd watchhub_admin
flutter run -d chrome
```

---

## 🗄️ Database Schema

### Firestore Collections

```
📁 users/{uid}
   ├── uid: string
   ├── name: string
   ├── email: string
   ├── phone: string
   ├── profileImageUrl: string
   ├── role: "customer" | "admin"
   ├── createdAt: timestamp
   └── updatedAt: timestamp

📁 products/{productId}
   ├── name: string
   ├── brand: string
   ├── description: string
   ├── price: number
   ├── originalPrice: number
   ├── imageUrl: string
   ├── imageUrls: array<string>
   ├── category: string
   ├── stock: number
   ├── specifications: map
   ├── rating: number
   ├── reviewCount: number
   ├── isFeatured: boolean
   ├── isNewArrival: boolean
   └── createdAt: timestamp

📁 carts/{uid}/items/{productId}
   ├── productId: string
   ├── quantity: number
   └── addedAt: timestamp

📁 wishlists/{uid}/items/{productId}
   ├── productId: string
   └── addedAt: timestamp

📁 orders/{orderId}
   ├── userId: string
   ├── orderNumber: string
   ├── items: array
   ├── subtotal: number
   ├── shippingCost: number
   ├── tax: number
   ├── totalAmount: number
   ├── status: string
   ├── shippingAddress: map
   ├── paymentMethod: string
   └── createdAt: timestamp

📁 products/{productId}/reviews/{reviewId}
   ├── userId: string
   ├── userName: string
   ├── rating: number
   ├── title: string
   ├── comment: string
   ├── adminReply: string
   ├── isVerifiedPurchase: boolean
   └── createdAt: timestamp

📁 feedbacks/{feedbackId}
   ├── userId: string
   ├── type: string
   ├── subject: string
   ├── message: string
   ├── status: string
   └── createdAt: timestamp
```

---

## 📸 Screenshots

### Mobile App

<table>
<tr>
<td align="center"><strong>Home</strong></td>
<td align="center"><strong>Product Details</strong></td>
<td align="center"><strong>Cart</strong></td>
<td align="center"><strong>Profile</strong></td>
</tr>
<tr>
<td><img src="docs/screenshots/home.png" width="200"/></td>
<td><img src="docs/screenshots/product.png" width="200"/></td>
<td><img src="docs/screenshots/cart.png" width="200"/></td>
<td><img src="docs/screenshots/profile.png" width="200"/></td>
</tr>
</table>

### Admin Panel

<table>
<tr>
<td align="center"><strong>Dashboard</strong></td>
<td align="center"><strong>Products</strong></td>
<td align="center"><strong>Orders</strong></td>
</tr>
<tr>
<td><img src="docs/screenshots/admin-dashboard.png" width="300"/></td>
<td><img src="docs/screenshots/admin-products.png" width="300"/></td>
<td><img src="docs/screenshots/admin-orders.png" width="300"/></td>
</tr>
</table>

> 📝 Add your screenshots to `docs/screenshots/` folder

---

## 🎨 Design System

### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| 🟡 Primary Gold | `#D4AF37` | Accents, CTAs, highlights |
| 🔵 Scaffold Background | `#0A1628` | Main background |
| 🔷 Card Background | `#0F1F33` | Card surfaces |
| ⚪ Text Primary | `#FFFFFF` | Main text |
| 🔘 Text Secondary | `#7A8B9A` | Secondary text |
| 🟢 Success | `#4CAF50` | Success states |
| 🔴 Error | `#F44336` | Error states |
| ⭐ Rating | `#FFD700` | Star ratings |

### Typography

| Style | Font | Size | Weight |
|-------|------|------|--------|
| Display Large | Playfair Display | 48 | Bold |
| Headline Medium | Playfair Display | 32 | Semi-Bold |
| Title Large | Inter | 22 | Bold |
| Body Medium | Inter | 16 | Normal |
| Label Small | Inter | 12 | Medium |

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**WatchHub Development Team**

---

<p align="center">
  Made with ❤️ and Flutter
</p>

<p align="center">
  <a href="#-watchhub">⬆️ Back to Top</a>
</p>
