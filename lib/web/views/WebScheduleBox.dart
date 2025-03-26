import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WebScheduleBox extends StatefulWidget {
  const WebScheduleBox({Key ? key}) : super(key: key);

  @override
  State<WebScheduleBox> createState() => _WebScheduleBoxState();
}

class _WebScheduleBoxState extends State<WebScheduleBox> {
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('work_schedules')
          .where('userId', isEqualTo: _currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final schedules = snapshot.data!.docs;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16.0),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Lịch làm việc của bạn",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        icon: const Icon(Icons.add, size: 20, color: Colors.white),
                        onPressed: _showAddForm,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),



              const SizedBox(height: 10),
              ...schedules.map((schedule) {
                LinearGradient gradient;
                Color textColor;

                if (schedule['shift'] == 'Ca tối') {
                  gradient = const LinearGradient(
                    colors: [Color(0xFFA33757), Color(0xFF852E4E), Color(0xFF4C1D3D)],
                  );
                  textColor = Colors.white;
                } else {
                  gradient = const LinearGradient(
                    colors: [Color(0xFFFFBB94), Color(0xFFFB9590), Color(0xFFDC586D)],
                  );
                  textColor = Colors.black;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule['shift'],
                              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                            ),
                            Text(
                              (schedule['date'] as Timestamp).toDate().toString(),
                              style: TextStyle(color: textColor),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _showEditForm(schedule),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
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
            ],
          ),
        );
      },
    );
  }


}
