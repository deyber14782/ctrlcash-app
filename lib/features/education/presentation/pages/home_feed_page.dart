import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/fade_in.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/education_notifier.dart';
import '../providers/education_state.dart';
import '../../domain/entities/content_item.dart';
import 'image_view_page.dart';
import 'article_view_page.dart';
import 'admin_publish_page.dart';

class HomeFeedPage extends ConsumerStatefulWidget {
  const HomeFeedPage({super.key});

  @override
  ConsumerState<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends ConsumerState<HomeFeedPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(educationNotifierProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(educationNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;
    final name = user?.displayName ?? 'de nuevo';
    final isAdmin = user?.role == 'administrador';

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: isAdmin
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.5),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: AppColors.accent,
                shape: const CircleBorder(),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminPublishPage()),
                ),
                child: const Icon(Icons.edit, color: AppColors.textPrimary),
              ),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          onRefresh: () => ref.read(educationNotifierProvider.notifier).load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 24, 4, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hola, $name',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text('Aprende hoy',
                        style: Theme.of(context).textTheme.displayMedium),
                  ],
                ),
              ),
              _buildContent(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(EducationState state) {
    if (state.status == EducationStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: SizedBox(
            width: 28, height: 28,
            child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
          ),
        ),
      );
    }
    if (state.status == EducationStatus.error) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text(state.errorMessage ?? 'Error',
              style: const TextStyle(color: AppColors.error)),
        ),
      );
    }
    if (state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text('Aún no hay publicaciones',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }
    return Column(
      children: List.generate(state.items.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: FadeIn(
            delay: Duration(milliseconds: 60 * i),
            child: _ContentCard(item: state.items[i]),
          ),
        );
      }),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final ContentItem item;
  const _ContentCard({required this.item});

  String get _typeLabel {
    switch (item.type) {
      case 'frase': return 'Frase';
      case 'articulo': return 'Artículo';
      case 'imagen': return 'Imagen';
      case 'video': return 'Video';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('C',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CtrlCash',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13)),
                  Text(_typeLabel,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (item.type) {
      case 'frase':
        return Text('"${item.body ?? ''}"',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.35));

      case 'articulo':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title ?? '',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              (item.body ?? '').length > 120
                  ? '${(item.body ?? '').substring(0, 120)}...'
                  : (item.body ?? ''),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ArticleViewPage(title: item.title ?? '', body: item.body ?? ''),
              )),
              child: const Text('Leer más →',
                  style: TextStyle(color: AppColors.accentLight, fontSize: 13)),
            ),
          ],
        );

      case 'imagen':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.title != null && item.title!.isNotEmpty) ...[
              Text(item.title!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
              const SizedBox(height: 10),
            ],
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ImageViewPage(imageUrl: item.imageUrl!),
              )),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Image.network(
                  item.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: AppColors.surfaceElevated,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case 'video':
        final thumb = item.youtubeId != null
            ? 'https://img.youtube.com/vi/${item.youtubeId}/hqdefault.jpg'
            : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final url = Uri.parse(item.videoUrl!);
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No se pudo abrir el video')),
                    );
                  }
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (thumb != null)
                      Image.network(thumb, width: double.infinity, height: 160, fit: BoxFit.cover)
                    else
                      Container(height: 160, width: double.infinity, color: AppColors.surfaceElevated),
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.6),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(item.title ?? '',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14)),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}