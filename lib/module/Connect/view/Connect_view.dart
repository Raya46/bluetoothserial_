// import 'dart:convert';

// import 'package:badges/badges.dart';
// import 'package:flutter/foundation.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/rendering.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:isoja_application/core.dart';
// import 'package:perfect_volume_control/perfect_volume_control.dart';
// import '../controller/Connect_controller.dart';

// class ConnectView extends StatefulWidget {
//   final String deviceName;
//   const ConnectView({Key? key, required this.deviceName}) : super(key: key);

//   Widget build(context, ConnectController controller) {
//     controller.view = this;

//     return LayoutBuilder(builder: (context, constraints) {
//       final height = constraints.maxHeight;
//       final width = constraints.maxWidth;
//         return Scaffold(
//           backgroundColor: controller.bgColor,
//           appBar: AppBar(
//             toolbarHeight: (constraints.maxHeight * 0.1),
//             backgroundColor: controller.baseColor,
//             title: Text(
//               "ISOJA",
//               style: GoogleFonts.michroma(
//                   textStyle: TextStyle(fontSize: 32),
//                   fontWeight: FontWeight.normal),
//             ),
//             actions: <Widget>[
//               IconButton(
//                 color: controller.power
//                     ? controller.powerOn
//                     : controller.disableBaseColor,
//                 icon: Icon(Icons.power_settings_new),
//                 iconSize: (width * 0.1),
//                 tooltip: "On/Off",
//                 onPressed: controller.powerOffOn,
//               ),
//               IconButton(
//                   icon: Icon(Icons.lightbulb),
//                   color: controller.lamp
//                       ? controller.lampOn
//                       : controller.fieldBgColor,
//                   iconSize: (width * 0.1),
//                   tooltip: "Save Todo and Retrun to List",
//                   onPressed: controller.lampOffOn),
//             ],
//           ),
//           body: Container(
//             child: Container(
//               padding: EdgeInsets.all(10.0),
//               child: Column(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: Center(
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "DN : ${deviceName}",
//                             textAlign: TextAlign.start,
//                             style: GoogleFonts.inter(
//                                 textStyle: TextStyle(
//                                     color: controller.textColor,
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold)),
//                           ),
//                           ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: controller.baseColor,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                               onPressed: controller.isButtonUnavailable
//                                   ? null
//                                   : controller.connected
//                                       ? controller.disconnect
//                                       : controller.connect,
//                               child: Icon(Icons.close_rounded))
//                         ],
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     flex: 8,
//                     child: Column(
//                       children: [
//                         Expanded(
//                             child: Container(
//                           margin: EdgeInsets.symmetric(
//                               horizontal: (constraints.maxWidth * 0.03)),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(15),
//                             child: Container(
//                               color: controller.baseColor12,
//                               child: Column(
//                                 children: [
//                                   Container(
//                                     margin: EdgeInsets.only(
//                                         bottom: (constraints.maxWidth * 0.04)),
//                                     color: controller.baseColor,
//                                     height: 20,
//                                   ),
//                                   Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Container(
//                                         margin: EdgeInsets.symmetric(
//                                           horizontal:
//                                               (constraints.maxWidth * 0.05),
//                                         ),
//                                         child: Text(
//                                           "Settings",
//                                           style: GoogleFonts.inter(
//                                               textStyle: TextStyle(
//                                                   color: controller.textColor,
//                                                   fontSize: 22,
//                                                   fontWeight: FontWeight.bold)),
//                                         ),
//                                       ),
//                                       Container(
//                                         margin: EdgeInsets.only(
//                                             top: (constraints.maxWidth * 0.01)),
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceEvenly,
//                                           children: [
//                                             sliderNoiseWidget(
//                                                 context, controller),
//                                             sliderMusicWidget(
//                                                 context, controller)
//                                           ],
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         )),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                       flex: 8,
//                       child: Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Text(
//                               "Play Music",
//                               textAlign: TextAlign.start,
//                               style: GoogleFonts.inter(
//                                   textStyle: TextStyle(
//                                       color: controller.baseColor,
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.bold)),
//                             ),
//                             ClipRRect(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(12.0),
//                               ),
//                               child: Container(
//                                 padding: EdgeInsets.all((width * 0.04)),
//                                 height: width / 2.5,
//                                 width: width / 1.2,
//                                 color: controller.baseColor12,
//                                 child: Column(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Container(
//                                       margin: EdgeInsets.symmetric(
//                                           horizontal: (0.05)),
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 12, vertical: 5),
//                                       decoration: BoxDecoration(
//                                           color: controller.baseColor,
//                                           borderRadius:
//                                               BorderRadius.circular(14)),
//                                       child: DropdownButton(
//                                         underline: Container(
//                                           height: 0,
//                                         ),
//                                         hint: Text(
//                                           "Select Music",
//                                           style: TextStyle(
//                                               color: controller.bgColor),
//                                         ),
//                                         isExpanded: true,
//                                         style: GoogleFonts.inter(
//                                             textStyle: TextStyle(
//                                                 color: controller.bgColor,
//                                                 fontSize: 16)),
//                                         items: controller.getListMusic(),
//                                         onChanged: (value) =>
//                                             controller.setState(() {
//                                           controller.message = value;
//                                         }),
//                                         value: controller.messages.isNotEmpty
//                                             ? controller.message
//                                             : null,
//                                         icon:
//                                             Icon(Icons.arrow_drop_down_rounded),
//                                         iconEnabledColor: controller.bgColor,
//                                         iconSize: 42,
//                                         dropdownColor: controller.baseColor,
//                                       ),
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         Container(
//                                           height: (height * 0.06),
//                                           child: ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor:
//                                                   controller.baseColor,
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           15)),
//                                             ),
//                                             onPressed: controller.retryMusic,
//                                             child: Icon(
//                                               Icons.repeat_one_rounded,
//                                               color: controller.retry
//                                                   ? controller.powerOn
//                                                   : controller.bgColor,
//                                               size: (width * 0.08),
//                                             ),
//                                           ),
//                                         ),
//                                         Row(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             IconButton(
//                                                 color: controller.baseColor,
//                                                 iconSize: width * 0.1,
//                                                 onPressed:
//                                                     controller.sendPrevious,
//                                                 icon: Icon(Icons
//                                                     .skip_previous_rounded)),
//                                             IconButton(
//                                                 color: controller.baseColor,
//                                                 iconSize: width * 0.1,
//                                                 onPressed:
//                                                     controller.playPaused,
//                                                 icon: Icon(controller.play
//                                                     ? Icons.pause_rounded
//                                                     : Icons
//                                                         .play_arrow_rounded)),
//                                             IconButton(
//                                                 color: controller.baseColor,
//                                                 iconSize: width * 0.1,
//                                                 onPressed: controller.sendNext,
//                                                 icon: Icon(
//                                                     Icons.skip_next_rounded))
//                                           ],
//                                         ),
//                                         Container(
//                                           height: (height * 0.06),
//                                           width: (height * 0.07),
//                                           child: ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor:
//                                                   controller.baseColor,
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           15)),
//                                             ),
//                                             onPressed: controller.sendConvert,
//                                             child: Icon(
//                                               Icons.send_rounded,
//                                               color: controller.bgColor,
//                                               size: (width * 0.06),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                           ])),
//                   Expanded(
//                     flex: 3,
//                     child: Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Container(
//                             height: (height * 0.065),
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: controller.baseColor,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15)),
//                               ),
//                               onPressed: controller.showAlertDelete,
//                               child: Icon(
//                                 Icons.delete,
//                                 color: controller.redColor,
//                                 size: (width * 0.08),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             height: (height * 0.065),
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: controller.baseColor,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15)),
//                               ),
//                               onPressed: controller.showAlert,
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.upload, color: controller.bgColor),
//                                   Text(
//                                     "Upload New Song",
//                                     style: GoogleFonts.inter(
//                                         textStyle: TextStyle(
//                                             color: controller.bgColor,
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold)),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Badge(
//                             animationType: BadgeAnimationType.fade,
//                             showBadge: controller.notif,
//                             padding: const EdgeInsets.all(10.0),
//                             badgeContent: Text('${controller.messages.length}',
//                                 style: TextStyle(color: Colors.white)),
//                             badgeColor: Colors.red,
//                             toAnimate: true,
//                             child: Container(
//                               height: (height * 0.065),
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: controller.baseColor,
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(15)),
//                                 ),
//                                 onPressed: controller.showAlertMail,
//                                 child: Icon(
//                                   Icons.mail_rounded,
//                                   color: controller.bgColor,
//                                   size: (width * 0.08),
//                                 ),
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         );
      
