# Chapter 08 - Caching

Caching is extremely important, not only for your users but also to reduce the cost of running your applications. The more users you have, the more important caching becomes.

Caching is nothing new. It usually means storing something in a cache, a simple key/value database, in order to re-access it faster. In software engineering, any value that is difficult and expensive to compute or retrieve should be cached.

For web development, HTTP comes with everything you need to allow clients to cache responses and avoid transferring the same data over and over again. This type of caching obviously happens on the client, but is made possible by the server and its configuration.

Data can also be cached on the server. We can cache static outputs (i.e.: JSON documents, HTML pages) to make future requests faster. Some representations are more complex to generate and caching them can shred hundreds of milliseconds off a request.

## Client Caching

By defining a few settings on the server, any client will be capable of getting data from the cache instead of requesting it from your server.

The goals of caching in HTTP are to eliminate the need to send requests as much as possible, and if requests have to be made, to reduce the need of sending data in the responses. The first goal can be achieved by using an **expiration** mechanism, known as `Cachel-Control`, and the second **validation** mechanism like `ETag` or `Last-Modified`.

### Preventing Requests Entirely

The fastest to way to send an HTTP request is to not send it at all.

The `Cache-Control` header can be used to define the caching policy for a resource. More specifically, it defines *who* can cache it, *how*, and for *how long*.

```
Cache-Control: max-age=3600
```
The `max-age` directive defines, in seconds, for how long the resource can be cached. For example, `Cache-Control: max-age=3600` means that the received response can be cached for 1 hour. In other words, for the next hour, a browser (for instance) can simply use the cached response instead of making another HTTP request, effectively saving time and bandwidth.

**The expiration time for a response can also be set using the `Expires` header. Note that if both the `Expires` header and the `max-age` directives are present in the response, the `max-age` directive takes precedence over `Expires`**.

```
Cache-Control: private, max-age=86400
```
The `public` and `private` directives define who can cache the response. `public` means that anyone and anything can cache it, but is often unecessary since `max-age` already defines the response as cacheable. `private`, on the other hand, defines a response as only being cacheable by a browser, not by intermediaries such as CDNs (Content Delivery Networks).


```
Cache-Control: no-cache
```
`no-cache` means that the response can be cached but cannot be re-used without first checking with the server. To avoid re-transmitting the whole response, `no-cache` can be combined with the `Etag` header to check if the response has changed or not. 

On the other hand, `no-store` simply means that nothing can cache the response, be it a browser or intermediary. This should be used for sensitive data that should never be cached.

### Prevent Data Transfer

We have just learned how requests can be prevented by using the `Cache-Control` header. Unfortunately, in most web APIs, this is rarely possible. But if a request has to be made anyway, we can save time and bandwith by using the `ETag` (Entity Tag) header, which is meant to hold a validation token identifying a specific version of a response.

```
-- Request 1:

GET /users/thibault HTTP/1.1
Host: localhost:4567

-- Response 1:

HTTP/1.1 200 OK
Content-Length: 2048
ETag: "123"

[DATA]
```

The next time the client sends a request to `/users/thibault`, it should include the `ETag` token it received in the `If-None-Match` header.

```
-- Request 2:
GET /users/thibault HTTP/1.1
Host: localhost:4567
If-None-Match: "123"

-- Response 2-A:
HTTP/1.1 304 Not Modified
ETag: "123"

-- Response 2-B:
HTTP/1.1 200 OK
Content-Length: 2048
ETag: "124"

[DATA]
```
Any kind of value will do as a validation token. It can be the hash of the representation (MD5, for example), `updated_at` attribute of the entity, or an internal version number that you update in the server every time data changes.
    - Hashing is simpler but takes more computation time, and works more effectively with server caching.

If you choose to use a timestamp, there is a better header for you: `Last-Modified`. Associated with the request header `If-Modified-Since`, it follows the same logic as `ETag` and the server will return `304 Not Modified` if the requested variant has not changed.

```
Last-Modified: Sat, 28 Apr 1990 02:00:00 GMT
```
### Pre-Condition

The two headers we just learned, `If-None-Match` and `If-Modified-Since`, are used to make conditional HTTP requests.

There are 5 headers which can be used to create conditional HTTP requests. The idea behind this type of request is to allow the client to tell the server that, if the condition is not met, the request should fail and the server should return `412 Precondition Failed`. This book only will use `If-None-Match`.

