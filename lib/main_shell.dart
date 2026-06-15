import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/session.dart';
import 'theme/app_theme.dart';
import 'inicio_page.dart';
import 'search_page.dart';
import 'packages_page.dart';
import 'my_reservations_page.dart';
import 'community_page.dart';
import 'operators_page.dart';
import 'dashboard_page.dart';
import 'admin_page.dart';
import 'profile_page.dart';

/// Estructura principal con la barra de navegación superior del diseño Figma.
/// Las pestañas visibles dependen del MODO de la cuenta (Session.isAdmin):
///  - Administrador: ve las 8 pestañas.
///  - Viajero: NO ve Operadores, Dashboard ni Administración.
/// En pantallas anchas las pestañas van en fila; en angostas, en un menú
/// lateral (hamburguesa). El contenido se intercambia con IndexedStack.
class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  static const _items = <_NavItem>[
    _NavItem('Inicio', Icons.home_outlined),
    _NavItem('Buscar', Icons.search),
    _NavItem('Paquetes', Icons.inventory_2_outlined),
    _NavItem('Reservas', Icons.event_available_outlined),
    _NavItem('Comunidad', Icons.groups_outlined),
    _NavItem('Operadores', Icons.place_outlined),
    _NavItem('Dashboard', Icons.dashboard_outlined),
    _NavItem('Administración', Icons.settings_outlined),
  ];

  // Índices de pestañas que solo ve el administrador.
  static const _adminOnly = {5, 6, 7};

  @override
  void initState() {
    super.initState();
    _aplicarModoAdmin();
  }

  /// Determina el modo administrador desde el backend: la cuenta es admin solo
  /// si su correo está en la lista cableada (AuthService.adminEmails). Ya no se
  /// lee de un campo persistido que el usuario pudiera manipular.
  void _aplicarModoAdmin() {
    Session.setAdmin(AuthService().isCurrentUserAdmin);
  }

  /// Índices de pestañas visibles según el modo actual.
  List<int> get _visible => Session.isAdmin.value
      ? const [0, 1, 2, 3, 4, 5, 6, 7]
      : const [0, 1, 2, 3, 4];

  List<Widget> get _pages => [
        InicioPage(onNavigate: _go),
        const SearchPage(),
        const PackagesPage(),
        const MyReservationsPage(),
        const CommunityPage(),
        const OperatorsPage(),
        const DashboardPage(),
        const AdminPage(),
      ];

  void _go(int i) {
    setState(() => _index = i);
    if (Navigator.canPop(context)) {
      Navigator.maybePop(context); // cierra el drawer si está abierto
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se reconstruye cuando cambia el modo (admin/viajero).
    return ValueListenableBuilder<bool>(
      valueListenable: Session.isAdmin,
      builder: (context, isAdmin, _) {
        // Si el modo actual oculta la pestaña activa, vuelve a Inicio.
        if (!isAdmin && _adminOnly.contains(_index)) {
          _index = 0;
        }
        final wide = MediaQuery.of(context).size.width >= 1100;
        final visible = _visible;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0.5,
            titleSpacing: wide ? 0 : 8,
            // Encabezado centrado dentro de un ancho máximo (como el Figma).
            title: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: wide ? 24 : 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _index = 0),
                        child: const EcoSpotLogo(),
                      ),
                      if (wide) ...[
                        const SizedBox(width: 24),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final i in visible)
                                  _NavButton(
                                    item: _items[i],
                                    active: _index == i,
                                    onTap: () =>
                                        setState(() => _index = i),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ] else
                        const Spacer(),
                      _UserMenu(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          drawer: wide ? null : _buildDrawer(context, visible),
          body: IndexedStack(index: _index, children: _pages),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, List<int> visible) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: EcoSpotLogo(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final i in visible)
                    ListTile(
                      leading: Icon(_items[i].icon,
                          color: _index == i
                              ? AppColors.emerald700
                              : AppColors.mutedForeground),
                      title: Text(
                        _items[i].label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _index == i
                              ? AppColors.emerald700
                              : AppColors.foreground,
                        ),
                      ),
                      selected: _index == i,
                      selectedTileColor: AppColors.emerald50,
                      onTap: () {
                        setState(() => _index = i);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;
  const _NavButton(
      {required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: active ? AppColors.emerald50 : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(item.icon,
                    size: 16,
                    color: active
                        ? AppColors.emerald700
                        : AppColors.mutedForeground),
                const SizedBox(width: 6),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? AppColors.emerald700
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón/menú de usuario (avatar + Perfil + Cerrar sesión).
class _UserMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final base = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email ?? 'U');
    final inicial = base.substring(0, 1).toUpperCase();

    return PopupMenuButton<String>(
      tooltip: 'Cuenta',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (v) async {
        if (v == 'perfil') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfilePage()));
        } else if (v == 'logout') {
          Session.reset();
          await AuthService().logout();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'perfil',
          child: Row(
            children: const [
              Icon(Icons.person_outline,
                  size: 18, color: AppColors.emerald700),
              SizedBox(width: 10),
              Text('Mi Perfil'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, size: 18, color: AppColors.red600),
              SizedBox(width: 10),
              Text('Cerrar Sesión',
                  style: TextStyle(color: AppColors.red600)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.emerald50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.emerald200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.emerald600,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                inicial,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down,
                size: 18, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}
