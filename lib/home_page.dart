import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

final TextEditingController _responseController = TextEditingController();
Future<void> uploadFile(String ufilePath) async {
  var dio = Dio();
  var formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(ufilePath, filename: 'recorder.mp3'),
  });

  var response = await dio.post('http://172.16.1.97:5000/save-record',
      data: formData, onSendProgress: (count, total) {
    print('onSendProgress');
  }, options: Options(contentType: 'multipart/form-data'));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = response.data;
    // Accessing specific fields from the JSON response
    String result = data['result'];
    _responseController.text = result;
    print('File uploaded successfully!');
    // Save response to TextField
  } else {
    print('Failed to upload file.');
  }
}

// Future<void> uploadFile(String ufilePath) async {
//   var request = http.MultipartRequest(
//       'POST', Uri.parse('http://172.16.1.97:5000/save-record'));
//   request.files.add(await http.MultipartFile.fromPath('file', ufilePath));

//   var response = await request.send();
//   if (response.statusCode == 200) {
//     var responseBody = await http.Response.fromStream(response);
//     String textResponse =
//         responseBody.body; // Assuming the server response is a plain string
//     print('Converted Text: $textResponse');
//   } else {
//     print('Failed to upload file.');
//   }
// }

class _HomePageState extends State<HomePage> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  String? recordingPath;
  bool isRecording = false, isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _recodingButton(),
      body: _buildUI(),
    );
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Widget _buildUI() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (recordingPath != null)
                  MaterialButton(
                    onPressed: () async {
                      if (audioPlayer.playing) {
                        audioPlayer.stop();
                        setState(() {
                          isPlaying = false;
                        });
                      } else {
                        await audioPlayer.setFilePath(recordingPath!);
                        audioPlayer.play();
                      }
                    },
                    color: Theme.of(context).colorScheme.primary,
                    child: Text(
                      isPlaying
                          ? "Stop playing Recording"
                          : "start playing Recording",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                if (recordingPath == null) const Text("يمكنك البدء بالتحدث")
              ],
            ),
          ),
          TextField(
            minLines: 1,
            maxLines: 10,
            textAlign: TextAlign.right,
            controller: _responseController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '  .... الرجاء انتظار الاجابة  ',
            ),
          ),
        ]);
  }

  Widget _recodingButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (isRecording) {
          String? filePath = await audioRecorder.stop();
          if (filePath != null) {
            setState(() {
              isRecording = false;
              recordingPath = filePath;
              uploadFile(recordingPath!);
            });
          }
        } else {
          if (await audioRecorder.hasPermission()) {
            final Directory appDocumentsDir =
                await getApplicationDocumentsDirectory();

            final String filePath =
                p.join(appDocumentsDir.path, "recorder.mp3");
            await audioRecorder.start(
              const RecordConfig(),
              path: filePath,
            );
            setState(() {
              isRecording = true;
              recordingPath = null;
            });
          }
        }
      },
      child: Icon(isRecording ? Icons.stop : Icons.mic),
    );
  }
}
