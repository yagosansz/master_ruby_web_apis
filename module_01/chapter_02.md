# Chapter 02 - A Simple Sinatra API to Learn The Basics

Installing Sinatra: `gem install sinatra --no-document`

The following command is the usual way to start a simple `Sinatra` application, but it can be changed for bigger ones by using *Rack* and the `rackup` comand.

```
ruby webapi.rb
```

### HTTP and URIs

In the scope of HTTP, URIs are "simply formatted strings which identify - via name, location, or any other characteristic - a resource".

A `resource` is the `thing` living on the other side of a URI and a URI only points to one resource. 

```
http://example.com/users
```

This URL points to a resource named `users`. Note that we can never retrieve this resource; instead, we can only get a representation of it. So we can say that a resource never changes, only its representations do.

Making a request to this URL would return a representation listing a bunch of users. Anyone would be able to understand this, and seeing the representation will just confirm their idea about this resource.

Remember that we are only getting representations of the "users" concept, and not the concept itself. You cannot transfer a concept over the Internet, only its representations, which can be  sent in different formats (e.g.: JSON, XML).
- One URI points to a single resource that can be represented in many different ways!