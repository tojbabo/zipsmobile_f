import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// WebView 설정 값
InAppWebViewGroupOptions _options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ));

/// WebView 설정 값 가져오는 함수
InAppWebViewGroupOptions getOptions() {
  return _options;
}
