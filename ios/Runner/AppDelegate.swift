import UIKit
import Flutter
import Speech


@UIApplicationMain
class AppDelegate: FlutterAppDelegate, SFSpeechRecognizerDelegate {
  var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))!
  public var speechChannel: FlutterMethodChannel?
  public var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  public var recognitionTask: SFSpeechRecognitionTask?
  public let audioEngine = AVAudioEngine()
  public var timer: Int = 0

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = self.window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "samples.flutter.io/speechRec", binaryMessenger: controller)
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if(call.method == "startRec")  { 
        self.initRec(res: result)
        result(true) 
      }
      if(call.method == "stopRec")  {
        self.stopRec()
        result(false) 
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    self.speechChannel = channel;
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
 
  public func initRec(res: @escaping FlutterResult) {
    recognitionRequest?.shouldReportPartialResults = true
    recognitionRequest?.taskHint = SFSpeechRecognitionTaskHint.dictation
    SFSpeechRecognizer.requestAuthorization { authStatus in
      OperationQueue.main.addOperation {
        switch authStatus {
        case .authorized:
          self.startRec(result: res)
          print("case autorized")
        case .denied:
          res(false)
          print("case denied")
        case .restricted:
          res(false)
          print("case restricted")
        case .notDetermined:
          res(false)
          print("case notDetermined")
        }
        print("SFSpeechRecognizer.requestAuthorization \(authStatus.rawValue)")
      }
    }
  }
    
  @objc public func sel(){
     self.stopRec()
  }
    
  public func startRec(result: Any){
      let audioSession = AVAudioSession.sharedInstance()
      do {
          try audioSession.setCategory(AVAudioSessionCategoryRecord)
          try audioSession.setMode(AVAudioSessionModeMeasurement)
          try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
      } catch {
        print("audioSession properties weren't set because of an error.")
      }
    
      recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
      let inputNode = self.audioEngine.inputNode
      inputNode.removeTap(onBus: 0)
      guard let recognitionRequest = recognitionRequest else {
         fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
      }

      let recordingFormat = inputNode.outputFormat(forBus: 0)
      inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
          recognitionRequest.append(buffer)
      }
      audioEngine.prepare()
      do {
        try audioEngine.start()
        if(self.audioEngine.isRunning){
          self.speechChannel?.invokeMethod("listening", arguments: true)
        }
      } catch let error {
        self.speechChannel?.invokeMethod("listening", arguments: false)
        inputNode.removeTap(onBus: 0)
        print("There was a problem starting recording: \(error.localizedDescription)")
      }
    
      recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
        if result != nil {
           if let result = result {
            Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.sel), userInfo: nil, repeats: false)
               print("---------------------- RESULT --------------------------  ")
               self.speechChannel?.invokeMethod("getTranscript", arguments: result.bestTranscription.formattedString)
               print(result.bestTranscription.formattedString)
               if(result.isFinal){
                    self.speechChannel?.invokeMethod("listening", arguments: false)
               }
           }
        }
       if error != nil {
         inputNode.removeTap(onBus: 0)
         self.stopRec()
         print("NO RESULT --  ")
         self.speechChannel?.invokeMethod("getTranscript", arguments: "")
       }
    }
  }
  
  public func stopRec() {
    self.recognitionTask = nil
    self.speechChannel?.invokeMethod("listening", arguments: false)
    self.recognitionRequest?.endAudio()
    self.audioEngine.stop()
  }

}