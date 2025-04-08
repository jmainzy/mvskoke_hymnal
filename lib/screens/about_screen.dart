import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:url_launcher/url_launcher.dart';

Logger logger = Logger();

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  AboutScreenState createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PackageInfo? packageInfo;

  @override
  void initState() {
    _getVersionInfo();
    super.initState();
  }

  _getVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Padding(
        padding: EdgeInsets.all(Dimens.marginLarge),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyText(
                'This is a Hymnal in the Mvskoke language',
                lineHeight: 2,
              ),
              HeaderText('Contact'),
              BodyText("nativeware.solutions@gmail.com")
            ],
          ),
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      logger.e('Could not launch $url');
    }
  }

  // void _share(String url) {
  //   logger.i('Sharing $url');
  //   try {
  //     Share.share(url);
  //   } catch (e) {
  //     logger.e('Could not share $url $e');
  //   }
  // }
}

class HeaderText extends StatelessWidget {
  final String text;

  const HeaderText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimens.marginLarge),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class BodyText extends StatelessWidget {
  final String text;
  final double? lineHeight;

  const BodyText(this.text, {this.lineHeight, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: lineHeight != null
          ? Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(height: lineHeight)
          : Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class Button extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;

  const Button(this.text, {super.key, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimens.marginShort),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, color: Theme.of(context).colorScheme.onSurface),
            if (icon != null) const SizedBox(width: Dimens.marginShort),
            Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontFamily: 'Noto'),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
