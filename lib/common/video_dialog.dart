import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoDialog extends StatefulWidget {
  final String videoPath;
  const VideoDialog(this.videoPath, {super.key});

  @override
  _VideoDialogState createState() => _VideoDialogState();
}

class _VideoDialogState extends State<VideoDialog> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(File(widget.videoPath));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _controller.setLooping(true);
          _controller.setVolume(1.0);
          _controller.play();
        });
      }
    }).catchError((error) {
      debugPrint("视频初始化失败: $error");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 提取文件名的辅助方法
  String _getFileName(String path) {
    try {
      return Uri.parse(path).pathSegments.last;
    } catch (e) {
      return path.split('/').last;
    }
  }

  void _closeDialog() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕高度，用于计算最大可用空间
    final screenHeight = MediaQuery.of(context).size.height;
    // 设置视频区域的最大高度（例如：屏幕高度的 60%，或者固定最大值 400）
    // 留出空间给 Title, 控制按钮和对话框内边距
    final maxVideoHeight = screenHeight * 0.6;

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      title: Row(
        children: [
          Expanded(
            child: Text(
              _getFileName(widget.videoPath),
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: _closeDialog,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      // 关键修改 1: 使用 SingleChildScrollView 包裹内容，防止硬溢出导致红屏
      // 如果视频太大，用户可以滚动查看（虽然视频通常不希望滚动，但这能消除报错）
      // 更好的方式是下面使用的 ConstrainedBox 强制限制高度
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text('视频加载失败: ${snapshot.error}',
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 关键修改 2: 使用 ConstrainedBox 限制最大高度
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: maxVideoHeight, // 限制最大高度
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.8, // 限制最大宽度
                        ),
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                                setState(() {});
                              } else {
                                _controller.play();
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // 加载中
                  return const SizedBox(
                    height: 200,
                    width: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      actions: null,
    );
  }
}
