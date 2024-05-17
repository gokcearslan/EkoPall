import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

class EkoBotPage extends StatefulWidget {
  @override
  _EkoBotPageState createState() => _EkoBotPageState();
}

class _EkoBotPageState extends State<EkoBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  final String _projectId = 'charged-epsilon-408415';
  final String _locationId = 'europe-west2';
  final String _agentId = 'e0940673-225b-4db6-b898-81912519be37';
  late String _sessionId;
  AutoRefreshingAuthClient? _authClient;

  @override
  void initState() {
    super.initState();
    _sessionId = Uuid().v4(); //
    authenticate().then((_) {
      print("Authentication complete.");
    }).catchError((e) {
      print("Error in authentication: $e");
    });
  }

  Future<void> authenticate() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/ekobotchatbotv3.json');
      final jsonAccount = json.decode(jsonString);
      final accountCredentials = ServiceAccountCredentials.fromJson(jsonAccount);

      _authClient = await clientViaServiceAccount(accountCredentials, ['https://www.googleapis.com/auth/dialogflow']);
      print("Authentication successful");
    } catch (e) {
      print("Error in authentication: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dialogflow CX Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Type your message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed:  _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || _authClient == null) {
      print("No text or auth client is not initialized.");
      return;
    }

    String message = _controller.text;
    _controller.clear();
    setState(() {
      _messages.add('You: $message');
    });

    // Using the updated location and agent ID
    String url = 'https://europe-west2-dialogflow.googleapis.com/v3/projects/charged-epsilon-408415/locations/europe-west2/agents/e0940673-225b-4db6-b898-81912519be37/sessions/$_sessionId:detectIntent';
    // print("${_sessionId}ALOOOOOOOOOOOOOOOO");

    // print("Making request to URL: $url");
    //  print("With headers: Authorization: Bearer ${_authClient?.credentials.accessToken.data}");
    try {
      var response = await _authClient!.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authClient?.credentials.accessToken.data}',
        },
        body: jsonEncode({
          "queryInput": {
            "text": {
              "text": message
            },
            "languageCode": "tr"
          },
          "queryParams": {
            "timeZone": "Europe/Istanbul"
          }
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var responseMessages = data['queryResult']['responseMessages'];


        String combinedMessage = responseMessages.map((m) => m['text']['text'][0]).join("\n");

        setState(() {
          _messages.add('EKOBOT: $combinedMessage');
        });
      } else {
        setState(() {
          _messages.add('EKOBOT: Error communicating with Dialogflow - ${response.statusCode} ${response.body}');
        });
      }
    } catch (e) {
      setState(() {
        _messages.add('EKOBOT: Failed to send message - $e');
      });
    }
  }





  @override
  void dispose() {
    _authClient?.close();
    super.dispose();
  }
}
