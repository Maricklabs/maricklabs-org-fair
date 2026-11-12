import 'package:http/http.dart' as http;

import '../../models/fair_event.dart';
import '../event_source.dart';

/// Sanity (hosted headless CMS), HTTP Query API with GROQ.
class SanityEventSource implements EventSource {
  SanityEventSource(
    this.client, {
    required this.projectId,
    this.dataset = 'production',
    this.token = '',
  });

  final http.Client client;
  final String projectId;
  final String dataset;
  final String token;

  static const query =
      '*[_type == "fairEvent"] | order(startsAt asc) '
      '{_id, title, orgId, startsAt, venue, description, cancelled}';

  @override
  String get name => 'Sanity';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    final uri = Uri.https(
      '$projectId.apicdn.sanity.io',
      '/v2025-02-19/data/query/$dataset',
      {'query': query},
    );
    final headers = <String, String>{};
    if (token.isNotEmpty) {
      headers['Authorization'] = token;
    }
    final json = await getJson(client, uri, cms: name, headers: headers);
    final items = (json as Map<String, dynamic>)['result'] as List<dynamic>;

    return [
      for (final item in items.cast<Map<String, dynamic>>())
        FairEvent(
          id: item['_id'] as String? ?? '',
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
