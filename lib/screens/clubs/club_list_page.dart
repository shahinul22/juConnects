import 'package:flutter/material.dart';
import '../../models/club_model.dart';
import '../../service/club_service.dart';
import 'club_details_page.dart';
import 'create_club_page.dart';

class ClubListPage extends StatelessWidget {
  final ClubService _clubService = ClubService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Clubs"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CreateClubPage()));
        },
      ),
      body: StreamBuilder<List<Club>>(
        stream: _clubService.getClubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No clubs found."));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              Club club = snapshot.data![index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(club.logoUrl),
                    backgroundColor: Colors.grey[200],
                    onBackgroundImageError: (_, __) => const Icon(Icons.groups),
                  ),
                  title: Text(club.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(club.moto, style: const TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 5),
                      Chip(
                        label: Text(club.type, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: _getTypeColor(club.type),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ClubDetailsPage(club: club)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Tech': return Colors.indigo;
      case 'Sports': return Colors.orange;
      case 'Cultural': return Colors.purple;
      case 'Social': return Colors.green;
      default: return Colors.blueGrey;
    }
  }
}