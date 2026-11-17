import 'package:flutter/material.dart';

import '../models/game_model.dart';
import '../services/library_service.dart';
import '../services/game_service.dart';

class DetailPage extends StatefulWidget {
  final int gameId;

  const DetailPage({super.key, required this.gameId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final GameService _service = GameService();
  final LibraryService _library = LibraryService();
  late Future<GameModel> _futureGame;

  @override
  void initState() {
    super.initState();
    _futureGame = _service.fetchGameDetail(widget.gameId);
  }

  void _retry() {
    setState(() {
      _futureGame = _service.fetchGameDetail(widget.gameId);
    });
  }

  Future<void> _toggleLibrary(GameModel game) async {
    final bool nowInLibrary = await _library.toggleLibrary(game);

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowInLibrary
              ? '${game.title} ditambahkan ke library'
              : '${game.title} dihapus dari library',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: FutureBuilder<GameModel>(
        future: _futureGame,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            debugPrint('DetailPage Error: ${snapshot.error}');

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  const Text('Gagal memuat detail'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          final GameModel game = snapshot.data!;
          final bool inLibrary = _library.isLibrary(game.id);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                _buildThumbnail(game),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Text(
                        game.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Genre & platform
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.category, size: 16),
                            label: Text(game.genre),
                          ),
                          Chip(
                            avatar: const Icon(Icons.computer, size: 16),
                            label: Text(game.platform),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Tombol library
                      ElevatedButton.icon(
                        onPressed: () => _toggleLibrary(game),
                        icon: Icon(
                          inLibrary
                              ? Icons.bookmark_remove
                              : Icons.bookmark_add_outlined,
                        ),
                        label: Text(
                          inLibrary
                              ? 'Hapus dari Library'
                              : 'Tambah ke Library',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Informasi
                      _sectionTitle('Informasi'),
                      const SizedBox(height: 8),
                      _infoRow('Publisher', game.publisher),
                      _infoRow('Developer', game.developer),
                      _infoRow('Rilis', game.release_date),
                      const SizedBox(height: 20),

                      // Overview
                      _sectionTitle('Overview'),
                      const SizedBox(height: 6),
                      Text(
                        game.description.isEmpty
                            ? 'Tidak ada deskripsi.'
                            : game.description,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),

                      // Screenshots
                      if (game.screenshots.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _sectionTitle('Screenshots'),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 130,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: game.screenshots.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  game.screenshots[index],
                                  height: 130,
                                  width: 220,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox(
                                    width: 220,
                                    height: 130,
                                    child: Center(
                                      child: Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      // System requirements
                      const SizedBox(height: 20),
                      _sectionTitle('Minimum System Requirements'),
                      const SizedBox(height: 8),
                      if (game.minimum_system_requirements.isEmpty)
                        const Text(
                          'Tidak ada data.',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ..._buildRequirements(game.minimum_system_requirements),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnail(GameModel game) {
    const placeholder = AspectRatio(
      aspectRatio: 16 / 9,
      child: Center(child: Icon(Icons.videogame_asset, size: 64)),
    );

    if (game.thumbnail == null) return placeholder;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        game.thumbnail!,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  List<Widget> _buildRequirements(Map<String, dynamic> req) {
    const labels = {
      'os': 'OS',
      'processor': 'Processor',
      'memory': 'Memory',
      'graphics': 'Graphics',
      'storage': 'Storage',
    };

    return req.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .map((e) => _infoRow(labels[e.key] ?? e.key, e.value.toString()))
        .toList();
  }
}
