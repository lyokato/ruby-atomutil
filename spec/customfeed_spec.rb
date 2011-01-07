require File.dirname(__FILE__) + '/spec_helper.rb'

describe Atom::Feed, "customized with other namespace" do

  it "should parse and handle openSearch elements collectly" do
    xmlstring = <<-EOS
    <feed xmlns="http://www.w3.org/2005/Atom"
          xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.1/">
    <title>Example</title>
    <icon>http://example.org/feed/icon.jpeg</icon>
    <openSearch:totalResult>153</openSearch:totalResult>
    <openSearch:startIndex>40</openSearch:startIndex>
    <openSearch:itemsPerPage>20</openSearch:itemsPerPage>
    </feed>
    EOS
    feed = Atom::Feed.new :stream => xmlstring
    feed.get(Atom::Namespace::OPEN_SEARCH, 'totalResult').text.to_i.should == 153
    feed.get(Atom::Namespace::OPEN_SEARCH, 'startIndex').text.to_i.should == 40
    feed.get(Atom::Namespace::OPEN_SEARCH, 'itemsPerPage').text.to_i.should == 20
  end

  it "should build and handle openSearch elements collectly" do
    feed = Atom::Feed.new
    feed.title = 'Example'
    feed.set(Atom::Namespace::OPEN_SEARCH, 'totalResult', 153)
    feed.set(Atom::Namespace::OPEN_SEARCH, 'startIndex', 40)
    feed.set(Atom::Namespace::OPEN_SEARCH, 'itemsPerPage', 20)
    feed.get(Atom::Namespace::OPEN_SEARCH, 'totalResult').text.to_i.should == 153
    feed.get(Atom::Namespace::OPEN_SEARCH, 'startIndex').text.to_i.should == 40
    feed.get(Atom::Namespace::OPEN_SEARCH, 'itemsPerPage').text.to_i.should == 20
  end

  it "shoudl parse and handle more complex elements" do
    xmlstring = <<-EOS
    <feed xmlns="http://www.w3.org/2005/Atom"
          xmlns:myns="http://example.org/2007/example">
    <title>Example</title>
    <icon>http://example.org/feed/icon.jpg</icon>
    <myns:foo><myns:bar buz="Buz">Bar</myns:bar></myns:foo>
    </feed>
    EOS
    myns = Atom::Namespace.new :prefix => 'myns', :uri => 'http://example.org/2007/example'
    feed = Atom::Feed.new :stream => xmlstring
    foo = feed.get(myns, 'foo')
    foo.class.should == REXML::Element
    bar = foo.elements[1]
    bar.class.should == REXML::Element
    bar.attributes['buz'].should == 'Buz'
    bar.text.should == 'Bar'
  end

  it "should build and handle more complex elements" do
    myns = Atom::Namespace.new :prefix => 'myns', :uri => 'http://example.org/2007/example'
    feed = Atom::Feed.new :title => 'Example'
    bar = REXML::Element.new("#{myns.prefix}:bar")
    bar.text = 'Bar'
    bar.add_attribute(REXML::Attribute.new("buz", 'Buz'))
    feed.set(myns, 'foo', bar)
    foo = feed.get(myns, 'foo')
    foo.class.should == REXML::Element
    bar2 = foo.elements[1]
    bar2.class.should == REXML::Element
    bar2.attributes['buz'].should == 'Buz'
    bar.text.should == 'Bar'
  end

end

