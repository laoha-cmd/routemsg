import 'package:flutter/material.dart';

/// 隐私政策页面
///
/// 授权说明：
/// 本代码允许任何人免费使用、商用、修改和分发，无需保留此注释，
/// 但保留也无妨。祝您开发顺利！
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('引言'),
            _buildText(
              '欢迎使用我们的应用程序。我们非常重视您的隐私。本隐私政策旨在向您说明我们如何收集、使用、披露和保护您的个人信息。请您在使用我们的服务前，仔细阅读并了解本政策。',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('1. 我们收集的信息'),
            _buildText(
              '我们不收集任何信息，绝对！\n',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('2. 数据安全与收费'),
            _buildText(
              '局域网内通讯，数据采用AES对称加密，密钥每次启动生成一次。\n工具永久免费且开源。',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('5. 您的权利'),
            _buildText(
              '代码可以随意用前提是别害人，不能侵犯别人的权益！\n'
              '• 对于使用本项目代码的其他人或组织所有结果与本项目无关。\n'
              '• 其他就不重要了。\n',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('7. 联系我们'),
            InkWell(
              onTap: () {},
              child: _buildText(
                'Github\n',
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 辅助组件：章节标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // 辅助组件：正文文本
  Widget _buildText(String content) {
    return Text(
      content,
      style: const TextStyle(
        fontSize: 15,
        height: 1.6, // 行高，增加可读性
        color: Colors.black54,
      ),
    );
  }
}
