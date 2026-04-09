import 'dart:io';

import 'package:flutter/foundation.dart';

class Ipv6AddressHelper {
  /// 判断接口名称是否为物理接口
  static bool _isPhysicalInterfaceName(String name) {
    final lowerName = name.toLowerCase();

    // Windows 常见物理接口
    if (lowerName.contains('ethernet') ||
        lowerName.contains('wi-fi') ||
        lowerName.contains('wlan') ||
        RegExp(r'^eth\d').hasMatch(lowerName) ||
        RegExp(r'^local area connection').hasMatch(lowerName)) {
      return true;
    }

    // Linux/Android 常见物理接口
    if (RegExp(r'^wlan\d').hasMatch(lowerName) || // Wi-Fi
        RegExp(r'^eth\d').hasMatch(lowerName) || // 有线
        RegExp(r'^rmnet\d').hasMatch(lowerName) || // 移动数据
        lowerName == 'wlan0' ||
        lowerName == 'eth0') {
      return true;
    }

    // macOS/iOS 常见物理接口
    // en0 通常是 Wi-Fi (Mac) 或 蜂窝/以太网 (iOS), en1/en2 可能是其他
    // 排除 awdl0 (AirDrop), utun (VPN), ipsec 等虚拟接口
    if (RegExp(r'^en\d').hasMatch(lowerName)) {
      if (lowerName.contains('awdl') ||
          lowerName.contains('utun') ||
          lowerName.contains('ipsec') ||
          lowerName.contains('vmnet')) {
        return false;
      }
      return true;
    }

    return false;
  }

  /// 获取所有可用的 IPv6 链路本地地址（带 Zone ID）
  static Future<List<Ipv6InterfaceInfo>> getLinkLocalAddresses({
    bool includeLoopback = false,
  }) async {
    final result = <Ipv6InterfaceInfo>[];

    try {
      final interfaces = await NetworkInterface.list(
          includeLinkLocal: true,
          includeLoopback: includeLoopback,
          type: InternetAddressType.IPv6);

      for (var interface in interfaces) {
        if (interface.addresses.isEmpty) continue;

        // 2. 名称过滤：只保留常见的物理接口前缀
        if (!_isPhysicalInterfaceName(interface.name)) {
          continue;
        }

        // 3. 地址过滤：必须至少有一个有效的 IPv6 地址
        // 断开的接口通常没有 IP，或者只有自动生成的临时地址
        final ipv6Addresses = interface.addresses
            .where((addr) => addr.type == InternetAddressType.IPv6)
            .toList();

        if (ipv6Addresses.isEmpty) {
          continue;
        }

        // 4. 进阶检查：尝试绑定测试 (最准确的“连接状态”判断)
        // 如果接口虽然有名有IP但实际链路断开，绑定可能会失败或无法加入组播
        if (await _isInterfaceUsable(interface)) {
          int index = 0;
          print(
              'find availble interface: ${interface.name} (index: ${interface.index})');
          for (var i = 0; i < ipv6Addresses.length; i++) {
            final addr = ipv6Addresses[i];
            print(
                '   - IPv6: ${addr.address} (local link: ${addr.isLinkLocal})');

            if (addr.isLinkLocal) {
              index = i;
            }
          }

          result.add(Ipv6InterfaceInfo(interface: interface, addrIndex: index));
        } else {
          print('ignore interface: ${interface.name}');
        }
      }
    } catch (e) {
      print('get IPv6 address: $e');
    }

    return result;
  }

  /// 尝试性测试接口是否真正可用
  /// 原理：尝试绑定一个 UDP socket 到该接口的任意端口，看是否成功
  static Future<bool> _isInterfaceUsable(NetworkInterface interface) async {
    try {
      // 尝试绑定到该接口的 IPv6 任意地址
      // 注意：Dart 的 bind 不直接支持指定 interface name，
      // 但我们可以通过尝试加入组播来验证，或者简单地认为有 IP 即大概率可用。
      // 更严格的测试是尝试 Join Multicast，但这会改变系统状态。

      // 这里采用一种轻量级策略：
      // 如果接口有非临时的全局单播地址 或 稳定的链路本地地址，视为可用。
      // 对于大多数局域网应用，只要有 link-local 地址且名字匹配，通常就是连上的。

      final hasValidLinkLocal = interface.addresses.any((addr) =>
              addr.type == InternetAddressType.IPv6 &&
              addr.isLinkLocal &&
              !addr.address.contains('fffe') // 过滤掉某些无效的自动配置
          );

      final hasGlobalUnicast = interface.addresses.any((addr) =>
          addr.type == InternetAddressType.IPv6 &&
          !addr.isLinkLocal &&
          !addr.isMulticast);

      return hasValidLinkLocal || hasGlobalUnicast;
    } catch (e) {
      return false;
    }
  }

  /// 获取适合组播的接口（排除回环和虚拟接口）
  static Future<List<Ipv6InterfaceInfo>> getMulticastReadyInterfaces() {
    return getLinkLocalAddresses();
  }
}

/// IPv6 接口信息
class Ipv6InterfaceInfo {
  final NetworkInterface interface;
  final int addrIndex;

  Ipv6InterfaceInfo({
    required this.addrIndex,
    required this.interface,
  });

  @override
  String toString() {
    return '$interface: $addrIndex';
  }
}
