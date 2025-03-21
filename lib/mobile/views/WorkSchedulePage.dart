import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkSchedulePage extends StatefulWidget {
  const WorkSchedulePage({Key? key}) : super(key: key);

  @override
  State<WorkSchedulePage> createState() => _WorkSchedulePageState();
}

class _WorkSchedulePageState extends State<WorkSchedulePage> {
  String? _selectedShift;
  DateTime? _selectedDate;
  String? _reason;
  String? _editReason;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Đăng kí ca làm"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedShift,
                items: const [
                  DropdownMenuItem(value: "Ca sáng", child: Text("Ca sáng")),
                  DropdownMenuItem(value: "Ca tối", child: Text("Ca tối")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedShift = value;
                  });
                },
                decoration: const InputDecoration(labelText: "Chọn ca"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickDate(context),
                child: const Text("Chọn ngày"),
              ),
              if (_selectedDate != null)
                Text("Ngày đã chọn: ${_selectedDate!.toLocal()}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedShift != null && _selectedDate != null && _currentUser != null) {
                  await FirebaseFirestore.instance.collection('work_schedules').add({
                    'userId': _currentUser!.uid,
                    'shift': _selectedShift,
                    'date': _selectedDate,
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Hoàn thành"),
            ),
          ],
        );
      },
    );
  }

  void _showEditForm(DocumentSnapshot schedule) {
    _selectedShift = schedule['shift'];
    _selectedDate = (schedule['date'] as Timestamp).toDate();

    // Ép kiểu schedule.data() thành Map<String, dynamic> để có thể sử dụng containsKey
    final data = schedule.data() as Map<String, dynamic>?;

    // Kiểm tra sự tồn tại của trường 'reason'
    _editReason = data != null && data.containsKey('reason') ? data['reason'] : '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Chỉnh sửa ca làm"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedShift,
                items: const [
                  DropdownMenuItem(value: "Ca sáng", child: Text("Ca sáng")),
                  DropdownMenuItem(value: "Ca tối", child: Text("Ca tối")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedShift = value;
                  });
                },
                decoration: const InputDecoration(labelText: "Chọn ca"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickDate(context),
                child: const Text("Chọn ngày"),
              ),
              if (_selectedDate != null)
                Text("Ngày đã chọn: ${_selectedDate!.toLocal()}"),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  _editReason = value;
                },
                decoration: const InputDecoration(
                  labelText: "Lí do thay đổi",
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _editReason),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedShift != null && _selectedDate != null) {
                  await FirebaseFirestore.instance.collection('work_schedules').doc(schedule.id).update({
                    'shift': _selectedShift,
                    'date': _selectedDate,
                    'reason': _editReason,
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Cập nhật"),
            ),
          ],
        );
      },
    );
  }


  void _showLeaveForm(DocumentSnapshot schedule) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Đăng kí nghỉ"),
          content: TextField(
            onChanged: (value) {
              _reason = value;
            },
            decoration: const InputDecoration(
              labelText: "Lí do xin nghỉ",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_reason != null) {
                  // Cập nhật lý do nghỉ trước khi xóa lịch làm
                  await FirebaseFirestore.instance.collection('work_schedules').doc(schedule.id).update({
                    'reason': _reason,
                  });

                  // Xóa lịch làm sau khi nhập lý do
                  await FirebaseFirestore.instance.collection('work_schedules').doc(schedule.id).delete();
                }
                Navigator.pop(context);
              },
              child: const Text("Hoàn thành"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch Làm"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('work_schedules').where('userId', isEqualTo: _currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final schedules = snapshot.data!.docs;
          return Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: schedules.map((schedule) {
                // Kiểm tra ca và chọn gradient tương ứng
                LinearGradient gradient;
                Color textColor;

                if (schedule['shift'] == 'Ca tối') {
                  gradient = LinearGradient(
                    colors: [Color(0xFFA33757), Color(0xFF852E4E), Color(0xFF4C1D3D)],
                  );
                  textColor = Colors.white;
                } else {
                  gradient = LinearGradient(
                    colors: [Color(0xFFFFBB94), Color(0xFFFB9590), Color(0xFFDC586D)],
                  );
                  textColor = Colors.black;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    gradient: gradient, // Áp dụng gradient nền
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule['shift'],
                              style: TextStyle(fontWeight: FontWeight.bold, color: textColor), // Màu chữ tùy thuộc vào ca
                            ),
                            Text(
                              (schedule['date'] as Timestamp).toDate().toString(),
                              style: TextStyle(color: textColor), // Màu chữ tùy thuộc vào ca
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          // Icon edit với background
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5), // Màu đen với opacity
                              borderRadius: BorderRadius.circular(8), // Bo góc
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _showEditForm(schedule),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Icon close với background
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5), // Màu đen với opacity
                              borderRadius: BorderRadius.circular(8), // Bo góc
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => _showLeaveForm(schedule),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
