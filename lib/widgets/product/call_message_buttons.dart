import 'package:flutter/material.dart';
import 'package:qio/models/offer.dart';
import 'package:qio/screens/chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class CallMessageButtons extends StatelessWidget {
  const CallMessageButtons({super.key, required this.offer});
  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            style: FilledButton.styleFrom(
              side: BorderSide(color: Colors.white, width: 1),
            ),
            onPressed: () async {
              await launchUrl(Uri.parse('tel:${offer.phone}'));
            },
            label: Text('اتصل'),
            icon: Icon(Icons.call),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ChatScreen(email: offer.user, sender: offer.user),
                ),
              );
            },
            label: Text('دردشة'),
            icon: Icon(Icons.chat),
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
