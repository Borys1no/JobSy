import 'package:flutter/material.dart';
import 'package:jobsy/core/theme/app_theme.dart';
import 'package:jobsy/core/widgets/blob_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jobsy/features/client/presentation/pages/client_home_page.dart';
import 'package:jobsy/core/constants/app_constants.dart';
import 'package:jobsy/core/widgets/top_background_layout.dart';

class ClientOnboardingPage extends StatefulWidget {
  const ClientOnboardingPage({super.key});

  @override
  State<ClientOnboardingPage> createState() => _ClientOnboardingPageState();
}

class _ClientOnboardingPageState extends State<ClientOnboardingPage> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "Encuentra al profesional perfecto",
      "subtitle":
          "Explora una amplia red de trabajadores calificados para cualquier necesidad de tu hogar.",
      "image": "assets/images/client/client.png",
    },
    {
      "title": "Comunica directamente",
      "subtitle":
          "Chatea con los profesionales, discute detalles y establece acuerdos de manera fácil.",
      "image": "assets/images/client/client_chat.png",
    },
    {
      "title": "Servicios garantizados",
      "subtitle":
          "Los profesionales tienen reseñas verificadas para que confíes en quien trabaja en tu hogar.",
      "image": "assets/images/client/client_reviews.png",
    },
    {
      "title": "Pagos seguros",
      "subtitle":
          "Realiza pagos dentro de la app con total seguridad y protección.",
      "image": "assets/images/client/client_pay.png",
    },
  ];

  void nextPage() {
    if (currentIndex < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      goToHome();
    }
  }

  void previousPage() {
    if (currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  Future<void> goToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("hasSeenClientOnboarding", true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ClientHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TopBackgroundLayout(
      title: AppConstants.appName,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlobImage(
                        imagePath: pages[index]["image"]!,
                        variant: index,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        pages[index]["title"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        pages[index]["subtitle"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                width: currentIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: previousPage,
                  child: Text(
                    currentIndex == 0 ? "Saltar" : "Atrás",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.clientPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    currentIndex == pages.length - 1 ? "Comenzar" : "Siguiente",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
