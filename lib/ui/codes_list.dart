import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_code/models/code_tile.dart';
import 'package:speech_to_code/speech_recognition.dart';

// audio player
import 'package:audioplayers/audio_cache.dart';

import 'coding_page.dart';

class CodesList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CodesListState();
  }
}

class _CodesListState extends State<CodesList> {
  String transcrpt = 'transcript';
  SpeechRecognition speechRecognition = SpeechRecognition();
  StreamSubscription stream;
  List<CodeTile> codes = [];
  static AudioPlayer player = AudioPlayer();
  static AudioCache audio = AudioCache(prefix: "audio/");

  @override
  void initState() {
    super.initState();
    speechRecognition.initPermission();

    codes = [
      CodeTile(
          code: 'Start new flutter project', audioName: '3-newproject.wav'),
      CodeTile(code: 'Crate a new Widget', audioName: '4-newwidget.wav'),
      CodeTile(code: 'Show voice command', audioName: '5-showcommands.wav'),
      CodeTile(
          code: 'Select property, set value', audioName: '6-propertyvalue.wav'),
    ];
    Future.delayed(Duration(milliseconds: 5), () async {
      showDialog(
          context: context,
          builder: (context) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/hawking.jpg'),
                ),
              ),
            );
          });
      player = await audio.play('1-hello.wav');
      player.completionHandler = () async {
        Navigator.pop(context);
        player = await audio.play('2-start.wav');
      };
    });
  }

  @override
  void dispose() {
    super.dispose();
    stream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView.builder(
            itemCount: codes.length,
            itemBuilder: (BuildContext context, int index) => listTile(index)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Add'),
        icon: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }

  /// [listTile] function wiil be builds and returns
  Widget listTile(index) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CodingPage(codeTile: codes[index]),
            ),
          );
        },
        title: Text(
          codes[index].code,
          maxLines: 1,
        ),
      ),
    );
  }
}
