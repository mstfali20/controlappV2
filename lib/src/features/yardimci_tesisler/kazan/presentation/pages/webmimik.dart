// // lib/src/features/presentation/role/widgets/web_mimik_inline.dart
// import 'dart:io' show Platform;
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebMimikInline extends StatefulWidget {
//   const WebMimikInline({
//     super.key,
//     required this.url,
//     this.showToolbar = true,
//   });

//   final String url;
//   final bool showToolbar;

//   @override
//   State<WebMimikInline> createState() => _WebMimikInlineState();
// }

// class _WebMimikInlineState extends State<WebMimikInline> {
//   late final WebViewController _controller;
//   int _progress = 0;
//   double _cssScale = 1.0;

//   static const _iosSafariUA =
//       'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
//       'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
//       'Mobile/15E148 Safari/604.1';

//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..enableZoom(true) // pinch-zoom
//       ..setBackgroundColor(Colors.white)
//       ..setNavigationDelegate(
//         NavigationDelegate(onProgress: (p) => setState(() => _progress = p)),
//       )
//       ..loadRequest(Uri.parse(widget.url));

//     if (Platform.isIOS) {
//       _controller.setUserAgent(_iosSafariUA);
//     }
//   }

//   Future<void> _applyCssScale(double s) async {
//     _cssScale = s.clamp(0.5, 5.0);
//     final js = """
//       (function(){
//         document.documentElement.style.zoom='$_cssScale';
//         document.body.style.zoom='$_cssScale';
//         document.documentElement.style.overflow='auto';
//         document.body.style.overflow='auto';
//       })();
//     """;
//     try {
//       await _controller.runJavaScript(js);
//     } catch (_) {}
//     if (mounted) setState(() {});
//   }

//   void _zoomIn() => _applyCssScale(_cssScale + 0.2);
//   void _zoomOut() => _applyCssScale(_cssScale - 0.2);
//   void _reset() => _applyCssScale(1.0);

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned.fill(child: WebViewWidget(controller: _controller)),
//         if (_progress < 100)
//           const Align(
//             alignment: Alignment.topCenter,
//             child: LinearProgressIndicator(minHeight: 3),
//           ),
//         if (widget.showToolbar)
//           Positioned(
//             right: 10,
//             bottom: 12,
//             child: DecoratedBox(
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.55),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(mainAxisSize: MainAxisSize.min, children: [
//                 IconButton(
//                   tooltip: 'Uzaklaştır',
//                   icon: const Icon(Icons.zoom_out, color: Colors.white),
//                   onPressed: _zoomOut,
//                 ),
//                 IconButton(
//                   tooltip: 'Yakınlaştır',
//                   icon: const Icon(Icons.zoom_in, color: Colors.white),
//                   onPressed: _zoomIn,
//                 ),
//                 IconButton(
//                   tooltip: 'Sıfırla',
//                   icon: const Icon(Icons.center_focus_strong,
//                       color: Colors.white),
//                   onPressed: _reset,
//                 ),
//                 IconButton(
//                   tooltip: 'Yenile',
//                   icon: const Icon(Icons.refresh, color: Colors.white),
//                   onPressed: () => _controller.reload(),
//                 ),
//               ]),
//             ),
//           ),
//       ],
//     );
//   }
// }
