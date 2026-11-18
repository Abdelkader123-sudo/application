import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ContactMessagerie {
  const ContactMessagerie({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.role,
  });

  final String id;
  final String nom;
  final String prenom;
  final String role;

  String get nomComplet => prenom.isEmpty ? nom : '$prenom $nom';

  factory ContactMessagerie.fromJson(Map<String, dynamic> json) =>
      ContactMessagerie(
        id: '${json['id'] ?? ''}',
        nom: '${json['nom'] ?? ''}',
        prenom: '${json['prenom'] ?? ''}',
        role: '${json['role'] ?? 'utilisateur'}',
      );
}

class ConversationMessagerie {
  const ConversationMessagerie({
    required this.id,
    required this.type,
    required this.titre,
    required this.membres,
    required this.dernierMessage,
  });

  final String id;
  final String type;
  final String titre;
  final List<ContactMessagerie> membres;
  final MessageMessagerie? dernierMessage;

  bool get estGroupe => type == 'groupe';

  factory ConversationMessagerie.fromJson(Map<String, dynamic> json) {
    final membresJson = json['membres'] as List<dynamic>? ?? const [];
    final dernierJson = json['dernier_message'];
    return ConversationMessagerie(
      id: '${json['id'] ?? ''}',
      type: '${json['type'] ?? 'direct'}',
      titre: '${json['titre'] ?? ''}',
      membres: membresJson
          .whereType<Map>()
          .map((membre) => ContactMessagerie.fromJson(
                Map<String, dynamic>.from(membre),
              ))
          .toList(),
      dernierMessage: dernierJson is Map
          ? MessageMessagerie.fromJson(
              Map<String, dynamic>.from(dernierJson),
            )
          : null,
    );
  }
}

class MessageMessagerie {
  const MessageMessagerie({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.texte,
    required this.creeLe,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String texte;
  final DateTime creeLe;

  factory MessageMessagerie.fromJson(Map<String, dynamic> json) =>
      MessageMessagerie(
        id: '${json['id'] ?? ''}',
        conversationId: '${json['conversation_id'] ?? ''}',
        senderId: '${json['sender_id'] ?? ''}',
        texte: '${json['texte'] ?? ''}',
        creeLe: _dateTime(json['cree_le']),
      );

  static DateTime _dateTime(dynamic valeur) {
    final date = valeur is String ? DateTime.tryParse(valeur) : null;
    if (date == null) {
      throw const FormatException('Date de message invalide.');
    }
    return date.toLocal();
  }
}

class MessagerieService {
  MessagerieService({AuthService? authService})
      : _authService = authService ?? AuthService.instance;

  final AuthService _authService;

  Future<List<ContactMessagerie>> listerContacts() async {
    final resultat = await _get('/messagerie/utilisateurs');
    return (resultat as List<dynamic>)
        .whereType<Map>()
        .map((json) => ContactMessagerie.fromJson(
              Map<String, dynamic>.from(json),
            ))
        .toList();
  }

  Future<List<ConversationMessagerie>> listerConversations() async {
    final resultat = await _get('/messagerie/conversations');
    return (resultat as List<dynamic>)
        .whereType<Map>()
        .map((json) => ConversationMessagerie.fromJson(
              Map<String, dynamic>.from(json),
            ))
        .toList();
  }

  Future<ConversationMessagerie> ouvrirConversation(String destinataireId) =>
      _postConversation(
        '/messagerie/conversations/direct',
        {'destinataire_id': destinataireId},
      );

  Future<ConversationMessagerie> creerGroupe({
    required String titre,
    required List<String> membres,
  }) =>
      _postConversation(
        '/messagerie/conversations/groupe',
        {'titre': titre, 'membres': membres},
      );

  Future<List<MessageMessagerie>> listerMessages(String conversationId) async {
    final resultat = await _get(
      '/messagerie/conversations/$conversationId/messages?limite=200',
    );
    return (resultat as List<dynamic>)
        .whereType<Map>()
        .map((json) => MessageMessagerie.fromJson(
              Map<String, dynamic>.from(json),
            ))
        .toList();
  }

  Future<MessageMessagerie> envoyerMessage(
    String conversationId,
    String texte,
  ) async {
    final resultat = await _post(
      '/messagerie/conversations/$conversationId/messages',
      {'texte': texte},
    );
    return MessageMessagerie.fromJson(
      Map<String, dynamic>.from(resultat as Map),
    );
  }

  Future<ConversationMessagerie> ajouterMembres(
    String conversationId,
    List<String> membres,
  ) async {
    final resultat = await _post(
      '/messagerie/conversations/$conversationId/membres',
      {'membres': membres},
    );
    return ConversationMessagerie.fromJson(
      Map<String, dynamic>.from(resultat as Map),
    );
  }

  Future<ConversationMessagerie> _postConversation(
    String path,
    Map<String, Object> body,
  ) async {
    final resultat = await _post(path, body);
    return ConversationMessagerie.fromJson(
      Map<String, dynamic>.from(resultat as Map),
    );
  }

  Future<dynamic> _get(String path) => _authService.requeteApi(
        () => http.get(
          _authService.uriApi(path),
          headers: _authService.entetesAutorisation,
        ),
      );

  Future<dynamic> _post(String path, Map<String, Object> body) =>
      _authService.requeteApi(
        () => http.post(
          _authService.uriApi(path),
          headers: _authService.entetesAutorisation,
          body: jsonEncode(body),
        ),
      );
}
