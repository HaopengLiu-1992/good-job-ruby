require 'logger'
require 'yaml'

module GoodJob
  module Logging
    def self.included(base)
      base.extend(ClassMethods)
    end

    def logger
      self.class.logger
    end

    module ClassMethods
      def logger
        MyLogger.new(self.name)
      end
    end
  end
end

class MyLogger
  def initialize(config_file = 'settings.yml', klass_name)
    config = YAML.load_file(config_file)
    if config && config.include?('logger')
      logger_config = config['logger']
      logfile = logger_config['logfile']
      level = logger_config['level']
    end
    logfile = 'log/good-job.log' unless logfile
    level = 'info' unless level
    @logger = Logger.new(logfile)
    @logger.level = Logger.const_get(level.upcase)

    stdout_logger = Logger.new(STDOUT)
    stdout_logger.level = @logger.level

    @logger.extend(Module.new {
      define_method(:add) do |severity, message = nil, progname = nil, &block|
        progname = "[#{klass_name}] #{progname}" unless self.class.nil?
        super(severity, message, progname, &block)
        stdout_logger.add(severity, message, progname, &block)
        true
      end
    })
  end

  def debug(message)
    @logger.debug(message)
  end

  def info(message)
    @logger.info(message)
  end

  def warn(message)
    @logger.warn(message)
  end

  def error(message)
    @logger.error(message)
  end

  def fatal(message)
    @logger.fatal(message)
  end

  def close
    @logger.close
  end
end
