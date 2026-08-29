import 'package:flutter/material.dart';

/// Keeps [child] mounted while [isLoading] is true.
///
/// Replacing the form/list with a [CircularProgressIndicator] disposes
/// OverlayPortals (dropdowns, popup menus, autocomplete) while they are
/// still calling [OverlayPortalController.hide], which trips Flutter's
/// `_zOrderIndex != null` assertion and aborts the in-flight save.
class CrudBusyBody extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const CrudBusyBody({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) ...[
          const ModalBarrier(dismissible: false, color: Color(0x33000000)),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}
