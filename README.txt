= Utilities for AtomPub / Atom Syndication Format

This library allows you to handle AtomPub and Atom Syndication Format easily.
Most of the idea is from great Perl modules on CPAN.

= INSTALLATION

  sudo gem install atomutil

= SYNOPSIS

== Building or parsing XML with Atom Syndication Format

=== How To Construct Each Atom Element

Create new object and setup with each accessor.

  entry = Atom::Entry.new

  entry.title     = 'Title!'
  entry.summary   = 'Summary!'
  entry.published = Time.now

Or you can do that at once with passing hash parameter to constructor

  entry = Atom::Entry.new(
    :title     => 'Title!',
    :summary   => 'Summary',
    :published => Time.now
  )

And you also can setup new element within a block if you pass one.

  entry = Atom::Entry.new(:title => 'New Entry') do |e|
    e.summary = 'New Summary'
    author = Atom::Author.new :name => 'John'
    e.author = author
    e.published = Time.now
  end

And finally you can get xml-document from them.

  xml_string = entry.to_s

If you pass false to to_s, it returns non-indented string

  xml_string = entry.to_s(false)

=== How To Parse Each Atom XML Document

  xml_string = <<-EOS
  <?xml version="1.0" encoding="UTF-8"?>
  <entry xmlns="http://www.w3.org/2005/Atom">
    <id>tag:example.org,2007-12-01:mybook</id>
    <title>Title</title>
    <summary>Summary</summary>
    <author><name>John</name></author>
  </entry>
  EOS

Pass the xml-string to proper Atom Element Class with :stream key

  entry = Atom::Entry.new :stream => xml_string
  puts entry.title       # Book
  puts entry.summary     # Summary
  puts entry.author.name # John

Atom::Feed and Atom::Entry can be build from files

  entry = Atom::Feed.new :file => 'my_feed.atom'

or from uri

  entry = Atom::Feed.new :uri => 'http://example.com/feed.atom'

== How To Handle other Namespace

There are times when you want to extend your atom element
with other namespaces.
For example, in case you want to deal pagination with OpenSearch 

  xmlstring = <<-EOS
  <feed xmlns="http://www.w3.org/2005/Atom"
        xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/">
  <openSearch:totalResult>153</openSearch:totalResult>
  <openSearch:startIndex>40</openSearch:startIndex>
  <openSearch:itemsPerPage>20</openSearch:itemsPerPage>
  ...
  </feed>
  EOS

How to get these values?
The answer is using 'get' method.
And then, just a reminder, you have to prepare Atom::Namespace object.
Pass the object and element name to the method.
And it returns REXML::Element object.

  feed = Atom::Feed.new :stream => xmlstring
  open_search_ns = Atom::Namespace.new(
    :prefix => 'openSearch',
    :uri    => 'http://a9.com/-/spec/opensearchrss/1.1/')

  total = feed.get(open_search_ns, 'totalResult').text.to_i
  start = feed.get(open_search_ns, 'startIndex').text.to_i
  per_page = feed.get(open_search_ns, 'itemsPerPage').text.to_i

And of cource, you also can 'set'

  feed = Atom::Feed.new
  feed.title = 'my new feed'
  feed.set(open_search_ns, 'totalResult', 153)
  feed.set(open_search_ns, 'startIndex',   40)
  feed.set(open_search_ns, 'itemsPerPage', 20)

In this example, I take the 'openSearch' for pagination, but it's already implemented with
useful methods.

  feed = Atom::Feed.new
  feed.total_results = 35
  feed.start_index = 1
  feed.items_per_page = 20

  puts feed.total_results
  puts feed.start_index
  puts feed.items_per_page

=== Build a Service Document

Create root service element

  service = Atom::Service.new

Create workspace element which the service appends.

  blog_workspace = Atom::Workspace.new
  blog_workspace.title = 'My Blog'

  collection = Atom::Collection.new
  collection.href = 'http://blog.example.org/feed'
  collection.title = 'Sample Blog'

