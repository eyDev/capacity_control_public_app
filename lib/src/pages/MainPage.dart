import 'dart:convert';

import 'package:capacity_control_public_app/src/data/DataProvider.dart';
import 'package:capacity_control_public_app/src/data/ScanBloc.dart';
import 'package:capacity_control_public_app/src/models/ErrorModel.dart';
import 'package:capacity_control_public_app/src/models/PlaceModel.dart';
import 'package:capacity_control_public_app/src/models/ScanModel.dart';
import 'package:capacity_control_public_app/src/pages/AfterScanPage.dart';
import 'package:capacity_control_public_app/src/pages/InfoPlace.dart';
import 'package:capacity_control_public_app/src/search/SearchDelegate.dart';
import 'package:capacity_control_public_app/src/widgets/SnackBarError.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final DataProvider apiConneection = DataProvider();
  final ScansBloc scansBloc = ScansBloc();
  @override
  Widget build(BuildContext context) {
    scansBloc.scGetScans();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Mis lugares visitados'),
        actions: [
          IconButton(
            onPressed: () => showSearch(
              context: context,
              delegate: DataSearch(),
            ),
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: StreamBuilder<List<ScanModel>>(
        stream: scansBloc.scansStream,
        builder: (BuildContext context, AsyncSnapshot<List<ScanModel>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final scans = snapshot.data;
          if (scans != null) {
            if (scans.length == 0) {
              return Center(
                child: Image.asset('assets/empty.png'),
              );
            }
            return ListView.builder(
              itemCount: scans.length,
              itemBuilder: (context, i) => Dismissible(
                key: UniqueKey(),
                background: Container(color: Colors.redAccent),
                onDismissed: (direction) => scansBloc.scDeleteScan(scans[i].id!),
                child: ListTile(
                  onTap: () => _goToPlace(scans[i].placeID),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  title: Text(scans[i].placeName),
                  subtitle: Text(scans[i].placeAddress),
                  trailing: Text(scans[i].checkInDate),
                ),
              ),
            );
          }
          return Container();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              backgroundColor: Colors.redAccent,
              heroTag: "delete",
              onPressed: () => _deleteAllScans(),
              child: Icon(Icons.delete),
            ),
            FloatingActionButton(
              backgroundColor: Colors.green,
              heroTag: "scan",
              onPressed: () => _scanQR(context),
              child: Icon(Icons.qr_code_scanner),
            )
          ],
        ),
      ),
    );
  }

  void _scanQR(BuildContext context) async {
    try {
      final String scannedQR = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancelar', true, ScanMode.QR);
      if (scannedQR != '-1') {
        _loadingDialog();
        final Map<String, dynamic> scanData = jsonDecode(scannedQR);
        final result = await apiConneection.getPlace(scanData['placeID']);
        Navigator.pop(context);

        if (result is Place) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AfterScanPage(place: result, process: scanData['process'])));
        } else {
          showInSnackBar(context, result);
        }
      }
    } catch (e) {
      showInSnackBar(context, [DataError(msg: 'Error al escanear el cdigo QR', param: 'user', location: 'camera')]);
    }
  }

  Future<void> _deleteAllScans() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('¿Está seguro que desea borrar todos los lugares visitados?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: Text('Aceptar'),
                onPressed: () {
                  scansBloc.scDeleteAllScans();
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  Future<void> _goToPlace(String placeID) async {
    _loadingDialog();
    apiConneection.getPlace(placeID).then((result) {
      Navigator.pop(context);
      result is Place
          ? Navigator.push(context, MaterialPageRoute(builder: (context) => InforPlacePage(place: result)))
          : showInSnackBar(context, result);
    });
  }

  void _loadingDialog() {
    showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text('Cargando...'),
                  ],
                ),
              )
            ],
          );
        });
  }
}
