// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../services/api_service.dart';

// class AppointmentModule extends StatefulWidget {
//   final double width;
//   final Color msuMaroon;
//   final Color colorEmerald;
//   final Color darkSlate;
//   final Color surfaceColor;

//   const AppointmentModule({
//     super.key,
//     required this.width,
//     required this.msuMaroon,
//     required this.colorEmerald,
//     required this.darkSlate,
//     required this.surfaceColor,
//   });

//   @override
//   State<AppointmentModule> createState() => _AppointmentModuleState();
// }

// class _AppointmentModuleState extends State<AppointmentModule> {
//   String _statusFilter = "All";
//   String _searchQuery = "";
//   bool _sortByBookingDate = true; 
//   final TextEditingController _searchController = TextEditingController();

//   // Helper to extract DateTime from the backend's specific format
//   DateTime _parseBackendTimestamp(dynamic timestamp) {
//     if (timestamp == null) return DateTime(2000);
//     try {
//       if (timestamp is Map) {
//         final datePart = timestamp['_DateTime__date'] ?? {};
//         final timePart = timestamp['_DateTime__time'] ?? {};
//         return DateTime.utc(
//           datePart['_Date__year'] ?? 2000,
//           datePart['_Date__month'] ?? 1,
//           datePart['_Date__day'] ?? 1,
//           timePart['_Time__hour'] ?? 0,
//           timePart['_Time__minute'] ?? 0,
//           timePart['_Time__second'] ?? 0,
//         ).toLocal();
//       }
//       String tsString = timestamp.toString();
//       if (tsString.contains(' ') && !tsString.contains('T')) {
//         tsString = tsString.replaceFirst(' ', 'T');
//       }
//       return DateTime.tryParse(tsString)?.toUtc().toLocal() ?? DateTime(2000);
//     } catch (e) {
//       return DateTime(2000);
//     }
//   }

//   Map<String, dynamic> _getTimeInfo(dynamic timestamp) {
//     if (timestamp == null || timestamp.toString() == "null") {
//       return {"text": "No Date", "isNew": false};
//     }

//     DateTime dt = _parseBackendTimestamp(timestamp);
//     if (dt.year == 2000) return {"text": "Invalid", "isNew": false};

//     DateTime now = DateTime.now();
//     Duration diff = now.difference(dt);
    
//     bool isNew = diff.inHours < 1 && !diff.isNegative;

//     String text;
//     if (diff.inSeconds < 60 && !diff.isNegative) {
//       text = "Just now";
//     } else if (diff.inMinutes < 60 && !diff.isNegative) {
//       text = "${diff.inMinutes}m ago";
//     } else if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
//       text = "Today, ${DateFormat('jm').format(dt)}";
//     } else if (dt.day == now.subtract(const Duration(days: 1)).day) {
//       text = "Yesterday";
//     } else {
//       text = DateFormat('MMM d, y').format(dt);
//     }
    
//     return {"text": text, "isNew": isNew};
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           _buildSearchAndFilter(),
//           const SizedBox(height: 20),
//           Expanded(
//             child: FutureBuilder<List<dynamic>>(
//               future: ApiService.getAllAppointments(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
                
//                 if (snapshot.hasError) {
//                   return Center(child: Text("Error loading appointments: ${snapshot.error}"));
//                 }
                
//                 var items = List<dynamic>.from(snapshot.data ?? []);

//                 if (_statusFilter != "All") {
//                   items = items.where((a) => a['status'].toString() == _statusFilter).toList();
//                 }

//                 if (_searchQuery.isNotEmpty) {
//                   items = items.where((a) {
//                     final name = (a['student_name']?.toString() ?? "").toLowerCase();
//                     final ref = (a['ref_code']?.toString() ?? "").toLowerCase();
//                     final query = _searchQuery.toLowerCase();
//                     return name.contains(query) || ref.contains(query);
//                   }).toList();
//                 }

//                 // FIXED ACCURATE SORTING LOGIC
//                 items.sort((a, b) {
//                   if (_sortByBookingDate) {
//                     // Sort by Request Timestamp (Newest first)
//                     DateTime timeA = _parseBackendTimestamp(a['timestamp']);
//                     DateTime timeB = _parseBackendTimestamp(b['timestamp']);
//                     return timeB.compareTo(timeA); 
//                   } else {
//                     // Sort by Meeting Date (Soonest first)
//                     DateTime dateA = DateTime.tryParse(a['date']?.toString() ?? "") ?? DateTime(2000);
//                     DateTime dateB = DateTime.tryParse(b['date']?.toString() ?? "") ?? DateTime(2000);
//                     return dateA.compareTo(dateB); 
//                   }
//                 });

