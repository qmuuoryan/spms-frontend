
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

class _UploadProposalScreenState extends State<UploadProposalScreen>
    with TickerProviderStateMixin {
  
  File? selectedFile; 
  Uint8List? selectedFileBytes; 
  PlatformFile? selectedPlatformFile; 
  
  bool isUploading = false;
  double uploadProgress = 0.0;
  String? fileSize;
  String? fileName;

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        
        setState(() {
          selectedPlatformFile = platformFile;
          fileName = platformFile.name;
          fileSize = _formatFileSize(platformFile.size);
        });

        if (kIsWeb) {
          if (platformFile.bytes != null) {
            setState(() {
              selectedFileBytes = platformFile.bytes;
              selectedFile = null;
            });
          } else {
            _showErrorSnackBar("Error: Could not read file bytes");
            return;
          }
        } else {
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            setState(() {
              selectedFile = file;
              selectedFileBytes = null;
            });
          } else {
            _showErrorSnackBar("Error: Could not access file path");
            return;
          }
        }

        _animationController.reset();
        _animationController.forward();
      }
    } catch (e) {
      _showErrorSnackBar("Error selecting file: $e");
    }
  }

  Future<void> uploadProposal() async {
    if ((kIsWeb && selectedFileBytes == null) || (!kIsWeb && selectedFile == null)) {
      _showErrorSnackBar("Please select a file first.");
      return;
    }

    setState(() {
      isUploading = true;
      uploadProgress = 0.0;
    });

    try {
      _simulateProgress();

      if (kIsWeb) {
        await ApiService.uploadProposalWeb(
          token: widget.token,
          projectId: widget.projectId,
          fileBytes: selectedFileBytes!,
          fileName: fileName!,
        );
      } else {
        await ApiService.uploadProposal(
          token: widget.token,
          projectId: widget.projectId,
          file: selectedFile!,
        );
      }

      setState(() => uploadProgress = 1.0);
      
      _showSuccessSnackBar("Proposal uploaded successfully!");
      
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) Navigator.pop(context, true);
      
    } catch (e) {
      _showErrorSnackBar("Upload failed: $e");
    } finally {
      setState(() => isUploading = false);
    }
  }

  void _simulateProgress() {
    const duration = Duration(milliseconds: 100);
    Timer.periodic(duration, (timer) {
      if (!isUploading) {
        timer.cancel();
        return;
      }
      
      setState(() {
        uploadProgress += 0.05;
        if (uploadProgress >= 0.9) {
          timer.cancel();
        }
      });
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool get hasSelectedFile {
    return (kIsWeb && selectedFileBytes != null) || (!kIsWeb && selectedFile != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF004D40),
              Color(0xFF00695C),
              Color(0xFF26A69A)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new, 
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Upload Proposal",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Project ID: ${widget.projectId}",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: hasSelectedFile ? 1.0 : _pulseAnimation.value,
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: hasSelectedFile
                                              ? [Colors.green[400]!, Colors.green[600]!]
                                              : [const Color(0xFF00695C), const Color(0xFF004D40)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (hasSelectedFile ? Colors.green : const Color(0xFF667eea))
                                                .withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        hasSelectedFile ? Icons.check : Icons.upload_file,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 32),

                              
                              if (!hasSelectedFile) ...[
                                const Text(
                                  "Select a proposal file",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Supported formats: PDF, DOC, DOCX",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                _buildChooseFileButton(),
                              ] else ...[
                                _buildSelectedFileInfo(),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Expanded(child: _buildChooseFileButton()),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildUploadButton()),
                                  ],
                                ),
                              ],

                              
                              if (isUploading) ...[
                                const SizedBox(height: 32),
                                _buildProgressSection(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChooseFileButton() {
    return ElevatedButton.icon(
      onPressed: pickFile,
      icon: const Icon(Icons.folder_open, size: 20),
      label: Text(!hasSelectedFile ? "Choose File" : "Change File"),
      style: ElevatedButton.styleFrom(
        backgroundColor: !hasSelectedFile 
            ? const Color(0xFF00695C) 
            : Colors.grey[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        shadowColor: const Color(0xFF00695C).withOpacity(0.3),
      ),
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton.icon(
      onPressed: isUploading ? null : uploadProposal,
      icon: isUploading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.cloud_upload, size: 20),
      label: Text(isUploading ? "Uploading..." : "Upload"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        shadowColor: Colors.green.withOpacity(0.3),
      ),
    );
  }

  Widget _buildSelectedFileInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getFileIcon(),
                  color: Colors.blue[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName ?? "Unknown file",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fileSize ?? "Unknown size",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Uploading...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            Text(
              "${(uploadProgress * 100).toInt()}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: uploadProgress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          minHeight: 8,
        ),
      ],
    );
  }

  IconData _getFileIcon() {
    if (fileName == null) return Icons.description;
    final extension = fileName!.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}