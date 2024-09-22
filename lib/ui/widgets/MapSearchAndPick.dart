import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class MapSearchAndPickWidget extends StatefulWidget {
  final Function(PickedData)? onPicked;

  const MapSearchAndPickWidget({
    Key? key,
    this.onPicked,
    this.buttonText,
    this.buttonHeight,
  }) : super(key: key);
  final String? buttonText;
  final double? buttonHeight;

  @override
  State<MapSearchAndPickWidget> createState() => _MapSearchAndPickWidgetState();
}

class _MapSearchAndPickWidgetState extends State<MapSearchAndPickWidget> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return OpenStreetMapSearchAndPick(
      buttonColor: Colors.blue,
      buttonText: widget.buttonText ?? 'Set Location',
        buttonHeight: widget.buttonHeight ?? 35,
      onPicked: widget.onPicked ?? (pickedData) {
        print('Location picked: ${pickedData.latLong}');
      },
    );
  }
}