//     });
//   }

//   //!Widget slider Noise
//   Widget sliderNoiseWidget(context, ConnectController controller) =>
//       LayoutBuilder(builder: (context, contraints) {
//         final width = contraints.maxWidth;
//         return Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Container(
//               margin: EdgeInsets.symmetric(horizontal: (width * 0.05)),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Music Streaming",
//                       style: GoogleFonts.inter(
//                           textStyle: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: controller.textColor))),
//                   Transform.scale(
//                     scale: 1.3,
//                     child: Switch(
//                       inactiveThumbColor: controller.bgColor,
//                       value: controller.switchEnable,
//                       onChanged: (value) {
//                         controller.setState(() {
//                           controller.switchDialog = value;
//                           controller.switchEnable = value;
//                           controller.sliderEnable = value;
//                           controller.switchEnablePlay = false;
//                           controller.sliderEnablePlay = false;
//                         });
//                         controller.openLoading(context);
//                         if (controller.switchEnable == true) {
//                           controller.sendMessageToBluetooth('o\n');
//                         } else if (controller.switchEnable == false) {
//                           controller.sendOffMessageToBluetooth("8\n");
//                         }
//                       },
//                       activeColor: controller.baseColor,
//                       inactiveTrackColor: Color.fromRGBO(78, 78, 78, 1),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.multitrack_audio,
//                   color: controller.baseColor,
//                   size: 32,
//                 ),
//                 Container(
//                   width: width / 1.2,
//                   child: SliderTheme(
//                     data: SliderTheme.of(context).copyWith(
//                       showValueIndicator: ShowValueIndicator.never,
//                       thumbShape:
//                           RoundSliderThumbShape(enabledThumbRadius: 10.0),
//                       trackHeight: 4,
//                       disabledActiveTrackColor: controller.bgColor,
//                       disabledThumbColor: controller.bgColor,
//                       overlayShape:
//                           RoundSliderOverlayShape(overlayRadius: 20.0),
//                     ),
//                     child: Slider(
//                       value: controller.currentValue,
//                       min: 0,
//                       max: 1.0,
//                       divisions: 100,
//                       activeColor: controller.baseColor,
//                       inactiveColor: controller.bgColor,
//                       onChanged: controller.sliderEnable == true
//                           ? controller.sliderControl
//                           : null,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         );
//       });

