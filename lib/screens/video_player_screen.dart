// lib/screens/video_player_screen.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/media_file.dart';

class VideoPlayerScreen extends StatefulWidget {
  final MediaFile file;

  const VideoPlayerScreen({super.key, required this.file});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file.file)
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller.play();
      });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black.withOpacity(0.7),
              foregroundColor: Colors.white,
              title: Text(
                widget.file.title,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              centerTitle: true,
            )
          : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video
            _isInitialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B6914)),
                  ),

            // Controles superpuestos
            if (_showControls && _isInitialized)
              _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final position = _controller.value.position;
    final duration = _controller.value.duration;
    final isPlaying = _controller.value.isPlaying;

    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Barra de progreso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: const Color(0xFF8B6914),
                      thumbColor: const Color(0xFF8B6914),
                      inactiveTrackColor: Colors.white30,
                    ),
                    child: Slider(
                      value: duration.inMilliseconds > 0
                          ? position.inMilliseconds / duration.inMilliseconds
                          : 0.0,
                      onChanged: (val) {
                        _controller.seekTo(
                          Duration(milliseconds: (val * duration.inMilliseconds).round()),
                        );
                      },
                    ),
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),

          // Botones de control
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Retroceder 10s
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
                onPressed: () {
                  final newPos = position - const Duration(seconds: 10);
                  _controller.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
                },
              ),
              const SizedBox(width: 24),

              // Play / Pause
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF8B6914),
                ),
                child: IconButton(
                  iconSize: 48,
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    isPlaying ? _controller.pause() : _controller.play();
                  },
                ),
              ),
              const SizedBox(width: 24),

              // Avanzar 10s
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
                onPressed: () {
                  final newPos = position + const Duration(seconds: 10);
                  _controller.seekTo(newPos > duration ? duration : newPos);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Info del video
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B6914),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.file.categoryLabel.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.file.roomNumber != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Habitación ${widget.file.roomNumber}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
                const Spacer(),
                if (widget.file.description.isNotEmpty)
                  Flexible(
                    child: Text(
                      widget.file.description,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
