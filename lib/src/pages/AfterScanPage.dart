import 'package:capacity_control_public_app/src/data/DataProvider.dart';
import 'package:capacity_control_public_app/src/data/ScanBloc.dart';
import 'package:capacity_control_public_app/src/models/PlaceModel.dart';
import 'package:capacity_control_public_app/src/models/ScanModel.dart';
import 'package:flutter/material.dart';

class AfterScanPage extends StatefulWidget {
  final Place place;
  final String process;
  const AfterScanPage({Key? key, required this.place, required this.process}) : super(key: key);

  @override
  _AfterScanPageState createState() => _AfterScanPageState();
}

class _AfterScanPageState extends State<AfterScanPage> {
  final ScansBloc scansBloc = new ScansBloc();
  final DataProvider apiConneection = DataProvider();
  @override
  Widget build(BuildContext context) {
    final double aforo = (widget.place.currentUsers / widget.place.maxCapacityPermited) * 100;
    final Color aforoColor = widget.process == "out"
        ? Colors.blue
        : aforo < 75
            ? Colors.green
            : aforo < 90
                ? Colors.amber
                : Colors.redAccent;

    return Scaffold(
      backgroundColor: aforoColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(border: Border.all(color: Colors.white), shape: BoxShape.circle),
                child: Icon(
                  widget.process == "out"
                      ? Icons.logout
                      : aforo < 75
                          ? Icons.check
                          : aforo < 90
                              ? Icons.warning
                              : Icons.error,
                  color: Colors.white,
                  size: 100,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  widget.place.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: (MediaQuery.of(context).size.width - 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _customCard('${widget.place.currentUsers}', 'Personas'),
                    _customCard('${(aforo).toStringAsFixed(1)}%', 'Lleno'),
                  ],
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 80),
                height: 60,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                  ),
                  onPressed: widget.process == 'in' && aforo >= 100 ? null : () => _check(),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.process == 'out'
                            ? 'Salir'
                            : aforo < 90
                                ? 'Ingresar'
                                : 'No puede ingresar',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Icon(
                        widget.process == 'out' ? Icons.logout : Icons.login,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Regresar',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _customCard(String quantity, String subtitle) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(top: 20, bottom: 30),
      elevation: 10,
      child: Container(
        width: (MediaQuery.of(context).size.width - 100) / 2,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              quantity,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
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

  void _check() async {
    _loadingDialog();
    final int status = await apiConneection.check(widget.place.uid, widget.process);
    final IconData icon = status == 200 ? Icons.check : Icons.error;
    final Color color = status == 200 ? Colors.green : Colors.red;
    Navigator.pop(context);
    final String now = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    final scan = ScanModel(
      placeID: widget.place.uid,
      placeName: widget.place.name,
      placeAddress: widget.place.address,
      checkInDate: now,
    );
    scansBloc.scNewScan(scan);
    showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: color,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(border: Border.all(color: Colors.white), shape: BoxShape.circle),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ],
          );
        });
    Future.delayed(Duration(seconds: 4)).then((value) {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }
}
