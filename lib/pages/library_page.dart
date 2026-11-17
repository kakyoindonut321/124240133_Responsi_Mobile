import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/game_model.dart';
import '../services/library_service.dart';
import 'detail_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LibraryService service = LibraryService();

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ValueListenableBuilder<Box>(
        valueListenable: service.listenable,
        builder: (context, box, child) {
          final List<GameModel> games = service.getLibrary();

          // Kondisi kosong
          if (games.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videogame_asset_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Library masih kosong',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final GameModel game = games[index];

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(gameId: game.id),
                      ),
                    );
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: game.thumbnail == null
                        ? const SizedBox(
                            width: 96,
                            height: 54,
                            child: Icon(
                              Icons.videogame_asset,
                              color: Colors.grey,
                            ),
                          )
                        : Image.network(
                            game.thumbnail!,
                            width: 96,
                            height: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(
                                  width: 96,
                                  height: 54,
                                  child: Icon(
                                    Icons.videogame_asset,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                  ),
                  title: Text(
                    game.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${game.genre} • ${game.platform}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await service.removeLibrary(game.id);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${game.title} dihapus dari library'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
