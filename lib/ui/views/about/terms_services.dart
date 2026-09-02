import 'package:flutter/material.dart';
import 'package:moon_cake_app/ui/core/app_theme.dart';

import 'package:provider/provider.dart';
import '../../utils/language_provider.dart';

class TermsServicesPage extends StatefulWidget {
  const TermsServicesPage({super.key});
  final String languageCode = 'zh'; // Default to Chinese

  @override
  State<TermsServicesPage> createState() => _TermsServicesPageState();
}

class _TermsServicesPageState extends State<TermsServicesPage> {
  bool isChinese = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
        final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    isChinese = lang == 'zh';
    return Scaffold(
      appBar: AppBar(
        title: Text(isChinese ? "服务条款" : "Terms of Service"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: isChinese ? _buildChineseContent() : _buildEnglishContent(),
        ),
      ),
    );
  }

  // -----------------------------
  // English Content
  // -----------------------------
  List<Widget> _buildEnglishContent() {
    return const [
      Text(
        "Terms of Service",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),

      Text(
        "Last Updated: August 2026\n",
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),

      Text(
        "These Terms of Service govern your use of Moon Cake Calendar App. "
        "By using the App, you agree to these Terms.",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "1. Use of the App",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "You may use the App for personal, non-commercial purposes. "
        "You agree not to misuse or interfere with the App.",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "2. No Data Collection",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "This App does not collect, store, transmit, or share any personal data. "
        "All data remains on your device.",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "3. Local Storage Responsibility",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "You are responsible for managing and backing up your own data. "
        "Uninstalling the App may delete all locally stored data.",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "4. Intellectual Property",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "All content and functionality of the App are owned by [Your Company Name]. "
        "You may not copy, modify, or reverse-engineer the App.",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "5. Third-Party Services",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "The App does not use third-party analytics, advertising, or cloud services.",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "6. Disclaimer of Warranty",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "The App is provided 'as is' without warranties of any kind.",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "7. Limitation of Liability",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "[Your Company Name] is not liable for damages arising from use of the App.",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "8. Changes to These Terms",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "We may update these Terms. Continued use of the App means you accept them.",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "9. Contact Us",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "If you have questions, contact us at:\nmc.cal.app@gmail.com",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 40),
    ];
  }

  // -----------------------------
  // Chinese Content
  // -----------------------------
  List<Widget> _buildChineseContent() {
    return const [
      Text(
        "服务条款",
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),

      Text(
        "最后更新日期: 2026年8月\n",
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),

      Text(
        "本服务条款规范您对 Moon Cake Calendar App 的使用。"
        "使用本应用即表示您同意这些条款。",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "1. 应用的使用",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "您可以将本应用用于个人、非商业用途。您同意不滥用本应用，也不干扰其正常运行。",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "2. 无数据收集",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "本应用不会收集、存储、传输或共享任何个人数据。所有数据均保存在您的设备本地。",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "3. 本地存储责任",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "您负责管理、备份或删除自己的数据。卸载应用可能会导致所有本地数据被永久删除。",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "4. 知识产权",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "本应用的所有内容、设计和功能均由 [Your Company Name] 所有。"
        "您不得复制、修改、分发或反向工程本应用。",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "5. 第三方服务",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "本应用不使用任何第三方分析、广告或云服务。",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "6. 免责声明",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "本应用按“原样”提供，不提供任何形式的保证。",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "7. 责任限制",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "在法律允许的最大范围内，[Your Company Name] 对因使用本应用而产生的任何损害不承担责任。",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "8. 条款变更",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "我们可能会更新这些条款。继续使用本应用即表示您接受更新后的条款。",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 20),
      Text(
        "9. 联系我们",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      SizedBox(height: 8),
      Text(
        "如有任何问题，请通过以下方式联系我们: \nmc.cal.app@gmail.com",
        style: TextStyle(fontSize: 16),
      ),

      SizedBox(height: 40),
    ];
  }
}
