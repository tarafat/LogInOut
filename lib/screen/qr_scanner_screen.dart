import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../providers/ApiConnector.dart';
import '../screen/signin_out_screen.dart';

class QRViewScreen extends StatefulWidget {
  static const routeName = "/QrScanScreen";
  const QRViewScreen({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen> {
  var qrText = '';
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      qrText = scanData;
      controller.pauseCamera();
      DateTime _dateTime = DateTime.now();
      String customer = _customer(qrText);
      Provider.of<ApiConnector>(context, listen: false)
          .openSession(customer, qrText, _dateTime.toString())
          .then((value) {
        if (value == true) {
          Navigator.of(context).pushReplacementNamed(SignInOutScreen.routeName);
        } else if (value == false) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text(
                  "QR not recognised",
                  style: TextStyle(color: Colors.red, fontSize: 24),
                ),
                content: new Text("Scan your QR code to active your session"),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("Close"),
                    onPressed: () {
                      controller.dispose();
                      Navigator.of(context)
                          .pushReplacementNamed(SignInOutScreen.routeName);
                    },
                  ),
                  new FlatButton(
                    child: new Text("Try Again"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.resumeCamera();
                    },
                  ),
                ],
              );
            },
          );
        }
      });
    });
  }

  String _customer(String qrText) {
    int firstIndex = qrText.indexOf('%') + 1;
    int lastIndex = qrText.replaceFirst('%', '').indexOf('%') + 1;
    String cus = qrText.substring(firstIndex, lastIndex);
    return cus;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
