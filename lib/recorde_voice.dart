import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class RecordeVoice extends StatelessWidget {
  const RecordeVoice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AudioRecorder(),
    );
  }
}

class AudioRecorder extends StatefulWidget {
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [Permission.microphone, Permission.storage].request();
  }

  Future<void> startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/recording.wav';
    // Implement audio recording logic here using your preferred method
    setState(() {});
  }

  Future<void> stopRecording() async {
    // Implement logic to stop recording
    if (_filePath != null) {
      await uploadFile(_filePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Recorder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: startRecording,
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: stopRecording,
              child: Text('Stop Recording'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> uploadFile(String filePath) async {
  var dio = Dio();
  var formData = FormData.fromMap({
    'audio': await MultipartFile.fromFile(filePath, filename: 'audio.wav'),
  });

  var response =
      await dio.post('https://yourserver.com/upload', data: formData);

  if (response.statusCode == 200) {
    print('File uploaded successfully!');
    String textResponse = response
        .data['text']; // Assuming the server response has a 'text' field
    print('Converted Text: $textResponse');
  } else {
    print('Failed to upload file.');
  }
}
