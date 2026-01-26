# WatchHub - Complete Project Documentation

---

## **Document Information**

| **Project Name** | WatchHub - Premium Watch E-Commerce Platform |
|------------------|---------------------------------------------|
| **Version** | 1.0.0 |
| **Date** | January 2026 |
| **Author** | WatchHub Development Team |
| **Document Type** | Technical & User Documentation |

---

# Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Project Overview](#2-project-overview)
3. [System Architecture](#3-system-architecture)
4. [Technology Stack](#4-technology-stack)
5. [Mobile Application](#5-mobile-application)
6. [Admin Panel](#6-admin-panel)
7. [Database Schema](#7-database-schema)
8. [API Integration](#8-api-integration)
9. [Security Implementation](#9-security-implementation)
10. [Testing Documentation](#10-testing-documentation)
11. [Deployment Guide](#11-deployment-guide)
12. [User Manual](#12-user-manual)
13. [Appendices](#13-appendices)

---

# 1. Executive Summary

## 1.1 Project Vision

WatchHub is a premium e-commerce platform designed specifically for luxury watch retail. The platform consists of two main components: a customer-facing mobile application built with Flutter and a web-based admin panel for business management.

## 1.2 Key Objectives

- Deliver a premium, luxury shopping experience for watch enthusiasts
- Provide seamless cross-platform mobile experience (iOS & Android)
- Enable efficient business operations through comprehensive admin tools
- Ensure secure transactions and user data protection
- Support real-time notifications and order tracking

## 1.3 Target Audience

**Mobile Application:**
- Watch collectors and enthusiasts
- Luxury goods shoppers
- Gift buyers seeking premium timepieces

**Admin Panel:**
- Store administrators
- Inventory managers
- Customer service representatives

---

# 2. Project Overview

## 2.1 Introduction

WatchHub represents a complete e-commerce solution for premium watch retail. The platform combines elegant design with powerful functionality to create an unparalleled shopping experience.

## 2.2 Business Goals

| Goal | Description |
|------|-------------|
| Premium Experience | Create a luxury shopping experience matching the caliber of products |
| Operational Efficiency | Streamline inventory, orders, and customer management |
| Customer Engagement | Build lasting relationships through reviews, feedback, and notifications |
| Scalability | Support business growth with robust architecture |

## 2.3 Project Scope

### In Scope
- Mobile application for iOS and Android
- Web-based admin panel
- User authentication (Email, Google, Facebook)
- Product catalog management
- Shopping cart and checkout
- Order management and tracking
- Customer reviews and ratings
- Push notifications
- User profile management
- Wishlist functionality

### Out of Scope
- Payment gateway integration (placeholder implemented)
- Shipping carrier API integration
- Multi-language support
- Multi-currency support

## 2.4 Key Features Summary

### Mobile Application Features
1. User Authentication & Registration
2. Product Browsing & Search
3. Shopping Cart Management
4. Secure Checkout Process
5. Order History & Tracking
6. Wishlist Management
7. Product Reviews & Ratings
8. Push Notifications
9. Profile Management
10. Customer Feedback System

### Admin Panel Features
1. Dashboard Analytics
2. Product Management (CRUD)
3. Category Management
4. Order Processing
5. User Management
6. Review Moderation
7. Feedback Management
8. Active Cart Monitoring
9. Admin Profile Settings
10. Application Settings

---

# 3. System Architecture

## 3.1 High-Level Architecture

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

## 3.2 Component Architecture

### 3.2.1 Presentation Layer
- **Screens**: UI components for each feature
- **Widgets**: Reusable UI components
- **Themes**: Dark/Light mode styling

### 3.2.2 Business Logic Layer
- **Providers**: State management using Provider pattern
- **Models**: Data structures and entities
- **Utilities**: Helper functions and constants

### 3.2.3 Data Layer
- **Services**: API communication and data operations
- **Repositories**: Data access abstraction

## 3.3 Data Flow

```
User Action → Provider → Service → Firebase/Supabase → Response → Provider Update → UI Rebuild
```

## 3.4 Application States

| State | Description |
|-------|-------------|
| Initial | App loading, checking auth status |
| Authenticated | User logged in, full access |
| Unauthenticated | Guest mode, limited access |
| Error | Error state with recovery options |
| Loading | Async operation in progress |

---

# 4. Technology Stack

## 4.1 Frontend Technologies

### Mobile Application
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.x | Cross-platform UI framework |
| Dart | 3.6.0+ | Programming language |
| Provider | 6.1.1 | State management |
| Flutter Animate | 4.3.0 | Animations |
| Cached Network Image | 3.3.1 | Image caching |

### Admin Panel
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter Web | 3.x | Web application framework |
| Data Table 2 | Latest | Advanced data tables |
| FL Chart | Latest | Dashboard charts |

## 4.2 Backend Services

| Service | Purpose | Features Used |
|---------|---------|---------------|
| Firebase Auth | Authentication | Email, Google, Facebook login |
| Cloud Firestore | Database | Real-time NoSQL database |
| Supabase Storage | File Storage | Image upload and hosting |
| OneSignal | Push Notifications | Cross-platform push |

## 4.3 Development Tools

| Tool | Purpose |
|------|---------|
| VS Code / Android Studio | IDE |
| Git | Version control |
| Firebase Console | Backend management |
| Supabase Dashboard | Storage management |
| OneSignal Dashboard | Push notification management |

## 4.4 Package Dependencies

### Mobile App Key Packages
```yaml
dependencies:
  # Firebase
  firebase_core: ^4.3.0
  firebase_auth: ^6.1.3
  cloud_firestore: ^6.1.1
  google_sign_in: ^6.2.1
  
  # Supabase
  supabase_flutter: ^2.3.0
  
  # State Management
  provider: ^6.1.1
  
  # UI Components
  google_fonts: ^6.1.0
  flutter_rating_bar: ^4.0.1
  cached_network_image: ^3.3.1
  flutter_animate: ^4.3.0
  
  # Push Notifications
  onesignal_flutter: ^5.3.5
```

---

# 5. Mobile Application

## 5.1 Application Structure

```
watchhub_app/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── routes/
│   │   ├── themes/
│   │   └── utils/
│   ├── models/
│   ├── providers/
│   ├── screens/
│   ├── services/
│   └── widgets/
├── assets/
└── pubspec.yaml
```

## 5.2 Core Constants

### 5.2.1 App Colors
The application uses a premium dark theme with gold accents:

| Color Name | Hex Value | Usage |
|------------|-----------|-------|
| Primary Gold | #D4AF37 | Accents, CTAs, highlights |
| Scaffold Background | #0A1628 | Main background |
| Card Background | #0F1F33 | Card surfaces |
| Text Primary | #FFFFFF | Main text |
| Text Secondary | #7A8B9A | Secondary text |
| Success | #4CAF50 | Success states |
| Error | #F44336 | Error states |
| Rating Color | #FFD700 | Star ratings |

### 5.2.2 Typography
Premium typography using Google Fonts:

| Style | Font | Size | Weight |
|-------|------|------|--------|
| Display Large | Playfair Display | 48 | Bold |
| Headline Medium | Playfair Display | 32 | Semi-Bold |
| Title Large | Inter | 22 | Bold |
| Body Medium | Inter | 16 | Normal |
| Label Small | Inter | 12 | Medium |

---

## 5.3 Authentication Module

### 5.3.1 Overview
The authentication module provides secure user access through multiple authentication methods.

### 5.3.2 Login Screen

**File Location:** `lib/screens/auth/login_screen.dart`

**Purpose:** Allow existing users to access their accounts.

**Features:**
- Email/password login
- Google Sign-In integration
- Facebook Sign-In integration
- "Forgot Password" functionality
- Navigation to registration

**UI Components:**
- WatchHub logo header
- Email input field with validation
- Password input field (obscured)
- "Remember Me" toggle
- Login button with loading state
- Social login buttons (Google, Facebook)
- "Forgot Password" link
- "Create Account" navigation link

**Validation Rules:**
| Field | Validation |
|-------|------------|
| Email | Required, valid email format |
| Password | Required, minimum 6 characters |

**[Screenshot Placeholder: Login Screen]**

---

### 5.3.3 Registration Screen

**File Location:** `lib/screens/auth/signup_screen.dart`

**Purpose:** Enable new users to create accounts.

**Features:**
- Full name input
- Email registration
- Password with confirmation
- Phone number (optional)
- Terms of service agreement

**UI Components:**
- Registration header
- Full name input field
- Email input field
- Password input field
- Confirm password field
- Phone number field
- Terms checkbox
- Create account button
- Social registration options
- "Already have account" link

**Validation Rules:**
| Field | Validation |
|-------|------------|
| Full Name | Required, minimum 2 characters |
| Email | Required, valid format, unique |
| Password | Required, minimum 6 characters |
| Confirm Password | Must match password |
| Phone | Optional, valid format |

**[Screenshot Placeholder: Registration Screen]**

---

### 5.3.4 Forgot Password Screen

**File Location:** `lib/screens/auth/forgot_password_screen.dart`

**Purpose:** Allow users to reset forgotten passwords.

**Features:**
- Email input for reset link
- Success confirmation message
- Return to login navigation

**Flow:**
1. User enters registered email
2. System sends password reset link
3. User clicks link in email
4. User sets new password
5. User logs in with new credentials

**[Screenshot Placeholder: Forgot Password Screen]**

---

## 5.4 Home Module

### 5.4.1 Home Screen

**File Location:** `lib/screens/home/home_screen.dart`

**Purpose:** Primary landing screen showcasing products and categories.

**Features:**
- Hero banner with promotional content
- Auto-scrolling category carousel
- Featured products section
- New arrivals section
- Premium brands showcase
- Pull-to-refresh functionality

**Sections:**

1. **App Bar**
   - WatchHub logo
   - Shopping cart badge
   - Notifications badge

2. **Hero Banner**
   - Full-width promotional image
   - "Premium Edition" label
   - "Exclusive Timepieces" heading
   - "Explore Collection" CTA button

3. **Curated Categories**
   - "Experience Elegance" subtitle
   - Horizontally scrolling category chips
   - Auto-looping continuous scroll
   - Tap to navigate to category

4. **Featured Products**
   - Section header with "See All" link
   - Auto-rotating product cards (2 columns)
   - Product image, name, price display
   - Tap to view product details

5. **New Arrivals**
   - "NEW" badge indicator
   - Latest products showcase
   - Auto-rotating display

6. **Premium Brands**
   - "World Renowned" subtitle
   - Brand name chips
   - Tap to filter by brand

**[Screenshot Placeholder: Home Screen - Full]**
**[Screenshot Placeholder: Home Screen - Hero Banner]**
**[Screenshot Placeholder: Home Screen - Categories]**
**[Screenshot Placeholder: Home Screen - Featured Products]**

---

### 5.4.2 Main Screen (Bottom Navigation)

**File Location:** `lib/screens/main_screen.dart`

**Purpose:** Container screen with bottom navigation.

**Navigation Items:**
| Index | Label | Icon | Screen |
|-------|-------|------|--------|
| 0 | Home | home_outlined | HomeScreen |
| 1 | Search | search | SearchScreen |
| 2 | Wishlist | favorite_outline | WishlistScreen |
| 3 | Cart | shopping_bag_outlined | CartScreen |
| 4 | Profile | person_outline | ProfileScreen |

**Features:**
- Persistent bottom navigation
- Badge indicators (cart count, wishlist count)
- Smooth screen transitions
- State preservation between tabs

**[Screenshot Placeholder: Bottom Navigation Bar]**

---

## 5.5 Product Module

### 5.5.1 Product Details Screen

**File Location:** `lib/screens/product/product_details_screen.dart`

**Purpose:** Display comprehensive product information.

**Features:**
- Hero image with zoom capability
- Product specifications
- Customer reviews section
- Quantity selector
- Add to Cart / Buy Now buttons
- Wishlist toggle

**Sections:**

1. **Image Gallery**
   - Full-screen hero image
   - Gradient overlay
   - Wishlist heart icon
   - Share button
   - Back navigation

2. **Product Information**
   - Brand name (uppercase)
   - Product name
   - Star rating with review count
   - Price (with sale badge if applicable)
   - Stock status indicator
   - Product description

3. **Specifications**
   - Glass container with specs
   - Key-value pairs display
   - Movement, case material, etc.

4. **Reviews Section**
   - Overall rating display
   - Rating distribution bars
   - "Write a Review" button
   - "See All" reviews link

5. **Bottom Action Bar**
   - Quantity selector (+/-)
   - "Add to Cart" button (outlined)
   - "Buy Now" button (filled)
   - Responsive layout for all screen sizes

**[Screenshot Placeholder: Product Details - Top]**
**[Screenshot Placeholder: Product Details - Specs]**
**[Screenshot Placeholder: Product Details - Reviews]**
**[Screenshot Placeholder: Product Details - Bottom Bar]**

---

### 5.5.2 Products List Screen

**File Location:** `lib/screens/product/products_list_screen.dart`

**Purpose:** Display filterable product listings.

**Features:**
- Grid/List view toggle
- Sort options (price, name, rating)
- Filter by category/brand
- Pull-to-refresh
- Infinite scroll pagination

**Filter Options:**
| Filter | Options |
|--------|---------|
| Category | All categories from database |
| Brand | All brands from products |
| Price Range | Min/Max slider |
| Rating | 1-5 stars minimum |

**Sort Options:**
- Price: Low to High
- Price: High to Low
- Name: A to Z
- Rating: Highest First
- Newest First

**[Screenshot Placeholder: Products List - Grid View]**
**[Screenshot Placeholder: Products List - Filters]**

---

## 5.6 Cart Module

### 5.6.1 Cart Screen

**File Location:** `lib/screens/cart/cart_screen.dart`

**Purpose:** Manage shopping cart items.

**Features:**
- Cart item list with images
- Quantity adjustment per item
- Remove item functionality
- Price breakdown
- Proceed to checkout

**UI Components:**

1. **Cart Item Card**
   - Product thumbnail
   - Product name and brand
   - Unit price
   - Quantity controls (+/-)
   - Remove button (swipe or icon)
   - Subtotal per item

2. **Cart Summary**
   - Subtotal amount
   - Estimated shipping
   - Tax calculation
   - Total amount
   - Proceed to Checkout button

3. **Empty State**
   - Empty cart illustration
   - "Your cart is empty" message
   - "Continue Shopping" button

**[Screenshot Placeholder: Cart Screen - With Items]**
**[Screenshot Placeholder: Cart Screen - Empty State]**

---

## 5.7 Checkout Module

### 5.7.1 Checkout Screen

**File Location:** `lib/screens/checkout/checkout_screen.dart`

**Purpose:** Complete purchase process.

**Features:**
- Shipping address selection
- Payment method selection
- Order summary review
- Place order confirmation

**Sections:**

1. **Shipping Address**
   - Saved addresses list
   - Add new address option
   - Selected address highlight
   - Edit address capability

2. **Payment Method**
   - Credit/Debit card (placeholder)
   - Cash on Delivery option
   - Payment icons display

3. **Order Summary**
   - Item count and list
   - Subtotal
   - Shipping cost
   - Tax
   - Grand total

4. **Place Order Button**
   - Prominent gold button
   - Loading state during processing
   - Success/Error feedback

**[Screenshot Placeholder: Checkout Screen - Address]**
**[Screenshot Placeholder: Checkout Screen - Payment]**
**[Screenshot Placeholder: Checkout Screen - Summary]**

---

## 5.8 Orders Module

### 5.8.1 Orders List Screen

**File Location:** `lib/screens/orders/orders_list_screen.dart`

**Purpose:** Display order history.

**Features:**
- List of all user orders
- Order status badges
- Order date and amount
- Tap to view details

**Order Status Types:**
| Status | Color | Description |
|--------|-------|-------------|
| Pending | Orange | Order placed, awaiting processing |
| Approved | Blue | Order confirmed |
| Processing | Blue | Being prepared |
| Shipped | Purple | In transit |
| Completed | Green | Delivered |
| Cancelled | Red | Order cancelled |

**[Screenshot Placeholder: Orders List Screen]**

---

### 5.8.2 Order Details Screen

**File Location:** `lib/screens/orders/order_details_screen.dart`

**Purpose:** View complete order information.

**Features:**
- Order number and date
- Current status
- Shipping address
- Item list
- Price breakdown
- Tracking information

**[Screenshot Placeholder: Order Details Screen]**

---

## 5.9 Reviews Module

### 5.9.1 Reviews Screen

**File Location:** `lib/screens/reviews/reviews_screen.dart`

**Purpose:** View all product reviews.

**Features:**
- Sort by newest/rating/helpful
- User reviews with ratings
- Admin reply display
- Helpful vote button
- Write review FAB

**Review Card Components:**
- User avatar (initials)
- Username and date
- Star rating display
- Review title
- Review comment
- "Verified Purchase" badge
- Admin reply section (gold styled)
- Helpful button with count

**[Screenshot Placeholder: Reviews Screen]**

---

### 5.9.2 Write Review Screen

**File Location:** `lib/screens/reviews/write_review_screen.dart`

**Purpose:** Submit product reviews.

**Features:**
- Star rating selector
- Review title input
- Review comment textarea
- Submit button

**[Screenshot Placeholder: Write Review Screen]**

---

## 5.10 Wishlist Module

### 5.10.1 Wishlist Screen

**File Location:** `lib/screens/wishlist/wishlist_screen.dart`

**Purpose:** Manage saved products.

**Features:**
- Grid view of wishlist items
- Remove from wishlist
- Move to cart
- View product details

**[Screenshot Placeholder: Wishlist Screen]**

---

## 5.11 Search Module

### 5.11.1 Search Screen

**File Location:** `lib/screens/search/search_screen.dart`

**Purpose:** Find products quickly.

**Features:**
- Search input with auto-suggestions
- Recent searches
- Popular searches
- Real-time results
- Filter integration

**[Screenshot Placeholder: Search Screen]**

---

## 5.12 Profile Module

### 5.12.1 Profile Screen

**File Location:** `lib/screens/profile/profile_screen.dart`

**Purpose:** User account management.

**Features:**
- Profile information display
- Edit profile access
- Order history link
- Settings access
- Help & Support
- Logout functionality

**Menu Items:**
| Item | Icon | Destination |
|------|------|-------------|
| Edit Profile | person | Edit Profile Screen |
| My Orders | shopping_bag | Orders List Screen |
| My Wishlist | favorite | Wishlist Screen |
| Notifications | notifications | Notification Settings |
| Help & Support | help | Feedback Screen |
| About | info | About Screen |
| Logout | logout | Login Screen |

**[Screenshot Placeholder: Profile Screen]**

---

### 5.12.2 Edit Profile Screen

**File Location:** `lib/screens/profile/edit_profile_screen.dart`

**Purpose:** Update user information.

**Features:**
- Profile image upload
- Name editing
- Phone number editing
- Address editing
- Save changes

**[Screenshot Placeholder: Edit Profile Screen]**

---

## 5.13 Notifications Module

### 5.13.1 Notifications Screen

**File Location:** `lib/screens/notifications/notifications_screen.dart`

**Purpose:** View all app notifications.

**Features:**
- Notification list
- Read/Unread status
- Notification type icons
- Tap to navigate
- Mark all as read
- Clear all option

**Notification Types:**
| Type | Icon | Navigation |
|------|------|------------|
| Order Update | shopping_bag | Order Details |
| Review Reply | rate_review | Reviews Screen |
| Promotion | local_offer | Product Details |
| System | info | None |

**[Screenshot Placeholder: Notifications Screen]**

---

## 5.14 Feedback Module

### 5.14.1 Feedback Screen

**File Location:** `lib/screens/feedback/feedback_screen.dart`

**Purpose:** Submit app feedback.

**Features:**
- Feedback type selection
- Rating input
- Comment textarea
- Submit functionality

**Feedback Types:**
- Bug Report
- Feature Request
- General Feedback
- Complaint

**[Screenshot Placeholder: Feedback Screen]**

---

# 6. Admin Panel

## 6.1 Admin Panel Overview

The WatchHub Admin Panel is a comprehensive web-based dashboard for managing all aspects of the e-commerce platform. Built with Flutter Web, it provides a consistent experience across browsers.

### 6.1.1 Access URL
```
http://localhost:port (Development)
https://watchhub-admin.web.app (Production)
```

### 6.1.2 Admin Credentials
- Hardcoded admin check for demo purposes
- Email: admin@watchhub.com
- Integration with Firebase Auth

## 6.2 Admin Application Structure

```
watchhub_admin/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   └── utils/
│   ├── models/
│   ├── providers/
│   ├── screens/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── products/
│   │   ├── categories/
│   │   ├── orders/
│   │   ├── users/
│   │   ├── reviews/
│   │   ├── feedback/
│   │   ├── carts/
│   │   ├── profile/
│   │   └── settings/
│   ├── services/
│   └── widgets/
└── pubspec.yaml
```

---

## 6.3 Authentication

### 6.3.1 Admin Login Screen

**File Location:** `lib/screens/auth/login_screen.dart`

**Purpose:** Secure admin authentication.

**Features:**
- Email/password login
- Admin verification
- Session persistence
- Error handling

**Security:**
- Only verified admin emails allowed
- Session timeout handling
- Failed login attempt tracking

**[Screenshot Placeholder: Admin Login Screen]**

---

## 6.4 Dashboard

### 6.4.1 Dashboard Screen

**File Location:** `lib/screens/dashboard/dashboard_screen.dart`

**Purpose:** Business overview and analytics.

**Features:**
- Key performance indicators
- Sales analytics charts
- Recent orders widget
- Quick action buttons

**Dashboard Widgets:**

1. **Statistics Cards**
   - Total Revenue
   - Total Orders
   - Total Products
   - Total Users

2. **Sales Chart**
   - Monthly revenue trend
   - Interactive line/bar chart
   - Period selector

3. **Recent Orders**
   - Latest 5-10 orders
   - Quick status view
   - Click to manage

4. **Low Stock Alert**
   - Products below threshold
   - Quick restock action

5. **Pending Reviews**
   - Reviews awaiting moderation
   - Quick approve/reject

**[Screenshot Placeholder: Dashboard - Overview]**
**[Screenshot Placeholder: Dashboard - Charts]**
**[Screenshot Placeholder: Dashboard - Widgets]**

---

## 6.5 Products Management

### 6.5.1 Products List Screen

**File Location:** `lib/screens/products/products_list_screen.dart`

**Purpose:** View and manage all products.

**Features:**
- DataTable with pagination
- Search functionality
- Filter by category/brand
- Bulk actions
- CRUD operations

**Table Columns:**
| Column | Description |
|--------|-------------|
| Image | Product thumbnail |
| Name | Product name |
| Brand | Brand name |
| Category | Product category |
| Price | Current price |
| Stock | Inventory count |
| Status | Active/Inactive |
| Actions | Edit/Delete buttons |

**Actions:**
- Add New Product
- Edit Product
- Delete Product
- Toggle Active Status
- View Details

**[Screenshot Placeholder: Products List Screen]**

---

### 6.5.2 Product Form (Add/Edit)

**File Location:** `lib/screens/products/product_form_screen.dart`

**Purpose:** Create or modify products.

**Form Fields:**

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| Name | Text | Yes | Min 3 characters |
| Description | Textarea | Yes | Min 10 characters |
| Brand | Dropdown | Yes | Select from list |
| Category | Dropdown | Yes | Select from list |
| Price | Number | Yes | Greater than 0 |
| Original Price | Number | No | For sale items |
| Stock | Number | Yes | 0 or greater |
| Image | File Upload | Yes | Max 5MB, JPG/PNG |
| Is Featured | Toggle | No | Default: false |
| Is New Arrival | Toggle | No | Default: false |

**Specifications Section:**
- Dynamic key-value pairs
- Add/Remove specification rows
- Common specs: Movement, Case Material, Water Resistance, etc.

**Image Upload:**
- Supabase Storage integration
- Image preview
- Progress indicator
- Replace existing image

**[Screenshot Placeholder: Product Form - Basic Info]**
**[Screenshot Placeholder: Product Form - Specifications]**
**[Screenshot Placeholder: Product Form - Image Upload]**

---

## 6.6 Categories Management

### 6.6.1 Categories Screen

**File Location:** `lib/screens/categories/categories_screen.dart`

**Purpose:** Manage product categories.

**Features:**
- Category list view
- Add new category
- Edit category
- Delete category
- Reorder categories

**Category Fields:**
| Field | Type | Required |
|-------|------|----------|
| Name | Text | Yes |
| Description | Text | No |
| Image URL | Text | No |
| Display Order | Number | Yes |
| Is Active | Toggle | Yes |

**[Screenshot Placeholder: Categories Screen]**

---

## 6.7 Orders Management

### 6.7.1 Orders List Screen

**File Location:** `lib/screens/orders/orders_list_screen.dart`

**Purpose:** Process and track orders.

**Features:**
- Orders table with filters
- Status management
- Order details view
- Notification triggers

**Table Columns:**
| Column | Description |
|--------|-------------|
| Order ID | Truncated unique ID |
| Date | Order creation date |
| Customer | User ID/email |
| Total | Order total amount |
| Status | Current status badge |
| Items | Item count |
| Actions | Status dropdown |

**Status Flow:**
```
Pending → Approved → Processing → Shipped → Completed
                                         ↘ Cancelled
```

**Status Change Actions:**
- Updates Firestore
- Sends in-app notification
- Triggers push notification via OneSignal
- Sends email notification (optional)

**[Screenshot Placeholder: Orders List Screen]**
**[Screenshot Placeholder: Order Status Change]**

---

## 6.8 Users Management

### 6.8.1 Users Screen

**File Location:** `lib/screens/users/users_screen.dart`

**Purpose:** View and manage registered users.

**Features:**
- User list with details
- User profile view
- Order history per user
- Account status management

**User Information Displayed:**
- Profile image
- Full name
- Email address
- Phone number
- Registration date
- Order count
- Total spent

**[Screenshot Placeholder: Users List Screen]**

---

## 6.9 Reviews Management

### 6.9.1 Reviews Screen

**File Location:** `lib/screens/reviews/reviews_screen.dart`

**Purpose:** Moderate and respond to reviews.

**Features:**
- All reviews listing
- Filter by product/rating
- Admin reply functionality
- Push notification on reply

**Review Card Display:**
- Product name link
- User name
- Star rating
- Review comment
- Review date
- Admin reply section
- Reply/Edit Reply button

**Reply Functionality:**
1. Click "Reply" button
2. Enter response in dialog
3. Save reply to Firestore
4. Send in-app notification to user
5. Trigger push notification

**[Screenshot Placeholder: Reviews Screen]**
**[Screenshot Placeholder: Review Reply Dialog]**

---

## 6.10 Feedback Management

### 6.10.1 Feedback Screen

**File Location:** `lib/screens/feedback/feedback_screen.dart`

**Purpose:** View customer feedback submissions.

**Features:**
- Feedback list view
- Filter by type
- Mark as resolved
- View details

**Feedback Types:**
- Bug Report
- Feature Request
- General Feedback
- Complaint

**[Screenshot Placeholder: Feedback Screen]**

---

## 6.11 Active Carts

### 6.11.1 Carts Screen

**File Location:** `lib/screens/carts/carts_screen.dart`

**Purpose:** Monitor active shopping carts.

**Features:**
- View all active carts
- Cart contents display
- User information
- Cart value totals
- Abandonment insights

**Use Cases:**
- Identify abandoned carts
- Customer support assistance
- Sales opportunity analysis

**[Screenshot Placeholder: Active Carts Screen]**

---

## 6.12 Admin Profile

### 6.12.1 Profile Screen

**File Location:** `lib/screens/profile/profile_screen.dart`

**Purpose:** Admin account management.

**Features:**
- View admin profile
- Update profile information
- Change password
- Activity log

**[Screenshot Placeholder: Admin Profile Screen]**

---

## 6.13 Settings

### 6.13.1 Settings Screen

**File Location:** `lib/screens/settings/settings_screen.dart`

**Purpose:** Application configuration.

**Settings Options:**
- Store Information
- Notification Settings
- Email Templates
- Tax Configuration
- Shipping Rates
- Payment Methods

**[Screenshot Placeholder: Settings Screen]**

---

# 7. Database Schema

## 7.1 Firestore Collections

### 7.1.1 Users Collection

**Path:** `users/{uid}`

| Field | Type | Description |
|-------|------|-------------|
| uid | String | Firebase Auth UID |
| name | String | Full name |
| email | String | Email address |
| phone | String? | Phone number |
| address | String? | Delivery address |
| profileImageUrl | String? | Supabase image URL |
| createdAt | Timestamp | Registration date |
| updatedAt | Timestamp? | Last update |
| oneSignalPlayerId | String? | Push notification ID |

---

### 7.1.2 Products Collection

**Path:** `products/{productId}`

| Field | Type | Description |
|-------|------|-------------|
| id | String | Auto-generated ID |
| name | String | Product name |
| description | String | Full description |
| brand | String | Brand name |
| category | String | Category name |
| price | Number | Current price |
| originalPrice | Number? | Price before discount |
| stock | Number | Available quantity |
| imageUrl | String | Product image URL |
| specifications | Map | Key-value specs |
| isFeatured | Boolean | Featured flag |
| isNewArrival | Boolean | New arrival flag |
| rating | Number | Average rating |
| reviewCount | Number | Total reviews |
| createdAt | Timestamp | Creation date |
| updatedAt | Timestamp? | Last update |

---

### 7.1.3 Categories Collection

**Path:** `categories/{categoryId}`

| Field | Type | Description |
|-------|------|-------------|
| id | String | Auto-generated ID |
| name | String | Category name |
| description | String? | Category description |
| imageUrl | String? | Category image |
| order | Number | Display order |
| isActive | Boolean | Active status |
| createdAt | Timestamp | Creation date |

---

### 7.1.4 Orders Collection

**Path:** `orders/{orderId}`

| Field | Type | Description |
|-------|------|-------------|
| id | String | Auto-generated ID |
| userId | String | Customer UID |
| orderNumber | String | Human-readable number |
| items | Array | Order items list |
| totalAmount | Number | Order total |
| status | String | Current status |
| shippingAddress | Map | Delivery address |
| paymentMethod | String | Payment type |
| createdAt | Timestamp | Order date |
| updatedAt | Timestamp? | Last update |

**Order Item Structure:**
```json
{
  "productId": "string",
  "productName": "string",
  "quantity": "number",
  "price": "number",
  "imageUrl": "string"
}
```

---

### 7.1.5 Carts Subcollection

**Path:** `carts/{uid}/items/{productId}`

| Field | Type | Description |
|-------|------|-------------|
| productId | String | Product reference |
| quantity | Number | Item quantity |
| addedAt | Timestamp | When added |

---

### 7.1.6 Wishlists Subcollection

**Path:** `wishlists/{uid}/items/{productId}`

| Field | Type | Description |
|-------|------|-------------|
| productId | String | Product reference |
| addedAt | Timestamp | When added |

---

### 7.1.7 Reviews Subcollection

**Path:** `products/{productId}/reviews/{reviewId}`

| Field | Type | Description |
|-------|------|-------------|
| id | String | Review ID |
| userId | String | Reviewer UID |
| userName | String | Reviewer name |
| rating | Number | 1-5 stars |
| title | String | Review title |
| comment | String | Review text |
| helpfulCount | Number | Helpful votes |
| adminReply | String? | Admin response |
| adminReplyAt | Timestamp? | Reply date |
| createdAt | Timestamp | Review date |
| isEdited | Boolean | Edit flag |

---

### 7.1.8 Notifications Subcollection

**Path:** `users/{uid}/notifications/{notificationId}`

| Field | Type | Description |
|-------|------|-------------|
| title | String | Notification title |
| message | String | Notification body |
| type | String | Notification type |
| productId | String? | Related product |
| orderId | String? | Related order |
| read | Boolean | Read status |
| createdAt | Timestamp | Creation date |

---

### 7.1.9 Feedback Collection

**Path:** `feedbacks/{feedbackId}`

| Field | Type | Description |
|-------|------|-------------|
| id | String | Feedback ID |
| userId | String | Submitter UID |
| type | String | Feedback type |
| rating | Number | App rating |
| comment | String | Feedback text |
| isResolved | Boolean | Resolution status |
| createdAt | Timestamp | Submission date |

---

## 7.2 Supabase Storage

### 7.2.1 Storage Buckets

| Bucket | Purpose | Access |
|--------|---------|--------|
| profile-images | User profile photos | Public |
| product-images | Product photos | Public |

### 7.2.2 File Naming Convention

```
profile-images/profiles/{uid}_{timestamp}.{ext}
product-images/products/{productId}_{timestamp}.{ext}
```

---

# 8. API Integration

## 8.1 Firebase Authentication API

### 8.1.1 Email/Password Authentication

**Sign Up:**
```dart
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);
```

**Sign In:**
```dart
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

### 8.1.2 Social Authentication

**Google Sign-In:**
```dart
final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);
await FirebaseAuth.instance.signInWithCredential(credential);
```

**Facebook Sign-In:**
```dart
final LoginResult result = await FacebookAuth.instance.login();
final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
await FirebaseAuth.instance.signInWithCredential(credential);
```

---

## 8.2 Firestore CRUD Operations

### 8.2.1 Create Document

```dart
await FirebaseFirestore.instance
    .collection('products')
    .doc(productId)
    .set(productData);
```

### 8.2.2 Read Document

```dart
final doc = await FirebaseFirestore.instance
    .collection('products')
    .doc(productId)
    .get();
final data = doc.data();
```

### 8.2.3 Update Document

```dart
await FirebaseFirestore.instance
    .collection('products')
    .doc(productId)
    .update({'stock': newStock});
```

### 8.2.4 Delete Document

```dart
await FirebaseFirestore.instance
    .collection('products')
    .doc(productId)
    .delete();
```

### 8.2.5 Query with Filters

```dart
final snapshot = await FirebaseFirestore.instance
    .collection('products')
    .where('category', isEqualTo: 'Luxury')
    .where('price', isLessThan: 5000)
    .orderBy('price', descending: true)
    .limit(20)
    .get();
```

---

## 8.3 Supabase Storage API

### 8.3.1 Upload Image

```dart
final bytes = await file.readAsBytes();
final fileName = 'profiles/${uid}_${DateTime.now().millisecondsSinceEpoch}.png';

await Supabase.instance.client.storage
    .from('profile-images')
    .uploadBinary(fileName, bytes);

final publicUrl = Supabase.instance.client.storage
    .from('profile-images')
    .getPublicUrl(fileName);
```

### 8.3.2 Delete Image

```dart
await Supabase.instance.client.storage
    .from('profile-images')
    .remove([fileName]);
```

---

## 8.4 OneSignal Push Notifications

### 8.4.1 Initialize SDK

```dart
OneSignal.initialize(appId);
await OneSignal.Notifications.requestPermission(true);
```

### 8.4.2 Login User

```dart
await OneSignal.login(uid);
```

### 8.4.3 Send Push via REST API

```dart
final response = await http.post(
  Uri.parse('https://onesignal.com/api/v1/notifications'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Basic $restApiKey',
  },
  body: jsonEncode({
    'app_id': appId,
    'include_player_ids': [playerId],
    'headings': {'en': title},
    'contents': {'en': body},
    'data': {'type': 'order_update'},
  }),
);
```

---

# 9. Security Implementation

## 9.1 Authentication Security

### 9.1.1 Firebase Auth
- Secure token-based authentication
- Automatic token refresh
- Session management

### 9.1.2 Password Requirements
- Minimum 6 characters
- Firebase handles hashing
- Password reset via email

## 9.2 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products readable by all, writable by admins
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && isAdmin();
    }
    
    // Orders accessible by owner or admin
    match /orders/{orderId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if request.auth != null;
      allow update: if request.auth != null && isAdmin();
    }
    
    function isAdmin() {
      return request.auth.token.email == 'admin@watchhub.com';
    }
  }
}
```

## 9.3 Environment Variables

Sensitive data stored in `.env` files:
```
AUTH0_DOMAIN=xxx
AUTH0_CLIENT_ID=xxx
ONESIGNAL_APP_ID=xxx
ONESIGNAL_REST_API_KEY=xxx
SUPABASE_URL=xxx
SUPABASE_ANON_KEY=xxx
```

## 9.4 Data Protection

- HTTPS for all communications
- Encrypted storage connections
- No sensitive data in logs
- Input validation on all forms

---

# 10. Testing Documentation

## 10.1 Testing Strategy

### 10.1.1 Test Types
- Unit Tests
- Widget Tests
- Integration Tests
- Manual Testing

## 10.2 Test Cases

### 10.2.1 Authentication Tests

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| AUTH-001 | Valid email login | User authenticated |
| AUTH-002 | Invalid password | Error displayed |
| AUTH-003 | Google sign-in | User authenticated |
| AUTH-004 | Password reset | Email sent |
| AUTH-005 | Sign out | User redirected to login |

### 10.2.2 Product Tests

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| PROD-001 | Load products list | Products displayed |
| PROD-002 | Search products | Filtered results |
| PROD-003 | View product details | Details screen shown |
| PROD-004 | Add to cart | Cart updated |
| PROD-005 | Add to wishlist | Wishlist updated |

### 10.2.3 Cart Tests

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| CART-001 | Add item to cart | Item appears in cart |
| CART-002 | Update quantity | Quantity changes |
| CART-003 | Remove item | Item removed |
| CART-004 | Clear cart | Cart empty |
| CART-005 | Proceed to checkout | Checkout screen |

### 10.2.4 Order Tests

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| ORD-001 | Place order | Order created |
| ORD-002 | View order history | Orders listed |
| ORD-003 | View order details | Details shown |
| ORD-004 | Status update notification | Notification received |

---

# 11. Deployment Guide

## 11.1 Mobile App Deployment

### 11.1.1 Android Build

**Debug APK:**
```bash
flutter build apk --debug
```

**Release APK:**
```bash
flutter build apk --release
```

**App Bundle (Play Store):**
```bash
flutter build appbundle --release
```

### 11.1.2 iOS Build

**Archive for App Store:**
```bash
flutter build ios --release
```

## 11.2 Admin Panel Deployment

### 11.2.1 Web Build

```bash
flutter build web --release
```

### 11.2.2 Firebase Hosting

```bash
firebase init hosting
firebase deploy --only hosting
```

## 11.3 Environment Setup

### 11.3.1 Firebase Configuration
1. Create Firebase project
2. Enable Authentication providers
3. Create Firestore database
4. Set security rules
5. Download google-services.json (Android)
6. Download GoogleService-Info.plist (iOS)

### 11.3.2 Supabase Configuration
1. Create Supabase project
2. Create storage buckets
3. Set bucket policies to public
4. Copy URL and anon key to .env

### 11.3.3 OneSignal Configuration
1. Create OneSignal app
2. Configure Android FCM
3. Configure iOS APNs
4. Copy App ID and REST API Key to .env

---

# 12. User Manual

## 12.1 Mobile App User Guide

### 12.1.1 Getting Started
1. Download WatchHub from App Store/Play Store
2. Open the app
3. Create account or sign in
4. Browse the collection

### 12.1.2 Shopping
1. Browse products on home screen
2. Use search to find specific items
3. Tap product for details
4. Select quantity and add to cart
5. Proceed to checkout
6. Enter shipping details
7. Confirm order

### 12.1.3 Managing Orders
1. Go to Profile > My Orders
2. View all past orders
3. Tap order for details
4. Track order status

### 12.1.4 Reviews
1. Navigate to product you purchased
2. Scroll to reviews section
3. Tap "Write a Review"
4. Rate and comment
5. Submit review

## 12.2 Admin Panel User Guide

### 12.2.1 Dashboard
- View daily/weekly/monthly stats
- Monitor recent orders
- Check low stock alerts

### 12.2.2 Managing Products
1. Navigate to Products
2. Click "Add Product"
3. Fill in product details
4. Upload product image
5. Add specifications
6. Save product

### 12.2.3 Processing Orders
1. Navigate to Orders
2. View pending orders
3. Change status as appropriate
4. Customer receives notification

### 12.2.4 Responding to Reviews
1. Navigate to Reviews
2. Find review to respond
3. Click "Reply"
4. Enter response
5. Save - notification sent to customer

---

# 13. Appendices

## Appendix A: Glossary

| Term | Definition |
|------|------------|
| UID | Unique Identifier (Firebase Auth) |
| CRUD | Create, Read, Update, Delete |
| API | Application Programming Interface |
| SDK | Software Development Kit |
| FCM | Firebase Cloud Messaging |
| APNs | Apple Push Notification Service |

## Appendix B: Color Palette Reference

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Primary Gold | #D4AF37 | 212, 175, 55 | CTAs, Accents |
| Light Gold | #F4D03F | 244, 208, 63 | Highlights |
| Dark Blue | #0A1628 | 10, 22, 40 | Background |
| Card Blue | #0F1F33 | 15, 31, 51 | Cards |
| Success Green | #4CAF50 | 76, 175, 80 | Success |
| Error Red | #F44336 | 244, 67, 54 | Errors |

## Appendix C: Screen Flow Diagrams

### C.1 User Registration Flow
```
App Launch → Login Screen → Sign Up Link → Registration Form → Email Verification → Home Screen
```

### C.2 Purchase Flow
```
Home → Product List → Product Details → Add to Cart → Cart → Checkout → Order Confirmation
```

### C.3 Order Processing Flow (Admin)
```
New Order → Pending → Approved → Processing → Shipped → Completed
                                                    ↓
                                              Cancelled
```

## Appendix D: API Endpoints Reference

### D.1 Firebase Services
- Authentication: https://firebase.google.com/docs/auth
- Firestore: https://firebase.google.com/docs/firestore
- Storage: https://firebase.google.com/docs/storage

### D.2 External Services
- Supabase: https://supabase.com/docs
- OneSignal: https://documentation.onesignal.com

## Appendix E: Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | Jan 2026 | Initial release |

---

# Document End

---

**WatchHub - Premium Watch E-Commerce Platform**

*Where Time Meets Luxury*

---

*This document is confidential and intended for WatchHub team use only.*

*© 2026 WatchHub. All rights reserved.*

