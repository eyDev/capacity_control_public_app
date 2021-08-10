class ScanModel {
  int? id;
  String placeID;
  String placeName;
  String placeAddress;
  String checkInDate;

  ScanModel({
    this.id,
    required this.placeID,
    required this.placeName,
    required this.placeAddress,
    required this.checkInDate,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) => new ScanModel(
        id: json['id'],
        placeID: json['placeID'],
        placeName: json['placeName'],
        placeAddress: json['placeAddress'],
        checkInDate: json['checkInDate'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "placeID": placeID,
        "placeName": placeName,
        "placeAddress": placeAddress,
        "checkInDate": checkInDate,
      };
}
