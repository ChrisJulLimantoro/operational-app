import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:operational_app/model/store.dart';
import 'package:operational_app/theme/colors.dart';
import 'package:operational_app/theme/text.dart';
import 'package:operational_app/widget/text_card_detail.dart';

class StoreDetailScreen extends StatefulWidget {
  final Store store;
  const StoreDetailScreen({super.key, required this.store});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    // Initialize items Details
    items = [
      {
        "label": "Kode",
        "value": widget.store.code,
        "type": "string",
        "isLong": false,
      },
      {
        "label": "Name",
        "value": widget.store.name,
        "type": "string",
        "isLong": false,
      },
      {
        "label": "NPWP",
        "value": widget.store.npwp,
        "type": "text",
        "isLong": false,
      },
      {
        "label": "Dibuka pada",
        "value": widget.store.openDate,
        "type": "date",
        "isLong": false,
      },
      {
        "label": "Usaha",
        "value":
            "${widget.store.company?.code} | ${widget.store.company?.name}",
        "type": "text",
        "isLong": false,
      },
      {
        "label": "Alamat",
        "value": widget.store.address,
        "type": "string",
        "isLong": true,
      },
      {
        "label": "Deskripsi",
        "value": widget.store.description,
        "type": "string",
        "isLong": true,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(widget.store.name, style: AppTextStyles.headingWhite),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Detail Cabang",
                            style: AppTextStyles.headingBlue,
                          ),
                          const Divider(),
                          ...items.map(
                            (item) => TextCardDetail(
                              label: item['label'],
                              value: item['value'],
                              type: item['type'],
                              isLong: item['isLong'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Logo Toko", style: AppTextStyles.headingBlue),
                          const Divider(),
                          Image.network(
                            'http://localhost:3000/${widget.store.logo}',
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.scaleDown,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Lokasi Toko", style: AppTextStyles.headingBlue),
                          const Divider(),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: SizedBox(
                              height: 200,
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(
                                    widget.store.latitude,
                                    widget.store.longitude,
                                  ),
                                  initialZoom: 16,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                    subdomains: ['a', 'b', 'c'],
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        width: 40.0,
                                        height: 40.0,
                                        point: LatLng(
                                          widget.store.latitude,
                                          widget.store.longitude,
                                        ),
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: AppColors.bluePrimary,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
