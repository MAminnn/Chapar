namespace Infrastructure.Services.EmailService
{
    public interface IEmailSender
    {
        void SendEmail(string FromEmailPassword, string ToEmail, string Subject, string Body, bool IsHtmlOn, string FromEmail, int? Port, string Host = "");
    }
}
