# Myqx App

Myqx is a social media application that connects users through their musical preferences and helps discover new music based on social compatibility with other users.

## Project Structure

The project follows a three-layer architecture:

- **Presentation Layer**: UI components including screens and reusable widgets
- **Core Layer**: Business logic, services, and models
- **Data Layer**: Data access and external API integration

## Features

- User profile management
- Music preference sharing
- Compatibility calculation between users
- Social feed with music-related posts
- Integration with music streaming services
- Track preview playback

## Documentation

### Architecture Documentation
- [Complete Architecture Diagram](/docs/architecture.puml) - Complete PlantUML diagram of the application structure (in Catalan)
- [Individual Architecture Diagrams](/docs/diagrams/) - Separate focused diagrams for better clarity (in Catalan):
  - [Arquitectura General](/docs/diagrams/01_overview_architecture.puml) - High-level architecture view
  - [Capa de Presentació](/docs/diagrams/02_presentation_layer.puml) - UI components detail
  - [Capa de Nucli](/docs/diagrams/03_core_layer.puml) - Business logic components
  - [Capa de Dades](/docs/diagrams/04_data_layer.puml) - Data access and external connections
  - [Flux Entre Capes](/docs/diagrams/05_cross_layer_flow.puml) - Flow between architectural layers
  - [Components de Perfil](/docs/diagrams/06_profile_components.puml) - User profile specific components
  - [Components Funcionals](/docs/diagrams/07_functional_components.puml) - High-level functional components
- [TFG Diagram Descriptions](/docs/DESCRIPCIO_DIAGRAMES_TFG.md) - Academic descriptions of diagrams for TFB (in Catalan)
- [Architecture Details](/docs/ARCHITECTURE_DETAILS.md) - Detailed explanation of each component
- [Diagram Generation Guide](/docs/GENERATE_DIAGRAM.md) - Instructions for generating diagram images
- [Documentation Overview](/docs/README.md) - Overview of architectural documentation

### Feature Documentation
- [Music Preview Feature](/myqx_app/README.md) - Documentation for the music preview functionality

## Recent Updates

- **2023-05-14**: 
  - Added comprehensive architecture diagram using PlantUML
  - Divided architecture into separate focused diagrams for better clarity
  - Translated all architecture diagrams to Catalan
  - Added academic descriptions of diagrams for TFG documentation
  - Created high-level functional components diagram
- **2023-05-13**: Fixed UI issues in profile components
  - Made album images square in TopFiveAlbums
  - Fixed overflow in StarOfTheDay widget
  - Positioned widget titles outside of containers
  - Reduced height of UserHeader component

## Setup and Installation

1. Ensure you have Flutter installed and set up on your machine
2. Clone the repository
3. Run `flutter pub get` in the project root to install dependencies
4. Configure `.env` file with necessary API keys (see `.env.example`)
5. Run `flutter run` to start the application

## Screenshots

*Coming soon*

## License

This project is proprietary and confidential.
