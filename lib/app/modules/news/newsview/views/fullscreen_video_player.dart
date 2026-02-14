import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/newsview_controller.dart';

class FullscreenVideoPlayer extends GetView<NewsviewController> {
  const FullscreenVideoPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // HAPUS SETTING ORIENTASI - Biarkan natural
    // Hanya hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return WillPopScope(
      onWillPop: () async {
        await controller.exitFullscreen();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          if (!controller.isVideoInitialized.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return GestureDetector(
            onTap: controller.toggleControls,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video player - centered and fitted
                Center(
                  child: AspectRatio(
                    aspectRatio:
                        controller.videoPlayerController!.value.aspectRatio,
                    child: VideoPlayer(controller.videoPlayerController!),
                  ),
                ),

                // Controls overlay
                if (controller.showControls.value ||
                    !controller.isVideoPlaying.value)
                  _buildControls(context),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          // Top bar with back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () async {
                      await controller.exitFullscreen();
                      Get.back();
                    },
                  ),
                  Expanded(
                    child: Text(
                      controller.news.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Center play/pause button
          GestureDetector(
            onTap: controller.togglePlayPause,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                controller.isVideoPlaying.value
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),

          const Spacer(),

          // Bottom controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar
                VideoProgressIndicator(
                  controller.videoPlayerController!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.red,
                    bufferedColor: Colors.white30,
                    backgroundColor: Colors.white10,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),

                // Time and buttons row
                Row(
                  children: [
                    // Current time
                    Text(
                      controller.formatDuration(
                        controller.videoPlayerController!.value.position,
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(width: 16),

                    // Play/Pause button
                    IconButton(
                      icon: Icon(
                        controller.isVideoPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: controller.togglePlayPause,
                    ),

                    const Spacer(),

                    // Duration
                    Text(
                      controller.formatDuration(
                        controller.videoPlayerController!.value.duration,
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
