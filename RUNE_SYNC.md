# Rune synchronization with Fluent UI 4.17.0

This branch synchronizes the Rune fork at `27dbb0d9a0ff63ec1bfd4c2f7afa60658ad7b88f`
with upstream `8edee07d4eb59c6452943b7a70afa44c542153b9`. It is a merge with both
histories preserved. The upstream commit's runtime, fonts, assets and pubspec
match the official 4.17.0 archive byte for byte. Later upstream master changes
are outside this synchronization.

The release archive SHA256 is
`4482326e3d4881f59b4a42e9c608b2be3171cd00fa181f51b6b0dd63bd786a0f`.
The package version is `4.17.0+rune.1`.

## Customization inventory

The old fork contained 15 behavioral customizations across 14 library files.
Thirteen remain necessary, two are replaced by upstream implementations.

| Customization | Intent and disposition |
| --- | --- |
| TextBox and AutoSuggestBox decorationBuilder | Keep selected chips above the editable body. Retained, including the new TextFormBox forwarding path. |
| onSelectTextDelegate | Replace chosen text with the chip input's sentinel; applied to pointer and keyboard submission. |
| Dynamic suggestions | Refresh an open popup and keyboard navigation when asynchronous results change. |
| Suggestion ellipsis | Keep long results inside the popup. |
| CommandBar overflowMenuItemBuilder | Preserve Rune's nested, route-aware menu actions using the new FlyoutController. Standard command bars retain upstream's anchored presenter. |
| comboBoxOpened | Suppress accidental navigation while a combo popup is open. Track multiple instances and clear on disposal. |
| Flyout pointer geometry | Compare pointer positions and parent/submenu bounds in the same coordinate system under scaling. |
| Popup invalidation | Dismiss stale ComboBox, Picker, suggestions, Flyout and Tooltip geometry on viewport changes; never dismiss an unrelated replacement popup. |
| Suggestion IME protection | Let composing keys reach the native input method without triggering ancestor shortcuts. |
| Text selection geometry | Preserve scaled Fluent and explicit adaptive toolbars and mobile MediaQuery restoration; retain upstream undo support. |
| Slider labels and semantics | Replace private Material state access with a public Tooltip and retain accessible overlay semantics and scaled edge avoidance. |
| Menu repaint isolation | Avoid repainting unrelated menu rows on hover. |
| Acrylic composition | Replaced by upstream 4.17.0 implementation; old composition patch removed. |
| Acrylic fonts | Replaced by upstream removal of the transparent Material; font-copy helper removed. |
| Bounded Acrylic warmup | Retain Skia warmup and 512×512 image bounds using the current painter. |

The unused ContainerWrapper enum and old example resize experiment are omitted.
No proposal or contribution to the upstream project is part of this sync.

## Validation

On Flutter 3.47.4/Linux, `flutter test --no-pub test --exclude-tags golden`
passes all 361 tests. Rune's application tests also cover scaled menus, mobile
and desktop text selection, input-method composing state and responsive forms.
Tests named `rune_*` retain and extend the fork's behavior checks.

The original five Acrylic golden baselines are retained. Two fail identically
on the unmodified upstream release in this environment; the produced PNGs are
byte-identical between upstream and this branch:

- dark_default: `5759627bf8152977406d8f6563c44574f9b3e5862db94e3e0ae355f8cf6f1b57`
- high_contrast: `f95c94d208a07d3c9b63cf029d1c045d267590285fe767a9bf57d07ebd07cc23`

Native IME and GPU performance require device testing; widget tests do not
establish those results.
