# Components de la Solució Myqx-app

## 1. Arquitectura General

### 1.1 Descripció Funcional
L'aplicació Myqx està dissenyada amb una arquitectura en capes que segueix els principis del Clean Architecture. Aquesta arquitectura separa clarament les responsabilitats entre presentació, lògica de negoci i accés a dades, facilitant el desenvolupament, el testing i el manteniment. L'estructura principal es divideix en tres capes ben definides: Presentació, Core/Domini i Dades.

### 1.2 Tecnologies Utilitzades
- **Flutter/Dart**: Escollit pel seu desenvolupament multiplataforma, rendiment natiu i comunitat activa. Alternatives com React Native o Xamarin requerien més codi específic per plataforma i tenien més limitacions en rendiment.
- **Clean Architecture**: Implementa una separació robusta entre capes. Es va preferir sobre MVC tradicional per facilitar la testabilitat i reduir acoblaments entre components.
- **Gestió d'Estat**: S'utilitza el patró BLoC per a una gestió d'estat predictible i escalable.

### 1.3 Problemes i Solucions
- **Problema**: Complexitat inicial en l'estructuració del projecte i la visualització de l'arquitectura.
- **Solució**: Implementació de diagrames UML per visualitzar i planificar l'arquitectura abans de la codificació, facilitant la comprensió global i la comunicació entre els membres de l'equip.

- **Problema**: Integració entre les diferents capes mantenint el desacoblament.
- **Solució**: Creació d'un sistema de serveis centralitzats (especialment el BroadcastService) que actua com a mediador entre components.

### 1.4 Codi Determinant
El fitxer `main.dart` estableix l'estructura base de l'aplicació i la injecció de dependències per mantenir els components desacoblats:

```dart
// Fragment de main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicialització dels serveis principals
  final broadcastService = BroadcastService();
  final authService = AuthService();
  final spotifyService = SpotifyService();
  
  // Injecció de dependències
  // ...
  
  runApp(MyApp(
    broadcastService: broadcastService,
    authService: authService,
  ));
}
```

### 1.5 Informació Detallada
Vegeu Annex A: Diagrama Complet d'Arquitectura (`architecture.puml`), Annex B: Estructura de Fitxers i Annex C: Diagrames Específics per Capes (`01_overview_architecture.puml`).

## 2. Capa de Presentació

### 2.1 Descripció Funcional
Aquesta capa gestiona la interfície d'usuari i la interacció amb l'usuari. Utilitza widgets, pantalles i gestors d'estat per mostrar i recollir informació. Està organitzada en quatre components principals: Pantalles, Widgets de Perfil, Widgets Generals i elements de Navegació.

### 2.2 Tecnologies Utilitzades
- **Flutter Widgets**: Per a la interfície d'usuari reactiva, aprofitant el sistema de composició de widgets per crear interfícies complexes i reutilitzables.
- **Bloc Pattern**: Elegit sobre Provider o GetX per la seva gestió d'estat predictible i la separació clara entre la UI, els events i els states.
- **Material Design**: Per garantir una experiència d'usuari consistent i moderna.

### 2.3 Problemes i Solucions
- **Problema**: Gestió d'estat complexa en pantalles amb múltiples fonts de dades, especialment en vistes que combinen informació de perfil d'usuari i dades musicals.
- **Solució**: Implementació de blocs compostos que coordinen diversos repositoris mitjançant un servei centralitzat (BroadcastService) que permet actualitzacions parcials de la UI.

- **Problema**: Rendiment en la visualització de llistes llargues de contingut musical.
- **Solució**: Implementació de tècniques de càrrega lazy i widgets virtualitzats per optimitzar l'ús de memòria i millorar la fluïdesa.

### 2.4 Codi Determinant
Els widgets de perfil i la integració amb la reproducció d'àudio:

```dart
// Fragment d'un widget de perfil
class ProfileMusicWidget extends StatelessWidget {
  final UserModel user;
  final SpotifyProfileService spotifyService;
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        // Lògica de renderitzat condicional segons l'estat
        // ...
      }
    );
  }
}
```

### 2.5 Informació Detallada
Vegeu Annex D: Diagrama de Components de la UI (`02_presentation_layer.puml`) i Annex E: Flux d'Interacció amb l'Usuari (`05_cross_layer_flow.puml`).

## 3. Capa de Nucli (Core) i Domini

### 3.1 Descripció Funcional
Aquesta capa constitueix el cor de l'aplicació, dividint-se en:

