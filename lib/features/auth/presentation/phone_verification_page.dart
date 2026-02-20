import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({super.key});

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();

  bool codeSent = false;
  bool loading = false;

  final supabase = Supabase.instance.client;

  Future<void> sendCode() async {
    setState(() => loading = true);

    try {
      await supabase.auth.signInWithOtp(phone: phoneController.text.trim());
      setState(() {
        codeSent = true;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> verifyCode() async {
    setState(() => loading = true);

    try {
      await supabase.auth.verifyOTP(
        phone: phoneController.text.trim(),
        token: codeController.text.trim(),
        type: OtpType.sms,
      );

      await supabase
          .from('profiles')
          .update({
            'phone': phoneController.text.trim(),
            'phone_verified': false,
          })
          .eq('id', supabase.auth.currentUser!.id);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Número verificado")));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Código inválido")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verificar teléfono")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!codeSent) ...[
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Número (+569...)",
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : sendCode,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Enviar código"),
              ),
            ] else ...[
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: "Código recibido"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : verifyCode,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Verificar código"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
