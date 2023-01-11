using System.Threading.Tasks;
using Core.DTOs;
using Core.ViewModels;
using Core.Interfaces;
using Infrastructure.Persistence.Context;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Services.Identity.JWT
{
    public class JwtMediateR
    {
        private IJWTManager _jwtManager { get; set; }
        public IUserManager _userManager { get; set; }
        public AppDbContext _dbContext { get; set; }

        public JwtMediateR(IJWTManager jwtManager, IUserManager userManager, AppDbContext dbContext)
        {
            _jwtManager = jwtManager;
            _userManager = userManager;
            _dbContext = dbContext;
        }

        public async Task<AuthenticationResponse> AuthenticateAsync(LoginCommand loginCmd)
        {
            try
            {
                string error = await _userManager.GetSignInErrorsAsync(loginCmd.UserName, loginCmd.Password);
                if (string.IsNullOrEmpty(error))
                {
                    return await _jwtManager.AuthenticateAsync(await _userManager.GetUserAsync(loginCmd.UserName, loginCmd.Password));
                };
                return new AuthenticationResponse()
                {
                    Error = error,
                    AccessToken = "",
                    RefreshToken = ""
                };
            }
            catch (System.Exception)
            {

                return new AuthenticationResponse()
                {
                    Error = "خطا در انجام عملیات",
                    RefreshToken = "",
                    AccessToken = ""
                };
            }
        }
        public async Task<AuthenticationResponse> RefreshToken(string refToken)
        {
            if (!string.IsNullOrEmpty(refToken))
            {

                var refreshToken = await _dbContext.RefreshTokens.Include(t => t.User).SingleOrDefaultAsync(x => x.Token == refToken);

                if (refreshToken != null)
                {
                    if (_jwtManager.ValidateRefreshToken(refreshToken.Token))
                    {
                        var user = refreshToken.User;
                        _dbContext.Remove(refreshToken);
                        await _dbContext.SaveChangesAsync();
                        return await _jwtManager.AuthenticateAsync(user);
                    }
                }
            }
            return null;
        }

        public async Task<bool> SignoutAsync(string refreshToken, int userId)
        {
            return await _jwtManager.SignoutAsync(refreshToken, userId);
        }
    }
}
