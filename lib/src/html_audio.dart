import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart' as lib;
import 'package:chewie_audio/chewie_audio.dart' as lib;
import 'package:video_player/video_player.dart' as lib;

class HtmlAudio extends StatefulWidget {
  final String url;

  final double aspectRatio;
  final bool autoResize;
  final bool autoplay;
  final bool controls;
  final bool loop;
  final Widget poster;

  HtmlAudio(
      this.url, {
        @required this.aspectRatio,
        this.autoResize = true,
        this.autoplay = false,
        this.controls = false,
        Key key,
        this.loop = false,
        this.poster,
      })  : assert(url != null),
        assert(aspectRatio != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _HtmlAudioState();
}

class _HtmlAudioState extends State<HtmlAudio> {
  _Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller = _Controller(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => lib.ChewieAudio(controller: _controller);

  void _onAspectRatioUpdated() => setState(() {});
}

class _Controller extends lib.ChewieAudioController {
  final _HtmlAudioState vps;

  double _aspectRatio;

  _Controller(this.vps)
      : super(
    autoInitialize: true,
    autoPlay: vps.widget.autoplay == true,
    looping: vps.widget.loop == true,
    showControls: vps.widget.controls == true,
    videoPlayerController: lib.VideoPlayerController.network(vps.widget.url),
  ) {
    if (vps.widget.autoResize) {
      _setupAspectRatioListener();
    }
  }

  @override
  double get aspectRatio => _aspectRatio ?? vps.widget.aspectRatio;

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  void _setupAspectRatioListener() {
    VoidCallback listener;

    listener = () {
      if (_aspectRatio == null) {
        final vpv = videoPlayerController.value;
        debugPrint('[_Controller]: vpv=$vpv');

        if (!vpv.initialized) return;
        _aspectRatio = vpv.aspectRatio;

        // workaround because we cannot call `vps.setState()` directly
        vps._onAspectRatioUpdated();
      }

      videoPlayerController.removeListener(listener);
    };

    videoPlayerController.addListener(listener);
  }
}
