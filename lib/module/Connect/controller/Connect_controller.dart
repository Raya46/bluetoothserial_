// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:isoja_application/state_util.dart';
// import 'package:perfect_volume_control/perfect_volume_control.dart';
// import '../view/Connect_view.dart';

// class _Message {
//   int whom;
//   String text;

//   _Message(this.whom, this.text);
// }

// class ConnectController extends State<ConnectView> implements MvcController {
//   static late ConnectController instance;
//   late ConnectView view;
//   bool switch1 = false;
//   bool btnVisible = true;
//   final ScrollController listScrollController = new ScrollController();
//   static final clientID = 0;
//   double currentValue = 0.0;
//   double playMusic = 0.0;

//   @override
//   void initState() {
//     instance = this;
//     super.initState();

//     FlutterBluetoothSerial.instance.state.then((state) {
//       setState(() {
//         bluetoothState = state;
//       });
//     });

//     deviceState = 0; // neutral

//     // If the bluetooth of the device is not enabled,
//     // then request permission to turn on bluetooth
//     // as the app starts up
//     enableBluetooth();

//     // Listen for further state changes
//     FlutterBluetoothSerial.instance
//         .onStateChanged()
//         .listen((BluetoothState state) {
//       setState(() {
//         bluetoothState = state;
//         if (bluetoothState == BluetoothState.STATE_OFF) {
//           isButtonUnavailable = true;
//         }
//         getPairedDevices();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     // Avoid memory leak and disconnect
//     if (isConnected!) {
//       isDisconnecting = true;
//       connection?.dispose();
//       // connection = null;
//     }

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => widget.build(context, this);
//   BluetoothState bluetoothState = BluetoothState.UNKNOWN;
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   final FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
//   BluetoothConnection? connection;
//   late int deviceState;
//   _Message? message;
//   List<_Message> messages = [];
//   int indexNum = 0;
//   bool isDisconnecting = false;
//   bool abdul = false;

//   //*Color//
//   final Color baseColor = Color.fromRGBO(42, 50, 75, 1);
//   final Color baseColor12 = Color.fromRGBO(42, 50, 75, 0.13);
//   final Color textColor = Color.fromRGBO(42, 50, 75, 0.8);
//   final Color bgColor = Color.fromRGBO(199, 204, 219, 1);
//   final Color subText = Color.fromRGBO(0, 0, 0, 0.56);
//   final Color disableBaseColor = Color.fromRGBO(216, 226, 220, 1);
//   final Color disableBaseColor12 = Color.fromRGBO(0, 0, 0, 0.56);
//   final Color fieldBgColor = Color.fromRGBO(221, 225, 234, 1);
//   final Color lampOn = Color.fromRGBO(249, 203, 64, 1);
//   final Color powerOn = Color.fromRGBO(36, 169, 108, 1);
//   final Color redColor = Color.fromRGBO(214, 71, 51, 1);

//   Future<void> enableBluetooth() async {
//     // Retrieving the current Bluetooth state
//     bluetoothState = await FlutterBluetoothSerial.instance.state;

//     // If the bluetooth is off, then turn it on first
//     // and then retrieve the devices that are paired.
//     if (bluetoothState == BluetoothState.STATE_OFF) {
//       await FlutterBluetoothSerial.instance.requestEnable();
//       await getPairedDevices();
//       // return true;
//     } else {
//       await getPairedDevices();
//     }
//     // return false;
//   }

//   // To track whether the device is still connected to Bluetooth
//   // bool? get isConnected => connection?.isConnected;
//   bool? get isConnected => connection != null && connection!.isConnected;

//   // Define some variabes, which will be required later
//   List<BluetoothDevice> devicesList = [];
//   BluetoothDevice? device;
//   String _messageBuffer = '';
//   bool connected = false;
//   bool isVisible = true;
//   bool isVisibleHome = false;
//   bool isButtonUnavailable = false;
//   //*slider & switch
//   int sliderValue = 0;
//   bool sliderEnable = false;
//   bool sliderEnablePlay = false;
//   bool switchEnable = false;
//   bool switchEnablePlay = false;

//   //! power
//   bool power = false;

//   powerOffOn() {
//     if (power == false) {
//       message9();
//     } else {
//       message0();
//     }
//   }

