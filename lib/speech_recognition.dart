import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:simple_permissions/simple_permissions.dart';

class SpeechRecognition {
  static MethodChannel platform =
      const MethodChannel("samples.flutter.io/speechRec");
  Permission permission = Permission.RecordAudio;
  bool checkPermission = false;
  var currentRecordingColor = Colors.black;
  bool _isCorrect = false;
  bool _speechRecIsListening = false;
  bool _speechRecognitionAvailable = false;
  String transcript = '';
  get getSpeechRecIsListening => _speechRecIsListening;
  get getspeechRecognitionAvailable => _speechRecognitionAvailable;
  get getIsCorrect => _isCorrect;
  get getCurrentRecordingColor => currentRecordingColor;
  StreamController transcriptStream = StreamController();
  _setSpeechRecIsListening(res) {
    _speechRecIsListening = res;
  }

  get getTranscript => transcript;
  _setTranscript(value) {
    transcript = value;
  }

  setspeechRecognitionAvailable(res) {
    _speechRecognitionAvailable = res;
  }

  setIsCorrect(res) {
    _isCorrect = res;
  }

  setCurrentRecordingColor(res) {
    currentRecordingColor = res;
  }

  void initPermission() async {
    if (checkPermission == false) {
      await SimplePermissions.requestPermission(permission);
    }
    SimplePermissions.checkPermission(permission).then((bool value) {
      checkPermission = value;
    });
  }

  startRec() async {
    _setTranscript('');
    initPermission();
    platform.setMethodCallHandler(_platformCallHandler);
    try {
      platform.invokeMethod("startRec").then((value) {
        if (value == true || value || false) {
          setspeechRecognitionAvailable(value);
        } else {}
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  stopRec() async {
    try {
      platform.invokeMethod("stopRec").then((dynamic value) {
        if (value == true || value == false) {
          setspeechRecognitionAvailable(value);
        } else {
          print(value.toString());
        }
      });
      ;
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "listening":
        _setSpeechRecIsListening(call.arguments);
        break;
      case "getTranscript":
          transcriptStream.sink.add(call.arguments.toString());

        _setTranscript(call.arguments.toString());
        break;
      default:
        print('Unknowm method ${call.method} ');
    }
  }
}
