module Erubis
  class SourceCompiler
    attr_reader :source, :_binding_object, :_binding, :filename

    def initialize source, _binding_object_or_hash, filename=nil
      @source = source
      @locals = {}
      @filename = filename
      if _binding_object_or_hash.kind_of? Hash
        @_binding_object = ::Object.new
        _binding_object_or_hash.each do |k,v|
          @_binding_object.define_singleton_method k do
            v
          end
        end
      else
        @_binding_object = _binding_object_or_hash
      end
      create_binding
    end

    def evaluate
      @evaluate ||= begin
        output = "_buf = '';"
        if contains_non_literals?
          source.statements.each do |statement|
            statement.write_src(output, :_buf)
          end
          run_eval output
        else
          source.statements.each do |statement|
            result = evaluate_statement statement
            output << result if result
          end
          output
        end
      end
    end

protected

    def contains_non_literals?
      !!source.statements.find do |statement|
        :statement == statement.type || :expr_escaped == statement.type
      end
    end

    def create_binding
      @_binding = @_binding_object.instance_eval { binding }
    end

    def evaluate_statement statement
      case statement.type
        when :text
          statement.data
        when :expr_literal
          begin
            if _binding_object.respond_to? statement.data
              _binding_object.send statement.data
            end || evil_eval(statement.data)
          end.to_s
        else
          raise "unknown statement type"
      end
    end

    def run_eval str
      eval str, _binding, (filename || '(reflective_erubis')
    end
  end
end