import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _lottoPurchaseUrl = 'https://m.dhlottery.co.kr/';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  late final WebViewController _webViewController;
  var _loadingProgress = 0;
  var _hasLoadError = false;

  bool get _supportsWebView {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();

    if (!_supportsWebView) {
      return;
    }

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(whiteColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) {
              return;
            }

            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (_) {
            if (!mounted) {
              return;
            }

            setState(() {
              _hasLoadError = false;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) {
              return;
            }

            setState(() {
              _hasLoadError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_lottoPurchaseUrl));
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsWebView) {
      return const _PurchaseUnsupportedView();
    }

    return ColoredBox(
      color: whiteColor,
      child: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_loadingProgress < 100)
            LinearProgressIndicator(
              minHeight: 2,
              value: _loadingProgress / 100,
              color: mainColor,
              backgroundColor: const Color(0xffF4F4F4),
            ),
          if (_hasLoadError)
            _PurchaseErrorView(
              onRetry: () {
                setState(() {
                  _hasLoadError = false;
                  _loadingProgress = 0;
                });
                _webViewController.loadRequest(Uri.parse(_lottoPurchaseUrl));
              },
            ),
        ],
      ),
    );
  }
}

class _PurchaseUnsupportedView extends StatelessWidget {
  const _PurchaseUnsupportedView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: whiteColor,
      child: PageContentWidth(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '웹에서는 동행복권 사이트를 앱 안에 표시할 수 없어요.\nAndroid/iOS 앱에서 확인해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: greyColor,
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PurchaseErrorView extends StatelessWidget {
  const _PurchaseErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: whiteColor,
      child: PageContentWidth(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '구매 페이지를 불러오지 못했어요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: whiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '다시 불러오기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
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
}
