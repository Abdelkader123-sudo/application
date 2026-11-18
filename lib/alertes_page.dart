import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:traceur_app/l10n/app_localizations.dart';
import 'package:traceur_app/services/historique_activite_page_integrated.dart';

import 'fond_page.dart';
import 'ws_service.dart';

/// Apparence propre à chaque type d'alerte (couleur, icône, étiquette).
class _AlertStyle {
  const _AlertStyle({
    required this.color,
    required this.background,
    required this.icon,
    required this.badge,
    this.isInfo = false,
  });

  final Color color; // couleur principale (icône, bandeau, badge)
  final Color background; // fond clair de la pastille d'icône
  final IconData icon;
  final String badge; // texte du badge (« Active » ou « Information »)
  final bool isInfo; // true : simple information, pas une vraie alerte
}

class AlertesPage extends StatelessWidget {
  const AlertesPage({
    super.key,
    required this.service,
  });

  final WsService service;

  static const Color _ink = Color(0xFF193C2D);
  static const Color _muted = Color(0xFF758178);

  /// Largeur maximale du contenu (utile sur grand écran / web).
  static const double _maxContentWidth = 720;

  /// Un style spécial par type d'alerte.
  /// - sortie_zone : bleu, classée sous « Information »
  static const Map<String, _AlertStyle> _typeStyles = {
    'sortie_zone': _AlertStyle(
      color: Color(0xFF2876D2),
      background: Color(0xFFE6F0FC),
      icon: Icons.social_distance_rounded,
      badge: 'Information',
      isInfo: true,
    ),
    'hors_pature': _AlertStyle(
      color: Color(0xFFD34444),
      background: Color(0xFFFFEEEE),
      icon: Icons.crop_free_rounded,
      badge: 'Active',
    ),
    'immobilite': _AlertStyle(
      color: Color(0xFF9655D8),
      background: Color(0xFFF2E9FB),
      icon: Icons.hotel_rounded,
      badge: 'Active',
    ),
    'deplacement_inhabituel': _AlertStyle(
      color: Color(0xFFE08A1E),
      background: Color(0xFFFFF3E0),
      icon: Icons.speed_rounded,
      badge: 'Active',
    ),
    'collier_silencieux': _AlertStyle(
      color: Color(0xFF546E7A),
      background: Color(0xFFECEFF1),
      icon: Icons.sensors_off_rounded,
      badge: 'Active',
    ),
    'comportement_inhabituel': _AlertStyle(
      color: Color(0xFFE34B8C),
      background: Color(0xFFFCE9F2),
      icon: Icons.psychology_alt_rounded,
      badge: 'Active',
    ),
  };

  /// Style par défaut pour un type inconnu.
  static const _AlertStyle _defaultStyle = _AlertStyle(
    color: Color(0xFFD34444),
    background: Color(0xFFFFEEEE),
    icon: Icons.warning_amber_rounded,
    badge: 'Active',
  );

  _AlertStyle _styleFor(String type) => _typeStyles[type] ?? _defaultStyle;

  bool _isResolved(dynamic alert) {
    return alert is Map && alert['resolue'] == true;
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final pi = polygon[i];
      final pj = polygon[j];

      final intersects = ((pi.longitude > point.longitude) !=
              (pj.longitude > point.longitude)) &&
          (point.latitude <
              (pj.latitude - pi.latitude) *
                      (point.longitude - pi.longitude) /
                      (pj.longitude - pi.longitude) +
                  pi.latitude);

      if (intersects) {
        inside = !inside;
      }
    }

