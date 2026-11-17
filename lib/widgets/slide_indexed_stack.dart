import 'package:flutter/material.dart';

/// Equivalente a un [IndexedStack] con transición lateral al cambiar de hijo.
///
/// Todos los hijos se mantienen vivos (conservan estado y scroll), igual que
/// en un IndexedStack. Si el sistema tiene las animaciones desactivadas, el
/// cambio es instantáneo.
class SlideIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const SlideIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<SlideIndexedStack> createState() => _SlideIndexedStackState();
}

class _SlideIndexedStackState extends State<SlideIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _current;
  int? _previous;
  bool _disableAnimations = false;

  @override
  void initState() {
    super.initState();
    _current = widget.index;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
    )..addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    // Al terminar la animación, la pantalla saliente deja de pintarse
    if (status == AnimationStatus.completed && _previous != null && mounted) {
      setState(() => _previous = null);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void didUpdateWidget(SlideIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == _current) return;

    if (_disableAnimations) {
      _previous = null;
      _current = widget.index;
      _controller.value = 1.0;
    } else {
      _previous = _current;
      _current = widget.index;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            for (int i = 0; i < widget.children.length; i++) _buildChild(i, t),
          ],
        );
      },
    );
  }

  Widget _buildChild(int i, double t) {
    final isCurrent = i == _current;
    final isPrevious = i == _previous;
    final direction = _current > (_previous ?? _current) ? 1.0 : -1.0;
    final translation = isCurrent
        ? Offset(direction * (1 - t), 0)
        : isPrevious
            ? Offset(-direction * t, 0)
            : Offset.zero;

    // IMPORTANTE: la estructura de widgets es siempre la misma para todos los
    // hijos y estados; si cambiara, Flutter destruiría el estado de la pantalla.
    return Offstage(
      offstage: !(isCurrent || isPrevious),
      child: TickerMode(
        enabled: isCurrent || isPrevious,
        child: IgnorePointer(
          ignoring: !isCurrent,
          child: FractionalTranslation(
            translation: translation,
            child: widget.children[i],
          ),
        ),
      ),
    );
  }
}
