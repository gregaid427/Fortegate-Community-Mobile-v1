// lib/screens/FocusGroup/meeting_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:stacked/stacked.dart';
import '../../appcore/helpers/snackbar_helper.dart';
import 'MeetingPage.dart';

class MeetingViewmodel extends BaseViewModel {
  AppProvider? _appProvider;

  void setProvider(AppProvider provider) {
    _appProvider = provider;
  }

  /// Fetch all meetings for user
  Future<void> getallmeetings(BuildContext context) async {
    if (_appProvider == null) return;
    await _appProvider!.fetchMeetings();
    notifyListeners();
  }

  /// Fetch meeting participants
  Future<void> meetingparticipant(BuildContext context, String meetingId) async {
    if (_appProvider == null) return;
    await _appProvider!.fetchMeetingParticipants(meetingId);
    notifyListeners();
  }

  /// Notify participants
  Future<void> notifynow(BuildContext context, List<String> participantIds) async {
    if (_appProvider == null || !context.mounted) return;
    
    await _appProvider!.notifyParticipants(
      context: context,
      participantIds: participantIds,
    );
  }

  /// Set meeting as started and navigate to Jitsi
  Future<void> setMeetingStarted(
    BuildContext context,
    String mid,
    String name,
    String moderator,
  ) async {
    if (_appProvider == null) return;

    try {
      debugPrint('🎬 Starting meeting: $mid');

      final success = await _appProvider!.updateMeetingStatus(
        meetingId: mid,
        status: 'Started',
      );

      if (!context.mounted) return;

      if (success) {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => JitsiWebViewPage(
              room: mid,
              username: name,
            ),
          ),
        );
      } else {
        SnackbarHelper.showError(context, 'Unable to start meeting');
      }
    } catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.showError(context, 'Error starting meeting: $e');
    }
  }
}