Create categories that your collection handles

  cats = Atom::Categories.new
  cats.fixed = 'no'

You can set each concrete categories here

  category1 = Atom::Category.new 
  category1.term = 'technology'
  category2 = Atom::Category.new
  category2.term = 'music'
  category3 = Atom::Category.new
  category3.term = 'sport'
  cats.add_category category1
  cats.add_category category2
  cats.add_category category3

Or set only href parameter that represents uri for Categories Document,
Instead of setting each categories here.
Then you should provides Categories Document at indicated uri.

  cats.href = 'http://blog.example.org/categories'

  collection.add_categories cats
  blog_workspace.add_collection collection
  service.add_workspace blog_workspace
  service_document_xml_string = service.to_s

=== Build a Categories Document

  cats = Atom::Categories.new
  category1 = Atom::Category.new
  category1.term = 'technology'
  category2 = Atom::Category.new
  category2.term = 'music'
  category3 = Atom::Category.new
  category3.term = 'sport'
  cats.add_category category1
  cats.add_category category2
  cats.add_category category3

  categories_xml_string = cats.to_s

=== Build an Entry

  entry = Atom::Entry.new

* id
* title
* summary
* rights
* source

Simple text accessors

  entry.id      = 'tag:example.org,2007:example'
  entry.title   = 'My First Blog Post'
  entry.summary = 'This is summary'
  entry.rights  = 'Copyright(c) 2007 Lyo Kato all rights reserved.'

* published
* updated

You can set them with Time class

  entry.published = Time.now
  entry.updated   = Time.now

Or you can set with W3CDTF formatted string

  entry.published = "2007-12-01T01:30:00Z"

And pick it up as Time object

  published = entry.published
  puts published.year
  puts published.month

* author
* contributor

Set person construct with Atom::Person

  person = Atom::Person.new
  person.name = 'Lyo Kato'
  person.email = 'lyo.kato atmark gmail.com'
  person.uri = 'http://www.lyokato.net/'
  
  entry.author = person.to_author
  entry.contributor = person.to_contributor

Or Atom::Author, Atom::Contributor directly

  cont = Atom::Contributor.new
  cont.name = 'Lyo'
  cont.email = 'lyo.kato atmark gmail.com'
  entry.contributor = cont

To set multiple data

  entry.add_author author1
  entry.add_author author2
  entry.add_contributor contributor1
  entry.add_contributor contributor2

Get all authors and contributors

  authors = entry.authors
  contributors = entry.contributors

Get only first author and contributor

  author = entry.author
  contributor = entry.contributor

* link

Link Element Accessor

  link = Atom::Link.new
  link.href = 'http://example.org/entry/1'
  link.rel = 'alternate'
  link.type = 'text/html'
  link.hreflang = 'fr'
  link.length = '512'
  link.title = 'My Blog Post'
  entry.link = link

You can set multiple links

  entry.add_link link1
  entry.add_link link2

To get all links as an Array

  links = entry.links

To get first one

  link = entry.link
  puts link.href
  puts link.rel

Further more, useful methods are implemented for major 'rel' types.

  entry.alternate_link = 'http://example.org/entry/1'

This is same as

  link = Atom::Link.new
  link.rel = 'alternate'
  link.href = 'http://example.org/entry/1'
  entry.add_link link

And

  puts entry.alternate_link # http://example.org/entry1

This is same as

  links = entry.links
  alternate_link = links.select{ |l| l.rel == 'alternate' }.first
  puts alternate_link.href

If it contains multiple 'alternate' links, to get all of them,

  alternate_links = links.alternate_links

Like this, you can use following methods for each links

