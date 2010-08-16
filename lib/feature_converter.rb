module Cucumber
  module Feature
    class Converter

      attr_accessor :options
      
      def initialize options={}
        self.options = options
      end
      
      def read_feature feature_file
        content = File.new(feature_file).read
        content.gsub!(/(@\w+):(\w+)/, '\1: \2')
        while content.gsub!(/(@\w+.*?);(\w+)/, '\1, \2') do          
        end
        content          
      end
      
      def write_feature feature_file, content
        content.gsub!(/(@\w+):\s+(\w+)/, '\1:\2')
        while content.gsub!(/(@\w+.*?),\s+(\w+)/, '\1;\2') do          
        end
        File.open(feature_file, 'w') {|f| f.write(content) }
      end
    end
  end
end
