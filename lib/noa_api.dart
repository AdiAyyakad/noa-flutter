import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final _log = Logger("Noa API");

// Simplified user class for basic information
class NoaUser {
  late String email;
  late String plan;
  late int creditsUsed;
  late int maxCredits;

  NoaUser({
    String? email,
    String? plan,
    int? creditsUsed,
    int? maxCredits,
  }) {
    this.email = email ?? "Local User";
    this.plan = plan ?? "Basic";
    this.creditsUsed = creditsUsed ?? 0;
    this.maxCredits = maxCredits ?? 100;
  }
}

// Noa messaging class
enum NoaRole {
  system('system'),
  user('user'),
  noa('noa');

  const NoaRole(this.value);
  final String value;
}

class NoaMessage {
  String message;
  NoaRole from;
  DateTime time;
  Uint8List? image;
  bool exclude = false;
  bool topicChanged = false;

  NoaMessage({
    required this.message,
    required this.from,
    required this.time,
    this.image,
    this.exclude = false,
    this.topicChanged = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "role": from == NoaRole.noa ? "assistant" : "user",
      "content": message,
    };
  }
}

// Simplified API class for local operations only
class NoaApi {
  // Create a simple echo response for messages
  static List<NoaMessage> createEchoResponse(String userMessage) {
    _log.info("Creating echo response for: $userMessage");
    
    String response;
    
    // Special commands
    if (userMessage.toLowerCase().trim() == "camera") {
      response = "Taking a picture...";
    } else if (userMessage.toLowerCase().trim() == "microphone") {
      response = "Recording audio for 1 minute...";
    } else {
      response = "Message received: $userMessage";
    }
    
    return [
      NoaMessage(
        message: userMessage,
        from: NoaRole.user,
        time: DateTime.now(),
      ),
      NoaMessage(
        message: response,
        from: NoaRole.noa,
        time: DateTime.now().add(const Duration(seconds: 1)),
      ),
    ];
  }
}