import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WebMimikPage extends StatefulWidget {
  const WebMimikPage({super.key, required this.url});
  final String url;

  @override
  State<WebMimikPage> createState() => _WebMimikPageState();
}

class _WebMimikPageState extends State<WebMimikPage> {
  late final WebViewController _controller;
  int _progress = 0;
  double _cssScale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true) // pinch-zoom açık
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(onProgress: (p) => setState(() => _progress = p)),
      )
      ..loadRequest(Uri.parse(widget.url));
    if (Platform.isIOS) {
      _controller.setUserAgent(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
        'Mobile/15E148 Safari/604.1',
      );
    }
  }

  Future<void> _applyCssScale(double s) async {
    _cssScale = s.clamp(0.5, 5.0);
    final js = """
      (function(){
        var html = document.documentElement, body = document.body;
        html.style.zoom = '$_cssScale';
        body.style.zoom = '$_cssScale';
        html.style.overflow = 'auto';
        body.style.overflow = 'auto';
        var vp = document.querySelector('meta[name="viewport"]');
        if (!vp){ vp = document.createElement('meta'); vp.name='viewport'; document.head.appendChild(vp); }
        vp.setAttribute('content','width=device-width, initial-scale=1.0, maximum-scale=5, user-scalable=yes');
      })();
    """;
    try {
      await _controller.runJavaScript(js);
    } catch (_) {}
    setState(() {});
  }

  Future<void> _fitToWidth() async {
    const js = """
      (function(){
        var w = window.innerWidth || document.documentElement.clientWidth;
        var sw = Math.max(
          document.documentElement.scrollWidth,
          document.body.scrollWidth,
          document.documentElement.clientWidth
        );
        var scale = (w / (sw || 1));
        if (scale > 1) scale = 1; // çok büyütme
        var html = document.documentElement, body = document.body;
        html.style.zoom = scale; body.style.zoom = scale;
        html.style.overflow='auto'; body.style.overflow='auto';
        return scale.toString();
      })();
    """;
    try {
      final res = await _controller.runJavaScriptReturningResult(js);
      final s = double.tryParse(res.toString().replaceAll('"', '')) ?? 1.0;
      setState(() => _cssScale = s);
    } catch (_) {}
  }

  void _zoomIn() => _applyCssScale(_cssScale + 0.2);
  void _zoomOut() => _applyCssScale(_cssScale - 0.2);
  void _reset() => _applyCssScale(1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Mimik'),
        actions: [
          IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (await _controller.canGoBack()) _controller.goBack();
              }),
          IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () async {
                if (await _controller.canGoForward()) _controller.goForward();
              }),
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload()),
          IconButton(
            tooltip: 'Tarayıcıda aç',
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => launchUrl(Uri.parse(widget.url),
                mode: LaunchMode.externalApplication),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _progress < 100
              ? LinearProgressIndicator(value: _progress / 100)
              : const SizedBox.shrink(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: WebViewWidget(controller: _controller)),
          Positioned(
            right: 12,
            bottom: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                    tooltip: 'Uzaklaştır',
                    icon: const Icon(Icons.zoom_out, color: Colors.white),
                    onPressed: _zoomOut),
                IconButton(
                    tooltip: 'Genişliğe sığdır',
                    icon: const Icon(Icons.fit_screen, color: Colors.white),
                    onPressed: _fitToWidth),
                IconButton(
                    tooltip: 'Yakınlaştır',
                    icon: const Icon(Icons.zoom_in, color: Colors.white),
                    onPressed: _zoomIn),
                IconButton(
                    tooltip: 'Sıfırla',
                    icon: const Icon(Icons.center_focus_strong,
                        color: Colors.white),
                    onPressed: _reset),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
