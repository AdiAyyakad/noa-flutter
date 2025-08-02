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
    try {
      final response = await http.post(
        Uri.parse('https://api.brilliant.xyz/noa/user/signin'),
        body: {
          'id_token': id,
          'provider': provider.value,
        },
      );

      if (response.statusCode != 200) {
        throw NoaApiServerException(
          reason: response.body,
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);

      return decoded['token'];
    } catch (error) {
      _log.warning(error);
      return Future.error(error);
    }
  }

  static Future<void> signOut(
    String userAuthToken,
  ) async {
    _log.info("Signing out");
    try {
      final response = await http.post(
        Uri.parse('https://api.brilliant.xyz/noa/user/signout'),
        headers: {"Authorization": userAuthToken},
      );

      if (response.statusCode != 200) {
        throw NoaApiServerException(
          reason: response.body,
          statusCode: response.statusCode,
        );
      }
    } catch (error) {
      _log.warning(error);
      return Future.error(error);
    }
  }

  static Future<NoaUser> getUser(String userAuthToken) async {
    _log.info("Getting user info");
    try {
      final response = await http.get(
        Uri.parse('https://api.brilliant.xyz/noa/user'),
        headers: {"Authorization": userAuthToken},
      );

      if (response.statusCode != 200) {
        throw NoaApiServerException(
          reason: response.body,
          statusCode: response.statusCode,
        );
      }

      final body = jsonDecode(response.body);
      final email = body['user']['email'];
      final plan = body['user']['plan'];
      final creditsUsed = body['user']['credit_used'];
      final maxCredits = body['user']['credit_total'];

      _log.info(
          "Got user account info: Email: $email, plan: $plan, credits: $creditsUsed/$maxCredits");

      return NoaUser(
        email: email,
        plan: plan,
        creditsUsed: creditsUsed,
        maxCredits: maxCredits,
      );
    } catch (error) {
      _log.warning(error);
      return Future.error(error);
    }
  }

  static Future<void> deleteUser(
    String userAuthToken,
  ) async {
    _log.info("Deleting user");
    try {
      final response = await http.post(
        Uri.parse('https://api.brilliant.xyz/noa/user/delete'),
        headers: {"Authorization": userAuthToken},
      );

      if (response.statusCode != 200) {
        throw NoaApiServerException(
          reason: response.body,
          statusCode: response.statusCode,
        );
      }
    } catch (error) {
      _log.warning(error);
      return Future.error(error);
    }
  }

  static Future<List<NoaMessage>> getMessage(
    String userAuthToken,
    Uint8List audio,
    Uint8List image,
    String systemRole,
    double temperature,
    List<NoaMessage> noaHistory,
    bool textToSpeech,
    String apiEndpoint,
    String apiToken,
    String apiHeader,
    bool isCustomServerEnabled,
    bool promptless,
  ) async {
    try {
      String endPoint = 'https://api.brilliant.xyz/noa';
      String token = userAuthToken;
      String header = "Authorization";

      if (apiEndpoint.isEmpty && isCustomServerEnabled) {
        throw NoaApiServerException(
          reason: "Custom server enabled but no endpoint provided",
          statusCode: 400,
        );
      }
      if (isCustomServerEnabled) {
        endPoint = apiEndpoint;
        token = apiToken;
        header = apiHeader;
      }
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(endPoint),
      );

      request.headers.addAll({header: token});

      request.files.add(http.MultipartFile.fromBytes(
        'audio',
        bytesToWav(audio, 8, 8000),
        filename: 'audio.wav',
      ));

      try {
        image = encodeJpg(copyRotate(decodeJpg(image)!, angle: -90));

        request.files.add(http.MultipartFile.fromBytes(
          'image',
          image,
          filename: 'image.jpg',
        ));
      } catch (error) {
        _log.warning(error);
      }
      noaHistory = noaHistory.where((msg) => !msg.exclude).toList();
      if (!isCustomServerEnabled) {
        request.fields['noa_system_prompt'] = systemRole;
        request.fields['temperature'] = temperature.toString();
        request.fields['tts'] = textToSpeech ? "1" : "0";
        request.fields['promptless'] = promptless ? "1" : "0";
      }
      request.fields['messages'] = jsonEncode(noaHistory);
      request.fields['location'] = await Location.getAddress();
      request.fields['time'] = DateTime.now().toString();

      _log.info(
          "Sending message request: audio[${audio.length}], image[${image.length}], ${request.fields.toString()}");

      var streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw NoaApiServerException(
          reason: streamedResponse.reasonPhrase ?? "",
          statusCode: streamedResponse.statusCode,
        );
      }

      List<int> serverResponse = List.empty(growable: true);
      await streamedResponse.stream
          .forEach((element) => serverResponse += element);
      var body = jsonDecode(utf8.decode(serverResponse));
      List<NoaMessage> response = List.empty(growable: true);
      final topicChanged = body["debug"]['topic_changed']??false;

      response.add(NoaMessage(
        message: body['user_prompt'].toString().replaceAll(RegExp(r'—'), '-'),
        from: NoaRole.user,
        time: DateTime.now(),
        image: kReleaseMode ? null : image,
        topicChanged: topicChanged
      ));

      response.add(NoaMessage(
        message: body['message'].toString().replaceAll(RegExp(r'—'), '-'),
        from: NoaRole.noa,
        time: DateTime.now(),
        image: body['image'] != null ? base64.decode(body['image']) : null,
      ));

      _log.info(
          "Received response. User: \"${body['user_prompt']}\". Noa: \"${body['message']}\". Debug: ${body['debug']}");

      if (textToSpeech && body['audio'] != null) {
        _playAudio(base64.decode(body['audio']));
      }

      return response;
    } catch (error) {
      _log.warning(error);
      return Future.error(error);
    }
  }

  static Future<List<NoaMessage>> getWildcardMessage(
    String userAuthToken,
    String systemRole,
    double temperature,
    bool textToSpeech,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.brilliant.xyz/noa/wildcard'),
      );

      request.headers.addAll({HttpHeaders.authorizationHeader: userAuthToken});

      request.fields['noa_system_prompt'] = systemRole;
      request.fields['location'] = await Location.getAddress();
      request.fields['time'] = DateTime.now().toString();
      request.fields['temperature'] = temperature.toString();
      request.fields['tts'] = textToSpeech ? "1" : "0";

      _log.info("Sending wildcard request: ${request.fields.toString()}");

      var streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw NoaApiServerException(
          reason: streamedResponse.reasonPhrase ?? "",
          statusCode: streamedResponse.statusCode,
        );
      }

      List<int> serverResponse = List.empty(growable: true);
      await streamedResponse.stream
          .forEach((element) => serverResponse += element);
      var body = jsonDecode(utf8.decode(serverResponse));

      List<NoaMessage> response = List.empty(growable: true);

      response.add(NoaMessage(
        message: "Wildcard 👻",
        from: NoaRole.user,
        time: DateTime.now(),
      ));

      response.add(NoaMessage(
        message: body['message'].toString().replaceAll(RegExp(r'—'), '-'),
        from: NoaRole.noa,
        time: DateTime.now(),
      ));

      _log.info(
          "Received wildcard response. User: \"${body['user_prompt']}\". Noa: \"${body['message']}\". Debug: ${body['debug']}");

      if (textToSpeech && body['audio'] != null) {
        _playAudio(base64.decode(body['audio']));
      }

      return response;
    } catch (error) {
      _log.warning(error);
      return Future.error(error);
    }
  }

  static void _playAudio(Uint8List audio) async {
    _log.info("Playing ${audio.length} bytes of audio");

    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/audio.mp3').create();
    file.writeAsBytesSync(audio);

    try {
      AudioPlayer player = AudioPlayer(handleAudioSessionActivation: false);
      await player.setAudioSource(AudioSource.file(file.path));
      await player.play();
      await player.dispose();
    } catch (error) {
      _log.warning("Error playing audio. $error");
    }
  }
}