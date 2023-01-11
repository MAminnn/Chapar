using System.Collections.Generic;

namespace Core.ViewModels
{
    public class RegisterationResponse
    {
        public bool Success { get; set; }
        public List<string> Errors { get; set; }
        public string EmailConfirmationToken { get; set; }
    }
}
