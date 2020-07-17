import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  String address;
  LatLng position;

  Place.fromJson(Map<String, dynamic> map)
      : address = map['address'],
        position = LatLng.fromJson(map['position']);

  Place(this.address, this.position);

  Map<String, dynamic> toJson() =>
      {'address': address, 'position': position.toJson()};
}
