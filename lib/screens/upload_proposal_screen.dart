import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class UploadProposalScreen extends StatefulWidget {
  final String token;
  final int projectId;

  const UploadProposalScreen({
    super.key,
    required this.token,
    required this.projectId,
  });

  @override
  State<UploadProposalScreen> createState() => _UploadProposalScreenState();
}

class _UploadProposalScreenState extends State<UploadProposalScreen> {
  File? selectedFile;
  bool isUploading = false;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> uploadProposal() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file first.")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      await ApiService.uploadProposal(
        token: widget.token,
        projectId: widget.projectId,
        file: selectedFile!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Proposal uploaded successfully.")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Proposal")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text("Choose File"),
              onPressed: pickFile,
            ),
            const SizedBox(height: 10),
            Text(
              selectedFile != null
                  ? "Selected: ${selectedFile!.path.split('/').last}"
                  : "No file selected",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload),
              label: Text(isUploading ? "Uploading..." : "Submit Proposal"),
              onPressed: isUploading ? null : uploadProposal,
            ),
          ],
        ),
      ),
    );
  }
}
