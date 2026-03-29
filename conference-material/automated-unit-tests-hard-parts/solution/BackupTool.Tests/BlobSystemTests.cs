namespace BackupTool.Tests;

public sealed class MemoryBlobSystemTests : BlobSystemTests
{
    public MemoryBlobSystemTests()
        : base(new MemoryBlobSystem())
    {
    }
}

public sealed class FileBlobSystemTests : BlobSystemTests
{
    public FileBlobSystemTests()
        : base(new FileBlobSystem(Some.Directory()))
    {
    }
}

public abstract class BlobSystemTests
{
    protected BlobSystemTests(IBlobSystem blobSystem)
    {
        BlobSystem = blobSystem;
    }

    protected IBlobSystem BlobSystem { get; }

    [Fact]
    public void BlobSystem_Can_Read_Write()
    {
        var blob = Some.Blob("some blob");
        var expected = new byte[] { 0x12, 0x34 };

        BlobSystem.Write(blob, expected);

        Assert.Equal(new[] { blob }, BlobSystem.List());
        Assert.Equal(expected, BlobSystem.Read(blob));
    }

    [Fact]
    public void OpenWrite_Overwrites_Previous_Content()
    {
        var blob = Some.Blob("some blob");
        var expected = new byte[] { 0x11 };

        BlobSystem.Write(blob, new byte[] { 0xFF, 0xFF, 0xFF, 0xFF });
        BlobSystem.Write(blob, expected);

        Assert.Equal(expected, BlobSystem.Read(blob));
    }
}
