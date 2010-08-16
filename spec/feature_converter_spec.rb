require 'spec_helper'
require 'cucumber'
require 'cucumber-hash-tags'

$KCODE='u' unless Cucumber::RUBY_1_9

module Cucumber
  module Feature    
    describe Converter do    
      describe "reads feature" do
        let (:feature_file) { File.dirname(__FILE__) + '/fixtures/hash_tags.feature' }
        let (:new_feature_file) { File.dirname(__FILE__) + '/fixtures/new_hash_tags.feature' }
        let (:converter)    { Cucumber::Feature::Converter.new }

        before do            
          @converted_feature = converter.read_feature(feature_file)
        end

        after do            
          FileUtils.rm_f(new_feature_file)
        end
      
        context "@authors:kristian_m;sally_k;mike_c @wip" do
          it "should convert Gherkin feature to nice Business Analyst format" do            
            @converted_feature.should match /@authors: kristian_m, sally_k, brian_m/
          end
        end
        
        context "@authors: kristian_m, sally_k, mike_c @wip" do
          it "should write nice Business Analyst format to valid Gherkin format" do
            converter.write_feature(new_feature_file, @converted_feature)

            old_file_content = File.new(feature_file).read
            new_file_content = File.new(new_feature_file).read            
            
            # feature format should be back to original
            old_file_content.should == new_file_content                        
          end
        end
      end
    end
  end
end
          
