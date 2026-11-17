import 'package:flutter/material.dart';

class ExpressivePopupMenuButton<T> extends StatelessWidget {
  const ExpressivePopupMenuButton({
    super.key,
    required this.itemBuilder,
    this.onSelected,
    this.initialValue,
    this.icon,
    this.tooltip,
  });

  final PopupMenuItemBuilder<T> itemBuilder;
  final ValueChanged<T>? onSelected;
  final T? initialValue;
  final Widget? icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<T>(
      itemBuilder: itemBuilder,
      onSelected: onSelected,
      initialValue: initialValue,
      icon: icon,
      tooltip: tooltip,
      color: colors.surfaceContainerHigh,
      surfaceTintColor: colors.surfaceTint,
      shadowColor: colors.shadow.withValues(alpha: 0.16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      menuPadding: const EdgeInsets.symmetric(vertical: 8),
      constraints: const BoxConstraints(minWidth: 264),
      clipBehavior: Clip.antiAlias,
      popUpAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 240),
        reverseDuration: Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }
}

class ExpressivePopupMenuItem<T> extends PopupMenuItem<T> {
  ExpressivePopupMenuItem({
    required T value,
    required IconData icon,
    required String label,
    bool selected = false,
  }) : super(
          value: value,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _ExpressivePopupMenuOption(
            icon: icon,
            label: label,
            selected: selected,
          ),
        );
}

class _ExpressivePopupMenuOption extends StatelessWidget {
  const _ExpressivePopupMenuOption({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected ? colors.primary : colors.onSurfaceVariant;

    return Ink(
      decoration: BoxDecoration(
        color: selected ? colors.secondaryContainer : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (selected)
            Icon(Icons.check_rounded, size: 20, color: colors.primary),
        ],
      ),
    );
  }
}