//   //!Widget slider music
//   Widget sliderMusicWidget(context, ConnectController controller) =>
//       LayoutBuilder(builder: (context, contraints) {
//         final width = contraints.maxWidth;
//         return Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Container(
//               margin: EdgeInsets.symmetric(horizontal: (width * 0.05)),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Play Music",
//                       style: GoogleFonts.inter(
//                           textStyle: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: controller.textColor))),
//                   Transform.scale(
//                     scale: 1.3,
//                     child: Switch(
//                       inactiveThumbColor: controller.bgColor,
//                       value: controller.switchEnablePlay,
//                       onChanged: (value) {
//                         controller.setState(() {
//                           controller.switchDialog = value;
//                           controller.switchEnablePlay = value;
//                           controller.sliderEnablePlay = value;
//                           controller.switchEnable = false;
//                           controller.sliderEnable = false;
//                         });
//                         controller.openLoading(context);
//                         if (controller.switchEnablePlay == true) {
//                           controller.sendMessageToBluetooth("l\n");
//                         } else if (controller.switchEnablePlay == false) {
//                           controller.sendOffMessageToBluetooth('5\n');
//                         }
//                       },
//                       activeColor: controller.baseColor,
//                       inactiveTrackColor: Color.fromRGBO(78, 78, 78, 1),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.audiotrack,
//                   color: controller.baseColor,
//                   size: 32,
//                 ),
//                 Container(
//                   width: width / 1.2,
//                   child: SliderTheme(
//                     data: SliderTheme.of(context).copyWith(
//                       showValueIndicator: ShowValueIndicator.never,
//                       thumbShape:
//                           RoundSliderThumbShape(enabledThumbRadius: 10.0),
//                       trackHeight: 4,
//                       disabledActiveTrackColor: controller.bgColor,
//                       disabledThumbColor: controller.bgColor,
//                       overlayShape:
//                           RoundSliderOverlayShape(overlayRadius: 20.0),
//                     ),
//                     child: Slider(
//                       value: controller.playMusic,
//                       min: 0,
//                       max: 1.0,
//                       divisions: 100,
//                       activeColor: controller.baseColor,
//                       inactiveColor: controller.bgColor,
//                       onChanged: controller.sliderEnablePlay == true
//                           ? controller.sliderControlPlay
//                           : null,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         );
//       });

//   @override
//   State<ConnectView> createState() => ConnectController();
// }
// //
