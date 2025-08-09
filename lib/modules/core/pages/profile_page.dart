import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/modules/core/pages/become_provider_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  String displayName = '';
  String email = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    if (!mounted) return;
    setState(() {
      displayName =
          (doc.data()?['name'] ?? user.displayName ?? 'Usuario').toString();
      phone = (doc.data()?['phone'] ?? '').toString();
      email = user.email ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1976D2);
    const pageBg = Color(0xFFEFF4FF);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // ==== HEADER ====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 21, 98, 176),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // fila de back + Edit Profile
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        const Spacer(),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BecomeProviderPage(),
                              ),
                            );
                          },
                          child: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Avatar
                    Container(
                      width: 86,
                      height: 86,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/parking_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${user.uid.substring(0, 8)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // ==== CARD BLANCA SUPERPUESTA ====
              Transform.translate(
                offset: const Offset(0, -32),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    top: 0,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _SectionTile(
                        icon: Icons.lock_outline,
                        label: 'Password',
                        onTap: () {
                          // TODO: navegar a cambio de contraseña
                        },
                      ),
                      _SectionTile(
                        icon: Icons.mail_outline,
                        label: 'Email Address',
                        subtitle: email,
                        onTap: () {
                          // TODO: editar email
                        },
                      ),
                      _SectionTile(
                        icon: Icons.fingerprint,
                        label: 'Fingerprint',
                        onTap: () {
                          // TODO: activar biométrico
                        },
                      ),
                      const SizedBox(height: 8),
                      _SectionTile(
                        icon: Icons.support_agent_outlined,
                        label: 'Support',
                        filled: true,
                        onTap: () {
                          // TODO: abrir soporte
                        },
                      ),
                      _SectionTile(
                        icon: Icons.logout,
                        label: 'Sign Out',
                        filled: true,
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.of(context).popUntil((r) => r.isFirst);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BecomeProviderPage(),
                            ),
                          );
                        },
                        child: const Text('Volverse proveedor...'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tile redondeado estilo “card” con icono y chevron
class _SectionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool filled;
  final VoidCallback? onTap;

  const _SectionTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.filled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? const Color(0xFFF4F7FE) : Colors.white;
    final border = filled ? Colors.transparent : const Color(0xFFE6ECF7);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          if (!filled)
            const BoxShadow(
              color: Color(0x11000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.apps,
            color: Color(0xFF1976D2),
          ), // se reemplaza abajo
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle:
            subtitle == null
                ? null
                : Text(subtitle!, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
