# Chapter 12 - Alexandria: Setup Time

## Setting up our Environment

[asdf](https://github.com/asdf-vm/asdf).

Installing Ruby:rail
```
asdf plugin add ruby
asdf install ruby 2.7.2
asdf global ruby 2.7.2
```

Installing Rails:
```
gem install bundler rails
```

## Creating the Application

```
rails new alexandria --api --skip-test-unit
```

## Testing Environment

### Why Write Automated Tests?

Writing tests is important so you can catch bugs as soon as possible, which should be before they leave your local environment.

Automated tests have a huge amount of benefits:

- Prevent regressions
  + You fixed an annoying bug and wrote a test for it to identify where the problem lies and document your solution. If someone breaks it in the future, the test will fail again and the regression won't make it to production.

- Reduce the number of bugs
  + When you write automated tests, you identify different scenarios that could occur. Some of these scenarios will trigger unexpected behaviour in your code. The only way to find them is to either test the code manually or write automated tests.

- Simplified refactoring
  + Having automated tests check the output of what you are refactoring will let you make changes safely and with more confidence, leading to an improved code quality.

- Ensure the code is doing what it is supposed to do
  + Following either TDD or BDD approach, lets you focus on writing the minimum amount of code necessary to make the test pass. This leads to simpler and smaller code.

- Make it easier to integrate people into the team
  + By having a strong test suite, the team can be confident that newcomers will change things safely and will know when they break something.

- Less (or no) manual testing
  +  For bigger projects, a test suite can save a huge amount of time and prevent the need of manually testing new code.

### Different Types of Tests

Rails applications can be composed of many different entities: models, controllers, views, serializers, and everything in between. Testing them requires writing test in different styles.

- **Unit Tests**: Those tests allow to test different parts of your system in isolation. They are fast because they don't need the whole project to run.
- **Integration Tests**: They rely on more components and test systems at a higher level, tending to be slower and bigger than unit tests. *Request tests in Rails are integration tests.*
- **Hybrid Tests**: Those tests are not meant to test the whole system or individual components, instead they will test a few components together, like controller and model - just like in Rails controller tests.

> The RSpec team discourages the use of `spec/controllers`. Testing `spec/requests` allows us to test a controller's actions through the stack (routing, request, response, etc.) versus testing the controller in isolation. *Source*: [RSpec fundamentals: setup, naming and basic structure](https://remimercier.com/rspec-101-basic-set-up/#fnref:1)

> https://remimercier.com/rspec-fundamentals-glossary/

### Setting up the Tools

Tools that can be used to implement tests in a Rails API:

- RSpec
- factory_bot
- Database Cleaner
- Webmock
  + It's a *library for stubbing and setting expectations on HTTP requests in Ruby*.
- Shoulda-Matchers
  + *It provides RSpec- and Minitest-compatible one-liners that test common Rails functionality. These tests would otherwise be much longer, more complex, and error-prone*.

After updating your `Gemfile` accordingly, run `rails generate rspec:install`:

```
create  .rspec
create  spec
create  spec/spec_helper.rb
create  spec/rails_helper.rb
```

- `.rspec`: This file contains the configuration for *RSpec* itself - for instance, if the test's output should be colored or not.
- `/spec`: This folder stores all our tests.
- `spec/spec_helper.rb`: It contains the basic configuration required to run tests that don't rely on Rails.
- `spec/rails_helper.rb`: It's just like the `spec_helper`, but for all tests that depend on the Rails stack.

**ADD LINK TO `spec_helper.rb`**

## Our First Test

We are going to use the **RED-GREEN-REFACTOR** cycle to write our first tests.

Our API is going to need a model to represent publishers. Before we write any tests, let's begin by creating the `Publisher` model and the associated table in the database.

### The Publisher Model

We can generate our model with the following command:

```
rails generate model Publisher name:string
```

Let's run the newly generated migration in the `development` and `test` environments:

```
rails db:migrate && rails db:migrate RAILS_ENV=test
```

### RSpec Vocabulary

There are some methods that make it easier to organize and manage your code by grouping tests.

- `describe`: it's used to define the target for a set of tests. `describe '#valid?' do ... end` means that we're writing tests for the `valid?` method.
- `context`: it allows us to define specific situations and write tests for each one of them. For instance, take the two contexts below:

```ruby
context 'with valid params' do ... end
```

```ruby
context 'with invalid params' do ... end
```

With those contexts, we can easily group tests that share the same context.

- `it` is used to define a test. It takes one parameter, the name of the test, and a block which contains the expectations.
- `expect` is a method which defines what the expected output for a given input should be.

>Originally, it was recommended to name your test using the `should` verb as in `it 'should work'`. Nowadays, the best practice is to simply use the verb presenting the expected behaviour like `it 'works'`.

### Validation Test

Using `Shoulda-Matchers` allows us to write one-liner validations:

```ruby
it { should validate_presence_of(:name) }
```

The longer version of the same validation test would be:

```ruby
it "is invalid when name is nil" do
  publisher = Publisher.new(name: nil)
  expect(publisher.valid?).to_be false
end

it "is invalid when name is empty" do
  publisher = Publisher.new(name: "")
  expect(publisher.valid?).to_be false
end

it "valid with a name" do
  publisher = Publisher.new(name: "O'Reilly")
  expect(publisher.valid?).to_be true
end
```









