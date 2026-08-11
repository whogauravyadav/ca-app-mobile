import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../widgets/ad_banner_placeholder.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  const ArticleDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  ArticleModel? _article;
  bool _loading = true;
  String? _error;
  bool _bookmarking = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final article =
          await ref.read(authServiceProvider).getArticle(widget.slug);
      if (!mounted) return;
      setState(() {
        _article = article;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = apiErrorMessage(e);
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to bookmark articles')),
      );
      return;
    }
    final article = _article;
    if (article == null || _bookmarking) return;

    setState(() => _bookmarking = true);
    try {
      final service = ref.read(authServiceProvider);
      if (article.isBookmarked) {
        await service.removeBookmark(article.id);
        setState(() => _article = article.copyWith(isBookmarked: false));
      } else {
        await service.addBookmark(article.id);
        setState(() => _article = article.copyWith(isBookmarked: true));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _bookmarking = false);
    }
  }

  Future<void> _share() async {
    final article = _article;
    if (article == null) return;
    await Share.share(
      '${article.title}\n\nRead more in Current Affairs app',
      subject: article.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error ?? 'Article not found'),
                const SizedBox(height: 12),
                FilledButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    final article = _article!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            actions: [
              IconButton(
                tooltip: 'Share',
                onPressed: _share,
                icon: const Icon(Icons.share_outlined),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: article.featuredImage != null &&
                      article.featuredImage!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: article.featuredImage!,
                      fit: BoxFit.cover,
                      color: Colors.black26,
                      colorBlendMode: BlendMode.darken,
                    )
                  : Container(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.article_rounded,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.category != null)
                    Text(
                      article.category!.name.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${article.readTimeMin} min read',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (article.summary != null && article.summary!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      article.summary!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const AdNativePlaceholder(),
                  if (article.body != null && article.body!.isNotEmpty)
                    Html(
                      data: article.body!,
                      style: {
                        'body': Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          fontSize: FontSize(16),
                          lineHeight: const LineHeight(1.55),
                        ),
                      },
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No content available for this article.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  if (article.quizzes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Related quiz', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...article.quizzes.map((q) {
                      final id = q['id'];
                      final title = q['title']?.toString() ?? 'Quiz';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.quiz_outlined),
                        title: Text(title),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: id == null
                            ? null
                            : () => context.push('/quiz/$id'),
                      );
                    }),
                  ],
                  const AdBannerPlaceholder(label: 'Article footer'),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bookmarking ? null : _toggleBookmark,
        icon: Icon(
          article.isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
        ),
        label: Text(article.isBookmarked ? 'Saved' : 'Bookmark'),
      ),
    );
  }
}
