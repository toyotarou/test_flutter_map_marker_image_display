import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';

import 'tile_provider.dart';

void main() {
  runApp(const MyApp());
}

/// アプリ全体のウィジェット
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Marker Image Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

/// 各マーカーに関するデータクラス
class MarkerData {
  // 画像の表示状態

  MarkerData({
    required this.point,
    required this.imageAsset,
    this.isImageVisible = true, // 初期状態は表示
  });

  final LatLng point;
  final String imageAsset;
  bool isImageVisible;
}

/// ホーム画面
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // MapController のインスタンス
  final MapController _mapController = MapController();

  // 現在のズームレベル（初期値は 13.0）
  double _currentZoom = 13.0;

  // 画像サイズの基準となるズームレベル
  final double _baseZoom = 13.0;

  // 基本の画像サイズ（ピクセル）
  final double _baseImageWidth = 50;
  final double _baseImageHeight = 50;

  // 5つのマーカーのデータ（位置と対応する画像アセットのパス）
  final List<MarkerData> _markersData = <MarkerData>[
    MarkerData(
      point: const LatLng(35.754295, 139.680191),
      imageAsset: 'assets/images/20250215_142242790.jpg',
    ),
    MarkerData(
      point: const LatLng(35.745894, 139.688521),
      imageAsset: 'assets/images/20250215_142311178.jpg',
    ),
    MarkerData(
      point: const LatLng(35.747509, 139.687350),
      imageAsset: 'assets/images/20250215_142413487.jpg',
    ),
    MarkerData(
      point: const LatLng(35.755180, 139.687729),
      imageAsset: 'assets/images/20250215_142643383.jpg',
    ),
    MarkerData(
      point: const LatLng(35.758469, 139.688141),
      imageAsset: 'assets/images/20250215_145409488.jpg',
    ),
  ];

  ///
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final LatLngBounds bounds = LatLngBounds.fromPoints(
        _markersData.map((MarkerData marker) => marker.point).toList(),
      );
      final LatLng center = bounds.center;

      final double latDiff = (bounds.north - bounds.south).abs();
      final double lngDiff = (bounds.east - bounds.west).abs();
      final double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
      double zoom;
      if (maxDiff < 0.1) {
        zoom = 15;
      } else if (maxDiff < 1) {
        zoom = 12;
      } else if (maxDiff < 5) {
        zoom = 10;
      } else {
        zoom = 5;
      }
      _mapController.move(center, zoom);
      setState(() {
        _currentZoom = zoom;
      });
    });
  }

  ///
  @override
  Widget build(BuildContext context) {
    final double scaleFactor = _currentZoom / _baseZoom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Map Marker Image Sample'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(36.2048, 138.2529),
          initialZoom: _currentZoom,
          onPositionChanged: (MapCamera position, bool isMoving) {
            if (isMoving) {
              setState(() {
                _currentZoom = position.zoom;
              });
            }
          },
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            tileProvider: CachedTileProvider(),
            userAgentPackageName: 'com.example.app',
          ),
          // マーカーレイヤー
          MarkerLayer(
            markers: _markersData.map((MarkerData markerData) {
              return Marker(
                point: markerData.point,
                width: (30 + 8 + _baseImageWidth) * scaleFactor,
                height: _baseImageHeight * scaleFactor,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      markerData.isImageVisible = !markerData.isImageVisible;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.location_on, size: 30 * scaleFactor, color: Colors.red),
                      if (markerData.isImageVisible) ...<Widget>[
                        Container(
                          width: _baseImageWidth * scaleFactor,
                          height: _baseImageHeight * scaleFactor,
                          decoration: BoxDecoration(border: Border.all(color: Colors.black54), color: Colors.white),
                          child: Image.asset(markerData.imageAsset, fit: BoxFit.cover),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
