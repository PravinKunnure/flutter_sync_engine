/// Defines a strategy for resolving conflicts between
/// local and remote versions of the same entity.
///
/// Implementations of this class determine how data is merged
/// when both local and remote changes exist.
abstract class ConflictResolver {
  /// Resolves a conflict between a local and remote entity.
  ///
  /// The [local] map represents the currently stored local data.
  /// The [remote] map represents the incoming data from the server.
  ///
  /// Implementations must return the final resolved entity
  /// that should be persisted locally.
  Map<String, dynamic> resolve({
    required Map<String, dynamic> local,
    required Map<String, dynamic> remote,
  });
}

/// A conflict resolution strategy where the most recently
/// updated entity always wins.
///
/// This resolver compares the `updatedAt` timestamp field
/// on both entities and returns whichever one is newer.
/// If the local entity does not exist, the remote entity
/// is returned.
class LastWriteWins implements ConflictResolver {
  /// Creates a [LastWriteWins] conflict resolver.
  const LastWriteWins();

  @override
  Map<String, dynamic> resolve({
    required Map<String, dynamic> local,
    required Map<String, dynamic> remote,
  }) {
    if (local.isEmpty) return remote;

    final localUpdated = local['updatedAt'] != null
        ? DateTime.parse(local['updatedAt'])
        : DateTime.fromMillisecondsSinceEpoch(0);

    final remoteUpdated = remote['updatedAt'] != null
        ? DateTime.parse(remote['updatedAt'])
        : DateTime.fromMillisecondsSinceEpoch(0);

    return localUpdated.isAfter(remoteUpdated) ? local : remote;
  }
}

///Without Docs
// abstract class ConflictResolver {
//   Map<String, dynamic> resolve({
//     required Map<String, dynamic> local,
//     required Map<String, dynamic> remote,
//   });
// }
//
// class LastWriteWins implements ConflictResolver {
//   const LastWriteWins();
//
//   @override
//   Map<String, dynamic> resolve({
//     required Map<String, dynamic> local,
//     required Map<String, dynamic> remote,
//   }) {
//     if (local.isEmpty) return remote;
//
//     final localUpdated = local['updatedAt'] != null
//         ? DateTime.parse(local['updatedAt'])
//         : DateTime.fromMillisecondsSinceEpoch(0);
//     final remoteUpdated = remote['updatedAt'] != null
//         ? DateTime.parse(remote['updatedAt'])
//         : DateTime.fromMillisecondsSinceEpoch(0);
//
//     return localUpdated.isAfter(remoteUpdated) ? local : remote;
//   }
// }
