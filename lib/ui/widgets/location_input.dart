import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// import '../../models/place.dart';
import '../admin/map.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(LatLng location) onSelectLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  final MapController mapController = MapController();
  LocationData? currentLocation;
  LatLng? _pickedLocation;
  var _isGettingLocation = false;
  final String orsApiKey =
      '5b3ce3597851110001cf62482a3bbccce840449baea616641f870310'; // Replace with your OpenRouteService API key

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    print(lat);
    print(lng);
    // return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyCOaEIViy3KsNPhxg8Nfd9RaD_rVzzDsow';

    return 'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey&start=${lng},${lat}';
  }

  Future<void> _savePlace(double latitude, double longitude) async{
    // final url = Uri.parse(
    //     'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyCOaEIViy3KsNPhxg8Nfd9RaD_rVzzDsow');
    final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey&start=${longitude},${latitude}');
    final response = await http.get(url);
    print(json.decode(response.body));
    // final resData = json.decode(response.body);
    // final address = resData['results'][0]['formatted_address'];

    final data = json.decode(response.body);
    final List<dynamic> coords =
    data['features'][0]['geometry']['coordinates'];
    // setState(() {
    //   // _pickedLocation = PlaceLocation(
    //   //   latitude: latitude,
    //   //   longitude: longitude,
    //   //   address: address,
    //   // );
      _isGettingLocation = false;
    // });

    widget.onSelectLocation(_pickedLocation!);
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();


    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    _savePlace(lat,lng);
  }

  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => const MapScreen(),
      ),
    );

    if(pickedLocation == null){
      return;
    }

    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onBackground),
    );

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
          ),
          child: SizedBox(
            height: 300,
            child: _pickedLocation == null ? SizedBox.shrink()  : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(
                    _pickedLocation!.latitude!, _pickedLocation!.longitude!),
                initialZoom: 17.0,
                onTap: (tapPosition, point) {

                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _pickedLocation!,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
                  ),]
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              onPressed: _getCurrentLocation,
              label: const Text('Get current location'),
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              onPressed: _selectOnMap,
              label: const Text('Select on map'),
            )
          ],
        ),
      ],
    );
  }
}
