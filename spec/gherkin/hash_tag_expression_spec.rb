require 'gherkin/spec_helper'
require 'gherkin/tag_expression'

# These comparisons should not conflict with the default array based workings of tags in gherkin
# This feature is simply an add-on which allows for more advanced use cases, fx for use by cucumber FM

module Gherkin
  describe TagExpression do
    
    context "@foo=bar" do
      before(:each) do
        @e = Gherkin::TagExpression.new(['@foo=bar'])
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 'bar'}).should == true
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 'blip'}).should == false
      end
    
    
      it "should not match @bar" do
        @e.eval(['@bar']).should == false
      end
    
      it "should not match no tags" do
        @e.eval([]).should == false
      end
    end
    
    context "@foo>=" do
      before(:each) do
        @e = Gherkin::TagExpression.new(['@foo>=1'])
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 0}).should == false
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 1}).should == true
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 2}).should == true
      end
    end
    
    context "@foo>" do
      before(:each) do
        @e = Gherkin::TagExpression.new(['@foo>1'])
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 0}).should == false
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 1}).should == false
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 2}).should == true
      end
    end
    
    context "~@foo>" do
      before(:each) do
        @e = Gherkin::TagExpression.new(['~@foo>1'])
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 0}).should == true
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 1}).should == true
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 2}).should == false
      end
    end
    
    
    context "@foo<=" do
      before(:each) do
        @e = Gherkin::TagExpression.new(['@foo<=1'])
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 0}).should == true
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 1}).should == true
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 2}).should == false
      end
    end
    
    context "@foo<" do
      before(:each) do
        @e = Gherkin::TagExpression.new(['@foo<1'])
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 0}).should == true
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 1}).should == false
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 2}).should == false
      end
    end
       
    context "@foo with item [3]" do
      before(:each) do
        @e = Gherkin::TagExpression.new(['@foo-%-3']) # % is the 'in list' operator
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 3}).should == true
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => [1, 3]}).should == true
      end
    
      it "should not match @foo" do
        @e.eval({'@foo' => 2}).should == false
      end
    end   
    
    context "@foo with items [1,3]" do
      before(:each) do
        @e = Gherkin::TagExpression.new(['@foo-%-1;3']) # % is the 'in list' operator
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 1}).should == true
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 3}).should == true
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => [3]}).should == true
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => [2, 3]}).should == true
      end
    
      it "should not match @foo" do
        @e.eval({'@foo' => 2}).should == false
      end
    end
       
    context "@foo with items ['brian_m']" do
      before(:each) do
        @e = Gherkin::TagExpression.new(['@foo-%-brian_m']) # % is the 'in list' operator
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => ['brian_m','sally_k']}).should == true
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => ['sally_k']}).should == false
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => ['brian_m']}).should == true
      end    
    end
    
    context "@foo NOT with items [1,3]" do
      before(:each) do
        @e = Gherkin::TagExpression.new(['~@foo-%-1;3']) # % is the 'in list' operator
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 1}).should == false
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 3}).should == false
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => [3]}).should == false
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => [2, 3]}).should == false
      end
    
      it "should not match @foo" do
        @e.eval({'@foo' => 2}).should == true
      end
    end
    
    context "(@foo == 1 || @bar) && !@zap" do
      before(:each) do
        @e = Gherkin::TagExpression.new(['@foo=1,@bar', '~@zap'])
      end
    
      it "should match @foo" do
        @e.eval({'@foo' => 1}).should == true
      end
    
      it "should not match @foo @zap" do
        @e.eval({'@foo' => 1, '@zap' => true}).should == false
      end
    end          
  end
end