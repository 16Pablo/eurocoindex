import 'package:material_ui/material_ui.dart';

import '../utils/adaptive_layout.dart';
import '../widgets/eurocoindex_wordmark.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = AdaptiveLayout.of(context);
    final useRail = layout.useNavigationRail;

    final pageView = MediaQuery.removePadding(
      context: context,
      removeLeft: useRail,
      child: PageView(
        controller: _pageController,
        physics: useRail ? const NeverScrollableScrollPhysics() : null,
        onPageChanged: (index) {
          if (index != _currentIndex) {
            setState(() => _currentIndex = index);
          }
        },
        children: [
          for (final screen in _screens) _KeepAlivePage(child: screen),
        ],
      ),
    );

    return Scaffold(
      body: Row(
        children: [
          if (useRail) ...[
            _buildNavigationRail(context, layout),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ],
          Expanded(child: pageView),
        ],
      ),
      bottomNavigationBar: useRail ? null : _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (i) {
        if (i != _currentIndex) {
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search),
          label: 'Buscar',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Estadísticas',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Ajustes',
        ),
      ],
    );
  }

  Widget _buildNavigationRail(BuildContext context, AdaptiveLayout layout) {
    final extended = layout.useExtendedRail;

    return NavigationRail(
      extended: extended,
      scrollable: true,
      selectedIndex: _currentIndex,
      groupAlignment: layout.isShortHeight ? 0.0 : -0.85,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      leading: layout.isShortHeight
          ? null
          : Padding(
              padding: EdgeInsets.fromLTRB(
                extended ? 16 : 0,
                12,
                extended ? 16 : 0,
                16,
              ),
              child: extended
                  ? ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 224),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: EuroCoinDexWordmark(
                          fontSize: 24,
                          wordGap: 2.5,
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/icons/icon.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
            ),
      onDestinationSelected: (i) {
        if (i != _currentIndex) {
          _pageController.jumpToPage(i);
        }
      },
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Inicio'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search),
          label: Text('Buscar'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: Text('Estadísticas'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Ajustes'),
        ),
      ],
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});

  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin<_KeepAlivePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
