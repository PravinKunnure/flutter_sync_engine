abstract class ConflictResolver {
  Map<String, dynamic> resolve({
    required Map<String, dynamic> local,
    required Map<String, dynamic> remote,
  });
}

class LastWriteWins implements ConflictResolver {
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
