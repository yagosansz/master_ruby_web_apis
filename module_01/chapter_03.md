# Chapter 03 - Understanding HTTP Requests with curl
We will use `curl` to define our requests, with which data can be transferred through various protocols including, but not limited to, HTTP.

A web browser can be used to test some parts of a web API, but it is very limited. Indeed, we can only run `GET` requests using a browser, and only if there is no HTTP Header to change.

## `curl` Crash Course
`curl` is a tool to transfer data from or to a server, using one of the supported protocols (e.g.: HTTP, HTTPS, FTP, SFTP).

A curl request is composed of the `curl` word, the `URL` you want to hit, and a set of options that allow you to modify anything you'd like in the request that will be sent.

Here are a few options we need to know how to write our first requests:

- `-H`: Shorthand for Header, this option lets us add/replace HTTP Header Fields. Example: `-H "Content-Type: application-json"`.

- `-d`: Shorthand for data, this is the option we'll use when we need to send data to the server. Example: `-d '{"name":"John Smith"}'`.

- `-i`, `-include`: This option tells `curl` to display both the body and the headers of the response sent back.

- `-X`, `-request`: This option specifies what kind of HTTP method we want to use in our request. The default is `GET` but we can use this option to send `POST`, `PUT`, `PATCH`, or `DELETE` requests, for example.

## Our First `curl` request

Run the following command in the terminal:
```
curl -i http://localhost:4567/users
```

The response should be:

```
HTTP/1.1 200 OK
Content-Type: text/html;charset=utf-8
Content-Length: 203
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Connection: keep-alive
Server: thin

[
  {"first_name":"Thibault", "last_name":"Denizet", "age":25, "id":"thibault"},
  {"first_name":"Simon", "last_name":"Random", "age":26, "id":"simon"},
  {"first_name":"John", "last_name":"Smith", "age":28, "id":"john"}
]
```

## HTTP Response

What curl displayed for us is an HTTP response. This response can be divided into four areas:

1. The `Start-Line` (mandatory)

- It contains the `Request-Line` and the `Status-Line`
	```
	HTTP/1.1 200 OK
	```

2. A list of `Header Fields` (can be 0 or more)

- The header fields represent the metadata of the HTTP requests and responses. Some of the headers in our response are:

	+ `Content-Type`: It contains the media type of the representation.
	+ `Server`: It contains information about the software that handled the request. In our case that's the Ruby web server `thin`.

- Non-official headers start, by convention, with an `X`. They are used to add metadata to the HTTP requests/responses to deal with specific problems.

3. An `Empty Line` (mandatory)
	It defines the end of the list of headers and the beginning of the body (if there is one).

4. A `Message-Body` (optional)
	It contains the data the server is sending back based on the request we made.

## HTTP Request

We now know what the server sent back to us! **But what did we send!?**

```
curl -v -i http://localhost:4567/users
```

Here's the output - response not included:

```
*   Trying ::1:4567...
* TCP_NODELAY set
* Connected to localhost (::1) port 4567 (#0)
> GET /users HTTP/1.1 // Start-Line
> Host: localhost:4567 // Header Field 1: Contains the address where the resource is found
> User-Agent: curl/7.68.0 // // Header Field 2: Emitter of the request
> Accept: */*
> 
... Response ...
```
