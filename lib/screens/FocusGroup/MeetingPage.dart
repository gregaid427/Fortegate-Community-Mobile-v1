import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fortegatecommunity/core/constants.dart';
import 'package:fortegatecommunity/main.dart';
import 'package:fortegatecommunity/screens/FocusGroup/meeting_viewmodel.dart';
import 'package:fortegatecommunity/screens/Points/Points_viewmodel.dart';
import 'package:fortegatecommunity/screens/home/home_view.dart';
import 'package:intl/intl.dart';
import 'package:fortegatecommunity/screens/FocusGroup/ParticipantsPage.dart';
import 'package:permission_handler/permission_handler.dart';

class JitsiWebViewPage extends StatefulWidget {
  final String room;
  final String username;

  const JitsiWebViewPage({Key? key, required this.room, required this.username})
    : super(key: key);

  @override
  _JitsiWebViewPageState createState() => _JitsiWebViewPageState();
}

class _JitsiWebViewPageState extends State<JitsiWebViewPage> {
  late InAppWebViewController _webViewController;
  bool isLoading = true; // 🔥 tracks loading state

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  @override
  Widget build(BuildContext context) {
    final jitsiUrl =
        "https://meet.ffmuc.net/fortegateMeetingID${widget.room}?userInfo.displayName=${widget.username}";

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(jitsiUrl)),

                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                    ),

                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },

                    // 🔥 Detect when page starts loading
                    onLoadStart: (controller, url) {
                      setState(() => isLoading = true);
                    },

                    // 🔥 Detect when page finishes loading
                    onLoadStop: (controller, url) {
                      setState(() => isLoading = false);
                    },

                    androidOnPermissionRequest:
                        (controller, origin, resources) async {
                          return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT,
                          );
                        },
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF107a64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) =>
                              HomeView(pageId: 2), // <-- ScheduleMeeting tab
                        ),
                        (route) => false,
                      );
                    },

                    child: Text(
                      "End/Leave Meeting",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 🔥 Loader Overlay
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
