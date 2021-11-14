# Chapter 14 - Exposing the Books Resource

We are going to start exposing stuff to the outside world, namely the `books` resource. To do so, we need to create the `book` controller and its first action, `index`.

## Creating the Controller

Create the file that will hold the `books` controller in `app/controllers/`.

```
touch app/controllers/books_controller.rb
```

Before adding anything to the controller create the following folders:

```
mkdir spec/requests && touch spec/requests/books_controller_spec.rb
```

The minimum content for this test file is to have a `describe "GET /api/books"` block where we can check that the `GET` method is working properly. In the background, Rails will route this resource to the `books` controller and the `index` action. *The route will be the link between the resource and the controller*.

## The Index Action

The first test we need is to make sure that `GET /api/books` returns `200 OK`.

## Returning Books

We are going to define a few `let`s to avoid repetition in the tests. The `let` is just an elegant way of defining variables in your tests. To give you an idea, defining the following `let`

```ruby
let(:my_variable) { "my variable" }
```

is the equivalent of something like this:

```ruby
def my_variable
  @my_variable ||= "my variable"
end
```

All `let` definitions are wiped between each test!

1. [RSpec fundamentals: setup, naming and basic structure](https://remimercier.com/rspec-101-basic-set-up/#fnref:1)

2. [RSpec fundamentals: a basic glossary](https://remimercier.com/rspec-fundamentals-glossary/)

## Seeding Some Data

If we run `rails server` and head to *http://localhost:3000/api/books*, we get something that looks like this:

```
{
  "data": []
}
```

We need to add seed data to `db/seeds.rb`. After that has been completed, run `rails db:seed` to populate the database.

## Adding a RSpec Helper

In all our request, we will be checking the `json_body` variable. Creating a small RSpec helper will save us from putting `let(:json_body) { JSON.parse(response.body) }` everywhere.

```
mkdir spec/support && touch spec/support/helpers.rb
```



