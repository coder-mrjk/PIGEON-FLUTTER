import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final double border;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry alignment;
  final List<Color>? gradientColors;
  final List<Color>? borderGradientColors;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.blur = 20,
    this.border = 1,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.alignment = Alignment.center,
    this.gradientColors,
    this.borderGradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      child: GlassmorphicContainer(
        width: width,
        height: height,
        borderRadius: borderRadius,
        blur: blur,
        alignment: alignment,
        border: border,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              gradientColors ??
              [
                backgroundColor ?? Colors.white.withOpacity(0.1),
                (backgroundColor ?? Colors.white).withOpacity(0.05),
              ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              borderGradientColors ??
              [
                borderColor ?? Colors.white.withOpacity(0.2),
                (borderColor ?? Colors.white).withOpacity(0.1),
              ],
        ),
        child: Container(padding: padding, child: child),
      ),
    );
  }
}

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double border;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final List<Color>? borderGradientColors;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.blur = 15,
    this.border = 1,
    this.backgroundColor,
    this.borderColor,
    this.gradientColors,
    this.borderGradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget card = GlassmorphicContainer(
      width: double.infinity,
      height: null,
      borderRadius: borderRadius,
      blur: blur,
      alignment: Alignment.center,
      border: border,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            gradientColors ??
            [
              backgroundColor ?? theme.colorScheme.surface.withOpacity(0.1),
              (backgroundColor ?? theme.colorScheme.surface).withOpacity(0.05),
            ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            borderGradientColors ??
            [
              borderColor ?? theme.colorScheme.outline.withOpacity(0.2),
              (borderColor ?? theme.colorScheme.outline).withOpacity(0.1),
            ],
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return Container(margin: margin, child: card);
  }
}

class GlassmorphicButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final double border;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final List<Color>? borderGradientColors;
  final bool isLoading;

  const GlassmorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.borderRadius = 12,
    this.blur = 10,
    this.border = 1,
    this.backgroundColor,
    this.borderColor,
    this.gradientColors,
    this.borderGradientColors,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 200),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: null,
          borderRadius: borderRadius,
          blur: blur,
          alignment: Alignment.center,
          border: border,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                gradientColors ??
                [
                  backgroundColor ?? theme.colorScheme.primary.withOpacity(0.1),
                  (backgroundColor ?? theme.colorScheme.primary).withOpacity(
                    0.05,
                  ),
                ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                borderGradientColors ??
                [
                  borderColor ?? theme.colorScheme.primary.withOpacity(0.3),
                  (borderColor ?? theme.colorScheme.primary).withOpacity(0.1),
                ],
          ),
          child: Container(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

class GlassmorphicInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final double borderRadius;
  final double blur;
  final double border;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final List<Color>? borderGradientColors;

  const GlassmorphicInput({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.borderRadius = 12,
    this.blur = 10,
    this.border = 1,
    this.backgroundColor,
    this.borderColor,
    this.gradientColors,
    this.borderGradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassmorphicContainer(
      width: double.infinity,
      height: null,
      borderRadius: borderRadius,
      blur: blur,
      alignment: Alignment.center,
      border: border,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            gradientColors ??
            [
              backgroundColor ?? theme.colorScheme.surface.withOpacity(0.1),
              (backgroundColor ?? theme.colorScheme.surface).withOpacity(0.05),
            ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            borderGradientColors ??
            [
              borderColor ?? theme.colorScheme.outline.withOpacity(0.2),
              (borderColor ?? theme.colorScheme.outline).withOpacity(0.1),
            ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        maxLines: maxLines,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 20,
                )
              : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          counterText: '',
        ),
      ),
    );
  }
}
