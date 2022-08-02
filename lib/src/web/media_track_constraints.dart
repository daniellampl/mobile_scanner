import 'package:js/js.dart';

@anonymous
@JS()
abstract class MediaTrackConstraints {
  external double? get aspectRatio;
  external set aspectRatio(double? v);
  external int? get channelCount;
  external set channelCount(int? v);
  external String? get deviceId;
  external set deviceId(String? v);
  external bool? get echoCancellation;
  external set echoCancellation(bool? v);
  external String? get facingMode;
  external set facingMode(String? v);
  external double? get frameRate;
  external set frameRate(double? v);
  external String? get groupId;
  external set groupId(String? v);
  external int? get height;
  external set height(int? v);
  external double? get latency;
  external set latency(double? v);
  external int? get sampleRate;
  external set sampleRate(int? v);
  external int? get sampleSize;
  external set sampleSize(int? v);
  external bool? get suppressLocalAudioPlayback;
  external set suppressLocalAudioPlayback(bool? v);
  external int? get width;
  external set width(int? v);

  external factory MediaTrackConstraints({
    double? aspectRatio,
    int? channelCount,
    String? deviceId,
    bool? echoCancellation,
    String? facingMode,
    double? frameRate,
    String? groupId,
    int? height,
    double? latency,
    int? sampleRate,
    int? sampleSize,
    bool? suppressLocalAudioPlayback,
    int? width,
  });
}
