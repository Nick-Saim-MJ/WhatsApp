import 'package:flutter/material.dart';
import '../models/api_service.dart';
import '../models/message_response.dart';

class HistoryScreen extends StatefulWidget {
  final String phoneNumber;

  const HistoryScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<MessageResponse> _messages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await ApiService.getMessageHistory(widget.phoneNumber);

    setState(() {
      _isLoading = false;
      if (response.success) {
        _messages = response.data ?? [];
      } else {
        _error = response.error;
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'SENT':
        return Colors.green;
      case 'DELIVERED':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'SENT':
        return Icons.check;
      case 'DELIVERED':
        return Icons.done_all;
      case 'FAILED':
        return Icons.error;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // SOLUCIÓN: Usamos un Column para combinar el título y el subtítulo
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinea el texto a la izquierda
          children: [
            Text(
              'Historial de Mensajes', // Título principal
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.phoneNumber, // Subtítulo
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70, // Un color un poco más suave
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadHistory,
            color: Colors.white, // Asegura que el ícono sea visible
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
        child: _isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green[700]),
              SizedBox(height: 16),
              Text('Cargando historial...'),
            ],
          ),
        )
            : _error != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error: $_error'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadHistory,
                child: Text('Reintentar'),
              ),
            ],
          ),
        )
            : _messages.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No hay mensajes en el historial'),
            ],
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(message.status),
                          color: _getStatusColor(message.status),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          message.status,
                          style: TextStyle(
                            color: _getStatusColor(message.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'ID: ${message.id}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (message.textMessage != null) ...[
                      SizedBox(height: 8),
                      Text(
                        message.textMessage!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                    if (message.fileUrl != null) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.attach_file, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Archivo adjunto',
                                style: TextStyle(color: Colors.blue[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}