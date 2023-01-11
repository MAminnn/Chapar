using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Core.DTOs;
using Core.Entities;

namespace Core.Interfaces
{
    public interface IJWTManager
    {
        public string GenerateToken(string secretKey, string issuer, string audience, double ExpireTime, IEnumerable<Claim> claims = null);
        public bool ValidateRefreshToken(string refreshToken);
        public Task<AuthenticationResponse> AuthenticateAsync(User user);
        public string GenerateAccessToken(User user);
        Task<bool> SignoutAsync(string refreshToken, int userId);
    }
}
