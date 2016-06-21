module Erubis
  class Source < ::String
    attr_reader :statements

    class Statement
      attr_reader :type, :data

      def initialize type, data
        @type = type
        @data = data
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

    def evaluate( _binding_object_or_hash, filename = nil )
      _hash, _binding_object, _binding = nil, nil, nil
      if _binding_object_or_hash.kind_of? Hash
        _hash = _binding_object_or_hash
      else
        _binding_object = _binding_object_or_hash
        _binding = _binding_object.instance_eval { binding }
      end

      output = ''
      statements.each do |statement|
        result = evaluate_statement _hash, _binding_object, _binding, filename, statement
        output << result if result
      end
      output
    end

    def evaluate_statement _hash, _binding_object, _binding, filename, statement
      case statement.type
        when :text
          statement.data
        when :statement
          evil_eval statement.data, _binding, filename
          nil
        when :expr_literal
          begin
            if _hash
              _hash[statement.data] || _hash[statement.data.to_s] || _hash[statement.data.to_sym]
            else
              _binding_object.send statement.data if _binding_object.respond_to? statement.data
            end || evil_eval(statement.data, _binding, filename)
          end.to_s
        when :expr_escaped
          eval "#{statement.data[:escape_func]}(#{code})"
        else
          raise "unknown statement type"
      end
    end

    def evil_eval code, _binding, filename
      puts "running eval on #{code}"
      result = eval "r = #{code};{:result => r, :locals => local_variables.map{ |l| [l, binding.local_variable_get(l)]}.to_h}", _binding, (filename || '(reflective_erubis')
      puts "evil eval result is #{result.inspect}"
    end

    def << value
      puts "appending #{value} to source"
      raise "went here with value #{value}"
      @statements << value
      super value
    end

    def add_text text
      @statements << Statement.new(:text, text)
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