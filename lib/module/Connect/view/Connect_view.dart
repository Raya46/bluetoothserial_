import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isoja_application/core.dart';
import 'package:isoja_application/module/Connect/widget/BluetoothCon.dart';
import '../controller/Connect_controller.dart';

class ConnectView extends StatefulWidget {
  const ConnectView({Key? key}) : super(key: key);

  Widget build(context, ConnectController controller) {
    controller.view = this;

    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;
      final width = constraints.maxWidth;
      return Scaffold(
        backgroundColor: controller.bgColor,
        appBar: AppBar(
          toolbarHeight: (constraints.maxHeight * 0.1),
          backgroundColor: controller.baseColor,
          title: Text(
            "ISOJA",
            style: GoogleFonts.michroma(
                textStyle: TextStyle(fontSize: 32),
                fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.bluetooth),
              iconSize: (width * 0.1),
              tooltip: "Save Todo and Retrun to List",
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
            )
          ],
        ),
        body: Container(
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: (width * 0.04)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text(
                            "Enable Bluetooth",
                            style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                    color: controller.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Container(
                          child: Transform.scale(
                            scale: 1.3,
                            child: Switch(
                              value: controller.bluetoothState.isEnabled,
                              // value: true,
                              onChanged: (bool value) {
                                future() async {
                                  if (value) {
                                    await FlutterBluetoothSerial.instance
                                        .requestEnable();
                                  } else {
                                    await FlutterBluetoothSerial.instance
                                        .requestDisable();
                                  }
                                  await controller.getPairedDevices();
                                  controller.isButtonUnavailable = false;

                                  if (controller.connected) {
                                    controller.disconnect();
                                  }
                                }

                                future().then((_) {
                                  controller.setState(() {});
                                });
                              },
                              activeColor: controller.baseColor,
                              inactiveTrackColor: Color.fromRGBO(78, 78, 78, 1),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Text("Paired Device",
                                    style: GoogleFonts.inter(
                                        textStyle: TextStyle(
                                            color: controller.textColor,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold))),
                              ),
                              Container(
                                child: RawMaterialButton(
                                  onPressed: () async {
                                    await controller
                                        .getPairedDevices()
                                        .then((_) {
                                      controller.show('Device list refreshed');
                                    });
                                  },
                                  elevation: 3.0,
                                  fillColor: controller.baseColor,
                                  child: Icon(
                                    Icons.refresh,
                                    color: controller.bgColor,
                                    size: (constraints.maxWidth * 0.1),
                                  ),
                                  padding: EdgeInsets.all(5.0),
                                  shape: CircleBorder(),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: width * 0.6,
                                // margin: EdgeInsets.symmetric(horizontal: (constraints.maxHeight * 0.1)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                    color: controller.baseColor,
                                    borderRadius: BorderRadius.circular(14)),
                                child: DropdownButton(
                                  underline: Container(
                                    height: 0,
                                  ),
                                  hint: Text(
                                    "Select a Device",
                                    style: TextStyle(color: controller.bgColor),
                                  ),
                                  isExpanded: true,
                                  style: GoogleFonts.inter(
                                      textStyle: TextStyle(
                                          color: controller.bgColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                  items: controller.getDeviceItems(),
                                  onChanged: (value) => controller.setState(
                                      () => controller.device = value!),
                                  value: controller.devicesList.isNotEmpty
                                      ? controller.device
                                      : null,
                                  icon: Icon(Icons.arrow_drop_down_rounded),
                                  iconEnabledColor: controller.bgColor,
                                  iconSize: 42,
                                  dropdownColor: controller.baseColor,
                                ),
                              ),
                              Container(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size((width * 0.3),
                                        (constraints.maxHeight * 0.07)),
                                    backgroundColor: controller.baseColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                  ),
                                  onPressed: controller.isButtonUnavailable
                                      ? null
                                      : controller.connected
                                          ? controller.disconnect
                                          : controller.connect,
                                  child: Text(
                                    controller.connected
                                        ? 'Disconnect'
                                        : 'Connect',
                                    style: GoogleFonts.inter(
                                        textStyle: TextStyle(
                                            color: controller.bgColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                    // style: GoogleFonts.inter(),
                                  ),
                                ),
                              )
                            ],
                          )
                        ]),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Row(children: [
                    ElevatedButton(
                      onPressed: () async {
                        await controller.sendOnMessageToBluetooth("on");
                      },
                      child: const Text("ON"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.sendOffMessageToBluetooth("off");
                      },
                      child: const Text("OFF"),
                    ),
                    Switch(
                        value: controller.abdul,
                        onChanged: (value) {
                          controller.setState(() {
                            controller.abdul = value;
                          });
                          if (controller.abdul == true) {
                            controller.sendOnMessageToBluetooth('on');
                          } else if (controller.abdul == false) {
                            controller.sendOffMessageToBluetooth('off');
                          }
                        })
                  ]),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  State<ConnectView> createState() => ConnectController();
}
