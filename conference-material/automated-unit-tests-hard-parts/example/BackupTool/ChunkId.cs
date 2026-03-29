namespace BackupTool;

public static class ChunkId
{
    public static string From(ReadOnlySpan<byte> chunk)
    {
        return Convert.ToHexString(SHA256.HashData(chunk));
    }
}
