// lib/screens/FocusGroup/ScheduleMeeting.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/helpers/snackbar_helper.dart';
import 'ParticipantsPage.dart';
import '../home/home_view.dart';
import 'meeting_viewmodel.dart';

class ScheduledMeetingsPage extends StatefulWidget {
  const ScheduledMeetingsPage({super.key});

  @override
  State<ScheduledMeetingsPage> createState() => _ScheduledMeetingsPageState();
}

class _ScheduledMeetingsPageState extends State<ScheduledMeetingsPage> {
  final _titleController = TextEditingController();
  final _infoController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MeetingViewmodel>.reactive(
      viewModelBuilder: () => MeetingViewmodel(),
      onViewModelReady: (model) {
        final appProvider = context.read<AppProvider>();
        model.setProvider(appProvider);
        model.getallmeetings(context);
      },
      builder: (context, model, child) {
        return Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            return Scaffold(
              body: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Center(
                            child: Text(
                              'focus'.tr(),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppGreen,
                              ),
                            ),
                          ),
                          SizedBox(height: 30.sp),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.sp,
                        vertical: 20.sp,
                      ),
                      child: RefreshIndicator(
                        onRefresh: () => model.getallmeetings(context),
                        child: appProvider!.allMeetings.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(height: 100.h),
                                  Center(
                                    child: Text(
                                      'No meetings scheduled yet',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 5.sp),
                                itemCount: appProvider.allMeetings.length,
                                itemBuilder: (context, index) {
                                  final meeting = appProvider.allMeetings[index];
                                  return _buildMeetingCard(
                                    context,
                                    meeting,
                                    index,
                                    appProvider.userId,
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: _showScheduleMeetingModal,
                label: const Text("Schedule Meeting"),
                icon: const Icon(Icons.add),
                backgroundColor: Colors.green.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            );
          },
        );
      },
    );
  }

