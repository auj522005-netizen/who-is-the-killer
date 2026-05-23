import '../../domain/entities/player.dart';

/// ────────────────────────────────────────────────────────────────
/// RealtimeDatasource — Abstract interface for real-time sync
///
/// Defines the clean data-contract interface for WebSocket /
/// Supabase Realtime Broadcast listeners to synchronize:
/// - Room state
/// - Active players list
/// - Current round index
/// - Timer countdown
/// - Voting arrays
///
/// This abstraction allows swapping between Supabase Realtime,
/// raw WebSockets, or any other real-time transport without
/// affecting the domain or presentation layers.
/// ────────────────────────────────────────────────────────────────
abstract class RealtimeDatasource {
  /// Connects to the real-time channel for a specific room.
  /// Must be called before any subscribe/publish operations.
  Future<void> connect(String roomId);

  /// Disconnects from the real-time channel and cleans up resources.
  Future<void> disconnect();

  // ── Room State Sync ──────────────────────────────────────────

  /// Stream of room state updates (phase, round, timer, etc.)
  Stream<Map<String, dynamic>> watchRoomState();

  /// Broadcasts the current room state to all connected clients.
  Future<void> broadcastRoomState(Map<String, dynamic> state);

  // ── Player Sync ──────────────────────────────────────────────

  /// Stream of player list updates (joins, leaves, eliminations).
  Stream<List<Map<String, dynamic>>> watchPlayers();

  /// Broadcasts a player update event.
  Future<void> broadcastPlayerUpdate(Map<String, dynamic> playerData);

  // ── Voting Sync ──────────────────────────────────────────────

  /// Stream of vote updates in real-time.
  Stream<List<Map<String, dynamic>>> watchVotes();

  /// Broadcasts a new vote event.
  Future<void> broadcastVote(Map<String, dynamic> voteData);

  // ── Chat Sync ────────────────────────────────────────────────

  /// Stream of chat messages.
  Stream<Map<String, dynamic>> watchChatMessages();

  /// Broadcasts a chat message.
  Future<void> broadcastChatMessage(Map<String, dynamic> messageData);

  // ── Presence ─────────────────────────────────────────────────

  /// Tracks the presence (online/offline) of players.
  Future<void> trackPresence(String playerId, Map<String, dynamic> metadata);

  /// Stream of presence state changes.
  Stream<Map<String, PlayerState>> watchPresence();

  // ── Connection State ─────────────────────────────────────────

  /// Whether the datasource is currently connected.
  bool get isConnected;

  /// Stream of connection state changes.
  Stream<bool> watchConnectionState();
}
