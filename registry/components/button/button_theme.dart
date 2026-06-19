import '../../tokens/kinetic_enums.dart';
import '../../tokens/kinetic_radius.dart';

class KineticButtonTheme {
  final KineticVariant defaultVariant;
  final KineticColor defaultColor;
  final KineticSize defaultSize;
  final double defaultRadius;

  const KineticButtonTheme({
    this.defaultVariant = KineticVariant.solid,
    this.defaultColor = KineticColor.primary,
    this.defaultSize = KineticSize.md,
    this.defaultRadius = KineticRadius.md,
  });
}
