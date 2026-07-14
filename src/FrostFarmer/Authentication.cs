using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;

namespace FrostFarmer;

public sealed record AuthResult(string Token, DateTimeOffset ExpiresAt, string Username, string Role);

public sealed class AuthenticationService(IFrostDatabase database, IOptions<FrostOptions> options)
{
    public async Task<AuthResult> RegisterAsync(string username,string password)
    {
        Validate(username,password);
        if(!options.Value.AllowBootstrapRegistration)throw new InvalidOperationException("Bootstrap registration is closed.");
        var user=new UserAccount(Guid.NewGuid(),username.Trim(),HashPassword(password),"admin",DateTimeOffset.UtcNow);
        if(!await database.TryCreateFirstUserAsync(user))throw new InvalidOperationException("Bootstrap registration is closed.");return await IssueAsync(user);
    }
    public async Task<AuthResult?> LoginAsync(string username,string password)
    {
        var user=await database.UserByNameAsync(username.Trim());
        return user is {Enabled:true}&&VerifyPassword(password,user.PasswordHash)?await IssueAsync(user):null;
    }
    public async Task<UserAccount?> AuthenticateAsync(string rawToken)
    {
        if(string.IsNullOrWhiteSpace(rawToken))return null;var token=await database.TokenByHashAsync(HashToken(rawToken));return token is null?null:await database.UserByIdAsync(token.UserId);
    }
    public Task LogoutAsync(string rawToken)=>database.RevokeTokenAsync(HashToken(rawToken));
    private async Task<AuthResult> IssueAsync(UserAccount user){var bytes=RandomNumberGenerator.GetBytes(32);var raw=Convert.ToBase64String(bytes).Replace('+','-').Replace('/','_').TrimEnd('=');var expires=DateTimeOffset.UtcNow.AddHours(options.Value.TokenLifetimeHours);await database.SaveTokenAsync(new(Guid.NewGuid(),user.Id,HashToken(raw),expires,DateTimeOffset.UtcNow));return new(raw,expires,user.Username,user.Role);}
    private static string HashPassword(string password){var salt=RandomNumberGenerator.GetBytes(16);var hash=Rfc2898DeriveBytes.Pbkdf2(password,salt,210_000,HashAlgorithmName.SHA256,32);return $"pbkdf2-sha256$210000${Convert.ToBase64String(salt)}${Convert.ToBase64String(hash)}";}
    private static bool VerifyPassword(string password,string encoded){var p=encoded.Split('$');if(p.Length!=4||!int.TryParse(p[1],out var rounds))return false;var expected=Convert.FromBase64String(p[3]);var actual=Rfc2898DeriveBytes.Pbkdf2(password,Convert.FromBase64String(p[2]),rounds,HashAlgorithmName.SHA256,expected.Length);return CryptographicOperations.FixedTimeEquals(expected,actual);}
    private static string HashToken(string token)=>Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token)));
    private static void Validate(string username,string password){if(username.Trim().Length is <3 or >64)throw new ArgumentException("Username must contain 3-64 characters.");if(password.Length<12)throw new ArgumentException("Password must contain at least 12 characters.");}
}
