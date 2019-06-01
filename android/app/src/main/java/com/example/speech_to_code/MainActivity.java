package com.example.speech_to_code;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.content.ContextWrapper;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

import android.app.Activity;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.util.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.ArrayList;
import java.util.Locale;

public class MainActivity extends FlutterActivity implements RecognitionListener {
  private static final String CHANNEL = "samples.flutter.io/speechRec";
  public SpeechRecognizer speech;
  RecognitionListener listener;
  Bundle bundle;
  public MethodChannel speechChannel;
  String transcription = "";
  public boolean cancelled = false;
  public Intent recognizerIntent;
  public Activity activity;
  Context context;



  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  speech = SpeechRecognizer.createSpeechRecognizer(getApplicationContext());
    speech.setRecognitionListener(this);
    speechChannel =  new MethodChannel(getFlutterView(), CHANNEL);
    speechChannel.setMethodCallHandler(
      new MethodCallHandler() {
          @Override
          public void onMethodCall(MethodCall call, Result result) {
              if (call.method.equals("startRec")) {
                speech.startListening(recognizerIntent);
                Log.d("startButton", "pressed");
                result.success(true);
              } else if (call.method.equals("stopRec")) {
                speech.stopListening();
                Log.d("stopButton", "pressed");
                String lang = "en-US";
                  result.success(false);
              } else {
                  result.notImplemented();
              }
          }
      });


    recognizerIntent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
    recognizerIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US");
    // recognizerIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,
    //     RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
    recognizerIntent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true);
    recognizerIntent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3);
    
  }
  
  @Override
  public void onReadyForSpeech(Bundle params) {
      Log.d("SpeechRecognition", "Ready for speech");
      speechChannel.invokeMethod("startRec", true);
  }

  @Override
  public void onBeginningOfSpeech() {
      speechChannel.invokeMethod("listening", true);
      Log.d("SpeechRecognition", "SPEECH STARTED");
      transcription = "";
  }

  @Override
  public void onEndOfSpeech() {
      Log.d("SpeechRecognition", "SPEECH END");
      speechChannel.invokeMethod("stopRec", false);
      speechChannel.invokeMethod("listening", false);
      speechChannel.invokeMethod("getTranscript", transcription);
      
  }

  @Override
    public void onError(int error) {
        Log.d("SpeechRecognitionError", "onError : " + error);
        speechChannel.invokeMethod("stopRec", false);
    }

    @Override
    public void onPartialResults(Bundle partialResults) {
        ArrayList<String> matches = partialResults
                .getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
        transcription = matches.get(0);
        Log.d("onPartialResults", "onPartialResults... " + transcription);
        speechChannel.invokeMethod("getTranscript", transcription);
    }

    @Override
    public void onEvent(int eventType, Bundle params) {
        Log.d("onEvent", "onEvent : " + eventType);
    }

    @Override
    public void onResults(Bundle results) {
        speechChannel.invokeMethod("getTranscript", transcription);
        Log.d("onResults", "onResults...");
        ArrayList<String> matches = results
                .getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
        String text = "";
        transcription = matches.get(0);
        Log.d("onResults", "onResults -> " + transcription);
    }

    @Override
    public void onRmsChanged(float rms) {
        Log.d("onRmsChanged", "onRmsChanged : " + rms);
    }

    @Override
    public void onBufferReceived(byte[] buffer) {
        Log.d("SpeechRecognition", "onBufferReceived");
    }

      
  };
      

    
 