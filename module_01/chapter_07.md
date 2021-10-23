# Chapter 07 - Versioning

Versioning is considered by many as mandatory in order to create Web APIS that can change. Indeed, due to the tight coupling developer usually create between clients and Web APIs, versioning an API becomes the only solution to make breaking changes without affecting the clients.

What is the best way to version a Web API? 

A lot of people think versioning should be done in the URL like `api.myapi.com`, `/v1/users` or `/users?version=1`. Others believe version should be present in a customer header such as `X-Version`. Finally, a third group, who usually understand more about REST and HTTP, thinks the version should be in the `Accept` header as a customer media type, like:

- `application/vnd.myapi-v1+json`
- `application/vnd.myapi+json; version=1`

Here are all the versioning styles that will be covered:
	
1. Subdomain
	`api1.example.com/users`
2. In the URL
	`example.com/v1/users`
3. In the URL with a query parameter
	`example.com/users?v=1`
4. Custom HTTP Header
	`X-API-Version: 1`
5. Accept header with custom media type
	`Accept: application/vnd.myapi.v2+json`
6. Accept header with a version option
	`Accept: application/vnd.myapi+json; version=2.0`

Keep in mind that resources and representations are two different things. You should never have to version a resource (reminder: resources are just 'concepts'), since only representations tend to change in their formats.
	
**In a perfect world, versioning would not be needed**

## Versioning with a Custom Media Type

The idea here is not to version in the URI, or in a custom header that would version a resource instead of its representation. We are going to use the media type and the `Accept` header to do content negotiation. With this approach, the client can ask for a specific version by giving a media type that can, for instance, look like `application/vnd.myapi.v1+json`.

Remember that the media type, sent in the `Accept` header, is there to allow the client to ask for its preferred format. **Formats are not just JSON or XML; they can be anything**.

### Implementation

For this implementation, we are going to check whether the client requested one supported media type or not. We will expect one media type in the `Accept` header to simplify the code, and we will also expect the client to use a media type that we understand. If it does not, we will send back a `406` error with the list of supported media types.

We are going to support 5 media types:

- `*/*`
- `application/*`
- `application/vnd.awesomeapi+json`
- `application/vnd.awesomeapi.v1+json`
- `application/vnd.awesomeapi.v2+json`

## Accept Header with a Version Option

We are staying in the media type realm, but this time we don't integrate the version number directly in the media type. Instead, the version is passed as an option in the `Accept` header in the following formats:

- `Accept: application/vnd.awesomeapi+json; version=1`
- `Accept: application/vnd.awesomeapi+json; version=2`
	
Note that although we could simply use `application/json`, using a custom media type allows us to explain the format in detail in our documentation.

### Implementation

The code is similar to the previous implementation except that this time, as API developers, we have decided to enforce the use of only one media type. Anything else will trigger a `406` error and will return the only supported media type (`application/vnd.myaesomeapi+json`) and the available versions (`1` or `2`).

Read more about `each_with_object` [here](https://womanonrails.com/each-with-object).

This approach is very clean and it separates versioning and media types, while keeping the URI clean and following HTTP principles.

## No Versioning?

Obviously, the best approach would be no versioning. While it is possible for some APIs to avoid versioning altogether by never introducing breaking changes, most developers will ned to improve their APIs.

In a lot of cases, versioning can be avoided altogether by simply never breaking the existing clients.

1. If you need to add a few attributes to a JSON representation, go ahead, you won't breaking anything (probably).

2. Maybe you also feel the need to change a resource URI? Just create a new resource if you have to. Let's say you have a `users` resource which should now be named `guests` (or whatever), just add the new resource. No need to version it since it's an entirely new concept - if you really have to, then use hypermedia or `3xx` (redirect) to let the client know there was a change.

3. It's another story if you need to rename attributes. The basic advice: don't do it!
	









