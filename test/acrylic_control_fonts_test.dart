import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => FluentApp(
      theme: FluentThemeData(fontFamily: 'CallerFont'),
      home: Center(child: SizedBox(width: 260, height: 40, child: child)),
    );

void expectPopupFont(WidgetTester tester, String label) {
  final text = tester.widget<RichText>(
    find.descendant(of: find.text(label), matching: find.byType(RichText)),
  );
  expect(text.text.style!.fontFamily, 'CallerFont');
  expect(find.byType(Acrylic), findsWidgets);
}

void main() {
  testWidgets('combo popup retains the Fluent font and selection', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      app(
        ComboBox<String>(
          value: 'one',
          items: const [
            ComboBoxItem(value: 'one', child: Text('One')),
            ComboBoxItem(value: 'two', child: Text('Two')),
          ],
          onChanged: (value) => selected = value,
        ),
      ),
    );
    await tester.tap(find.byType(ComboBox<String>));
    await tester.pumpAndSettle();
    expectPopupFont(tester, 'Two');
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
    expect(selected, 'two');
    expect(find.byType(Acrylic), findsNothing);
  });

  testWidgets('suggestion popup retains the Fluent font and selection', (
    tester,
  ) async {
    final key = GlobalKey<AutoSuggestBoxState<String>>();
    final focus = FocusNode();
    final controller = TextEditingController();
    String? selected;
    await tester.pumpWidget(
      app(
        AutoSuggestBox<String>(
          key: key,
          focusNode: focus,
          controller: controller,
          items: [AutoSuggestBoxItem(value: 'option', label: 'Option')],
          onSelected: (item) => selected = item.value,
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    key.currentState!.showOverlay();
    await tester.pumpAndSettle();
    expectPopupFont(tester, 'Option');
    await tester.tap(find.text('Option'));
    await tester.pumpAndSettle();
    expect(selected, 'option');
    expect(controller.text, 'Option');
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    focus.dispose();
  });

  testWidgets('selection toolbar retains the Fluent font and copy action', (
    tester,
  ) async {
    final focus = FocusNode();
    final controller = TextEditingController(text: 'sample text');
    await tester.pumpWidget(
      app(
        TextBox(
          controller: controller,
          focusNode: focus,
          selectionControls: fluentTextSelectionControls,
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 6);
    await tester.pump();
    tester.state<EditableTextState>(find.byType(EditableText)).showToolbar();
    await tester.pumpAndSettle();
    expectPopupFont(tester, 'Copy');
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(controller.text, 'sample text');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    focus.dispose();
  });
}
