# todo_webapi.rb
require 'sinatra'

# Will be used in the XML route
require 'gyoku'


# "name":"Spiritual","description":"Yoga Class","status":0,"due_date":"2021-09-21"

tasks = {
	'intellectual': { name: 'Intellectual', description: 'Study APIs', status: 1, due_date: '2021-09-18' },
	'physical': { name: 'Physical', description: 'Bike to the Park', status: 0, due_date: '2021-09-18' },
	'social': { name: 'Social', description: 'Watch Marvel Movie', status: 0, due_date: '2021-09-20' }
}

deleted_tasks = {}


helpers do
	def json_or_default(type)
		%w(application/json application/* */*).include?(type)
	end

	def xml?(type)
		'application/xml' == type
	end

	def accepted_media_type
		return 'json' unless request.accept.any?

		request.accept.each do |mt|
			media_type = mt.to_s

			return 'json' if json_or_default(media_type)
			return 'xml' if xml?(media_type)
		end

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
	'Welcome to the Sinatra To-Do Web API !!!'
end

# route: '/tasks'

[:put, :patch, :delete].each do |http_method|
	send(http_method, '/tasks') do
		halt 405
	end
end

options '/tasks' do
	response.headers['Allow'] = 'HEAD, GET,POST'	
	status 200
end

get '/tasks' do 
	send_data(json: -> { tasks.map { |name, data| data.merge(id: name) } },
		        xml:  -> { { tasks: tasks } })
end

head '/tasks' do
	type = accepted_media_type

	if type == 'json'
		content_type 'application/json'		
	elsif type == 'xml'
		content_type 'application/xml'
	end
end

post '/tasks' do
	# request.media_type
	unless request.env['CONTENT_TYPE'] == 'application/json'
		halt 415, 'application/json'
	end

	begin
		task = JSON.parse(request.body.read)
	rescue JSON::ParserError => e
		halt 400, send_data(json: -> { { message: e.to_s } },
			                  xml:  -> { { message: e.to_s } })
	end

	task_name = task['name'].downcase.to_sym

	# Conflict
	if tasks[task_name]
		message = { message: "Task #{task['name']} already exists." }
		halt 409, send_data(json: -> { message },
			                  xml:  -> { message })		
	end

	tasks[task_name] = task

	url = "http://localhost:4567/tasks/#{task_name}"
	response.headers['Location'] = url

	status 201	
end

# route: '/tasks/:name'

options '/tasks/:name' do
	response.headers['Allow'] = 'GET, PUT, PATCH, DELETE'
	status 200
end

get '/tasks/:name' do
	task_name = params[:name].to_sym

  halt 410 if deleted_tasks[task_name]
	halt 404 unless tasks[task_name]

	send_data(json: -> { tasks[task_name].merge(id: params[:name]).to_json },
		        xml:  -> { { task_name => tasks[task_name] } })
end

put '/tasks/:name' do
	unless request.media_type == 'application/json'
		halt 415, 'application/json'
	end
	
	begin
		task = JSON.parse(request.body.read)
	rescue JSON::ParserError => e
		halt 400, send_data(json: -> { { message: e.to_s } },
											  xml:  -> { { message: e.to_s } })
	end

	task_name = params[:name].to_sym

	existing_task = tasks[task_name]
	tasks[task_name] = task

	status existing_task ? 204 : 201 
end

patch '/tasks/:name' do
	unless request.media_type == 'application/json'
		halt 415, 'application/json'
	end

	begin 
		task_client = JSON.parse(request.body.read)
	rescue JSON::ParserError => e
		halt 400, send_data(json: -> { { message: e.to_s } },
												xml:  -> { { message: e.to_s } })
	end

	task_name = params[:name].to_sym

	halt 410 if deleted_tasks[task_name]
	halt 404 unless tasks[task_name]

	task_server = tasks[task_name]

	task_client.each do |key, value|
		task_server[key.to_sym] = value
	end

	send_data(json: -> { task_server.merge(id: params[:name]).to_json },
		        xml:  -> { { task_name => task_server } })
end

delete '/tasks/:name' do
	task_name = params[:name].to_sym

	halt 404 unless tasks[task_name]

	deleted_tasks[task_name] = tasks[task_name] if tasks[task_name]
	tasks.delete(task_name)

	status 204
end

