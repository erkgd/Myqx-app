# Diagrames d'Arquitectura Myqx-app

Aquest directori conté diversos diagrames PlantUML que mostren diferents aspectes de l'arquitectura de Myqx-app. Cada diagrama es centra en un aspecte específic per facilitar la comprensió de l'estructura del projecte.

## Llista de Diagrames

1. **01_overview_architecture.puml**
   - **Descripció**: Visió general de l'arquitectura de tres capes (Presentació, Nucli, Dades)
   - **Propòsit**: Mostrar l'estructura d'alt nivell i les relacions entre les principals capes

2. **02_presentation_layer.puml**
   - **Descripció**: Detall de la capa de presentació, incloent pantalles i widgets
   - **Propòsit**: Visualitzar els components d'UI i les seves relacions

3. **03_core_layer.puml**
   - **Descripció**: Detall de la capa de nucli amb serveis, models i utilitats
   - **Propòsit**: Mostrar la lògica de negoci i la gestió de dades dins de l'aplicació

4. **04_data_layer.puml**
   - **Descripció**: Detall de la capa de dades i la seva connexió amb sistemes externs
   - **Propòsit**: Il·lustrar com l'aplicació interactua amb APIs i emmagatzematge

5. **05_cross_layer_flow.puml**
   - **Descripció**: Flux de dades i control entre les diferents capes
   - **Propòsit**: Explicar com flueix una sol·licitud des de la UI fins a les dades i de tornada

6. **06_profile_components.puml**
   - **Descripció**: Enfocament específic en els components del perfil d'usuari
   - **Propòsit**: Detallar l'estructura interna d'una funcionalitat específica

7. **07_functional_components.puml**
   - **Descripció**: Components funcionals d'alt nivell de l'aplicació
   - **Propòsit**: Mostrar les principals funcionalitats de l'aplicació des d'una perspectiva d'usuari

## Generació d'Imatges

Per generar imatges a partir d'aquests fitxers PlantUML, consulteu les instruccions al fitxer `../GENERATE_DIAGRAM.md`.

## Recomanacions de Visualització

Per una millor comprensió de l'arquitectura, es recomana revisar els diagrames en el següent ordre:

1. Visió general (01_overview_architecture)
2. Flux entre capes (05_cross_layer_flow)
3. Detalls de cada capa (02, 03, 04)
4. Components específics (06)
