import 'package:flutter/material.dart';
import 'package:routemsg/model/app.dart';

class RecommendPage extends StatelessWidget {
  const RecommendPage({super.key});

  // 模拟应用数据：包含图标、名称、简介、链接
  static const List<AppInfo> _apps = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('推荐应用'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 响应式宽度：最大宽度 1000，小屏幕则填满
            final double maxWidth =
                constraints.maxWidth > 1000 ? 1000 : constraints.maxWidth;
            return Center(
              child: Container(
                width: maxWidth,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  itemCount: _apps.length,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: (context, index) {
                    final app = _apps[index];
                    return _buildAppCard(context, app, index);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建单个应用卡片（响应式且适配桌面悬停效果）
  Widget _buildAppCard(BuildContext context, AppInfo app, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          child: Image.network(app.icon),
        ),
        title: Text(
          app.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.description,
                style: const TextStyle(fontSize: 14, height: 1.3),
              ),
              const SizedBox(height: 6),
              // 显示简洁的链接文本，可点击的提示
              Text(
                _formatUrl(app.url),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_browser),
          tooltip: '打开链接',
          onPressed: () {},
        ),
        onTap: () {},
        // 桌面端悬停时显示更明显的反馈
        hoverColor: Theme.of(context).hoverColor,
      ),
    );
  }

  /// 格式化链接，仅显示域名部分（更美观）
  String _formatUrl(String url) {
    try {
      final uri = Uri.parse(url);
      // 返回 host，例如 "maps.google.com"
      return uri.host.isEmpty ? url : uri.host;
    } catch (_) {
      return url;
    }
  }
}
