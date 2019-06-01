import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_code/speech_recognition.dart';
import 'package:speech_to_code/ui/codes_list.dart';

class SpeechToCode extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SpeechToCodeState();
  }
}

class _SpeechToCodeState extends State<SpeechToCode> {
  String transcrpt = 'transcript';
  SpeechRecognition speechRecognition = SpeechRecognition();

  @override
  void initState() {
    super.initState();
    speechRecognition.initPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CodesList(),
      
    );
  }
}
