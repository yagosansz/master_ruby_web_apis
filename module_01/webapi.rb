# webapi.rb
require 'sinatra'
require 'json'

users = {
  'thibault': { first_name: 'Thibault', last_name: 'Denizet', age: 25 },
  'simon':    { first_name: 'Simon', last_name: 'Random', age: 26 },
  'john':     { first_name: 'John', last_name: 'Smith', age: 28 },
  'frank':    { first_name: 'Frank', last_name: 'Sinatra', age: 51 },
  'yago':     { first_name: 'Yago', last_name: 'Santos', age: 81 }
}

get '/' do
  'Master Ruby Web APIs - Chapter 2'
end


get '/users' do
  users.map { |name, data| data.merge(id: name) }.to_json
end