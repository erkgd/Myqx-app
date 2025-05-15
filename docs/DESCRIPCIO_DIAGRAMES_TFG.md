# Diagrames d'Arquitectura per al TFG: Aplicació Myqx

## Introducció

Aquest document presenta els diagrames d'arquitectura de l'aplicació Myqx, una xarxa social orientada a la música que permet als usuaris connectar a través de les seves preferències musicals. Els diagrames s'han creat utilitzant PlantUML i mostren l'estructura del sistema des de diferents perspectives.

## Descripció dels Diagrames

### 1. Arquitectura General (01_overview_architecture.puml)

**Descripció:** Aquest diagrama presenta una visió d'alt nivell de l'arquitectura de l'aplicació Myqx, mostrant la divisió en tres capes principals: Presentació, Nucli i Dades. S'il·lustren les relacions generals entre aquestes capes, oferint una perspectiva global del sistema.

**Rellevància per al TFG:** La visualització de l'arquitectura general permet entendre ràpidament l'enfocament de disseny adoptat, demostrant l'aplicació del patró arquitectònic en capes. Aquest patró facilita la separació de responsabilitats i millora la mantenibilitat del sistema, aspectes fonamentals a considerar en el desenvolupament d'aplicacions mòbils modernes.

**Elements clau:**
- **Capa de Presentació:** Encarregada de la interfície d'usuari
- **Capa de Nucli:** Gestiona la lògica de negoci
- **Capa de Dades:** Responsable de l'accés i persistència de dades
- **Relacions entre capes:** Mostren el flux d'informació a través del sistema

### 2. Capa de Presentació (02_presentation_layer.puml)

**Descripció:** Aquest diagrama detalla tots els components de la interfície d'usuari de l'aplicació, incloent les diferents pantalles, widgets de perfil, widgets generals i elements de navegació. Mostra com s'estructuren i es relacionen aquests components visuals.

**Rellevància per al TFG:** L'anàlisi de la capa de presentació il·lustra l'aplicació de principis de disseny d'interfícies d'usuari, com la componentització i la reutilització. Demostra com s'ha implementat una estructura modular que facilita tant el desenvolupament com les futures ampliacions de la interfície.

**Elements clau:**
- **Pantalles:** Components principals de la interfície (Inicial, Perfil, Login, etc.)
- **Widgets de Perfil:** Components especialitzats per mostrar informació musical de l'usuari
- **Widgets Generals:** Components reutilitzables en diverses parts de l'aplicació
- **Navegació:** Estructura que permet el moviment entre les diferents pantalles

### 3. Capa Core i Domain (03_core_layer.puml)

**Descripció:** Aquest diagrama mostra en detall l'estructura real del projecte centrant-se en les capes Core i Domain. La capa Core conté la infraestructura i utilitats base, mentre que la capa Domain gestiona els models de dades, repositoris i casos d'ús que implementen la lògica de negoci. Es visualitzen les relacions entre aquests components i com s'organitzen segons l'arquitectura real del codi.

**Rellevància per al TFG:** L'estudi d'aquestes capes demostra l'aplicació d'una arquitectura neta (Clean Architecture) que separa clarament les responsabilitats. La capa Domain encapsula la lògica de negoci pura mentre que la capa Core proporciona la infraestructura necessària sense dependre de detalls d'implementació externs. Aquesta separació millora la testabilitat i mantenibilitat del sistema.

**Elements clau:**
- **Core Layer:**
  - **Config i Constants:** Configuracions i constants globals de l'aplicació
  - **HTTP:** Components per a la comunicació amb APIs
  - **Services:** Serveis d'infraestructura com analítiques i connectivitat
  - **Storage:** Gestió de l'emmagatzematge local i segur
  - **Utils:** Utilitats compartides per tota l'aplicació
  - **Exceptions:** Gestió centralitzada d'errors

- **Domain Layer:**
  - **Entities:** Objectes de domini purs que representen conceptes clau
  - **Models:** Representacions més riques dels conceptes del domini
  - **Repositories:** Interfícies que defineixen com accedir a les dades
  - **UseCases:** Implementacions de la lògica de negoci específica

- **Relacions entre capes:** Mostren com la capa Core proporciona suport a la capa Domain mantenint la independència de la lògica de negoci

### 4. Capa de Dades (04_data_layer.puml)

**Descripció:** Aquest diagrama detalla els components responsables de l'accés i persistència de les dades, incloent els repositoris, les fonts de dades i les connexions amb sistemes externs com l'API de Spotify i l'emmagatzematge local.

**Rellevància per al TFG:** L'anàlisi de la capa de dades demostra l'aplicació del patró Repositori, que permet abstraure les fonts de dades i facilitar els canvis en la implementació subjacent sense afectar la resta del sistema. També mostra la integració amb APIs externes, un aspecte crític en aplicacions modernes.

**Elements clau:**
- **Repositoris:** Abstraccions que gestionen l'accés a les dades
- **Fonts de Dades:** Components que interactuen directament amb APIs i emmagatzematge
- **Sistemes Externs:** APIs i bases de dades amb les que es comunica l'aplicació
- **Patrons d'accés:** Il·lustració de com es recupera i s'emmagatzema la informació

### 5. Flux Entre Capes (05_cross_layer_flow.puml)

**Descripció:** Aquest diagrama il·lustra el flux de dades i control a través de les diferents capes de l'aplicació, mostrant com una sol·licitud d'usuari es propaga des de la interfície fins a les fonts de dades i com la resposta retorna a l'usuari.

