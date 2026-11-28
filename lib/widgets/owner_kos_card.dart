import 'package:flutter/material.dart';
import '../models/kos_model.dart';

class OwnerKosCard extends StatelessWidget {
  final Kos kos;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRestore;

  const OwnerKosCard({
    super.key,
    required this.kos,
    required this.onEdit,
    required this.onDelete,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    kos.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kos.isFull ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    kos.isFull ? 'Penuh' : 'Sisa ${kos.roomAvailable}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: kos.isFull ? Colors.red.shade900 : Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(kos.address, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 4),
            Text(kos.formattedPrice, style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            
            // Tombol Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!kos.isActive)
                  TextButton.icon(
                    onPressed: onRestore,
                    icon: const Icon(Icons.restore, color: Colors.blue, size: 20),
                    label: const Text('Pulihkan', style: TextStyle(color: Colors.blue)),
                  )
                else ...[
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                    label: const Text('Edit', style: TextStyle(color: Colors.orange)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}