import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_code/models/code_tile.dart';
import 'package:speech_to_code/speech_recognition.dart';

import '../sToC.dart';

class CodingPage extends StatefulWidget {
  CodeTile codeTile;

  CodingPage({@required this.codeTile});
  @override
  _CodingPage createState() => _CodingPage();
}

class _CodingPage extends State<CodingPage> with TickerProviderStateMixin {
  String transcript = '';
  Widget paramWidget = SizedBox();
  static AudioPlayer player = AudioPlayer();
  static AudioCache audio = AudioCache(prefix: "audio/");
  SpeechRecognition speechRecognition = SpeechRecognition();
  StreamSubscription stream;

  int pagesNumber = 0;

  @override
  void initState() {
    super.initState();

    stream =
        speechRecognition.transcriptStream.stream.listen((_transcript) {
      if (mounted) {
        SToC sToC = SToC();
        List<String> splittedTranscript = _transcript.split(' ');

        for (String word in splittedTranscript) {
          sToC.command(word);

          setState(() {
            transcript = sToC.code;
          });
        }
      }
    });
    Future.delayed(Duration(milliseconds: 100), () async {
      player = await audio.play(widget.codeTile.audioName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TabBar(
          onTap: (int index) {
            setState(() {
              pagesNumber = index;
            });
          },
          labelPadding: EdgeInsets.symmetric(vertical: 40),
          controller: TabController(vsync: this, length: 2),
          tabs: <Widget>[
            Icon(
              Icons.text_fields,
              color: (pagesNumber == 0) ? Colors.blue : Colors.black,
              size: 30.0,
            ),
            Icon(
              Icons.visibility,
              color: (pagesNumber == 1) ? Colors.blue : Colors.black,
              size: 30.0,
            )
          ],
        ),
        body: getBody(pagesNumber),
        bottomNavigationBar: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.mic,
                  color: Colors.black,
                ),
                onPressed: () {
                  speechRecognition.startRec();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.save,
                  color: Colors.black,
                ),
                onPressed: () {
                  //save
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ));
  }

  Widget getBody(int pagesNuber) {
    return (pagesNuber == 0)
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.blueGrey[600],
            padding: EdgeInsets.all(20),
            child: Text(
              transcript,
              style: TextStyle(color: Colors.white),
            ),
          )
        : Center(child: paramWidget);
  }
}
