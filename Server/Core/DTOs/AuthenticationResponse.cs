namespace Core.DTOs
{
    public class AuthenticationResponse
    {
        public string AccessToken { get; set; }
        public string RefreshToken { get; set; }
        public string Error { get; set; }
    }
}
