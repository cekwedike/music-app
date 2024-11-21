# Music Search App

This is a Flutter-based mobile application that allows users to search for music tracks using the Spotify Web API.

## Features

1. **Home Screen**: Users can enter a search query to find tracks.
2. **Search Results Screen**: Displays a list of tracks matching the search query, showing the track name, artist, album artwork, and a preview indicator.
3. **Track Details Screen**: Provides detailed information about a selected track, including the album name, duration, popularity, and a preview player.

## API Integration

The app uses the Spotify Web API to fetch all the music data. The key steps involved in the API integration are:

1. Obtaining an access token by making a POST request to the Spotify API's token endpoint, using the client ID and client secret.
2. Making subsequent GET requests to the Spotify API to search for tracks and retrieve their details.
3. Handling API rate limiting and token expiration by retrying the requests with a new access token when necessary.

## Code Structure

The main code files and their responsibilities are:

1. `main.dart`: The entry point of the application, sets up the app and navigation.
2. `spotify_provider.dart`: The central state management class that handles Spotify API interactions and data.
3. `home_screen.dart`: Implements the home screen where users can enter a search query.
4. `search_result_screen.dart`: Displays the search results and handles navigation to the track details screen.
5. `detail_screen.dart`: Shows the detailed information and preview for a selected track.
6. `models/spotify_models.dart`: Defines the data models used to represent Spotify entities like tracks and artists.
7. `widgets/track_player_widget.dart`: Implements the track preview player functionality.
8. `widgets/artist_section_widget.dart`: Displays the artist information and top tracks.

## Getting Started

To run the app, you'll need to have Flutter installed on your development machine. Follow these steps:

1. Clone the repository: `git clone https://github.com/your-username/music-search-app.git`
2. Navigate to the project directory: `cd music-search-app`
3. Install the dependencies: `flutter pub get`
4. Run the app: `flutter run`

## Future Improvements

Some potential improvements for the app include:

1. **Favorites/Playlists**: Allowing users to save their favorite tracks and create personalized playlists.
2. **Offline Support**: Caching track data to provide offline access and playback capabilities.
3. **Improved Error Handling**: Enhancing the error messages and providing more user-friendly feedback when API requests fail.
4. **Advanced Filtering and Sorting**: Allowing users to filter and sort the search results based on various criteria (e.g., release date, popularity).

## Contact

If you have any questions or feedback, please feel free to reach out to me at c.ekwedike@alustudent.com.