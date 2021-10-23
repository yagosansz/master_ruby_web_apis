# Chapter 06 - Handling Errors

It's the server's duty to provide descriptive errors to the client.

The obvious problem in our current web API is that we don't send back meaningful errors when something goes wrong.

HTTP comes with a set of features to handle errors. Indeed, thanks to all its HTTP status codes, we can configure our API to send back descriptive error messages to a client in a format that it can understand.

## The Different Classes of HTTP Status Codes

- `1XX` Informational: most of the informational codes are rarely used nowadays.
- `2XX` Success: these codes indicate that the exchange between the server and the client was successful.
- `3XX` Redirection: these codes indicate that the client must take additional action before the request can be completed.
- `4XX` Client Error: there was something wrong with the request the client sent and the server could not process it.
- `5XX` Server Error: the client sent a valid request but the server was not able to process it successfully.

## Global

We will add error handling for each route, but let's first see the errors we need to handle for **every** request.

### 405 *Method Not Allowed*

This HTTP status code can be used when the client tries to access a resource using an unsupported HTTP method. For example, what would happen if we tried to use the `PUT` method with the `/users` URI?

### 406 *Not Acceptable*

If the client requests a media type that our API does not support, we will return `406 Not Acceptable`. To the client receiving this, it means that the server was not able to generate a representation for the resource according to the criteria the client had fixed.

The response should also include what formats are actually available for the client to pick from.

Alternatively, we could actually return a JSON representation instead of telling the client that we can't give it anything. We would set the `Content-Type` header to `application/json` to let the client do its own checking before parsing the response. Both options are acceptable as defined in the HTTP RFC.

## POST /users

For the `post /users` route, we are currently not handling any errors.

### 415 Unsupported Media Type

`415 Unsupported Media Type` is exactly what its name implies - we can return it to the client when we don't understand the format of the data sent by the client.

First we need to check if the data is being sent as JSON document, the only format we support for requests.

### 400 Bad Request

The `400 Bad Request` is used way to often in modern web applications. Its real purpose is to indicate that the server could not understand the request due to some syntax issue. For example, a malformed JSON document.


### 409 Conflict

Currently, if we try to re-create a user that already exists, it's just going to override the existing one. Not good. This should throw up some kind of conflict error saying that a user cannot be overriden. The problem here is how we save users in a Ruby hash. Since we use the first name as key, we don't want to allow an existing user to be overriden.

Luckly, that's what the `409 Conflict` HTTP code is for. **Note that this code is only allowed in situations where the client can actually fix the conflict**. In our case, the client can either change the first name or use another endpoint to update the user.

## GET /users/:first_name

We know our endpoint works when the user exists. But what happens when it doesn't?

### 404 Not Found

This code is meant to tell the client that nothing was found at the URI specified by the client; in other words, the requested resource does not exist.

### 410 Gone

Sadly `404 Not Foud` can seem quite generic to a client. We can use other codes to give a more specific response. One of them is `410 Gone` which indicates that a resource used to live at the given URI, but doesn't anymore.

Currently, if we delete a user and then try to access it, we will just get `404`, as if it never existed.

It's not always possible for a server to indicate a deleted resource and there is nothing forcing us to use this HTTP status. It is helpful for the client though, since it will let the client know that this URI does not point to anything **anymore**.

In a production application with a real database, it is possible to achieve this kind of mechanism by using a boolean to check if something has been deleted or not.

## PUT /users/:first_name

For this route, we can handle `415 Unsupported Media Type` and `400 Bad Request`.

## PATCH /users/:first_name

For this route, we can handle `415 Unsupported Media Type`, `404 Not Found`, `410 Gone`, and `400 Bad Request`. You can get inspired by what we did for `PUT /users/:first_name` and `GET /users/:first_name`





