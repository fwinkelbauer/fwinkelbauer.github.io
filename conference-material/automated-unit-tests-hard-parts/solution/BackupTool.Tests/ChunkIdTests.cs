namespace BackupTool.Tests;

public sealed class ChunkIdTests
{
    [Fact]
    public void From_Returns_Hash_Of_Input()
    {
        Assert.Equal(
            "185F8DB32271FE25F561A6FC938B2E264306EC304EDA518007D1764826381969",
            ChunkId.From("Hello"u8));
    }

    [Fact]
    public void From_Returns_Same_Hash_For_Same_Input()
    {
        Assert.Equal(
            ChunkId.From("Hello"u8),
            ChunkId.From("Hello"u8));
    }

    [Fact]
    public void From_Returns_Different_Hash_For_Different_Input()
    {
        Assert.NotEqual(
            ChunkId.From("Hello"u8),
            ChunkId.From("World"u8));
    }
}
