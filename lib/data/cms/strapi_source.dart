import 'package:http/http.dart' as http;

import '../../models/fair_event.dart';
import '../event_source.dart';

/// Strapi 5 (headless CMS), REST API.
class StrapiEventSource implements EventSource {
  StrapiEventSource(this.client, {required this.baseUrl, this.token = ''});

  final http.Client client;
  final String baseUrl;
  final String token;

  @override
  String get name => 'Strapi';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    final uri = Uri.parse('$baseUrl/api/fair-events').replace(
      queryParameters: {
        'sort': 'startsAt:asc',
        'pagination[pageSize]': '100',
      },
    );
    final headers = <String, String>{};
    if (token.isNotEmpty) {
      headers['Authorization'] = token;
    }
    final json = await getJson(client, uri, cms: name, headers: headers);
    final items = (json as Map<String, dynamic>)['data'] as List<dynamic>;

    return [
      for (final item in items.cast<Map<String, dynamic>>())
        FairEvent(
          id: item['documentId'] as String? ?? '',
          orgId: item['orgId'] as String? ?? '',
          title: item['title'] as String? ?? '',
          startsAt: DateTime.parse(item['startsAt'] as String),
          venue: item['venue'] as String? ?? '',
          description: item['description'] as String? ?? '',
          cancelled: item['cancelled'] as bool? ?? false,
        ),
    ];
  }
}
