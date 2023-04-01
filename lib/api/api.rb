require 'sinatra/base'
require 'sinatra/namespace'
require 'json'
require 'date'
require 'rack-request-id'

class API < Sinatra::Base

  register Sinatra::Namespace
  set :show_exceptions, false
  set :public_folder, File.dirname(__FILE__) + '/public'
  set :server, 'puma'
  set :protection, except: :path_traversal

  namespace '/api/v1' do
    before do
      content_type :json
    end


    post '/execute' do

    end

    get '/jobs/job/:job_id' do

    end

    get '/jobs/all' do

    end

    post 'jobs/cancel/:job_id' do

    end

    get 'workers/status' do

    end
  end
  
  error do
    content_type :json
    status 500 # or whatever

    e = env['sinatra.error']
    { result: 'error', message: e.message, backtrace: e.backtrace }.to_json
  end

  error Sinatra::NotFound do
    content_type :json
    status 404 # or whatever

    e = env['sinatra.error']
    { result: 'unknown method', message: e.message, backtrace: e.backtrace }.to_json
  end
end