import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isoja_application/state_util.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import '../view/Connect_view.dart';

class ConnectController extends State<ConnectView> implements MvcController {
  static late ConnectController instance;
  late ConnectView view;
  double currentValue = 0.0;
  double discreet = 0.0;
  double stream = 0.0;

  @override
  void initState() {
    instance = this;
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        bluetoothState = state;
      });
    });

    deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        bluetoothState = state;
        if (bluetoothState == BluetoothState.STATE_OFF) {
          isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected!) {
      isDisconnecting = true;
      connection?.dispose();
      // connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.build(context, this);
  BluetoothState bluetoothState = BluetoothState.UNKNOWN;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  late int deviceState;
  int indexNum = 0;
  bool isDisconnecting = false;
  bool abdul = false;

  //*Color//
  final Color baseColor = Color.fromRGBO(42, 50, 75, 1);
  final Color baseColor12 = Color.fromRGBO(42, 50, 75, 0.13);
  final Color textColor = Color.fromRGBO(42, 50, 75, 0.8);
  final Color bgColor = Color.fromRGBO(199, 204, 219, 1);
  final Color subText = Color.fromRGBO(0, 0, 0, 0.56);
  final Color disableBaseColor = Color.fromRGBO(216, 226, 220, 1);
  final Color disableBaseColor12 = Color.fromRGBO(0, 0, 0, 0.56);
  final Color fieldBgColor = Color.fromRGBO(221, 225, 234, 1);

  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      // return true;
    } else {
      await getPairedDevices();
    }
    // return false;
  }

  // To track whether the device is still connected to Bluetooth
  // bool? get isConnected => connection?.isConnected;
  bool? get isConnected => connection != null && connection!.isConnected;

  // Define some variabes, which will be required later
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? device;
  bool connected = false;
  bool isVisible = true;
  bool isVisibleHome = false;
  bool isButtonUnavailable = false;
  int sliderValue = 0;
  bool sliderEnable = true;
  bool sliderEnablePlay = true;
  bool switchEnable = true;
  bool switchEnablePlay = true;

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      debugPrint("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    setState(() {
      devicesList = devices;
    });
  }

  List<DropdownMenuItem<BluetoothDevice>> getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (devicesList.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text(
          'Select a Device',
          style: TextStyle(color: Colors.white),
        ),
      ));
    } else {
      for (var device in devicesList) {
        items.add(DropdownMenuItem(
          value: device,
          child: Text(device.name!),
        ));
      }
    }
    return items;
  }

  // Method to connect to bluetooth
  void connect() async {
    setState(() {
      isButtonUnavailable = true;
    });
    if (device == null) {
      show('No device selected');
    } else {
      // if (connection == null || (connection != null && !isConnected!)) {
      if (!isConnected!) {
        await BluetoothConnection.toAddress(device?.address).then((conn) {
          debugPrint('Connected to the device');
          connection = conn;
          setState(() {
            connected = true;
            isVisible = false;
            isVisibleHome = true;
          });

          connection?.input?.listen(null).onDone(() {
            if (isDisconnecting) {
              debugPrint('Disconnecting locally!');
            } else {
              debugPrint('Disconnected remotely!');
            }
            if (mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          debugPrint('Cannot connect, exception occurred');
          debugPrint(error);
        });
        show('Device connected');
        setState(() => isButtonUnavailable = false);
      }
    }
  }

  //!Malas
  sliderControl(newVol) {
    setState(() {
      currentValue = newVol;
    });
    PerfectVolumeControl.setVolume(currentValue);
    sendVolume('$currentValue');
    debugPrint('$currentValue');
  }

  sliderControlDis(newVol) {
    setState(() {
      discreet = newVol;
    });
    PerfectVolumeControl.setVolume(discreet);
    sendVolume('$discreet');
    debugPrint('$discreet');
  }
  //!

  void disconnect() async {
    setState(() {
      isButtonUnavailable = true;
      deviceState = 0;
      isVisibleHome = false;
      isVisible = true;
    });

    await connection?.close();
    show('Device disconnected');
    if (!connection!.isConnected) {
      setState(() {
        connected = false;
        isButtonUnavailable = false;
      });
    }
  }

  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  ///!json

  final keyController = TextEditingController();
  final valueController = TextEditingController();
  String key = '';
  String value = '';
  String jsonString = '';

  void sendJsonToEsp() {
    key = keyController.text;
    value = valueController.text;
    convertInputToJson();
    Navigator.pop(context);
    sendJsonString(jsonString);
    keyController.clear();
    valueController.clear();
  }

  void sendJsonString(String jsonString) async {
    Uint8List json = utf8.encode(jsonString) as Uint8List;
    connection?.output.add(json);
    await connection?.output.allSent;
  }

  void convertInputToJson() {
    key = key.replaceAll(new RegExp(r'\s'), "");
    value = value.replaceAll(new RegExp(r'\s'), "");
    jsonString = '{"$key":"$value"}';
  }

  Future showAlert() => showDialog(
    barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: bgColor,
            title: Text("Upload New Song"),
            content: Container(
                height: MediaQuery.of(context).size.width / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextFormField(
                      style: GoogleFonts.inter(
                          textStyle: TextStyle(color: textColor)),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: baseColor12,
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 10, color: baseColor)),
                        labelText: 'SSID',
                        hintText: 'Insert..',
                        suffixIcon: Icon(Icons.wifi),
                      ),
                      controller: keyController,
                      onChanged: (value) {
                        jsonString = value;
                      },
                    ),
                    TextFormField(
                      style: GoogleFonts.inter(
                          textStyle: TextStyle(color: textColor)),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: baseColor12,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 3, color: baseColor),
                        ),
                        labelText: 'Password',
                        hintText: 'Insert..',
                        suffixIcon: Icon(Icons.password_rounded),
                      ),
                      controller: valueController,
                      onChanged: (value) {
                        jsonString = value;
                      },
                    ),
                  ],
                )),
            actions: <Widget>[
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: baseColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                    valueController.clear();
                    keyController.clear();
                  },
                  child: const Icon(Icons.clear)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: baseColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: sendJsonToEsp,
                  child: const Icon(Icons.subdirectory_arrow_left)),
            ],
          ));

  void sendVolume(String value) async {
    Uint8List data = utf8.encode("$value\n") as Uint8List;
    // PerfectVolumeControl.setVolume(value.);
    connection?.output.add(data);
    await connection?.output.allSent;
    debugPrint(value);
  }

  void sendDiscreet(String discreet) async {
    Uint8List data = utf8.encode("$discreet\n") as Uint8List;
    // PerfectVolumeControl.setVolume(value.);
    connection?.output.add(data);
    await connection?.output.allSent;
  }

  void sendStream(String stream) async {
    Uint8List data = utf8.encode("$stream\n") as Uint8List;
    // PerfectVolumeControl.setVolume(value.);
    connection?.output.add(data);
    await connection?.output.allSent;
  }

  sendOnMessageToBluetooth(String message) async {
    Uint8List data = utf8.encode(message) as Uint8List;
    connection?.output.add(data);
    await connection?.output.allSent;
    show('Device Turned On');
    if (mounted) {
      setState(() {
        deviceState = 1; // device on
      });
    }
  }

  sendOffMessageToBluetooth(String message) async {
    Uint8List data = utf8.encode(message) as Uint8List;
    connection?.output.add(data);
    await connection?.output.allSent;
    show('Device Turned On');
    if (mounted) {
      setState(() {
        deviceState = -1; // device on
      });
    }
  }
}



  // @override
  // Widget build(BuildContext context) => widget.build(context, this);

