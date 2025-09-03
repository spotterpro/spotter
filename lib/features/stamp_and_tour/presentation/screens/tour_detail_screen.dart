import 'package:flutter/material.dart';

class TourDetailScreen extends StatelessWidget {
  final Map<String, dynamic> tourData;
  const TourDetailScreen({super.key, required this.tourData});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stamps = (tourData['stamps'] as List).cast<Map<String, dynamic>>();

    return Scaffold(
      appBar: AppBar(
        title: Text(tourData['title'] as String),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tourData['title'] as String,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              tourData['description'] as String,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stamps.length,
              itemBuilder: (context, index) {
                final stamp = stamps[index];
                final isCompleted = stamp['completed'] as bool;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: isCompleted ? Colors.orange[400] : Theme.of(context).dividerColor,
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 30)
                            : Text('${index + 1}', style: TextStyle(color: Colors.grey[600], fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCompleted ? '(완료) ${stamp['name'] as String}' : stamp['name'] as String,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                color: isCompleted ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color
                            ),
                          ),
                          if (isCompleted)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '수집일: ${stamp['date'] as String}',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tourData['reward'] as String,
                    style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}