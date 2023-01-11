using System.Net;
using System.Net.Mail;

namespace Infrastructure.Services.EmailService
{
    public class PleskMailSender : IEmailSender
    {
        public void SendEmail(string FromEmailPassword, string ToEmail, string Subject, string Body, bool IsHtmlOn, string FromEmail, int? Port, string Host = "")
        {
            MailMessage message = new MailMessage();
            System.Net.Mail.SmtpClient smtp = new System.Net.Mail.SmtpClient();
            message.From = new MailAddress(FromEmail);
            message.To.Add(new MailAddress(ToEmail));
            message.Subject = Subject;
            message.IsBodyHtml = IsHtmlOn; //to make message body as html  
            message.Body = Body;
            smtp.Port = Port.Value;
            smtp.Host = Host; //for gmail host  
            smtp.EnableSsl = false;
            smtp.UseDefaultCredentials = false;
            smtp.Credentials = new NetworkCredential(FromEmail, FromEmailPassword);
            smtp.DeliveryMethod = SmtpDeliveryMethod.Network;
            smtp.Send(message);
        }
    }
}
