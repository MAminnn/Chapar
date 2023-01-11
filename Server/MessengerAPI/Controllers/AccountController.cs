using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Infrastructure.Services.Identity;
using Core.ViewModels;
using Core.Entities;
using Infrastructure.Services.EmailService;
using Core.Interfaces;
using Core.DTOs;
using Infrastructure.Services.Identity.JWT;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using System.Security.Claims;

namespace MessengerAPI.Controllers
{
    [ApiController]
    public class AccountController : ControllerBase
    {
        #region fields
        private UserManager _userManager;
        private IEmailSender _emailSender;
        private UserManager<User> _aspUserManager;
        private JwtMediateR _jwtMediatR;
        #endregion
        public AccountController(UserManager<User> aspUserManager, IEmailSender emailSender, JwtMediateR jwtMediatR, SignInManager<User> signInManager, IContactManager contactManager)
        {
            _aspUserManager = aspUserManager;
            _emailSender = emailSender;
            _jwtMediatR = jwtMediatR;
            _userManager = new UserManager(_aspUserManager, signInManager, contactManager);
        }
        [HttpGet]
        [Route("/api/account/ConfirmEmail", Name = "ConfirmEmailAction")]
        public async Task<IActionResult> ConfirmEmail(string username, string token)
        {
            var res = await _userManager.ConfirmEmail(username, token);
            if (res)
            {
                return Content("ایمیل با موفق تایید شد");
            }
            return Content("عملیات با خطا مواجه شد");

        }


        [Route("/api/account/login")]
        [HttpPost]
        public async Task<AuthenticationResponse> Authenticate([FromBody] LoginCommand lcmd)
        {
            return await _jwtMediatR.AuthenticateAsync(lcmd);
        }

        [Route("/api/account/refrshtoken")]
        [HttpPost]
        public async Task<AuthenticationResponse> RefreshToken([FromBody] RefreshCommand refcmd)
        {
            return await _jwtMediatR.RefreshToken(refcmd.Token);
        }
        [HttpPost]
        [Route("/api/account/register")]
        public async Task<RegisterationResponse> Register([FromBody] RegisterationCommand rcmd)
        {
            var res = await _userManager.Register(rcmd);
            if (res.Success)
            {
                SendEmailAsync(rcmd.Email, rcmd.UserName, res.EmailConfirmationToken);
            }
            res.EmailConfirmationToken = "";
            return res;
        }

        [HttpGet]
        [Authorize]
        [Route("/api/account/checkauth")]
        public void CheckAuthentication() { }

        [HttpGet]
        [Authorize]
        [Route("/api/account/logout/{refreshToken}")]
        public async Task<bool> Signout(string refreshToken)
        {
            int Id = int.Parse(HttpContext.User.FindFirst(ClaimTypes.NameIdentifier).Value);
            return await _jwtMediatR.SignoutAsync(refreshToken,Id);
        }
        private void SendEmailAsync(string email, string UserName, string token)
        {
            string serverUrl = Url.Link("ConfirmEmailAction", new
            {
                username = UserName,
                token = token

            });
            string body = $"<h1> سلام {UserName} عزیز </h1><br/>" +
        $"<h4> تشکر می کنیم که از پیام رسان چاپار استفاده می کنید . <br/>" +
        $" برای تایید ایمیل خود و فعال شدن حساب کاربری روی لینک زیر کلیک نمایید <br/>" +
        $" امیدواریم از برنامه ی ما نهایت لذت را ببرید ، خواهشمندیم در صورت بروز هرگونه مشکل و یا ثبت پیشنهاد یا انتقادی از طریق پل های ارتباطی ارائه شده در برنامه به ما گزارش دهید ، تشکر   <br/>" +
        $"<h3><a href='{serverUrl}' >تایید ایمیل </a></h3>";
            _emailSender.SendEmail("Amin@karvizi1384", email, "تایید ایمیل", body, true, "cmsg@crusaders.ir", 25, "webmail.crusaders.ir");
        }
    }
}
