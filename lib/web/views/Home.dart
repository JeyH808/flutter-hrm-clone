import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../common/services/authentication.dart';
import '../../common/widgets/ListOptionsWidget.dart';
import '../../common/widgets/GridHomePage.dart';
import 'dart:typed_data';

class WebHome extends StatefulWidget {
  const WebHome({super.key});

  @override
  _WebHomeState createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  String selectedOption = 'Trang Chủ';

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

            return Row(
              children: [
                // Phần Navbar (30%)
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.grey[200],
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: userData['profileImage'] != null
                                        ? MemoryImage(Uint8List.fromList(
                                        List<int>.from(
                                            userData['profileImage'])))
                                        : const AssetImage(
                                        'lib/img/default-user-avt.png') as ImageProvider,
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
                                  Text(
                                    userData?['department'] ?? 'Không có bộ phận',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ListOptionsWidget(
                          icon: Icons.home,
                          title: 'Trang Chủ',
                          isSelected: selectedOption == 'Trang Chủ',
                          onTap: () {
                            setState(() {
                              selectedOption = 'Trang Chủ';
                            });
                          },
                        ),
                        ListOptionsWidget(
                          icon: Icons.person,
                          title: 'Hồ sơ',
                          description: 'Thay đổi thông tin cá nhân',
                          isSelected: selectedOption == 'Hồ sơ',
                          onTap: () {
                            setState(() {
                              selectedOption = 'Hồ sơ';
                            });
                          },
                        ),
                        ListOptionsWidget(
                          icon: Icons.lock,
                          title: 'Bảo mật',
                          description: 'Danh sách thiết bị đăng nhập, đổi mật khẩu',
                          isSelected: selectedOption == 'Bảo mật',
                          onTap: () {
                            setState(() {
                              selectedOption = 'Bảo mật';
                            });
                          },
                        ),
                        ListOptionsWidget(
                          icon: Icons.notifications,
                          title: 'Cài đặt thông báo',
                          description: 'Tắt/bật các thông báo cần thiết',
                          isSelected: selectedOption == 'Cài đặt thông báo',
                          onTap: () {
                            setState(() {
                              selectedOption = 'Cài đặt thông báo';
                            });
                          },
                        ),
                        ListOptionsWidget(
                          icon: Icons.logout,
                          title: 'Đăng xuất',
                          iconColor: Colors.red,
                          textColor: Colors.red,
                          onTap: () async {
                            await FirebaseAuthService().signOut(context);
                            context.go('/');
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Phần Nội dung (70%)
                Expanded(
                  flex: 7,
                  child: Container(
                    color: Colors.white,
                    child: selectedOption == 'Trang Chủ'
                        ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          GridItem(
                            icon: Icons.calendar_today,
                            title: 'Lịch làm việc',
                            subtitle: 'Ca làm việc và thay ca',
                            onTap: () {},
                          ),
                          GridItem(
                              icon: Icons.beach_access,
                              title: 'Đăng ký nghỉ',
                              subtitle: 'Nghỉ ngày, nghỉ ca',
                              onTap: () {}),
                          GridItem(
                              icon: Icons.access_time,
                              title: 'Số giờ làm việc',
                              subtitle: '89 giờ',
                              onTap: () {}),
                          GridItem(
                              icon: Icons.announcement,
                              title: 'Bảng tin',
                              subtitle: '0 tin tức',
                              onTap: () {}),
                        ],
                      ),
                    )
                        : const Center(
                      child: Text(
                        'Chức năng đang phát triển',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
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