    return inside;
  }

  List<Map<String, dynamic>> _fallbackHorsPatureAlerts() {
    final pasture = service.pature;
    if (pasture == null || pasture.length < 3) return const [];

    final polygon = <LatLng>[];
    for (final point in pasture) {
      final latitude = point['latitude'] ?? point['lat'];
      final longitude = point['longitude'] ?? point['lon'] ?? point['lng'];
      if (latitude is num && longitude is num) {
        polygon.add(LatLng(latitude.toDouble(), longitude.toDouble()));
      }
    }
    if (polygon.length < 3) return const [];

    final activeAnimalIds = service.alertes
        .where((alert) =>
            alert['resolue'] != true &&
            alert['type'] == 'hors_pature' &&
            alert['animal_id'] != null)
        .map((alert) => alert['animal_id'].toString())
        .toSet();

    final alerts = <Map<String, dynamic>>[];
    for (final entry in service.positions.entries) {
      final animalId = entry.key.toString();
      if (activeAnimalIds.contains(animalId)) continue;

      final raw = entry.value;
      final latitude = raw['latitude'] ?? raw['lat'];
      final longitude = raw['longitude'] ?? raw['lon'] ?? raw['lng'];
      if (latitude is! num || longitude is! num) continue;

      final point = LatLng(latitude.toDouble(), longitude.toDouble());
      if (_isPointInPolygon(point, polygon)) continue;

      alerts.add({
        'animal_id': animalId,
        'type': 'hors_pature',
        'message': 'Cet animal est hors de la zone de pâturage.',
        'timestamp': raw['timestamp'] ??
            raw['last_seen'] ??
            DateTime.now().toUtc().toIso8601String(),
        'resolue': false,
      });
    }

    return alerts;
  }

  String _readText(
    dynamic alert,
    String key, {
    required String fallback,
  }) {
    if (alert is! Map) return fallback;

    final value = alert[key];
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  String _labelForType(String type, AppLocalizations loc) {
    switch (type) {
      case 'sortie_zone':
        return loc.alertTypeOutOfZone;
      case 'hors_pature':
        return loc.alertTypeOutsidePasture;
      case 'immobilite':
        return loc.alertTypeInactive;
      case 'deplacement_inhabituel':
        return loc.alertTypeUnusualMovement;
      case 'collier_silencieux':
        return loc.alertTypeCollarSilent;
      case 'comportement_inhabituel':
        return loc.alertTypeUnusualBehavior;
      default:
        if (type.trim().isEmpty) return loc.unknownAlert;
        final formatted = type.replaceAll('_', ' ').trim();
        return '${formatted[0].toUpperCase()}${formatted.substring(1)}';
    }
  }

  String _formatDate(dynamic rawDate, AppLocalizations loc) {
    if (rawDate == null) return loc.dateUnavailable;

    final original = rawDate.toString();
    final date = DateTime.tryParse(original)?.toLocal();
    if (date == null) return original;

    const months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${date.day} ${months[date.month - 1]} ${date.year} · '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  /// Transforme le message technique du serveur en phrase simple.
  /// Si une regex ne trouve rien, la phrase reste correcte, sans le chiffre.
  String _friendlyMessage(String type, dynamic alert, AppLocalizations loc) {
    final raw = _readText(alert, 'message', fallback: '');

    String? find(String pattern) =>
        RegExp(pattern).firstMatch(raw)?.group(1);

    switch (type) {
      case 'sortie_zone':
        final distance = find(r'(\d+)\s*m du grand troupeau');
        final n = int.tryParse(find(r'hors zone\s*:\s*(\d+)') ?? '');

        final buffer = StringBuffer(loc.animalLeftHerd);
        if (distance != null) buffer.write(' (environ $distance m)');
        buffer.write('.');

        if (n != null) {
          buffer.write(
            n > 1
                ? ' $n ${loc.animalsSeparatedFromGroup}.'
                : ' $n ${loc.animalSeparatedFromGroup}.',
          );
        }
        return buffer.toString();

      case 'hors_pature':
        final zone = find(r'«\s*(.+?)\s*»');
        final distance = find(r'à\s*(\d+)\s*m du bord');
        final distancePhrase = distance != null
            ? ' ${loc.animalAtDistanceFromLimit(int.parse(distance))}'
            : '';
        return '${loc.animalOutsidePasture}'
            '${zone != null ? ' « $zone »' : ''}.'
            '$distancePhrase';

      case 'immobilite':
        return loc.animalInactive;

      case 'deplacement_inhabituel':
        return loc.abnormalMovement;

      case 'collier_silencieux':
        return loc.collarSilent;

      case 'comportement_inhabituel':
        return loc.abnormalBehavior;

      default:
        return raw.isEmpty ? loc.noDetailProvided : raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        // Sécurité : on n'affiche jamais une alerte résolue.
        // Fallback local : on complète aussi les animaux visibles hors de la
        // zone de pâturage quand le backend ne renvoie pas d'alerte active.
        final toutes = <Map<String, dynamic>>[
          ...service.alertes.where((a) => !_isResolved(a)),
          ..._fallbackHorsPatureAlerts(),
        ];
        final connected = service.connecte;

        String typeOf(dynamic a) => _readText(a, 'type', fallback: 'alerte');

        final alertes =
            toutes.where((a) => !_styleFor(typeOf(a)).isInfo).toList();
        final infos =
            toutes.where((a) => _styleFor(typeOf(a)).isInfo).toList();

        final items = <Object>[
          if (alertes.isNotEmpty && infos.isNotEmpty) loc.alertSection,
          ...alertes,
          if (infos.isNotEmpty) loc.infoSection,
          ...infos,
        ];

        return FondPage(
          image: 'assets/images/Alerte.jpg',
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: _ink,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleSpacing: 20,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.alertsTitle,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    loc.alertsMonitoring,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: _ConnectionBadge(connected: connected),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: _maxContentWidth),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                        child: _SummaryCard(
                          activeCount: alertes.length,
                          infoCount: infos.length,
                          connected: connected,
                        ),
                      ),
                      Expanded(
                        child: items.isEmpty
                            ? _EmptyState(connected: connected)
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                itemCount: items.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = items[index];

                                  // En-tête de section
                                  if (item is String) {
                                    return _SectionHeader(
                                      title: item,
                                      isInfo: item == loc.infoSection,
                                    );
                                  }

                                  final alert = item as Map;
                                  final type = typeOf(alert);
                                  final style = _styleFor(type);
                                  final animalId = _readText(
                                    alert,
                                    'animal_id',
                                    fallback: loc.animalNotIdentified,
                                  );
                                  // Seule l'alerte « comportement_inhabituel »
                                  // ouvre l'historique ; les autres types
                                  // restent inchangés.
                                  final ouvreHistorique =
                                      type == 'comportement_inhabituel' &&
                                          alert['animal_id'] != null;

                                  return _AlertCard(
                                    animalId: animalId,
                                    title: _labelForType(type, loc),
                                    message: _friendlyMessage(type, alert, loc),
                                    startedAt: _formatDate(
                                      alert['timestamp'],
                                      loc,
                                    ),
                                    style: style,
                                    onTap: ouvreHistorique
                                        ? () => Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    HistoriqueActivitePage(
                                                  animalId: animalId,
                                                ),
                                              ),
                                            )
                                        : null,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.isInfo,
  });

  final String title;
  final bool isInfo;

  @override
  Widget build(BuildContext context) {
    final color = isInfo ? const Color(0xFF2876D2) : const Color(0xFFB34444);

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Row(
        children: [
          Icon(
            isInfo ? Icons.info_outline_rounded : Icons.notifications_rounded,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.activeCount,
    required this.infoCount,
    required this.connected,
  });

  final int activeCount;
  final int infoCount;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isCalm = activeCount == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF174C38), Color(0xFF21845B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123D2E).withValues(alpha: 0.17),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isCalm ? loc.noAlertsActive : loc.alertsToHandle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  isCalm
                      ? Icons.verified_rounded
                      : Icons.notifications_active_rounded,
                  color: isCalm
                      ? const Color(0xFFBCECCF)
                      : const Color(0xFFFFD0C9),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            connected
                ? loc.alertsToHandleMessage
                : '${loc.connectionInterrupted} · ${loc.alertsToHandleMessage}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.priority_high_rounded,
                color: isCalm
                    ? const Color(0xFFBCECCF)
                    : const Color(0xFFFFD0C9),
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                '$activeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                activeCount > 1 ? loc.alertsTitle : loc.alertActive,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (infoCount > 0) ...[
                const Spacer(),
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFBFD9F7),
                  size: 17,
                ),
                const SizedBox(width: 6),
                Text(
                  '$infoCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  infoCount > 1 ? loc.infoSection : loc.information,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({
    required this.connected,
  });

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final color =
        connected ? const Color(0xFF218455) : const Color(0xFFB77832);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
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
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.animalId,
    required this.title,
    required this.message,
    required this.startedAt,
    required this.style,
    this.onTap,
  });

  final String animalId;
  final String title;
  final String message;
  final String startedAt;
  final _AlertStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.color.withValues(alpha: 0.22)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D183A2C),
            blurRadius: 13,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bandeau coloré propre au type d'alerte
                  Container(width: 5, color: style.color),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: style.background,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(style.icon,
                                color: style.color, size: 21),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        animalId,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF526157),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _TypeBadge(style: style),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: style.color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  message,
                                  style: const TextStyle(
                                    color: Color(0xFF68756C),
                                    fontSize: 12,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 11),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule_rounded,
                                      size: 13,
                                      color: Color(0xFF89948C),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      loc.startedAt,
                                      style: const TextStyle(
                                        color: Color(0xFF89948C),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        startedAt,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF758178),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (onTap != null) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.show_chart_rounded,
                                        size: 14,
                                        color: style.color,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        loc.viewActivityHistory,
                                        style: TextStyle(
                                          color: style.color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge du type : « Active » (rouge, orange…) ou « Information » (bleu).
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.style});

  final _AlertStyle style;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final label = style.isInfo ? loc.information : loc.active;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style.isInfo ? Icons.info_outline_rounded : Icons.circle,
            size: style.isInfo ? 10 : 6,
            color: style.color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: style.color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.connected,
  });

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final icon = connected ? Icons.verified_rounded : Icons.cloud_off_rounded;
    final iconColor =
        connected ? const Color(0xFF23845B) : const Color(0xFFB77832);
    final iconBackground =
        connected ? const Color(0xFFE8F4EC) : const Color(0xFFFFF3E4);
    final title = connected ? loc.noAlertsActive : loc.connectionInterrupted;
    final message = connected
        ? loc.noAlertsMessage
        : loc.connectionInterruptedMessage;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF193C2D),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 310),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF758178),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}