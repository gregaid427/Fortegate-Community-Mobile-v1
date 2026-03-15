// lib/screens/FocusGroup/ParticipantsPage.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'meeting_viewmodel.dart';

class ParticipantsPage extends StatefulWidget {
  final String meetingTitle;
  final String meetingTime;
  final String meetingInfo;
  final dynamic mid;
  final dynamic moderator;

  const ParticipantsPage({
    super.key,
    required this.meetingTitle,
    required this.meetingInfo,
    required this.meetingTime,
    required this.mid,
    required this.moderator,
  });

  @override
  State<ParticipantsPage> createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MeetingViewmodel>.reactive(
      viewModelBuilder: () => MeetingViewmodel(),
      onViewModelReady: (model) {
        final appProvider = context.read<AppProvider>();
        model.setProvider(appProvider);
        model.getallmeetings(context);
        model.meetingparticipant(context, widget.mid);
      },
      builder: (context, model, child) {
        return Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            final participants = appProvider.meetingParticipants ?? [];

            return Scaffold(
              appBar: AppBar(
                leading: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.chevron_left, size: 30.sp),
                ),
                centerTitle: true,
                title: const Text(
                  "Participants",
                  style: TextStyle(fontSize: 18),
                ),
                automaticallyImplyLeading: false,
                foregroundColor: AppGreen,
              ),
              body: Column(
                children: [
                  // Meeting Info Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15.sp),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        children: [
                          // Top Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                              color: AppGreen,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.r),
                                topRight: Radius.circular(10.r),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Title",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  widget.meetingTitle,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 1.sp),
                                Text(
                                  "Info",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  widget.meetingInfo,
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "Link",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  "https://meet.ffmuc.net/${widget.mid}",
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom Section
                          Container(
                            width: double.infinity,
                            height: 40.h,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 209, 208, 208),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "🕓 ${widget.meetingTime} GMT",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      participants.length.toString(),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade900,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Colors.black87,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Participants List
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: RefreshIndicator(
                        onRefresh: () => model.meetingparticipant(
                          context,
                          widget.mid,
                        ),
                        child: participants.isEmpty || participants.length <= 1
                            ? ListView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 50),
                                  Center(
                                    child: Text(
                                      "No Other Participants Added Yet!",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                itemCount: participants.length,
                                itemBuilder: (_, index) {
                                  final p = participants[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                          color: Colors.black.withOpacity(0.08),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor:
                                              Colors.green.shade400,
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p["name"] ?? "",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.phone,
                                                    size: 16,
                                                    color:
                                                        Colors.green.shade700,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    p["phone"] ?? "",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (p["participantId"] ==
                                            appProvider.userId)
                                          const Icon(
                                            Icons.check_circle,
                                            color: AppGreen,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Notify FAB
                  FloatingActionButton(
                    heroTag: "fab_notify",
                    onPressed: () => _showNotifyModal(context, participants),
                    backgroundColor: Colors.green.shade800,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Proceed FAB
                  FloatingActionButton.extended(
                    heroTag: "fab_proceed",
                    onPressed: () => model.setMeetingStarted(
                      context,
                      widget.mid,
                      appProvider.name ?? '',
                      widget.moderator,
                    ),
                    label: const Text("Proceed"),
                    icon: const Icon(Icons.chevron_right_outlined),
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNotifyModal(
    BuildContext context,
    List<dynamic> participants,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Are you sure you want to notify all participants that the meeting is starting now?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          side: const BorderSide(color: AppGreen),
                        ),
                        child: const Text(
                          "Decline",
                          style: TextStyle(color: AppGreen),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);

                          final appProvider = context.read<AppProvider>();
                          final participantIds = participants
                              .map((item) =>
                                  item["participantId"].toString())
                              .toList();

                          await appProvider.notifyParticipants(
                            context: context,
                            participantIds: participantIds,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: const Text("Notify"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}