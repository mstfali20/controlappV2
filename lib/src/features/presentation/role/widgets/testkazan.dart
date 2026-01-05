import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// INTERACTIVE BOILER MAP
///  - Harita gibi pan/zoom
///  - Hotspot'lara tıklayınca otomatik yakınlaşma (focus)
///  - Değerler `data` (ör: anaAnlikVeriMap) üzerinden okunur
///  - Hotspot koordinatları YÜZDE (0..1) olarak tanımlanır, resimden bağımsızdır
/// ---------------------------------------------------------------------------

class InteractiveBoilerMap extends StatefulWidget {
  const InteractiveBoilerMap({
    super.key,
    required this.imageAsset,
    required this.hotspots,
    required this.data,
    this.minScale = 1.0,
    this.maxScale = 5.0,
    this.initialScale,
    this.background,
    this.heroTag,
    this.aspectRatio,
  });

  final String imageAsset;
  final List<HotspotConfig> hotspots;
  final Map<String, dynamic> data;
  final double minScale;
  final double maxScale;
  final double? initialScale;
  final Color? background;
  final Object? heroTag;
  final double? aspectRatio; // Eğer verilirse içerideki AspectRatio buna uyar

  @override
  State<InteractiveBoilerMap> createState() => _InteractiveBoilerMapState();
}

