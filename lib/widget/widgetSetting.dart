import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isoja_application/global/color.dart';
import 'package:isoja_application/page/storagePage.dart';

class buttonUploadd extends StatelessWidget {
  final BluetoothDevice device;

  const buttonUploadd({
    Key? key,
    required this.width,
    required this.device,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context) {
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
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StoragePage(
                        device: device,
                      )),
            );
          },
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(
                  Icons.upload_rounded,
                  size: 32,
                ),
                Text(
                  "Upload",
                  style: GoogleFonts.inter(
                      color: bg, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          )),
    );
  }
}

class buttonDelete extends StatelessWidget {
  final BluetoothDevice device;
  final VoidCallback displayInput;
  buttonDelete({
    Key? key,
    required this.width,
    required this.device,
    required this.displayInput,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context) {
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
            displayInput();
          },
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(
                  Icons.delete_rounded,
                  size: 32,
                ),
                Text(
                  "Delete",
                  style: GoogleFonts.inter(
                      color: bg, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          )),
    );
  }
}

class songList extends StatelessWidget {
  const songList({
    Key? key,
    required this.width,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("dadc");
      },
      child: SizedBox(
        width: width,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // <-- Radius
          ),
          color: base,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Song 1",
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: disable),
                ),
                Icon(
                  Icons.play_arrow_rounded,
                  size: width * 0.1,
                  color: disable,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
