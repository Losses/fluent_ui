import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoiseBundle extends CachingAssetBundle {
  int loads = 0;

  @override
  Future<ByteData> load(String key) async {
    expect(key, 'packages/fluent_ui/assets/AcrylicNoise.png');
    loads++;
    final data = await rootBundle.load(key);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final padded = Uint8List(bytes.length + 16)
      ..setRange(8, bytes.length + 8, bytes);
    return ByteData.sublistView(padded, 8, bytes.length + 8);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('renders acrylic operations for fractional viewport scales', () async {
    final bundle = _NoiseBundle();
    final previous = debugCaptureShaderWarmUpImage;
    ui.Image? captured;
    debugCaptureShaderWarmUpImage = (image) {
      captured = image.clone();
      return true;
    };
    try {
      await AcrylicShaderWarmUp(
        devicePixelRatio: 2,
        scaleFactors: const [0.75, 1, 1.25, 1.5, 1.75, 2],
        assetBundle: bundle,
      ).execute();
      expect(bundle.loads, 1);
      expect(captured, isNotNull);
      expect(captured!.width, 512);
      expect(captured!.height, 512);
      final bytes = (await captured!.toByteData())!.buffer.asUint8List();
      const center = (128 * 512 + 128) * 4;
      const corner = (500 * 512 + 500) * 4;
      expect(
        bytes.sublist(center, center + 4),
        isNot(bytes.sublist(corner, corner + 4)),
      );
    } finally {
      debugCaptureShaderWarmUpImage = previous;
      captured?.dispose();
    }
  });

  test('rejects invalid scales before loading assets', () async {
    final bundle = _NoiseBundle();
    for (final scale in [0.0, -1.0, double.nan, double.infinity]) {
      await expectLater(
        AcrylicShaderWarmUp(
          scaleFactors: [scale],
          assetBundle: bundle,
        ).execute(),
        throwsArgumentError,
      );
      await expectLater(
        AcrylicShaderWarmUp(
          devicePixelRatio: scale,
          assetBundle: bundle,
        ).execute(),
        throwsArgumentError,
      );
    }
    expect(bundle.loads, 0);
  });
}
