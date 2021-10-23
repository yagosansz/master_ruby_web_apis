# webapi_no_version.rb
require 'sinatra'
require 'json'

users = {
  thibault: { first_name: 'Thibault', last_name: 'Denizet', age: 25 },
  simon:    { first_name: 'Simon', last_name: 'Random', age: 26 },
  john:     { first_name: 'John', last_name: 'Smith', age: 28 }
}

helpers do
  
  def present_user(name, data)
    {
      id: name,
      full_name: "#{data[:first_name]} #{data[:last_name]}",
      first_name: data[:first_name],
      last_name: data[:last_name],
      age: data[:age]
    }
  end

end


get '/users' do
  media_type = request.accept.first.to_s

  unless ['*/*', 'application/*', 'application/json'].include?(media_type)
    halt 406
  end

  content_type 'application/json'
  users.map { |name, data| present_user(name, data) }.to_json

end