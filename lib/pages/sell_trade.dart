import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:test/api/api.dart';
import 'package:test/api/trade.dart';
import 'package:test/constants/color.dart';
import 'package:test/controllers/trade.dart';
import 'package:test/controllers/user.dart';
import 'package:test/models/trade.dart';
import 'package:test/widgets/head_bar.dart';

class SellTradePage extends StatefulWidget {
  const SellTradePage({super.key});

  @override
  State<SellTradePage> createState() => _SellTradePageState();
}

class _SellTradePageState extends State<SellTradePage> {
  final UserController userController = Get.find<UserController>();
  final TradeController tradeController = Get.put(TradeController());

  String status = '';

  Future<void> loadSell({String status = ''}) async {
    await tradeController.loadSellList(sellerId: userController.id.value, status: status);
  }

  String statusZH(String status) {
    switch (status) {
      case 'Pending':
        return '待交易';
      case 'Completed':
        return '已完成';
      case 'Cancelled':
        return '已取消';
      default:
        return '-';
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Color(0xFF0082ef);
      case 'Completed':
        return Color(0xFF07c160);
      case 'Cancelled':
        return CupertinoColors.destructiveRed;
      default:
        return kMainColor;
    }
  }

  @override
  void initState() {
    loadSell();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Obx(
            () => Container(
              margin: EdgeInsets.fromLTRB(40.w, 250.h, 0, 0),
              child: tradeController.sellList.isEmpty
                  ? Center(
                      child: Text(
                        '暂无交易',
                        style: TextStyle(fontSize: 50.sp, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tradeController.sellList.length,
                      itemBuilder: (context, index) {
                        TradeModel item = tradeController.sellList[index];
                        return Container(
                          width: 1.sw,
                          padding: EdgeInsets.fromLTRB(0, 40.h, 40.w, 40.h),
                          margin:
                              EdgeInsets.fromLTRB(0, 10.h, 0, index == tradeController.sellList.length - 1 ? 150.h : 0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  bottom: BorderSide(
                                color: kDevideColor,
                                width: 2.h,
                              ))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  item.buyer != null
                                      ? Container(
                                          width: 90.w,
                                          height: 90.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                  replaceLocalhost(item.buyer!.avatar),
                                                ),
                                                fit: BoxFit.cover),
                                          ),
                                        )
                                      : Container(
                                          width: 90.w,
                                          height: 90.w,
                                          decoration: BoxDecoration(color: kGrey),
                                        ),
                                  SizedBox(width: 20.w),
                                  Text(
                                    item.buyer!.name,
                                    style: TextStyle(
                                      fontSize: 40.sp,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    statusZH(item.status),
                                    style: TextStyle(
                                      fontSize: 42.sp,
                                      color: statusColor(item.status),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30.h),
                              Row(
                                children: [
                                  Container(
                                    width: 200.w,
                                    height: 200.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          replaceLocalhost(item.images[0]),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 30.w),
                                  Container(
                                    width: 450.w,
                                    child: Text(
                                      item.name,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 40.sp,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\￥${item.price}',
                                        style: TextStyle(
                                          fontSize: 60.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (item.status == 'Pending') SizedBox(height: 20.h),
                                      if (item.status == 'Pending')
                                        CupertinoButton(
                                          onPressed: () async {
                                            await TradeApi.updateStatus(tradeId: item.id, status: 'Cancelled');
                                            await loadSell(status: status);
                                          },
                                          padding: EdgeInsets.zero,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 17.h),
                                            decoration: BoxDecoration(
                                              color: kMainColor,
                                              borderRadius: BorderRadius.circular(50.r),
                                            ),
                                            child: Text(
                                              '取消交易',
                                              style: TextStyle(
                                                fontSize: 35.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      '交易地点',
                                      style: TextStyle(
                                        fontSize: 37.sp,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    width: 0.7.sw,
                                    child: Text(
                                      item.location,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 37.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      '交易时间',
                                      style: TextStyle(
                                        fontSize: 37.sp,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    width: 0.7.sw,
                                    child: Text(
                                      item.tradeTime,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 37.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
            ),
          ),
          Positioned(
            top: 0,
            child: HeadBar(
              title: '我卖出的',
              canBack: true,
            ),
          ),
          Positioned(
              top: 180.h,
              child: Container(
                width: 1.sw,
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: kDevideColor, width: 2.h),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        onPressed: () {
                          loadSell(status: '');
                          setState(() {
                            status = '';
                          });
                        },
                        padding: EdgeInsets.zero,
                        child: Container(
                          child: Center(
                            child: Text(
                              '全部',
                              style: TextStyle(
                                fontSize: 37.sp,
                                color: Colors.black,
                                fontWeight: status == '' ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoButton(
                        onPressed: () {
                          loadSell(status: 'Pending');
                          setState(() {
                            status = 'Pending';
                          });
                        },
                        padding: EdgeInsets.zero,
                        child: Container(
                          child: Center(
                            child: Text(
                              '待交易',
                              style: TextStyle(
                                fontSize: 37.sp,
                                color: Colors.black,
                                fontWeight: status == 'Pending' ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoButton(
                        onPressed: () {
                          loadSell(status: 'Completed');
                          setState(() {
                            status = 'Completed';
                          });
                        },
                        padding: EdgeInsets.zero,
                        child: Container(
                          child: Center(
                            child: Text(
                              '已完成',
                              style: TextStyle(
                                fontSize: 37.sp,
                                color: Colors.black,
                                fontWeight: status == 'Completed' ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoButton(
                        onPressed: () {
                          loadSell(status: 'Cancelled');
                          setState(() {
                            status = 'Cancelled';
                          });
                        },
                        padding: EdgeInsets.zero,
                        child: Container(
                          child: Center(
                            child: Text(
                              '已取消',
                              style: TextStyle(
                                fontSize: 37.sp,
                                color: Colors.black,
                                fontWeight: status == 'Cancelled' ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
