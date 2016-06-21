module Erubis
  class Source < ::String
    attr_reader :statements

    def initialize str=""
      if str.kind_of? self.class
        @statements = str.statements.clone
        super str.to_s
      else
        @statements = []
        @statements << str if str && str.size > 0
        super str
      end
    end

    def << value
      puts "appending #{value} to source"
      @statements << value
      super value
    end

    def add_text text

    end

    def add_statement statement

    end

    def add_expression_literal

    end
  end
end