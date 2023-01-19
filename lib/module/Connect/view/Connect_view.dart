import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isoja_application/core.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import '../controller/Connect_controller.dart';

class ConnectView extends StatefulWidget {
  const ConnectView({Key? key}) : super(key: key);

  Widget build(context, ConnectController controller) {
    controller.view = this;

    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;
      final width = constraints.maxWidth;
      if (controller.connected == true ) {
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
              ),
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
                                inactiveTrackColor:
                                    Color.fromRGBO(78, 78, 78, 1),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: EdgeInsets.only(bottom: (height / 20)),
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
                                        controller
                                            .show('Device list refreshed');
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
                                onChanged: (value) => controller
                                    .setState(() => controller.device = value!),
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
                              margin: EdgeInsets.symmetric(
                                  horizontal: (constraints.maxWidth * 0.1)),
                              child: Center(
                                child: Text(
                                  "Turn On the Bluetooth Connnection of this device",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                      textStyle: TextStyle(
                                          color: controller.subText,
                                          fontSize: 14)),
                                ),
                              ),
                            ),
                            Container(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size((width / 1.2),
                                      (constraints.maxHeight * 0.07)),
                                  backgroundColor: controller.baseColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)),
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
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  // style: GoogleFonts.inter(),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                  Expanded(child: Container(), flex: 3)
                ],
              ),
            ),
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: controller.bgColor,
          appBar: AppBar(
            toolbarHeight: (constraints.maxHeight * 0.1),
            backgroundColor: controller.baseColor,
            title: Text(
              "ISOJA",
              style: GoogleFonts.michroma(
                  textStyle: TextStyle(fontSize: 32),
                  fontWeight: FontWeight.normal),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.power_settings_new),
                iconSize: (width * 0.1),
                tooltip: "Save Todo and Retrun to List",
                onPressed: controller.isButtonUnavailable
                    ? null
                    : controller.connected
                        ? controller.disconnect
                        : controller.connect,
              )
            ],
          ),
          body: Container(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "DN : ${controller.device?.name}",
                            textAlign: TextAlign.start,
                            style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                    color: controller.textColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.baseColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: controller.isButtonUnavailable
                                  ? null
                                  : controller.connected
                                      ? controller.disconnect
                                      : controller.connect,
                              child: Icon(Icons.close_rounded))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Column(
                      children: [
                        Expanded(
                            child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: (constraints.maxWidth * 0.03)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              color: controller.baseColor12,
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        bottom: (constraints.maxWidth * 0.04)),
                                    color: controller.baseColor,
                                    height: 20,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal:
                                              (constraints.maxWidth * 0.05),
                                        ),
                                        child: Text(
                                          "Settings",
                                          style: GoogleFonts.inter(
                                              textStyle: TextStyle(
                                                  color: controller.textColor,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: (constraints.maxWidth * 0.01)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            sliderNoiseWidget(
                                                context, controller),
                                            sliderMusicWidget(
                                                context, controller)
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                      flex: 8,
                      child: Column(children: [
                        Container(
                          margin: EdgeInsets.only(bottom: width * 0.05),
                          child: Text(
                            "Play Music",
                            textAlign: TextAlign.start,
                            style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                    color: controller.baseColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: width / 1.3,
                                height: width / 7,
                                color: controller.baseColor12,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("song 1"),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon:
                                                Icon(Icons.play_arrow_rounded),
                                            onPressed: () {},
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ])),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Container(
                        width: (width / 1.3),
                        height: (height * 0.065),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.baseColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: controller.showAlert,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload, color: controller.bgColor),
                              Text(
                                "Upload New Song",
                                style: GoogleFonts.inter(
                                    textStyle: TextStyle(
                                        color: controller.bgColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  //!Widget slider Noise
  Widget sliderNoiseWidget(context, ConnectController controller) =>
      LayoutBuilder(builder: (context, contraints) {
        final width = contraints.maxWidth;
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: (width * 0.05)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Noise",
                      style: GoogleFonts.inter(
                          textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: controller.textColor))),
                  Transform.scale(
                    scale: 1.3,
                    child: Switch(
                      inactiveThumbColor: controller.bgColor,
                      value: controller.switchEnable,
                      onChanged: (bool value) {
                        controller.setState(() {
                          controller.sliderEnable = value;
                          controller.switchEnable = value;
                        });
                      },
                      activeColor: controller.baseColor,
                      inactiveTrackColor: Color.fromRGBO(78, 78, 78, 1),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.multitrack_audio,
                  color: controller.baseColor,
                  size: 32,
                ),
                Container(
                  width: width / 1.2,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      showValueIndicator: ShowValueIndicator.never,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 10.0),
                      trackHeight: 4,
                      disabledActiveTrackColor: controller.bgColor,
                      disabledThumbColor: controller.bgColor,
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 20.0),
                    ),
                    child: Slider(
                      value: controller.currentValue,
                      min: 0,
                      max: 1.0,
                      divisions: 10,
                      activeColor: controller.baseColor,
                      inactiveColor: controller.bgColor,
                      onChanged: controller.sliderEnable == true
                          ? controller.sliderControl
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      });

  //!Widget slider music
  Widget sliderMusicWidget(context, ConnectController controller) =>
      LayoutBuilder(builder: (context, contraints) {
        final width = contraints.maxWidth;
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: (width * 0.05)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Play Music",
                      style: GoogleFonts.inter(
                          textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: controller.textColor))),
                  Transform.scale(
                    scale: 1.3,
                    child: Switch(
                      inactiveThumbColor: controller.bgColor,
                      value: controller.switchEnablePlay,
                      onChanged: (bool value) {
                        controller.setState(() {
                          controller.sliderEnablePlay = value;
                          controller.switchEnablePlay = value;
                        });
                      },
                      activeColor: controller.baseColor,
                      inactiveTrackColor: Color.fromRGBO(78, 78, 78, 1),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.audiotrack,
                  color: controller.baseColor,
                  size: 32,
                ),
                Container(
                  width: width / 1.2,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      showValueIndicator: ShowValueIndicator.never,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 10.0),
                      trackHeight: 4,
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 20.0),
                      disabledActiveTrackColor: controller.bgColor,
                      disabledThumbColor: controller.bgColor,
                    ),
                    child: Slider(
                      value: controller.discreet,
                      min: 0,
                      max: 1.0,
                      divisions: 10,
                      activeColor: controller.baseColor,
                      inactiveColor: controller.bgColor,
                      onChanged: controller.sliderEnablePlay                  == true
                          ? controller.sliderControlDis
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      });

  @override
  State<ConnectView> createState() => ConnectController();
}
//