//                 if (items.isEmpty) {
//                   return const Center(child: Text("No appointments found matching your filters."));
//                 }

//                 return ListView.builder(
//                   itemCount: items.length,
//                   itemBuilder: (context, i) => _modernAppointmentCard(items[i]),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchAndFilter() {
//     return Column(
//       children: [
//         TextField(
//           controller: _searchController,
//           onChanged: (val) => setState(() => _searchQuery = val),
//           decoration: InputDecoration(
//             hintText: "Search name or reference...",
//             prefixIcon: const Icon(Icons.search),
//             filled: true,
//             fillColor: widget.surfaceColor,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//             suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
//               _searchController.clear();
//               setState(() => _searchQuery = "");
//             }) : null,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: ["All", "Pending", "Confirmed", "Rejected"].map((f) {
//                     bool sel = _statusFilter == f;
//                     return Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: FilterChip(
//                         label: Text(f, style: TextStyle(color: sel ? Colors.white : widget.darkSlate, fontSize: 12)),
//                         selected: sel,
//                         onSelected: (v) => setState(() => _statusFilter = f),
//                         backgroundColor: widget.surfaceColor,
//                         selectedColor: widget.msuMaroon,
//                         checkmarkColor: Colors.white,
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 setState(() => _sortByBookingDate = !_sortByBookingDate);
//               },
//               icon: Icon(_sortByBookingDate ? Icons.history : Icons.calendar_month, color: widget.msuMaroon),
//               tooltip: _sortByBookingDate ? "Sorted by: Recent Booking" : "Sorted by: Meeting Date",
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _modernAppointmentCard(dynamic ap) {
//     String status = ap['status']?.toString() ?? 'Pending';
//     Color sColor = status == 'Confirmed' 
//         ? widget.colorEmerald 
//         : (status == 'Pending' ? Colors.orange : Colors.red);

//     // In appointment_module.dart -> _modernAppointmentCard
//     String userType = (ap['user_type'] ?? ap['type'] ?? 'Student').toString();
//     var timeInfo = _getTimeInfo(ap['timestamp']);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: widget.surfaceColor, 
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: CircleAvatar(
//           backgroundColor: sColor.withOpacity(0.1), 
//           child: Text(
//             ap['student_name']?.toString()[0].toUpperCase() ?? 'S', 
//             style: TextStyle(color: sColor, fontWeight: FontWeight.bold)
//           )
//         ),
//         title: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         ap['student_name']?.toString() ?? 'Student', 
//                         style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
//                         child: Text(userType, style: TextStyle(fontSize: 10, color: widget.darkSlate.withOpacity(0.7))),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 2),
//                   Row(
//                     children: [
//                       if (timeInfo['isNew'])
//                         Container(
//                           margin: const EdgeInsets.only(right: 6),
//                           padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
//                           decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(3)),
//                           child: const Text("NEW", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
//                         ),
//                       Text("Requested: ${timeInfo['text']}", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(color: sColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
//               child: Text(
//                 status.toUpperCase(), 
//                 style: TextStyle(color: sColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)
//               ),
//             ),
//           ],
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Divider(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween, // Added this
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.calendar_month, size: 14, color: widget.msuMaroon),
//                       const SizedBox(width: 6),
//                       Text(
//                         "Meeting: ${ap['date']} • ${ap['time']}", 
//                         style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))
//                       ),
//                     ],
//                   ),
//                   // NEW: Reference Code Badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(4),
//                       border: Border.all(color: Colors.grey[300]!),
//                     ),
//                     child: Text(
//                       "#${ap['ref_code'] ?? 'N/A'}",
//                       style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         trailing: Icon(Icons.chevron_right, color: widget.darkSlate.withOpacity(0.3)),
//         onTap: () => _showStudentCredentials(ap),
//       ),
//     );
//   }

//   void _showStudentCredentials(dynamic ap) {
//     final nc = TextEditingController(text: ap['notes']?.toString() ?? "");
//     final String currentStatus = ap['status']?.toString() ?? 'Pending';
//     var timeInfo = _getTimeInfo(ap['timestamp']);

//     showDialog(
//       context: context,
//       builder: (c) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text(ap['student_name']?.toString() ?? 'Details', style: const TextStyle(fontWeight: FontWeight.bold)),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _infoRow(Icons.access_time_filled, "Requested", timeInfo['text']), 
//               _infoRow(Icons.person, "User Type", ap['user_type']?.toString() ?? ap['type']?.toString()),
//               _infoRow(Icons.email, "Email", ap['email']?.toString()),
//               _infoRow(Icons.phone, "Contact", ap['contact']?.toString()),
//               _infoRow(Icons.calendar_month, "Appt. Date", "${ap['date']} | ${ap['time']}"),
//               _infoRow(Icons.qr_code, "Ref Code", ap['ref_code']?.toString()?.toUpperCase() ?? "N/A"),
//               const Divider(height: 20),
//               const Text("REASON", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
//               Text(ap['reason']?.toString() ?? "No reason provided.", style: const TextStyle(fontStyle: FontStyle.italic)),
//               const SizedBox(height: 20),
//               const Text("SESSION NOTES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: nc,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           // 1. Close Button (Left side)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Row(
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(c),
//                   child: Text("Close", style: TextStyle(color: Colors.grey[600])),
//                 ),
//                 const Spacer(),
                
//                 // 2. Update Notes (Secondary Action)
//                 if (currentStatus != 'Rejected')
//                   TextButton(
//                     onPressed: () => _handleDecision(ap['id'].toString(), currentStatus, nc.text),
//                     child: const Text("Update Notes"),
//                   ),
//               ],
//             ),
//           ),
          
//           const Divider(), // Optional visual separator
          
//           // 3. Main Action Buttons (Bottom row)
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 if (currentStatus == 'Pending' || currentStatus == 'Confirmed')
//                   OutlinedButton(
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: Colors.red),
//                       foregroundColor: Colors.red,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                     onPressed: () => _handleCancelFlow(ap['id'].toString(), nc.text),
//                     child: const Text("Cancel"),
//                   ),
//                 const SizedBox(width: 12),
//                 if (currentStatus == 'Pending')
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: widget.colorEmerald,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                     onPressed: () => _handleDecision(ap['id'].toString(), "Confirmed", nc.text),
//                     child: const Text("Confirm Appointment", style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _infoRow(IconData icon, String label, String? value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: widget.msuMaroon),
//           const SizedBox(width: 8),
//           Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
//           Expanded(child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 13))),
//         ],
//       ),
//     );
//   }

//   void _handleCancelFlow(String id, String notes) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Cancel Appointment?"),
//         content: const Text("This will reject the appointment and free the timeslot."),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
//           TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes, Cancel")),
//         ],
//       ),
//     );
//     if (confirm == true) _handleDecision(id, "Rejected", notes);
//   }

//   void _handleDecision(String id, String status, String notes) async {
//     try {
//       await ApiService.updateAppointmentStatus(id, status, notes: notes);
//       if (mounted) {
//         Navigator.pop(context);
//         setState(() {});
//       }
//     } catch (e) {
//       debugPrint("Error: $e");
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Added for json.decode
import 'package:flutter/services.dart'; // Added for rootBundle
import '../../../services/api_service.dart';

class AppointmentModule extends StatefulWidget {
  final double width;
  final Color msuMaroon;
  final Color colorEmerald;
  final Color darkSlate;
  final Color surfaceColor;

  const AppointmentModule({
    super.key,
    required this.width,
    required this.msuMaroon,
    required this.colorEmerald,
    required this.darkSlate,
    required this.surfaceColor,
  });

  @override
  State<AppointmentModule> createState() => _AppointmentModuleState();
}

class _AppointmentModuleState extends State<AppointmentModule> {
  String _statusFilter = "All";
  String _searchQuery = "";
  bool _sortByBookingDate = true; 
  final TextEditingController _searchController = TextEditingController();

  // --- NEW: LINKED ASSESSMENT VIEW LOGIC ---
  void _viewLinkedAssessment(dynamic ap) async {
    final String response = await rootBundle.loadString('assets/questions.json');
    final data = json.decode(response);
    final List<dynamic> sections = data['sections'];

    List<dynamic> rawAnswers;
    try {
      rawAnswers = ap['assessment_answers'] is String 
          ? json.decode(ap['assessment_answers']) 
          : ap['assessment_answers'];
    } catch (e) {
      rawAnswers = [];
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Related Assessment", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Score: ${ap['assessment_score']} | Level: ${ap['assessment_level']}", 
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: ListView.builder(
            itemCount: sections.length,
            itemBuilder: (context, sIndex) {
              final section = sections[sIndex];
              final sectionAnswers = rawAnswers[sIndex] as List<dynamic>;

              return ExpansionTile(
                title: Text(section['title'], 
                    style: TextStyle(color: widget.msuMaroon, fontWeight: FontWeight.bold, fontSize: 14)),
                children: List.generate(section['questions'].length, (qIndex) {
                  final questionText = section['questions'][qIndex];
                  final answerValue = sectionAnswers[qIndex];
                  final option = (section['options'] as List).firstWhere(
                    (opt) => opt['value'] == answerValue,
                    orElse: () => {'text': 'Unknown'},
                  );

                  return ListTile(
                    title: Text(questionText, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(option['text'], 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  );
                }),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  // Helper to extract DateTime from the backend's specific format
  DateTime _parseBackendTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime(2000);
    try {
      if (timestamp is Map) {
        final datePart = timestamp['_DateTime__date'] ?? {};
        final timePart = timestamp['_DateTime__time'] ?? {};
        return DateTime.utc(
          datePart['_Date__year'] ?? 2000,
          datePart['_Date__month'] ?? 1,
          datePart['_Date__day'] ?? 1,
          timePart['_Time__hour'] ?? 0,
          timePart['_Time__minute'] ?? 0,
          timePart['_Time__second'] ?? 0,
        ).toLocal();
      }
      String tsString = timestamp.toString();
      if (tsString.contains(' ') && !tsString.contains('T')) {
        tsString = tsString.replaceFirst(' ', 'T');
      }
      return DateTime.tryParse(tsString)?.toUtc().toLocal() ?? DateTime(2000);
    } catch (e) {
      return DateTime(2000);
    }
  }

  Map<String, dynamic> _getTimeInfo(dynamic timestamp) {
    if (timestamp == null || timestamp.toString() == "null") {
      return {"text": "No Date", "isNew": false};
    }

    DateTime dt = _parseBackendTimestamp(timestamp);
    if (dt.year == 2000) return {"text": "Invalid", "isNew": false};

    DateTime now = DateTime.now();
    Duration diff = now.difference(dt);
    
    bool isNew = diff.inHours < 1 && !diff.isNegative;

    String text;
    if (diff.inSeconds < 60 && !diff.isNegative) {
      text = "Just now";
    } else if (diff.inMinutes < 60 && !diff.isNegative) {
      text = "${diff.inMinutes}m ago";
    } else if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      text = "Today, ${DateFormat('jm').format(dt)}";
    } else if (dt.day == now.subtract(const Duration(days: 1)).day) {
      text = "Yesterday";
    } else {
      text = DateFormat('MMM d, y').format(dt);
    }
    
    return {"text": text, "isNew": isNew};
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSearchAndFilter(),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: ApiService.getAllAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading appointments: ${snapshot.error}"));
                }
                
                var items = List<dynamic>.from(snapshot.data ?? []);

                if (_statusFilter != "All") {
                  items = items.where((a) => a['status'].toString() == _statusFilter).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  items = items.where((a) {
                    final name = (a['student_name']?.toString() ?? "").toLowerCase();
                    final ref = (a['ref_code']?.toString() ?? "").toLowerCase();
                    final query = _searchQuery.toLowerCase();
                    return name.contains(query) || ref.contains(query);
                  }).toList();
                }

                // FIXED ACCURATE SORTING LOGIC
                items.sort((a, b) {
                  if (_sortByBookingDate) {
                    // Sort by Request Timestamp (Newest first)
                    DateTime timeA = _parseBackendTimestamp(a['timestamp']);
                    DateTime timeB = _parseBackendTimestamp(b['timestamp']);
                    return timeB.compareTo(timeA); 
                  } else {
                    // Sort by Meeting Date (Soonest first)
                    DateTime dateA = DateTime.tryParse(a['date']?.toString() ?? "") ?? DateTime(2000);
                    DateTime dateB = DateTime.tryParse(b['date']?.toString() ?? "") ?? DateTime(2000);
                    return dateA.compareTo(dateB); 
                  }
                });

                if (items.isEmpty) {
                  return const Center(child: Text("No appointments found matching your filters."));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) => _modernAppointmentCard(items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: "Search name or reference...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: widget.surfaceColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = "");
            }) : null,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["All", "Pending", "Confirmed", "Rejected"].map((f) {
                    bool sel = _statusFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(f, style: TextStyle(color: sel ? Colors.white : widget.darkSlate, fontSize: 12)),
                        selected: sel,
                        onSelected: (v) => setState(() => _statusFilter = f),
                        backgroundColor: widget.surfaceColor,
                        selectedColor: widget.msuMaroon,
                        checkmarkColor: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() => _sortByBookingDate = !_sortByBookingDate);
              },
              icon: Icon(_sortByBookingDate ? Icons.history : Icons.calendar_month, color: widget.msuMaroon),
              tooltip: _sortByBookingDate ? "Sorted by: Recent Booking" : "Sorted by: Meeting Date",
            ),
          ],
        ),
      ],
    );
  }

  Widget _modernAppointmentCard(dynamic ap) {
    String status = ap['status']?.toString() ?? 'Pending';
    Color sColor = status == 'Confirmed' 
        ? widget.colorEmerald 
        : (status == 'Pending' ? Colors.orange : Colors.red);

    String userType = (ap['user_type'] ?? ap['type'] ?? 'Student').toString();
    var timeInfo = _getTimeInfo(ap['timestamp']);
    bool hasAssessment = ap['assessment_id'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.surfaceColor, 
        borderRadius: BorderRadius.circular(16),
        border: hasAssessment ? Border.all(color: Colors.orange.withOpacity(0.3), width: 1) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: sColor.withOpacity(0.1), 
          child: Text(
            ap['student_name']?.toString()[0].toUpperCase() ?? 'S', 
            style: TextStyle(color: sColor, fontWeight: FontWeight.bold)
          )
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ap['student_name']?.toString() ?? 'Student', 
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                        child: Text(userType, style: TextStyle(fontSize: 10, color: widget.darkSlate.withOpacity(0.7))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (timeInfo['isNew'])
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(3)),
                          child: const Text("NEW", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      Text("Requested: ${timeInfo['text']}", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            if (hasAssessment) Icon(Icons.analytics, size: 16, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: sColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(
                status.toUpperCase(), 
                style: TextStyle(color: sColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, size: 14, color: widget.msuMaroon),
                      const SizedBox(width: 6),
                      Text(
                        "Meeting: ${ap['date']} • ${ap['time']}", 
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      "#${ap['ref_code'] ?? 'N/A'}",
                      style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: widget.darkSlate.withOpacity(0.3)),
        onTap: () => _showStudentCredentials(ap),
      ),
    );
  }

  void _showStudentCredentials(dynamic ap) {
    final nc = TextEditingController(text: ap['notes']?.toString() ?? "");
    final String currentStatus = ap['status']?.toString() ?? 'Pending';
    var timeInfo = _getTimeInfo(ap['timestamp']);
    bool hasAssessment = ap['assessment_id'] != null;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(ap['student_name']?.toString() ?? 'Details', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAssessment) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    foregroundColor: Colors.orange[900],
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 45),
                    side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                  ),
                  onPressed: () => _viewLinkedAssessment(ap),
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: Text("View Related Result (${ap['assessment_level']})"),
                ),
                const SizedBox(height: 15),
              ],
              _infoRow(Icons.access_time_filled, "Requested", timeInfo['text']), 
              _infoRow(Icons.person, "User Type", ap['user_type']?.toString() ?? ap['type']?.toString()),
              _infoRow(Icons.email, "Email", ap['email']?.toString()),
              _infoRow(Icons.phone, "Contact", ap['contact']?.toString()),
              _infoRow(Icons.calendar_month, "Appt. Date", "${ap['date']} | ${ap['time']}"),
              _infoRow(Icons.qr_code, "Ref Code", ap['ref_code']?.toString().toUpperCase() ?? "N/A"),
              const Divider(height: 20),
              const Text("REASON", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
              Text(ap['reason']?.toString() ?? "No reason provided.", style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 20),
              const Text("SESSION NOTES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: nc,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: Text("Close", style: TextStyle(color: Colors.grey[600])),
                ),
                const Spacer(),
                if (currentStatus != 'Rejected')
                  TextButton(
                    onPressed: () => _handleDecision(ap['id'].toString(), currentStatus, nc.text),
                    child: const Text("Update Notes"),
                  ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (currentStatus == 'Pending' || currentStatus == 'Confirmed')
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _handleCancelFlow(ap['id'].toString(), nc.text),
                    child: const Text("Cancel"),
                  ),
                const SizedBox(width: 12),
                if (currentStatus == 'Pending')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.colorEmerald,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _handleDecision(ap['id'].toString(), "Confirmed", nc.text),
                    child: const Text("Confirm Appointment", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: widget.msuMaroon),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _handleCancelFlow(String id, String notes) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Appointment?"),
        content: const Text("This will reject the appointment and free the timeslot."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes, Cancel")),
        ],
      ),
    );
    if (confirm == true) _handleDecision(id, "Rejected", notes);
  }

  void _handleDecision(String id, String status, String notes) async {
    try {
      await ApiService.updateAppointmentStatus(id, status, notes: notes);
      if (mounted) {
        Navigator.pop(context);
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}