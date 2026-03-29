namespace BackupTool;

public sealed record Blob(string Name, DateTime LastWriteTimeUtc);
public sealed record Snapshot(IReadOnlyDictionary<string, Blob> Blobs, DateTime CreationTimeUtc);
public sealed record SnapshotData(string ChunkId, string Salt, int Iterations);

public static class Program
{
    public static void Main()
    {
        var source = @"???";
        var repository = @"???";

        CreateSnapshot(source, repository);
    }

    private static void CreateSnapshot(string source, string repository)
    {
        var chunks = Path.Combine(repository, "chunks");
        var crypto = new Crypto(Prompt.NewPassword());
        var snapshotContent = new Dictionary<string, Blob>();

        foreach (var file in Directory.GetFiles(source, "*", SearchOption.AllDirectories))
        {
            var blob = new Blob(
                Path.GetRelativePath(source, file),
                File.GetLastWriteTimeUtc(file));

            var blobEncrypted = crypto.Encrypt(File.ReadAllBytes(file));
            var blobChunkId = ChunkId.From(blobEncrypted);
            var blobStored = Path.Combine(chunks, blobChunkId);

            PathUtils.EnsureParent(blobStored);
            File.WriteAllBytes(blobStored, blobEncrypted);

            snapshotContent.Add(blobChunkId, blob);
        }

        var snapshot = new Snapshot(snapshotContent, DateTime.UtcNow);
        var snapshotEncrypted = crypto.Encrypt(Encoding.UTF8.GetBytes(JsonSerializer.Serialize(snapshot)));
        var snapshotChunkId = ChunkId.From(snapshotEncrypted);
        var snapshotStored = Path.Combine(chunks, snapshotChunkId);

        PathUtils.EnsureParent(snapshotStored);
        File.WriteAllBytes(snapshotStored, snapshotEncrypted);

        var snapshotData = new SnapshotData(snapshotChunkId, crypto.Salt, crypto.Iterations);
        File.WriteAllBytes(Path.Combine(repository, "backup"), Encoding.UTF8.GetBytes(JsonSerializer.Serialize(snapshotData)));
    }
}
