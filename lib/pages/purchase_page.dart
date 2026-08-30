import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luckez/theme/app_colors.dart';
import 'package:luckez/theme/app_layout.dart';
import 'package:luckez/widgets/app_button.dart';
import 'package:luckez/widgets/app_card.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const _lottoPurchaseUrl = 'https://m.dhlottery.co.kr/';
const _lottoHomeUrl = 'https://www.dhlottery.co.kr/';

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
    return ColoredBox(
      color: backgroundColor,
      child: PageContentWidth(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _PurchaseStateCard(
              icon: Icons.open_in_browser_outlined,
              title: '앱 안에서 열 수 없어요',
              message: '웹에서는 동행복권 사이트를 앱 안에 표시할 수 없어요.\n아래 버튼으로 홈페이지를 열어주세요.',
              primaryLabel: '동행복권 홈페이지로 이동',
              onPrimaryPressed: _openLottoHomePage,
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
      color: backgroundColor,
      child: PageContentWidth(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _PurchaseStateCard(
              icon: Icons.cloud_off_outlined,
              title: '구매 페이지를 불러오지 못했어요',
              message: '다시 불러오거나 동행복권 홈페이지로 이동해서 확인할 수 있어요.',
              primaryLabel: '다시 불러오기',
              onPrimaryPressed: onRetry,
              secondaryLabel: '동행복권 홈페이지로 이동',
              onSecondaryPressed: _openLottoHomePage,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _openLottoHomePage() async {
  final uri = Uri.parse(_lottoHomeUrl);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _PurchaseStateCard extends StatelessWidget {
  const _PurchaseStateCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            icon,
            color: mainColor,
            size: 34,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: blackColor,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: greyColor,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          AppButton.primary(
            label: primaryLabel,
            onPressed: onPrimaryPressed,
            height: 48,
          ),
          if (secondaryLabel != null && onSecondaryPressed != null) ...[
            const SizedBox(height: 10),
            AppButton.neutral(
              label: secondaryLabel!,
              onPressed: onSecondaryPressed,
              height: 48,
            ),
          ],
        ],
      ),
    );
  }
}
