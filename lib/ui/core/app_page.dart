import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moon_cake_app/ui/core/nav_bottom.dart';
import 'package:provider/provider.dart';
import '../utils/app_strings.dart';
import '../utils/language_provider.dart';
import 'app_theme.dart';
import '../views/about/privacy_policy.dart';
import '../views/about/terms_services.dart';
import '../views/about/feedback.dart';

class AppPage extends StatelessWidget {
  final String title;
  final Widget child;
  final int currentNavIndex;
  final bool extendBodyBehindAppBar;

  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.currentNavIndex = 0,
    this.extendBodyBehindAppBar = false,
  });
  Future<void> openRatingPage() async {
    final url = Uri.parse(
      "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor:
          Colors.transparent, // Make Scaffold background transparent
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        toolbarHeight: 32,
        systemOverlayStyle: SystemUiOverlayStyle(
          // background of the top bar
          statusBarIconBrightness: Brightness.dark, // icons become white
          systemNavigationBarColor: AppColors.espressoLight,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      endDrawer: SizedBox(
        width: 250, // <<< Adjust this to make the menu smaller or larger
        child: Drawer(
          backgroundColor: AppColors.sectionBg,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 100,
                child: Text("", style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text(AppStrings.get('language_select', lang)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/');
                },
              ),
              ListTile(
                leading: Radio<String>(
                  value: 'en',
                  groupValue: lang,
                  onChanged: (value) {
                    languageProvider.setLanguage(value!);
                  },
                ),
                title: Text(AppStrings.get('english', lang)),
                onTap: () {
                  languageProvider.setLanguage('en');
                },
              ),
              ListTile(
                leading: Radio<String>(
                  value: 'zh',
                  groupValue: lang,
                  onChanged: (value) {
                    languageProvider.setLanguage(value!);
                  },
                ),
                title: Text(AppStrings.get('chinese', lang)),
                onTap: () {
                  languageProvider.setLanguage('zh');
                },
              ),
              Divider(color: AppColors.borderLight, thickness: 1, height: 32),
              ListTile(
                leading: Icon(Icons.privacy_tip),
                title: Text(AppStrings.get('privacy_policy', lang)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacyPolicyPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.description),
                title: Text(AppStrings.get('terms_of_service', lang)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TermsServicesPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.feedback),
                title: Text(AppStrings.get('feedback', lang)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedbackPage()),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.star_rate),
                title: Text(AppStrings.get('rate_this_app', lang)),
                onTap: openRatingPage,
              ),
            ],
          ),
        ),
      ),

      body: child,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: currentNavIndex,
      ),
    );
  }
}
