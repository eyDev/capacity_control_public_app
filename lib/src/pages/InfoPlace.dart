import 'package:capacity_control_public_app/src/models/PlaceModel.dart';

import 'package:flutter/material.dart';

class InforPlacePage extends StatefulWidget {
  final Place place;
  InforPlacePage({required this.place});

  @override
  _InforPlacePageState createState() => _InforPlacePageState();
}

class _InforPlacePageState extends State<InforPlacePage> {
  @override
  void initState() {
    super.initState();
    _evictImage();
  }

  @override
  Widget build(BuildContext context) {
    final double aforo = (widget.place.currentUsers / widget.place.maxCapacityPermited) * 100;
    final Color aforoColor = aforo < 70
        ? Colors.green
        : aforo < 80
            ? Colors.amber
            : Colors.red;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: aforoColor,
        title: Text(widget.place.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image(
              image: NetworkImage('http://10.0.2.2:8000/api/place/img/${widget.place.uid}'),
              width: MediaQuery.of(context).size.width,
              height: (MediaQuery.of(context).size.width * 3) / 4,
              fit: BoxFit.fill,
              key: UniqueKey(),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                children: [
                  _customCard(
                    'Aforo',
                    'La cantidad de personas que se encuentran alojadas en el establecimiento en este momento.',
                    widget.place.currentUsers.toString(),
                    color: aforoColor,
                  ),
                  _customCard(
                      'Porcentaje del Aforo',
                      'La división entre el número actual de personas alojadas y la cantidad máxima de personas permitidas.',
                      '${((widget.place.currentUsers / widget.place.maxCapacityPermited) * 100).toStringAsFixed(2)}%',
                      color: aforoColor),
                  _customCard(
                    'Capacidad Máxima',
                    'La cantidad de personas que el establecimiento puede alojar.',
                    widget.place.maxCapacity.toString(),
                  ),
                  _customCard(
                    'Capacidad Máxima Permitida',
                    'La cantidad de personas que el establecimiento puede alojar debido a la pandemia.',
                    widget.place.maxCapacityPermited.toString(),
                  ),
                  _customCard(
                    'Procentaje máximo de personas permitido',
                    'La división entre la capacidad máxima y la capacidad máxima permitida de personas.',
                    '${((widget.place.maxCapacityPermited / widget.place.maxCapacity) * 100).toStringAsFixed(2)}%',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _customCard(String title, String subtitle, String quantity, {Color color = Colors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Card(
          margin: EdgeInsets.only(bottom: 10),
          color: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 10,
          child: Container(
            width: (MediaQuery.of(context).size.width - 30) * 0.70,
            height: 120,
            child: Center(
              child: ListTile(
                title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(subtitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.only(bottom: 10),
          color: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 10,
          child: Container(
            width: (MediaQuery.of(context).size.width - 30) * 0.30,
            height: 120,
            child: Center(
              child: Text(quantity, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  void _evictImage() {
    NetworkImage('http://10.0.2.2:8000/api/place/img/${widget.place.uid}').evict();
  }
}
