// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isoja_application/global/color.dart';
import 'package:isoja_application/helper/BluetoothManager.dart';
import 'package:isoja_application/widget/widgetSetting.dart';

class _Message {
  int whom;
  String text;
  _Message(
    this.whom,
    this.text,
  );
}

class ControlPage extends StatefulWidget {
  final BluetoothDevice deviceName;
  const ControlPage({Key? key, required this.deviceName}) : super(key: key);

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  bool power = false;
  bool lamp = false;
  bool music = false;
  bool stream = false;
  bool sliderEnable = false;
  bool retry = false;
  bool switch1 = false;
  bool btnVisible = true;
  String jsonString = '';
  String _messageBuffer = '';
  String value = '';
  bool notif = false;
  bool isConnecting = true;
  bool isDisconnecting = false;
  bool? get isConnected =>
      BluetoothManager.connection != null &&
      BluetoothManager.connection!.isConnected;
  _Message? message;
  List<_Message> messages = [];
  List messags = [];
  List<Widget> carouselData = [];
  late int deviceState;
  TextEditingController valueController = TextEditingController();
  final CarouselController carouselController = CarouselController();

//!double
  double sliderValue = 0.0;
  double counter = 0;
  double counter2 = 0;
  String? selectedValue;

  bool selectedMusic = false;

  @override
  void dispose() {
    BluetoothManager.disconnect();
    super.dispose();
  }

