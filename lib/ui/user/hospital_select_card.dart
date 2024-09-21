import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:techwiz_5/ui/admin/hospital/edit_hospital_screen.dart';
import 'package:techwiz_5/ui/user/hospital_detail_screen.dart';

class HospitalSelectCard extends StatefulWidget {
  const HospitalSelectCard({super.key, required this.hospital, required this.color});
  final dynamic hospital;
  final Color color;

  @override
  State<HospitalSelectCard> createState() => _HospitalSelectCardState();
}

class _HospitalSelectCardState extends State<HospitalSelectCard> {
  bool isAdmin = false;
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
          border: const Border(
            left: BorderSide(
              color: Colors.blue,
              width: 6.0,
            ),
            top: BorderSide(
              color: Colors.blue,
              width: 1.0,
            ),
            right: BorderSide(
              color: Colors.blue,
              width: 1.0,
            ),
            bottom: BorderSide(
              color: Colors.blue,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 10,
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(// Image border
                child: SizedBox.fromSize(
                  size: const Size(40, 40),
                  child: Image.network(
                    widget.hospital['image'] ?? 'https://i.pravatar.cc/150',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.hospital['name'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.black38,
                size: 18,
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                child: Text(
                  '${widget.hospital['address'] ?? ''} ',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.call,
                color: Colors.black38,
                size: 18,
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                child: Text(
                  '${widget.hospital['phone'] ?? ''} ',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.attach_money,
                color: Colors.red,
                size: 18,
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                child: Text(
                  '\$${widget.hospital['price'] ?? ''}/km',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.red
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${widget.hospital['description'] ?? ''} ',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${widget.hospital['distance'].toStringAsFixed(2)} km',
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              SizedBox(
                width: 90,
                height: 35,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HospitalDetailScreen(hospital: widget.hospital),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100]),
                  child: const Text("Detail"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
