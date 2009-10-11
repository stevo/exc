module ErrorProcessors

  module RailsLog
    def self.process(*args)
      RAILS_DEFAULT_LOGGER.error args.first.message
    end
  end

  module Console
    def self.process(*args)
      puts args.first.message
    end
  end

  module CustomLog
    def self.process(*args)
      args.third.each do |custom_logger|
        custom_logger.error args.first.message
      end
    end
  end

  module GlobalFlash
    def self.process(*args)
      err = args.first
      klass = args.second
      extend_klass(klass)
      klass.send(:add_error, err)
    end

    def self.extend_klass(klass)
      unless klass.respond_to?(:message) and  klass.respond_to?(:errors)
        klass.send(:class_inheritable_accessor, :errors)
        klass.errors = []
        klass.send(:extend,ErrorProcessors::GlobalFlash::ClassMethods) unless klass.respond_to?(:message)
      end
      klass
    end

    module ClassMethods
      def message
        result = self.errors.map{|e| ActionView::Base.new.content_tag(:li,e.message)}.join
        self.errors = self.errors.select(&:persistant)
        result
      end

      def add_error(err)
        self.errors.push(err)
      end

      def errors?
        not self.errors.empty?
      end

      def purge_errors!
        self.errors = []
      end
    end
  end
end