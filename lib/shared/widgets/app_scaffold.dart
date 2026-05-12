import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/user_role.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.eyebrow,
  });

  /// Big page title rendered in the masthead.
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  /// Optional uppercase rubric shown above the title (e.g. "SECTION · 03").
  final String? eyebrow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final role = user?.role ?? UserRole.resident;
    final isWide = MediaQuery.sizeOf(context).width >= 1024;
    final destinations = _destinationsFor(role);
    final currentLocation = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(destinations, currentLocation);

    if (isWide) {
      const sidebarWidth = 268.0;
      return Scaffold(
        backgroundColor: TereTheme.paper,
        floatingActionButton: floatingActionButton,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final rightWidth =
                (constraints.maxWidth - sidebarWidth).clamp(0.0, double.infinity);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: sidebarWidth,
                  child: _EditorialSidebar(
                    user: user,
                    role: role,
                    destinations: destinations,
                    selectedIndex: selectedIndex,
                    onSignOut: () async {
                      await ref.read(authRepositoryProvider).signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ),
                SizedBox(
                  width: rightWidth,
                  child: Material(
                    color: TereTheme.paper,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Masthead(
                          title: title,
                          eyebrow: eyebrow,
                          actions: actions,
                        ),
                        Expanded(child: body),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // Compact / mobile layout
    return Scaffold(
      backgroundColor: TereTheme.paper,
      appBar: AppBar(
        backgroundColor: TereTheme.paper,
        foregroundColor: TereTheme.ink,
        elevation: 0,
        title: Text(title.toUpperCase(), style: TereTheme.overline(size: 13)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(height: 2, thickness: 2, color: TereTheme.ink),
        ),
        actions: [
          ...?actions,
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: Container(
        decoration: const Border(top: BorderSide(color: TereTheme.ink, width: 2))
            .toBoxDecoration(),
        child: NavigationBar(
          backgroundColor: TereTheme.paper,
          indicatorColor: TereTheme.ink,
          selectedIndex: selectedIndex.clamp(0, destinations.length - 1),
          onDestinationSelected: (i) => context.go(destinations[i].path),
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon, color: TereTheme.paper),
                label: d.label,
              ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  int _selectedIndex(List<_NavDest> dests, String location) {
    int best = 0;
    int bestLen = -1;
    for (var i = 0; i < dests.length; i++) {
      if (location.startsWith(dests[i].path) && dests[i].path.length > bestLen) {
        best = i;
        bestLen = dests[i].path.length;
      }
    }
    return best;
  }

  List<_NavDest> _destinationsFor(UserRole role) {
    final dashboard = const _NavDest(
        '/home', 'Dashboard', Icons.dashboard_outlined, Icons.dashboard);
    final community = const _NavDest(
        '/community', 'Community', Icons.forum_outlined, Icons.forum);

    if (role.isOfficialOrAdmin) {
      return [
        dashboard,
        community,
        const _NavDest(
            '/admin', 'Newsroom', Icons.gavel_outlined, Icons.gavel),
      ];
    }

    return [
      dashboard,
      const _NavDest(
          '/report', 'File Report', Icons.create_outlined, Icons.create),
      const _NavDest('/my-reports', 'My Desk', Icons.folder_open_outlined,
          Icons.folder),
      community,
    ];
  }
}

class _Masthead extends StatelessWidget {
  const _Masthead({required this.title, required this.eyebrow, required this.actions});

  final String title;
  final String? eyebrow;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: TereTheme.ink, width: 2),
        ),
        color: TereTheme.paper,
      ),
      padding: const EdgeInsets.fromLTRB(64, 28, 32, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (eyebrow ?? 'BANTAY BARANGAY · EDITION').toUpperCase(),
                  style: TereTheme.overline(size: 11, color: TereTheme.accent),
                ),
                const SizedBox(height: 8),
                Text(title, style: TereTheme.headline(size: 44)),
              ],
            ),
          ),
          if (actions != null && actions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}

class _EditorialSidebar extends StatelessWidget {
  const _EditorialSidebar({
    required this.user,
    required this.role,
    required this.destinations,
    required this.selectedIndex,
    required this.onSignOut,
  });

  final dynamic user; // AppUser? — kept dynamic to avoid the import on this slim widget.
  final UserRole role;
  final List<_NavDest> destinations;
  final int selectedIndex;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 268,
      decoration: const BoxDecoration(
        color: TereTheme.paper,
        border: Border(right: BorderSide(color: TereTheme.ink, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VOLUME I · ${DateTime.now().year}',
                    style: TereTheme.overline(size: 10, color: TereTheme.textSecondary)),
                const SizedBox(height: 8),
                Text('BANTAY\nBARANGAY',
                    style: TereTheme.display(size: 28).copyWith(height: 0.95)),
                Container(margin: const EdgeInsets.only(top: 6), height: 4, width: 64, color: TereTheme.accent),
                const SizedBox(height: 8),
                Text('The barangay bulletin.',
                    style: TereTheme.body(size: 13, color: TereTheme.textSecondary)),
              ],
            ),
          ),
          const Divider(height: 2, thickness: 2, color: TereTheme.ink),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
            child: Text('SECTIONS', style: TereTheme.overline(size: 11)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: destinations.length,
              itemBuilder: (context, i) {
                final d = destinations[i];
                final selected = i == selectedIndex;
                return _SidebarItem(
                  dest: d,
                  index: i + 1,
                  selected: selected,
                  onTap: () => context.go(d.path),
                );
              },
            ),
          ),
          const Divider(height: 2, thickness: 1, color: TereTheme.borderSubtle),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: TereTheme.ink,
                    shape: BoxShape.rectangle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (user?.displayName ?? 'R').toString().trim().isEmpty
                        ? 'R'
                        : (user!.displayName as String).trim()[0].toUpperCase(),
                    style: TereTheme.overline(size: 16, color: TereTheme.paper),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (user?.displayName ?? 'Resident').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TereTheme.body(size: 13, weight: FontWeight.w700),
                      ),
                      Text(
                        role.name.toUpperCase(),
                        style: TereTheme.overline(size: 10, color: TereTheme.accent),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Sign out',
                  icon: const Icon(Icons.logout, size: 18),
                  onPressed: onSignOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.dest,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final _NavDest dest;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final iconColor = selected ? TereTheme.paper : (_hover ? TereTheme.accent : TereTheme.ink);
    final textColor = selected ? TereTheme.paper : TereTheme.ink;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? TereTheme.ink : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: selected
                    ? TereTheme.accent
                    : (_hover ? TereTheme.accent : Colors.transparent),
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  widget.index.toString().padLeft(2, '0'),
                  style: TereTheme.overline(
                    size: 10,
                    color: selected ? TereTheme.paper : TereTheme.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(selected ? widget.dest.selectedIcon : widget.dest.icon,
                  size: 18, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.dest.label.toUpperCase(),
                  style: TereTheme.overline(size: 12, color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavDest {
  const _NavDest(this.path, this.label, this.icon, this.selectedIcon);
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

extension on Border {
  BoxDecoration toBoxDecoration() => BoxDecoration(border: this, color: TereTheme.paper);
}
