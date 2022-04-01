import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? barcode;
  double ratio = 0.85;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            buildQRScanner(context),
            Positioned(
              bottom: 40.0,
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width * ratio,
                      child: buildResult(context))),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQRScanner(BuildContext context) => QRView(
        // requires a key which is declared as qrKey
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        // This adds overlay to the Camera
        overlay: QrScannerOverlayShape(
            borderColor: Colors.blue,
            borderWidth: 5,
            borderRadius: 20,
            // Takes 80% of our screen width
            cutOutSize: MediaQuery.of(context).size.width * ratio),
      );

  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);
    controller.scannedDataStream.listen(
      (barcode) {
        setState(
          () {
            this.barcode = barcode;
            // controller.scannedDataStream.first;
          },
        );
      },
    );
  }

  Widget buildResult(BuildContext context) {
    // barcode!.code.toString().startsWith('https://')
    bool isVisible = true;
    if (barcode == null) {
      isVisible = false;
    }
    return Visibility(
      visible: isVisible,
        child: barcode != null ?(barcode!.code.toString().startsWith(RegExp(
                '[(https://)(https://)(mailto:)(tel:)(sms:)(file:/)]',
                caseSensitive: true))
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  child: Center(
                    child: Text(
                      barcode!.code.toString(),
                      style:
                          const TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                  onTap: () {
                    launch(barcode!.code.toString());
                  },
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  barcode!.code.toString(),
                  style: const TextStyle(
                      fontSize: 18,
                    decoration: TextDecoration.none,
                  ),
                ),
              )) : Container());
  }
}
