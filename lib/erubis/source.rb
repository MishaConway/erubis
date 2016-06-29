module Erubis
  class Source < ::String
    attr_reader :statements

    class Statement
      attr_reader :type, :data

      def initialize type, data
        @type = type
        @data = data
      end

      def write_src src, bufvar
        case type
          when :text
            src << " #{bufvar} << '" << data.gsub(/['\\]/, '\\\\\&') << "';"
          when :expr_literal
            src << " #{bufvar} << (" << data << ').to_s;'
          when :expr_escaped
            src << " #{bufvar} << " << "#{data[:escape_func]}(#{data[:code]})" << ';'
          when :statement
            src << data
            src << ';' unless data[-1] == ?\n
        end
      end
    end

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
      raise "went here with value #{value}"
      @statements << value
      super value
    end

    def add_text text
      @statements << Statement.new(:text, text) unless text.empty?
    end

    def add_statement statement
      @statements << Statement.new(:statement, statement)
    end

    def add_expr_literal code
      @statements << Statement.new(:expr_literal, code.strip)
    end

    def add_expr_escaped code, escape_func
      @statements << Statement.new(:expr_escaped, :code => code.strip, :escape_func => escape_func)
    end
  end
end