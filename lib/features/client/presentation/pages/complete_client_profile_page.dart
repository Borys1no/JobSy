import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobsy/core/theme/app_theme.dart';
import 'package:jobsy/features/auth/auth_providers.dart';
import 'package:jobsy/features/auth/data/profile_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;

class CompleteClientProfilePage extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const CompleteClientProfilePage({super.key, this.onComplete});

  @override
  ConsumerState<CompleteClientProfilePage> createState() =>
      _CompleteClientProfilePageState();
}

class _CompleteClientProfilePageState
    extends ConsumerState<CompleteClientProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();

  String? _avatarPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatarPath = image.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = ref.read(supabaseProvider);
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      String? avatarUrl;
      if (_avatarPath != null) {
        var file = File(_avatarPath!);
        final fileSize = await file.length();
        
        // Comprimir si es mayor a 500KB
        if (fileSize > 500 * 1024) {
          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            _avatarPath!,
            _avatarPath!.replaceAll(RegExp(r'\.\w+$'), '_compressed.jpg'),
            quality: 70,
            minWidth: 800,
            minHeight: 800,
          );
          if (compressedFile != null) {
            file = File(compressedFile.path);
          }
        }
        
        final fileExt = 'jpg';
        final filePath = '${user.id}/avatar.$fileExt';

        await supabase.storage
            .from('profiles')
            .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

        avatarUrl = supabase.storage.from('profiles').getPublicUrl(filePath);
      }

      await supabase.from('profiles').update({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'avatar_url': avatarUrl,
      }).eq('id', user.id);

      final existingIdentity = await supabase
          .from('user_identity')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingIdentity != null) {
        await supabase.from('user_identity').update({
          'national_id': _nationalIdController.text.trim(),
        }).eq('user_id', user.id);
      } else {
        await supabase.from('user_identity').insert({
          'user_id': user.id,
          'national_id': _nationalIdController.text.trim(),
          'verified': false,
        });
      }

      ref.invalidate(isProfileCompleteProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        String message = 'Error al guardar el perfil';
        if (e.toString().contains('413') || e.toString().contains('Payload too large')) {
          message = 'La imagen es muy grande. Máximo 2MB.';
        } else if (e.toString().contains('object')) {
          message = 'La imagen es muy grande. Máximo 2MB.';
        } else {
          message = 'Error: $e';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF121212) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.clientPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          'Completar perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: cardColor,
                      backgroundImage: _avatarPath != null
                          ? FileImage(File(_avatarPath!))
                          : null,
                      child: _avatarPath == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.clientPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Por favor completa tu información personal',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'Nombres',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: cardColor,
                ),
                style: TextStyle(color: textColor),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tus nombres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Apellidos',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: cardColor,
                ),
                style: TextStyle(color: textColor),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tus apellidos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nationalIdController,
                decoration: InputDecoration(
                  labelText: 'Cédula',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.badge),
                  helperText: '10 dígitos sin guiones',
                  filled: true,
                  fillColor: cardColor,
                ),
                style: TextStyle(color: textColor),
                keyboardType: TextInputType.number,
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu cédula';
                  }
                  if (value.length != 10) {
                    return 'La cédula debe tener 10 dígitos';
                  }
                  return null;
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta información no será visible públicamente',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                  helperText: 'Ej: 0991234567',
                  filled: true,
                  fillColor: cardColor,
                ),
                style: TextStyle(color: textColor),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu teléfono';
                  }
                  if (value.length != 10) {
                    return 'El teléfono debe tener 10 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.clientPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}