import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../common/services/authentication.dart';
import '../../common/widgets/BottomNavBarWidget.dart';
import '../../common/widgets/ListOptionsWidget.dart';
import 'dart:typed_data';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser?.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text('Không tìm thấy dữ liệu người dùng'),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              children: [
                // Title Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: userData['profileImage'] != null
                                    ? MemoryImage(Uint8List.fromList(List<int>.from(userData['profileImage'])))
                                    : const AssetImage('lib/img/default-user-avt.png') as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'] ?? 'Không có tên',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Chỉnh sửa thông tin cá nhân',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
                // List Section
                Expanded(
                  child: Column(
                    children: [
                      const ListOptionsWidget(
                        icon: Icons.lock,
                        title: 'Bảo mật',
                        description: 'Danh sách thiết bị đăng nhập, đổi mật khẩu',
                      ),
                      const ListOptionsWidget(
                        icon: Icons.notifications,
                        title: 'Cài đặt thông báo',
                        description: 'Tắt/bật các thông báo cần thiết',
                      ),
                      const ListOptionsWidget(
                        icon: Icons.feedback,
                        title: 'Đóng góp ý kiến, báo lỗi',
                        description: 'Đóng góp ý kiến, báo lỗi',
                      ),
                      const ListOptionsWidget(
                        icon: Icons.group,
                        title: 'Group HRM trên Facebook',
                        description: 'Cộng đồng trao đổi, tư vấn kinh nghiệm',
                      ),
                      const ListOptionsWidget(
                        icon: Icons.swap_horiz,
                        title: 'Chuyển tài khoản',
                        description: 'Có thể đăng nhập nhiều tài khoản...',
                      ),
                      ListOptionsWidget(
                        icon: Icons.logout,
                        title: 'Đăng xuất',
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () async {
                          // Thực hiện đăng xuất
                          await FirebaseAuthService().signOut(context);
                          context.go('/');
                        },
                      ),
                    ],
                  ),
                ),
                // Bottom Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HRM Nhân Viên v2.8.8'),
                          Text('Powered by iPOS.vn'),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.flag),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
