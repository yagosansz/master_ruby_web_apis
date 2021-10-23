# webapi_practice.rb
require 'sinatra'
require 'gyoku'

cars = {
  'a3': { model: 'A3', color: 'Red', year: 2021 },
  'rvr': { model: 'RVR', color: 'Dark Grey', year: 2015 },
  'toro': { model: 'Toro', color: 'Black', year: 2019 },
  'wrangler': { model: 'Wrangler', color: 'Green', year: 2022 }
}

deleted_cars = {}

configure do

  mime_type :json, 'application/json'
  mime_type :xml, 'application/xml'

end

helpers do

  def json_or_default?(media_type)
    ['application/json', 'application/*', '*/*'].include?(media_type.to_s)
  end

  def xml?(media_type)
    media_type.to_s == 'application/xml'
  end


  def accepted_media_types
    return 'json' unless request.accept.any?

    request.accept.each do |media_type|
      return 'json' if json_or_default?(media_type)
      return 'xml' if xml?(media_type)
    end

    content_type 'text/plain'
    halt 406, 'application/json, application/xml'
  end

  def type 
    @type ||= accepted_media_types
  end

  def send_data(data = {})
    if type == 'json'
      content_type :json
      data[:json].call.to_json if data[:json]
    elsif type == 'xml'
      content_type :xml
      Gyoku.xml(data[:xml].call) if data[:xml]
    end
  end

end

get '/' do
	'Say Hello to My Cars Web API!'
end

# <HTTP_METHOD> '/cars'

options '/cars' do
  response.headers['Allow'] = 'HEAD, GET, POST'

  status 200
end

head '/cars' do
  send_data()
end

get '/cars' do
  send_data({ json: -> { cars.map { |model, car| car.merge(id: model) } }, 
              xml:  -> { { cars: cars } } })
end

# -d '{"model":"Model","color":"color","year": 0000}'
post '/cars' do
  # request.env['CONTENT_TYPE']
  halt 415, 'application/json' unless request.content_type == 'application/json'

  begin
    car = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    halt 400, send_data({ json: -> { { message: e.to_s } },
                          xml:  -> { { message: e.to_s } } }) 
  end

  existing_car = cars[car['model'].downcase.to_sym]

  if existing_car
    message = { message: "Car model #{existing_car[:model]} already exists in the DB." }

    halt 409, send_data({ json: -> { message },
                          xml:  -> { message } })
  end

  cars[car['model'].downcase.to_sym] = car

  url = "http://localhost:4567/users/#{car['model'].downcase}"
  response.headers['Location'] = url

  status 201
end

[:put, :patch, :delete].each do |method|
  send(method, '/cars') do
    halt 405
  end
end

# <HTTP_METHOD> '/cars/:model'

options '/cars/:model' do |model|
  response.headers['Allow'] = 'GET, PUT, PATCH, DELETE'

  status 200
end

get '/cars/:model' do |model|
  halt 404 unless cars[model.downcase.to_sym]   

  send_data({ json: -> { car.merge(id: model) },
              xml:  -> { { model => car } } })
end

put '/cars/:model' do |model|
  car_model = model.downcase.to_sym
  
  # request.env['CONTENT_TYPE']
  halt 415, 'application/json' unless request.content_type == 'application/json'
  
  begin
    data = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    halt 400, send_data({ json: -> { { message: e.to_s } },
                          xml:  -> { { message: e.to_s } }})
  end

  existing_car = cars[car_model]
  cars[car_model] = data

  if existing_car
    status 204
  else
    url = "http://localhost:4567/cars/#{model.downcase}"
    response.headers['Location'] = url

    status 201
  end
end

patch '/cars/:model' do |model|
  car_model = model.downcase.to_sym

  # request.env['CONTENT_TYPE']
  halt 415, 'application/json' unless request.content_type == 'application/json'
  halt 410 if deleted_cars[car_model]
  halt 404 unless cars[car_model]

  begin
    data = JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    halt 400, send_data({ json: -> { { message: e.to_s } },
                          xml:  -> { { message: e.to_s } }})
  end

  car = cars[car_model]

  data.each do |key, value|
    car[key.to_sym] = value
  end

  cars[car_model] = car

  status 204
end

delete '/cars/:model' do |model|
  car_model = model.downcase.to_sym
  halt 410 if deleted_cars[car_model]
  halt 404 unless cars[car_model]    

  deleted_cars[car_model] = cars[car_model]
  cars.delete(car_model)

  status 204
end
