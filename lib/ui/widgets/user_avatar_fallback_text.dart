import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Widget privado para mostrar las iniciales del usuario como fallback de avatar
class UserAvatarFallbackText extends StatelessWidget {
  const UserAvatarFallbackText({
    required this.user,
    required this.theme,
    super.key,
  });
  final UserModel user;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final String initials = user.displayName.isNotEmpty
        ? user.displayName
              .trim()
              .split(' ')
              .map((String w) => w.isNotEmpty ? w[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : '--';
    return Text(
      initials,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }
}
