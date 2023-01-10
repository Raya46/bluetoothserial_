import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:isoja_application/state_util.dart';
import '../view/Connect_view.dart';

  // final Color baseColor = Color.fromRGBO(42, 50, 75, 1);
  // final Color textColor = Color.fromRGBO(42, 50, 75, 0.8);
  // final Color bgColor = Color.fromRGBO(199, 204, 219, 1);
  // final Color subText = Color.fromRGBO(0, 0, 0, 0.56);
class ConnectController extends State<ConnectView> implements MvcController {
  static late ConnectController instance;
  late ConnectView view;

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
  final Color textColor = Color.fromRGBO(42, 50, 75, 0.8);
  final Color bgColor = Color.fromRGBO(199, 204, 219, 1);
  final Color subText = Color.fromRGBO(0, 0, 0, 0.56);

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
  bool isButtonUnavailable = false;

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
            // isVisible = false;
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

  // Method to disconnect bluetooth
  void disconnect() async {
    Navigator.pop(context);

    setState(() {
      isButtonUnavailable = true;
      deviceState = 0;
      // isVisible = true;
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
        deviceState = 1; // device on
      });
    }
  }

}


  // @override
  // Widget build(BuildContext context) => widget.build(context, this);