//   void message9() async {
//     sendMessageToBluetooth("9\n");
//     setState(() {
//       deviceState = 1;
//       power = true; // device on
//     });
//   }

//   void message0() async {
//     sendOffMessageToBluetooth("0\n");
//     setState(() {
//       deviceState = 1;
//       power = false; // device on
//     });
//   }

//   //!message lamp led
//   //*lamp
//   bool lamp = false;
//   lampOffOn() {
//     if (lamp == false) {
//       messageA();
//     } else {
//       messageB();
//     }
//   }

//   void messageA() async {
//     sendMessageToBluetooth("a\n");
//     setState(() {
//       deviceState = 1;
//       power = true; // device on
//     });
//   }

//   void messageB() async {
//     sendMessageToBluetooth("b\n");
//     setState(() {
//       deviceState = 1;
//       power = true; // device on
//     });
//   }

//   //! Play Paused
//   bool play = false;
//   playPaused() {
//     if (play == false) {
//       message3();
//     } else {
//       message4();
//     }
//   }

//   void message3() async {
//     sendOffMessageToBluetooth("3\n");
//     setState(() {
//       deviceState = 1;
//       play = true; // device on
//     });
//   }

//   void message4() async {
//     sendOffMessageToBluetooth("4\n");
//     setState(() {
//       deviceState = 1;
//       play = false; // device on
//     });
//   }

//   //!streaming
//   mySwitch() => (value) async {
//         setState(() {
//           deviceState = 1;
//           sliderEnable = value;
//           switchEnable = value;
//         });
//         sendMessageToBluetooth("2");
//       };

//   //!retry
//   bool retry = false;

//   retryMusic() {
//     if (retry == false) {
//       sendOffMessageToBluetooth("6\n");
//       setState(() {
//         retry = true;
//       });
//     } else {
//       sendOffMessageToBluetooth("7\n");
//       setState(() {
//         retry = false;
//       });
//     }
//   }

//   //?! delay
//   bool isSwitchEnable = false;
//   delay() {
//     Future.delayed(Duration(seconds: 5));
//   }

//   Future<void> sendOnnMessageToBluetooth(String message) async {
//     setState(() {
//       isSwitchEnable = true;
//     });
//     sendResetMessage('8');
//     await delay();
//     Uint8List data = utf8.encode(message) as Uint8List;
//     connection?.output.add(data);
//     await connection?.output.allSent;
//     setState(() {
//       isSwitchEnable = false;
//       switchEnablePlay = false;
//     });
//   }

//   sendResetMessage(String message) async {
//     Uint8List data = utf8.encode(message) as Uint8List;
//     connection?.output.add(data);
//     await connection?.output.allSent;
//   }

//   Future<void> getPairedDevices() async {
//     List<BluetoothDevice> devices = [];

//     // To get the list of paired devices
//     try {
//       devices = await bluetooth.getBondedDevices();
//     } on PlatformException {
//       debugPrint("Error");
//     }

//     // It is an error to call [setState] unless [mounted] is true.
//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       devicesList = devices;
//     });
//   }

//   //!previous && next
//   sendNext() {
//     sendOffMessageToBluetooth('n\n');
//   }

//   sendPrevious() {
//     sendOffMessageToBluetooth('p\n');
//   }

//   //!List dropdown anti malas
//   List<DropdownMenuItem<_Message>> getListMusic() {
//     List<DropdownMenuItem<_Message>> music = [];
//     if (messages.isEmpty) {
//       music.add(const DropdownMenuItem(
//         child: Text(
//           'Select music',
//           style: TextStyle(color: Colors.white),
//         ),
//       ));
//     } else {
//       var mpFiles = messages
//           .where((message) =>
//               message.text.trim().contains('.mp3') ||
//               message.text.trim().contains('.wav'))
//           .toList();
//       for (var message in mpFiles) {
//         music.add(DropdownMenuItem(
//           value: message,
//           child: Text(message.text.trim()),
//         ));
//       }
//     }
//     return music;
//   }

//   sendConvert() {
//     Uint8List json =
//         utf8.encode('/${message?.text.trim().trim()}\n') as Uint8List;
//     connection?.output.add(json);
//     connection?.output.allSent;
//   }

