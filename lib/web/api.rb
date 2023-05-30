require 'sinatra'
require 'sinatra/namespace'
require 'json'
require 'webrick'

class API < Sinatra::Base
  register Sinatra::Namespace

  configure do
    set :show_exceptions, false
    set :public_folder, File.dirname(__FILE__) + '/public'
  end

  namespace '/api/v1' do
    before do
      content_type :json
    end

    ###############
    # Diagnostics
    ###############

    get '/diagnostic' do
      200
    end

    get '/ping' do
      200
    end

    get '/' do
      send_file File.dirname(__FILE__) + '/public/index.html'
    end

    post '/start_job' do
      opts = JSON.parse(request.body.read)
      job_name = opts["name"]
      resp = settings.manager.start_job(job_name)
      status = resp[:status]
      if status
        msg = {
          job_id: resp[:job_id],
          check_status_url: "#{request.base_url}/api/v1/#{resp[:job_id]}"
        }
        [201, msg.to_json]
      else
        [403, { message: resp[:message] }.to_json]
      end
    end

    get '/:job_id' do
      resp = settings.manager.get_job_status(params[:job_id])
      if resp[:job_exist]
        [200, resp.to_json]
      else
        [404, resp.to_json]
      end
    end

    get '/jobs/all' do
      [200, settings.manager.get_all_jobs.to_json]
    end

    get '/status/workers' do
      resp = settings.manager.get_worker_status
      if resp[:statuses]
        [200, resp.to_json]
      else
        [404, resp.to_json]
      end
    end

    post '/cancel' do
      opts = JSON.parse(request.body.read)
      job_id = opts['job_id']
      resp = settings.manager.cancel_job(job_id)
      if resp[:cancelled]
        [200, resp.to_json]
      else
        [404, resp.to_json]
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
end
