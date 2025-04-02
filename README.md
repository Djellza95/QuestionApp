# QuestionApp

A modern iOS application that implements a hierarchical content display system with offline support and robust error handling.

## Features

### Content Display
- Hierarchical content structure (Pages → Sections → Questions)
- Support for different content types:
  - Text content
  - Image content with full-screen view
  - Nested sections with proper indentation
- Dynamic font sizing based on hierarchy level
- Smooth animations and transitions

### Network & Offline Support
- Robust network error handling
- Automatic retry mechanism with exponential backoff
- Offline data persistence
- Network status indicators
- Last update time tracking

### UI/UX
- Clean and modern interface
- Pull-to-refresh functionality
- Loading indicators
- Error states with retry options
- Toast messages for status updates
- Smooth image transitions

## Architecture

### Design Pattern
- MVVM (Model-View-ViewModel) architecture
- Protocol-oriented design
- Clean separation of concerns

  ### Dependency Injection (DI)
- The app uses **Dependency Injection** to enhance modularity, testability, and separation of concerns.
- Services like `NetworkManager` and `StorageService` are injected into view models via protocols.


### Key Components

#### Models
- `Item`: Core data model representing content items
- Supporting protocols for type safety

#### Views
- `QuestionCell`: Reusable cell for different content types
- `ErrorView`: Custom error state display
- `ImageViewController`: Full-screen image display

#### ViewModels
- `ContentViewModel`: Manages content state and business logic
- Handles network requests and data persistence

#### Services
- `StorageService`: Manages offline data persistence
- `NetworkManager`: Handles network requests and reachability
  
#### Utils
- `DesignSystem`: Centralized design constants and styling
- 
- **Protocols Interface definitions for dependency injection

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## Dependencies

The project uses Swift Package Manager (SPM) for dependency management:

- [Alamofire](https://github.com/Alamofire/Alamofire): Elegant HTTP Networking for network requests and image loading

## Installation

1. Clone the repository
```bash
git clone https://github.com/Djellza95/QuestionApp.git
```

2. Open the project in Xcode
```bash
open QuestionApp.xcodeproj
```

3. Xcode will automatically resolve and download the dependencies using SPM

4. Build and run the project

## Usage

### Content Structure
- Pages are displayed at the top level
- Sections can be nested within pages
- Questions can be text or image-based
- Tap to expand/collapse sections
- Tap images to view full screen

### Offline Mode
- Content is automatically cached
- Works without internet connection
- Shows last update time
- Indicates offline status

## Error Handling

The app handles various error scenarios:
- Network connectivity issues
- Server errors
- Invalid data
- Poor connection
- Timeout situations

## Commit History

1. Initial project setup
2. Design system implementation
3. Core models and protocols
4. Base UI components
5. Cell implementation
6. View model layer
7. Network and storage services
8. Network enhancement
9. UI refinements
10. Final polish
