# webapi_server_caching.rb
require 'sinatra'
require 'json'
require 'digest/sha1'

users = {
  revision: 1,
  list: {
    thibault: { first_name: 'Thibault', last_name: 'Denizet', age: 25 },
    simon:    { first_name: 'Simon', last_name: 'Random', age: 26 },
    john:     { first_name: 'John', last_name: 'Smith', age: 28 }
  }
}

cached_data = {}

helpers do
  def cache_and_return(cached_data, key, &block)
    cached_data[key] ||= block.call
    cached_data[key]
  end
end

before do
  content_type 'application/json'
end

get '/users' do
  key = "users:#{users[:revision]}"

  cache_and_return(cached_data, key) do
    (1..1000).each_with_object([]) do |item, array|
      users[:list].each do |name, data|
        array << data
      end
    end.to_json
  end
end

put '/users/:first_name' do |first_name|
  user = JSON.parse(request.body.read)
  existing = user[:list][first_name.to_sym]
  users[:list][first_name.to_sym] = user
  users[:revision] += 1
  status existing ? 204 : 201
end