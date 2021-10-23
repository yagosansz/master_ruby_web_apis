# Chapter 04 - Media Type Fun

Our web API is currently returning a `JSON` document labeled with the media type for `HTML`.

In this chapter we'll do two things - fix our application and use a couple of headers to start doing some content negotiation.

## Offering `JSON` and `XML`

We still want `/users` to return a `JSON` document by default, but we also want to allow users to use `/users.json` and `/users.xml` if they want to.

```
- Installing lastest version of Gyoku `gem install gyoku --no-document`
```

## The Fundamental Issue With This Approach

While this approach works, it does not follow the principles of the HTTP and URI RFCs. Indeed, we went from having one resource, available at the URI `/users`, to three different ones: `/users`, `/users.json`, and `users.xml`.

We end with three different resources representing the same concept, each one having **one representation**.

## Following The RFC Recommendations

The HTTP header we need for this to work is called `Accept`. This header field allows the client to specify which media types it would like to get. It is defined as a string listing all media types that the client can understand, with an optional priority parameter named `q` that can be added to each media type in the list.

We can also set our server to respond to a client with `415 Unsupported Media Type` status code if the server cannot offer what the client is asking for.

```
# Accept vs Content-Type
The correct way for a client to ask for a specific media type is with the Accept header field. However, HTTP requests that include a body with data, such as POST, can contain the Content-Type header to tell the server in what format the data is sent. This Content-Type header should not be used by the server to decide how to format the response.
```

Sinatra comes with a way to give you the list of accepted media types, sorted by priority.

The `request.accept` array contains a list of `AcceptEntry` objects that we can use to see what the client would like to receive.

## Understanding Media Types

Simply put, a media type defines how some data is formatted and how it can be read by a machine. It allows a computer to differentiate between a `JSON` document and an `XML` document.

### MIME Type

Media types were originally named MIME Types. You will see both in different web technologies and you should know they refer to the same thing.

### The `Accept` Header
As we said earlier, the `Accept` header is used by a client to tell the server what media type it wants and can use. This header is not limited to only one value and multiple types can be chained, separated by commas.

```
Accept: application/xml;q=0.5, text/html;q=0.4, application/json; text/plain;q=0.1
```

The `q` paramter defines something called the **quality factor**. Using this, a client can indicate which media type they would prefer in a prioritized order. The quality factor can range from **0 to 1** and the default value (when `q` is not present) is 1.

## One Resource To Rule Them All

We need to find a way to return the format that the client wants the most (with the highest quality factor as defined in the `Accept` header - which are  given sorted by Sinatra). 

To do that, we are going to create a method named `accepted_media_type`, which will return to us either `JSON` or `XML`.

