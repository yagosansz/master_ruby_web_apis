# Chapter 09 - Authentication

Authentication is an important part of any modern web application. Being able to identify who is using your application and to see if they have the authorization to do so is invaluable.

On most websites and web applications, authentication is handled with the use of cookies, defined in the *RFC 6265* titled "HTTP State Management Mechanism".

The name says it all: cookies were created to let a server store states. That's the complete opposite of what Fielding offered in the REST architectural style. The Stateles constraint states that all client-server interactions should be stateles, i.e. a request should not depend upon another one. The idea behind this is to allow web applications to scale more easily and cache to be more effective.

By default, HTTP authentication schemes, *Basic and Digest*, are stateless. But nowadays, most businesses need to know who their users are and want to lower the barrier to use their products. This means avoiding asking a user for his credentials too often and, if possible, only the first time.

If your web API is meant to offer tools for other web applications, using a long, unique, secret key is the best practice and is known as an `API Key` or an `API Secret Token`. It can be associated with an *access token* that acts as an identifier for that password.

```
# SSL, everywhere, all the time.

Whatever authentication scheme you choose, you should always set up an SSL certificate for your application in order to protect the data being exchanged between your clients and your server.
```

## Identification vs Authentication vs Authorization

**Identity** is knowing who claims to be making the API request. **Authentication** is the process of checking that they really are who they claim to be. **Authorization** is the set of rules used to ensure that they only do what they are allowed to do.

### Identity

Google Maps provides developers with only API keys. That's all they need to start looking up addresses. They are used by the Google Maps' API to **identify** who is making the request, in order to limit usage for example. But, I can give the API key to one of my friends and he/she will be able to use it as well. The API is **not** authenticating its users.

### Authentication

On the other hand, if you take Twitter as an example, most API calls require authentication. To access more than the public information for a user, you need to sign in using either a username/password combination or with OAuth.

### Authorization

In Twitter's case, even once you are authenticated, you still cannot post tweets under someone else's identity, unless you have their credentials or an OAuth key for their account. You are not authorized to do so.

## Understanding the "Stateless" Constraint

First, we need to know that the HTTP protocal is stateless, i.e. it doesn't keep any state between requests, meaning that each request is independent.

The stateless constraint is part of the REST architectural style and its goals are scalability and caching. To do so, the server shouldn't keep track of where the user is or what he is doing. The state should not be maintaned on the server.

While great on paper, there are very few stateless web applications on the web.

**An application can be considered stateless only if each request is independent and does not rely on previously sent requests. For example, any application with a mandatory login cannot be considered stateless, whatever the mechanism used (e.g.: cookies, access tokens).**

## Authentication with HTTP

The default authentication mechanisms for HTTP are defined in the **RFC 2617** as Basic and Digest. Those mechanisms were designed following the REST constraints, which means they are stateless. The username/password pair is included in every request, either in clear, enconded in Base64 (Basic Auth), or hashed with the MD5 hash function (Digest Auth).

Following the RFC, in order to authenticate, a client needs to send the `Authorization` header formatted as:

```
Authorization: auth-scheme hashed-credentials
```

If the server receives the adequate values, the request proceeds and the server returns the requested representation. However, in case of an unauthenticated request, the server should respond with the `401 Unauthorized` and set the `WWW-Authenticate` header specifying what authentication scheme should be used and in which realm.

```
WWW-Authenticate: Basic realm="User Realm"
```

The realm directive, which is actually optional, indicates the protection space. With it, the same server application can have different protected areas using different authentication schemes.

### Basic

The Basic authentication is, by default, not secure. The credentials can be easily decoded as they are enconded.

The main advantage of using Basic is that it's stateless. However, due to the stateless constraint, the credentials have to be sent with every request.

Using SSL is mandatory in order to provide a minimum amount of security.

- The `--verbose` flag will display sent and received requests.
```
curl -v -u john:pass http://localhost:4567
```

### Digest

Digest works pretty much like Basic, but is more secure since the credentials are hashed using MD5. Additionally, it is also stateless, with all its subsequents advantages and incoveniences.

In order to use Digest authentication, we need to pass Sinatra application through a `rack` middleware (`Rack::Auth::Digest::MD5`).

Start the server with - make sure `rack` is installed (`gem install rack`):

```
rackup config.ru
```

```
curl -v --digest -u john:pass http://localhost:9292
```

### Token

Token-based authentication is the usual choice for web APIs. It allows the user to enter their username and password in order to get a token that will then be used in every request. This authentication approach is similar to the one using cookies, and cannot be considered stateless.

Here is an example of the `Authorization` header for this mechanism.

- Sample requests:

```
curl http://localhost:4567/login \
  -i -d '{"email":"thibault@samurails.com", "password": "supersecret"}'
```

```
curl -i -H 'Authorization: Token enter_token_here' \
  http://localhost:4567
```

### API Keys

It can also be used to authenticate clients automatically, as in the case of a mobile application. The client needs to contain that secret key before being deployed and will send that key with every request. Often, developers implement API keys in a way that allows people to simply append the key at the end of the URL, as a query parameter `?api_key=fkdjslfkjdslfkjdfsdfdsfdsf`.

It's usually a better idea to reuse the `Authorization` header with a custom authentication scheme. The only reason to add the API key as a query parameter is if you really, really want to be able to copy/paste the URL around.

```
curl -i -H "Authorization: Key ZmvhBBpb4RlbyblpKoj9F716CoONTOtr" \
http://localhost:4567
```

## A Note about OAuth 2.0

[OAuth 2.0 is not an authentication protocol](https://oauth.net/articles/authentication/).

[YouTube - Explain OAuth 2.0 Like I'm 5](https://www.youtube.com/watch?v=hHRFjbGTEOk)

[OAuth 2.0 - Guia do Iniciante (pt-BR)](https://www.brunobrito.net.br/oauth2/)


