import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../providers/game_controller.dart';
import 'game_room_screen.dart';

/// ────────────────────────────────────────────────────────────────
/// LobbyScreen — Pre-game lobby for creating or joining rooms
///
/// Players can either create a new game room (selecting a case)
/// or join an existing room using a code. Displays available
/// murder cases and validates player count constraints.
/// ────────────────────────────────────────────────────────────────
class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  final _roomCodeController = TextEditingController();
  final _playerNameController = TextEditingController();
  String? _selectedCaseId;
  bool _isCreating = false;

  @override
  void dispose() {
    _roomCodeController.dispose();
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('من هو القاتل؟'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title Section ─────────────────────────────────
            Center(
              child: Column(
                children: [
                  const Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 48,
                    color: AppColors.neonOrange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'من هو القاتل؟',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.neonOrange,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لعبة غموض تفاعلية متعددة اللاعبين',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── Player Name ───────────────────────────────────
            Text(
              'اسم اللاعب',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _playerNameController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'أدخل اسمك...',
                hintStyle: Theme.of(context).textTheme.bodySmall,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.neonOrange),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Create Room Section ───────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.plus,
                        size: 16,
                        color: AppColors.neonOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'إنشاء غرفة جديدة',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.neonOrange,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Case selection
                  Text(
                    'اختر القضية',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),

                  _buildCaseOption('case_1', 'كره أعمى', 'جريمة شقة فيصل'),
                  _buildCaseOption('case_2', 'مباراة القمة', 'تخطيط ذكي جداً'),
                  _buildCaseOption('case_3', 'الورث', 'الحقيقة أبشع من الخيال'),
                  _buildCaseOption('case_7', 'تحت الأظافر', 'ملفات الطب الشرعي'),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCreating || _selectedCaseId == null
                          ? null
                          : _handleCreateRoom,
                      child: _isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOnAccent,
                              ),
                            )
                          : const Text('إنشاء الغرفة'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Join Room Section ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.doorOpen,
                        size: 16,
                        color: AppColors.neonGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الانضمام لغرفة',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.neonGreen,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _roomCodeController,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFamily: 'monospace',
                          letterSpacing: 3,
                        ),
                    textAlign: TextAlign.center,
                    maxLength: GameConstants.roomCodeLength,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'كود الغرفة',
                      hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            letterSpacing: 3,
                          ),
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.neonGreen),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _handleJoinRoom,
                      child: const Text('انضمام'),
                    ),
                  ),
                ],
              ),
            ),

            // ── Error Display ─────────────────────────────────
            if (gameState.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neonRed.withOpacity(0.1),
                  border: Border.all(color: AppColors.neonRed),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.neonRed,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        gameState.errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.neonRed,
                            ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(gameControllerProvider.notifier).clearError();
                      },
                      child: const Icon(
                        Icons.close,
                        color: AppColors.neonRed,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCaseOption(String caseId, String title, String subtitle) {
    final isSelected = _selectedCaseId == caseId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCaseId = caseId;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonOrange.withOpacity(0.1)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.neonOrange : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.neonOrange : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.neonOrange : AppColors.textDisabled,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: AppColors.textOnAccent)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isSelected ? AppColors.neonOrange : AppColors.textPrimary,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateRoom() async {
    if (_playerNameController.text.trim().isEmpty) {
      ref.read(gameControllerProvider.notifier).clearError();
      // In production, show a validation error
      return;
    }

    setState(() => _isCreating = true);

    final controller = ref.read(gameControllerProvider.notifier);
    await controller.createRoom(
      name: 'غرفة ${_playerNameController.text}',
      hostPlayerId: 'player_${DateTime.now().millisecondsSinceEpoch}',
      caseId: _selectedCaseId!,
    );

    if (mounted) {
      setState(() => _isCreating = false);

      final gameState = ref.read(gameControllerProvider);
      if (gameState.room != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GameRoomScreen(roomId: gameState.room!.id),
          ),
        );
      }
    }
  }

  Future<void> _handleJoinRoom() async {
    if (_roomCodeController.text.trim().isEmpty) return;

    final controller = ref.read(gameControllerProvider.notifier);
    await controller.joinRoom(
      code: _roomCodeController.text.trim().toUpperCase(),
      playerId: 'player_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (mounted) {
      final gameState = ref.read(gameControllerProvider);
      if (gameState.room != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GameRoomScreen(roomId: gameState.room!.id),
          ),
        );
      }
    }
  }
}
