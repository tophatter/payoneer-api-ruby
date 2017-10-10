module Payoneer
  class ResponseError < StandardError
    attr_reader :code, :body

    def initialize(code:, body:)
      @code = code
      @body = body
    end
  end
end
