require File.dirname(__FILE__) + '/spec_helper.rb'

describe Atom::Content, "setter/getter and building xml" do

  it "should set and get type" do
    content = Atom::Content.new
    content.type = "image/jpeg"
    content.type.should == "image/jpeg"
    content.type = "application/gzip"
    content.type.should == "application/gzip"
  end

  it "should construct with body collectly" do
    content = Atom::Content.new :body => 'This is a test'
    content.body.should == 'This is a test'
    content.type.should == 'text'
  end

  it "should set body and type collectly" do
    content = Atom::Content.new :body => 'This is a test', :type => 'text/bar'
    content.body.should == 'This is a test'
    content.type.should == 'text/bar'
  end

  it "should handle text body collectly" do
    content = Atom::Content.new
    content.body = 'This is a test'
    content.body.should == 'This is a test'
    content.type = 'foo/bar'
    content.type.should == 'foo/bar'
  end

  it "should handle xhtml body collectly" do
    content = Atom::Content.new
    content.body = '<p>This is a test with XHTML</p>'
    content.body.should == '<p>This is a test with XHTML</p>'
    content.type.should == 'xhtml'
  end

  it "should handle invalid xhtml body collectly" do
    content = Atom::Content.new
    content.body = '<p>This is a test with invalid XHTML'
    content.body.should == '<p>This is a test with invalid XHTML'
    content.type.should == 'html'
  end

  it "should handle image data collectly" do
    content = Atom::Content.new
    content.type = 'image/jpeg'
    content.body = "\xff\xde\xde\xde"
    content.type.should == 'image/jpeg'
    content.body.should == "\xff\xde\xde\xde"
  end

end

