require 'gherkin/tag_expression'

module Cucumber
  module Ast
    class Tags #:nodoc:
      attr_reader :tag_names, :tag_hash

      def initialize(line, tag_names)
        @line, @tag_names = line, tag_names
        set_tag_hash
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        tag_hash.each do |tag_key, tag_value|
          visitor.visit_tag(tag_key, tag_value)
        end
      end

      def set_tag_hash
        @tag_hash = tag_names.inject({}) do |hash, tag|
          tag = tag.split(':')
          tag_key, tag_value = tag[0] ,tag[1]
          hash[tag_key] = tag_value ? tag_value : true 
          hash
        end
      end

      def to_sexp
        res = []
        tag_hash.each_pair do |tag_key, tag_value|
          val = (tag_value == true) ? [:tag, tag_key] : [:tag, tag_key => parse_value(tag_value)]
          res << val
        end
        res
      end

      ITEM_SPLIT = ';'

      def parse_value val
        if val =~ /;/
          [convert_list(val)].flatten
        else             
          convert_val(val)
        end
      end

      def convert_val val       
        val.gsub! /--(.*)/, '\1' 
        val.gsub! /..(.*)/, '\1' 
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

      def accept_hook?(hook)
        Gherkin::TagExpression.new(hook.tag_expressions).eval(tag_hash)
      end
    end
  end
end
