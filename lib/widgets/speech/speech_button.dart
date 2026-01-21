import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../constants/app_colors.dart';

class SpeechButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final double size;

  const SpeechButton({
    super.key,
    required this.isListening,
    required this.onPressed,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isListening ? AppColors.error : AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isListening ? AppColors.error : AppColors.primary)
                  .withValues(alpha: 0.3),
              blurRadius: isListening ? 20 : 10,
              spreadRadius: isListening ? 5 : 2,
            ),
          ],
        ),
        child: Icon(
          isListening
              ? PhosphorIcons.stop(PhosphorIconsStyle.fill)
              : PhosphorIcons.microphone(PhosphorIconsStyle.fill),
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }
}
