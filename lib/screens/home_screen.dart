import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whattsap/models/api_response.dart';
import 'package:whattsap/models/api_service.dart';
import 'package:whattsap/screens/history_screen.dart';
import '../models/message_response.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  File? _selectedFile;
  bool _isLoading = false;
  String? _lastSentPhone;

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
    await Permission.camera.request();
    await Permission.photos.request();
  }

  Future<void> _selectFile() async {
    await _requestPermissions();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Seleccionar imagen'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_file),
                title: Text('Seleccionar archivo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = _phoneController.text.trim();
    final textMessage = _messageController.text.trim();

    if (textMessage.isEmpty && _selectedFile == null) {
      _showSnackBar('Debe ingresar un mensaje o seleccionar un archivo', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      ApiResponse<MessageResponse> response;

      if (_selectedFile != null) {
        response = await ApiService.sendMessageWithFile(
          phoneNumber: phoneNumber,
          textMessage: textMessage.isNotEmpty ? textMessage : null,
          file: _selectedFile!,
        );
      } else {
        response = await ApiService.sendTextMessage(
          phoneNumber: phoneNumber,
          textMessage: textMessage,
        );
      }

      if (response.success) {
        _showSnackBar('Mensaje enviado exitosamente', isError: false);
        _lastSentPhone = phoneNumber;
        _clearForm();
      } else {
        _showSnackBar(response.error ?? 'Error desconocido', isError: true);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _messageController.clear();
    setState(() {
      _selectedFile = null;
    });
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _navigateToHistory() {
    if (_lastSentPhone != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HistoryScreen(phoneNumber: _lastSentPhone!),
        ),
      );
    } else {
      _showSnackBar('No hay historial disponible', isError: true);
    }
  }

  String _getFileName() {
    if (_selectedFile == null) return '';
    return _selectedFile!.path.split('/').last;
  }

  IconData _getFileIcon() {
    if (_selectedFile == null) return Icons.attach_file;

    final extension = _getFileName().split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'ogg':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WhatsApp Messenger'),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          if (_lastSentPhone != null)
            IconButton(
              icon: Icon(Icons.history),
              onPressed: _navigateToHistory,
              tooltip: 'Ver historial',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.green[50]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.chat, // Or Icons.message, Icons.send, etc.
                          size: 50,
                          color: Colors.green[700],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Enviar Mensaje',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        Text(
                          'Envía mensajes y archivos a WhatsApp',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Formulario
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Campo número de teléfono
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Número de teléfono',
                              hintText: '+51987654321',
                              prefixIcon: Icon(Icons.phone, color: Colors.green[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.green[700]!),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese un número de teléfono';
                              }
                              if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value.replaceAll(' ', ''))) {
                                return 'Número de teléfono inválido';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 16),

                          // Campo mensaje
                          TextFormField(
                            controller: _messageController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Mensaje (opcional)',
                              hintText: 'Escribe tu mensaje aquí...',
                              prefixIcon: Icon(Icons.message, color: Colors.green[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.green[700]!),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          // Botón seleccionar archivo
                          OutlinedButton.icon(
                            onPressed: _isLoading ? null : _selectFile,
                            icon: Icon(_getFileIcon()),
                            label: Text(_selectedFile == null
                                ? 'Seleccionar archivo (opcional)'
                                : 'Archivo: ${_getFileName()}'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.all(12),
                              side: BorderSide(color: Colors.green[700]!),
                              foregroundColor: Colors.green[700],
                            ),
                          ),

                          if (_selectedFile != null) ...[
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(_getFileIcon(), color: Colors.green[700]),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _getFileName(),
                                      style: TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, size: 16),
                                    onPressed: () {
                                      setState(() {
                                        _selectedFile = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],

                          SizedBox(height: 20),

                          // Botón enviar
                          ElevatedButton(
                            onPressed: _isLoading ? null : _sendMessage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Enviando...'),
                              ],
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send),
                                SizedBox(width: 8),
                                Text(
                                  'Enviar Mensaje',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
