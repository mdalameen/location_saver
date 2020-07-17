import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_saver/data.dart';

class MapPage extends StatefulWidget {
  final LatLng location;
  final bool _isTypeSelect;
  String adddress;

  MapPage.select([this.location]) : this._isTypeSelect = true;

  MapPage.display(this.location, this.adddress) : this._isTypeSelect = false;
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng initialPostion;
  GoogleMapController _controller;
  Set<Marker> markers = Set();
  @override
  void initState() {
    super.initState();
    initialPostion = widget.location ?? LatLng(13.067439, 80.237617);
    if (!widget._isTypeSelect)
      markers.add(Marker(
          markerId: MarkerId(
              '${initialPostion.latitude},${initialPostion.longitude}'),
          infoWindow: widget.adddress == null
              ? null
              : InfoWindow(title: widget.adddress),
          visible: true,
          position: initialPostion));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select location'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) => _controller = controller,
        initialCameraPosition: CameraPosition(target: initialPostion, zoom: 12),
        myLocationButtonEnabled: true,
        compassEnabled: true,
        markers: markers,
        onTap: widget._isTypeSelect ? _onPostionTapped : null,
        myLocationEnabled: true,
      ),
    );
  }

  _onPostionTapped(LatLng position) async {
    markers.clear();
    markers.add(Marker(
        markerId: MarkerId(
          '${position.latitude},${position.longitude}',
        ),
        position: position));
    setState(() {});
    _controller.moveCamera(CameraUpdate.newLatLng(position));

    Place place = await showModalBottomSheet(
        context: context,
        builder: (_) => FetchLocationPage(position),
        isScrollControlled: true);
    if (place != null) Navigator.pop(context, place);
  }
}

class FetchLocationPage extends StatefulWidget {
  final LatLng position;
  FetchLocationPage(this.position);
  @override
  _FetchLocationPageState createState() => _FetchLocationPageState();
}

class _FetchLocationPageState extends State<FetchLocationPage> {
  bool _isLoading = true;
  String address;
  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  _fetchAddress() async {
    if (!_isLoading) {
      _isLoading = true;
      setState(() {});
    }

    try {
      List<Placemark> addresses = await Geolocator().placemarkFromCoordinates(
          widget.position.latitude, widget.position.longitude);

      if (addresses != null && addresses.isNotEmpty) {
        Placemark placeMark = addresses.first;
        print(placeMark.subThoroughfare);
        address = '';
        // can be used google api to get full address but I sticked to this because of time shortage
        for (String s in [
          placeMark.name,
          placeMark.subLocality,
          placeMark.locality,
          placeMark.administrativeArea,
          placeMark.postalCode,
          placeMark.country
        ]) address += (s != null && s.length > 0) ? '$s, ' : '';
        address = address.substring(0, address.length - 2);
      }

      print(address);
    } catch (e) {}
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(15),
          color: Colors.blue,
          child: Text(
            'Selected Location',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        if (_isLoading)
          SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        if (!_isLoading)
          ListTile(
              title: Text(
            address == null ? 'Invalid location!' : address,
          )),
        SafeArea(
            child: FlatButton(
          onPressed: () {
            Navigator.pop(context, Place(address, widget.position));
          },
          child: Text(
            'Add Location',
            style: TextStyle(color: Colors.blue),
          ),
        ))
      ],
    );
  }
}