//   List<DropdownMenuItem<BluetoothDevice>> getDeviceItems() {
//     List<DropdownMenuItem<BluetoothDevice>> items = [];
//     if (devicesList.isEmpty) {
//       items.add(const DropdownMenuItem(
//         child: Text(
//           'Select a Device',
//           style: TextStyle(color: Colors.white),
//         ),
//       ));
//     } else {
//       for (var device in devicesList) {
//         items.add(DropdownMenuItem(
//           value: device,
//           child: Text(device.name!),
//         ));
//       }
//     }
//     return items;
//   }

//   // Method to connect to bluetooth
//   void connect() async {
//     setState(() {
//       isButtonUnavailable = true;
//     });
//     if (device == null) {
//       show('No device selected');
//     } else {
//       // if (connection == null || (connection != null && !isConnected!)) {
//       if (!isConnected!) {
//         await BluetoothConnection.toAddress(device?.address).then((conn) {
//           connection = conn;
//           setState(() {
//             connected = true;
//             isVisible = false;
//             isVisibleHome = true;
//           });

//           connection?.input?.listen(onDataReceived).onDone(() {
//             if (isDisconnecting) {
//               debugPrint('Disconnecting locally!');
//             } else {
//               debugPrint('Diconnected remotely!');
//             }
//             if (mounted) {
//               setState(() {});
//             }
//           });
//         }).catchError((error) {
//           debugPrint('Cannot connect, exception occurred');
//           debugPrint(error);
//         });
//         show('Device connected');
//         setState(() => isButtonUnavailable = false);
//       }
//     }
//   }

//   List<DropdownMenuItem<_Message>> getLogInfo() {
//     List<DropdownMenuItem<_Message>> music = [];
//     if (messages.isEmpty) {
//       music.add(const DropdownMenuItem(
//         child: Text(
//           'status',
//           style: TextStyle(color: Colors.black),
//         ),
//       ));
//     } else {
//       for (var message in messages) {
//         music.add(DropdownMenuItem(
//           value: message,
//           child: Text("• ${message.text.trim()}"),
//         ));
//       }
//     }
//     return music;
//   }

//   //! Loading dialog kacau
//   bool switchDialog = false;

//   void openLoading(BuildContext context, [bool mounted = true]) async {
//     if (switchDialog) {
//       showDialog(
//           barrierDismissible: false,
//           context: context,
//           builder: (_) {
//             return Dialog(
//               // The background color
//               backgroundColor: bgColor,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 20),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: const [
//                     // The loading indicator
//                     CircularProgressIndicator(),
//                     SizedBox(
//                       height: 40,
//                     ),
//                     // Some text
//                     Text('Loading...')
//                   ],
//                 ),
//               ),
//             );
//           });
//       await Future.delayed(const Duration(seconds: 2));
//       if (!mounted) return;
//       Navigator.of(context).pop();
//     }
//   }

//   //!Malas
//   sliderControl(newVol) {
//     setState(() {
//       currentValue = newVol;
//     });
//     PerfectVolumeControl.setVolume(currentValue);
//     sendVolume('$currentValue');
//     debugPrint('$currentValue');
//   }

//   sliderControlPlay(newVol) {
//     setState(() {
//       playMusic = newVol;
//     });
//     PerfectVolumeControl.setVolume(playMusic);
//     sendVolume('$playMusic');
//     debugPrint('$playMusic');
//   }
//   //!

//   void disconnect() async {
//     setState(() {
//       isButtonUnavailable = true;
//       deviceState = 0;
//       isVisibleHome = false;
//       isVisible = true;
//     });

//     await connection?.close();
//     show('Device disconnected');
//     if (!connection!.isConnected) {
//       setState(() {
//         connected = false;
//         isButtonUnavailable = false;
//       });
//     }
//   }

//   Future show(
//     String message, {
//     Duration duration = const Duration(seconds: 3),
//   }) async {
//     await Future.delayed(const Duration(milliseconds: 100));
//   }

//   ///!json

//   String jsonString = '';
//   String value = '';
//   String ssid = '';
//   String pass = '';
//   String link = '';
//   final valueController = TextEditingController();
//   final ssidController = TextEditingController();
//   final passController = TextEditingController();
//   final linkController = TextEditingController();


//   //? delete
//   void convertInputToJson() {
//     value = value.replaceAll(new RegExp(r'\s'), "");
//     jsonString = '{"DLT":"$value"}';
//   }

