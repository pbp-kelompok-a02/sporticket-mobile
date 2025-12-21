import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sporticket_mobile/event/widgets/bottom_navbar.dart';
import 'package:sporticket_mobile/event/screens/event_list.dart';
import 'package:sporticket_mobile/models/profile.dart';

class ProfilePage extends StatefulWidget {
  final int? userId; // kalo null, berarti liat profil sendiri yg lg login

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Profile? userProfile;
  bool isLoading = true;

  final Color profileHeaderColor = const Color(0xFF537fb9);

  // variabel buat simpan gambar baru yg dipilih saat edit
  String? _newImageBase64;
  String? _newImageName;
  final ImagePicker _picker = ImagePicker();

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
      String url = 'http://127.0.0.1:8000/account/profile-mobile/';

      if (widget.userId != null) {
        url = 'http://127.0.0.1:8000/account/profile-mobile/${widget.userId}/';
      }

      final response = await request.get(url);

      if (!mounted) return;

      setState(() {
        if (response['status'] == true) {
          userProfile = Profile.fromJson(response['data']);
        }
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // fungsi helper buat pilih gambar baru
  Future<void> _pickNewImage(StateSetter setStateModal) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      String mimeType = "image/jpeg";
      if (pickedFile.path.endsWith(".png")) {
        mimeType = "image/png";
      }

      final String formattedBase64 = "data:$mimeType;base64,$base64Image";

      // pake setStateModal biar UI di dalem dialog ke-update
      setStateModal(() {
        _newImageBase64 = formattedBase64;
        _newImageName = pickedFile.name;
      });
    }
  }

  // munculin popup buat edit profil (nama, no hp, & FOTO)
  void showEditDialog() {
    String name = userProfile?.name ?? "";
    String phone = userProfile?.phoneNumber ?? "";

    // reset gambar baru setiap kali dialog dibuka
    _newImageBase64 = null;
    _newImageName = null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // pake StatefulBuilder biar bisa setState di dalam dialog sehingga bisa update preview gambar
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: const Text("Edit Profile"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // bagian buat nampilin foto profil & ganti foto
                    GestureDetector(
                      onTap: () => _pickNewImage(setStateModal),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.grey[100],
                            ),
                            child: ClipOval(
                              // logika nampilin gambar : kalo ada gambar baru, pake itu. kalo gaada, pake gambar lama. kalo gaada gambar lama, pake placeholder
                              child: _newImageBase64 != null
                                  ? Image.memory(
                                      base64Decode(
                                        _newImageBase64!.split(',').last,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : (userProfile?.profilePhoto != null
                                        // TODO: ganti jd link pws
                                        ? Image.network(
                                            "http://127.0.0.1:8000${userProfile!.profilePhoto!}",
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/images/no-profile-picture.png',
                                            fit: BoxFit.cover,
                                          )),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _newImageName ?? "Tap to change photo",
                            style: TextStyle(
                              color: profileHeaderColor,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: "Full Name"),
                      onChanged: (val) => name = val,
                      controller: TextEditingController(text: name),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                      ),
                      onChanged: (val) => phone = val,
                      controller: TextEditingController(text: phone),
                    ),
                  ],
                ),
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
                      // siapin data yg mau dikirim
                      Map<String, dynamic> dataToSend = {
                        'name': name,
                        'phone_number': phone,
                      };

                      // cuma tambahin profile_photo kalo user milih gambar baru
                      if (_newImageBase64 != null) {
                        dataToSend['profile_photo'] = _newImageBase64;
                      }

                      // TODO: ganti jd link pws
                      final response = await request.postJson(
                        'http://127.0.0.1:8000/account/edit-profile-mobile/',
                        jsonEncode(dataToSend),
                      );

                      if (mounted) {
                        Navigator.pop(context);

                        if (response['status'] == true) {
                          fetchProfile();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Profile Updated!")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response['message'] ?? "Failed"),
                            ),
                          );
                        } 
                      }                     
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
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
                  'http://127.0.0.1:8000/account/delete-account-mobile/',
                  {},
                );

                if (mounted) {
                  Navigator.pop(context);
                  // cek response dari server
                  if (response['status'] == true ||
                      response['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Account deleted successfully."),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // logout supaya navbar berubah ke versi not logged in
                    await request.logout(
                      'http://127.0.0.1:8000/account/logout-mobile/',
                    );

                    if (!mounted) return;

                    // redirect ke halaman utama setelah hapus akun
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
                          response['message'] ?? "Failed to delete account",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // tutup dialog kalo error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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

    final data = userProfile;

    if (data == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text("Failed to load profile.")),
      );
    }

    final bool isAdmin = data.isSuperuser;

    final bool isOwnProfile = data.isOwnProfile;
    final bool canSeeSensitive = data.canSeeSensitiveData;

    final bool showActions = isOwnProfile && !isAdmin;

    // TODO: ganti jd link pws
    final String photoUrl = data.profilePhoto != null
        ? "http://127.0.0.1:8000${data.profilePhoto}"
        : "";

    String headerDisplayName = data.name;
    if (isAdmin) {
      headerDisplayName = "Admin";
    } else if (headerDisplayName == "Not Set" || headerDisplayName.isEmpty) {
      headerDisplayName = data.username;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: widget.userId == null
          ? const BottomNavBarWidget()
          : null,

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
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login-background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

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
                                  const SizedBox(height: 20),
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

                                if (isOwnProfile) ...[
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
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
                                _sectionTitle("Basic Information"),
                                const SizedBox(height: 16),
                                _infoRow(
                                  "Full Name",
                                  data.name.isNotEmpty ? data.name : "Not set",
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

                                _sectionTitle("Account Details"),
                                const SizedBox(height: 16),

                                if (canSeeSensitive) ...[
                                  _infoRow("Email Address", data.email),
                                  const SizedBox(height: 16),
                                  _infoRow(
                                    "Phone Number",
                                    data.phoneNumber ?? "Not set",
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
                                      isAdmin ? "Admin" : data.role,
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
