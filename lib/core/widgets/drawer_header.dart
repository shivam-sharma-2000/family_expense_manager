import 'package:cached_network_image/cached_network_image.dart';
import 'package:expense_manager/core/extensions/theme_extension.dart';
import 'package:expense_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:expense_manager/features/user/presentation/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

class DrawerHeaderSection extends StatelessWidget {
  const DrawerHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        String name = 'Loading...';
        String email = '';
        String? photoUrl;

        if (state is UserLoaded) {
          name = state.user.name;
          email = state.user.email;
          photoUrl = state.user.photoUrl;

          if (photoUrl == null || photoUrl.isEmpty) {
            photoUrl =
                'https://ui-avatars.com/api/?name=$name&size=300&utm_source=chatgpt.com';
          }
        } else if (state is UserError) {
          name = 'Error loading profile';
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: context.theme.colorScheme.primary.withValues(
                  alpha: 0.5,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: photoUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => HugeIcon(
                      icon: HugeIcons.strokeRoundedUser,
                      size: 28,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.theme.colorScheme.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
