using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Persistence.Context
{
    public class AppDbContext : IdentityDbContext<User, IdentityRole<int>, int>
    {
        public AppDbContext(DbContextOptions options) : base(options)
        {

        }
        public DbSet<Contact> Contacts { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }
        public DbSet<Message> Messages { get; set; }
        public DbSet<Chat> Chats { get; set; }
        public DbSet<FriendRequest> FriendRequests { get; set; }
        public DbSet<ChatContact> ChatContacts { get; set; }
        public DbSet<Friend> Friends { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            builder.Entity<Contact>().HasMany<FriendRequest>(c => c.SentFriendRequests).WithOne(fr => fr.FromContact);
            builder.Entity<Contact>().HasMany<FriendRequest>(c => c.ReceivedFriendRequests).WithOne(fr => fr.ToContact);

            builder.Entity<Contact>().HasMany<Chat>(c => c.Chats).WithMany(c => c.Contacts).UsingEntity<ChatContact>(
                cc => cc.HasOne(prop => prop.Chat).WithMany().HasForeignKey(prop => prop.ChatId),
                cc => cc.HasOne(prop => prop.Contact).WithMany().HasForeignKey(prop => prop.ContactId)
            );

            builder.Entity<Friend>().HasKey(f => new { f.FriendContactId, f.ContactId });
            builder.Entity<Contact>().HasMany<Friend>(c => c.Friends).WithOne(f => f.Contact);

            builder.Entity<ChatContact>().Ignore(cc=>cc.LastMessage);
            
            base.OnModelCreating(builder);
        }
    }
}
