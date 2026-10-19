import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({Key? key}) : super(key: key);

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  // ============================================================
  // STOPWATCH
  // ============================================================

  final Stopwatch _stopwatch = Stopwatch();

  Timer? _stopwatchTimer;

  // ============================================================
  // COUNTDOWN
  // ============================================================

  Timer? _countdownTimer;

  final TextEditingController _minuteController =
      TextEditingController();

  final TextEditingController _secondController =
      TextEditingController();

  Duration _countdownDuration = Duration.zero;

  Duration _remainingDuration = Duration.zero;

  // ============================================================
  // MODE
  // ============================================================

  bool _isCountdownMode = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Nilai awal countdown
    _minuteController.text = '0';
    _secondController.text = '0';
  }

  // ============================================================
  // STOPWATCH - MULAI
  // ============================================================

  void _startStopwatch() {
    if (_stopwatch.isRunning) {
      return;
    }

    _stopwatch.start();

    _stopwatchTimer ??= Timer.periodic(
      const Duration(milliseconds: 30),
      (_) {
        if (!mounted) return;

        setState(() {});
      },
    );

    setState(() {});
  }

  // ============================================================
  // STOPWATCH - JEDA
  // ============================================================

  void _pauseStopwatch() {
    _stopwatch.stop();

    _stopwatchTimer?.cancel();
    _stopwatchTimer = null;

    setState(() {});
  }

  // ============================================================
  // STOPWATCH - RESET
  // ============================================================

  void _resetStopwatch() {
    _stopwatch.stop();
    _stopwatch.reset();

    _stopwatchTimer?.cancel();
    _stopwatchTimer = null;

    setState(() {});
  }

  // ============================================================
  // COUNTDOWN - AMBIL INPUT
  // ============================================================

  Duration _getInputDuration() {
    final int minutes =
        int.tryParse(
              _minuteController.text.trim(),
            ) ??
            0;

    final int seconds =
        int.tryParse(
              _secondController.text.trim(),
            ) ??
            0;

    return Duration(
      minutes: minutes,
      seconds: seconds,
    );
  }

  // ============================================================
  // COUNTDOWN - SET DURASI
  // ============================================================

  void _setCountdownDuration() {
    final duration = _getInputDuration();

    if (duration <= Duration.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Masukkan durasi lebih dari 0 menit atau detik.',
          ),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    _countdownTimer?.cancel();
    _countdownTimer = null;

    setState(() {
      _countdownDuration = duration;
      _remainingDuration = duration;
    });
  }

  // ============================================================
  // COUNTDOWN - MULAI
  // ============================================================

  void _startCountdown() {
    // Kalau belum ada durasi,
    // ambil dari input.
    if (_remainingDuration <= Duration.zero) {
      final duration = _getInputDuration();

      if (duration <= Duration.zero) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Masukkan durasi terlebih dahulu.',
            ),
            backgroundColor: Colors.orange,
          ),
        );

        return;
      }

      _countdownDuration = duration;
      _remainingDuration = duration;
    }

    // Jangan membuat timer baru
    // kalau countdown sedang berjalan.
    if (_countdownTimer != null &&
        _countdownTimer!.isActive) {
      return;
    }

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingDuration.inSeconds <= 1) {
          timer.cancel();
          _countdownTimer = null;

          setState(() {
            _remainingDuration =
                Duration.zero;
          });

          _showTimeUpMessage();

          return;
        }

        setState(() {
          _remainingDuration -=
              const Duration(seconds: 1);
        });
      },
    );

    setState(() {});
  }

  // ============================================================
  // COUNTDOWN - JEDA
  // ============================================================

  void _pauseCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;

    setState(() {});
  }

  // ============================================================
  // COUNTDOWN - RESET
  // ============================================================

  void _resetCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;

    setState(() {
      _remainingDuration =
          _countdownDuration;
    });
  }

  // ============================================================
  // NOTIFIKASI WAKTU HABIS
  // ============================================================

  void _showTimeUpMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '⏰ Waktu habis!',
        ),
        backgroundColor: Color(0xFFB88E65),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // FORMAT STOPWATCH
  // ============================================================

  String _formatStopwatch(Duration duration) {
    final hours =
        duration.inHours.toString().padLeft(2, '0');

    final minutes =
        (duration.inMinutes % 60)
            .toString()
            .padLeft(2, '0');

    final seconds =
        (duration.inSeconds % 60)
            .toString()
            .padLeft(2, '0');

    final milliseconds =
        (duration.inMilliseconds % 1000) ~/ 10;

    final ms =
        milliseconds
            .toString()
            .padLeft(2, '0');

    return '$hours:$minutes:$seconds.$ms';
  }

  // ============================================================
  // FORMAT COUNTDOWN
  // ============================================================

  String _formatCountdown(Duration duration) {
    final hours =
        duration.inHours;

    final minutes =
        duration.inMinutes % 60;

    final seconds =
        duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // GANTI MODE
  // ============================================================

  void _changeMode(bool countdownMode) {
    // Hentikan stopwatch
    _stopwatch.stop();

    _stopwatchTimer?.cancel();
    _stopwatchTimer = null;

    // Hentikan countdown
    _countdownTimer?.cancel();
    _countdownTimer = null;

    setState(() {
      _isCountdownMode = countdownMode;
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _countdownTimer?.cancel();

    _minuteController.dispose();
    _secondController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch & Timer'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // ==================================================
            // PILIH MODE
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.all(4),

              decoration: BoxDecoration(
                color: const Color(
                  0xFF869277,
                ).withOpacity(0.15),

                borderRadius:
                    BorderRadius.circular(30),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: _buildModeButton(
                      title: 'Stopwatch',
                      icon: Icons.timer,
                      selected:
                          !_isCountdownMode,
                      onTap: () =>
                          _changeMode(false),
                    ),
                  ),

                  Expanded(
                    child: _buildModeButton(
                      title: 'Hitung Mundur',
                      icon:
                          Icons.hourglass_bottom,
                      selected:
                          _isCountdownMode,
                      onTap: () =>
                          _changeMode(true),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // ==================================================
            // MODE STOPWATCH
            // ==================================================

            if (!_isCountdownMode)
              _buildStopwatchContent(),

            // ==================================================
            // MODE COUNTDOWN
            // ==================================================

            if (_isCountdownMode)
              _buildCountdownContent(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MODE BUTTON
  // ============================================================

  Widget _buildModeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),

        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF869277)
              : Colors.transparent,

          borderRadius:
              BorderRadius.circular(25),
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? Colors.white
                  : const Color(
                      0xFF869277,
                    ),
            ),

            const SizedBox(width: 6),

            Text(
              title,

              style: TextStyle(
                color: selected
                    ? Colors.white
                    : const Color(
                        0xFF869277,
                      ),

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TAMPILAN STOPWATCH
  // ============================================================

  Widget _buildStopwatchContent() {
    return Column(
      children: [
        // ==================================================
        // DISPLAY WAKTU
        // ==================================================

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(
            vertical: 35,
            horizontal: 20,
          ),

          decoration: BoxDecoration(
            color: const Color(
              0xFF869277,
            ).withOpacity(0.12),

            borderRadius:
                BorderRadius.circular(20),
          ),

          child: Column(
            children: [
              const Icon(
                Icons.timer,
                size: 50,
                color: Color(0xFF869277),
              ),

              const SizedBox(height: 15),

              Text(
                _formatStopwatch(
                  _stopwatch.elapsed,
                ),

                style: const TextStyle(
                  fontSize: 38,
                  fontWeight:
                      FontWeight.bold,
                  letterSpacing: 2,
                  color:
                      Color(0xFFB88E65),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _stopwatch.isRunning
                    ? 'Stopwatch sedang berjalan'
                    : 'Stopwatch berhenti',

                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // ==================================================
        // TOMBOL STOPWATCH
        // ==================================================

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            // MULAI / JEDA
            Expanded(
              child: ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF869277,
                  ),

                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 14,
                  ),
                ),

                onPressed:
                    _stopwatch.isRunning
                        ? _pauseStopwatch
                        : _startStopwatch,

                icon: Icon(
                  _stopwatch.isRunning
                      ? Icons.pause
                      : Icons.play_arrow,

                  color: Colors.white,
                ),

                label: Text(
                  _stopwatch.isRunning
                      ? 'Jeda'
                      : 'Mulai',

                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // RESET
            Expanded(
              child: OutlinedButton.icon(
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(
                    0xFFB88E65,
                  ),

                  side:
                      const BorderSide(
                    color:
                        Color(0xFFB88E65),
                  ),

                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 14,
                  ),
                ),

                onPressed:
                    _resetStopwatch,

                icon: const Icon(
                  Icons.refresh,
                ),

                label: const Text(
                  'Reset',
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // TAMPILAN COUNTDOWN
  // ============================================================

  Widget _buildCountdownContent() {
    final bool isRunning =
        _countdownTimer != null &&
            _countdownTimer!.isActive;

    return Column(
      children: [
        // ==================================================
        // INPUT DURASI
        // ==================================================

        Row(
          children: [
            Expanded(
              child: TextField(
                controller:
                    _minuteController,

                keyboardType:
                    TextInputType.number,

                decoration:
                    const InputDecoration(
                  labelText: 'Menit',
                  hintText: '50',
                  border:
                      OutlineInputBorder(),
                  prefixIcon:
                      Icon(
                    Icons.timer,
                  ),
                ),

                enabled: !isRunning,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: TextField(
                controller:
                    _secondController,

                keyboardType:
                    TextInputType.number,

                decoration:
                    const InputDecoration(
                  labelText: 'Detik',
                  hintText: '00',
                  border:
                      OutlineInputBorder(),
                  prefixIcon:
                      Icon(
                    Icons.access_time,
                  ),
                ),

                enabled: !isRunning,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // ==================================================
        // TOMBOL ATUR WAKTU
        // ==================================================

        SizedBox(
          width: double.infinity,

          child: OutlinedButton.icon(
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  const Color(0xFF869277),

              side:
                  const BorderSide(
                color:
                    Color(0xFF869277),
              ),

              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 13,
              ),
            ),

            onPressed: isRunning
                ? null
                : _setCountdownDuration,

            icon: const Icon(
              Icons.settings,
            ),

            label: const Text(
              'Atur Waktu',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // ==================================================
        // DISPLAY COUNTDOWN
        // ==================================================

        Container(
          width: double.infinity,

          padding:
              const EdgeInsets.symmetric(
            vertical: 40,
            horizontal: 20,
          ),

          decoration: BoxDecoration(
            color: const Color(
              0xFFB88E65,
            ).withOpacity(0.12),

            borderRadius:
                BorderRadius.circular(20),
          ),

          child: Column(
            children: [
              Icon(
                _remainingDuration ==
                        Duration.zero
                    ? Icons.alarm_off
                    : Icons.hourglass_bottom,

                size: 55,

                color:
                    const Color(0xFFB88E65),
              ),

              const SizedBox(height: 15),

              Text(
                _formatCountdown(
                  _remainingDuration,
                ),

                style: const TextStyle(
                  fontSize: 48,
                  fontWeight:
                      FontWeight.bold,
                  letterSpacing: 3,
                  color:
                      Color(0xFFB88E65),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _remainingDuration ==
                        Duration.zero
                    ? 'Belum ada waktu yang diatur'
                    : isRunning
                        ? 'Hitung mundur sedang berjalan'
                        : 'Siap untuk dimulai',

                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // ==================================================
        // TOMBOL COUNTDOWN
        // ==================================================

        Row(
          children: [
            // MULAI / JEDA
            Expanded(
              child: ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF869277,
                  ),

                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 14,
                  ),
                ),

                onPressed:
                    _remainingDuration <=
                            Duration.zero
                        ? _startCountdown
                        : isRunning
                            ? _pauseCountdown
                            : _startCountdown,

                icon: Icon(
                  isRunning
                      ? Icons.pause
                      : Icons.play_arrow,

                  color: Colors.white,
                ),

                label: Text(
                  isRunning
                      ? 'Jeda'
                      : 'Mulai',

                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // RESET
            Expanded(
              child: OutlinedButton.icon(
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(
                    0xFFB88E65,
                  ),

                  side:
                      const BorderSide(
                    color:
                        Color(0xFFB88E65),
                  ),

                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 14,
                  ),
                ),

                onPressed:
                    _resetCountdown,

                icon: const Icon(
                  Icons.refresh,
                ),

                label: const Text(
                  'Reset',
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ==================================================
        // INFORMASI
        // ==================================================

        Container(
          width: double.infinity,

          padding:
              const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: const Color(
              0xFF869277,
            ).withOpacity(0.08),

            borderRadius:
                BorderRadius.circular(12),
          ),

          child: const Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Icon(
                Icons.info_outline,
                color:
                    Color(0xFF869277),
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Masukkan durasi dalam menit dan detik. '
                  'Contoh: masukkan 50 pada kolom menit '
                  'untuk membuat timer selama 50 menit.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}