MinknBear is a feature-rich, cross-platform e-commerce mobile application built with Flutter. It offers a seamless shopping experience, integrating the Shopify Storefront API for product management, Razorpay for secure payments, and Firebase for authentication and data storage. The app uses the BLoC pattern for efficient state management, ensuring scalability and maintainability.

Features
User Authentication: Secure login and registration using Firebase Authentication with email/password validation.
Product Browsing: Dynamic product catalog with category filters, keyword search, and sorting options (price, popularity).
Wishlist: Save favorite products for future purchase, with easy transfer to the cart.
Cart Management: Real-time price computation, quantity updates, and discount application.
Secure Checkout: Integrated Razorpay payment gateway with Cash on Delivery (COD) fallback and webhook synchronization.
Order Tracking: View order history and track shipment status via Shopify’s order pipeline.
User Profiles: Manage addresses, past orders, and account settings with session persistence.
Cross-Platform: Consistent UI/UX on Android and iOS, built with a single Flutter codebase.
Tech Stack
Frontend: Flutter (Dart)
Backend Services:
Firebase Authentication (user login/registration)
Firestore Database (user data, orders, cart)
Commerce Engine: Shopify Storefront API (GraphQL)
Payment Gateway: Razorpay
State Management: BLoC (Business Logic Component)
Local Storage: Hive (optional data caching)
Networking: GraphQL for Shopify API queries
Architecture
MinknBear uses a hybrid architecture for scalability and performance:

Frontend Layer: Component-based Flutter UI for reusability and responsiveness.
Commerce Engine: Shopify Storefront API for product data and order processing.
State Management: BLoC pattern for separation of UI and business logic.
Payment Module: Razorpay with COD fallback for reliable transactions.
The user flow ensures a seamless journey from browsing to checkout, with authentication checks for secure cart and order operations.

Installation
Prerequisites
Flutter SDK (v3.0 or higher)
Dart
Android Studio/Xcode for emulator/simulator
Firebase project setup
Shopify Storefront API access token
Razorpay API keys
Steps
Clone the Repository:
bash

Copy
git clone https://github.com/yourusername/minknbear.git
cd minknbear
Install Dependencies:
bash

Copy
flutter pub get
Configure Firebase:
Create a Firebase project at Firebase Console.
Add Android/iOS apps to the project and download google-services.json (Android) or GoogleService-Info.plist (iOS).
Place these files in android/app/ and ios/Runner/, respectively.
Enable Firebase Authentication (Email/Password) and Firestore Database.
Set Up Shopify API:
Obtain a Storefront API access token from your Shopify store.
Add the token to your app’s configuration (e.g., .env file or constants).
Configure Razorpay:
Get API keys from Razorpay Dashboard.
Update the payment module with your keys.
Run the App:
bash

Copy
flutter run
Testing
The app has been thoroughly tested for:

Functional Testing: Authentication, product listing, cart, checkout, and order tracking.
UI/UX: Responsiveness across screen sizes and platform-specific guidelines.
API: Shopify GraphQL queries, mutations, and error handling.
Performance: Fast API responses and low-latency UI updates.
Security: Encrypted data storage, secure login, and HTTPS API calls.
Payment: End-to-end checkout with success/failure scenarios.
See the  section for details.

Screenshots
Registration	Home Screen	Product Details	Checkout
			
Project Structure
minknbear/
├── android/                # Android-specific files
├── ios/                    # iOS-specific files
├── lib/                    # Flutter source code
│   ├── blocs/              # BLoC state management
│   ├── models/             # Data models
│   ├── screens/            # UI screens (Home, Cart, etc.)
│   ├── services/           # API and backend services
│   └── utils/              # Utilities and helpers
├── doc/                    # Documentation and screenshots
├── test/                   # Unit and widget tests
└── pubspec.yaml            # Dependencies and config


License
This project is licensed under the MIT License. See the  file for details.

Contact
For issues or inquiries, reach out via GitHub Issues or email at your.email@example.com.
