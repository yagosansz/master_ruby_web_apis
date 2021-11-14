# Chapter 13 - Adding Books and Authors

In this chapter, we will be focusing on completing the basic set of models we need before creating any endpoint. To accompany the `Publisher` model, we are going to create the `Book` and `Author` models. Finally, we will update the `Publisher` model since it's currently incomplete.

## The Author Model

Run the corresponding `model` generator:

```
rails generate model Author given_name:string family_name:string
```

Execute the migration:

```
rails db:migrate && rails db:migrate RAILS_ENV=test
```

## The Book Model

Run the corresponding `model` generator:

```
rails generate model Book title:string subtitle:text isbn_10:string:uniq \
isbn_13:string:uniq description:text released_on:date \
publisher:references author:references
```

Open the generated migration file and an index to the following attributes: title, isbn_10, isbn_13, publisher_id, and author_id.
  - Both `isbn_10` and `isbn_13` have to be unique!

**### CORRECTION ###**

>The uniqueness constraint was not properly added when generating the *Book* model and I've added a fix for it. You can also edit the migration file like the in the example below, if you already ran the migration and don't want to rollback:

```ruby
t.string :isbn_10, index: { unique: true }
t.string :isbn_13, index: { unique: true }
```

I was able to find that error thanks to [Rubocop](https://github.com/rubocop/rubocop). You can also read more about it on this greate [ThoughtBot Article](https://thoughtbot.com/blog/the-perils-of-uniqueness-validations).

**### CORRECTION ###**

Execute the migration:

```
rails db:migrate && rails db:migrate RAILS_ENV=test
```

## Associations

We have three different models (`Publisher`, `Author`, and `Book`) that are related.

### Author Associations

### Publisher Associations

### Book Associations

We need to add `required: false` for an optional association. Publishers are optional since authors can self-publishe their books. In that case, `publisher` should be `nil`.

## Handling Book Covers

Uploading files to a Web API is a bit different from using an HTML form and the `multipart/form-data` media type.

Since any client should be able to send images to our API, we are going to use a different approach that will work the same way on both mobile and JavaScript applications. The idea is simply to enconde the file in the client in *Base64*, send it, and let the server decode it and store it.

For this purpose, we're going to use [carrierwave](https://github.com/carrierwaveuploader/carrierwave) and [carrierwave-base64](https://github.com/y9v/carrierwave-base64)

Add the 2 gems bellow to your `Gemfile` then run `bundle install`:

```
gem 'carrierwave'
gem 'carrierwave-base64'
```

>If you have trouble understanding how *carrierwave* is working behind the scenes watch [File Uploading in Rails with Carrierwave](https://www.youtube.com/watch?v=Q8wF9RrJhrY).

Generate the file that will contain the configuration for *carrierwave*:

```
rails generate uploader Cover
```
After configuring *app/uploaders/cover_uploader.rb* we need to add the `cover` column to the `books` table.

```
rails generate migration AddCoverToBook cover:string
```

If you try to run `rails console` and end up with an uninitialized constant error, add the lines bellow to your *config/application.rb*:

```
require 'carrierwave'
require 'carrierwave/orm/activerecord'
```