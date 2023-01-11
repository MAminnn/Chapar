using System.Threading.Tasks;
using Core.ViewModels;
using Core.Entities;

namespace Core.Interfaces
{
    public interface IUserManager
    {
        Task<RegisterationResponse> Register(RegisterationCommand command);
        Task<bool> ConfirmEmail(string username,string token);
        Task<User> GetUserAsync(string userName,string password);
        Task<User> GetUserByIdAsync(string id);
        Task<bool> IsLockOutUserAsync(User user);
        Task<User> GetUserByNameAsync(string userName);
        Task<string> GetSignInErrorsAsync(string userName, string password);
    }
}