### How do Caches Store Different Representations of the Same Resource

```
-- Request:

GET /users HTTP/1.1
Accept: application/json

-- Response:

GET /users HTTP/1.1
Host: example.com
Content-Type: application/json
```

The response above was cached, and then we proceed to make a second request but asking for a different representation.

```
-- Request:

GET /users HTTP/1.1
Accept: application/xml

-- Response:

GET /users HTTP/1.1
Host: example.com
Content-Type: application/xml
```

If cached only used a combination of the HTTP method and the URI as a key for the cached response, the second request would still give us the JSON document - same method, same URI.

Luckily, cache systems also use a secondary cache key, and, by using the `Vary` header, we can change how this secondary key is built. `Vary` let us set exactly which headers impact the body of the request and should be part of the caching key.

If we had added `Vary: Accept` as one of the headers in our previous responses, cache would have noticed that the two requests are distinct. They will both be stored under the same primary key `GET /users`. The first request will have the secondary key `application/json`, and the second one `application/xml`.

There are other headers, such as `Accept-Language` and `Accept-Enconding`, that can affect the format or content of the response body.

### Invalidating Cache

Cache invalidation is hard. That's why most people don't do it and just create new and different entries in the cache.

A problem arises for the representation of resources: How should we cache them? Do we need to add a fingerprint (e.g.: MD5) every time we make a change?

If you plan your caching strategy adequately, you can get away by simply using the `ETag` header. Since it's a specific version of a representation, you can know exactly when the client and the server are not in syc.

Using `Cache-Control` and `max-age` is the best way to save time, but is much harder to use with web APIs. If you set `max-age: 86400`, you need to ensure that any update sent to the server will reset the expiration date and the cached data. 

### Implementation

Sinatra has a good support of HTTP caching.

```ruby
etag Digest::SHA1.hexdigest(users.to_s)
```

We are using the Sinatra `etag` method, giving it a `SHA1` digest of the `users` hash (after converting it to a `string`). Sinatra will now automatically check if the client has sent the `ETag` header. If the tokes match, it will halt the execution and return `304 Not Modified`.

## Server Caching
We can go one step further on the server by caching the representations to boost the requests that have not been HTTP cached yet.

Building representations can be costly for a server and you want to be able to cache as many as possible. Of course, not everything can be cached.

Lets say if we have the following resource available for users: `users/{id}/book`. From there, the following representation is returned:

```
{
  "books": [
    { "title": "Something", "ISBN": "123" },
    { ... },
  ]
}
```

To create this representation, we had to complete at least 2 SQL queries, one to get the user's `id` and another one get the all the books associated with the user. It might not take too long for a single request, but what if we had 1 million requests?

The thing with our fake API is that users don't update their reading list frequently: the writing ratio is much lower than the reading ratio.

What if we decided to generate a representation as soon as a change was made?

1. A user sends a `POST` request to add a book
2. The server receives the request and links the book with the user
3. Right after, the server re-generates the books list as a JSON document and caches it
4. The user requests its reading list and gets it super fast because the server can just get it from the cache

This approach has a problem. There is often more than one representation, and you don't want to have to cache them all before they are accessed. What we can do instead is use **lazy-loading**. Any time a `GET` request is received by the server, it looks in the cache to "see" if the representation is there or not. If it is there, the server simply sends it back. If it is not there, the server first generates it, stores it, and then sends it back. The keys for the cache entries can be a combination of identifiers, media types, last update timestamp, and language.

**Caching is awesome, if your scenario allows it!**

### Implementation

Let's create a simple implementation of server-side caching. Since we don't store `updated_at` attributes for our users, we cannot use the same strategy as Rails. Instead, we are just going to use a revision number.

Use the following `curl` request to see how much time we can save by caching our huge representation:

```
curl -i -s -w "\n%{time_total}s \n" -o /dev/null http://localhost:4567/users
```

- `-s`: Quiet Mode. Dont' show progress or error messages.
- `-w`: Set what to display after a successful request. Here we are displaying it in seconds.
- `-o`: Write the output to the specified location. Here we are discarding the output by sending it to `/dev/null`

Read more about [each_with_object](https://womanonrails.com/each-with-object).








