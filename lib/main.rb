require_relative 'setup'
require_relative 'manager'

settings = GoodJob::Setup.settings
GoodJob::Manager.new(settings).run
