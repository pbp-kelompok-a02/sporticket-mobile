import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporticket_mobile/event/widgets/bottom_navbar.dart';
import 'package:sporticket_mobile/event/screens/event_list.dart';

class ProfilePage extends StatefulWidget {
  final int? userId; // kalo null, berarti liat profil sendiri yg lg login

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  final Color profileHeaderColor = const Color(0xFF537fb9);

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  // fungsi buat ambil data profil dari django
  Future<void> fetchProfile() async {
    final request = context.read<CookieRequest>();
    try {
      // TODO: ganti jd link pws
      // endpoint buat liat profil sendiri
      String url = 'http://127.0.0.1:8000/account/profile-mobile/';

      // kalo ada userid yg dipassing, ganti url jd endpoint detail profil org lain
      // ini endpoint untuk liat profil org lain
      if (widget.userId != null) {
        url = 'http://127.0.0.1:8000/account/profile-mobile/${widget.userId}/';
      }

      final response = await request.get(url);
      if (mounted) {
        setState(() {
          if (response['status'] == true) {
            userProfile = response['data'];
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // logic buat logout, panggil endpoint logout di django
  Future<void> handleLogout() async {
    final request = context.read<CookieRequest>();
    try {
      // TODO: ganti jd link pws
      final response = await request.logout(
        "http://127.0.0.1:8000/account/logout-mobile/",
      );
      if (!mounted) return;

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Logged out successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        // redirect ke halaman event list & apus history navigasi biar ga bs back karena udh logout
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const EventListPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Logout failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // munculin popup buat edit profil (nama & no hp)
  void showEditDialog() {
    String name = userProfile?['name'] ?? "";
    String phone = userProfile?['phone_number'] ?? "";

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Full Name"),
              onChanged: (val) => name = val,
              controller: TextEditingController(text: name),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Phone Number"),
              onChanged: (val) => phone = val,
              controller: TextEditingController(text: phone),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final request = context.read<CookieRequest>();
              try {
                // TODO: ganti jd link pws
                final response = await request.post(
                  'http://127.0.0.1:8000/account/edit-profile-mobile/',
                  {'name': name, 'phone_number': phone},
                );

                if (mounted) {
                  Navigator.pop(context);
                  if (response['status'] == true) {
                    fetchProfile(); // refresh data di layar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile Updated!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'] ?? "Failed")),
                    );
                  }
                }
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // munculin popup buat ganti password
  void showPasswordDialog() {
    String currentPass = "";
    String newPass = "";
    String confirmPass = "";

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: "Current Password"),
              onChanged: (v) => currentPass = v,
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
              onChanged: (v) => newPass = v,
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
              onChanged: (v) => confirmPass = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final request = context.read<CookieRequest>();
              try {
                // TODO: ganti jd link pws
                final response = await request.post(
                  'http://127.0.0.1:8000/account/change-password-mobile/',
                  {
                    'current_password': currentPass,
                    'new_password': newPass,
                    'confirm_password': confirmPass,
                  },
                );

                if (mounted) {
                  Navigator.pop(context);
                  if (response['status'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password changed!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response['message'] ?? "Failed"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }

  // munculin popup konfirmasi hapus akun
  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final request = context.read<CookieRequest>();
              try {
                // TODO: ganti jd link pws
                final response = await request.post(
                  'http://127.0.0.1:8000/account/delete-account/',
                  {},
                );

                if (mounted) {
                  Navigator.pop(context);
                  if (response['status'] == true ||
                      response['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Account deleted.")),
                    );
                    // balikin ke halaman awal kalo akun dh kehapus
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EventListPage(),
                      ),
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          response['message'] ?? "Failed to delete",
                        ),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = userProfile ?? {};
    final bool isAdmin = (data['is_superuser'] == true);

    // logic display data sensitif (email, no hp)
    final bool isOwnProfile = data['is_own_profile'] ?? true;
    final bool canSeeSensitive = data['can_see_sensitive_data'] ?? true;

    // logic tombol edit & delete -> cuma muncul kalo profil sendiri DAN bukan admin
    final bool showActions = isOwnProfile && !isAdmin;

    // TODO: ganti jd link pws
    final String photoUrl = data['profile_photo'] != null
        ? "http://127.0.0.1:8000${data['profile_photo']}"
        : "";

    // logic nama di header -> kalo admin tulisan namanya "admin", kalo user biasa ya nama dia
    String headerDisplayName = data['name'] ?? "User";
    if (isAdmin) {
      headerDisplayName = "Admin";
    } else if (headerDisplayName == "Not Set") {
      headerDisplayName = data['username'] ?? "User";
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      // navbar cuma muncul kalo lg liat profil sendiri (ga ada userid di parameter)
      bottomNavigationBar: widget.userId == null
          ? const BottomNavBarWidget()
          : null,

      // kalo liat profil org lain, kasih tombol back di appbar
      appBar: widget.userId != null
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
            )
          : null,

      body: Stack(
        children: [
          // background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login-background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // card utama
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          spreadRadius: 0,
                          blurRadius: 50,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Column(
                        children: [
                          // header section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            color: profileHeaderColor,
                            child: Column(
                              children: [
                                if (widget.userId != null)
                                  const SizedBox(
                                    height: 20,
                                  ), // spasi buat tombol back
                                Row(
                                  children: [
                                    // foto profil
                                    Container(
                                      width: 96,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: photoUrl.isNotEmpty
                                            ? Image.network(
                                                photoUrl,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'assets/images/no-profile-picture.png',
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),

                                    // info nama & status akun
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            headerDisplayName,
                                            style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            isOwnProfile
                                                ? "Your Personal Account"
                                                : "User Profile",
                                            style: const TextStyle(
                                              color: Color(0xFFDBEAFE),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // tombol-tombol di header (cuma buat profil sendiri)
                                if (isOwnProfile) ...[
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      // tombol edit profil (admin gabisa edit)
                                      if (!isAdmin) ...[
                                        ElevatedButton(
                                          onPressed: showEditDialog,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: profileHeaderColor,
                                            elevation: 0,
                                            shape: const StadiumBorder(),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            "Edit Profile",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],

                                      // tombol logout
                                      ElevatedButton(
                                        onPressed: handleLogout,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: const StadiumBorder(),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: const Text(
                                          "Logout",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // body section
                          Container(
                            padding: const EdgeInsets.all(32),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // basic info
                                _sectionTitle("Basic Information"),
                                const SizedBox(height: 16),
                                _infoRow(
                                  "Full Name",
                                  data['name'] ?? "Not set",
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Profile Photo",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: photoUrl.isNotEmpty
                                        ? Image.network(
                                            photoUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/images/no-profile-picture.png',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // account details
                                _sectionTitle("Account Details"),
                                const SizedBox(height: 16),

                                // tampilan data sensitif kalo boleh liat (admin atau owner akun)
                                if (canSeeSensitive) ...[
                                  _infoRow(
                                    "Email Address",
                                    data['email'] ?? "Not set",
                                  ),
                                  const SizedBox(height: 16),
                                  _infoRow(
                                    "Phone Number",
                                    data['phone_number'] ?? "Not set",
                                  ),
                                  const SizedBox(height: 16),

                                  const Text(
                                    "Account Role",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAdmin
                                          ? Colors.purple[100]
                                          : Colors.blue[100],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isAdmin
                                          ? "Admin"
                                          : (data['role'] ?? "Buyer"),
                                      style: TextStyle(
                                        color: isAdmin
                                            ? Colors.purple[800]
                                            : Colors.blue[800],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  // tampilan kalo ga boleh liat data sensitif (bukan admin atau bukan account owner)
                                  Center(
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.lock_outline,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Some information is hidden for privacy",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 32),
                                const Divider(),

                                // quick actions (cuma buat owner yg bukan admin karena account admin immutable)
                                if (showActions) ...[
                                  _sectionTitle(
                                    "Quick Actions",
                                    withLine: false,
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _quickActionButton(
                                        "Edit Profile",
                                        Icons.edit,
                                        profileHeaderColor,
                                        showEditDialog,
                                      ),
                                      _quickActionButton(
                                        "Change Password",
                                        Icons.lock,
                                        Colors.green,
                                        showPasswordDialog,
                                      ),
                                      _quickActionButton(
                                        "Delete Account",
                                        Icons.delete_forever,
                                        Colors.red,
                                        showDeleteDialog,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // widget buat section title
  Widget _sectionTitle(String title, {bool withLine = true}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: withLine
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            )
          : null,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // widget buat row info label & value
  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ],
    );
  }

  // widget buat action button
  Widget _quickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}