import 'package:flutter/material.dart';

class ScrollViewPage extends StatefulWidget {
  const ScrollViewPage({super.key});

  @override
  State<ScrollViewPage> createState() => _ScrollViewPageState();
}

class _ScrollViewPageState extends State<ScrollViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollViewExample(),
    );
  }
}

class CustomScrollViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar 具有展开、折叠的功能
          SliverAppBar(
            shadowColor: Colors.transparent, // 也可以设置为透明来彻底去掉阴影
            expandedHeight: 300.0, // 展开时的高度
            toolbarHeight: 200,
            pinned: true, // 滚动时始终固定在顶部
            backgroundColor: Colors.transparent, // 设置背景颜色为透明
            elevation: 0, // 去掉阴影
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                double top = constraints.biggest.height;
                double scale =
                    (top - kToolbarHeight) / (200.0 - kToolbarHeight);
                // double opacity = scale.clamp(0.0, 1.0); // 确保透明度在 0.0 和 1.0 之间

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    child: Image.asset(
                      'assets/images/cate1.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),

          // SliverList 用于展示列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ListTile(
                  title: Text('Item #$index'),
                );
              },
              childCount: 20, // 设置列表项的数量
            ),
          ),

          // SliverGrid 用于创建网格布局
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 每行显示 2 个项目
              crossAxisSpacing: 10.0, // 水平间距
              mainAxisSpacing: 10.0, // 垂直间距
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Card(
                  color: Colors.blueAccent,
                  child: Center(
                    child: Text('Grid Item #$index'),
                  ),
                );
              },
              childCount: 10, // 设置网格项的数量
            ),
          ),

          // SliverFillRemaining 用于填充剩余空间
          SliverFillRemaining(
            child: Center(
              child: Text('这是填充剩余空间的区域'),
            ),
          ),
        ],
      ),
    );
  }
}
