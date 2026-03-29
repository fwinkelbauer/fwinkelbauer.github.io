namespace BackupTool.Tests;

public class BlobSystemBuilder
{
    private readonly IBlobSystem _blobSystem;

    public BlobSystemBuilder(IBlobSystem blobSystem)
    {
        _blobSystem = blobSystem;
    }

    public BlobSystemBuilder WithBlob(Blob blob, byte[] content)
    {
        _blobSystem.Write(blob, content);

        return this;
    }

    public BlobSystemBuilder WithBlob(Blob blob)
    {
        return WithBlob(blob, Encoding.UTF8.GetBytes(blob.Name));
    }

    public BlobSystemBuilder WithBlob(string name)
    {
        return WithBlob(new Blob(name, Some.UtcNow()));
    }

    public BlobSystemBuilder WithExampleBlobs()
    {
        return WithBlob("blob 1")
            .WithBlob("dir/blob-2");
    }

    public IBlobSystem Build()
    {
        return _blobSystem;
    }
}
