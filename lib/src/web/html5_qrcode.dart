// ignore_for_file: avoid_positional_boolean_parameters

@JS()
library html5_qrcode;

import 'dart:async';
import 'dart:js_util';

import 'package:js/js.dart';
import 'package:mobile_scanner/src/web/media_track_constraints.dart';

@JS()
abstract class _Promise<T> {}

@JS('Html5Qrcode')
class _Html5Qrcode {
  external String get elementId;
  external set elementId(String v);

  external factory _Html5Qrcode(String elementId);

  @JS('start')
  external _Promise<void> start(
    dynamic cameraIdOrConfig,
    Html5QrcodeCameraScanConfig? configuration,
    QrcodeSuccessCallback qrCodeSuccessCallback,
    QrcodeErrorCallback? qrCodeErrorCallback,
  );

  @JS('stop')
  external _Promise<void> stop();

  @JS('resume')
  external void resume();

  @JS('pause')
  external void pause([bool? shouldPauseVideo]);

  @JS('getState')
  external int getState();
}

enum Html5QrcodeScannerState {
  // Invalid internal state, do not set to this state.
  unknown,
  // Indicates the sanning is not running or user is using file based
  // scanning.
  notStarted,
  // Camera scan is running.
  scanning,
  // Camera scan is paused but camera is running.
  paused,
}

class Html5Qrcode {
  Html5Qrcode(String elementId) : _html5qrcode = _Html5Qrcode(elementId);

  final _Html5Qrcode _html5qrcode;

  Future<void> startWithCameraId(
    String cameraId, {
    required QrcodeSuccessCallback qrCodeSuccessCallback,
    Html5QrcodeCameraScanConfig? configuration,
    QrcodeErrorCallback? qrCodeErrorCallback,
  }) async {
    await _start(
      cameraIdOrConfig: cameraId,
      qrCodeSuccessCallback: qrCodeSuccessCallback,
      configuration: configuration,
      qrCodeErrorCallback: qrCodeErrorCallback,
    );
  }

  Future<void> startWithConfig(
    MediaTrackConstraints config, {
    required QrcodeSuccessCallback qrCodeSuccessCallback,
    Html5QrcodeCameraScanConfig? configuration,
    QrcodeErrorCallback? qrCodeErrorCallback,
  }) async {
    await _start(
      cameraIdOrConfig: config,
      qrCodeSuccessCallback: qrCodeSuccessCallback,
      configuration: configuration,
      qrCodeErrorCallback: qrCodeErrorCallback,
    );
  }

  Future<void> _start({
    required dynamic cameraIdOrConfig,
    required QrcodeSuccessCallback qrCodeSuccessCallback,
    Html5QrcodeCameraScanConfig? configuration,
    QrcodeErrorCallback? qrCodeErrorCallback,
  }) async {
    assert(
      cameraIdOrConfig is String || cameraIdOrConfig is MediaTrackConstraints,
      '"cameraIdOrConfig" must either be of type "String" or '
      '"MediaTrackConstraints"!',
    );

    await promiseToFuture(
      _html5qrcode.start(
        cameraIdOrConfig,
        configuration,
        allowInterop(qrCodeSuccessCallback),
        qrCodeErrorCallback != null ? allowInterop(qrCodeErrorCallback) : null,
      ),
    );
  }

  Future<void> stop() async {
    await promiseToFuture(_html5qrcode.stop());
  }

  void resume() {
    _html5qrcode.resume();
  }

  void pause([bool? shouldPauseVideo]) {
    _html5qrcode.pause(shouldPauseVideo);
  }

  static Future<List<CameraDevice>> getCameras() async {
    return (await promiseToFuture(_getCamerasPromise()) as List<dynamic>)
        .cast<CameraDevice>();
  }

  Html5QrcodeScannerState getState() {
    final state = _html5qrcode.getState();

    switch (state) {
      case 1:
        return Html5QrcodeScannerState.notStarted;
      case 2:
        return Html5QrcodeScannerState.scanning;
      case 3:
        return Html5QrcodeScannerState.paused;
      default:
        return Html5QrcodeScannerState.unknown;
    }
  }
}

@JS('Html5Qrcode.getCameras')
external _Promise<List<CameraDevice>> _getCamerasPromise();

/// Defines dimension for QR Code Scanner.
@anonymous
@JS()
abstract class QrDimensions {
  external num get width;
  external set width(num v);
  external num get height;
  external set height(num v);

  external factory QrDimensions({num width, num height});
}

/// A function that takes in the width and height of the video stream
/// and returns QrDimensions.
/// Viewfinder refers to the video showing camera stream.
typedef QrDimensionFunction = QrDimensions Function(
  num viewfinderWidth,
  num viewfinderHeight,
);

/// Defines bounds of detected QR code w.r.t the scan region.
@anonymous
@JS()
abstract class QrBounds implements QrDimensions {
  external num get x;
  external set x(num v);
  external num get y;
  external set y(num v);

