namespace BackupTool.Tests;

public static class SerializerTests
{
    private static readonly DateTime Date = new(2025, 1, 2, 3, 4, 5);

    private static readonly Snapshot Snapshot = new(
        new Dictionary<string, Blob>
        {
            { "ad95131bc0b799c0b1af477fb14fcf26a6a9f76079e48bf090acb7e8367bfd0e", new("some blob", Date) }
        },
        Date);

    [Fact]
    public static void Serialize_Can_Convert_Snapshot()
    {
        var expected = Snapshot;

        var actual = Serializer.Deserialize<Snapshot>(
            Serializer.Serialize(expected));

        Assert.Equal(expected.Blobs, actual.Blobs);
        Assert.Equal(expected.CreationTimeUtc, actual.CreationTimeUtc);
    }

    [Fact]
    public static Task Serialize_Respects_Serialized_Snapshot()
    {
        var json = Encoding.UTF8.GetString(
            Serializer.Serialize(Snapshot));

        return Verify(json);
    }
}
