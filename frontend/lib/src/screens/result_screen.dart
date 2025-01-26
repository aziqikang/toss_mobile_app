// lib/src/screens/result_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultScreen({Key? key, required this.resultData}) : super(key: key);

  // Helper function to safely launch URLs
  void launchUrlHelper(Uri url) async {
    if (!await canLaunchUrl(url)) {
      throw Exception('Could not launch $url');
    } else {
      await launchUrl(url); // Open the URL
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = resultData['location'] ?? 'Unknown location';
    final classifications = resultData['classifications'] as List<dynamic>? ?? [];
    final rawLabels = resultData['raw_labels'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Screen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: $location', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Text('Classifications:', style: Theme.of(context).textTheme.titleLarge),
            ...classifications.map((classification) {
              return ListTile(
                title: Text(classification['subcategory'] ?? 'Unknown'),
                subtitle: Text(classification['disposal_instruction'] ?? 'No instructions available'),
                trailing: classification['url'] != null
                    ? TextButton(
                        onPressed: () {
                          final url = Uri.parse(classification['url']);
                          launchUrlHelper(url); // Use the helper function to open the link
                        },
                        child: const Text('Learn More'),
                      )
                    : null,
              );
            }).toList(),
            const SizedBox(height: 20),
            Text('Raw Labels:', style: Theme.of(context).textTheme.titleLarge),
            ...rawLabels.map((label) => Text('- $label')).toList(),
          ],
        ),
      ),
    );
  }
}
