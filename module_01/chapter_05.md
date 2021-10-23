# Chapter 05 - Using HTTP Verbs

## HTTP Methods, a.k.a "Verbs"

We've seen before that websites are just web APIs with a web browser as a client, outputting `HTML` instead of `JSON` or `XML`.

Sadly, `HTML` only supports two HTTP methods: `GET` and `POST`.

### What Is An HTTP Method?

HTTP methods, also known as HTTP verbs, are just English verbs like `GET` which define what action the client wants to be performed on the identified resource.

### What Is A "Safe" Method?

"Safe" methods do not have any side effects and should only retrieve data. You can, of course, implement something in our API when a safe method is called, like updating a user's quota for example. However, the client cannot be held responsible for those modifications since he did not request them and considered the method safe to use.

The only safe methods are `GET` and `HEAD`.

### What Is An "Idempotent" Method?

Idempotence is the property of some operations in mathematics and computer science, where running the same operation multiple times will not change the result **after the initial run**.

**The impact of sending 10 HTTP requests with an idempotent method is the same as sending just one request.**

| HTTP METHOD | Idempotent  | Safe |
|-------------|-------------|------|
| GET         | Yes         | Yes  |
| HEAD        | Yes         | Yes  |
| PUT         | Yes         | No   |
| DELETE      | Yes         | No   |
| POST        | No          | No   |
| PATCH       | No          | No   |

## Using All HTTP Verbs In Our API

### GET

This method is meant to retrieve information from the specified resource in the form of a representation.

The `GET` method can also be used as a "conditional `GET`" when conditional header fields are used and as "partial `GET`" when the `Range` header field is used.

### HEAD

The `HEAD` method works in pretty much the same way as the `GET` method. The only difference is that the server is not supposed to return a body after receiving a `HEAD` request.

It can be used to test a URI before actually sending a request to **retrieve** data.

**The HTTP headers received back by the client should be exactly like the ones it would receive from a `GET` request.**

To run a `HEAD` request with `curl`, we need to use the `-I` option. Simply using the `-X` option and setting it to `HEAD` (`-X HEAD`) will correctly send a `HEAD` request, but it will then wait for the data to be received.
- `curl -I -v http://localhost:4567/users`

### POST

`POST` is as famous as `GET` because it's the only other HTTP method supported by the `HTML` format.

`POST` is supposed to be used only to create new entities, be it as a new database record or as an annotation of an existing resource.

The RFC also specifies how to respond to the client by using specific status codes like `200` (OK), `204` (No Content), or `201` (Created). **The first two codes should only be used if the created entity cannot be specified by a URI;** `200` when the response contains a body and `204` when it does not. Otherwise, `201` should be returned with the `Location` header set to the URI of this new entity.

```ruby
    url = "http://localhost:4567/users/#{user['first_name']}"
    response.headers['Location'] = url
```

### PUT

`PUT` can be used by a client to tell the server to store the given entity at the specified URI. This will not just update it, but will completely replace the entity available at that URI with the one supplied by the client.

`PUT` can also be used to create a new entity at the specified URI if there is no entity identified by this URI yet. In such case, the server should create it.

It would be totally possible to send a `PUT /users` request with a list of users to replace all the users currently stored. However, in most scenarios, it doesn't really make sense to do this kind of thing.

### PATCH

`PATCH` is a bit special. This method is not part of the HTTP RFC 2616, but was later defined in the RFC 5789 in order to do "partial resource modification".

**While `PUT` only allows the complete replacement of a document, `PATCH` allows the partial modification of a resource.**

Just like `PUT`, it uses a unique entity URI like `/users/1` and the server can create a new entity if there is none that exist yet. *However, in my opinion, it's better to keep `POST` **or** `PUT` for creation and only use `PATCH` for updates*.

*It would be also possible to send `PATCH` requests to a URI like `/users` to do partial modifications to more than one user in one request.*

`PATCH` requests can be made idempotent in order to avoid conflicts between multiple updates by using two headers, `Etag` and `If-Match`, to make conditional requests. These headers will contain a value to ensure that the client and the server have the same version of the entity and prevent an update if they have different versions. This not required for every operation, only for the ones where a conflict is possible.

*Since we only send what we want to update in a atomic way, `PATCH` requests are usually smaller in size than the `PUT` ones. This can have a positive impact on the performances of web APIs.*

### DELETE
The `DELETE` method is used by the client to ask the server to delete a resource identified by the specified URI. The server should only tell the client that operation was successful in case it's really going to delete the resource or at least move it to an inacessible location.

The server should send back `200 OK` if it has some content to transfer back to the client or simply `204 No Content` if everything went as planned, but the server has nothing to show for it.

There is also the option of returning `202 Accepted` if the server is planning to delete the resource later, but hasn't had time to do it before the response was sent back.

### OPTIONS

The `OPTIONS` method is a way for the client to ask the server what the requirements are for the identified resource. For example, `OPTIONS` can be used to ask a server what HTTP methods can be applied to the identified resource or which source URL is allowed to communicate with that resource.

Minimally, a server should respond with `200 OK` to an `OPTIONS` request and include the `Allow` header that contains the list of support HTTP methods. **Optimally, the server should send back the details of the possible operations in a documented style.**

## A Global Overview
We are done reviewing and integrating almost all HTTP verbs into our Sinatra API; next, we'll add error handling. Indeed, while building our endpoints, we forgot that clients can make mistakes or just be plain deceptive.

There are two things we can improve quickly:

1. We can extract the method `type = accepted_media_type` that is at the beginning of some of our requests into a method that will load it when we need it and then just reuse it: `@type ||= accepted_media_type`.

2. We can also change the code that sends back either `JSON` or `XML`. The same piece of code is duplicated in multiple places, so we are going to extract it and put it inside a `send_method(data = {})` method.