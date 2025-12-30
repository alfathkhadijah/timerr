import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'timer_service.dart';
import 'models/app_theme.dart';
import 'models/app_character.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context);
    final theme = timerService.currentTheme;

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: theme.textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Personalize your focus space.',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙 ', style: TextStyle(fontSize: 14)),
                        Text(
                          '${timerService.coins}',
                          style: const TextStyle(
                            color: Color(0xFFB8860B),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          TabBar(
            labelColor: theme.textColor,
            unselectedLabelColor: theme.textColor.withOpacity(0.4),
            indicatorColor: theme.accent,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            tabs: const [
              Tab(text: 'Themes'),
              Tab(text: 'Characters'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _buildThemesGrid(context, timerService, theme),
                _buildCharactersGrid(context, timerService, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesGrid(BuildContext context, TimerService timerService, AppTheme theme) {
    final sortedThemes = List<AppTheme>.from(AppTheme.allThemes)
      ..sort((a, b) {
        final aUnlocked = timerService.unlockedThemeIds.contains(a.id);
        final bUnlocked = timerService.unlockedThemeIds.contains(b.id);
        if (aUnlocked != bUnlocked) return aUnlocked ? -1 : 1;
        return a.cost.compareTo(b.cost);
      });

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: sortedThemes.length,
      itemBuilder: (context, index) {
        final shopTheme = sortedThemes[index];
        final isUnlocked = timerService.unlockedThemeIds.contains(shopTheme.id);
        final isActive = timerService.activeThemeId == shopTheme.id;

        return _buildShopItem(
          context: context,
          name: shopTheme.name,
          cost: shopTheme.cost,
          isUnlocked: isUnlocked,
          isActive: isActive,
          onTap: () {
            if (isActive) return;
            if (isUnlocked) {
              timerService.setTheme(shopTheme.id);
            } else if (timerService.coins >= shopTheme.cost) {
              _showPurchaseDialog(
                context, 
                theme, 
                'Unlock ${shopTheme.name}?', 
                'This theme will give your app a fresh new look.',
                () => timerService.purchaseTheme(shopTheme),
              );
            } else {
              _showInsufficientCoins(context);
            }
          },
          previewWidget: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: shopTheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: isActive ? const Icon(Icons.check_circle, color: Colors.white, size: 30) : null,
          ),
          itemTheme: shopTheme,
        );
      },
    );
  }

  Widget _buildCharactersGrid(BuildContext context, TimerService timerService, AppTheme theme) {
    final sortedCharacters = List<AppCharacter>.from(AppCharacter.allCharacters)
      ..sort((a, b) {
        final aUnlocked = timerService.unlockedCharacterIds.contains(a.id);
        final bUnlocked = timerService.unlockedCharacterIds.contains(b.id);
        if (aUnlocked != bUnlocked) return aUnlocked ? -1 : 1;
        return a.cost.compareTo(b.cost);
      });

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: sortedCharacters.length,
      itemBuilder: (context, index) {
        final character = sortedCharacters[index];
        final isUnlocked = timerService.unlockedCharacterIds.contains(character.id);
        final isActive = timerService.activeCharacterId == character.id;

        return _buildShopItem(
          context: context,
          name: character.name,
          cost: character.cost,
          isUnlocked: isUnlocked,
          isActive: isActive,
          onTap: () {
            if (isActive) return;
            if (isUnlocked) {
              timerService.setCharacter(character.id);
            } else if (timerService.coins >= character.cost) {
              _showPurchaseDialog(
                context, 
                theme, 
                'Adopt ${character.name}?', 
                'This character will accompany you during focus sessions.',
                () => timerService.purchaseCharacter(character),
              );
            } else {
              _showInsufficientCoins(context);
            }
          },
          previewWidget: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: character.effectColor.withOpacity(0.1),
            ),
            child: Center(
              child: Text(character.icon, style: const TextStyle(fontSize: 40)),
            ),
          ),
          itemTheme: theme, // Use current theme for character cards
          customBg: character.effectColor.withOpacity(0.05),
        );
      },
    );
  }

  Widget _buildShopItem({
    required BuildContext context,
    required String name,
    required int cost,
    required bool isUnlocked,
    required bool isActive,
    required VoidCallback onTap,
    required Widget previewWidget,
    required AppTheme itemTheme,
    Color? customBg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: customBg ?? itemTheme.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isActive ? itemTheme.accent.withOpacity(0.15) : Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isActive ? itemTheme.accent.withOpacity(0.5) : Colors.white.withOpacity(0.8),
          width: isActive ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  previewWidget,
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: itemTheme.textColor,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? itemTheme.accent.withOpacity(0.1) : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'EQUIPPED' : 'USE',
                        style: TextStyle(
                          color: isActive ? itemTheme.accent : itemTheme.textColor.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙 ', style: TextStyle(fontSize: 10)),
                          Text(
                            '$cost',
                            style: const TextStyle(
                              color: Color(0xFFB8860B),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showInsufficientCoins(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Not enough coins! Keep focusing! 🪙'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, AppTheme theme, String title, String message, VoidCallback onPurchase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold)),
        content: Text(message, style: TextStyle(color: theme.textColor.withOpacity(0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: theme.textColor.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              onPurchase();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('PURCHASE'),
          ),
        ],
      ),
    );
  }
}
