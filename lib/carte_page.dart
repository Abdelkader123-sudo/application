import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:traceur_app/l10n/app_localizations.dart';

import 'locale_controller.dart';
import 'ws_service.dart';

/// Écran de suivi des troupeaux (lecture seule, mise à jour en direct).
class CartePage extends StatefulWidget {
  const CartePage({
    super.key,
    required this.service,
    this.apiUrl = 'https://traceur-backend.onrender.com/pastures',
  });

  final WsService service;
  final String apiUrl;

  @override
  State<CartePage> createState() => _CartePageState();
}

class _CartePageState extends State<CartePage> {
  static const _green = Color(0xFF187653);
  static const _deepGreen = Color(0xFF123D2E);
  static const _blue = Color(0xFF2876D2);
  static const _purple = Color(0xFF9655D8);
  static const _cyan = Color(0xFF00A8C8);
  static const _pink = Color(0xFFE34B8C);
  static const _canvas = Color(0xFFF5F8F5);
  static const _red = Color(0xFFD34444);
  static const _orange = Color(0xFFE08A1E);

  /// AJOUT PÂTURAGE : couleur dédiée à la zone de pâturage.
  static const _zoneColor = Color(0xFF0B6E4F);

  /// AJOUT : types d'alerte traités à part sur la carte.
  static const _typeDistanceTroupeau = 'sortie_zone';
  static const _typeCollier = 'collier_silencieux';

  static const _herdPalette = <Color>[
    _blue,
    _orange,
    _purple,
    _cyan,
    _green,
    _pink,
  ];

  /// Zoom à partir duquel les noms des animaux sont affichés sur la carte.
  static const _zoomNoms = 16.5;

  final _mapController = MapController();
  final _searchController = TextEditingController();

  /// Alertes hors_pature déjà vues (évite de les afficher deux fois).
  final Set<String> _seenPastureAlerts = {};
  bool _alertsInitialized = false;