entry.self_link::       <link rel='self' href='...'/>
entry.edit_link::       <link rel='edit' href='...'/>
entry.edit_media_link:: <link rel='edit-media' href='...'/>
entry.enclosure_link::  <link rel='enclosure' href='...'/>
entry.related_link::    <link rel='related' href='...' />
entry.via_link::        <link rel='via' href='...' />
entry.first_link::      <link rel='first' href='...'/>
entry.previous_link::   <link rel='previous' href='...'/>
entry.next_link::       <link rel='next' href='...' />
entry.last_link::       <link rel='last' href='...' />

* category

Category Element Accessor

  category = Atom::Category.new
  category.term   = 'music'
  category.scheme = 'http://example.org/category/music'
  category.label  = 'My Music'
  entry.category = category

You can set multiple categories

  entry.add_category cat1
  entry.add_category cat2

To get all categories as an Array

  categories = entry.categories

To get first one

  first_category = entry.category
  puts first_category.term
  puts first_category.scheme

* content

You can push it as a text

  entry.content = 'This is a content'

Or an Atom::Content object

  content = Atom::Content.new :body => 'This is a content'
  entry.content = content

To pick it up

  content = entry.content

  puts content.type
  puts content.body

* control

Control Element Accessor

  control = Atom::Control.new
  control.draft = 'yes'
  entry.control = control

Then entry includes

  <app:control xmlns:app='http://www.w3.org/2007/app'>
    <app:draft>yes</app:draft>
  </app:control>

* edited

Represents what time this entry was edited.

  entry.edited = Time.now

Then entry includes

  <app:edited>2007-09-01T00:00:00Z</app:edited>

To pick it up

  edited = entry.edited
  puts edited.year
  puts edited.month

