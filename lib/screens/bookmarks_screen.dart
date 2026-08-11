import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../widgets/article_card.dart';
import '../widgets/shimmer_list.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  List<BookmarkModel> _bookmarks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) {
      setState(() {
        _loading = false;
        _bookmarks = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref.read(authServiceProvider).getBookmarks();
      if (!mounted) return;
      setState(() {
        _bookmarks = list;
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

  Future<void> _remove(BookmarkModel bookmark) async {
    final article = bookmark.article;
    if (article == null) return;
    try {
      await ref.read(authServiceProvider).removeBookmark(article.id);
      setState(() {
        _bookmarks = _bookmarks.where((b) => b.id != bookmark.id).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: auth.status != AuthStatus.authenticated
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      size: 56,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text('Sign in to save articles', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Bookmarks sync across sessions once you are logged in.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: ShimmerList(),
                    )
                  : _error != null
                      ? ListView(
                          children: [
                            const SizedBox(height: 120),
                            Center(child: Text(_error!)),
                            Center(
                              child: TextButton(
                                onPressed: _load,
                                child: const Text('Retry'),
                              ),
                            ),
                          ],
                        )
                      : _bookmarks.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.55,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.bookmarks_outlined,
                                          size: 56,
                                          color: theme.colorScheme.outline,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No bookmarks yet',
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Tap the bookmark button on any article to save it here.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: _bookmarks.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final bookmark = _bookmarks[index];
                                final article = bookmark.article;
                                if (article == null) {
                                  return const SizedBox.shrink();
                                }
                                return Dismissible(
                                  key: ValueKey(bookmark.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                  onDismissed: (_) => _remove(bookmark),
                                  child: ArticleCard(article: article),
                                );
                              },
                            ),
            ),
    );
  }
}
