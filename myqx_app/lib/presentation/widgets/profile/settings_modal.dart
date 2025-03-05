import 'package:flutter/material.dart';
import 'package:myqx_app/core/constants/corporative_colors.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({Key? key}) : super(key: key);

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  bool _isProfilePublic = true;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: CorporativeColors.whiteColor, height: 20),
            Row(
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CorporativeColors.whiteColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: CorporativeColors.whiteColor),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            const Divider(color: CorporativeColors.mainColor, height: 16),
            
            // Perfil público toggle - compacto
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Public Profile',
                  style: TextStyle(
                    fontSize: 15,
                    color: CorporativeColors.whiteColor,
                  ),
                ),
                Switch(
                  value: _isProfilePublic,
                  onChanged: (value) {
                    setState(() {
                      _isProfilePublic = value;
                    });
                  },
                  activeColor: CorporativeColors.mainColor,
                ),
              ],
            ),
            
            const SizedBox(height: 5),
            

            // Botón para guardar - compacto
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint('Profile public: $_isProfilePublic');
                  debugPrint('Description: ${_descriptionController.text}');
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CorporativeColors.mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(0, 36),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            const Divider(color: CorporativeColors.mainColor, height: 24),
            
            // Eliminar cuenta - compacto
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  _showDeleteConfirmation(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
                child: const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          title: const Text(
            'Delete Account?',
            style: TextStyle(color: CorporativeColors.whiteColor, fontSize: 16),
          ),
          content: const Text(
            'This action cannot be undone. All your data will be permanently deleted.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                debugPrint('Account deletion requested');
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
              ),
              child: const Text('Delete', style: TextStyle(fontSize: 14, color: CorporativeColors.whiteColor)),
            ),
          ],
        );
      },
    );
  }
}