import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final keyboard in [false, true]) {
    testWidgets('chip layout and selection replacement keyboard=$keyboard', (
      tester,
    ) async {
      final controller = TextEditingController();
      final key = GlobalKey<AutoSuggestBoxState<int>>();
      final focus = FocusNode();
      addTearDown(focus.dispose);
      final selected = <int>[];
      await tester.pumpWidget(
        FluentApp(
          home: Center(
            child: SizedBox(
              width: 240,
              height: 80,
              child: AutoSuggestBox<int>(
                key: key,
                focusNode: focus,
                controller: controller,
                items: [AutoSuggestBoxItem(value: 7, label: 'Album')],
                leadingIcon: const Text('existing chip'),
                decorationBuilder: (context, body, prefix, suffix) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [?prefix, body, ?suffix],
                ),
                onSelectTextDelegate: (_) => '\u200B',
                onSelected: (item) => selected.add(item.value!),
              ),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pumpAndSettle();
      key.currentState!.showOverlay();
      await tester.pumpAndSettle();
      expect(
        tester.getBottomLeft(find.text('existing chip')).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(EditableText)).dy),
      );
      if (keyboard) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        // Flutter receives the keyboard submit through the text input channel.
        await tester.testTextInput.receiveAction(TextInputAction.done);
      } else {
        await tester.tap(find.text('Album'));
      }
      await tester.pumpAndSettle();
      expect(selected, [7]);
      expect(controller.text, '\u200B');
      expect(controller.selection, const TextSelection.collapsed(offset: 1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    });
  }

  testWidgets('open suggestions refresh and long labels stay bounded', (
    tester,
  ) async {
    final key = GlobalKey<AutoSuggestBoxState<int>>();
    final focus = FocusNode();
    addTearDown(focus.dispose);
    late StateSetter update;
    var label = 'before';
    int? selected;
    await tester.pumpWidget(
      FluentApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Center(
              child: SizedBox(
                width: 180,
                height: 40,
                child: AutoSuggestBox<int>(
                  key: key,
                  focusNode: focus,
                  onSelected: (item) => selected = item.value,
                  items: [
                    AutoSuggestBoxItem(
                      value: label == 'before' ? 1 : 2,
                      label: label,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    focus.requestFocus();
    await tester.pumpAndSettle();
    key.currentState!.showOverlay();
    await tester.pumpAndSettle();
    expect(find.text('before'), findsOneWidget);
    update(() => label = 'A very long asynchronous suggestion ' * 10);
    await tester.pumpAndSettle();
    expect(find.text('before'), findsNothing);
    expect(find.text(label), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(selected, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'combo open query clears on disposal and preserves another popup',
    (tester) async {
      final first = GlobalKey<ComboBoxState<int>>();
      final second = GlobalKey<ComboBoxState<int>>();
      Widget app(bool includeFirst) => FluentApp(
        home: Column(
          children: [
            if (includeFirst)
              ComboBox<int>(
                key: first,
                items: const [ComboBoxItem(value: 1, child: Text('first'))],
                onChanged: (_) {},
              ),
            ComboBox<int>(
              key: second,
              items: const [ComboBoxItem(value: 2, child: Text('second'))],
              onChanged: (_) {},
            ),
          ],
        ),
      );
      await tester.pumpWidget(app(true));
      first.currentState!.openPopup();
      second.currentState!.openPopup();
      await tester.pumpAndSettle();
      expect(comboBoxOpened, isTrue);
      await tester.pumpWidget(app(false));
      await tester.pumpAndSettle();
      expect(comboBoxOpened, isTrue);
      second.currentState!.closePopup();
      await tester.pumpAndSettle();
      expect(comboBoxOpened, isFalse);
      second.currentState!.openPopup();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      expect(comboBoxOpened, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('custom command overflow retains nested menus and the page', (
    tester,
  ) async {
    var called = 0;
    await tester.pumpWidget(
      FluentApp(
        home: Column(
          children: [
            const Text('page remains'),
            CommandBar(
              primaryItems: const [],
              secondaryItems: [
                CommandBarButton(
                  onPressed: () {},
                  label: const Text('command'),
                ),
              ],
              overflowItemBuilder: (open) => CommandBarButton(
                onPressed: open,
                label: const Text('overflow'),
              ),
              overflowMenuItemBuilder: (context, item) => MenuFlyoutSubItem(
                text: const Text('parent'),
                items: (_) => [
                  MenuFlyoutItem(
                    text: const Text('nested action'),
                    onPressed: () => called++,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('overflow'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('nested action'));
    await tester.pumpAndSettle();
    expect(called, 1);
    expect(find.text('page remains'), findsOneWidget);
    expect(find.text('parent'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
