abstract class ConflictResolver {
  Map<String, dynamic> resolve({
    required Map<String, dynamic> local,
    required Map<String, dynamic> remote,
  });
}

class LastWriteWins implements ConflictResolver {
  @override
  Map<String, dynamic> resolve({
    required Map<String, dynamic> local,
    required Map<String, dynamic> remote,
  }) {
    // If local is empty, just return remote
    if (local.isEmpty) return remote;

    final localUpdatedStr = local['updatedAt'] as String?;
    final remoteUpdatedStr = remote['updatedAt'] as String?;

    final localUpdated = localUpdatedStr != null
        ? DateTime.parse(localUpdatedStr)
        : DateTime.fromMillisecondsSinceEpoch(0);
    final remoteUpdated = remoteUpdatedStr != null
        ? DateTime.parse(remoteUpdatedStr)
        : DateTime.fromMillisecondsSinceEpoch(0);

    return localUpdated.isAfter(remoteUpdated) ? local : remote;
  }
}
