import 'package:flutter/material.dart';
import '../theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ProfileAvatar({
    Key? key,
    required this.name,
    this.photoUrl,
    this.radius = 26,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.accentGreen;
    final fg = foregroundColor ?? AppColors.darkGreen;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: ClipOval(
          child: Image.network(
            photoUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Center(
                child: SizedBox(
                  width: radius * 0.7,
                  height: radius * 0.7,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: fg,
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _initial(initial, fg, radius),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: _initial(initial, fg, radius),
    );
  }

  Widget _initial(String letter, Color color, double r) {
    return Text(
      letter,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: r * 0.72,
      ),
    );
  }
}
