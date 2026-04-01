import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/patient.dart';
import '../../login_page.dart';
import '../../theme.dart';
import '../../widgets/profile_avatar.dart';

class PatientProfile extends StatefulWidget {
  final User user;
  const PatientProfile({Key? key, required this.user}) : super(key: key);

  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  Patient? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try { profile = await ApiService.getMyProfile(widget.user.code); } catch (_) {}
    if (mounted) setState(() => isLoading = false);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (_) => false,
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.darkGreen))
          : CustomScrollView(
              slivers: [
                // ── Collapsing header ──────────────────────────────────
                SliverAppBar(
                  expandedHeight: 230,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout_rounded,
                          color: Colors.white70),
                      onPressed: _showLogoutDialog,
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: AppDecorations.headerGradient,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          ProfileAvatar(
                            name: widget.user.name,
                            photoUrl: photoUrl(profile?.photo),
                            radius: 46,
                          ),
                          const SizedBox(height: 14),
                          Text(widget.user.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      AppColors.accentGreen.withOpacity(0.5)),
                            ),
                            child: const Text('Patient',
                                style: TextStyle(
                                    color: AppColors.accentGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Content ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Personal Information',
                            style: AppTextStyles.heading3),
                        const SizedBox(height: 12),

                        Container(
                          decoration: AppDecorations.card,
                          child: Column(
                            children: [
                              _tile(Icons.badge_rounded, 'Patient ID',
                                  widget.user.code, AppColors.accentIndigo),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _tile(Icons.email_rounded, 'Email',
                                  profile?.email ?? '—', AppColors.accentTeal),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _tile(Icons.phone_rounded, 'Phone',
                                  profile?.phone ?? '—', AppColors.statusCompleted),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _tile(Icons.cake_rounded, 'Date of Birth',
                                  profile?.birthdate ?? '—', AppColors.accentOrange),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _tile(Icons.person_rounded, 'Gender',
                                  profile?.gender ?? '—', AppColors.accentPurple),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              _tile(Icons.location_on_rounded, 'Address',
                                  profile?.address ?? '—', AppColors.accentRed,
                                  isLast: true),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _showLogoutDialog,
                            icon: const Icon(Icons.logout_rounded,
                                color: AppColors.accentRed),
                            label: const Text('Sign Out',
                                style: TextStyle(
                                    color: AppColors.accentRed,
                                    fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.accentRed.withOpacity(0.4)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _tile(
    IconData icon,
    String label,
    String value,
    Color color, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, isLast ? 14 : 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: AppDecorations.iconBadge(color),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyBold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
