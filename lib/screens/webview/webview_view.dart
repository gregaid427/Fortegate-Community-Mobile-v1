// lib/screens/webview/webview_view.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fortegatecommunity/appcore/providers.dart/app_provider.dart';
import 'package:fortegatecommunity/appcore/utils/constants.dart';
import 'package:fortegatecommunity/screens/webview/webView_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';

class WebView extends StatefulWidget {
  final dynamic token;
  final dynamic surveyid;

  const WebView({
    Key? key,
    required this.surveyid,
    required this.token,
  }) : super(key: key);

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  InAppWebViewController? controller;

  @override
  Widget build(BuildContext context) {
   final String baseUrl = dotenv.env['LS_BASE_URL'] ?? '';

  final String url = '${baseUrl}survey/index&sid=${widget.surveyid}&token=${widget.token}&newtest=Y';  
  print(url);
  return ViewModelBuilder<WebViewModel>.reactive(
      viewModelBuilder: () => WebViewModel(),
      onViewModelReady: (model) {
        final appProvider = context.read<AppProvider>();
        model.setProvider(appProvider);
        
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 1,
            title: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_outlined, color: AppGreen),
                  onPressed: () => model.navigateBack(context),
                ),
                InkWell(
                  onTap: () => model.navigateBack(context),
                  child: Text(
                    context.tr('Back_to_Surveys'),
                    style: TextStyle(fontSize: 14.sp, color: AppGreen),
                  ),
                ),
              ],
            ),
          ),
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              useHybridComposition: true,
            ),
            onWebViewCreated: (ctrl) {
              controller = ctrl;
            },
            androidOnPermissionRequest: (controller, origin, resources) async {
              return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT,
              );
            },
            onLoadStart: (ctrl, uri) {
              debugPrint('📄 WebView loading: $uri');
            },
            onLoadStop: (ctrl, uri) async {
              debugPrint('✅ WebView loaded: $uri');
              // Refresh surveys and points after survey completion
              await model.refreshData();
            },
            onReceivedError: (ctrl, req, error) {
              debugPrint('❌ WebView error: ${error.description}');
            },
          ),
        );
      },
    );
  }
}