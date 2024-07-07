
# Chapar

A unique and lightweight messenger that is easily accessible for anyone to pick up at any time and instantly engage with.




## Features

- Light/dark mode toggle along with 3 other cool themes
- Private and group chats
- Chat status (unread or seen)
- Cross platform
- Fast
- Specially designed for Persian language
- JWT Authentication along with Asp.net core identity
- Communication using WebSocket


## Screenshots
![screely-1720389971857](https://github.com/MAminnn/Chapar/assets/67999549/922e219c-c750-4164-9571-9ee0cae557f7)
![screely-1720383726750](https://github.com/MAminnn/Chapar/assets/67999549/d321f29b-149b-44eb-a9b2-596f4c8a26fe)
![MixCollage-08-Jul-2024-01-28-AM-4343](https://github.com/MAminnn/Chapar/assets/67999549/bb2f5ea4-9f2d-40ab-8d6c-b782f9d5849d)




## Run Locally

Clone the project

```
git clone https://github.com/MAminnn/Chapar
```

Go to the project directory

```
cd chapar
```

### For client application

```
cd Client\chapar
```
Then run the following command to recreate the flutter project

```
flutter create .
```

Then you can either `run` it or `build` it

### For server application

The server application is based on the Clean Architecture with 3 layers

once you run the solution, before running the application you have to specify necessary [user-secrets](https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets) like this :

```
{
  "ConnectionStrings": {
    "Server": "{YOUR_CONNECTION_STRING}"
  },
  "EmailSettings": {
    "EmailAddress": "{YOUR_EMAIL_ADDRESS}", // TO send account verification email with
    "EmailPassword": "{YOUR_EMAIL_PASSWORD}",
    "EmailHost": "{YOUR_EMAIL_HOST}" // Usually it's "webmail.{DOMAIN}"
  }
}
```
## Note
The client application is originally developed in version 3.0.3 of flutter and is just updated without much code changes and it's done to make the project compatible with the latest version

The server application is originally developed in **ASP.NET Core 5**
and again its packages just updated to **ASP.NET Core 8** to be compatible with it without any code changes


## Usage

After you made an account you can send request the your friends and once they accepted your request you can then start chatting 

