import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:sumberkerto_smart_village/app/data/models/news_model.dart';
import 'package:sumberkerto_smart_village/app/modules/news/newsview/views/fullscreen_video_player.dart';
import 'package:video_player/video_player.dart';

class NewsviewController extends GetxController {
  late NewsModel news;
  final creatorName = ''.obs;

  VideoPlayerController? videoPlayerController;
  final isVideoInitialized = false.obs;
  final isVideoPlaying = false.obs;
  final showControls = true.obs;
  final isFullscreen = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments is NewsModel) {
      news = Get.arguments as NewsModel;
      creatorName.value = news.createdBy.isNotEmpty
          ? news.createdBy
          : 'Anonymous';

      if (news.videoUrl != null && news.videoUrl!.isNotEmpty) {
        _initializeVideoPlayer();
      }
    }
  }

  void _initializeVideoPlayer() async {
    try {
      videoPlayerController = VideoPlayerController.network(news.videoUrl!);

      await videoPlayerController!.initialize();
      isVideoInitialized.value = true;

      videoPlayerController!.addListener(() {
        if (videoPlayerController!.value.isPlaying != isVideoPlaying.value) {
          isVideoPlaying.value = videoPlayerController!.value.isPlaying;
        }
      });
    } catch (e) {
      print('Error initializing video: $e');
      isVideoInitialized.value = false;
    }
  }

  void togglePlayPause() {
    if (videoPlayerController == null || !isVideoInitialized.value) return;

    if (videoPlayerController!.value.isPlaying) {
      videoPlayerController!.pause();
      isVideoPlaying.value = false;
    } else {
      videoPlayerController!.play();
      isVideoPlaying.value = true;

      // Hide controls after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (isVideoPlaying.value) {
          showControls.value = false;
        }
      });
    }
  }

  void toggleControls() {
    showControls.value = !showControls.value;

    if (showControls.value && isVideoPlaying.value) {
      Future.delayed(const Duration(seconds: 3), () {
        if (isVideoPlaying.value) {
          showControls.value = false;
        }
      });
    }
  }

  /// Exit fullscreen mode
  Future<void> exitFullscreen() async {
    isFullscreen.value = false;

    // Show system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    // Restore to allow all orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    print('Exiting fullscreen mode');
  }

  void seekTo(Duration position) {
    videoPlayerController?.seekTo(position);
  }

  Future<void> enterFullscreen() async {
    isFullscreen.value = true;

    print('Entering fullscreen...');

    // Allow all orientations - biarkan user putar HP sendiri
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Navigate to fullscreen
    Get.to(
      () => const FullscreenVideoPlayer(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 200),
    );

    print('Entering fullscreen mode - DONE');
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void toggleFullscreen() {
    if (isFullscreen.value) {
      exitFullscreen();
    } else {
      enterFullscreen();
    }
  }

  @override
  void onClose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    videoPlayerController?.dispose();

    print('NewsviewController disposed');
    super.onClose();
  }
}