- **Core**: Proporciona la infraestructura i serveis base com HTTP, Storage, Constants, Config, Utils i gestió d'excepcions.
- **Domini**: Conté les entitats, models, repositoris i casos d'ús que implementen la lògica de negoci específica de l'aplicació.

Aquesta divisió segueix els principis de Clean Architecture, on el domini representa les regles de negoci independents de la infraestructura.

### 3.2 Tecnologies Utilitzades
- **Casos d'Ús (UseCases)**: Implementen operacions de negoci específiques, preferits sobre serveis genèrics per la seva millor testabilitat i encapsulament.
- **Entitats i Models**: Representen les estructures de dades de l'aplicació, amb entitats pures al domini i models amb més funcionalitat.
- **Serveis Especialitzats**: Una família de serveis que proporcionen funcionalitats específiques, especialment enfocats a la integració amb Spotify.

### 3.3 Problemes i Solucions
- **Problema**: Integració complexa amb les APIs externes, especialment Spotify.
- **Solució**: Creació d'una família especialitzada de serveis Spotify (AuthService, ProfileService, SearchService, etc.) que s'encarreguen de diferents aspectes, coordinats pel BroadcastService.

- **Problema**: Gestió de dependències entre serveis mantenint la testabilitat.
- **Solució**: Implementació d'un sistema d'injecció de dependències que permet substituir implementacions per mocks en tests.

### 3.4 Codi Determinant
El BroadcastService, element central de coordinació:

```dart
// Fragment de BroadcastService
class BroadcastService {
  final _profileController = StreamController<ProfileEvent>.broadcast();
  final _searchController = StreamController<SearchEvent>.broadcast();
  
  Stream<ProfileEvent> get profileStream => _profileController.stream;
  Stream<SearchEvent> get searchStream => _searchController.stream;
  
  void updateProfile(ProfileEvent event) {
    _profileController.add(event);
  }
  
  void search(SearchEvent event) {
    _searchController.add(event);
  }
}
```

### 3.5 Informació Detallada
Vegeu Annex F: Diagrama del Core i Domini (`03_core_layer.puml`) i Annex G: Documentació dels Serveis Core.

## 4. Capa de Dades

### 4.1 Descripció Funcional
Gestiona l'accés a dades externes (APIs) i locals (emmagatzematge al dispositiu), abstraient aquests detalls de la resta de l'aplicació mitjançant repositoris. Inclou repositoris, fonts de dades i la comunicació amb sistemes externs com l'API de Spotify i l'emmagatzematge local.

