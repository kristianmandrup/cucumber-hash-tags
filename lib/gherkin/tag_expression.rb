require 'gherkin/native'

module Gherkin
  class TagExpression
    native_impl('gherkin')

    attr_reader :limits

    def initialize(tag_expressions)
      @ands = []
      @limits = {}
      tag_expressions.each do |expr|
        add(expr.strip.split(/\s*,\s*/))
      end
    end

    def empty?
      @ands.empty?
    end

    # def eval(tags)
    #   return true if @ands.flatten.empty?
    #   vars = Hash[*tags.map{|tag| [tag, true]}.flatten]
    #   !!Kernel.eval(ruby_expression)
    # end

    def eval(tag_hash) 
      tag_hash = case tag_hash
      when Array
        tag_hash.inject({}) do |hash, item| 
          hash[item] = true
          hash
        end
      when Hash
        tag_hash
      else
        raise ArgumentException, "tag must eval as either Hash or Array"
      end
      
      return true if @ands.flatten.empty?
      vars = tag_hash
      !!Kernel.eval(ruby_expression)
    end

  private

    def add(tags_with_negation_and_limits)
      negatives, positives = tags_with_negation_and_limits.partition{|tag| tag =~ /^~/}
      @ands << (store_and_extract_limits(negatives, true) + store_and_extract_limits(positives, false))
    end

    def store_and_extract_limits(tags_with_negation_and_limits, negated)
      tags_with_negation = []
      tags_with_negation_and_limits.each do |tag_with_negation_and_limit|
        tag_with_negation, limit = tag_with_negation_and_limit.split(':')
        tags_with_negation << tag_with_negation
        if limit
          tag_without_negation = negated ? tag_with_negation[1..-1] : tag_with_negation
          if @limits[tag_without_negation] && @limits[tag_without_negation] != limit.to_i
            raise "Inconsistent tag limits for #{tag_without_negation}: #{@limits[tag_without_negation]} and #{limit.to_i}" 
          end
          @limits[tag_without_negation] = limit.to_i
        end
      end
      tags_with_negation
    end

    # def ruby_expression
    #   "(" + @ands.map do |ors|
    #     ors.map do |tag|
    #       if tag =~ /^~(.*)/
    #         "!vars['#{$1}']"
    #       else
    #         "vars['#{tag}']"
    #       end
    #     end.join("||")
    #   end.join(")&&(") + ")"
    # end 
    
    IN_OP = '%'
    INCLUDE_OP = '&'
    ITEM_SPLIT = ';'

    def ruby_expression
      expr = "(" + @ands.map do |ors|
        ors.map do |tag| 
          tag_expr = TagStatement.parse_expression tag
          # puts TagStatement.new(tag_expr).print_expression
          TagStatement.new(tag_expr).print_expression
        end.join("||")
      end.join(")&&(") + ")"
      expr
    end 
    
    class TagStatement
      attr_accessor :pre_op, :left, :operator, :right, :tag_name
      
      def initialize tag_expr
        @operator= '=='
        @right=true
        @pre_op = ''
        @tag_name = ''
        set tag_expr
      end 

      def self.parse_expression tag
        tag.gsub! /-?#{IN_OP}-?/, IN_OP
        tag.split /(#{IN_OP}|<=|>=|=|>|<)/
      end
        

      def to_s
        "tag_name: #{tag_name.inspect}, pre_op: #{pre_op}, left: #{left}, operator: #{operator}, right: #{right}"
      end

      def print_expression
        hash_var = "vars['#{tag_name}']"
        hash_var = "[#{hash_var}].flatten" if operator == INCLUDE_OP
        @left = "#{hash_var}"
        ex = (right == true) ? "#{pre_op}#{left}" : print_expr
      end

      def print_expr
        if operator == INCLUDE_OP
          return "!(#{left} #{operator} #{right}).empty?" if pre_op == ''
          return "(#{left} #{operator} #{right}).empty?"
        end
        "#{pre_op}(#{left} #{operator} #{right})"               
      end

      def set tag_expr
        @tag_name = tag_expr[0]  
        if tag_name =~ /^~(@\w+)/
          @tag_name = $1 
          @pre_op = '!'
        end
        handle_list(tag_expr) if tag_expr.size > 2 
      end
      
      def handle_list tag_expr        
        set_operator tag_expr[1]
        set_right tag_expr[2]
      end      

      def set_right arg
        @right = if operator == INCLUDE_OP
          arg = [convert_list(arg)].flatten 
          "#{arg}"
        else
          convert_val_single(arg)
        end
      end

      def convert_val_single val
        is_numeric?(val) ? val.to_i : val.inspect
      end

      def convert_val val
        is_numeric?(val) ? val.to_i : val
      end
      
      def convert_list list_str
        list_str.split(ITEM_SPLIT).map do |item|
          convert_val(item)
        end
      end

      def is_numeric?(i)
          i.to_i.to_s == i || i.to_f.to_s == i
      end

      def set_operator op
        @operator = case op
        when IN_OP
          INCLUDE_OP
        when '='
          '=='
        else                               
          raise ArgumentError, "Unknown tag comparison operator: #{op}" if !['>=', '<=', '>', '<', '='].include?(op)
          op
        end
      end      
    end    
  end
end
