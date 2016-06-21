##
## $Release:$
## $Copyright$
##

require 'erubis/engine'
require 'erubis/enhancer'


module Erubis


  ##
  ## code generator for Ruby
  ##
  module RubyGenerator
    include Generator
    #include ArrayBufferEnhancer
    include StringBufferEnhancer

    def init_generator(properties={})
      super
      @escapefunc ||= "Erubis::XmlHelper.escape_xml"
      @bufvar     = properties[:bufvar] || "_buf"
    end

    def self.supported_properties()  # :nodoc:
      return []
    end

    def escape_text(text)
      text.gsub(/['\\]/, '\\\\\&')   # "'" => "\\'",  '\\' => '\\\\'
    end

    def escaped_expr(code)
      return "#{@escapefunc}(#{code})"
    end

    #--
    #def add_preamble(src)
    #  src << "#{@bufvar} = [];"
    #end
    #++

    def add_text(src, text)
      statement = escape_text(text)
      src.add_text statement unless text.empty?
    end

    def add_stmt(src, code)
      #src << code << ';'
      statement = "#{code}"
      statement << ';' unless code[-1] == ?\n
      src.add_statement statement
    end

    def add_expr_literal(src, code)
      statement = " #{@bufvar} << (" << code << ').to_s;'
      src.add_expr_literal code
    end

    def add_expr_escaped(src, code)
      statement = " #{@bufvar} << " << escaped_expr(code) << ';'
      src.add_expr_escaped code, @escapefunc
    end

    def add_expr_debug(src, code)
      raise "went to add_expr_debug"
      code.strip!
      s = (code.dump =~ /\A"(.*)"\z/) && $1
      src << ' $stderr.puts("*** debug: ' << s << '=#{(' << code << ').inspect}");'
    end

    #--
    #def add_postamble(src)
    #  src << "\n#{@bufvar}.join\n"
    #end
    #++

  end


  ##
  ## engine for Ruby
  ##
  class Eruby < Basic::Engine
    include RubyEvaluator
    include RubyGenerator
  end


  ##
  ## fast engine for Ruby
  ##
  class FastEruby < Eruby
    include InterpolationEnhancer
  end


  ##
  ## swtich '<%= %>' to escaped and '<%== %>' to not escaped
  ##
  class EscapedEruby < Eruby
    include EscapeEnhancer
  end


  ##
  ## sanitize expression (<%= ... %>) by default
  ##
  ## this is equivalent to EscapedEruby and is prepared only for compatibility.
  ##
  class XmlEruby < Eruby
    include EscapeEnhancer
  end


  class PI::Eruby < PI::Engine
    include RubyEvaluator
    include RubyGenerator

    def init_converter(properties={})
      @pi = 'rb'
      super(properties)
    end

  end


end
