namespace BackupTool.Tests;

public class CryptoTests
{
    [Fact]
    public void Encrypt_And_Decrypt_Return_Input()
    {
        var crypto = Some.Crypto();
        var plain = "Hello world"u8;

        var encrypted = crypto.Encrypt(plain);
        var decrypt = crypto.Decrypt(encrypted);

        Assert.Equal(plain, decrypt);
    }

    [Fact]
    public void Encrypt_Gives_Different_Result_For_Different_Salt()
    {
        var crypto1 = Some.Crypto("same");
        var crypto2 = Some.Crypto("same");

        var encrypted1 = crypto1.Encrypt("Hello world"u8);
        var encrypted2 = crypto2.Encrypt("Hello world"u8);

        Assert.NotEqual(encrypted1, encrypted2);
    }

    [Fact]
    public void Decrypt_Throws_If_Wrong_Password()
    {
        var salt = RandomNumberGenerator.GetBytes(Crypto.SaltBytes);
        var iterations = Crypto.DefaultIterations;

        var crypto1 = new Crypto("something", salt, iterations);
        var crypto2 = new Crypto("else", salt, iterations);

        var encrypted = crypto1.Encrypt("Hello world"u8);

        Assert.Throws<AuthenticationTagMismatchException>(
            () => crypto2.Decrypt(encrypted));
    }
}
