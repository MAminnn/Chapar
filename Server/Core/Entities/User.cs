using System.Collections.Generic;

namespace Core.Entities
{
    public class User : Microsoft.AspNetCore.Identity.IdentityUser<int>
    {
        public ICollection<RefreshToken> RefreshTokens { get; set; }
    }
}


