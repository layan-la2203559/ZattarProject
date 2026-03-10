import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class SoundEngine {
  static final AudioPlayer _sfx   = AudioPlayer();
  static final AudioPlayer _alarm = AudioPlayer();

  static const int _sr = 22050; // sample rate

  // ── Public API ──────────────────────────────────────────────────────────────
  static void playAdd()    => _play(_sfx,   _buildAdd(),    'sfx_add.wav');
  static void playRemove() => _play(_sfx,   _buildRemove(), 'sfx_remove.wav');
  static void playTab()    => _play(_sfx,   _buildTab(),    'sfx_tab.wav');
  static void playAlarm()  => _play(_alarm, _buildAlarm(),  'sfx_alarm.wav');

  static Future<void> _play(AudioPlayer p, Uint8List bytes, String name) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(bytes, flush: true);
      await p.stop();
      await p.play(DeviceFileSource(file.path));
    } catch (e) {
      // ignore
    }
  }

  // ── Sound builders ──────────────────────────────────────────────────────────
  static Uint8List _buildAdd() => _wav([
        ..._sq(330, 0.07),
        ..._sq(440, 0.07),
        ..._sq(660, 0.10),
      ]);

  static Uint8List _buildRemove() => _wav([
        ..._sq(440, 0.07),
        ..._sq(330, 0.07),
        ..._sq(220, 0.10),
      ]);

  static Uint8List _buildTab() => _wav(_sq(880, 0.04, vol: 0.18));

  static Uint8List _buildAlarm() {
    final samples = <int>[];
    double elapsed = 0.0;
    while (elapsed < 3.0) {
      samples.addAll(_sq(880, 0.18, vol: 0.6));
      samples.addAll(_sq(660, 0.18, vol: 0.6));
      samples.addAll(List.filled((_sr * 0.08).round(), 0));
      elapsed += 0.44;
    }
    return _wav(samples);
  }

  // ── Square wave generator ───────────────────────────────────────────────────
  static List<int> _sq(double freq, double dur,
      {double vol = 0.3, int sr = _sr}) {
    final n = (sr * dur).round();
    final period = sr / freq;
    return List.generate(n, (i) {
      final s = (i % period) < (period / 2) ? 1.0 : -1.0;
      final env = max(0.0, 1.0 - i / n * 0.4);
      return (s * env * vol * 32767).round().clamp(-32767, 32767);
    });
  }

  // ── WAV file builder ────────────────────────────────────────────────────────
  static Uint8List _wav(List<int> samples, {int sr = _sr}) {
    final dataSize = samples.length * 2;
    final buf = ByteData(44 + dataSize);
    int o = 0;

    void u8(int v) => buf.setUint8(o++, v);
    void u16(int v) { buf.setUint16(o, v, Endian.little); o += 2; }
    void u32(int v) { buf.setUint32(o, v, Endian.little); o += 4; }
    void s16(int v) { buf.setInt16(o, v, Endian.little); o += 2; }
    void str(String s) { for (final c in s.codeUnits) u8(c); }

    str('RIFF'); u32(36 + dataSize); str('WAVE');
    str('fmt '); u32(16); u16(1); u16(1);
    u32(sr); u32(sr * 2); u16(2); u16(16);
    str('data'); u32(dataSize);
    for (final s in samples) s16(s);

    return buf.buffer.asUint8List();
  }
}
