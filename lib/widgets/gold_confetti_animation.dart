import 'dart:math' as math;

import 'package:flutter/material.dart';

/// パズル完成時に表示する金色の紙吹雪アニメーション
///
/// 盤面の中央から金色の紙片が放射状に広がり、
/// 回転しながら落下していく演出を行う。
///
/// 表示時間は約3秒。
class GoldConfettiAnimation extends StatefulWidget {
  const GoldConfettiAnimation({
    super.key,
    this.duration = const Duration(seconds: 3),
    this.particleCount = 100,
    this.onCompleted,
  });

  /// アニメーションの再生時間
  final Duration duration;

  /// 紙吹雪の数
  final int particleCount;

  /// アニメーション終了時のコールバック
  final VoidCallback? onCompleted;

  @override
  State<GoldConfettiAnimation> createState() =>
      _GoldConfettiAnimationState();
}

class _GoldConfettiAnimationState
    extends State<GoldConfettiAnimation>
    with SingleTickerProviderStateMixin {
  /// アニメーションコントローラー
  late final AnimationController _controller;

  /// 紙吹雪のデータ
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();

    // 紙吹雪の位置・大きさ・回転などを生成
    _particles = _createParticles();

    // 約3秒間のアニメーションを設定
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // アニメーション終了時の処理
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call();
      }
    });

    // アニメーション開始
    _controller.forward();
  }

  /// 紙吹雪のデータを生成する
  List<_ConfettiParticle> _createParticles() {
    final math.Random random = math.Random();

    return List.generate(
      widget.particleCount,
      (int index) {
        // 中央から放射状に広がる方向
        final double angle =
            random.nextDouble() * math.pi * 2;

        // 紙吹雪が広がる速度
        final double speed =
            0.55 + random.nextDouble() * 0.75;

        // 紙吹雪の大きさ
        final double width =
            3.0 + random.nextDouble() * 5.0;

        final double height =
            5.0 + random.nextDouble() * 8.0;

        // 紙吹雪の回転速度
        final double rotationSpeed =
            (random.nextDouble() * 8.0 + 3.0) *
                (random.nextBool() ? 1 : -1);

        // 紙吹雪の落下量
        final double gravity =
            0.15 + random.nextDouble() * 0.25;

        // 表示開始タイミングを少しずつずらす
        final double delay =
            random.nextDouble() * 0.12;

        // 金色のバリエーション
        final List<Color> goldColors = [
          const Color(0xFFFFD700),
          const Color(0xFFFFC107),
          const Color(0xFFFFE082),
          const Color(0xFFD4AF37),
          const Color(0xFFFFF1A8),
          const Color(0xFFDAA520),
        ];

        final Color color =
            goldColors[random.nextInt(goldColors.length)];

        return _ConfettiParticle(
          angle: angle,
          speed: speed,
          width: width,
          height: height,
          rotationSpeed: rotationSpeed,
          gravity: gravity,
          delay: delay,
          color: color,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _GoldConfettiPainter(
                progress: _controller.value,
                particles: _particles,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

/// 紙吹雪1つ分のデータ
class _ConfettiParticle {
  const _ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.width,
    required this.height,
    required this.rotationSpeed,
    required this.gravity,
    required this.delay,
    required this.color,
  });

  /// 広がる方向
  final double angle;

  /// 広がる速度
  final double speed;

  /// 紙片の横幅
  final double width;

  /// 紙片の縦幅
  final double height;

  /// 回転速度
  final double rotationSpeed;

  /// 落下量
  final double gravity;

  /// 表示開始タイミング
  final double delay;

  /// 紙片の色
  final Color color;
}

/// 金色の紙吹雪を描画する
class _GoldConfettiPainter extends CustomPainter {
  const _GoldConfettiPainter({
    required this.progress,
    required this.particles,
  });

  /// アニメーションの進行度
  final double progress;

  /// 紙吹雪の一覧
  final List<_ConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    // パズル盤面の中央
    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    // 紙吹雪が広がる最大距離
    final double maxRadius =
        math.sqrt(
          size.width * size.width +
              size.height * size.height,
        ) *
        0.48;

    for (final _ConfettiParticle particle in particles) {
      // 紙吹雪ごとの開始タイミングを反映
      final double localProgress =
          ((progress - particle.delay) /
                  (1.0 - particle.delay))
              .clamp(0.0, 1.0);

      if (localProgress <= 0) {
        continue;
      }

      // 放射状に広がる距離
      final double easedProgress =
          Curves.easeOut.transform(localProgress);

      final double distance =
          maxRadius * particle.speed * easedProgress;

      // 放射状の移動
      final double dx =
          math.cos(particle.angle) * distance;

      final double dy =
          math.sin(particle.angle) * distance;

      // 重力による落下
      final double gravityOffset =
          size.height *
              particle.gravity *
              localProgress *
              localProgress;

      final Offset position = Offset(
        center.dx + dx,
        center.dy + dy + gravityOffset,
      );

      // 回転角度
      final double rotation =
          particle.rotationSpeed *
              localProgress *
              math.pi;

      // 終了に向かって透明にする
      final double opacity =
          (1.0 - Curves.easeIn.transform(
            ((localProgress - 0.65) / 0.35)
                .clamp(0.0, 1.0),
          ));

      if (opacity <= 0) {
        continue;
      }

      final Paint paint = Paint()
        ..color = particle.color.withValues(
          alpha: opacity,
        )
        ..style = PaintingStyle.fill;

      canvas.save();

      canvas.translate(
        position.dx,
        position.dy,
      );

      canvas.rotate(rotation);

      // 紙片を長方形として描画
      final Rect rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.width,
        height: particle.height,
      );

      // 角を少し丸くした紙吹雪
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(1.2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(
    covariant _GoldConfettiPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
  }
}