You also can handle Atom-Threading
(http://tools.ietf.org/html/rfc4685)

  target = Atom::ReplyTarget.new
  target.id   = 'tag:example.org,2007:12:example'
  target.href = 'http://example.org/blog/2007/12/archive01'
  target.type = 'text/xhtml'

  entry.in_reply_to target

Or you can set the target direclty with hash

  entry.in_reply_to(
    :id   => 'tag:example.org,2007:12:example',
    :href => 'http://example.org/blog/2007/12/archive01',
    :type => 'text/xhtml'
  )

And then entry includes xml

  <thr:in-reply-to xmlns:thr='http://purl.org/syndication/thread/1.0'
    ref='tag:example.org,2007:12:example'
    href='http://example.org/blog/2007/12/archive01'
    type='text/xhtml'/>

Pick it up from entry

  target = entry.in_reply_to
  puts target.id
  puts target.href
  puts target.type

Add a replies link

  link = Atom::RepliesLink.new
  link.href = 'http://example.org/entry/1/replies'
  link.count = 10
  link.updated = Time.now

  entry.add_link link

Then entry includes

  <link rel='replies' href='http://example.org/entry/1/replies'
    thr:count='10' thr:updated='2007-01-01T00:00:00Z'>

Add total replies count

  entry.total = 10

Then entry includes

  <thr:total>10</thr:total>

=== Build a Feed

  feed = Atom::Feed.new

* id
* title
* subtitle
* rights
* icon
* logo
* language
* version

Simple text accessors

  feed.id = 'tag:example.org,2007:example'
  feed.title = 'Example Feed'
  feed.subtitle = 'Subtitle of Example Feed'
  feed.rights = 'Copyright(c) 2007 example.org all rights reserved'
  feed.icon = 'http://example.org/icon.png'
  feed.logo = 'http://example.org/logo.png'
  feed.language = 'fr'
  feed.version = '1.0'

* updated

Time accessor

  feed.updated = Time.now
  updated = feed.updated
  puts updated.year
  puts updated.month

* generator

You can set generator information

  feed.generator = 'MyGenerator'

Or more in detail

  generator = Atom::Generator.new(
    :name    => 'MyGenerator',
    :uri     => 'http://example.org/mygenerator',
    :version => '1.0'
  )
  feed.generator = generator

  generator = feed.generator
  puts generator.name
  puts generator.uri
  puts generator.version

* link

You can set links like you do with entry

  link1 = Atom::Link.new :href => 'http://example.org/entry/1', :rel => 'alternate'
  feed.add_link link1

  feed.edit_link = 'http://example.org/entry/1/edit'

* category

You can set categoryes like you do with entry

* author
* contributor

Person construct data.
You can set authors/contributors on same way for entry.

* entry

Entry Accessors

  entry1 = Atom::Entry.new
  entry1.title = 'Entry1'

  entry2 = Atom::Entry.new
  entry2.title = 'Entry2'

  feed.add_entry entry1
  feed.add_entry entry2

  entries = feed.entries

OpenSeach Pagination Control

  feed.total_results = 35
  feed.items_per_page = 10
  feed.start_index = 11

Then feed includes

  <openSearch:totalResults>35</openSearch:totalResults>
  <openSearch:itemsPerPage>10</openSearch:itemsPerPage>
  <openSearch:startIndex>11</openSearch:startIndex>

== Using service that provides AtomPub API

At first, construct appropriate authorizer
At this time, let's assume that we're requried WSSE Authentication.
Of cource, you can choose other authorizer, 
for example, Atom::Auth::Basic(Basic authentication),
and in future, Atom::Auth::OAuth, Atom::Auth::OpenID, and etc.

  auth = Atompub::Auth::Wsse.new :username => 'myname', :password => 'mypass'

  client = Atompub::Client.new :auth => auth

  service = client.get_service( 'http://example/service/api/endpoint' )
  collection = service.workspaces.first.collection.first
  categories = client.get_categories( collection.categories.href )

  categories.categories.each do |category|
    puts category.label
    puts category.scheme
    puts category.term
  end

  feed = client.get_feed( collection.href )

  puts feed.title # 'Example Feed'
  puts feed.icon  # http://example/icon.jpg
  puts feed.logo  # http://example/logo.jpg

  entries = feed.entries
  entries.each do |entry|
    puts entry.id
    puts entry.title
  end

  entry = entries.first
  entry.title = 'Changed!'

  client.update_entry( entry.edit_link, entry )

  client.delete_entry( entries[2].edit_link )

  new_entry = Atom::Entry.new
  new_entry.title = 'New!'
  new_entry.summary = 'New Entry for Example'
  new_entry.published = Time.now 

  edit_uri = client.create_entry( collection.href, new_entry )

  # you also can use 'slug'
  slug = 'new entry'
  edit_uri = client.create_entry( collection.href, new_entry, slug )

  media_collection = service.workspaces.first.collections[1]
  media_collection_uri = media_collection.href

  media_uri = client.create_media( media_collection_uri, 'foo.jpg', 'image/jpeg')
  # with slug
  # client.create_media( media_collection_uri, 'foo.jpg', 'image/jpeg', 'new-image') 

  media_entry = client.get_entry( media_uri )
  edit_media_link = media_entry.edit_media_link
  client.update_media( edit_media_link, 'bar.jpg', 'image/jpeg' )
  client.delete_media( edit_media_link )

  feed_contains_media_entreis = client.get_feed( media_collection_uri )

= TO DO

* More document
* More tests (RSpec)
* Encoding control
* New Auth classes Atompub::Auth::OpenID and Atompub::Auth::OAuth

= SEE ALSO

AtomPub Spec(RFC)::               http://atompub.org/rfc4287.html
XML::Atom(Perl)::                 http://search.cpan.org/perldoc?XML%3A%3AAtom
XML::Atom::Service(Perl)::        http://search.cpan.org/perldoc?XML%3A%3AAtom%3A%3AService
XML::Atom::Ext::Threading(Perl):: http://search.cpan.org/perldoc?XML%3A%3AAtom%3A%3AExt%3A%3AThreading
Atompub(Perl)::                   http://search.cpan.org/perldoc?Atompub

= Author and License

Author::    Lyo Kato (lyo.kato atmark gmail.com)
Copyright:: Copyright (c) 2007, Lyo Kato All rights reserved.
License::   Ruby License

