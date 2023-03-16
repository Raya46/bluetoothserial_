// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:isoja_application/global/color.dart';
import 'package:isoja_application/helper/BluetoothManager.dart';

class FormPage extends StatefulWidget {
  final BluetoothDevice device;

  const FormPage({
    Key? key,
    required this.device,
  }) : super(key: key);
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  String jsonString = '';
  String ssid = '';
  String pass = '';
  String link = '';
  final ssidController = TextEditingController();
  final passController = TextEditingController();
  final linkController = TextEditingController();
  BluetoothConnection? connection;

@override
   void initState() {
    super.initState();
  }

  void openLoading(BuildContext context, [bool mounted = true]) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            // The background color
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // The loading indicator
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  // Some text
                  Text('Loading...')
                ],
              ),
            ),
          );
        });
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void convertWifi() {
    ssid = ssid.replaceAll(new RegExp(r'\s'), "");
    pass = pass.replaceAll(new RegExp(r'\s'), "");
    link = link.replaceAll(new RegExp(r'\s'), "");
    jsonString = '{"S":"$ssid"},{"PW":"$pass"},{"F":"$link"}';
  }

  void sendWifi() async {
    ssid = ssidController.text;
    pass = passController.text;
    link = linkController.text;
    convertWifi();
    await BluetoothManager.sendData(jsonString);
    ssidController.clear();
    passController.clear();
    linkController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            toolbarHeight: (height * 0.1),
            backgroundColor: base,
            title: const Text("Submit Sound"),
            centerTitle: true,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            height: 50,
            margin: const EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: textColor,
              ),
              onPressed: () {
                sendWifi();
              },
              child: Center(child: const Text("Submit")),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: fieldBgColor,
                        borderRadius: BorderRadius.all(Radius.circular(13))),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          value = jsonString.trim();
                        });
                      },
                      controller: ssidController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Container(
                              width: width * 0.13,
                              margin: const EdgeInsets.only(
                                right: 10.0,
                              ),
                              decoration: BoxDecoration(
                                  color: textColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(13))),
                              child: Icon(Icons.wifi,
                                  color: Color.fromARGB(255, 199, 199, 199))),
                          hintText: "Enter Your Wifi Name"),
                    ),
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: fieldBgColor,
                        borderRadius: BorderRadius.all(Radius.circular(13))),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          value = jsonString.trim();
                        });
                      },
                      controller: passController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Container(
                              width: width * 0.13,
                              margin: const EdgeInsets.only(
                                right: 10.0,
                              ),
                              decoration: BoxDecoration(
                                  color: textColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(13))),
                              child: Icon(Icons.lock,
                                  color: Color.fromARGB(255, 199, 199, 199))),
                          hintText: "Enter Your Wifi Password"),
                    ),
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: fieldBgColor,
                        borderRadius: BorderRadius.all(Radius.circular(13))),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          value = jsonString.trim();
                        });
                      },
                      controller: linkController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Container(
                              width: width * 0.13,
                              margin: const EdgeInsets.only(
                                right: 10.0,
                              ),
                              decoration: BoxDecoration(
                                  color: textColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(13))),
                              child: Icon(Icons.link,
                                  color: Color.fromARGB(255, 199, 199, 199))),
                          hintText: "Enter Your Link"),
                    ),
                  ),
                  Divider(
                    color: Colors.transparent,
                  ),
                  Text(
                    'Enter Your Link/Previous Link',
                    style: TextStyle(color: base),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
