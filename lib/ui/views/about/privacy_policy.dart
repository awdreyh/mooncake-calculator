import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/language_provider.dart';
import '../../core/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final String languageCode = 'zh'; // Default to Chinese
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    final isChinese = lang == 'zh';
    return Scaffold(
      appBar: AppBar(title: Text(isChinese ? "隐私政策" : "Privacy Policy")),
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
    return [
      const Text(
        "Privacy Policy",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      const SizedBox(height: 8),

      const Text(
        "Last Updated: August 2026\n",
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),

      const Text(
        "This Privacy Policy explains how Moon Cake Calendar App handles your "
        "information. This is a simple app that does not collect, store, "
        "or transmit any personal data. All data created within the app "
        "is saved locally on your device and never shared with us or any "
        "third parties.",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 20),
      const Text(
        "1. Information We Do Not Collect",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.espresso),
      ),
      const SizedBox(height: 8),
      const Text(
        "• We do not collect personal information.\n"
        "• We do not collect usage data.\n"
        "• We do not use cookies or tracking technologies.\n"
        "• We do not access your contacts, location, photos, or files "
        "unless required for core app functionality and only with your permission.",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 20),
      const Text(
        "2. Local Data Storage",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.espresso),
      ),
      const SizedBox(height: 8),
      const Text(
        "All data you create or save within the app remains stored locally "
        "on your device. We do not have access to this data.",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 20),
      const Text(
        "3. Third-Party Services",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.espresso),
      ),
      const SizedBox(height: 8),
      const Text(
        "This app does not use any third‑party analytics, advertising, or "
        "data-collection services.",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 20),
      const Text(
        "4. Children's Privacy",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.espresso),
      ),
      const SizedBox(height: 8),
      const Text(
        "Since we do not collect any data, the app is safe for users of all ages.",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 20),
      const Text(
        "5. Changes to This Policy",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.espresso),
      ),
      const SizedBox(height: 8),
      const Text(
        "If we make changes to this Privacy Policy, we will update the date "
        "above. Any future versions will continue to respect your privacy.",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 20),
      const Text(
        "6. Contact Us",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.espresso),
      ),
      const SizedBox(height: 8),
      const Text(
        "If you have any questions, you can contact us at:\n"
        "mc.cal.app@gmail.com",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 40),
    ];
  }

  // -----------------------------
  // Chinese Content
  // -----------------------------
  List<Widget> _buildChineseContent() {
    return [
      const Text(
        "隐私政策",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      const SizedBox(height: 8),

      const Text(
        "最后更新日期: 2026年8月\n",
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),

      const Text(
        "本隐私政策说明 Moon Cake Calendar App 如何处理您的信息。"
        "本应用为简单的离线应用，不会收集、存储或传输任何个人数据。"
        "所有在应用中创建的数据都保存在您的设备本地，不会与我们或任何第三方共享。",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 20),
      const Text(
        "1. 我们不收集的信息",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      const SizedBox(height: 8),
      const Text(
        "• 我们不收集个人信息。\n"
        "• 我们不收集使用数据。\n"
        "• 我们不使用 Cookies 或任何追踪技术。\n"
        "• 除非核心功能需要且获得您的许可，我们不会访问您的联系人、位置、照片或文件。",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 20),
      const Text(
        "2. 本地数据存储",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      const SizedBox(height: 8),
      const Text(
        "您在应用中创建或保存的所有数据都存储在您的设备本地。我们无法访问这些数据。",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 20),
      const Text(
        "3. 第三方服务",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      const SizedBox(height: 8),
      const Text("本应用不使用任何第三方分析、广告或数据收集服务。", style: TextStyle(fontSize: 16)),

      const SizedBox(height: 20),
      const Text(
        "4. 儿童隐私",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      const SizedBox(height: 8),
      const Text("由于我们不收集任何数据，本应用适用于所有年龄段的用户。", style: TextStyle(fontSize: 16)),

      const SizedBox(height: 20),
      const Text(
        "5. 政策变更",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      const SizedBox(height: 8),
      const Text(
        "如果我们更新隐私政策，我们会修改上方日期。未来版本仍将尊重您的隐私。",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 20),
      const Text(
        "6. 联系我们",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.espresso),
      ),
      const SizedBox(height: 8),
      const Text(
        "如有任何问题，请通过以下方式联系我们: \n"
        "mc.cal.app@gmail.com",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 40),
    ];
  }
}
