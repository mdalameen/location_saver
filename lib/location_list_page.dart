import 'package:flutter/material.dart';
import 'package:location_saver/app_preferences.dart';
import 'package:location_saver/data.dart';
import 'package:location_saver/map_page.dart';

class LocationListPage extends StatefulWidget {
  @override
  _LocationListPageState createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    List<Place> places = AppPreference().getLocations();
    return Scaffold(
      appBar: AppBar(
        title: Text('Locations'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: _onAddLocationPressed)
        ],
      ),
      body: places.isEmpty
          ? _buildEmptyPage()
          : ListView.separated(
              separatorBuilder: (_, i) => Divider(),
              itemBuilder: (_, i) => _buildPlaceItem(places, i),
              itemCount: places.length,
            ),
    );
  }

  Widget _buildEmptyPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.add_location, size: 100, color: Colors.grey.shade400),
        SizedBox(
          height: 20,
        ),
        Text(
          'Press add button to add location.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
        ),
        SizedBox(
          height: 50,
        ),
      ],
    );
  }

  Widget _buildPlaceItem(List<Place> places, index) {
    Place place = places[index];
    return ListTile(
      onTap: () => _onItemPressed(place),
      title: Text(place.address),
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: Icon(Icons.location_on, color: Colors.white),
      ),
      trailing: IconButton(
          icon: Icon(Icons.delete_forever),
          onPressed: () => _onDeletePressed(places, index)),
    );
  }

  _onDeletePressed(List<Place> places, index) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('Do you want to Delete?'),
              content: Text('Do you want to delete ${places[index].address}'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      places.removeAt(index);
                      AppPreference().setLocations(places);
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Text('Yes')),
                FlatButton(
                    onPressed: () => Navigator.pop(context), child: Text('No'))
              ],
            ));
  }

  void _onItemPressed(Place place) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MapPage.display(place.position, place.address)));
  }

  void _onAddLocationPressed() async {
    Place place = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => MapPage.select()));
    if (place != null) {
      setState(() {
        AppPreference()
            .setLocations(AppPreference().getLocations()..add(place));
      });
    }
  }
}
