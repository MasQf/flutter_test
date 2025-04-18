import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:test/constants/color.dart';
import 'package:test/controllers/deal.dart';
import 'package:test/widgets/head_bar.dart';

// POI数据模型
class POI {
  final String id;
  final String name;
  final LatLng location;

  POI({
    required this.id,
    required this.name,
    required this.location,
  });

  factory POI.fromJson(Map<String, dynamic> json) {
    final locationParts = (json['location'] as String).split(',');
    return POI(
      id: json['id'],
      name: json['name'],
      location: LatLng(
        double.parse(locationParts[1]), // 纬度
        double.parse(locationParts[0]), // 经度
      ),
    );
  }
}

class CampusMapPage extends StatefulWidget {
  @override
  _CampusMapPageState createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage> {
  final DealController dealController = Get.find<DealController>();
  // 地图初始配置
  final LatLng _campusCenter = LatLng(23.088794, 113.354798); // 校园中心坐标
  final double _minZoom = 17.0;
  final double _maxZoom = 18.0;
  final double _initZoom = 17.5;

  // 地图控制器
  late MapController _mapController;

  // 状态管理
  List<POI> _poiList = [];
  LatLng? _selectedLocation;
  bool _isLoading = true;
  String? _errorMessage;

  // 距离计算工具
  final Distance _distanceCalculator = Distance();
  String place = '交易地点';

  @override
  void initState() {
    super.initState();
    _fetchPOIData();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // 获取POI数据
  Future<void> _fetchPOIData() async {
    try {
      final response = await Dio().get(
        'https://restapi.amap.com/v3/place/text',
        queryParameters: {
          'keywords': '广东财经大学(广州校区)',
          'city': '广州',
          'offset': 50,
          'page': 1,
          'key': '3f2f5c596f218f7c8458f2a2d25f63c1',
          'extensions': 'base',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> pois = response.data['pois'];
        setState(() {
          _poiList = pois.map((json) => POI.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '数据加载失败: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '连接错误: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // 地图点击处理
  void _handleMapTap(LatLng tapPosition) {
    if (_poiList.isEmpty) return;

    // 寻找最近POI
    POI? nearestPOI;
    double minDistance = double.infinity;

    for (final poi in _poiList) {
      final distance = _distanceCalculator(tapPosition, poi.location);
      if (distance < minDistance) {
        minDistance = distance;
        nearestPOI = poi;
      }
    }

    if (nearestPOI != null) {
      _selectedLocation = tapPosition;
      place = '${nearestPOI.name} (距离大约 ${minDistance.toStringAsFixed(0)} 米)';
      setState(() {});
    }
  }

  // 重置视角到校园中心
  void _resetView() {
    _mapController.move(
      _campusCenter,
      _initZoom,
      id: 'resetView',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackColor,
      body: Stack(
        children: [
          _buildMapContent(),
          Column(
            children: [
              HeadBar(title: '选择交易地点', canBack: true),
              Stack(
                children: [
                  Positioned(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                        child: Container(
                          height: 160.h,
                          width: 1.sw,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1.sw,
                    height: 160.h,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '📍',
                          style: TextStyle(fontSize: 80.w),
                        ),
                        Container(
                          width: 0.68.sw,
                          child: Text(
                            place,
                            style: TextStyle(
                              fontSize: 38.sp,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        CupertinoButton(
                          onPressed: () {
                            setState(() {
                              place = '交易地点';
                              _selectedLocation = null;
                            });
                          },
                          padding: EdgeInsets.zero,
                          child: Icon(
                            CupertinoIcons.gobackward,
                            color: Colors.black,
                            size: 70.w,
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Container(
                          width: 2.w,
                          height: 100.h,
                          color: kDevideColor,
                        ),
                        SizedBox(width: 20.w),
                        CupertinoButton(
                          onPressed: () {
                            _resetView();
                          },
                          padding: EdgeInsets.zero,
                          child: Icon(
                            CupertinoIcons.location,
                            color: Colors.black,
                            size: 70.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: 1.sw,
                height: 2.h,
                color: kDevideColor,
              ),
            ],
          ),
          Positioned(
            top: 80.h,
            right: 40.w,
            child: CupertinoButton(
              onPressed: () {
                if (_selectedLocation == null) {
                  return;
                }
                dealController.location.value = place;
                Get.back();
              },
              padding: EdgeInsets.zero,
              pressedOpacity: _selectedLocation != null ? 0.4 : 1,
              child: Text(
                '确定',
                style: TextStyle(
                  fontSize: 45.sp,
                  fontWeight: FontWeight.bold,
                  color: _selectedLocation != null ? kMainColor : kGrey,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMapContent() {
    if (_isLoading) {
      return Center(child: CupertinoActivityIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _campusCenter,
            zoom: _initZoom,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
            onTap: (tapPosition, latlng) => _handleMapTap(latlng),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'http://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
              subdomains: ['1', '2', '3', '4'],
              userAgentPackageName: 'com.example.campus_map',
            ),
            MarkerLayer(
              markers: [
                // 所有POI标记
                ..._poiList.map((poi) => Marker(
                      width: 80.w,
                      height: 40.h,
                      point: poi.location,
                      builder: (ctx) => Icon(
                        CupertinoIcons.placemark_fill,
                        color: CupertinoColors.systemBlue,
                        size: 60.w,
                      ),
                    )),
                // 用户点击标记
                if (_selectedLocation != null)
                  Marker(
                    height: 260.h,
                    width: 130.w,
                    point: _selectedLocation!,
                    builder: (ctx) => Text(
                      '📍',
                      style: TextStyle(
                        fontSize: 100.sp,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(1, 2),
                          )
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
