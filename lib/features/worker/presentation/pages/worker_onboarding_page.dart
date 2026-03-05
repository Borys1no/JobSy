import 'package:flutter/material.dart';
import 'package:jobsy/core/widgets/blob_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jobsy/features/worker/presentation/pages/complete_profile_page.dart';
import 'package:jobsy/core/constants/app_constants.dart';
import 'package:jobsy/core/widgets/top_background_layout.dart';

class WorkerOnboardingPage extends StatefulWidget {
  const WorkerOnboardingPage({super.key});

  @override
  State<WorkerOnboardingPage> createState() => _WorkerOnboardingPageState();
}

class _WorkerOnboardingPageState extends State<WorkerOnboardingPage> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "Tu talento merece más clientes",
      "subtitle":
          "Haz visible tu experiencia, destaca tus habilidades y conecta con personas que realmente valoran tu trabajo.",
      "image": "assets/images/worker/worker.png",
    },
    {
      "title": "Construye tu reputación y consigue más clientes",
      "subtitle":
          "Cada servicio completado suma confianza y mejores calificaciones, ayudándote a atraer nuevas oportunidades.",
      "image": "assets/images/worker/worker_confiable.png",
    },
    {
      "title": "Recibe pagos seguros dentro de la app",
      "subtitle":
          "Gestiona tus cobros de forma protegida, con respaldo y registro claro de cada trabajo realizado.",
      "image": "assets/images/worker/worker_pay.png",
    },
    {
      "title": "Chatea y acuerda el servicio",
      "subtitle":
          "Habla directamente con el cliente, define los detalles y formaliza el trabajo con total claridad.",
      "image": "assets/images/worker/worker_chat.png",
    },
  ];
  void nextPage() {
    if (currentIndex < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      goToCompleteProfile();
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

  Future<void> goToCompleteProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("hasSeenWorkerOnboarding", true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        pages[index]["subtitle"]!,
                        textAlign: TextAlign.center,
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
                width: currentIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.blue
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(onPressed: previousPage, child: const Text("Atras")),
              ElevatedButton(
                onPressed: nextPage,
                child: Text(
                  currentIndex == pages.length - 1 ? "Finalizar" : "Siguiente",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
