# webapi_basic_auth.rb
require 'sinatra'

use Rack::Auth::Basic, 'User Area' do |username, password|
  username == 'john' && password == 'pass'
end

get '/' do
  'Master Ruby Web APIs - Chapter 9'
end