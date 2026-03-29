namespace BackupTool;

public static class Serializer
{
    private static readonly JsonSerializerOptions Options = new()
    {
        WriteIndented = true
    };

    public static byte[] Serialize(object obj)
    {
        return JsonSerializer.SerializeToUtf8Bytes(obj, Options);
    }

    public static T Deserialize<T>(byte[] json)
    {
        return JsonSerializer.Deserialize<T>(json)!;
    }
}
