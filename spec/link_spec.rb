require File.dirname(__FILE__) + '/spec_helper.rb'

describe Atom::Link, "link object" do

  it "should handle each accessors collectly" do
    link = Atom::Link.new
    link.title = 'This is a test'
    link.title.should == 'This is a test'
    link.title = 'Different title'
    link.title.should == 'Different title'
    link.rel = 'alternate'
    link.rel.should == 'alternate'
    link.href = 'http://example.org/'
    link.href.should == 'http://example.org/'
    link.type = 'text/html'
    link.type.should == 'text/html'
    link.length = 100
    link.length.should == "100"
    link.hreflang = 'ja'
    link.hreflang.should == 'ja'
  end

  it "should handle hash-style parameter" do
    link = Atom::Link.new(
      :title    => 'This is a test',
      :rel      => 'alternate',
      :href     => 'http://example.org/',
      :type     => 'text/html',
      :length   => 100,
      :hreflang => 'ja'
    )
    link.title.should    == 'This is a test'
    link.rel.should      == 'alternate'
    link.href.should     == 'http://example.org/'
    link.type.should     == 'text/html'
    link.length.should   == "100"
    link.hreflang.should == 'ja'
  end

  it "should handle xml collectly" do
    xmlstring = Atom::Link.new(
      :title    => 'This is a test',
      :rel      => 'alternate',
      :href     => 'http://example.org/',
      :type     => 'text/html',
      :length   => 100,
      :hreflang => 'ja'
    ).to_s
    xmlstring.should =~ %r{<link}
    xmlstring.should =~ %r{rel='alternate'}
    xmlstring.should =~ %r{href='http://example\.org/'}
    xmlstring.should =~ %r{type='text/html'}
    xmlstring.should =~ %r{length='100'}
    xmlstring.should =~ %r{hreflang='ja'}
  end

end

