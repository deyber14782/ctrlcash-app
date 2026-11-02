import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/toast_helpers.dart';
import '../providers/education_notifier.dart';

class AdminPublishPage extends ConsumerStatefulWidget {
  const AdminPublishPage({super.key});

  @override
  ConsumerState<AdminPublishPage> createState() => _AdminPublishPageState();
}

class _AdminPublishPageState extends ConsumerState<AdminPublishPage> {
  String type = 'frase';
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  final videoCtrl = TextEditingController();
  XFile? pickedImage;
  bool saving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => pickedImage = img);
  }

  Future<void> _publish() async {
    if (saving) return;
    final notifier = ref.read(educationNotifierProvider.notifier);

    switch (type) {
      case 'frase':
        if (bodyCtrl.text.trim().isEmpty) {
          showError(context, 'Escribe la frase');
          return;
        }
        break;
      case 'articulo':
        if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) {
          showError(context, 'El artículo necesita título y cuerpo');
          return;
        }
        break;
      case 'video':
        if (titleCtrl.text.trim().isEmpty || videoCtrl.text.trim().isEmpty) {
          showError(context, 'El video necesita título y enlace');
          return;
        }
        break;
      case 'imagen':
        if (pickedImage == null) {
          showError(context, 'Selecciona una imagen');
          return;
        }
        break;
    }

    setState(() => saving = true);
    bool ok = false;
    try {
      switch (type) {
        case 'frase':
          ok = await notifier.publishText(type: 'frase', body: bodyCtrl.text.trim());
          break;
        case 'articulo':
          ok = await notifier.publishText(
              type: 'articulo', title: titleCtrl.text.trim(), body: bodyCtrl.text.trim());
          break;
        case 'video':
          ok = await notifier.publishText(
              type: 'video', title: titleCtrl.text.trim(), videoUrl: videoCtrl.text.trim());
          break;
        case 'imagen':
          final bytes = await pickedImage!.readAsBytes();
          ok = await notifier.publishImage(
            title: titleCtrl.text.trim(),
            imageBytes: bytes,
            fileName: pickedImage!.name,
          );
          break;
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }

    if (!mounted) return;
    if (ok) {
      showSuccess(context, 'Publicado');
      Navigator.of(context).pop();
    } else {
      showError(context, 'No se pudo publicar', 'Inténtalo de nuevo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Publicar'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Tipo de contenido',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _typeChip('frase', 'Frase'),
                _typeChip('articulo', 'Artículo'),
                _typeChip('imagen', 'Imagen'),
                _typeChip('video', 'Video'),
              ],
            ),
            const SizedBox(height: 28),
            ..._fieldsForType(),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: saving ? null : _publish,
              child: Text(saving ? 'PUBLICANDO...' : 'PUBLICAR',
                  style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _fieldsForType() {
    switch (type) {
      case 'frase':
        return [
          AppTextField(controller: bodyCtrl, label: 'Frase'),
        ];
      case 'articulo':
        return [
          AppTextField(controller: titleCtrl, label: 'Título'),
          const SizedBox(height: 16),
          AppTextField(controller: bodyCtrl, label: 'Cuerpo del artículo'),
        ];
      case 'video':
        return [
          AppTextField(controller: titleCtrl, label: 'Título'),
          const SizedBox(height: 16),
          AppTextField(controller: videoCtrl, label: 'Enlace de YouTube'),
        ];
      case 'imagen':
        return [
          AppTextField(controller: titleCtrl, label: 'Título (opcional)'),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: AppColors.border),
              ),
              child: pickedImage == null
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded,
                              color: AppColors.textSecondary, size: 32),
                          SizedBox(height: 8),
                          Text('Toca para elegir imagen',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    )
                  : Center(
                      child: Text('Imagen seleccionada: ${pickedImage!.name}',
                          style: const TextStyle(color: AppColors.accentLight, fontSize: 13)),
                    ),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _typeChip(String value, String label) {
    final selected = type == value;
    return GestureDetector(
      onTap: () => setState(() => type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 13)),
      ),
    );
  }
}