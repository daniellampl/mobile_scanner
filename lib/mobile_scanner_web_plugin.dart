import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_scanner/src/web/web.dart';

/// This plugin is the web implementation of mobile_scanner.
class MobileScannerWebPlugin {
  static void registerWith(Registrar registrar) {
    final PluginEventChannel event = PluginEventChannel(
      'dev.steenbakker.mobile_scanner/scanner/event',
      const StandardMethodCodec(),
      registrar,
    );
    final MethodChannel channel = MethodChannel(
      'dev.steenbakker.mobile_scanner/scanner/method',
      const StandardMethodCodec(),
      registrar,
    );
    final MobileScannerWebPlugin instance = MobileScannerWebPlugin();
    WidgetsFlutterBinding.ensureInitialized();

    channel.setMethodCallHandler(instance.handleMethodCall);
    event.setController(instance.controller);
  }

  /// A [StreamController] to send events back to the framework.
  StreamController controller = StreamController.broadcast();

  /// The ID of the web plugins platform view.
  String platformViewID =
      'MobileScanner-PlatformView-${DateTime.now().millisecondsSinceEpoch}';

  /// The ID of the [html.DivElement] the `html5-qrcode` scanner is displayed in.
  String scannerID =
      'MobileScanner-html5-qrcode-${DateTime.now().millisecondsSinceEpoch}';

  /// Determines wether the device has flash.
  bool hasFlash = false;

  /// The html5-qrcode interactor.
  Html5Qrcode? _html5qrcode;

  html.DivElement scannerDiv = html.DivElement();

  /// Handle incomming messages
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'start':
        final cameraFacing = (call.arguments as Map).containsKey('facing')
            // ignore: avoid_dynamic_calls
            ? CameraFacing.values[call.arguments['facing'] as int]
            : CameraFacing.front;

        return _start(cameraFacing: cameraFacing);
      case 'stop':
        return cancel();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The mobile_scanner plugin for web doesn't implement "
              "the method '${call.method}'",
        );
    }
  }

  /// Starts the video stream and the scanner
  Future<Map> _start({
    required CameraFacing cameraFacing,
  }) async {
    // See https://github.com/flutter/flutter/issues/41563
    // ignore: UNDEFINED_PREFIXED_NAME, avoid_dynamic_calls
    ui.platformViewRegistry.registerViewFactory(
        platformViewID,
        (int id) => scannerDiv
          ..id = scannerID
          ..style.width = '100%'
        );

    final documentObserver = html.MutationObserver((_, observer) async {
      if (html.document.contains(scannerDiv)) {
        observer.disconnect();

        final width = scannerDiv.clientWidth;
        final height = scannerDiv.clientHeight;

        await _initHtml5Qrcode(
          cameraFacing: cameraFacing,
          aspectRatio: width / height,
          qrBoxDimensions: QrDimensions(
            width: 250,
            height: 250,
          ),
        );
      }
    });

    documentObserver.observe(html.document, childList: true, subtree: true);

    return {
      'ViewID': platformViewID,
      'torchable': hasFlash,
    };
  }

  Future<void> _initHtml5Qrcode({
    required CameraFacing cameraFacing,
    required double? aspectRatio,
    required QrDimensions qrBoxDimensions,
  }) async {
    try {
      _html5qrcode = Html5Qrcode(scannerID);

      final facingMode =
          cameraFacing == CameraFacing.front ? 'user' : "environment";

      await _html5qrcode!.startWithConfig(
        MediaTrackConstraints(facingMode: facingMode),
        configuration: Html5QrcodeCameraScanConfig(
          aspectRatio: aspectRatio,
          fps: 10,
          qrbox: qrBoxDimensions,
        ),
        qrCodeSuccessCallback: (decodedText, result) => controller.add({
          'name': 'barcodeWeb',
          'data': decodedText,
        }),
      );
    } catch (e) {
      throw PlatformException(code: 'MobileScannerWeb', message: '$e');
    }
  }

  /// Check if any camera's are available
  static Future<bool> cameraAvailable() async {
    final sources =
        await html.window.navigator.mediaDevices!.enumerateDevices();
    for (final e in sources) {
      // ignore: avoid_dynamic_calls
      if (e.kind == 'videoinput') {
        return true;
      }
    }
    return false;
  }

  /// Stops the video feed and analyzer
  Future<void> cancel() async {
    try {
      if (_html5qrcode != null) {
        await _html5qrcode!.stop();
      }
    } catch (e) {
      debugPrint('Failed to stop stream: $e');
    }
  }
}
