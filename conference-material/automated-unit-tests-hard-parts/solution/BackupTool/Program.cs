namespace BackupTool;

public sealed record Blob(string Name, DateTime LastWriteTimeUtc);
public sealed record Snapshot(IReadOnlyDictionary<string, Blob> Blobs, DateTime CreationTimeUtc);
public sealed record SnapshotData(string ChunkId, string Salt, int Iterations);

public static class Program
{
    public static void Main()
    {
        var repository = new DryRunRepository(
            new FileRepository(@"???"));

        var crypto = new Crypto(Prompt.NewPassword());

        var blobSystem = new DryRunBlobSystem(
            new LoggingBlobSystem(
                new FileBlobSystem(@"???")));

        new SnapshotStore(repository, crypto)
            .Store(blobSystem, DateTime.UtcNow);
    }
}
