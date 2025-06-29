import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SubmitTopicScreen extends StatefulWidget {
  final String token;
  const SubmitTopicScreen({super.key, required this.token});

  @override
  State<SubmitTopicScreen> createState() => _SubmitTopicScreenState();
}

class _SubmitTopicScreenState extends State<SubmitTopicScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String message = '';
  bool isSubmitting = false;

  Future<void> _submitTopic() async {
    setState(() {
      isSubmitting = true;
      message = '';
    });

    try {
      await ApiService.submitProjectTopic(
        widget.token,
        _titleController.text,
        _descController.text,
      );
      setState(() {
        message = 'Topic submitted successfully!';
      });
    } catch (e) {
      setState(() {
        message = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Project Topic")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Project Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitTopic,
                    child: const Text("Submit Topic"),
                  ),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  message,
                  style: TextStyle(
                    color: message.contains('success') ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