Widget _buildMeetingCard(
  BuildContext context,
  Map<String, dynamic> meeting,
  int index,
  String? userId,
) {
  final status = meeting["status"] ?? "";
  final isLive = status == "Started";

  return GestureDetector(
    onTap: () => _showMeetingPreview(meeting, index, userId),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar for live meetings
              if (isLive)
                Container(width: 3, color: AppGreen),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: status == "Completed"
                                  ? Colors.grey.shade100
                                  : const Color(0xFFEAF3DE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              size: 20,
                              color: status == "Completed"
                                  ? Colors.grey
                                  : AppGreen,
                            ),
                          ),
                          if (isLive)
                            Positioned(
                              top: -3,
                              right: -3,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00C803),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meeting["title"] ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: status == "Completed"
                                    ? Colors.grey.shade500
                                    : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _buildStatusPill(status),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.access_time_rounded,
                                        size: 12,
                                        color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      meeting["scheduledPeriod"] != null
                                          ? "${DateFormat('dd MMM yyyy · HH:mm').format(DateTime.parse(meeting["scheduledPeriod"]))} GMT"
                                          : "-",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right_rounded,
                          size: 20, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
Widget _buildStatusPill(String status) {
  Color bg;
  Color fg;
  String label;
  Widget? dot;

  switch (status) {
    case "Pending Approval":
      bg = const Color(0xFFC0DD97);
      fg = const Color(0xFF27500A);
      label = "Pending approval";
      break;
    case "Awaiting Moderator":
      bg = const Color(0xFF085041);
      fg = const Color(0xFF9FE1CB);
      label = "Awaiting moderator";
      break;
    case "Started":
      bg = const Color(0x2000C803);
      fg = const Color(0xFF177319);
      label = "Meeting Initiated";
      dot = Container(
        width: 6, height: 6,
        margin: const EdgeInsets.only(right: 4),
        decoration: const BoxDecoration(
          color: Color(0xFF00C803), shape: BoxShape.circle),
      );
      break;
    default:
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade600;
      label = status.isEmpty ? "Completed" : status;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
    decoration: BoxDecoration(
      color: bg, borderRadius: BorderRadius.circular(20)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot != null) dot,
        Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
      ],
    ),
  );
}
  void _showMeetingPreview(
    Map<String, dynamic> meeting,
    int index,
    String? userId,
  ) {
    showGeneralDialog(
      barrierLabel: "Meeting Preview",
      barrierDismissible: true,
      context: context,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = Curves.easeOut.transform(animation.value);
        return Transform.translate(
          offset: Offset(0, (1 - curved) * 300),
          child: Opacity(
            opacity: animation.value,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 60,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Title",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            meeting["title"] ?? "-",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "Info",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            meeting["info"] ?? "-",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "Status",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0, bottom: 6),
                          child: _buildStatusChip(meeting["status"] ?? "-"),
                        ),
                        Text(
                          "🕓 ${meeting["scheduledPeriod"] != null ? DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(meeting["scheduledPeriod"])) : "-"} GMT",
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 18),
                        _buildButtons(meeting, index, userId),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg = Colors.white;

    switch (status) {
      case "Pending Approval":
        bg = const Color.fromARGB(255, 27, 6, 77);
        break;
      case "Awaiting Moderator":
        bg = Colors.green.shade700;
        break;
      case "Active":
        bg = Colors.blue.shade700;
        break;
      default:
        bg = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(status, style: TextStyle(color: fg, fontSize: 12)),
    );
  }

  Widget _buildButtons(
    Map<String, dynamic> meeting,
    int index,
    String? userId,
  ) {
    final canStart = meeting["status"] == "Awaiting Moderator" &&
        meeting["moderator"] == userId;
    final canDelete = meeting["status"] == "Pending Approval" &&
        meeting["moderator"] == userId;
    final canJoinAudience =
        meeting["status"] == "Started" && meeting["moderator"] != userId;
    final canJoinModerator =
        meeting["status"] == "Started" && meeting["moderator"] == userId;

    final elevatedStyle = ElevatedButton.styleFrom(
      backgroundColor: AppGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    );

    final outlinedStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      side: const BorderSide(color: AppGreen, width: 2),
      foregroundColor: AppGreen,
    );

    if (canStart) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    final homeState = HomeView.of(context);
                    homeState?.meetingsNavKey.currentState?.pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => ParticipantsPage(
                          meetingTitle: meeting["title"],
                          meetingTime: meeting["scheduledPeriod"],
                          meetingInfo: meeting["info"],
                          mid: meeting["mid"],
                          moderator: meeting["moderator"],
                        ),
                      ),
                    );
                  },
                  style: elevatedStyle,
                  child: const Text("Start Meeting"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    _confirmAndDelete(meeting["mid"]);
                  },
                  style: outlinedStyle,
                  child: const Text("Delete"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              style: outlinedStyle,
              child: const Text("Close"),
            ),
          ),
        ],
      );
    }

    if (canDelete) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                _confirmAndDelete(meeting["mid"]);
              },
              style: outlinedStyle,
              child: const Text("Delete"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              style: outlinedStyle,
              child: const Text("Close"),
            ),
          ),
        ],
      );
    }

    if (canJoinModerator) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                final homeState = HomeView.of(context);
                homeState?.meetingsNavKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (_) => ParticipantsPage(
                      meetingTitle: meeting["title"],
                      meetingTime: meeting["scheduledPeriod"],
                      meetingInfo: meeting["info"],
                      mid: meeting["mid"],
                      moderator: meeting["moderator"],
                    ),
                  ),
                );
              },
              style: elevatedStyle,
              child: const Text("Join Meeting"),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    _confirmAndDelete(meeting["mid"]);
                  },
                  style: outlinedStyle,
                  child: const Text("Delete"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  style: outlinedStyle,
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (canJoinAudience) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                final homeState = HomeView.of(context);
                homeState?.meetingsNavKey.currentState?.pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ParticipantsPage(
                      meetingTitle: meeting["title"],
                      meetingTime: meeting["scheduledPeriod"],
                      meetingInfo: meeting["info"],
                      mid: meeting["mid"],
                      moderator: meeting["moderator"],
                    ),
                  ),
                );
              },
              style: elevatedStyle,
              child: const Text("Join Meeting"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              style: outlinedStyle,
              child: const Text("Close"),
            ),
          ),
        ],
      );
    }

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          style: outlinedStyle,
          child: const Text("Close"),
        ),
      ),
    );
  }

Future<void> _confirmAndDelete(String mid) async {
  final appProvider = context.read<AppProvider>();
  
  await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Confirm delete"),
        content: const Text("Are you sure you want to delete this meeting?"),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await appProvider.deleteMeeting(
                context: context,
                meetingId: mid,
              );
              Navigator.of(context, rootNavigator: true).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );

  // ❌ Remove the block below — it was popping the page after deletion
  // if (confirmed == true && mounted) {
  //   Navigator.of(context).pop();
  // }
}
  void _showScheduleMeetingModal() {
    _titleController.clear();
    _infoController.clear();
    _selectedDate = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                "Schedule Meeting",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Meeting Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _infoController,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: "Meeting Info",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? "Set Date & Time"
                          : DateFormat('dd/MM/yy HH:mm').format(_selectedDate!),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedTime != null) {
                          setState(() {
                            _selectedDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text("Select"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_titleController.text.isNotEmpty &&
                            _selectedDate != null) {
                          final appProvider = context.read<AppProvider>();

                          final data = {
                            "title": _titleController.text,
                            "info": _infoController.text,
                            "scheduledPeriod": _selectedDate.toString(),
                            "moderator": appProvider.userId,
                            "name": appProvider.name,
                          };

                          await appProvider.createMeeting(
                            context: context,
                            data: data,
                          );

                          Navigator.of(context, rootNavigator: true).pop();
                        } else {
                          SnackbarHelper.showError(
                            context,
                            "Fill fields to schedule meeting!",
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: const Text("Submit"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        side: const BorderSide(color: AppGreen, width: 2),
                        foregroundColor: AppGreen,
                      ),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}