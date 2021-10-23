# webapi_token_auth.rb
require 'sinatra'
require 'json'

users = { 'thibault@samurails.com' => 'supersecret' }

tokens = {}
access_token = ''

helpers do 
  def unauthorized!
    response.headers['WWW-Authenticate'] = 'Token realm="Token Realm"'
    halt 401
  end

  def authenticate!(tokens)
    auth = env['HTTP_AUTHORIZATION']

    unauthorized! unless auth && auth.match(/Token .+/)
    
    _, access_token = auth.split(' ')

    unauthorized! unless tokens[access_token]
  end
end

get '/' do
  authenticate!(tokens)
  'Master Ruby Web APIs - Chapter 9'
end

post '/login' do
  params = JSON.parse(request.body.read)
  email = params['email']
  password = params['password']

  content_type 'application/json'

  if users[email] && users[email] == password
    token = SecureRandom.hex

    tokens[token] = email
    { 'access_token' => token }.to_json
  else
    halth 400, { error: 'Invalid username or password.' }.to_json
  end
end

delete '/logout' do
  authenticate!(tokens)
  tokens.delete(access_token)
  access_token = ''
  halt 204
end







