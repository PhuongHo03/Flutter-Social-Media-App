import 'package:flutter/material.dart';
import 'package:social_app/components/list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfile;
  final void Function()? onChatHome;
  final void Function()? onSettings;
  final void Function()? onSignOut;
  const MyDrawer({
    super.key,
    required this.onProfile,
    required this.onChatHome,
    required this.onSettings,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //header
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  size: 64,
                ),
              ),

              //home list tile
              MyListTile(
                icon: Icons.home,
                text: "H O M E",
                onTap: () => Navigator.pop(context),
              ),

              //profile list tile
              MyListTile(
                icon: Icons.person,
                text: "P R O F I L E",
                onTap: onProfile,
              ),

              //chat home list tile
              MyListTile(
                icon: Icons.chat,
                text: "C H A T H O M E",
                onTap: onChatHome,
              ),

              //settings list tile
              MyListTile(
                icon: Icons.settings,
                text: "S E T T I N G S",
                onTap: onSettings,
              ),
            ],
          ),

          //logout list tile
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.logout,
              text: "L O G O U T",
              onTap: onSignOut,
            ),
          ),
        ],
      ),
    );
  }
}
