require 'processors'

ExcS = Struct.new(:message, :persistant, :obj)

class ExcErrorHandler
  AVAILABLE_PROCESSORS = %w(console rails_log custom_log)
  DEFAULT_TIMESTAMP = "%Y.%m.%d %H:%M:%S"

  class_inheritable_accessor :timestamp, :processors

  self.processors = []
  self.timestamp = DEFAULT_TIMESTAMP

  def initialize(e, *args)
    begin
      options = args.extract_options!

      err = if e.kind_of? Exception
        ExcS.new("#{timestamp} > #{e.message}",options[:persistant],e || options[:object])
      elsif e.respond_to?(:to_s)
        ExcS.new("#{timestamp} > #{e.to_s}",options[:persistant],nil || options[:object])
      end

      self.class.process err, options
    rescue => exception
      return nil if RAILS_ENV=='production'
      raise exception
    end
  end

  def timestamp
    timestamp = self.class.timestamp ? "@#{Time.now.strftime(self.class.timestamp)}" : ''
    "[#{self.class.name}]#{timestamp}"
  end

  class << self

    def process(err,options)
      processors.each do |processor, processor_options|
        "ErrorProcessors::#{processor.to_s.classify}".constantize.process(err,self,processor_options)
      end
    end

  end

end

class ErrorMessageHandler
  def self.new(*args)
    klass = Class.new(ExcErrorHandler)
    options = args.extract_options!
    klass.timestamp = options.delete(:timestamp) unless options[:timestamp].nil?
    klass.processors = options
    #custom
    ErrorProcessors::GlobalFlash.extend_klass(klass) if klass.processors[:global_flash]
    return klass
  end
end