  void initState() {
    try {
      super.initState();
      BluetoothManager.connection!.input!.listen(onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      Navigator.pop(context);
    }
  }

  void changeIconPlay() {
    if (selectedMusic == false) {
      BluetoothManager.sendData('/${selectedValue}\n');
      setState(() {
        selectedMusic = true;
      });
    } else {
      BluetoothManager.sendData('p\n');
      setState(() {
        selectedMusic = false;
      });
    }
  }

  void onDataReceived(Uint8List data) {
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;
    setState(() {
      notif = true;
    });

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      String message = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString.substring(0, index));
      if (message.endsWith('.mp3') ||
          message.endsWith('.wav') ||
          message.endsWith('.aac') ||
          message.endsWith('.mpeg')) {
        setState(() {
          messages.add(
            _Message(1, message.trim()),
          );
          if (messages.length > 3) {
            messages.removeAt(0);
          }
        });
      }
      _messageBuffer = dataString.substring(index);
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  sendMessageToBluetooth(String message) async {
    BluetoothManager.sendData('8\n');
    await Future.delayed(Duration(seconds: 1));
    BluetoothManager.sendData(message);
    if (mounted) {
      setState(() {
        deviceState = 1;
        switch1 = true;
        btnVisible = true;
      });
    }
  }

  void convertInputToJson() {
    value = value.replaceAll(new RegExp(r'\s'), "");
    jsonString = '{"DLT":"$value"}';
  }

  void sendJsonDelete() {
    value = valueController.text;
    convertInputToJson();
    Navigator.pop(context);
    BluetoothManager.sendData(jsonString);
    valueController.clear();
  }

  void lampStats() {
    if (lamp == true) {
      BluetoothManager.sendData('b\n');
    } else {
      BluetoothManager.sendData('a\n');
    }
    setState(() {
      lamp = !lamp;
    });
    debugPrint('$lamp');
  }

  void incrementCounter() {
    setState(() {
      counter += 0.1;
      if (counter > 1.0) {
        counter = 1.0;
      }
      BluetoothManager.sendData(counter.toStringAsFixed(1));
    });
  }

  void decrementCounter() {
    setState(() {
      counter -= 0.1;
      if (counter < 0.0) {
        counter = 0.0;
      }
      BluetoothManager.sendData(counter.toStringAsFixed(1));
    });
  }

  Future<void> displayInput(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Write title'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  value = jsonString.trim();
                });
              },
              controller: valueController,
              decoration: const InputDecoration(hintText: "title"),
            ),
            actions: <Widget>[
              ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () {
                    sendJsonDelete();
                  }),
            ],
          );
        });
  }

  void openLoading(BuildContext context, [bool mounted = true]) async {
    if (stream || music) {
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
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: bg,
      appBar: appbarContent(context, height, width, lampStats),
      // ignore: avoid_unnecessary_containers
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        onTap: () {
                          try {
                            setState(() {
                              stream = !stream;
                              sliderEnable = false;
                              music = false;
                            });
                            openLoading(context);
                            if (stream == true) {
                              sendMessageToBluetooth('o\n');
                            } else if (stream == false) {
                              BluetoothManager.sendData('f\n');
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: cardNoise(width)),
                    InkWell(
                        onTap: () {
                          try {
                            setState(() {
                              music = !music;
                              sliderEnable = false;
                              stream = false;
                            });
                            openLoading(context);
                            if (music == true) {
                              sendMessageToBluetooth('l\n');
                            } else if (music == false) {
                              BluetoothManager.sendData('5\n');
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: cardPlayMusic(width)),
                  ],
                )),
            Divider(
              height: height / 45,
              color: Colors.transparent,
            ),
            Expanded(
                flex: 2,
                child: Container(
                  child: cardVolume(width),
                )),
            Divider(
              height: height / 50,
              color: Colors.transparent,
            ),
            Expanded(
                flex: 1,
                // ignore: avoid_unnecessary_containers
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buttonRepeat(width),
                      buttonUploadd(
                        width: width,
                        device: widget.deviceName,
                      ),
                      buttonDelete(
                        width: width,
                        device: widget.deviceName,
                        displayInput: () {
                          displayInput(context);
                        },
                      ),
                    ],
                  ),
                )),
            const Divider(
              height: 10,
              color: Colors.transparent,
            ),
            Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Card(
                    color: disable,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    child: SizedBox(
                      width: width,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: messages.isNotEmpty
                                    ? SizedBox(
                                        width: width,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                16), // <-- Radius
                                          ),
                                          color: base,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0.0),
                                            child: CarouselSlider.builder(
                                              itemCount: messages.length,
                                              carouselController:
                                                  carouselController,
                                              itemBuilder:
                                                  (context, index, realindex) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 0.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Card(
                                                        color: Colors.black,
                                                        child: Text(
                                                          messages[index]
                                                              .text
                                                              .trim(),
                                                          style:
                                                              GoogleFonts.inter(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      disable),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              options: CarouselOptions(
                                                  viewportFraction: 1,
                                                  height: 400.0,
                                                  enableInfiniteScroll: false,
                                                  enlargeCenterPage: true,
                                                  autoPlay: false,
                                                  initialPage: 1,
                                                  onPageChanged:
                                                      (index, reason) {
                                                    setState(() {
                                                      selectedValue =
                                                          messages[index]
                                                              .text
                                                              .trim();
                                                    });
                                                  }),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text('tidak ada data'),
                                      ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    InkWell(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(100.0),
                                      ),
                                      child: Icon(Icons.skip_previous,
                                          size: width * 0.15, color: base),
                                      onTap: () {
                                        if (carouselData.isNotEmpty) {
                                          try {
                                            BluetoothManager.sendData('k \n');
                                            carouselController.previousPage(
                                                duration:
                                                    Duration(milliseconds: 300),
                                                curve: Curves.linear);
                                          } catch (e) {
                                            print(e);
                                          }
                                        } else if (carouselData.isEmpty) {
                                          print('none');
                                        }
                                      },
                                    ),
                                    InkWell(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(100.0),
                                      ),
                                      child: selectedMusic
                                          ? Icon(Icons.pause_circle,
                                              size: width * 0.18, color: base)
                                          : Icon(Icons.play_circle_fill_rounded,
                                              size: width * 0.18, color: base),
                                      onTap: () {
                                        if (carouselData.isNotEmpty) {
                                          try {
                                            changeIconPlay();
                                          } catch (e) {
                                            print(e);
                                          }
                                        } else {
                                          print('none');
                                        }
                                      },
                                    ),
                                    InkWell(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(100.0),
                                      ),
                                      child: Icon(Icons.skip_next,
                                          size: width * 0.15, color: base),
                                      onTap: () {
                                        if (carouselData.isNotEmpty) {
                                          try {
                                            BluetoothManager.sendData('n \n');
                                            carouselController.nextPage(
                                                duration:
                                                    Duration(milliseconds: 300),
                                                curve: Curves.linear);
                                          } catch (e) {
                                            print(e);
                                          }
                                        } else if (carouselData.isEmpty) {
                                          print('none');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  SizedBox buttonRepeat(double width) {
    return SizedBox(
      width: width / 4,
      height: width / 5,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // <-- Radius
            ),
            primary: base,
          ),
          onPressed: () {
            try {
              BluetoothManager.sendData('r\n');
              setState(() {
                retry = !retry;
              });
            } catch (e) {
              print(e);
            }
          },
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.repeat_rounded,
                  size: 32,
                  color: retry ? powerOn : fieldBgColor,
                ),
                Text(
                  "Repeat",
                  style: GoogleFonts.inter(
                      color: bg, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          )),
    );
  }

  Card cardPlayMusic(double width) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: AnimatedContainer(
        decoration: BoxDecoration(
            color: music ? base : disable,
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        duration: const Duration(milliseconds: 400),
        child: SizedBox(
          width: width / 2.3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.music_note,
                    size: width / 4.6,
                    color: music ? bg : base,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Play Music",
                        style: GoogleFonts.inter(
                            color: music ? bg : base,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      FlutterSwitch(
                        activeToggleColor: base,
                        toggleColor: disable,
                        activeColor: disable,
                        inactiveColor: bg,
                        width: width / 8,
                        height: width * 0.07,
                        value: music,
                        onToggle: (value) {
                          try {
                            setState(() {
                              music = value;
                              stream = false;
                            });
                            openLoading(context);
                            if (music == true) {
                              sendMessageToBluetooth('1\n');
                            } else if (music == false) {
                              BluetoothManager.sendData('5\n');
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                      )
                    ],
                  )
                ]),
          ),
        ),
      ),
    );
  }

  Card cardVolume(double width) => Card(
        color: disable,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        child: Container(
          width: width,
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Volume",
                    style: GoogleFonts.inter(
                        color: base, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Slider(
                      min: 0,
                      max: 1.0,
                      divisions: 100,
                      activeColor: base,
                      inactiveColor: bg,
                      value: counter,
                      onChanged: (value) {
                        setState(() {
                          value = counter;
                        });
                      }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          try {
                            stream || music ? incrementCounter() : null;
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Icon(
                          Icons.add_circle,
                          size: 33.5,
                        ),
                      ),
                      VerticalDivider(),
                      InkWell(
                        onTap: () {
                          try {
                            stream || music ? decrementCounter() : null;
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Icon(
                          Icons.remove_circle,
                          size: 33.5,
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ),
      );

  Card cardNoise(double width) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: AnimatedContainer(
        decoration: BoxDecoration(
            color: stream ? base : disable,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        duration: const Duration(milliseconds: 400),
        child: SizedBox(
          width: width / 2.4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.multitrack_audio_rounded,
                    size: width / 4.6,
                    color: stream ? bg : base,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Stream",
                        style: GoogleFonts.inter(
                            color: stream ? bg : base,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      FlutterSwitch(
                        activeToggleColor: base,
                        toggleColor: disable,
                        activeColor: disable,
                        inactiveColor: bg,
                        width: width / 8,
                        height: width * 0.07,
                        value: stream,
                        onToggle: (value) {
                          try {
                            setState(() {
                              stream = value;
                              music = false;
                            });
                            openLoading(context);
                            if (stream == true) {
                              sendMessageToBluetooth('o\n');
                            } else if (stream == false) {
                              BluetoothManager.sendData('f\n');
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                      )
                    ],
                  )
                ]),
          ),
        ),
      ),
    );
  }

  AppBar appbarContent(
      BuildContext context, double height, double width, void lampStats()) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      toolbarHeight: (height * 0.1),
      backgroundColor: base,
      title: Text('${widget.deviceName.name}'),
      actions: <Widget>[
        IconButton(
          color: power ? powerOn : disableBaseColor,
          icon: const Icon(Icons.power_settings_new),
          iconSize: (width * 0.1),
          onPressed: () {
            try {
              if (power == true) {
                BluetoothManager.sendData('d');
              } else {
                sendMessageToBluetooth('c');
              }
              setState(() {
                power = !power;
              });
            } catch (e) {
              print(e);
            }
          },
        ),
        IconButton(
            icon: const Icon(Icons.lightbulb),
            color: lamp ? lampOn : fieldBgColor,
            iconSize: (width * 0.1),
            onPressed: lampStats),
      ],
    );
  }
}
