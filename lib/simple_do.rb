require "erb"
require "yaml"

require "rubygems"
require "data_objects"
require File.dirname(__FILE__) + "/simple_do/logger"
require "addressable/uri"

module DataObjects
  class Simple
    attr_reader :options, :uri
    
    def initialize(*args)
      if args.size == 3
        @logger = DataObjects::Simple::Logger.new(args.pop)
      end
      if args.size == 2 || args.size == 3
        filename, environment = args
        @options = normalize_keys(render_and_load_yml(filename))[environment.to_s.to_sym]
        @uri = construct_uri(@options)
        load_driver(@options)
      end
    end

    def make_connection
      return DataObjects::Connection.new(@uri)
    end

    def select(query, types = nil, *args)
      log(query, args)
      connection = make_connection
      command = connection.create_command(query)
      command.set_types(types) unless types.nil?
      reader = command.execute_reader(*args)
      rows = []
      while reader.next!
        rows << reader.values
      end
      return rows
    ensure
      reader.close if reader
      connection.close if connection
    end

    def execute(query, *args)
      log(query, args)
      connection = make_connection
      command = connection.create_command(query)
      result = command.execute_non_query(*args)
      return result
    ensure
      connection.close if connection
    end
    alias_method :insert, :execute
    alias_method :update, :execute
    alias_method :delete, :execute

  private
    
    def log(query, variables)
      if @logger
        @logger.log(query, variables)
      end
    end

    def render_and_load_yml(filename)
      return YAML.load(ERB.new(File.read(filename), nil, "-").result)
    end

    # from merb_datamapper
    def normalize_keys(h)
      config = {}
      h.each do |k, v|
        if k == 'port'
          config[k.to_sym] = v.to_i
        elsif k == 'adapter' && v == 'postgresql'
          config[k.to_sym] = 'postgres'
        elsif v.is_a?(Hash)
          config[k.to_sym] = normalize_keys(v)
        else
          config[k.to_sym] = v
        end
      end
      return config
    end

    # stolen mostly from datamapper
    def construct_uri(options)
      options = options.dup
      adapter  = options.delete(:adapter).to_s
      user     = options.delete(:username)
      password = options.delete(:password)
      host     = options.delete(:host)
      port     = options.delete(:port)
      database = options.delete(:database)
      query    = options.to_a.map { |pair| pair * '=' } * '&'
      query    = nil if query == ''

      return Addressable::URI.new(adapter, user, password, host, port, database, query, nil).to_s
    end

    def load_driver(options)
      require "do_#{options[:adapter]}"
    end
  end
end