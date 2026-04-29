import 'package:flutter/material.dart';

class AppMenuItem {
  const AppMenuItem(
    this.icon,
    this.label, {
    this.active = false,
    this.count,
    this.countColor,
    this.section,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final String? count;
  final Color? countColor;
  final String? section;
  final VoidCallback? onTap;
}

class AppMenu extends StatelessWidget {
  const AppMenu({
    super.key,
    required this.items,
    this.userName = 'อรรถกร กิติ',
    this.userRole = 'Admin',
    this.userFaculty,
    this.userInitials = 'AK',
    this.closeOnTap = false,
    this.onLogout,
  });

  final List<AppMenuItem> items;
  final String userName;
  final String userRole;
  final String? userFaculty;
  final String userInitials;
  final bool closeOnTap;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    String? currentSection;

    return Container(
      color: const Color(0xFFF8F5EE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'College News Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  'ระบบประกาศข่าวมหาวิทยาลัย',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Color(0xFF5E5A50)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE1D8C8)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: Row(
              children: <Widget>[
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8D2FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    userInitials,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4E49B7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'ชื่อ: $userName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'สถานะ: $userRole',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF555147),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (userFaculty != null) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          'คณะที่เรียน: $userFaculty',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6E6A61),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE1D8C8)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
              children: items.map((AppMenuItem item) {
                final List<Widget> sectionWidgets = <Widget>[];

                if (item.section != null && item.section != currentSection) {
                  currentSection = item.section;
                  sectionWidgets.add(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Text(
                        item.section!,
                        style: const TextStyle(
                          color: Color(0xFF726D62),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }

                sectionWidgets.add(
                  _AppMenuTile(item: item, closeOnTap: closeOnTap),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sectionWidgets,
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE1D8C8)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: ListTile(
              dense: true,
              minLeadingWidth: 28,
              leading: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFC74A47),
              ),
              title: const Text(
                'ออกจากระบบ',
                style: TextStyle(
                  color: Color(0xFFC74A47),
                  fontWeight: FontWeight.w700,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onTap: () {
                if (closeOnTap) {
                  Navigator.of(context).maybePop();
                }
                onLogout?.call();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppMenuTile extends StatelessWidget {
  const _AppMenuTile({required this.item, required this.closeOnTap});

  final AppMenuItem item;
  final bool closeOnTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = item.active
        ? const Color(0xFF4E49B7)
        : const Color(0xFF4D4940);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: item.active ? const Color(0xFFE5E3FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        dense: true,
        minLeadingWidth: 28,
        leading: Icon(item.icon, color: foreground),
        title: Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: item.active ? FontWeight.w700 : FontWeight.w600,
            color: foreground,
          ),
        ),
        trailing: item.count == null
            ? null
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: item.countColor ?? const Color(0xFFD9D1FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.count!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF443F9D),
                  ),
                ),
              ),
        onTap: () {
          if (closeOnTap) {
            Navigator.of(context).maybePop();
          }
          item.onTap?.call();
        },
      ),
    );
  }
}
