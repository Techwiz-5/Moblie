import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class MapSearchAndPickWidget extends StatelessWidget {
  final Function(PickedData)? onPicked;

  const MapSearchAndPickWidget({
    Key? key,
    this.onPicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenStreetMapSearchAndPick(
      buttonColor: Colors.blue,
      buttonText: 'Set Current Location',
        buttonHeight: 35,
      onPicked: onPicked ?? (pickedData) {
        print('Location picked: ${pickedData.latLong}');
      },
    );
  }
}