//   //?upload
//   void convertWifi() {
//     ssid = ssid.replaceAll(new RegExp(r'\s'), "");
//     pass = pass.replaceAll(new RegExp(r'\s'), "");
//     link = link.replaceAll(new RegExp(r'\s'), "");
//     jsonString = '{"S":"$ssid"},{"PW":"$pass"},{"f":"$link"}';
//   }

//   void sendJsonWifi() {
//     ssid = ssidController.text;
//     pass = passController.text;
//     link = linkController.text;
//     convertWifi();
//     Navigator.pop(context);
//     sendJsonString(jsonString);
//     ssidController.clear();
//     passController.clear();
//     linkController.clear();
//     setState(() {});
//   }

//   void sendJsonString(String jsonString) async {
//     Uint8List json = utf8.encode(jsonString) as Uint8List;
//     connection?.output.add(json);
//     await connection?.output.allSent;
//   }

//   void sendJsonDelete() {
//     value = valueController.text;
//     convertInputToJson();
//     Navigator.pop(context);
//     sendJsonString(jsonString);
//     valueController.clear();
//   }

//   void onDataReceived(Uint8List data) {
//     // Allocate buffer for parsed data
//     int backspacesCounter = 0;
//     data.forEach((byte) {
//       if (byte == 8 || byte == 127) {
//         backspacesCounter++;
//       }
//     });
//     Uint8List buffer = Uint8List(data.length - backspacesCounter);
//     int bufferIndex = buffer.length;
//     setState(() {
//       notif = true;
//     });

//     // Apply backspace control character
//     backspacesCounter = 0;
//     for (int i = data.length - 1; i >= 0; i--) {
//       if (data[i] == 8 || data[i] == 127) {
//         backspacesCounter++;
//       } else {
//         if (backspacesCounter > 0) {
//           backspacesCounter--;
//         } else {
//           buffer[--bufferIndex] = data[i];
//         }
//       }
//     }

//     // Create message if there is new line character
//     String dataString = String.fromCharCodes(buffer);
//     int index = buffer.indexOf(13);
//     if (~index != 0) {
//       setState(() {
//         messages.add(
//           _Message(
//             1,
//             backspacesCounter > 0
//                 ? _messageBuffer.substring(
//                     0, _messageBuffer.length - backspacesCounter)
//                 : _messageBuffer + dataString.substring(0, index),
//           ),
//         );
//         _messageBuffer = dataString.substring(index);
//       });
//     } else {
//       _messageBuffer = (backspacesCounter > 0
//           ? _messageBuffer.substring(
//               0, _messageBuffer.length - backspacesCounter)
//           : _messageBuffer + dataString);
//     }
//   }

//   //! alert dialog

//         Future showAlert() => showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) => AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//             backgroundColor: bgColor,
//             title: Text("Upload New Song"),
//             content: Container(
//                 height: MediaQuery.of(context).size.width / 1.5,
//                 width: MediaQuery.of(context).size.width / 1.5,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     TextFormField(
//                       style: GoogleFonts.inter(
//                           textStyle: TextStyle(color: textColor)),
//                       decoration: InputDecoration(
//                         isDense: true,
//                         filled: true,
//                         fillColor: baseColor12,
//                         enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: baseColor)),
//                         labelText: 'SSID',
//                         hintText: 'Insert..',
//                         suffixIcon: Icon(Icons.wifi),
//                       ),
//                       controller: ssidController,
//                       onChanged: (value) {
//                         jsonString = value;
//                       },
//                     ),
//                     TextFormField(
//                       style: GoogleFonts.inter(
//                           textStyle: TextStyle(color: textColor)),
//                       decoration: InputDecoration(
//                         isDense: true,
//                         filled: true,
//                         fillColor: baseColor12,
//                         enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: baseColor)),
//                         labelText: 'Password',
//                         hintText: 'Insert..',
//                         suffixIcon: Icon(Icons.password_rounded),
//                       ),
//                       controller: passController,
//                       onChanged: (value) {
//                         jsonString = value;
//                       },
//                     ),
//                     TextFormField(
//                       style: GoogleFonts.inter(
//                           textStyle: TextStyle(color: textColor)),
//                       decoration: InputDecoration(
//                         isDense: true,
//                         filled: true,
//                         fillColor: baseColor12,
//                         enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: baseColor)),
//                         labelText: 'Link',
//                         hintText: 'Insert..',
//                         suffixIcon: Icon(Icons.link),
//                       ),
//                       controller: linkController,
//                       onChanged: (value) {
//                         jsonString = value;
//                       },
//                     ),
//                   ],
//                 )),
//             actions: <Widget>[
//               ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: baseColor,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4)),
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       Navigator.pop(context);
//                     });
//                     ssidController.clear();
//                     passController.clear();
//                     linkController.clear();
//                   },
//                   child: const Icon(Icons.clear)),
//               ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: baseColor,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4)),
//                   ),
//                   onPressed: sendJsonWifi,
//                   child: const Icon(Icons.subdirectory_arrow_left)),
//             ],
//           ));