**Rellevància per al TFG:** La comprensió del flux entre capes és essencial per entendre el funcionament dinàmic de l'aplicació. Aquest diagrama demostra l'aplicació de principis de comunicació entre components i la gestió del cicle de vida de les peticions, aspectes fonamentals en el desenvolupament d'aplicacions escalables i mantenibles.

**Elements clau:**
- **Seqüència d'operacions:** Numeració que mostra l'ordre dels processos
- **Direcció del flux:** Indicació de com es propaga la informació
- **Transformació de dades:** Com les dades es processen en passar d'una capa a una altra
- **Cicle complet:** Visualització de tot el recorregut d'una sol·licitud fins a la seva resposta

### 6. Components de Perfil (06_profile_components.puml)

**Descripció:** Aquest diagrama es centra en els components específics relacionats amb la visualització i gestió del perfil d'usuari, mostrant com s'integren els diferents widgets i serveis per oferir aquesta funcionalitat concreta.

**Rellevància per al TFG:** L'estudi d'un cas concret com el perfil d'usuari permet aprofundir en la implementació pràctica dels principis arquitectònics. Aquest diagrama demostra com els diferents components col·laboren per oferir una funcionalitat complexa, il·lustrant la modularitat i la cohesió del sistema.

**Elements clau:**
- **Components visuals:** Widgets específics per mostrar informació de perfil
- **Integració de dades:** Com els components visuals es connecten amb els serveis
- **Flux d'informació:** Com les dades del perfil s'obtenen i es mostren
- **Responsabilitats específiques:** Distribució de tasques entre els diferents components

### 7. Arquitectura Completa (architecture.puml)

**Descripció:** Aquest diagrama integra tots els components de l'aplicació en una única vista, mostrant l'estructura completa del sistema amb totes les seves capes i relacions. Serveix com a referència global de l'arquitectura.

**Rellevància per al TFG:** La visió completa de l'arquitectura permet entendre la complexitat del sistema en la seva totalitat. Aquest diagrama demostra com tots els components s'integren per formar una aplicació cohesionada, il·lustrant l'aplicació dels principis de disseny de software a escala global.

**Elements clau:**
- **Visió integral:** Tots els components del sistema en un únic diagrama
- **Relacions globals:** Connexions entre components de diferents capes
- **Estructura general:** Organització jeràrquica dels components
- **Patrons de disseny:** Visualització de com s'apliquen a nivell global

### 8. Components Funcionals (07_functional_components.puml)

**Descripció:** Aquest diagrama presenta una visió d'alt nivell centrada en les funcionalitats principals de l'aplicació des de la perspectiva de l'usuari, mostrant els grans blocs funcionals i com interactuen entre si, així com amb actors externs i sistemes de tercers.

**Rellevància per al TFG:** L'anàlisi funcional permet connectar l'arquitectura tècnica amb els requisits i casos d'ús del sistema. Aquest diagrama demostra com les necessitats dels usuaris es tradueixen en components funcionals, il·lustrant l'enfocament orientat a l'usuari que ha guiat el desenvolupament de l'aplicació.

**Elements clau:**
- **Components funcionals principals:** Gestió de perfil, descobriment musical, compatibilitat entre usuaris, etc.
- **Components de suport:** Autenticació, emmagatzematge, analítiques, notificacions
- **Actors:** Usuaris i artistes/creadors que interactuen amb el sistema
- **Flux d'interacció:** Com els usuaris naveguen entre les diverses funcionalitats
- **Integració externa:** Connexions amb serveis musicals de tercers

## Conclusions sobre l'Arquitectura

Els diagrames presentats il·lustren una arquitectura en tres capes ben definida, amb una clara separació de responsabilitats entre la presentació, la lògica de negoci i les dades, així com una organització funcional centrada en l'usuari. Aquest disseny ofereix diversos avantatges:

1. **Modularitat:** Els components poden ser desenvolupats, testejats i mantinguts de manera independent.
2. **Extensibilitat:** Nous components poden ser afegits sense necessitat de modificar els existents.
3. **Mantenibilitat:** La separació de responsabilitats facilita la localització i correcció d'errors.
4. **Reutilització:** Components com els widgets generals poden ser utilitzats en diferents parts de l'aplicació.
5. **Orientació a l'usuari:** L'organització funcional facilita la comprensió de com l'estructura tècnica satisfà les necessitats dels usuaris.
6. **Escalabilitat:** La separació clara entre components funcionals permet l'evolució independent de cada àrea de l'aplicació.

L'arquitectura implementada segueix les millors pràctiques de desenvolupament de software modern, aplicant patrons de disseny adequats per a cada capa i establint una comunicació clara entre elles. La integració entre la visió tècnica (arquitectura en capes) i la visió funcional (components d'alt nivell) permet una comprensió completa del sistema des de múltiples perspectives.

## Recomanacions per al TFG

En el context del TFG, aquests diagrames poden ser utilitzats per:

1. **Il·lustrar el procés de disseny:** Mostrar com s'ha passat dels requisits a una arquitectura estructurada.
2. **Justificar decisions tecnològiques:** Explicar per què s'han escollit determinats patrons o tecnologies.
3. **Analitzar la qualitat del software:** Avaluar aspectes com l'acoblament, la cohesió i l'extensibilitat.
4. **Proposar millores futures:** Identificar àrees on l'arquitectura podria evolucionar en futures versions.