### 4.2 Tecnologies Utilitzades
- **Repositori Pattern**: Per desacoblar les fonts de dades de la lògica de negoci, permetent canviar implementacions sense afectar la resta del sistema.
- **HTTP Client**: Per comunicació amb APIs REST, amb suport per interceptors que gestionen autenticació i errors.
- **Secure Storage**: Per emmagatzemar informació sensible (com tokens d'autenticació). Escollit sobre alternatives més simples per la seva seguretat.
- **Mappers**: Per transformar dades entre formats d'API i models interns.

### 4.3 Problemes i Solucions
- **Problema**: Gestió de tokens d'autenticació i refrescament.
- **Solució**: Implementació d'interceptors HTTP que gestionen automàticament la renovació de tokens caducats sense interrumpre l'experiència d'usuari.

- **Problema**: Estructura complexa de respostes de l'API de Spotify.
- **Solució**: Creació de mappers especialitzats que transformen les dades a models interns més útils i manejables.

### 4.4 Codi Determinant
Els repositoris específics i interceptors HTTP:

```dart
// Fragment de SpotifyRepository
class SpotifyRepositoryImpl implements SpotifyRepositoryInterface {
  final HttpClient client;
  final LocalStorage storage;
  
  @override
  Future<UserEntity> getUserProfile(String accessToken) async {
    final response = await client.get('/me', 
      headers: {'Authorization': 'Bearer $accessToken'});
    return UserMapper.fromJson(response.data);
  }
}
```

### 4.5 Informació Detallada
Vegeu Annex H: Diagrama de la Capa de Dades (`04_data_layer.puml`) i Annex I: Documentació d'APIs Externes.

## 5. Integració amb Spotify

### 5.1 Descripció Funcional
Component especialitzat que permet a l'aplicació connectar-se amb l'API de Spotify per accedir a informació musical, perfils d'usuari, i reproduir fragments d'àudio. És una part central de l'aplicació que proporciona la majoria del contingut musical.

### 5.2 Tecnologies Utilitzades
- **OAuth 2.0**: Per autenticació segura amb Spotify. Preferit sobre solucions més simples per ser l'estàndard de la indústria i requisit de l'API de Spotify.
- **WebView Integration**: Per processos d'autenticació interactius que permeten l'inici de sessió d'usuaris.
- **Audio Playback**: Reproducció d'àudio integrada amb previsualitzacions de cançons de Spotify.

### 5.3 Problemes i Solucions
- **Problema**: Gestió del flux OAuth en aplicacions mòbils.
- **Solució**: Implementació d'un Custom URL Scheme que permet la redirecció segura després de l'autenticació, facilitant l'experiència d'usuari.

- **Problema**: Limitacions en les crides a l'API de Spotify i gestió de quotes.
- **Solució**: Sistema de cache i control de freqüència de peticions per evitar arribat als límits de l'API.

### 5.4 Codi Determinant
La integració amb Spotify a través dels serveis especialitzats:

```dart
// Fragment de SpotifyAuthService
class SpotifyAuthService {
  final SecureStorage _storage;
  final HttpClient _client;
  
  Future<String> authenticate() async {
    // Implementació del flux OAuth 2.0
    // ...
    
    // Emmagatzematge segur del token
    await _storage.write('spotify_token', token);
    return token;
  }
  
  Future<String> refreshToken() async {
    // Lògica per refrescar el token
    // ...
  }
}
```

### 5.5 Informació Detallada
Vegeu Annex J: Diagrama de Flux d'Autenticació OAuth i Annex K: Documentació d'Endpoints de Spotify.

## 6. Serveis Transversals

### 6.1 Descripció Funcional
Serveis que proporcionen funcionalitat utilitzada per múltiples components de l'aplicació, com gestió d'errors, logging, i configuració. Actuen com a infraestructura comuna per tota l'aplicació.

### 6.2 Tecnologies Utilitzades
- **BroadcastService**: Sistema de missatgeria intern per coordinar components seguint el patró Mediator.
- **Gestió d'Excepcions Centralitzada**: Per manejar errors de forma consistent i proporcionar feedback adequat a l'usuari.
- **Logging**: Per registrar events importants i facilitar el debugging.

### 6.3 Problemes i Solucions
- **Problema**: Comunicació entre components desacoblats sense crear dependències creuades.
- **Solució**: Implementació del patró mediador a través del BroadcastService que permet la comunicació indirecta entre components.

- **Problema**: Gestió consistent d'errors a tots els nivells de l'aplicació.
- **Solució**: Sistema d'excepcions jerarquitzat que permet capturar i tractar errors específics.

### 6.4 Codi Determinant
Gestió d'errors i logging:

```dart
// Fragment de sistema d'excepcions
class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, {this.code});
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code}) 
    : super(message, code: code);
}

// Al lloc on es captura
try {
  // Operació que pot fallar
} on NetworkException catch (e) {
  logger.log('Error de xarxa: ${e.message}');
  // Gestió específica
} on AppException catch (e) {
  logger.log('Error general: ${e.message}');
  // Gestió general
}
```

### 6.5 Informació Detallada
Vegeu Annex L: Diagrama de Components Transversals i Annex M: Documentació de Gestió d'Errors.

## 7. Experiència d'Usuari

### 7.1 Descripció Funcional
Aquest component abasta els aspectes visuals i d'interacció que fan que l'aplicació sigui intuïtiva, atractiva i eficient per als usuaris. Inclou el disseny visual, els fluxos d'usuari i els elements d'interacció.

### 7.2 Tecnologies Utilitzades
- **Material Design**: Per una interfície moderna i consistent que segueix guies establertes.
- **Animacions Personalitzades**: Per millorar l'experiència d'usuari en transicions i interaccions.
- **Responsive Design**: Adaptació a diferents mides de pantalla i orientacions.

### 7.3 Problemes i Solucions
- **Problema**: Rendiment en la visualització de llistes llargues.
- **Solució**: Implementació de tècniques de càrrega lazy i reciclatge de widgets per optimitzar el rendiment.

- **Problema**: Consistència visual entre diferents pantalles i components.
- **Solució**: Creació d'un sistema de temes i components compartits que garanteixen consistència visual.

### 7.4 Codi Determinant
Implementació de widgets personalitzats per a l'experiència musical:

```dart
// Fragment de MusicPlayerWidget
class MusicPlayerWidget extends StatefulWidget {
  final String previewUrl;
  final String trackName;
  final String artistName;
  
  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  late AudioPlayer _audioPlayer;
  
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }
  
  Future<void> _initializePlayer() async {
    // Configuració del reproductor d'àudio
    // ...
  }
  
  @override
  Widget build(BuildContext context) {
    // Interfície del reproductor
    // ...
  }
}
```



