require File.dirname(__FILE__) + '/spec_helper.rb'

describe Atom::Feed, "feed object" do

  it "should handle feed from file with filepath" do
    path = File.join(File.dirname(__FILE__), 'samples', 'feed.atom')
    feed = Atom::Feed.new :file => path
    feed.title.should == 'dive into mark'
    feed.id.should == 'tag:example.org,2003:3'
    feed.updated.iso8601.should == '2005-07-31T12:29:29Z'
    feed.alternate_link.should == 'http://example.org/'
    feed.self_link.should == 'http://example.org/feed.atom'
    feed.rights.should == 'Copyright (c) 2003, Mark Pilgrim'
    feed.generator.name.gsub(/^[\s\n]*(.+)[\s\n]*$/, '\1').should == 'Example Toolkit'
    feed.links.length.should == 2
    entry = feed.entries[0]
    entry.title.should == 'Atom draft-07 snapshot'
    entry.id.should == 'tag:example.org,2003:3.2397'
    entry.updated.iso8601.should == '2005-07-31T12:29:29Z'
    entry.published.iso8601.should == Time.iso8601('2003-12-13T08:29:29-04:00').iso8601
    entry.alternate_link.should == 'http://example.org/2005/04/02/atom'
    entry.enclosure_link.should == 'http://example.org/audio/ph34r_my_podcast.mp3'
    author = entry.author
    author.name.should == 'Mark Pilgrim'
    author.uri.should == 'http://example.org/'
    author.email.should == 'f8dy@example.com'
    homepage = author.get(Atom::Namespace::FOAF, 'homepage')
    homepage.class.should == REXML::Element
    homepage.attributes['rdf:resource'].should == 'http://www.example.org/blog'
    img = author.get(Atom::Namespace::FOAF, 'img')
    img.class.should == REXML::Element
    img.attributes['rdf:resource'].should == 'http://www.example.org/mypic.png'

    contributors = entry.contributors
    contributors.size.should == 2
    contributors[0].name.should == 'Sam Ruby'
    contributors[1].name.should == 'Joe Gregorio'

    content = entry.content
    content.type.should == 'xhtml'
    body = content.body
    body.gsub(/^[\n\s]*(.+)[\n\s]*$/, '\1').should == '<p><i>[Update: The Atom draft is finished.]</i></p>'
  end

  it "should handle feed from file with Pathname object" do
    path = Pathname.new(File.join(File.dirname(__FILE__), 'samples', 'feed.atom'))
    feed = Atom::Feed.new :file => path
    feed.title.should == 'dive into mark'
    feed.id.should == 'tag:example.org,2003:3'
    feed.updated.iso8601.should == '2005-07-31T12:29:29Z'
    feed.alternate_link.should == 'http://example.org/'
    feed.self_link.should == 'http://example.org/feed.atom'
    feed.rights.should == 'Copyright (c) 2003, Mark Pilgrim'
    feed.generator.name.gsub(/^[\s\n]*(.+)[\s\n]*$/, '\1').should == 'Example Toolkit'
    entry = feed.entries[0]
    entry.title.should == 'Atom draft-07 snapshot'
    entry.id.should == 'tag:example.org,2003:3.2397'
    entry.updated.iso8601.should == '2005-07-31T12:29:29Z'
    entry.published.iso8601.should == Time.iso8601('2003-12-13T08:29:29-04:00').iso8601
    entry.alternate_link.should == 'http://example.org/2005/04/02/atom'
    entry.enclosure_link.should == 'http://example.org/audio/ph34r_my_podcast.mp3'
    author = entry.author
    author.name.should == 'Mark Pilgrim'
    author.uri.should == 'http://example.org/'
    author.email.should == 'f8dy@example.com'
    homepage = author.get(Atom::Namespace::FOAF, 'homepage')
    homepage.class.should == REXML::Element
    homepage.attributes['rdf:resource'].should == 'http://www.example.org/blog'
    img = author.get(Atom::Namespace::FOAF, 'img')
    img.class.should == REXML::Element
    img.attributes['rdf:resource'].should == 'http://www.example.org/mypic.png'

    contributors = entry.contributors
    contributors.size.should == 2
    contributors[0].name.should == 'Sam Ruby'
    contributors[1].name.should == 'Joe Gregorio'

    content = entry.content
    content.type.should == 'xhtml'
    body = content.body
    body.gsub(/^[\n\s]*(.+)[\n\s]*$/, '\1').should == '<p><i>[Update: The Atom draft is finished.]</i></p>'
  end
  #it "should handle feed from uri" do
  #  feed = Atom::Feed.new :uri => ''
  #end

  it "should handle feed from stream" do
    xmlstring = <<-EOS
<?xml version="1.0" encoding="utf-8"?>

