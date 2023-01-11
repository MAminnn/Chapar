using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Core.Entities;

namespace Infrastructure.Services.Identity.Customization
{
    class UserValidator : IUserValidator<User>
    {
        public Task<IdentityResult> ValidateAsync(UserManager<User> manager, User user)
        {
            return Task.Run(() =>
            {


                if (manager.Users.Any(u => u.UserName == user.UserName))
                {
                    return IdentityResult.Failed(new IdentityError() { 
                    Code="123",
                    Description="این نام کاربری قبلاً انتخاب شده"
                    });
                }
                return IdentityResult.Success;
            });
        }
    }
}
