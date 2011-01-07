require File.dirname(__FILE__) + '/spec_helper.rb'

describe Atom::Categories, "categories handler" do

  it "should handle attributes and elements collectly with each accessor" do
    cats = Atom::Categories.new
    cats.fixed = 'yes'
    cats.fixed.should == 'yes'
    cats.scheme = 'http://example.org/extra-cats/'
    cats.scheme.should == 'http://example.org/extra-cats/'
  end

  it "should handle attributes and elements collectly with hash-type parameter" do
    cats = Atom::Categories.new :fixed => 'yes', :scheme => 'http://example.org/extra-cats/'
    cats.fixed.should == 'yes'
    cats.scheme.should == 'http://example.org/extra-cats/'
  end


  it "should handle Atom::Category objects collectly" do
    cats = Atom::Categories.new
    cats.fixed = 'yes'
    cats.scheme = 'http://example.org/extra-cats/'
    cat = Atom::Category.new
    cat.scheme = "http://example.org/extra-cats/"
    cat.term = "joke"
    cats.add_category cat
    first = cats.categories.first
    first.scheme.should == "http://example.org/extra-cats/"
    first.term.should == "joke"
    cat2 = Atom::Category.new
    cat2.scheme = "http://example.org/extra-cats/"
    cat2.term = "serious"
    cats.add_category cat2
    cats2 = cats.categories
    cats2[0].scheme.should == "http://example.org/extra-cats/"
    cats2[0].term.should == "joke"
    cats2[1].scheme.should == "http://example.org/extra-cats/"
    cats2[1].term.should == "serious"
    cats_xml = cats.to_s
    cats_xml.should =~ %r{<categories(?: xmlns='http://www.w3.org/2007/app')?} 
  end

end