class _InteractiveBoilerMapState extends State<InteractiveBoilerMap>
    with SingleTickerProviderStateMixin {
  final TransformationController _tc = TransformationController();
  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  Animation<Matrix4>? _zoomAnim;

  Size _viewport = Size.zero;
  Size _imageLogicalSize = Size.zero;

  int? _selectedIndex;
  bool _fitApplied = false;
  bool _pendingFit = false;
  bool _isZoomed = false;
  Matrix4? _baseMatrix;
  Offset? _lastDoubleTapPos;

  static const double _kDefaultAspectRatio = 3 / 2;
  static const double _baseWidth = 1200.0;
  static const double _infoOutsideOffset = 72.0;

  @override
  void initState() {
    super.initState();
    _tc.addListener(_onMatrixChanged);
    if (widget.initialScale != null) {
      _tc.value = Matrix4.identity()..scale(widget.initialScale!);
    }
  }

  @override
  void didUpdateWidget(covariant InteractiveBoilerMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.aspectRatio != oldWidget.aspectRatio) {
      _fitApplied = false;
      _pendingFit = false;
    }
  }

  @override
  void dispose() {
    _tc.removeListener(_onMatrixChanged);
    _animController.dispose();
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = Size(constraints.maxWidth, constraints.maxHeight);

        final core = InteractiveViewer(
          transformationController: _tc,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          panEnabled: true,
          scaleEnabled: true,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(800),
          clipBehavior: Clip.none,
          child: _contentWithHotspots(context),
          onInteractionStart: (_) => _zoomAnim?.removeListener(_tick),
          onInteractionEnd: (_) => _handleInteractionEnd(),
        );

        if (!_fitApplied && !_pendingFit) {
          _pendingFit = true;
          final aspect = widget.aspectRatio ?? _kDefaultAspectRatio;
          final viewportSize =
              Size(constraints.maxWidth, constraints.maxHeight);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _applyInitialFit(viewportSize, aspect);
            _pendingFit = false;
          });
        }

        Widget baseViewer = DecoratedBox(
          decoration: BoxDecoration(color: widget.background ?? Colors.black12),
          child: GestureDetector(
            onDoubleTapDown: (details) =>
                _lastDoubleTapPos = details.localPosition,
            onDoubleTap: _handleDoubleTap,
            child: core,
          ),
        );

        Widget viewer = widget.heroTag != null
            ? Hero(tag: widget.heroTag!, child: baseViewer)
            : baseViewer;

        viewer = ClipRRect(
          borderRadius: BorderRadius.circular(32),
          clipBehavior: Clip.antiAlias,
          child: viewer,
        );

        final List<Widget> children = [viewer];

        final overlay = _buildInfoOverlay(context);
        if (overlay != null) {
          children.add(overlay);
        }

        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }

  Widget _contentWithHotspots(BuildContext context) {
    final aspect = widget.aspectRatio ?? _kDefaultAspectRatio;
    final width = _baseWidth;
    final height = width / aspect;
    _imageLogicalSize = Size(width, height);

    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                widget.imageAsset,
                fit: BoxFit.fill,
              ),
            ),
            ..._buildHotspots(context),
          ],
        ),
      ),
    );
  }

  void _applyInitialFit(Size viewport, double aspect) {
    if (viewport.width <= 0 || viewport.height <= 0) {
      return;
    }
    final imageWidth = _baseWidth;
    final imageHeight = imageWidth / aspect;
    final sx = viewport.width / imageWidth;
    final sy = viewport.height / imageHeight;
    final scale = math.min(sx, sy).clamp(widget.minScale, widget.maxScale);
    final dx = (viewport.width - imageWidth * scale) / 2;
    final dy = (viewport.height - imageHeight * scale) / 2;

    final matrix = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);

    _baseMatrix = matrix.clone();
    _tc.value = matrix;
    _fitApplied = true;
    _updateZoomFlag();
  }

  List<Widget> _buildHotspots(BuildContext context) {
    return [
      for (int i = 0; i < widget.hotspots.length; i++)
        _HotspotButton(
          key: ValueKey('hotspot_$i'),
          cfg: widget.hotspots[i],
          imageSize: _imageLogicalSize,
          onTap: () => _focusOn(i),
          valueText: _valueText(widget.hotspots[i]),
          isSelected: i == _selectedIndex,
        ),
    ];
  }

  String _valueText(HotspotConfig cfg) {
    final raw = widget.data[cfg.dataKey];
    if (raw == null || raw == '#' || raw.toString().trim().isEmpty) return '--';
    final v = _shorten(raw.toString());
    return cfg.unit == null || cfg.unit!.isEmpty ? v : '$v ${cfg.unit}';
  }

  String _shorten(String x) {
    // Küçük bir kısaltma/formatlama yardımı (örn. 23.4567 -> 23.46)
    final asNum = double.tryParse(x.replaceAll(',', '.'));
    if (asNum == null) return x;
    return asNum.toStringAsFixed(asNum.abs() >= 100 ? 1 : 2);
  }

  void _focusOn(int index) {
    setState(() => _selectedIndex = index);

    final cfg = widget.hotspots[index];

    // Hedef dikdörtgeni hesapla (resim koordinatları cinsinden)
    final w = _imageLogicalSize.width;
    final h = _imageLogicalSize.height;
    final targetW = (cfg.focusW ?? 0.22) * w;
    final targetH = (cfg.focusH ?? 0.22) * h;
    final cx = (cfg.x.clamp(0.0, 1.0)) * w;
    final cy = (cfg.y.clamp(0.0, 1.0)) * h;

    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: targetW,
      height: targetH,
    );

    _animateToRect(rect);
  }

  void _animateToRect(Rect target) {
    final viewW = _viewport.width;
    final viewH = _viewport.height;

    if (viewW <= 0 || viewH <= 0 || _imageLogicalSize.isEmpty) return;

    // Ekrana sığacak ölçek
    final sx = viewW / target.width;
    final sy = viewH / target.height;
    var scale = math.min(sx, sy);
    scale = scale.clamp(widget.minScale, widget.maxScale);

    // Hedef translate: hedef rect merkezde olacak şekilde
    final tx = -target.left * scale + (viewW - target.width * scale) / 2;
    final ty = -target.top * scale + (viewH - target.height * scale) / 2;

    final targetM = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);

    _animateToMatrix(targetM);
  }

  void _animateToMatrix(Matrix4 target) {
    _zoomAnim = Matrix4Tween(
      begin: _tc.value.clone(),
      end: target,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic))
      ..addListener(_tick);

    _animController
      ..reset()
      ..forward();
  }

  void _onMatrixChanged() => _updateZoomFlag();

  void _updateZoomFlag() {
    final scale = _matrixScale(_tc.value);
    final baseScale =
        _baseMatrix != null ? _matrixScale(_baseMatrix!) : widget.minScale;
    final zoomed = (scale - baseScale).abs() > 0.1;
    if (zoomed != _isZoomed) {
      setState(() => _isZoomed = zoomed);
    }
  }

  void _handleInteractionEnd() {
    final scale = _matrixScale(_tc.value);
    if (_baseMatrix != null && scale <= widget.minScale + 0.02) {
      _animateToMatrix(_baseMatrix!);
    }
  }

  void _handleDoubleTap() {
    final tap = _lastDoubleTapPos;
    final currentScale = _matrixScale(_tc.value);

    if (currentScale > widget.minScale + 0.1 && _baseMatrix != null) {
      if (_selectedIndex != null) {
        setState(() => _selectedIndex = null);
      }
      _animateToMatrix(_baseMatrix!);
      _lastDoubleTapPos = null;
      return;
    }

    if (tap == null) {
      if (_baseMatrix != null) {
        if (_selectedIndex != null) {
          setState(() => _selectedIndex = null);
        }
        _animateToMatrix(_baseMatrix!);
      }
      _lastDoubleTapPos = null;
      return;
    }

    final targetScale =
        (currentScale * 2).clamp(widget.minScale, widget.maxScale);
    final scaleFactor = targetScale / currentScale;

    final matrix = _tc.value.clone()
      ..translate(-tap.dx, -tap.dy)
      ..scale(scaleFactor)
      ..translate(tap.dx, tap.dy);

    _animateToMatrix(matrix);
    if (_selectedIndex != null) {
      setState(() => _selectedIndex = null);
    }
    _lastDoubleTapPos = null;
  }

  double _matrixScale(Matrix4 m) => m.storage[0];

  void _tick() {
    final m = _zoomAnim?.value;
    if (m != null) _tc.value = m;
  }

  Widget? _buildInfoOverlay(BuildContext context) {
    final idx = _selectedIndex;
    if (idx == null) {
      return null;
    }

    final cfg = widget.hotspots[idx];
    final value = _valueText(cfg);

    final safeBottom = MediaQuery.of(context).padding.bottom;
    final hasRoomBelow =
        (_viewport.height - _imageLogicalSize.height) > _infoOutsideOffset;
    final showOutside = !_isZoomed && hasRoomBelow;
    final bottomOffset = showOutside ? -_infoOutsideOffset : safeBottom + 16;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomOffset,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _InfoBar(
            icon: cfg.icon,
            title: cfg.label,
            value: value,
            onClose: () => setState(() => _selectedIndex = null),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// HOTSPOT CONFIG
/// ---------------------------------------------------------------------------
class HotspotConfig {
  const HotspotConfig({
    required this.id,
    required this.label,
    required this.dataKey,
    required this.x,
    required this.y,
    this.focusW,
    this.focusH,
    this.icon = Icons.circle,
    this.badgeColor,
    this.markerAlign = Alignment.topCenter,
  });

  final String id; // benzersiz id
  final String label; // "Sıcaklık" gibi
  final String dataKey; // anaAnlikVeriMap key'i
  final double x; // 0..1 (resim sol=0, sağ=1)
  final double y; // 0..1 (resim üst=0, alt=1)
  final double? focusW; // 0..1 (yakınlaşma alanı genişliği)
  final double? focusH; // 0..1 (yakınlaşma alanı yüksekliği)
  final IconData icon; // gösterim ikonu
  final Color? badgeColor; // marker rengi
  final Alignment markerAlign; // balon hizası
  String? get unit => _unitForKey(dataKey);

  static String? _unitForKey(String k) {
    // Basit bir eşleştirme (gerekirse genişletin)
    final lower = k.toLowerCase();
    if (lower.contains('nem')) return '%';
    if (lower.contains('sicak')) return '°C';
    if (lower.contains('basinc')) return 'bar';
    if (lower.contains('debi') || lower.contains('flow')) return 'm³/h';
    return null;
  }
}

/// ---------------------------------------------------------------------------
/// UI WIDGETS
/// ---------------------------------------------------------------------------
class _HotspotButton extends StatelessWidget {
  const _HotspotButton({
    super.key,
    required this.cfg,
    required this.imageSize,
    required this.onTap,
    required this.valueText,
    required this.isSelected,
  });

  final HotspotConfig cfg;
  final Size imageSize;
  final VoidCallback onTap;
  final String valueText;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (imageSize.isEmpty) return const SizedBox.shrink();

    final dx = cfg.x.clamp(0.0, 1.0) * imageSize.width;
    final dy = cfg.y.clamp(0.0, 1.0) * imageSize.height;

    final bubble = _MarkerBubble(
      icon: cfg.icon,
      label: cfg.label,
      value: valueText,
      color: cfg.badgeColor,
      isSelected: isSelected,
    );

    return Positioned(
      left: dx,
      top: dy,
      child: Align(
        alignment: cfg.markerAlign,
        child: GestureDetector(
          onTap: onTap,
          child: bubble,
        ),
      ),
    );
  }
}

class _MarkerBubble extends StatelessWidget {
  const _MarkerBubble({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSelected,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bg = (color ?? Colors.white).withOpacity(isSelected ? 1 : 0.92);
    final border = isSelected ? Colors.black87 : Colors.black26;

    return Material(
      elevation: isSelected ? 8 : 3,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: isSelected ? 1.2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.blueGrey.shade700),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBar extends StatelessWidget {
  const _InfoBar({
    required this.icon,
    required this.title,
    required this.value,
    required this.onClose,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.55),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// ÖRNEK KULLANIM (KazanWidget içine entegre)
/// ---------------------------------------------------------------------------
class KazanInteractiveSection extends StatefulWidget {
  const KazanInteractiveSection({super.key, required this.data});
  final Map<String, dynamic> data; // anaAnlikVeriMap gönderin

  @override
  State<KazanInteractiveSection> createState() =>
      _KazanInteractiveSectionState();
}

class _KazanInteractiveSectionState extends State<KazanInteractiveSection> {
  static const _imageAsset = 'assets/mimik/kazan.png';
  static const _heroTag = 'kazan-hero';

  double? _aspectRatio; // küçük görünüm için resmin oranı
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    _resolveAspectRatio();
  }

  void _resolveAspectRatio() {
    if (_resolving || _aspectRatio != null) return;
    _resolving = true;
    final ImageStream stream =
        const AssetImage(_imageAsset).resolve(const ImageConfiguration());
    ImageStreamListener? listener;
    listener = ImageStreamListener((imageInfo, _) {
      if (!mounted) {
        _resolving = false;
        stream.removeListener(listener!);
        return;
      }
      setState(() {
        _aspectRatio =
            imageInfo.image.width / imageInfo.image.height.toDouble();
        _resolving = false;
      });
      stream.removeListener(listener!);
    }, onError: (error, stackTrace) {
      _resolving = false;
      stream.removeListener(listener!);
    });
    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    final aspect = _aspectRatio ?? 3 / 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context).size;
        final maxWidth =
            constraints.hasBoundedWidth ? constraints.maxWidth : media.width;
        final maxHeight =
            constraints.hasBoundedHeight ? constraints.maxHeight : media.height;
        final available = Size(maxWidth, maxHeight);
        final fitted = _fittedSize(available, aspect);

        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: fitted.width,
                height: fitted.height,
                child: InteractiveBoilerMap(
                  imageAsset: _imageAsset,
                  heroTag: _heroTag,
                  data: widget.data,
                  hotspots: _boilerHotspots(),
                  minScale: 0.5,
                  maxScale: 6,
                  background: Colors.white,
                  aspectRatio: aspect,
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Material(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  child: IconButton(
                    icon: const Icon(Icons.open_in_full, color: Colors.white),
                    onPressed: _openFullScreen,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openFullScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, __, ___) => BoilerFullscreenPage(
          data: widget.data,
          aspectRatio: _aspectRatio,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Size _fittedSize(Size available, double aspect) {
    double width = available.width;
    double height = available.height;

    if (!width.isFinite || width <= 0) {
      width = height.isFinite && height > 0 ? height * aspect : 400;
    }
    if (!height.isFinite || height <= 0) {
      height = width / aspect;
    }
    double fittedWidth = width;
    double fittedHeight = fittedWidth / aspect;
    if (fittedHeight > height) {
      fittedHeight = height;
      fittedWidth = fittedHeight * aspect;
    }
    return Size(fittedWidth, fittedHeight);
  }
}

/// Tam ekran sayfa: EKRANI %100 kaplar ve geri tuşu doğal şekilde çalışır.
class BoilerFullscreenPage extends StatelessWidget {
  const BoilerFullscreenPage({super.key, required this.data, this.aspectRatio});

  static const _imageAsset = 'assets/mimik/kazan.png';
  static const _heroTag = 'kazan-hero';
  final Map<String, dynamic> data;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final aspect = aspectRatio ?? 3 / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Tam ekranı doldurur
            Positioned.fill(
              child: InteractiveBoilerMap(
                imageAsset: _imageAsset,
                heroTag: _heroTag,
                data: data,
                hotspots: _boilerHotspots(),
                minScale: 0.5,
                maxScale: 8,
                background: Colors.black,
                aspectRatio: aspect,
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Material(
                color: Colors.black.withOpacity(0.6),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<HotspotConfig> _boilerHotspots() {
  // Not: x,y koordinatlarını görsele göre KENDİNİZE GÖRE ayarlayın.
  // Aşağıdaki değerler örnek/dummy'dir.
  return const [
    HotspotConfig(
      id: 'ana-kazan-sicaklik',
      label: 'Kazan Sıcaklığı',
      dataKey: 'IOKazanSicaklikGosterge',
      x: 0.52,
      y: 0.58,
      focusW: 0.24,
      focusH: 0.26,
      icon: Icons.local_fire_department,
    ),
    HotspotConfig(
      id: 'ana-kazan-basinci',
      label: 'Kazan Basıncı',
      dataKey: 'IOKazanBasinci',
      x: 0.58,
      y: 0.42,
      focusW: 0.22,
      focusH: 0.20,
      icon: Icons.speed,
    ),
    HotspotConfig(
      id: 'giris-sicaklik',
      label: 'Giriş Sıcaklığı',
      dataKey: 'IOKazanGirisSicaklik',
      x: 0.24,
      y: 0.63,
      focusW: 0.24,
      focusH: 0.22,
      icon: Icons.thermostat,
      markerAlign: Alignment.center,
    ),
    HotspotConfig(
      id: 'cikis-sicaklik',
      label: 'Çıkış Sıcaklığı',
      dataKey: 'IOKazanCikisSicaklik',
      x: 0.82,
      y: 0.60,
      focusW: 0.24,
      focusH: 0.22,
      icon: Icons.thermostat_auto,
      markerAlign: Alignment.center,
    ),
    HotspotConfig(
      id: 'ic-istem-nem',
      label: 'İç Ortam Nem',
      dataKey: 'IOSalonNemGosterge',
      x: 0.20,
      y: 0.78,
      focusW: 0.26,
      focusH: 0.24,
      icon: Icons.water_drop_outlined,
      markerAlign: Alignment.topCenter,
    ),
    HotspotConfig(
      id: 'dis-ortam-sicaklik',
      label: 'Dış Ortam Sıcaklığı',
      dataKey: 'IODisSicaklikGosterge',
      x: 0.80,
      y: 0.22,
      focusW: 0.24,
      focusH: 0.20,
      icon: Icons.ac_unit_outlined,
      markerAlign: Alignment.bottomCenter,
    ),
  ];
}

/// ---------------------------------------------------------------------------
/// Notlar:
/// - Tam ekran artık Dialog değil bir Route: geri tuşu doğal çalışır.
/// - Hero çakışmasını önlemek için sadece InteractiveBoilerMap içinde hero kullanılıyor.
/// - Tam ekranda aspectRatio = ekran oranı verildi; böylece görüntü alanı tamamını doldurur.
/// - İstersen `BoilerFullscreenPage` içine `final Map<String, dynamic> data;`
///   ekleyip `Navigator.push` ile verileni taşıyabilirsin.
/// ---------------------------------------------------------------------------
