import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/utils/app_logger.dart';
import '../data/models/lieu.dart';
import '../data/sources/lieu_supabase_source.dart';

/// Page used to suggest and create a new campus place.
class AddLieuPage extends StatefulWidget {
  /// Creates the add place page.
  const AddLieuPage({super.key});

  @override
  State<AddLieuPage> createState() => _AddLieuPageState();
}

class _AddLieuPageState extends State<AddLieuPage> {
  final _formKey = GlobalKey<FormState>();
  final _source = LieuSupabaseSource();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _horaireController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _selectedCategory = ValueNotifier<LieuCategorie>(
    LieuCategorie.services,
  );
  final _isSubmitting = ValueNotifier<bool>(false);
  final _isLocating = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _horaireController.dispose();
    _imageUrlController.dispose();
    _selectedCategory.dispose();
    _isSubmitting.dispose();
    _isLocating.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            children: [
              _AddLieuTopBar(onBackPressed: () => Navigator.of(context).pop()),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Suggérer un lieu',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Aidez-nous à enrichir la carte du campus en proposant de nouvelles adresses utiles.',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const _InfoMessage(),
              const SizedBox(height: AppSpacing.md),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.borderSubtle),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(label: 'CATÉGORIE'),
                      const SizedBox(height: AppSpacing.xs),
                      _CategoryDropdown(selectedCategory: _selectedCategory),
                      const SizedBox(height: AppSpacing.md),
                      _FieldLabel(label: 'NOM DU LIEU'),
                      const SizedBox(height: AppSpacing.xs),
                      _TextInput(
                        controller: _nomController,
                        hintText: 'Ex: Foyer Etudiant, BU Sciences...',
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FieldLabel(label: 'DESCRIPTION'),
                      const SizedBox(height: AppSpacing.xs),
                      _TextInput(
                        controller: _descriptionController,
                        hintText:
                            'Que peut-on y trouver ? Horaires habituels ?',
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _FieldLabel(label: 'COORDONNÉES GPS'),
                          const Spacer(),
                          ValueListenableBuilder<bool>(
                            valueListenable: _isLocating,
                            builder: (context, isLocating, _) {
                              return TextButton.icon(
                                onPressed: isLocating
                                    ? null
                                    : _useCurrentPosition,
                                icon: isLocating
                                    ? const SizedBox.square(
                                        dimension: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.my_location, size: 18),
                                label: const Text('Ma Position'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.accent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: _TextInput(
                              controller: _latitudeController,
                              hintText: 'Latitude',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                              validator: _coordinateValidator,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _TextInput(
                              controller: _longitudeController,
                              hintText: 'Longitude',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                              validator: _coordinateValidator,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'Soyez le plus précis possible pour aider les autres étudiants à trouver le lieu.',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 10,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FieldLabel(label: 'HORAIRES'),
                      const SizedBox(height: AppSpacing.xs),
                      _TextInput(
                        controller: _horaireController,
                        hintText: 'Ex: 08:00 - 18:00',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FieldLabel(label: 'IMAGE'),
                      const SizedBox(height: AppSpacing.xs),
                      _TextInput(
                        controller: _imageUrlController,
                        hintText: 'URL de l’image du lieu',
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ValueListenableBuilder<bool>(
                valueListenable: _isSubmitting,
                builder: (context, isSubmitting, _) {
                  return FilledButton(
                    onPressed: isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      disabledBackgroundColor: AppColors.secondaryText,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.surface,
                            ),
                          )
                        : const Text(
                            'Ajouter le lieu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      AppLogger.warning(
        'Add place validation failed: required field is empty.',
      );
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  String? _coordinateValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      AppLogger.warning('Add place validation failed: coordinate is empty.');
      return 'Obligatoire';
    }
    if (double.tryParse(value.trim().replaceAll(',', '.')) == null) {
      AppLogger.warning('Add place validation failed: invalid coordinate.');
      return 'Nombre invalide';
    }
    return null;
  }

  Future<void> _useCurrentPosition() async {
    _isLocating.value = true;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Activez la localisation pour utiliser votre position.',
            ),
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (!mounted) {
        return;
      }
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) {
          return;
        }
      }

      if (permission == LocationPermission.denied) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Permission de localisation refusée.')),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Autorisez la localisation dans les réglages pour utiliser votre position.',
            ),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) {
        return;
      }

      _latitudeController.text = position.latitude.toStringAsFixed(6);
      _longitudeController.text = position.longitude.toStringAsFixed(6);
    } on Object catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

      AppLogger.error(
        'Failed to retrieve current position.',
        error: error,
        stackTrace: stackTrace,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Impossible de récupérer la position.')),
      );
    } finally {
      if (mounted) {
        _isLocating.value = false;
      }
    }
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      AppLogger.warning('Add place form submitted with invalid values.');
      return;
    }

    _isSubmitting.value = true;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final lieu = Lieu(
      nom: _nomController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: double.parse(
        _latitudeController.text.trim().replaceAll(',', '.'),
      ),
      longitude: double.parse(
        _longitudeController.text.trim().replaceAll(',', '.'),
      ),
      categorie: _selectedCategory.value,
      horaireOuverture: _horaireController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
    );

    try {
      await _source.create(lieu);
      if (!mounted) {
        return;
      }

      _isSubmitting.value = false;
      AppLogger.info('Place added successfully: ${lieu.nom}.');
      messenger.showSnackBar(
        const SnackBar(content: Text('Lieu ajouté avec succès.')),
      );
      navigator.pop();
    } on Object catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

      _isSubmitting.value = false;
      AppLogger.error(
        'Failed to add place: ${lieu.nom}.',
        error: error,
        stackTrace: stackTrace,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Impossible d’ajouter le lieu.')),
      );
    }
  }
}

class _AddLieuTopBar extends StatelessWidget {
  final VoidCallback onBackPressed;

  const _AddLieuTopBar({required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBackPressed,
              icon: const Icon(Icons.arrow_back_ios_new),
              color: AppColors.primary,
              tooltip: 'Retour',
            ),
          ),
          const Text(
            'Ajouter un lieu',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoMessage extends StatelessWidget {
  const _InfoMessage();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.selected,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info, color: AppColors.accent, size: 20),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Votre suggestion sera enregistrée dans la base de données pour enrichir la carte du campus.',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final ValueNotifier<LieuCategorie> selectedCategory;

  const _CategoryDropdown({required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    final categories = LieuCategorie.values
        .where((category) => category != LieuCategorie.all)
        .toList(growable: false);
    return ValueListenableBuilder<LieuCategorie>(
      valueListenable: selectedCategory,
      builder: (context, value, _) {
        return DropdownButtonFormField<LieuCategorie>(
          initialValue: value,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.keyboard_arrow_down),
          decoration: _inputDecoration('Sélectionnez une catégorie...'),
          items: categories
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(category.label),
                ),
              )
              .toList(),
          onChanged: (category) {
            if (category != null) {
              selectedCategory.value = category;
            }
          },
        );
      },
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TextInput({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(hintText),
    );
  }
}

InputDecoration _inputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.secondaryText),
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: 14,
    ),
  );
}
