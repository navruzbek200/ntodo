import 'package:url_launcher/url_launcher.dart';

import '../untils/logger.dart';

abstract class AppLinks {
  static const privacyPolicy = 'https://navruzbek200.github.io/ntodo/privacy-policy.html';
  static const deleteAccountPage = '$privacyPolicy#delete-account';
  static const supportEmail = 'navrozbekbektemirov7@gmail.com';

  /// Opens [url] in the browser; false if nothing could handle it.
  static Future<bool> open(String url) async {
    try {
      return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e, s) {
      LoggerService.error('Could not open $url', e, s);
      return false;
    }
  }

  /// Pre-filled deletion request email; falls back to the web instructions.
  static Future<void> requestAccountDeletion(String username) async {
    final mail = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: _query({
        'subject': 'Ntodo account deletion',
        'body': 'Please delete my Ntodo account and all of its data.\n\nUsername: $username',
      }),
    );
    try {
      if (await launchUrl(mail)) return;
    } catch (e, s) {
      LoggerService.warning('No email app, opening web page instead: $e\n$s');
    }
    await open(deleteAccountPage);
  }

  // Uri(queryParameters:) encodes spaces as '+', which mail apps show literally.
  static String _query(Map<String, String> params) => params.entries
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
