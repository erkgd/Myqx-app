# Generating PlantUML Diagrams

This guide explains how to generate PNG images from the PlantUML diagram in this project.

## Prerequisites

To generate the diagram image, you need:

1. Java Runtime Environment (JRE) installed
2. PlantUML JAR file

## How to Generate the Diagram

### Option 1: Using the PlantUML JAR

1. Download the PlantUML JAR file from [PlantUML website](https://plantuml.com/download)
2. Run the following command in terminal:
```
java -jar path/to/plantuml.jar docs/architecture.puml
```
3. This will generate `architecture.png` in the same directory as the `.puml` file

### Option 2: Using Visual Studio Code

1. Install the "PlantUML" extension for VS Code
2. Open `architecture.puml`
3. Use Alt+D to preview the diagram
4. Click the "Export Diagram" button in the preview to save as PNG

### Option 3: Using Online PlantUML Server

1. Open [PlantUML Web Server](https://www.plantuml.com/plantuml/uml/)
2. Copy and paste the content of `architecture.puml`
3. Use the "Save as PNG" option

## Diagram Location

After generating, please save the PNG file in the `docs/images` directory with the name `architecture.png` for reference in documentation.
