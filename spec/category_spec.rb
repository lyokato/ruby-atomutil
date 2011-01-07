require File.dirname(__FILE__) + '/spec_helper.rb'

describe Atom::Category, "category object" do

  before(:all) do
    @cat = Atom::Category.new
    @cat.term = "foo"
    @cat.label = "bar"
    @cat.scheme = "http://example.com/"
  end

  it "should handle parameters collectly" do
    @cat.term.should == "foo"
    @cat.label.should == "bar"
    @cat.scheme.should == "http://example.com/"
  end

  it "should build xml collectly" do
    cat_xml = @cat.to_s
    cat_xml.should =~ /<category\s.*\/>/
    cat_xml.should =~ /term='foo'/
    cat_xml.should =~ /label='bar'/
    cat_xml.should =~ /scheme='http:\/\/example\.com\/'/
  end

end

