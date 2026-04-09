import 'package:flutter/material.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 定义主题色
  final Color alipayColor = const Color(0xFF1677FF); // 支付宝蓝
  final Color wechatColor = const Color(0xFF07C160); // 微信绿

  @override
  void initState() {
    super.initState();
    // 初始化 TabController，长度为 2 (两个标签)
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫码打赏，请作者喝杯咖啡 ☕️'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(icon: Icon(Icons.payments), text: '支付宝'),
            Tab(icon: Icon(Icons.wechat), text: '微信'),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            const SizedBox(height: 20),
            // TabBarView 内容区域
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 支付宝页面
                  _buildQrCodeCard(
                    color: alipayColor,
                    assetName: 'assets/images/alipay_qr.jpg',
                    label: '支付宝扫码',
                    icon: Icons.payments,
                  ),
                  // 微信页面
                  _buildQrCodeCard(
                    color: wechatColor,
                    assetName: 'assets/images/wechat_qr.jpg',
                    label: '微信扫码',
                    icon: Icons.wechat,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                '感谢您的支持！',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建二维码卡片组件
  Widget _buildQrCodeCard({
    required Color color,
    required String assetName,
    required String label,
    required IconData icon,
  }) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 二维码图片区域
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _loadImage(assetName),
              )),
              const SizedBox(height: 20),
              // 底部文字和图标
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 加载图片逻辑（包含占位符处理）
  Widget _loadImage(String assetName) {
    // 在实际项目中，请确保 pubspec.yaml 中已注册 assets
    // 这里为了演示代码直接运行，如果图片不存在会显示一个灰色的占位框
    return Image.asset(
      assetName,
      fit: BoxFit.fitHeight,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code, size: 60, color: Colors.grey[500]),
                const SizedBox(height: 10),
                Text(
                  '暂无图片\n请替换为真实二维码',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
