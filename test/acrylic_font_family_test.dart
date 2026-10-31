import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final scale in [0.75, 1.0, 2.0]) {
    for (final family in <String?>[null, 'CallerFont']) {
      testWidgets(
        'acrylic inherits fonts and retains formatting at $scale with $family',
        (tester) async {
          Widget app(Color color) => FluentApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: material.Theme(
                data: material.ThemeData().copyWith(
                  textTheme: material.TextTheme(
                    bodyMedium: TextStyle(
                      color: color,
                      fontFamily: 'MaterialFont',
                      fontFamilyFallback: const ['MaterialFallback'],
                      fontSize: 19,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      wordSpacing: 0.4,
                      leadingDistribution: TextLeadingDistribution.even,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: family,
                    fontFamilyFallback: family == null
                        ? null
                        : ['CallerFallback'],
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  child: const Row(
                    children: [
                      material.Material(
                        type: material.MaterialType.transparency,
                        child: Text('control'),
                      ),
                      Acrylic(child: Text('candidate')),
                    ],
                  ),
                ),
              ),
            ),
          );
          for (final color in [Colors.black, Colors.white]) {
            await tester.pumpWidget(app(color));
            await tester.pumpAndSettle();
            TextStyle style(String text) => tester
                .widget<RichText>(
                  find.descendant(
                    of: find.text(text),
                    matching: find.byType(RichText),
                  ),
                )
                .text
                .style!;
            final candidate = style('candidate');
            final control = style('control');
            expect(candidate.fontFamily, family);
            expect(
              candidate.fontFamilyFallback,
              family == null ? null : ['CallerFallback'],
            );
            TextStyle withoutFonts(TextStyle value) => value.copyWith(
              fontFamily: 'comparison',
              fontFamilyFallback: const ['comparison'],
            );
            expect(withoutFonts(candidate), withoutFonts(control));
            expect(
              tester.getSize(find.text('candidate')).height,
              tester.getSize(find.text('control')).height,
            );
          }
        },
      );
    }
  }
  testWidgets('acrylic preserves package font names and descendant overrides', (
    tester,
  ) async {
    await tester.pumpWidget(
      const FluentApp(
        home: DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'Body',
            fontFamilyFallback: ['Fallback'],
            package: 'example',
          ),
          child: Acrylic(
            child: Column(
              children: [
                Text('inherited'),
                Text(
                  'overridden',
                  style: TextStyle(
                    fontFamily: 'Child',
                    fontFamilyFallback: ['ChildFallback'],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    TextStyle style(String label) => tester
        .widget<RichText>(
          find.descendant(
            of: find.text(label),
            matching: find.byType(RichText),
          ),
        )
        .text
        .style!;
    expect(style('inherited').fontFamily, 'packages/example/Body');
    expect(style('inherited').fontFamilyFallback, [
      'packages/example/Fallback',
    ]);
    expect(style('overridden').fontFamily, 'Child');
    expect(style('overridden').fontFamilyFallback, ['ChildFallback']);
  });
}
