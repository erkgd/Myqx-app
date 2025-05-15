# Myqx-app Architecture Diagram Details

## Diagram Overview

The architecture diagram (`architecture.puml`) provides a visual representation of the Myqx app structure, following a classic three-layer architecture pattern. This document explains each component in detail.

## Architectural Layers

### 1. Presentation Layer

This layer contains all UI components that users interact with directly.

#### Screens
- **HomeScreen**: Main entry point displaying the feed and navigation options
- **ProfileScreen**: Shows the logged-in user's profile and music preferences
- **UnaffiliatedProfileScreen**: Displays profile information for other users
- **LoginScreen**: Handles user authentication
- **SearchScreen**: Allows users to search for music and other users
- **PostScreen**: For creating and viewing individual posts
- **NotificationScreen**: Displays user notifications

#### Widgets
- **Profile Widgets**:
  - **TopFiveAlbums**: Displays a user's top five favorite albums
  - **StarOfTheDay**: Showcases a featured album or track
  - **UserCompatibility**: Shows compatibility metrics between users
  
- **General Widgets**:
  - **UserHeader**: Header component showing user information
  - **Divisor**: Visual separator component
  - **MusicContainer**: Container for displaying music-related content
  - **PostCard**: Card displaying a user post
  - **AlbumCard**: Card displaying album information
  - **ArtistCard**: Card displaying artist information

- **Navigation**:
  - **AppNavigationBar**: Bottom navigation bar for app-wide navigation

### 2. Core Layer

This layer contains the business logic and data models of the application.

#### Services
- **UnaffiliatedProfileService**: Handles data for viewing other user profiles
- **ProfileService**: Manages user profile data
- **AuthService**: Handles authentication and user sessions
- **BroadcastService**: Manages communication between UI and data sources
- **PostService**: Handles post creation and retrieval
- **SearchService**: Manages search functionality

#### Models
- **User**: Represents user data and preferences
- **Album**: Represents music album data
- **Artist**: Represents music artist data
- **Post**: Represents user posts
- **Music**: Generic music data model

#### Utils & Constants
- **AppConstants**: Application-wide constants
- **ThemeConfig**: UI theme configuration
- **Routes**: Application navigation routes

### 3. Data Layer

This layer handles data access and external API interactions.

#### Repositories
- **UserRepository**: Manages user data operations
- **MusicRepository**: Handles music data operations
- **PostRepository**: Manages post data operations

#### Data Sources
- **ApiService**: Handles external API communications (Spotify, backend)
- **LocalStorage**: Manages local data persistence

## Key Relationships

1. **UI Flow**:
   - Screens use the AppNavigationBar for navigation
   - UnaffiliatedProfileScreen uses multiple specialized widgets

2. **Data Flow**:
   - UI components connect to services for data
   - Services use repositories to access data
   - Repositories communicate with data sources

3. **Model Relationships**:
   - User model relates to Albums, Artists, and Posts
   - BroadcastService coordinates communication between components

## Design Patterns

1. **Singleton Pattern**: Used for services like BroadcastService
2. **Repository Pattern**: Abstracts data access
3. **Dependency Injection**: Used for providing services to UI components
4. **Observer Pattern**: For state management and updates

## Future Considerations

The diagram can be extended to include:
- Authentication flow details
- External API integration details
- State management implementation
- Error handling mechanisms