  bool _hasAutoCentered = false;
  bool _zoneCentree = false; // AJOUT PÂTURAGE : recadrage quand la zone arrive
  bool _nomsVisibles = false;
  LatLng? _searchedPoint;
  String? _selectedAnimalId;

  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onServiceChanged);
    _onServiceChanged();
  }

  @override
  void dispose() {
    widget.service.removeListener(_onServiceChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Alertes
  // ---------------------------------------------------------------------
  void _onServiceChanged() {
    final fresh = <Map<String, dynamic>>[];
    for (final alert in widget.service.alertes) {
      if (alert['type'] != 'hors_pature' || alert['resolue'] == true) continue;
      final key = '${alert['animal_id']}|${alert['timestamp']}';
      if (_seenPastureAlerts.add(key) && _alertsInitialized) fresh.add(alert);
    }
    if (widget.service.connecte) _alertsInitialized = true;
    if (fresh.isEmpty) return;

    if (fresh.length == 1) {
      final alert = fresh.first;
      final loc = AppLocalizations.of(context)!;
      _showMessage(
        '${alert['animal_id']} · ${loc.animalOutsidePasture}',
        isError: true,
        duration: const Duration(seconds: 8),
      );
    } else {
      final ids = fresh.map((a) => a['animal_id']).join(', ');
      _showMessage(
        AppLocalizations.of(context)!.animalsOutsideZone(fresh.length, ids),
        isError: true,
        duration: const Duration(seconds: 8),
      );
    }
  }

  /// MODIFIÉ : animaux avec une alerte active, SAUF la distance au grand
  /// troupeau (déjà visible par le cercle rouge et le trait de mesure).
  Set<String> _animalsWithActiveAlerts() {
    return widget.service.alertes
        .where(
          (alert) =>
              alert['resolue'] != true &&
              alert['type'] != _typeDistanceTroupeau,
        )
        .map((alert) => alert['animal_id']?.toString())
        .whereType<String>()
        .toSet();
  }

  /// AJOUT : animaux dont le collier n'envoie plus de signal.
  Set<String> _animalsWithSilentCollar() {
    return widget.service.alertes
        .where(
          (alert) => alert['resolue'] != true && alert['type'] == _typeCollier,
        )
        .map((alert) => alert['animal_id']?.toString())
        .whereType<String>()
        .toSet();
  }

  // ---------------------------------------------------------------------
  // Données
  // ---------------------------------------------------------------------
  LatLng? _readPosition(dynamic value) {
    if (value is! Map) return null;
    final latitude = value['lat'];
    final longitude = value['lon'];
    if (latitude is! num || longitude is! num) return null;

    final lat = latitude.toDouble();
    final lon = longitude.toDouble();
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) return null;
    return LatLng(lat, lon);
  }

  Map<String, LatLng> _currentPositions() {
    final result = <String, LatLng>{};
    for (final entry in widget.service.positions.entries) {
      final point = _readPosition(entry.value);
      if (point != null) result[entry.key.toString()] = point;
    }
    return result;
  }

  /// AJOUT PÂTURAGE : lit la zone, que le service fournisse directement la
  /// liste des sommets ou un objet {name, coordinates}.
  List<LatLng> _savedPasturePoints() {
    dynamic raw = widget.service.pature;
    if (raw is Map) raw = raw['coordinates'];
    if (raw is! List) return const [];
    final points = <LatLng>[];
    for (final c in raw) {
      if (c is! Map) continue;
      final lat = c['latitude'] ?? c['lat'];
      final lon = c['longitude'] ?? c['lon'] ?? c['lng'];
      if (lat is num && lon is num) {
        points.add(LatLng(lat.toDouble(), lon.toDouble()));
      }
    }
    return points;
  }

  /// AJOUT PÂTURAGE : centre approximatif du polygone (pour l'étiquette).
  LatLng _pastureCenter(List<LatLng> points) {
    final lat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final lon =
        points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    return LatLng(lat, lon);
  }

  /// Troupeaux fournis par le backend (null si pas d'analyse disponible).
  Map<String, dynamic>? _troupeaux() {
    final t = widget.service.troupeau;
    if (t == null || t['statut'] != 'ok') return null;
    return t;
  }

  List<String> _readAnimalIds(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((animal) {
          if (animal is Map) {
            return (animal['animal_id'] ?? animal['id'] ?? animal['tag'])
                ?.toString();
          }
          return animal?.toString();
        })
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
  }

  double? _readNumber(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.'));
    return null;
  }

  LatLng? _readGroupCenter(
    Map zone,
    Map<String, LatLng> positions,
    List<String> animalIds,
  ) {
    final nestedCenter = zone['centre'] ?? zone['center'];
    if (nestedCenter is Map) {
      final nested = _readPosition({
        'lat':
            nestedCenter['lat'] ??
            nestedCenter['latitude'] ??
            nestedCenter['centre_lat'] ??
            nestedCenter['center_lat'],
        'lon':
            nestedCenter['lon'] ??
            nestedCenter['lng'] ??
            nestedCenter['longitude'] ??
            nestedCenter['centre_lon'] ??
            nestedCenter['center_lon'],
      });
      if (nested != null) return nested;
    }

    final direct = _readPosition({
      'lat':
          zone['centre_lat'] ??
          zone['center_lat'] ??
          zone['latitude'] ??
          zone['lat'],
      'lon':
          zone['centre_lon'] ??
          zone['center_lon'] ??
          zone['longitude'] ??
          zone['lon'] ??
          zone['lng'],
    });
    if (direct != null) return direct;

    final animalPoints = animalIds
        .map((id) => positions[id])
        .whereType<LatLng>()
        .toList();
    if (animalPoints.isEmpty) return null;
    final averageLatitude =
        animalPoints.map((point) => point.latitude).reduce((a, b) => a + b) /
        animalPoints.length;
    final averageLongitude =
        animalPoints.map((point) => point.longitude).reduce((a, b) => a + b) /
        animalPoints.length;
    return LatLng(averageLatitude, averageLongitude);
  }

  /// Prépare les groupes, leur centre, leur rayon et leur distance au grand
  /// troupeau. Si le backend n'envoie pas de centre, il est déduit des GPS.
  List<_HerdGroup> _herdGroups() {
    final data = _troupeaux();
    if (data == null) return const [];

    final positions = _currentPositions();
    final groups = <_HerdGroup>[];

    _HerdGroup? createGroup({
      required Map raw,
      required String label,
      required Color color,
      required bool isMain,
      required bool isAlert,
    }) {
      final zone = raw['zone'] is Map ? raw['zone'] as Map : raw;
      final animals = _readAnimalIds(zone['animaux'] ?? raw['animaux']);
      final center =
          _readGroupCenter(zone, positions, animals) ??
          _readGroupCenter(raw, positions, animals);
      if (center == null) return null;

      final rawRadius = _readNumber(
        zone['rayon_m'] ??
            zone['radius_m'] ??
            raw['rayon_m'] ??
            raw['radius_m'],
      );
      var radius = rawRadius;
      if (radius == null) {
        final animalPoints = animals
            .map((id) => positions[id])
            .whereType<LatLng>();
        final distances = animalPoints
            .map(
              (point) => const Distance().as(LengthUnit.Meter, center, point),
            )
            .toList();
        radius = distances.isEmpty
            ? 25.0
            : distances.reduce((a, b) => a > b ? a : b) + 10.0;
      }

      return _HerdGroup(
        label: label,
        color: isAlert ? _red : color,
        center: center,
        radiusMeters: radius.clamp(15, 100000).toDouble(),
        animalIds: animals,
        isMain: isMain,
        isAlert: isAlert,
      );
    }

    final loc = AppLocalizations.of(context)!;
    final mainRaw = data['grand_troupeau'];
    if (mainRaw is Map) {
      final main = createGroup(
        raw: mainRaw,
        label: loc.herdGroupLabel,
        color: _herdPalette.first,
        isMain: true,
        isAlert: false,
      );
      if (main != null) groups.add(main);
    }

    final others = data['autres_groupes'];
    if (others is List) {
      var smallGroupNumber = 0;
      for (final value in others) {
        if (value is! Map) continue;
        final zone = value['zone'] is Map ? value['zone'] as Map : value;
        final animals = _readAnimalIds(zone['animaux'] ?? value['animaux']);
        final isIndividual = animals.length == 1;
        if (!isIndividual) smallGroupNumber++;
        final label = isIndividual
            ? loc.isolatedCow(animals.first)
            : loc.smallHerdLabel(smallGroupNumber);
        final existingSmallGroups = groups
            .where((group) => !group.isMain)
            .length;
        final color =
            _herdPalette[(existingSmallGroups + 1) % _herdPalette.length];
        final group = createGroup(
          raw: value,
          label: label,
          color: color,
          isMain: false,
          isAlert: value['depasse_seuil'] == true,
        );
        if (group != null) groups.add(group);
      }
    }

    final main = _mainGroup(groups);
    if (main == null) return groups;
    return groups
        .map(
          (group) => group.isMain
              ? group
              : group.withDistance(
                  const Distance().as(
                    LengthUnit.Meter,
                    main.center,
                    group.center,
                  ),
                ),
        )
        .toList();
  }

  /// Couleur de chaque animal selon le groupe détecté.
  Map<String, Color> _animalColors(List<_HerdGroup> groups) {
    final colors = <String, Color>{};
    for (final group in groups) {
      for (final id in group.animalIds) {
        colors[id] = group.color;
      }
    }
    return colors;
  }

  _HerdGroup? _mainGroup(List<_HerdGroup> groups) {
    for (final group in groups) {
      if (group.isMain) return group;
    }
    return null;
  }

  _HerdGroup? _groupOf(List<_HerdGroup> groups, String animalId) {
    for (final group in groups) {
      if (group.animalIds.contains(animalId)) return group;
    }
    return null;
  }

  /// Cercles colorés autour des troupeaux et petits groupes.
  List<CircleMarker> _groupCircles(List<_HerdGroup> groups) {
    return groups
        .map(
          (group) => CircleMarker(
            point: group.center,
            radius: group.radiusMeters,
            useRadiusInMeter: true,
            color: group.color.withValues(alpha: 0.10),
            borderColor: group.color,
            borderStrokeWidth: group.isAlert ? 3 : 2.5,
          ),
        )
        .toList();
  }

  /// AJOUT PÂTURAGE : petits points sur chaque sommet de la zone.
  List<CircleMarker> _pastureVertices(List<LatLng> points) {
    return points
        .map(
          (p) => CircleMarker(
            point: p,
            radius: 5,
            color: Colors.white,
            borderColor: _zoneColor,
            borderStrokeWidth: 2.5,
          ),
        )
        .toList();
  }

  /// Traits de mesure reliant chaque groupe secondaire au grand troupeau.
  List<Polyline> _distanceLines(List<_HerdGroup> groups) {
    final main = _mainGroup(groups);
    if (main == null) return const [];
    return groups
        .where((group) => !group.isMain && group.distanceFromMain != null)
        .map(
          (group) => Polyline(
            points: [main.center, group.center],
            color: group.color.withValues(alpha: 0.9),
            strokeWidth: 2.5,
            borderColor: Colors.white,
            borderStrokeWidth: 1.5,
          ),
        )
        .toList();
  }

  LatLng _midpoint(LatLng first, LatLng second) => LatLng(
    (first.latitude + second.latitude) / 2,
    (first.longitude + second.longitude) / 2,
  );

  /// Point le plus au nord du cercle : l'étiquette est posée juste au-dessus.
  LatLng _groupLabelPosition(_HerdGroup group) {
    return const Distance().offset(group.center, group.radiusMeters, 0);
  }

  List<Marker> _groupLabelMarkers(List<_HerdGroup> groups) {
    return groups
        .map(
          (group) => Marker(
            point: _groupLabelPosition(group),
            width: 220,
            height: 54,
            alignment: Alignment.topCenter,
            child: _GroupLabel(
              title: group.label,
              animalCount: group.animalIds.length,
              color: group.color,
              isAlert: group.isAlert,
            ),
          ),
        )
        .toList();
  }

  List<Marker> _distanceLabelMarkers(List<_HerdGroup> groups) {
    final main = _mainGroup(groups);
    if (main == null) return const [];
    return groups
        .where((group) => !group.isMain && group.distanceFromMain != null)
        .map(
          (group) => Marker(
            point: _midpoint(main.center, group.center),
            width: 74,
            height: 26,
            child: _DistanceLabel(
              text: _formatDistance(group.distanceFromMain!),
              color: group.color,
            ),
          ),
        )
        .toList();
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  // ---------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------
  void _showMessage(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? const Color(0xFF9B3030) : _deepGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
  }

  void _focusMap(LatLng point, {double zoom = 17}) {
    _mapController.move(point, zoom);
  }

  void _fitAnimals(Iterable<LatLng> points) {
    final coordinates = points.toList();
    if (coordinates.isEmpty) {
      _showMessage(AppLocalizations.of(context)!.noPositionsAvailable);
      return;
    }
    if (coordinates.length == 1) {
      _focusMap(coordinates.single, zoom: 16);
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: coordinates,
        padding: const EdgeInsets.fromLTRB(50, 170, 50, 150),
        maxZoom: 16,
      ),
    );
  }

  /// AJOUT PÂTURAGE : cadre la caméra sur la zone de pâturage.
  void _fitPasture(List<LatLng> points) {
    if (points.length < 3) {
      _showMessage(AppLocalizations.of(context)!.noPastureRecorded);
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.fromLTRB(50, 170, 50, 150),
        maxZoom: 18,
      ),
    );
  }

  void _zoom(double amount) {
    final camera = _mapController.camera;
    _mapController.move(
      camera.center,
      (camera.zoom + amount).clamp(3.0, 19.0).toDouble(),
    );
  }

  /// Une seule barre de recherche : coordonnées ou identifiant d'animal.
  void _rechercher(String input) {
    final texte = input.trim();
    if (texte.isEmpty) return;
    final estCoordonnee = RegExp(r'^-?\d+(\.\d+)?\s*[,;\s]\s*-?\d+(\.\d+)?$')
        .hasMatch(texte);
    if (estCoordonnee) {
      _searchCoordinates(texte);
    } else {
      _searchAnimal(texte);
    }
  }

  void _searchAnimal(String input) {
    final query = input.trim().toLowerCase();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();

    final positions = _currentPositions();
    String? match;
    for (final id in positions.keys) {
      if (id.toLowerCase().contains(query)) {
        match = id;
        break;
      }
    }
    if (match == null) {
      _showMessage(
        AppLocalizations.of(context)!.noAnimalMatches(input.trim()),
        isError: true,
      );
      return;
    }

    final point = positions[match]!;
    setState(() {
      _selectedAnimalId = match;
      _searchedPoint = null;
    });
    _focusMap(point);
  }

  void _searchCoordinates(String input) {
    final parts = input.trim().split(RegExp(r'[,;\s]+'));
    if (parts.length != 2) {
      _showMessage(
        AppLocalizations.of(context)!.enterCoordinatesFormat,
        isError: true,
      );
      return;
    }

    final latitude = double.tryParse(parts[0]);
    final longitude = double.tryParse(parts[1]);
    if (latitude == null ||
        longitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      _showMessage(
        AppLocalizations.of(context)!.invalidCoordinatesExample,
        isError: true,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    final point = LatLng(latitude, longitude);
    setState(() {
      _searchedPoint = point;
      _selectedAnimalId = null;
    });
    _focusMap(point);
  }

  // ---------------------------------------------------------------------
  // Interface
  // ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        final positions = _currentPositions();
        final alerts = _animalsWithActiveAlerts();
        final colliers = _animalsWithSilentCollar(); // AJOUT
        final groups = _herdGroups();
        final couleurs = _animalColors(groups);
        final savedPasture = _savedPasturePoints();
        final aZone = savedPasture.length >= 3;
        final zoneName = widget.service.nomPature;
        final loc = AppLocalizations.of(context)!;
        final localizedZoneName = _localizedPastureName(zoneName, loc);

        // AJOUT PÂTURAGE : la zone fait partie des points à cadrer.
        final mapPoints = <LatLng>[
          ...positions.values,
          ...groups.map((group) => group.center),
          if (aZone) ...savedPasture,
        ];

        if (!aZone) _zoneCentree = false;
        if (mapPoints.isNotEmpty &&
            (!_hasAutoCentered || (aZone && !_zoneCentree))) {
          _hasAutoCentered = true;
          if (aZone) _zoneCentree = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fitAnimals(mapPoints);
          });
        }

        return Scaffold(
          backgroundColor: _canvas,
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(36.8015, 10.182),
                  initialZoom: 14,
                  onPositionChanged: (camera, hasGesture) {
                    final visibles = camera.zoom >= _zoomNoms;
                    if (visibles != _nomsVisibles && mounted) {
                      setState(() => _nomsVisibles = visibles);
                    }
                  },
                ),
                children: [
                  // Fond OpenStreetMap, éclairci et désaturé pour que les
                  // couleurs des groupes ressortent.
                  // Ajustement : les trois « 22 » éclaircissent le fond
                  // (0 = rendu d'origine, 50 = très clair).
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.traceur_app',
                    tileBuilder: (context, tileWidget, tile) => ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.528,
                        0.429,
                        0.043,
                        0,
                        22,
                        0.128,
                        0.829,
                        0.043,
                        0,
                        22,
                        0.128,
                        0.429,
                        0.443,
                        0,
                        22,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: tileWidget,
                    ),
                  ),
                  // AJOUT PÂTURAGE : zone de pâturage (remplissage + contour).
                  if (aZone)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: savedPasture,
                          color: _zoneColor.withValues(alpha: 0.16),
                          borderColor: _zoneColor,
                          borderStrokeWidth: 4,
                        ),
                      ],
                    ),
                  // AJOUT PÂTURAGE : sommets de la zone.
                  if (aZone)
                    CircleLayer(circles: _pastureVertices(savedPasture)),
                  // Mesures entre le grand troupeau et les autres groupes.
                  PolylineLayer(polylines: _distanceLines(groups)),
                  // Périmètres des groupes.
                  CircleLayer(circles: _groupCircles(groups)),
                  // Animaux, puis distances, puis noms des groupes (au-dessus).
                  MarkerLayer(
                    markers: [
                      // AJOUT PÂTURAGE : nom de la zone au centre.
                      if (aZone)
                        Marker(
                          point: _pastureCenter(savedPasture),
                          width: 200,
                          height: 30,
                          child: _ZoneLabel(
                            text:
                                '$localizedZoneName'
                                '${widget.service.modePature == 'auto' ? ' · ${loc.automaticModeLabel}' : ''}',
                          ),
                        ),
                      for (final entry in positions.entries)
                        Marker(
                          point: entry.value,
                          width: 90,
                          height: 34,
                          child: _AnimalMarker(
                            id: entry.key,
                            color: alerts.contains(entry.key)
                                ? _red
                                : (couleurs[entry.key] ?? _green),
                            hasAlert: alerts.contains(entry.key),
                            silentCollar: colliers.contains(entry.key),
                            isSelected: _selectedAnimalId == entry.key,
                            showName: _nomsVisibles,
                            onTap: () =>
                                setState(() => _selectedAnimalId = entry.key),
                          ),
                        ),
                      if (_searchedPoint != null)
                        Marker(
                          point: _searchedPoint!,
                          width: 48,
                          height: 54,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: _blue,
                            size: 46,
                            shadows: [
                              Shadow(color: Colors.white, blurRadius: 8),
                            ],
                          ),
                        ),
                      ..._distanceLabelMarkers(groups),
                      ..._groupLabelMarkers(groups),
                    ],
                  ),
                ],
              ),
              // Panneau du haut (compact, aligné à gauche).
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      heightFactor: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: _buildTopPanel(
                          animalCount: positions.length,
                          groupCount: groups.length,
                          alertCount: alerts.length,
                          connected: widget.service.connecte,
                          hasZone: aZone,
                          zoneName: zoneName,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: _selectedAnimalId != null ? 118 : 28,
                child: _buildMapControls(mapPoints, savedPasture),
              ),
              if (_selectedAnimalId == null && positions.isNotEmpty)
                Positioned(
                  left: 16,
                  bottom: 28,
                  child: _Legend(
                    groups: groups,
                    hasAlerts: alerts.isNotEmpty,
                    hasSilentCollar: colliers.isNotEmpty,
                    hasZone: aZone,
                  ),
                ),
              if (_selectedAnimalId != null)
                Positioned(
                  left: 16,
                  right: 78,
                  bottom: 24,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _buildSelectedAnimalCard(
                        animalId: _selectedAnimalId!,
                        point: positions[_selectedAnimalId!],
                        hasAlert: alerts.contains(_selectedAnimalId),
                        silentCollar: colliers.contains(_selectedAnimalId),
                        group: _groupOf(groups, _selectedAnimalId!),
                      ),
                    ),
                  ),
                ),
              if (positions.isEmpty)
                Positioned(
                  left: 16,
                  right: 78,
                  bottom: 28,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: _buildEmptyPositionsNotice(
                        widget.service.connecte,
                      ),
                    ),
                  ),
                ),
              // Attribution du fond de carte.
              Positioned(
                right: 8,
                bottom: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.openStreetMapAttribution,
                    style: const TextStyle(
                      color: Color(0xFF5E6B63),
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _localizedPastureName(String? name, AppLocalizations loc) {
    final trimmedName = name?.trim();
    if (trimmedName == null || trimmedName.isEmpty) return loc.pastureName;
    switch (trimmedName.toLowerCase()) {
      case 'pâturage':
        return loc.pastureName;
      case 'pâturage principal':
        return loc.mainPastureName;
      default:
        return trimmedName;
    }
  }

  Widget _buildTopPanel({
    required int animalCount,
    required int groupCount,
    required int alertCount,
    required bool connected,
    required bool hasZone,
    required String? zoneName,
  }) {
    final loc = AppLocalizations.of(context)!;
    final animaux = loc.countAnimals(animalCount);
    final groupes = loc.groupCount(groupCount);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5ECE6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A183A2C),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.terrain_rounded,
                  color: _green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.appTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _deepGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF738078),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(text: '$animaux · $groupes'),
                          if (alertCount > 0)
                            TextSpan(
                              text: ' · ${loc.countAlerts(alertCount)}',
                              style: const TextStyle(
                                color: _red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: loc.settingsLanguageSection,
                onPressed: () {
                  final next =
                      Localizations.localeOf(context).languageCode == 'fr'
                      ? 'ar'
                      : 'fr';
                  appLocaleController.changer(next);
                },
                icon: const Icon(Icons.translate_rounded, size: 20),
              ),
              const SizedBox(width: 4),
              _ConnectionBadge(connected: connected),
            ],
          ),
          const SizedBox(height: 12),
          _SearchField(
            controller: _searchController,
            hint: loc.searchAnimalsAndCoordinates,
            icon: Icons.search_rounded,
            accent: _green,
            onSubmitted: _rechercher,
            onClear: () => setState(() {
              _selectedAnimalId = null;
              _searchedPoint = null;
            }),
          ),
          if (hasZone) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.map_outlined, color: _zoneColor, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    loc.zoneLabel(zoneName ?? loc.unknownZone),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _zoneColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapControls(Iterable<LatLng> points, List<LatLng> pasture) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        _MapControlButton(
          icon: Icons.add_rounded,
          tooltip: loc.zoomIn,
          onPressed: () => _zoom(1),
        ),
        const SizedBox(height: 8),
        _MapControlButton(
          icon: Icons.remove_rounded,
          tooltip: loc.zoomOut,
          onPressed: () => _zoom(-1),
        ),
        // AJOUT PÂTURAGE : bouton « centrer sur la zone ».
        if (pasture.length >= 3) ...[
          const SizedBox(height: 8),
          _MapControlButton(
            icon: Icons.crop_free_rounded,
            tooltip: loc.centerPasture,
            onPressed: () => _fitPasture(pasture),
          ),
        ],
        const SizedBox(height: 8),
        _MapControlButton(
          icon: Icons.gps_fixed_rounded,
          tooltip: loc.centerAnimals,
          onPressed: () => _fitAnimals(points),
          accent: true,
        ),
      ],
    );
  }

  Widget _buildSelectedAnimalCard({
    required String animalId,
    required LatLng? point,
    required bool hasAlert,
    required bool silentCollar,
    required _HerdGroup? group,
  }) {
    if (point == null) return const SizedBox.shrink();
    final loc = AppLocalizations.of(context)!;
    final statut = silentCollar
        ? loc.collarNoSignal
        : (hasAlert
              ? loc.alertActive
              : (group != null ? group.label : loc.positionLive));

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5ECE6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A183A2C),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasAlert
                  ? const Color(0xFFFFEEEE)
                  : const Color(0xFFE8F4EC),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              silentCollar
                  ? Icons.sensors_off_rounded
                  : (hasAlert
                        ? Icons.warning_amber_rounded
                        : Icons.pets_rounded),
              color: hasAlert ? _red : _green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animalId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _deepGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statut,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasAlert ? _red : (group?.color ?? _green),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF758178),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: loc.close,
            onPressed: () => setState(() => _selectedAnimalId = null),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF89948C),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPositionsNotice(bool connected) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5ECE6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x17183A2C),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            connected ? Icons.sensors_rounded : Icons.wifi_off_rounded,
            color: connected ? _green : const Color(0xFFB77832),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              connected
                  ? loc.waitingForFirstPositions
                  : loc.trackingConnectionInterrupted,
              style: const TextStyle(
                color: _deepGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------------
// Widgets
// -------------------------------------------------------------------------
class _HerdGroup {
  const _HerdGroup({
    required this.label,
    required this.color,
    required this.center,
    required this.radiusMeters,
    required this.animalIds,
    required this.isMain,
    required this.isAlert,
    this.distanceFromMain,
  });

  final String label;
  final Color color;
  final LatLng center;
  final double radiusMeters;
  final List<String> animalIds;
  final bool isMain;
  final bool isAlert;
  final double? distanceFromMain;

  _HerdGroup withDistance(double distance) => _HerdGroup(
    label: label,
    color: color,
    center: center,
    radiusMeters: radiusMeters,
    animalIds: animalIds,
    isMain: isMain,
    isAlert: isAlert,
    distanceFromMain: distance,
  );
}

/// AJOUT PÂTURAGE : étiquette du nom de la zone, posée au centre du polygone.
class _ZoneLabel extends StatelessWidget {
  const _ZoneLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _CartePageState._zoneColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fence_rounded, color: Colors.white, size: 13),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Étiquette d'un groupe : une seule ligne (nom + nombre de vaches), posée
/// au-dessus du cercle. Le vide en dessous garde un petit écart avec les
/// animaux pour ne pas les recouvrir.
class _GroupLabel extends StatelessWidget {
  const _GroupLabel({
    required this.title,
    required this.animalCount,
    required this.color,
    required this.isAlert,
  });

  final String title;
  final int animalCount;
  final Color color;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 214),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAlert) ...[
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (animalCount > 0) ...[
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.animalsInGroup(animalCount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}

class _DistanceLabel extends StatelessWidget {
  const _DistanceLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2A000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          maxLines: 1,
          style: const TextStyle(
            color: _CartePageState._deepGreen,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.groups,
    required this.hasAlerts,
    required this.hasSilentCollar,
    required this.hasZone,
  });

  final List<_HerdGroup> groups;
  final bool hasAlerts;
  final bool hasSilentCollar; // AJOUT
  final bool hasZone; // AJOUT PÂTURAGE

  Widget _line(Color color, String text, {String? count}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _CartePageState._deepGreen,
            ),
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF758178),
            ),
          ),
        ],
      ],
    ),
  );

  /// AJOUT : ligne de légende pour les colliers sans signal.
  Widget _collarLine(String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        const Icon(
          Icons.sensors_off_rounded,
          color: _CartePageState._red,
          size: 13,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _CartePageState._deepGreen,
            ),
          ),
        ),
      ],
    ),
  );

  /// AJOUT PÂTURAGE : pastille carrée pour la zone (forme polygone).
  Widget _zoneLine(String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: _CartePageState._zoneColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: _CartePageState._zoneColor, width: 2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _CartePageState._deepGreen,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5ECE6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A183A2C),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  loc.detectedGroups,
                  style: const TextStyle(
                    color: Color(0xFF758178),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (groups.isEmpty)
                _line(_CartePageState._green, loc.liveTrackedAnimals)
              else
                for (final group in groups)
                  _line(
                    group.color,
                    group.isAlert
                        ? '${group.label} · ${loc.alertSuffix}'
                        : group.label,
                    count: group.animalIds.isEmpty
                        ? null
                        : '${group.animalIds.length}',
                  ),
              if (hasAlerts) _line(_CartePageState._red, loc.animalInAlert),
              if (hasSilentCollar) _collarLine(loc.collarNoSignal),
              if (hasZone) _zoneLine(loc.pastureZone),
              if (groups.any((group) => group.distanceFromMain != null))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.swap_horiz_rounded,
                        color: Color(0xFF66736A),
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          loc.distanceToMainHerd,
                          style: const TextStyle(
                            color: Color(0xFF66736A),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pastille d'un animal, centrée exactement sur sa position GPS.
/// Le nom n'est affiché qu'en zoomant ou quand l'animal est sélectionné.
class _AnimalMarker extends StatelessWidget {
  const _AnimalMarker({
    required this.id,
    required this.color,
    required this.hasAlert,
    required this.silentCollar,
    required this.isSelected,
    required this.showName,
    required this.onTap,
  });

  final String id;
  final Color color;
  final bool hasAlert;
  final bool silentCollar; // AJOUT : collier sans signal
  final bool isSelected;
  final bool showName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final taille = isSelected ? 34.0 : 28.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: taille,
            height: taille,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: isSelected ? 12 : 6,
                  spreadRadius: isSelected ? 2 : 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              silentCollar
                  ? Icons.sensors_off_rounded
                  : (hasAlert
                        ? Icons.priority_high_rounded
                        : Icons.pets_rounded),
              color: Colors.white,
              size: isSelected ? 18 : 15,
            ),
          ),
        ),
        if (showName || isSelected)
          Positioned(
            top: 38,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 84),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFFE5ECE6),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x17183A2C),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasAlert
                        ? const Color(0xFFB34444)
                        : _CartePageState._deepGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final color = connected ? const Color(0xFF218455) : const Color(0xFFB77832);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            connected
                ? AppLocalizations.of(context)!.onlineStatus
                : AppLocalizations.of(context)!.offlineStatus,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.accent,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color accent;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 12, right: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EEE9)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                color: _CartePageState._deepGreen,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: accent,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF929C94),
                  fontSize: 12,
                ),
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox(width: 3);
              return IconButton(
                tooltip: 'Effacer',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  controller.clear();
                  onClear();
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF89948C),
                  size: 17,
                ),
              );
            },
          ),
          const SizedBox(width: 2),
          Material(
            color: accent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSubmitted(controller.text),
              child: const SizedBox(
                width: 33,
                height: 33,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.accent = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent ? _CartePageState._green : Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 3,
      shadowColor: const Color(0x26183A2C),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: accent ? Colors.white : _CartePageState._deepGreen,
          size: 20,
        ),
        style: IconButton.styleFrom(
          minimumSize: const Size(46, 46),
          maximumSize: const Size(46, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
