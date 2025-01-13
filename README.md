# Flutter Unsplash Demo

A modern Flutter application showcasing photo gallery functionality using the Unsplash API. This project demonstrates clean architecture, proper state management, and best practices in Flutter development.

## 🌟 Core Features

- Infinite scrolling photo gallery
- Full-screen photo view with pinch-to-zoom and double tap to zoom capability
- Local gallery photo saving
- Photo sharing functionality
- API response caching
- Image caching
- Comprehensive unit tests (incomplete; in process)

## 📱 Main Functionalities

### Gallery Screen
- Grid view of photos from Unsplash API
- Infinite scroll implementation
- Smooth image loading with placeholder support
- Cached images for offline viewing
- Link to detail screen on photo tap, search, refresh or settings

### Detail Screen
- Full-screen photo view
- Pinch to zoom and double tap to zoom functionality
- Save to local gallery option
- Share photo feature
- High-resolution image loading

### Settings Screen
- Toggle between light and dark mode
- Clear cache option
- Adding custom API key

### Search Functionality
- Search photos by keyword

## 🛠️ Technical Stack

- **Framework**: Flutter
- **API Integration**: REST API with Unsplash
- **Storage**: Shared Preferences and cache for local storage
- **Network**: Connectivity Plus for network state management
- **Permissions**: Permission Handler
- **Sharing**: Share Plus

## 📱 Platform Support

- Android (Tested on Android 15)
- iOS (Not tested)

## 💾 Caching Implementation

### Image Caching
- Implemented using `cached_network_image`
- Efficient memory and disk caching
- Offline image viewing support

### API Response Caching
- Local storage of API responses using Hive
- Reduced API calls
- Offline data availability

## 🚀 Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Get your Unsplash API key from [Unsplash Developer](https://unsplash.com/developers) and add it to the .env file.
4. Run the app using `flutter run`
