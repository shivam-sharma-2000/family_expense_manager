import 'package:expense_manager/core/di/injection_container.dart';
import 'package:expense_manager/core/service/i_local_storage_service.dart';
import 'package:expense_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:expense_manager/features/user/presentation/bloc/user_event.dart';
import 'package:expense_manager/features/user/presentation/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:expense_manager/features/family/presentation/widgets/create_family_dialog.dart';

import '../../../../core/extensions/theme_extension.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final localStorage = sl<ILocalStorageService>();
    final userId = await localStorage.userId;
    if (userId != null && mounted) {
      context.read<UserBloc>().add(LoadUserEvent(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedAlert02,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load profile',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadUser,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is UserLoaded) {
            final user = state.user;
            String? photoUrl = user.photoUrl;

            if (photoUrl == null || photoUrl.isEmpty) {
              photoUrl =
                  'https://ui-avatars.com/api/?name=${user.name}&size=300&utm_source=chatgpt.com';
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    backgroundImage: photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    onBackgroundImageError: (_, __) {},
                    child: photoUrl.isEmpty
                        ? HugeIcon(
                            icon: HugeIcons.strokeRoundedUser,
                            size: 50,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Name & Email
                  Text(
                    user.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Details Card
                  Card(
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildProfileItem(
                            context: context,
                            icon: HugeIcons.strokeRoundedBadge,
                            title: 'User ID',
                            value: '${user.id.substring(0, 8)}...',
                          ),
                          const Divider(),
                          _buildProfileItem(
                            context: context,
                            icon: HugeIcons.strokeRoundedUserGroup,
                            title: 'Family ID',
                            value: user.familyId ?? 'None',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Edit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/edit_profile', extra: user);
                      },
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedEdit02,
                        color: context.theme.colorScheme.onPrimary,
                      ),
                      label: Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.onPrimary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  if (user.familyId == null || user.familyId!.isEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                CreateFamilyDialog(userId: user.id),
                          );
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedUserGroup,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          'Create Family',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/edit_profile', extra: user);
                      },
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedLogout01,
                        color: context.theme.colorScheme.onPrimary,
                      ),
                      label: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.onError,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/sync', extra: user);
                      },
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedRefresh,
                        color: context.theme.colorScheme.onPrimary,
                      ),
                      label: Text(
                        'Sync Data',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.onError,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No profile data.'));
        },
      ),
    );
  }

  Widget _buildProfileItem({
    required BuildContext context,
    required dynamic icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: HugeIcon(icon: icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
