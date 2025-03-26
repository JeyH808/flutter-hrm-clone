import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../common/services/authentication.dart';
import '../../common/widgets/ListOptionsWidget.dart';
import '../../common/widgets/GridHomePage.dart';
import 'dart:typed_data';

import 'WebScheduleBox.dart';

class WebHome extends StatefulWidget {
  const WebHome({super.key});

  @override
  _WebHomeState createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  String selectedOption = 'Trang Chủ';
  final ScrollController scrollController = ScrollController();

  void scrollLeft() {
    scrollController.animateTo(
      scrollController.offset - 220,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
    );
  }

  void scrollRight() {
    scrollController.animateTo(
      scrollController.offset + 220,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
    );
  }


  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

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
                                    userData['department'] ?? 'Không có bộ phận',
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
                Expanded(
                  flex: 7,
                  child: Container(
                    color: Colors.white,
                    child: selectedOption == 'Trang Chủ'
                        ? Padding(
                      padding: const EdgeInsets.all(10.0),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios),
                                onPressed: scrollLeft,
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 130,
                                  child: GestureDetector(
                                    onHorizontalDragUpdate: (details) {
                                      // Cập nhật vị trí cuộn theo hướng di chuột
                                      scrollController.jumpTo(scrollController.offset - details.primaryDelta!);
                                    },
                                    child: ListView(
                                      controller: scrollController,
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      children: [
                                        GridItem(icon: Icons.calendar_today, title: 'Lịch làm việc', subtitle: 'Ca làm việc và thay ca', onTap: () {}),
                                        GridItem(icon: Icons.work, title: 'Công việc', subtitle: 'Danh sách công việc', onTap: () {}),
                                        GridItem(icon: Icons.group, title: 'Nhân sự', subtitle: 'Quản lý nhân viên', onTap: () {}),
                                        GridItem(icon: Icons.assignment, title: 'Báo cáo', subtitle: 'Báo cáo công việc', onTap: () {}),
                                        GridItem(icon: Icons.rule, title: 'Nội quy', subtitle: 'Nội quy công việc', onTap: () {}),
                                        GridItem(icon: Icons.article, title: 'Hướng dẫn', subtitle: 'Sử dụng hệ thống', onTap: () {}),
                                      ].map((item) => Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                        child: SizedBox(width: 150, child: item),
                                      )).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: scrollRight,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const WebScheduleBox(), // Box hiển thị lịch làm việc
                        ],
                      ),
                    )
                        : const Center(
                      child: Text('Chức năng đang phát triển', style: TextStyle(fontSize: 18, color: Colors.grey)),
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