<feed xmlns="http://www.w3.org/2005/Atom"
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      xmlns:foaf="http://xmlns.com/foaf/0.1">

  <title type="text">dive into mark</title>
  <id>tag:example.org,2003:3</id>

  <updated>2005-07-31T12:29:29Z</updated>

  <link rel="alternate" type="text/html"
   hreflang="en" href="http://example.org/"/>
  <link rel="self" type="application/atom+xml"
   href="http://example.org/feed.atom"/>

  <rights>Copyright (c) 2003, Mark Pilgrim</rights>
  <generator uri="http://www.example.com/" version="1.0">
    Example Toolkit
  </generator>
  
  <entry>
    <title>Atom draft-07 snapshot</title>
    <id>tag:example.org,2003:3.2397</id>

    <updated>2005-07-31T12:29:29Z</updated>
    <published>2003-12-13T08:29:29-04:00</published>

    <link rel="alternate" type="text/html"
     href="http://example.org/2005/04/02/atom"/>

    <link rel="enclosure" type="audio/mpeg" length="1337"
     href="http://example.org/audio/ph34r_my_podcast.mp3"/>

    <author>
      <name>Mark Pilgrim</name>
      <uri>http://example.org/</uri>
      <email>f8dy@example.com</email>

      <foaf:homepage rdf:resource="http://www.example.org/blog" />
      <foaf:img rdf:resource="http://www.example.org/mypic.png" />
    </author>

    <contributor>
      <name>Sam Ruby</name>
    </contributor>
    <contributor>
      <name>Joe Gregorio</name>
    </contributor>

    <content type="xhtml" xml:lang="en" xml:base="http://diveintomark.org/">
      <div xmlns="http://www.w3.org/1999/xhtml">
        <p><i>[Update: The Atom draft is finished.]</i></p>
      </div>
    </content>

  </entry>

</feed>

    EOS
    feed = Atom::Feed.new :stream => xmlstring
    feed.title.should == 'dive into mark'
    feed.id.should == 'tag:example.org,2003:3'
    feed.updated.iso8601.should == '2005-07-31T12:29:29Z'
    feed.alternate_link.should == 'http://example.org/'
    feed.self_link.should == 'http://example.org/feed.atom'
    feed.rights.should == 'Copyright (c) 2003, Mark Pilgrim'
    feed.generator.name.gsub(/^[\s\n]*(.+)[\s\n]*$/, '\1').should == 'Example Toolkit'
    entry = feed.entries[0]
    entry.title.should == 'Atom draft-07 snapshot'
    entry.id.should == 'tag:example.org,2003:3.2397'
    entry.updated.iso8601.should == '2005-07-31T12:29:29Z'
    entry.published.iso8601.should == Time.iso8601('2003-12-13T08:29:29-04:00').iso8601
    entry.alternate_link.should == 'http://example.org/2005/04/02/atom'
    entry.enclosure_link.should == 'http://example.org/audio/ph34r_my_podcast.mp3'
    author = entry.author
    author.name.should == 'Mark Pilgrim'
    author.uri.should == 'http://example.org/'
    author.email.should == 'f8dy@example.com'
    homepage = author.get(Atom::Namespace::FOAF, 'homepage')
    homepage.class.should == REXML::Element
    homepage.attributes['rdf:resource'].should == 'http://www.example.org/blog'
    img = author.get(Atom::Namespace::FOAF, 'img')
    img.class.should == REXML::Element
    img.attributes['rdf:resource'].should == 'http://www.example.org/mypic.png'

    contributors = entry.contributors
    contributors.size.should == 2
    contributors[0].name.should == 'Sam Ruby'
    contributors[1].name.should == 'Joe Gregorio'

    content = entry.content
    content.type.should == 'xhtml'
    body = content.body
    body.gsub(/^[\n\s]*(.+)[\n\s]*$/, '\1').should == '<p><i>[Update: The Atom draft is finished.]</i></p>'
  end

  it "should build feed collectly" do

    feed = Atom::Feed.new
    feed.id = 'tag:example.org,2007:myexample'
    feed.id.should == 'tag:example.org,2007:myexample'
    feed.version = '1.00'
    feed.version.should == '1.00'
    feed.language = 'en'
    feed.language.should == 'en'
    feed.generator = 'MyFeedGenerator'
    feed.generator.name.should == 'MyFeedGenerator'
    feed.generator = Atom::Generator.new(
      :name    => 'MySecondGenerator',
      :uri     => 'http://example.org/generator',
      :version => '1.00'
    )
    feed.generator.name.should == 'MySecondGenerator'
    feed.generator.uri.should == 'http://example.org/generator'
    feed.generator.version.should == '1.00'
    feed.rights = 'Copyright(c) 2007, Example.'
    feed.rights.should == 'Copyright(c) 2007, Example.'

    author = Atom::Author.new
    author.name = 'Atom User'
    author.email = 'atom@example.org'
    author.uri = 'http://example.org/atom'
    feed.author = author

    feed.language = 'fr'
    feed.language.should == 'fr'

    xmlstring = feed.to_s
    xmlstring.should =~ %r{<feed}
    xmlstring.should =~ %r{<author}
    xmlstring.should =~ %r{<id}
    xmlstring.should =~ %r{version='1.00'}
    xmlstring.should =~ %r{xml:lang='fr'}
    xmlstring.should =~ %r{<generator}
  end

end

