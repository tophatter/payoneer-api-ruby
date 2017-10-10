module Payoneer
  class Response
    OK_STATUS_CODE = '000'.freeze

    attr_reader :code, :body

    def initialize(code, body)
      @code = code
      @body = body
    end

    def ok?
      code == OK_STATUS_CODE
    end

    def ==(other)
      code == other.code && body == other.body
    end
  end
end
