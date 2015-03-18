require 'rest-client'
require 'json'

require_relative 'ebanx/version'
require_relative 'ebanx/response'
require_relative 'ebanx/command/command'
require_relative 'ebanx/command/cancel'
require_relative 'ebanx/command/capture'
require_relative 'ebanx/command/exchange'
require_relative 'ebanx/command/print_html'
require_relative 'ebanx/command/query'
require_relative 'ebanx/command/refund'
require_relative 'ebanx/command/refund_or_cancel'
require_relative 'ebanx/command/request'
require_relative 'ebanx/command/token'
require_relative 'ebanx/command/zipcode'
require_relative 'ebanx/command/direct'

module Ebanx
  @test_mode = false

  class << self
    attr_accessor :integration_key, :test_mode, :parse_response
  end

  def self.base_uri
    if @test_mode
      'https://sandbox.ebanx.com/ws/'
    else
      'https://api.ebanx.com/ws/'
    end
  end

  protected
  def self.run_command(method, params)
    klass = get_command_class method

    raise ArgumentError if !params[0] || params[0].length == 0

    params = params[0].merge! integration_key: @integration_key
    command = klass.new params

    command.valid?

    request command
  end

  def self.request(command)
    uri = Ebanx::base_uri + command.request_action
    case command.request_method
      when :post then response = RestClient.post uri, command.params, content_type: command.response_type
      when :get  then response = RestClient.get uri, params: command.params
    end
    Ebanx::Response.new response, command.response_type
  end

  def self.method_missing(method, *args, &block)
    if method.to_s =~ /^do_[a-z]+/
      run_command method.to_s, args
    else
      super
    end
  end

  def self.get_command_class(method)
    method = method.gsub /^do_/, ''
    class_name = 'Ebanx::Command::' + method.split('_').map { |w| w.capitalize }.join
    Object.const_get class_name
  end
end