import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../utils/language_provider.dart';
import '../../core/app_theme.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});
  final String languageCode = 'zh'; // Default to Chinese

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool isChinese = true;
  final TextEditingController feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> sendFeedback() async {
    final feedback = feedbackController.text.trim();
    if (feedback.isEmpty) return;

    final email = Uri(
      scheme: 'mailto',
      path: 'mc.cal.app@gmail.com',
      query: 'subject=App Feedback&body=$feedback',
    );

    await launchUrl(email);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    isChinese = lang == 'zh';
    return Scaffold(
      appBar: AppBar(title: Text(isChinese ? "反馈意见" : "Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isChinese ? "我们非常重视您的意见" : "We value your feedback",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.espresso),
            ),
            const SizedBox(height: 12),

            Text(
              isChinese
                  ? "如果您有任何建议、问题或想法，请在下面输入并发送给我们。"
                  : "If you have any suggestions, questions, or ideas, please write them below and send them to us.",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: feedbackController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: isChinese ? "请输入您的反馈…" : "Enter your feedback…",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sendFeedback,
                child: Text(
                  isChinese ? "发送反馈" : "Send Feedback",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
