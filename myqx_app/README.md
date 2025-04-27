# Myqx App Music Preview Feature

## Music Playback Features

The Myqx App now includes music preview functionality that allows users to listen to track previews directly in the app. Here's how it works:

### Track Preview Functionality

- **In-App Previews**: Tracks with available preview URLs can be played directly within the app
- **Spotify Integration**: If a preview is not available, the app will automatically open the track in the Spotify app or web player
- **Visual Indicators**: Tracks without preview availability are marked with a small amber dot on the play button

### How to Use

1. Browse albums or search for tracks in the app
2. Press the play button on any track card:
   - If a preview is available, it will play directly in the app
   - If no preview is available, Spotify will open with the track ready to play

### Technical Implementation

The app uses the following components for audio playback:

- `just_audio` package for playing audio previews
- `AudioPlayerService` singleton for centralized audio state management
- `url_launcher` for opening Spotify links when previews aren't available

---

*Note: Track previews are provided through Spotify's API and typically offer 30-second snippets of songs.*
