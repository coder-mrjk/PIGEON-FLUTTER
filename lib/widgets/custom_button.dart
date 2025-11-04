import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: Size(width ?? 0, height ?? 48),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final maxW = constraints.maxWidth;
                  final hasIcon = icon != null;
                  final compact = maxW < 80;
                  final iconOnly = hasIcon && maxW < 56;

                  if (iconOnly) {
                    return Icon(icon, size: 20);
                  }

                  final textStyle = TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 14 : 16,
                  );

                  final textWidget = Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: textStyle,
                    ),
                  );

                  if (hasIcon) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: compact ? 18 : 20),
                        SizedBox(width: compact ? 4 : 8),
                        textWidget,
                      ],
                    );
                  } else {
                    // For extremely tight spaces, wrap text in FittedBox to scale down if needed
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: textStyle,
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? theme.colorScheme.primary).withValues(
              alpha: 0.3,
            ),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor ?? Colors.white, size: size),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

class CustomFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;

  const CustomFloatingButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      child: Icon(icon, color: iconColor ?? Colors.white),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
