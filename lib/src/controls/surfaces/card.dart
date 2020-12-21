import 'package:fluent_ui/fluent_ui.dart';

class Card extends StatelessWidget {
  const Card({
    Key key,
    this.child,
    this.style,
  }) : super(key: key);

  final Widget child;
  final CardStyle style;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.cardStyle.copyWith(this.style);
    return Container(
      margin: style.margin,
      decoration: BoxDecoration(
        boxShadow: elevationShadow(
          style.elevation ?? 2,
          color: style.elevationColor,
        ),
      ),
      child: ClipRRect(
        borderRadius: style.borderRadius,
        child: Container(
          padding: style.padding,
          decoration: BoxDecoration(
            border: _buildBorder(style),
            color: style.color,
          ),
          child: child,
        ),
      ),
    );
  }

  Border _buildBorder(CardStyle style) {
    final BorderSide Function(CardHighlightPosition) buildSide = (p) {
      if (style.highlightPosition == p)
        return BorderSide(
          color: style.highlightColor ?? Colors.blue,
          width: style.highlightSize ?? 1.8,
        );
      else
        return BorderSide.none;
    };
    return Border(
      bottom: buildSide(CardHighlightPosition.bottom),
      left: buildSide(CardHighlightPosition.left),
      top: buildSide(CardHighlightPosition.top),
      right: buildSide(CardHighlightPosition.right),
    );
  }
}

class CardStyle {
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  final Color color;

  final int elevation;
  final Color elevationColor;

  final Color highlightColor;
  final CardHighlightPosition highlightPosition;
  final double highlightSize;

  CardStyle({
    this.borderRadius,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.elevationColor,
    this.highlightColor,
    this.highlightPosition,
    this.highlightSize,
  });

  static CardStyle defaultTheme(Brightness brightness) {
    final def = CardStyle(
      borderRadius: BorderRadius.circular(2),
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(12),
      elevation: 2,
      highlightPosition: CardHighlightPosition.top,
      highlightColor: Colors.blue,
      highlightSize: 1.8,
    );
    if (brightness == null || brightness == Brightness.light)
      return def.copyWith(CardStyle(
        elevationColor: Colors.black.withOpacity(0.1),
        color: Colors.white,
      ));
    else
      return def.copyWith(CardStyle(
        elevationColor: Colors.white.withOpacity(0.1),
        color: Colors.grey,
      ));
  }

  CardStyle copyWith(CardStyle style) {
    if (style == null) return this;
    return CardStyle(
      borderRadius: style?.borderRadius ?? borderRadius,
      padding: style?.padding ?? padding,
      margin: style?.margin ?? margin,
      color: style?.color ?? color,
      elevation: style?.elevation ?? elevation,
      elevationColor: style?.elevationColor ?? elevationColor,
      highlightColor: style?.highlightColor ?? highlightColor,
      highlightPosition: style?.highlightPosition ?? highlightPosition,
      highlightSize: style?.highlightSize ?? highlightSize,
    );
  }
}

enum CardHighlightPosition { top, bottom, left, right }