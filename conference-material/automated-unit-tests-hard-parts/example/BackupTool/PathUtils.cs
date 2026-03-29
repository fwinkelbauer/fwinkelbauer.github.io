namespace BackupTool;

public static class PathUtils
{
    public static void EnsureParent(string path)
    {
        var parent = Path.GetDirectoryName(path);

        if (string.IsNullOrEmpty(parent)
            || parent.Equals(Path.GetPathRoot(parent)))
        {
            return;
        }

        _ = Directory.CreateDirectory(parent);
    }
}