//   Future showAlertDelete() => showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) => AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//             backgroundColor: bgColor,
//             title: Text("Delete File Music"),
//             content: Container(
//                 height: MediaQuery.of(context).size.width / 7,
//                 width: MediaQuery.of(context).size.width / 1.5,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     TextFormField(
//                       style: GoogleFonts.inter(
//                           textStyle: TextStyle(color: textColor)),
//                       decoration: InputDecoration(
//                         enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: baseColor)),
//                         isDense: true,
//                         filled: true,
//                         fillColor: baseColor12,
//                         labelText: 'Delete',
//                         hintText: 'Insert file name..',
//                         suffixIcon: Icon(Icons.delete),
//                       ),
//                       controller: valueController,
//                       onChanged: (value) {
//                         jsonString = value;
//                       },
//                     ),
//                   ],
//                 )),
//             actions: <Widget>[
//               ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: baseColor,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4)),
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       Navigator.pop(context);
//                     });
//                     valueController.clear();
//                   },
//                   child: const Icon(Icons.clear)),
//               ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: baseColor,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4)),
//                   ),
//                   onPressed: sendJsonDelete,
//                   child: const Icon(Icons.subdirectory_arrow_left)),
//             ],
//           ));

//   bool notif = false;

//   Future showAlertMail() => showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) => AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//             backgroundColor: bgColor,
//             title: Text("History Log"),
//             content: Container(
//                 height: MediaQuery.of(context).size.width / 2,
//                 width: MediaQuery.of(context).size.width / 1.2,
//                 child: ListView(
//                   children: getLogInfo(),
//                 )),
//             actions: <Widget>[
//               ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: baseColor,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4)),
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       Navigator.pop(context);
//                     });
//                     valueController.clear();
//                   },
//                   child: const Icon(Icons.clear)),
//             ],
//           ));

//   void sendVolume(String value) async {
//     Uint8List data = utf8.encode("$value\n") as Uint8List;
//     // PerfectVolumeControl.setVolume(value.);
//     connection?.output.add(data);
//     await connection?.output.allSent;
//     debugPrint(value);
//   }

//   void sendDiscreet(String discreet) async {
//     Uint8List data = utf8.encode("$discreet\n") as Uint8List;
//     // PerfectVolumeControl.setVolume(value.);
//     connection?.output.add(data);
//     await connection?.output.allSent;
//   }

//   void sendStream(String stream) async {
//     Uint8List data = utf8.encode("$stream\n") as Uint8List;
//     // PerfectVolumeControl.setVolume(value.);
//     connection?.output.add(data);
//     await connection?.output.allSent;
//   }

//   sendMessageToBluetooth(String message) async {
//     sendResetMessage('8\n');
//     await Future.delayed(Duration(seconds: 1));
//     Uint8List data = utf8.encode(message) as Uint8List;
//     connection?.output.add(data);
//     await connection?.output.allSent;
//     show('Device Turned On');
//     if (mounted) {
//       setState(() {
//         deviceState = 1;
//         switch1 = true;
//         btnVisible = true;
//       });
//     }
//   }

//   sendOffMessageToBluetooth(String message) async {
//     Uint8List data = utf8.encode(message) as Uint8List;
//     connection?.output.add(data);
//     await connection?.output.allSent;
//   }

//   sendListMessage(String message) async {
//     Uint8List data = utf8.encode(message) as Uint8List;
//     await Future.delayed(Duration(seconds: 4));
//     connection?.output.add(data);
//     await connection?.output.allSent;
//   }
// }
// // @override
// // Widget build(BuildContext context) => widget.build(context, this);
