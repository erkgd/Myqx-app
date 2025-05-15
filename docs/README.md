# Myqx-app Architecture Documentation

## Documentation Files

- **architecture.puml**: PlantUML diagram source showing the complete application architecture
- **ARCHITECTURE_DETAILS.md**: Detailed explanation of each component in the diagram
- **GENERATE_DIAGRAM.md**: Instructions for generating PNG images from the PlantUML file
- **DESCRIPCIO_DIAGRAMES_TFG.md**: Detailed academic descriptions of each diagram for TFG (in Catalan)
- **images/**: Directory for storing generated diagram images
- **diagrams/**: Directory containing individual, focused architecture diagrams

## PlantUML Diagrams

### Complete Architecture Diagram
The file `architecture.puml` contains a comprehensive diagram of the entire Myqx-app architecture. This diagram illustrates the complete structure of the application, showing all components and their relationships.

### Individual Architecture Diagrams
For better readability, the architecture has also been divided into smaller, focused diagrams in the `diagrams/` directory (in Catalan):

1. **Arquitectura General**: High-level view of the three-layer architecture
2. **Capa de Presentació**: Detail of screens, widgets and UI components
3. **Capa de Nucli**: Services, models and business logic components
4. **Capa de Dades**: Repositories, data sources and external connections
5. **Flux Entre Capes**: Visualization of how data flows between layers
6. **Components de Perfil**: Specific focus on profile-related components and their interactions
7. **Components Funcionals**: High-level functional components from a user perspective

See the `diagrams/README.md` file for more information about these individual diagrams.

## How to View or Generate the Diagram

1. **Online PlantUML Viewer**: 
   - Go to [PlantUML Web Server](https://www.plantuml.com/plantuml/uml/)
   - Copy and paste the content of `architecture.puml` to view the diagram

2. **VSCode Extension**:
   - Install the "PlantUML" extension in Visual Studio Code
   - Open the `architecture.puml` file
   - Use Alt+D to preview the diagram

3. **Local PlantUML**:
   - If you have PlantUML installed locally, you can generate an image with:
     ```
     java -jar plantuml.jar architecture.puml
     ```

## Architecture Overview

The application follows a three-layer architecture:

1. **Presentation Layer**:
   - Screens: Main UI screens of the application
   - Widgets: Reusable UI components categorized by function
   - Navigation: Components handling app navigation

2. **Core Layer**:
   - Services: Business logic components
   - Models: Data models representing application entities
   - Utils & Constants: Helper classes and application constants

3. **Data Layer**:
   - Repositories: Abstraction over data sources
   - Data Sources: Components interacting with external APIs and local storage

## Key Components

- **UnaffiliatedProfileScreen**: Shows profile data for non-connected users
- **BroadcastService**: Central service coordinating communication between UI and data
- **UserHeader**: Common component for displaying user information
- **TopFiveAlbums**, **StarOfTheDay**, **UserCompatibility**: Profile components showing music preferences
