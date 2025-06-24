import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'user_avatar_fallback_text.dart';

class UserSquareWidget extends StatelessWidget {
  const UserSquareWidget({
    required this.user,
    this.onTap,
    this.displayName = true,
    super.key,
  });

  final UserModel user;
  final VoidCallback? onTap;
  final bool displayName;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color fallbackColor = theme.colorScheme.secondary.withValues(
      alpha: 0.82,
    );
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(
            radius: 24,
            backgroundColor: fallbackColor,
            child: (user.photoUrl.isEmpty)
                ? UserAvatarFallbackText(user: user, theme: theme)
                : ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.photoUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (BuildContext context, String url) => Center(
                        child: UserAvatarFallbackText(user: user, theme: theme),
                      ),
                      errorWidget:
                          (BuildContext context, String url, Object error) =>
                              Center(
                                child: UserAvatarFallbackText(
                                  user: user,
                                  theme: theme,
                                ),
                              ),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          if (displayName)
            Text(
              user.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
        ],
      ),
    );
  }
}
