namespace BackupTool;

public interface IRepository
{
    string[] List();

    byte[] Read(string name);

    void Write(string name, byte[] content);
}

public sealed class FileRepository : IRepository
{
    private readonly string _directory;

    public FileRepository(string directory)
    {
        _directory = directory;
    }

    public string[] List()
    {
        return Directory.GetFiles(_directory, "*", SearchOption.AllDirectories)
            .Select(f => Path.GetRelativePath(_directory, f))
            .ToArray();
    }

    public byte[] Read(string name)
    {
        return File.ReadAllBytes(
            Path.Combine(_directory, name));
    }

    public void Write(string name, byte[] content)
    {
        var path = Path.Combine(_directory, name);

        PathUtils.EnsureParent(path);
        File.WriteAllBytes(path, content);
    }
}

public class MemoryRepository : IRepository
{
    private readonly Dictionary<string, byte[]> _values = new();

    public string[] List()
    {
        return _values.Keys.ToArray();
    }

    public byte[] Read(string name)
    {
        return _values[name];
    }

    public void Write(string name, byte[] content)
    {
        _values[name] = content;
    }
}

public sealed class DryRunRepository : IRepository
{
    private readonly IRepository _repository;

    public DryRunRepository(IRepository repository)
    {
        _repository = repository;
    }

    public string[] List()
    {
        return _repository.List();
    }

    public byte[] Read(string name)
    {
        return _repository.Read(name);
    }

    public void Write(string name, byte[] content)
    {
        // We do nothing on purpose
    }
}
