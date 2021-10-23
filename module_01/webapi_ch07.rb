# webapi_ch07.rb
require 'sinatra'
require 'json'

# Will be used in the XML route
require 'gyoku'

users = {
  'thibault': { first_name: 'Thibault', last_name: 'Denizet', age: 25 },
  'simon':    { first_name: 'Simon', last_name: 'Random', age: 26 },
  'john':     { first_name: 'John', last_name: 'Smith', age: 28 },
  'frank':    { first_name: 'Frank', last_name: 'Sinatra', age: 51 },
  'yago':     { first_name: 'Yago', last_name: 'Santos', age: 81 }
}

deleted_users = {}

helpers do

  def json_or_default?(type)
    %w(application/json application/* */*).include?(type.to_s)
  end

  def xml?(type)
    type.to_s == 'application/xml'
  end

  def accepted_media_type
    # Guard Clause
    return 'json' unless request.accept.any?

    request.accept.each do |media_type|
      return 'json' if json_or_default?(media_type)
      return 'xml' if xml?(media_type)
    end

    content_type 'text/plain'
    halt 406, 'application/json, application/xml'
  end

  def type
    @type ||= accepted_media_type
  end

  def send_data(data = {})
    if type == 'json'
      content_type 'application/json'
      data[:json].call.to_json if data[:json]
    elsif type == 'xml'
      content_type 'application/xml'
      Gyoku.xml(data[:xml].call) if data[:xml]
    end   
  end

end

get '/' do
  'Master Ruby Web APIs - Chapter 2'
end

# /users

options '/users' do
  response.headers['Allow'] = 'HEAD, GET, POST'
  status 200
end

head '/users' do
  send_data()
end

get '/users' do
  send_data({ json: -> { users.map { |name, data| data.merge(id: name) } },
              xml:  -> { { users: users } } })  
end

post '/users' do
  halt 415, 'application/json' unless request.env['CONTENT_TYPE'] == 'application/json'

  begin
    user = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    halt 400, send_data(json: -> { { message: e.to_s } },
                        xml:  -> { { message: e.to_s } })
  end
  
  if users[user['first_name'].downcase.to_sym] 
    message = { message: "User #{user['first_name'].downcase} already in DB."}
       halt 409, send_data(json: -> { message },
                           xml:  -> { message })
  end

  users[user['first_name'].downcase.to_sym] = user
  
  url = "http://localhost:4567/users/#{user['first_name']}"
  response.headers['Location'] = url

  status 201
end

[:put, :patch, :delete].each do |method|
  send(method, '/users') do
    halt 405
  end
end

# /users/:first_name

options '/users/:first_name' do
  response.headers['Allow'] = 'GET, PUT, PATCH, DELETE'
  status 200
end

get '/users/:first_name' do |first_name|
  halt 410 if deleted_users[first_name.downcase.to_sym]
  halt 404 unless users[first_name.downcase.to_sym]

  send_data({ json: -> { users[first_name.to_sym].merge(id: first_name) },
              xml:  -> { { first_name => users[first_name.to_sym] } } })
end

put '/users/:firs_name' do |first_name|
  halt 415, 'application/json' unless request.env['CONTENT_TYPE'] == 'application/json'

  begin
    user = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    halt 400, send_data({ json: -> { { message: e.to_s } },
                          xml:  -> { { message: e.to_s } } })
  end

  existing = users[first_name.downcase.to_sym]
  users[first_name.downcase.to_sym] = user

  status existing ? 204 : 201 
end


patch '/users/:first_name' do |first_name|
  halt 415, 'application/json' unless request.env['CONTENT_TYPE'] == 'application/json'

  begin
    user_client = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    halt 400, send_data({ json: -> { { message: e.to_s } },
                          xml:  -> { { message: e.to_s } } })
  end
  
  first_name = first_name.downcase.to_sym
  
  halt 410 if deleted_users[first_name]
  halt 404 unless users[first_name] 

  user_server = users[first_name]

  user_client.each do |key, value|
    user_server[key.to_sym] = value
  end

  send_data({ json: -> { user_server.merge(id: first_name) },
              xml:  -> { { first_name => user_server } } })
end

delete '/users/:first_name' do |first_name|
  first_name = first_name.downcase.to_sym
  deleted_users[first_name] = users[first_name] if users[first_name]
  users.delete(first_name)
  status 204
end