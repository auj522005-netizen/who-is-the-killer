import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../core/utils/game_utils.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/clue.dart';
import '../providers/game_state.dart' as gs;
import '../providers/game_controller.dart';
import '../widgets/player_card.dart';
import '../widgets/clue_card.dart';
import '../widgets/voting_panel.dart';
import '../widgets/timer_display.dart';
import '../widgets/ghost_indicator.dart';

/// ────────────────────────────────────────────────────────────────
/// GameRoomScreen — Main responsive game UI
///
/// This is the primary game screen that updates adaptively based
/// on the player's current state (Alive vs. Ghost) and the
/// current game phase (Discussion, Voting, Final Showdown, etc.).
///
/// Design System: "Structured Rebellion"
/// - Solid pitch-black backgrounds
/// - Neon orange/green accent colors
/// - Bold, heavy typography
/// - Swiss-style minimalist layout
/// ────────────────────────────────────────────────────────────────
class GameRoomScreen extends ConsumerStatefulWidget {
  final String roomId;

  const GameRoomScreen({required this.roomId, super.key});

  @override
  ConsumerState<GameRoomScreen> createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends ConsumerState<GameRoomScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize game state by fetching room data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameControllerProvider.notifier).startGame(widget.roomId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final currentPlayerId = ref.watch(currentPlayerIdProvider);
    final currentPlayer = gameState.getPlayerById(currentPlayerId);
    final isAlive = currentPlayer?.isAlive ?? true;
    final isGhost = currentPlayer?.isGhost ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildBody(context, gameState, isAlive, isGhost, currentPlayer),
      ),
    );
  }

  /// Builds the main body based on the current game phase and player state
  Widget _buildBody(
    BuildContext context,
    gs.GameState gameState,
    bool isAlive,
    bool isGhost,
    Player? currentPlayer,
  ) {
    return CustomScrollView(
      slivers: [
        // ── Header: Room info + Phase indicator ────────────────
        _buildHeader(gameState),

        // ── Phase-specific content ─────────────────────────────
        switch (gameState.currentPhase) {
          gs.GamePhase.roleReveal => _buildRoleReveal(currentPlayer),
          gs.GamePhase.discussion => _buildDiscussionPhase(gameState, isAlive, isGhost),
          gs.GamePhase.clueReveal => _buildClueRevealPhase(gameState),
          gs.GamePhase.voting => _buildVotingPhase(gameState, isAlive, isGhost),
          gs.GamePhase.eliminationReveal => _buildEliminationReveal(gameState),
          gs.GamePhase.finalShowdown => _buildFinalShowdown(gameState, isAlive),
          gs.GamePhase.ghostVoting => _buildGhostVotingPhase(gameState, isGhost),
          gs.GamePhase.verdict => _buildVerdict(gameState),
          _ => _buildWaitingState(),
        },
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════

  Widget _buildHeader(gs.GameState gameState) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Room code
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الغرفة',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  gameState.room?.code ?? '------',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.neonOrange,
                        fontFamily: 'monospace',
                        letterSpacing: 3,
                      ),
                ),
              ],
            ),

            // Round indicator
            Column(
              children: [
                Text(
                  'الجولة',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${gameState.currentRoundNumber}/${gameState.totalRounds}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.neonGreen,
                      ),
                ),
              ],
            ),

            // Alive count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'الأحياء',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      FontAwesomeIcons.user,
                      size: 14,
                      color: AppColors.neonGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${gameState.aliveCount}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.neonGreen,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ROLE REVEAL PHASE
  // ══════════════════════════════════════════════════════════════

  Widget _buildRoleReveal(Player? currentPlayer) {
    if (currentPlayer == null) {
      return _buildWaitingState();
    }

    final isMafioso = currentPlayer.isMafioso;

    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Role icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMafioso ? AppColors.mafiosoRed : AppColors.neonGreen,
                boxShadow: [
                  BoxShadow(
                    color: (isMafioso ? AppColors.mafiosoRed : AppColors.neonGreen)
                        .withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                isMafioso ? FontAwesomeIcons.skull : FontAwesomeIcons.shieldHalved,
                size: 48,
                color: AppColors.textOnAccent,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // Role title
            Text(
              isMafioso ? 'أنت المافيوسو' : 'أنت بريء',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: isMafioso ? AppColors.neonRed : AppColors.neonGreen,
                  ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 16),

            // Character name
            Text(
              currentPlayer.characterName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.neonOrange,
                  ),
            ),

            const SizedBox(height: 24),

            // Alibi card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.comment,
                        size: 14,
                        color: AppColors.neonOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الحجة المعلنة',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentPlayer.alibi,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Secrets card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                border: Border.all(
                  color: isMafioso ? AppColors.neonRed : AppColors.neonGreen,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.eyeSlash,
                        size: 14,
                        color: isMafioso ? AppColors.neonRed : AppColors.neonGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الأسرار المخفية',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: isMafioso ? AppColors.neonRed : AppColors.neonGreen,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentPlayer.secrets,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Proceed button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(gameControllerProvider.notifier).proceedToFirstRound();
                },
                child: const Text('ابدأ اللعبة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // DISCUSSION PHASE
  // ══════════════════════════════════════════════════════════════

  Widget _buildDiscussionPhase(gs.GameState gameState, bool isAlive, bool isGhost) {
    return SliverFillRemaining(
      child: Column(
        children: [
          // Timer
          TimerDisplay(
            seconds: gameState.phaseTimerSeconds,
            label: 'مناقشة',
          ),

          const SizedBox(height: 8),

          // Phase banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.neonOrange.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.comments,
                  color: AppColors.neonOrange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isGhost ? '👁 مرحلة المناقشة (مراقب)' : 'مرحلة المناقشة',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Previously revealed clues
          if (gameState.revealedClues.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الأدلة المكتشفة',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  ...gameState.revealedClues.map(
                    (clue) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClueCard(clue: clue, isRevealed: true),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Player list
          Expanded(
            child: _buildPlayerList(gameState, isAlive, isGhost),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // CLUE REVEAL PHASE
  // ══════════════════════════════════════════════════════════════

  Widget _buildClueRevealPhase(gs.GameState gameState) {
    final clue = gameState.currentRoundClue;
    if (clue == null) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.neonOrange),
        ),
      );
    }

    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Clue reveal header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.neonOrange,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                'دليل الجولة ${gameState.currentRoundNumber}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.2, end: 0),

            const SizedBox(height: 24),

            // Clue card with animation
            ClueCard(clue: clue, isRevealed: true)
                .animate()
                .fadeIn(delay: 500.ms, duration: 800.ms)
                .scale(delay: 500.ms, duration: 600.ms, begin: const Offset(0.8, 0.8)),

            if (clue.isDecisive) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.neonRed.withOpacity(0.15),
                  border: Border.all(color: AppColors.neonRed),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      FontAwesomeIcons.triangleExclamation,
                      color: AppColors.neonRed,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'دليل حاسم!',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.neonRed,
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

  // ══════════════════════════════════════════════════════════════
  // VOTING PHASE
  // ══════════════════════════════════════════════════════════════

  Widget _buildVotingPhase(gs.GameState gameState, bool isAlive, bool isGhost) {
    return SliverFillRemaining(
      child: Column(
        children: [
          // Timer
          TimerDisplay(
            seconds: gameState.phaseTimerSeconds,
            label: 'التصويت',
          ),

          const SizedBox(height: 8),

          // Phase banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.neonRed.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.checkToSlot,
                  color: AppColors.neonRed,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'مرحلة التصويت',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.neonRed,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Voting panel (only alive players can vote)
          if (isAlive)
            Expanded(
              child: VotingPanel(
                players: gameState.alivePlayers,
                onVote: (targetId) {
                  ref.read(gameControllerProvider.notifier).vote(targetId);
                },
                currentVotes: gameState.currentRoundVotes,
              ),
            )
          else
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GhostIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'أنت مراقب — لا يمكنك التصويت',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ELIMINATION REVEAL PHASE
  // ══════════════════════════════════════════════════════════════

  Widget _buildEliminationReveal(gs.GameState gameState) {
    final eliminated = gameState.eliminatedThisRound;

    if (eliminated == null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.scaleBalanced,
                size: 48,
                color: AppColors.neonYellow,
              ),
              const SizedBox(height: 16),
              Text(
                'تعادل في الأصوات — لا إقصاء',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(gameControllerProvider.notifier).advancePhase();
                },
                child: const Text('الجولة التالية'),
              ),
            ],
          ),
        ),
      );
    }

    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Eliminated icon
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonRed,
              ),
              child: const Icon(
                FontAwesomeIcons.xmark,
                size: 40,
                color: AppColors.textOnAccent,
              ),
            )
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 300.ms),

            const SizedBox(height: 24),

            Text(
              'تم الإقصاء!',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.neonRed,
                  ),
            ),

            const SizedBox(height: 16),

            // Eliminated player info
            Text(
              eliminated.characterName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.neonOrange,
                  ),
            ),

            const SizedBox(height: 8),

            // Role reveal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: eliminated.isMafioso
                    ? AppColors.mafiosoRed
                    : AppColors.neonGreen.withOpacity(0.15),
                border: Border.all(
                  color: eliminated.isMafioso
                      ? AppColors.mafiosoRed
                      : AppColors.neonGreen,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                eliminated.isMafioso ? '🛑 مافيوسو' : '😇 بريء',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: eliminated.isMafioso
                          ? AppColors.textPrimary
                          : AppColors.neonGreen,
                    ),
              ),
            ),

            const SizedBox(height: 32),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(gameControllerProvider.notifier).advancePhase();
                },
                child: const Text('متابعة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // FINAL SHOWDOWN PHASE
  // ══════════════════════════════════════════════════════════════

  Widget _buildFinalShowdown(gs.GameState gameState, bool isAlive) {
    final survivors = gameState.alivePlayers;
    final currentDefender = gameState.currentDefender;

    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Final Showdown banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neonRed.withOpacity(0.1),
                border: Border.all(color: AppColors.neonRed, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  const Icon(
                    FontAwesomeIcons.skullCrossbones,
                    color: AppColors.neonRed,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'المواجهة الأخيرة',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.neonRed,
                        ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .shimmer(duration: 2000.ms, color: AppColors.neonRed.withOpacity(0.3)),

            const SizedBox(height: 24),

            // Survivors
            Text(
              'الناجون (${survivors.length})',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 12),

            ...survivors.map(
              (player) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PlayerCard(
                  player: player,
                  isCurrentDefender: player.id == currentDefender?.id,
                  showRole: false,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Defense token timer
            if (currentDefender != null && isAlive) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.neonOrange.withOpacity(0.1),
                  border: Border.all(color: AppColors.neonOrange),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Text(
                      'دورة الدفاع: ${currentDefender.characterName}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      GameUtils.formatDuration(gameState.defenseTokenSecondsRemaining),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: AppColors.neonOrange,
                            fontFamily: 'monospace',
                          ),
                    ),
                  ],
                ),
              ),
            ],

            // Ghost observer notice
            if (!isAlive) ...[
              const SizedBox(height: 16),
              const GhostIndicator(),
              const SizedBox(height: 8),
              Text(
                'أنت مراقب — الدردشة مقفلة',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // GHOST VOTING PHASE
  // ══════════════════════════════════════════════════════════════

  Widget _buildGhostVotingPhase(gs.GameState gameState, bool isGhost) {
    return SliverFillRemaining(
      child: Column(
        children: [
          // Timer
          TimerDisplay(
            seconds: gameState.phaseTimerSeconds,
            label: 'تصويت الأشباح',
          ),

          const SizedBox(height: 8),

          // Phase banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.ghostCyan.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.ghost,
                  color: AppColors.ghostCyan,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'تصويت الأشباح — القرار الحاسم',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.ghostCyan,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Both ghosts and survivors vote
          Expanded(
            child: VotingPanel(
              players: gameState.alivePlayers,
              onVote: (targetId) {
                ref.read(gameControllerProvider.notifier).vote(targetId);
              },
              currentVotes: gameState.ghostVotes,
              isGhostVoting: true,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // VERDICT PHASE
  // ══════════════════════════════════════════════════════════════

  Widget _buildVerdict(gs.GameState gameState) {
    final mafiosoIdentified = gameState.mafiosoIdentified ?? false;
    final mafiosi = gameState.players.where((p) => p.isMafioso).toList();

    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Result icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mafiosoIdentified ? AppColors.neonGreen : AppColors.neonRed,
              ),
              child: Icon(
                mafiosoIdentified
                    ? FontAwesomeIcons.trophy
                    : FontAwesomeIcons.skull,
                size: 48,
                color: AppColors.textOnAccent,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            Text(
              mafiosoIdentified ? 'تم كشف المافيوسو!' : 'المافيوسو انتصر!',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: mafiosoIdentified ? AppColors.neonGreen : AppColors.neonRed,
                  ),
            ),

            const SizedBox(height: 24),

            // Mafioso reveal
            ...mafiosi.map(
              (mafioso) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mafiosoRed.withOpacity(0.15),
                  border: Border.all(color: AppColors.mafiosoRed),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.skull,
                      color: AppColors.neonRed,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mafioso.characterName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.neonRed,
                                ),
                          ),
                          Text(
                            mafioso.role == PlayerRole.mafiosoMain
                                ? 'القاتل الرئيسي'
                                : 'الشريك',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Verdict text
            if (gameState.verdictText != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.gavel,
                          size: 14,
                          color: AppColors.neonOrange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'الحكم النهائي',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      gameState.verdictText!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PLAYER LIST WIDGET
  // ══════════════════════════════════════════════════════════════

  Widget _buildPlayerList(gs.GameState gameState, bool isAlive, bool isGhost) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: gameState.players.length,
      itemBuilder: (context, index) {
        final player = gameState.players[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PlayerCard(
            player: player,
            showRole: isGhost, // Ghosts can see eliminated player roles
            isCurrentUser: player.id == ref.read(currentPlayerIdProvider),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // WAITING STATE
  // ══════════════════════════════════════════════════════════════

  Widget _buildWaitingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.neonOrange),
            const SizedBox(height: 16),
            Text(
              'جارٍ التحميل...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