  external factory QrBounds({num x, num y, num width, num height});
}

@anonymous
@JS()
abstract class QrcodeResultFormat {
  external num get format;
  external set format(num v);
  external String get formatName;
  external set formatName(String v);

  external factory QrcodeResultFormat({num format, String formatName});
}

/// Detailed scan result.
@anonymous
@JS()
abstract class QrcodeResult {
  /// Decoded text.
  external String get text;
  external set text(String v);

  /// Format that was successfully scanned.
  external QrcodeResultFormat get format;
  external set format(QrcodeResultFormat v);

  /// The bounds of the decoded QR code or bar code in the whole stream of
  /// image.
  /// Note: this is experimental, and not fully supported.
  external QrBounds get bounds;
  external set bounds(QrBounds v);

  /// If the decoded text from the QR code or bar code is of a known type like
  /// url or upi id or email id.
  /// Note: this is experimental, and not fully supported.
  external num get decodedTextType;
  external set decodedTextType(num v);
  external factory QrcodeResult({
    String text,
    QrcodeResultFormat format,
    QrBounds bounds,
    num decodedTextType,
  });
}

/// QrCode result object.
@anonymous
@JS()
abstract class Html5QrcodeResult {
  external String get decodedText;
  external set decodedText(String v);
  external QrcodeResult get result;
  external set result(QrcodeResult v);
  external factory Html5QrcodeResult({String decodedText, QrcodeResult result});
}

/// Interface for scan error response.
@anonymous
@JS()
abstract class Html5QrcodeError {
  external String get errorMessage;
  external set errorMessage(String v);
  external num get type;
  external set type(num v);

  external factory Html5QrcodeError({String errorMessage, num type});
}

/// Type for a callback for a successful code scan.
typedef QrcodeSuccessCallback = void Function(
  String decodedText,
  Html5QrcodeResult result,
);

/// Type for a callback for failure during code scan.
typedef QrcodeErrorCallback = void Function(
  String errorMessage,
  Html5QrcodeError error,
);

/// Camera Device interface.
@anonymous
@JS()
abstract class CameraDevice {
  external String get id;
  external set id(String v);
  external String get label;
  external set label(String v);

  external factory CameraDevice({String id, String label});
}

/// Configuration type for scanning QR code with camera.
@anonymous
@JS()
abstract class Html5QrcodeCameraScanConfig {
  /// Optional, Expected framerate of qr code scanning. example { fps: 2 } means
  /// the scanning would be done every 500 ms.
  external num? get fps;
  external set fps(num? v);

  /// Optional, edge size, dimension or calculator function for QR scanning
  /// box, the value or computed value should be smaller than the width and
  /// height of the full region.
  /// This would make the scanner look like this:
  /// ----------------------
  /// |********************|
  /// |******,,,,,,,,,*****|      <--- shaded region
  /// |******|       |*****|      <--- non shaded region would be
  /// |******|       |*****|          used for QR code scanning.
  /// |******|_______|*****|
  /// |********************|
  /// |********************|
  /// ----------------------
  /// Instance of {@interface QrDimensions} can be passed to construct a non
  /// square rendering of scanner box. You can also pass in a function of type
  /// {@type QrDimensionFunction} that takes in the width and height of the
  /// video stream and return QR box size of type {@interface QrDimensions}.
  /// If this value is not set, no shaded QR box will be rendered and the
  /// scanner will scan the entire area of video stream.
  external QrDimensions? get qrbox;
  external set qrbox(QrDimensions? v);

  /// Optional, Desired aspect ratio for the video feed. Ideal aspect ratios
  /// are 4:3 or 16:9. Passing very wrong aspect ratio could lead to video feed
  /// not showing up.
  external num? get aspectRatio;
  external set aspectRatio(num? v);

  /// Optional, if {@code true} flipped QR Code won't be scanned. Only use this
  /// if you are sure the camera cannot give mirrored feed if you are facing
  /// performance constraints.
  external bool? get disableFlip;
  external set disableFlip(bool? v);

  /// Optional, @beta(this config is not well supported yet).
  /// Important: When passed this will override other parameters like
  /// 'cameraIdOrConfig' or configurations like 'aspectRatio'.
  /// 'videoConstraints' should be of type {@code MediaTrackConstraints} as
  /// defined in
  /// https://developer.mozilla.org/en-US/docs/Web/API/MediaTrackConstraints
  /// and is used to specify a variety of video or camera controls like:
  /// aspectRatio, facingMode, frameRate, etc.
  external MediaTrackConstraints? get videoConstraints;
  external set videoConstraints(MediaTrackConstraints? v);

  external factory Html5QrcodeCameraScanConfig({
    num? fps,
    QrDimensions? qrbox,
    num? aspectRatio,
    bool? disableFlip,
    MediaTrackConstraints? videoConstraints,
  });
}
