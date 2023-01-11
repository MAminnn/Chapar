namespace Core.DTOs
{
    public class SeenCommand
    {
        public int ContactId { get; set; }
        public int ChatId { get; set; }
        public bool Seen { get; set; }
    }
}
