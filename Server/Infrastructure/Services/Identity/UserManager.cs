using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Core.Entities;
using Core.Interfaces;
using Core.ViewModels;

namespace Infrastructure.Services.Identity
{
    public class UserManager : IUserManager
    {
        private UserManager<User> _userManager;
        private SignInManager<User> _signInManager;
        private IContactManager _contactManager;
        public UserManager(UserManager<User> userManager, SignInManager<User> signInManager, IContactManager contactManager)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _contactManager = contactManager;
        }
        public async Task<bool> ConfirmEmail(string username, string token)
        {
            if (!string.IsNullOrEmpty(username) && !string.IsNullOrEmpty(token))
            {
                token = token.Replace("%2F", "/");
                var user = await _userManager.FindByNameAsync(username);
                var res = await _userManager.ConfirmEmailAsync(user, token);
                if (res.Succeeded)
                {
                    await _contactManager.InsertContactAsync(new Contact()
                    {
                        Username = user.UserName,
                        UserId = user.Id,
                    });
                }
                return res.Succeeded;
            }

            return false;
        }
        public async Task<RegisterationResponse> Register(RegisterationCommand command)
        {
            RegisterationResponse response = new RegisterationResponse();
            if (string.IsNullOrEmpty(command.Email) || string.IsNullOrEmpty(command.ConfirmPassword) || string.IsNullOrEmpty(command.Password) || string.IsNullOrEmpty(command.UserName))
            {
                response.Success = false;
                response.Errors = new List<string>()
                {
                    "عملیات با خطا مواجه شد"
                };
                return response;
            }
            try
            {
                User user = new User()
                {
                    Email = command.Email,
                    UserName = command.UserName,
                };

                if (command.Password != command.ConfirmPassword)
                {
                    response.Success = false;
                    response.Errors = new List<string>();
                    response.Errors.Add("کلمه ی عبور با تکرار کلمه ی عبور مطابقت ندارد");
                    return response;
                }

                IdentityResult res = await _userManager.CreateAsync(user, command.Password);
                if (!res.Succeeded)
                {
                    response.Success = false;
                    response.Errors = new List<string>();
                    foreach (var error in res.Errors)
                    {
                        response.Errors.Add(error.Description);
                    }
                    return response;
                }
                response.Errors = null;
                response.Success = true;
                response.EmailConfirmationToken = await _userManager.GenerateEmailConfirmationTokenAsync(user);
                return response;
            }
            catch (System.Exception)
            {

                response.Success = false;
                response.Errors = new List<string>() { "عملیات با خطا مواجه شد" };
                response.EmailConfirmationToken = "";
                return response;
            }
        }
        public async Task<User> GetUserAsync(string userName, string password)
        {

            User user = await _userManager.FindByNameAsync(userName);
            if (user != null && await _userManager.CheckPasswordAsync(user, password))
            {
                return user;
            }
            return null;
        }
        public async Task<User> GetUserByIdAsync(string id)
        {
            User user = await _userManager.FindByIdAsync(id);
            if (user != null)
            {
                return user;
            }
            return null;
        }
        public async Task<bool> IsLockOutUserAsync(User user)
        {
            return await _userManager.IsLockedOutAsync(user);
        }
        public async Task<User> GetUserByNameAsync(string userName)
        {
            return await _userManager.FindByNameAsync(userName);
        }
        public async Task<string> GetSignInErrorsAsync(string userName, string password)
        {
            User user = await GetUserByNameAsync(userName);
            if (user is null)
            {
                return "نام کاربری یا رمز عبور اشتباه است";
            }
            if (!await _userManager.CheckPasswordAsync(user, password))
            {
                if (await _userManager.IsLockedOutAsync(user))
                {
                    return "حساب کاربری شما به علت تلاش های متعدد ناموفق به مدت پانزده دقیقه قفل شده است";
                }
                await _signInManager.UserManager.AccessFailedAsync(user);
                return "نام کاربری یا رمز عبور اشتباه است";
            }
            if (!await _userManager.IsEmailConfirmedAsync(user))
            {
                return "حساب کاربری شما فعال نشده است ، ایمیل خود را بررسی کنید";
            }
            if (await _userManager.IsLockedOutAsync(user))
            {
                return "حساب کاربری شما به علت تلاش های متعدد ناموفق به مدت پانزده دقیقه قفل شده است";
            }
            return null;

        }

    }
}
