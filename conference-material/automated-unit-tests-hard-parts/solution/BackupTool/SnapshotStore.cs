namespace BackupTool;

public sealed class SnapshotStore
{
    private readonly IRepository _repository;
    private readonly Crypto _crypto;

    public SnapshotStore(IRepository repository, Crypto crypto)
    {
        _repository = repository;
        _crypto = crypto;
    }

    public void Store(IBlobSystem blobSystem, DateTime utcNow)
    {
        var snapshotContent = new Dictionary<string, Blob>();

        foreach (var blob in blobSystem.List())
        {
            var blobEncrypted = _crypto.Encrypt(blobSystem.Read(blob));
            var blobChunkId = ChunkId.From(blobEncrypted);
            snapshotContent.Add(blobChunkId, blob);
            _repository.Write($"chunks/{blobChunkId}", blobEncrypted);
        }

        var snapshot = new Snapshot(snapshotContent, utcNow);
        var snapshotEncrypted = _crypto.Encrypt(Serializer.Serialize(snapshot));
        var snapshotChunkId = ChunkId.From(snapshotEncrypted);
        _repository.Write($"chunks/{snapshotChunkId}", snapshotEncrypted);

        var snapshotData = new SnapshotData(snapshotChunkId, _crypto.Salt, _crypto.Iterations);
        _repository.Write("backup", Serializer.Serialize(snapshotData));
    }

    public void Restore(IBlobSystem blobSystem)
    {
        var snapshotData = Serializer.Deserialize<SnapshotData>(
            _repository.Read("backup"));

        var snapshot = Serializer.Deserialize<Snapshot>(
            _crypto.Decrypt(
                _repository.Read($"chunks/{snapshotData.ChunkId}")));

        foreach (var (chunkId, blob) in snapshot.Blobs)
        {
            blobSystem.Write(
                blob,
                _crypto.Decrypt(
                    _repository.Read($"chunks/{chunkId}")));
        }
    }

    public bool Check()
    {
        var snapshotData = Serializer.Deserialize<SnapshotData>(
            _repository.Read("backup"));

        var snapshot = Serializer.Deserialize<Snapshot>(
            _crypto.Decrypt(
                _repository.Read($"chunks/{snapshotData.ChunkId}")));

        foreach (var chunkId in snapshot.Blobs.Keys)
        {
            var value = _repository.Read($"chunks/{chunkId}");
            var newChunkId = ChunkId.From(value);

            if (!chunkId.Equals(newChunkId))
            {
                return false;
            }
        }

        return true;
    }
}
