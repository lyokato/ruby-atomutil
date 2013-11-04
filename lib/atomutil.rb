#--
# Copyright (C) 2007 Lyo Kato, <lyo.kato _at_ gmail.com>.
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to 
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions: 
#
# The above copyright notice and this permission notice shall be 
# included in all copies or substantial portions of the Software. 
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
#
# This package allows you to handle AtomPub and Atom Syndication Format easily.
# This is just a porting for Perl's great libraries, XML::Atom, XML::Atom::Service,
# XML::Atom::Ext::Threading, and Atompub
#
# http://search.cpan.org/perldoc?XML%3A%3AAtom
# http://search.cpan.org/perldoc?XML%3A%3AAtom%3A%3AService
# http://search.cpan.org/perldoc?XML%3A%3AAtom%3A%3AExt%3A%3AThreading
# http://search.cpan.org/perldoc?Atompub
#
# This package however supports only version 1.0 of Atom(original Perl libraries support also version 0.3),
# and is not stable yet.
# We need more document, more tutorials, and more tests by RSpec.
#++
require 'digest/sha1'
require 'uri'
require 'open-uri'
require 'pathname'
require 'time'
require 'net/https'
require 'rexml/document'

# = Utilities for AtomPub / Atom Syndication Format
#
# This class containts two important modules
#
# [Atom]    Includes classes for parsing or building atom element.
#           For example, Atom::Entry, Atom::Feed, and etc.
#
# [Atompub] Includes client class works according to AtomPub protocol.
#           And other useful helper classes.
#
module AtomUtil
  module VERSION#:nodoc:
    MAJOR = 0
    MINOR = 1
    TINY  = 4
    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end
# = Utility to build or parse Atom Syndication Format
#
# Spec: http://atompub.org/rfc4287.html
#
# This allows you to handle elements used on Atom Syndication Format easily.
# See each element classes' document in detail.
#
# == Service Document
#
# === Element Classes used in service documents
#
# * Atom::Service
# * Atom::Workspace
# * Atom::Collection
# * Atom::Categories
# * Atom::Category
#
# == Categories Document
#
# === Element Classes used in categories documents
#
# * Atom::Categories
# * Atom::Category
#
# == Feed
#
# === Element classes used in feeds.
#
# * Atom::Feed
# * Atom::Entry
#
# == Entry
#
# == Element classes used in entries.
#
# * Atom::Entry
# * Atom::Link
# * Atom::Author
# * Atom::Contributor
# * Atom::Content
# * Atom::Control
# * Atom::Category
#
module Atom
  # Namespace Object Class
  #
  # Example:
  #
  #   namespace = Atom::Namespace.new(:prefix => 'dc', :uri => 'http://purl.org/dc/elements/1.1/')
  #   # you can omit prefix
  #   # namespace = Atom::Namespace.new(:uri => 'http://purl.org/dc/elements/1.1/')
  #   puts namespace.prefix # dc
  #   puts namespace.uri    # http://purl.org/dc/elements/1.1/
  #
  # Mager namespaces are already set as constants. You can use them directly
  # without making new Atom::Namespace instance
  #
  class Namespace
    attr_reader :prefix, :uri
    def initialize(params) #:nodoc:
      @prefix, @uri = params[:prefix], params[:uri]
      raise ArgumentError.new(%Q<:uri is not found.>) if @uri.nil?
    end
    def to_s #:nodoc:
      @uri
    end
    # Atom namespace
    ATOM = self.new :uri => 'http://www.w3.org/2005/Atom'
    # Atom namespace using prefix
    ATOM_WITH_PREFIX = self.new :prefix => 'atom', :uri => 'http://www.w3.org/2005/Atom'
    # Atom namespace for version 0.3
    OBSOLETE_ATOM = self.new :uri => 'http://purl.org/atom/ns#'
    # Atom namespace for version 0.3 using prefix
    OBSOLETE_ATOM_WITH_PREFIX = self.new :prefix => 'atom', :uri => 'http://purl.org/atom/ns#'
    # Atom app namespace
    APP = self.new :uri => 'http://www.w3.org/2007/app'
    # Atom app namespace with prefix
    APP_WITH_PREFIX = self.new :prefix => 'app', :uri => 'http://www.w3.org/2007/app'
    # Atom app namespace for version 0.3
    OBSOLETE_APP = self.new :uri => 'http://purl.org/atom/app#'
    # Atom app namespace for version 0.3 with prefix
    OBSOLETE_APP_WITH_PREFIX = self.new :prefix => 'app', :uri => 'http://purl.org/atom/app#'
    # Dubline Core namespace
    DC = self.new :prefix => 'dc', :uri => 'http://purl.org/dc/elements/1.1/'
    # Open Search namespace that is often used for pagination
    OPEN_SEARCH = self.new :prefix => 'openSearch', :uri => 'http://a9.com/-/spec/opensearchrss/1.1/'
    RDF = self.new :prefix => 'rdf', :uri => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
    FOAF = self.new :prefix => 'foaf', :uri => 'http://xmlns.com/foaf/0.1'
    THR = self.new :prefix => 'thr', :uri => 'http://purl.org/syndication/thread/1.0'
  end
  # = MediaType
  #
  # Class represents MediaType
  #
  # == Accessors
  #
  #   feed = Atom::MediaType.new 'application/atom+xml;type=feed'
  #   puts feed.type               # application
  #   puts feed.subtype            # atom+xml
  #   puts feed.subtype_major      # xml
  #   puts feed.without_parameters # application/atom+xml
  #   puts feed.parameters         # type=feed
  #   puts feed.to_s               # application/atom+xml;type=feed
  #
  # == Equivalence
  #
  #   feed2 = Atom::MediaType.new 'application/atom+xml;type=feed'
  #   entry = Atom::MediaType.new 'application/atom+xml;type=entry'
  #   feed == feed2 # -> true
  #   feed == entry # -> false
  #   feed == 'application/atom+xml;type=feed' # -> true
  #
  # == Constants
  #
  # Major media types for atom syndication format are already prepared.
  # Use following constants for them.
  #
  # [Atom::MediaType::SERVICE]    application/atomsvc+xml
  # [Atom::MediaType::CATEGORIES] application/atomcat+xml
  # [Atom::MediaType::FEED]       application/atom+xml;type=feed
  # [Atom::MediaType::ENTRY]      application/atom+xml;type=entry
  #
  class MediaType
    attr_reader :type, :subtype, :parameters
    def initialize(type) #:nodoc:
      result = type.split(%r<[/;]>)
      @type       = result[0]
      @subtype    = result[1]
      @parameters = result[2]
    end

    def subtype_major
      @subtype =~ /\+(.+)/ ? $1 : @subtype
    end

    def without_parameters
      "#{@type}/#{@subtype}"
    end

    def to_s
      [without_parameters, @parameters].select{ |p| !p.nil? }.join(";")
    end

    def ==(value)
      if value.is_a?(MediaType)
        to_s == value.to_s
      else
        to_s == value
      end
    end

    def is_a?(value)
      value = self.class.new value unless value.instance_of?(self.class)
      return true  if     value.type == '*'
      return false unless value.type == @type
      return true  if     value.subtype == '*'
      return false unless value.subtype == @subtype
      return true  if     value.parameters.nil? || @parameters.nil? 
      return value.parameters == @parameters
    end
    SERVICE    = self.new 'application/atomsvc+xml'
    CATEGORIES = self.new 'application/atomcat+xml'
    FEED       = self.new 'application/atom+xml;type=feed'
    ENTRY      = self.new 'application/atom+xml;type=entry'
  end
  # = Atom::Element
  #
  # Base Element Object Class
  #
  # You don't use this class directly.
  # This is a base class of each element classes used in Atom Syndication Format.
  #
  class Element
    def self.new(params={})
      obj = super(params)
      yield(obj) if block_given?
      obj
    end
    @@ns = Namespace::ATOM
    def self.ns(ns=nil)
      unless ns.nil?
        @@ns = ns.is_a?(Namespace) ? ns : Namespace.new(:uri => ns)
      end
      @@ns
    end
    @element_name = nil
    def self.element_name(name=nil)
      unless name.nil?
        @element_name = name.to_s
      end
      @element_name
    end
    @element_ns = nil
    def self.element_ns(ns=nil)
      unless ns.nil?
        @element_ns = ns.is_a?(Namespace) ? ns : Namespace.new(:uri => ns) 
      end
      @element_ns
    end
    # Generate element accessor for indicated name
    # The generated accessors can deal with elements which has only simple text-node,
    # such as title, summary, rights, and etc.
    # Of course, these elements should handle more complex data.
    # In such a case, you can control them directly with 'set' and 'get' method.
    #
    # Example:
    #
    #   class Entry < Element
    #     element_text_accessor 'title'
    #     element_text_accessor 'summary'
    #   end
    #
    #   elem = MyElement.new
    #   elem.title   = "foo"
    #   elem.summary = "bar"
    #   puts elem.title #foo
    #   puts elem.summary #bar
    #
    #   div = REXML::Element.new("<div><p>hoge</p></div>")
    #   elem.set('http://www.w3.org/2005/Atom', 'title', div, { :type => 'xhtml' })
    #
    def self.element_text_accessor(name)
      name = name.to_s
      name.tr!('-', '_')
      class_eval(<<-EOS, __FILE__, __LINE__)
        def #{name}
          value = get(@ns, '#{name}')
          value.nil? ? nil : value.text
        end
        def #{name}=(value, attributes=nil)
          set(@ns, '#{name}', value, attributes)
        end
      EOS
    end
    # You can set text_accessor at once with this method
    #
    # Example:
    #   class Entry < BaseEntry
    #     element_text_accessors :title, :summary
    #   end
    #   entry = Entry.new
    #   entry.title = "hoge"
    #   puts entry.title #hoge
    #
    def self.element_text_accessors(*names)
      names.each{ |n| element_text_accessor(n) }
    end
    # Generate datetime element accessor for indicated name.
    #
    # Example:
    #   class Entry < BaseEntry
    #     element_datetime_accessor :updated
    #     element_datetime_accessor :published
    #   end
    #   entry = Entry.new
    #   entry.updated = Time.now
    #   puts entry.updated.year
    #   puts entry.updated.month
    #
    def self.element_datetime_accessor(name)
      name = name.to_s
      name.tr!('-', '_')
      class_eval(<<-EOS, __FILE__, __LINE__)
        def #{name}
          dt = get(@ns, '#{name}')
          dt.nil? ? nil : Time.iso8601(dt.text)
        end
        def #{name}=(value, attributes=nil)
          case value
            when Time
              date = value.iso8601
            else
              date = value
          end
          set(@ns, '#{name}', date, attributes)
        end
      EOS
    end
    # You can set datetime accessor at once with this method
    #
    # Example:
    #   class Entry < BaseEntry
    #     element_datetime_accessor :updated, :published
    #   end
    #   entry = Entry.new
    #   entry.updated = Time.now
    #   puts entry.updated.year
    #   puts entry.updated.month
    #
    def self.element_datetime_accessors(*names)
      names.each{ |n| element_datetime_accessor(n) }
    end
    # Generates text accessor for multiple value.
    #
    # Example:
    def self.element_text_list_accessor(name, moniker=nil)
      name = name.to_s
      name.tr!('-', '_')
      unless moniker.nil?
        moniker = moniker.to_s
        moniker.tr!('-', '_') 
      end
      elem_ns = element_ns || ns
      class_eval(<<-EOS, __FILE__, __LINE__)
        def #{name}
          value = getlist('#{elem_ns}', '#{name}')
          value.empty?? nil : value.first
        end
        def #{name}=(stuff)
          set('#{elem_ns}', '#{name}', stuff)
        end
        def add_#{name}(stuff)
          add('#{elem_ns}', '#{name}', stuff)
        end
      EOS
      class_eval(<<-EOS, __FILE__, __LINE__) unless moniker.nil?
        def #{moniker}
          getlist('#{elem_ns}', '#{name}')
        end
        def #{moniker}=(stuff)
          #{name} = stuff
        end
      EOS
    end
    # Generate useful accessor for the multiple element
    #
    # Example:
    #   class Entry < Element
    #     element_object_list_accessors :author, Author, :authors
    #     element_object_list_accessors :contributor, Contributor, :contributors
    #   end
    #
    def self.element_object_list_accessor(name, ext_class, moniker=nil)
      name = name.to_s
      name.tr!('-', '_')
      unless moniker.nil?
        moniker = moniker.to_s
        moniker.tr!('-', '_') 
      end
      elem_ns = ext_class.element_ns || ns
      class_eval(<<-EOS, __FILE__, __LINE__)
        def #{name}
          get_object('#{elem_ns}', '#{name}', #{ext_class})
        end
        def #{name}=(stuff)
          set('#{elem_ns}', '#{name}', stuff)
        end
        def add_#{name}(stuff)
          add('#{elem_ns}', '#{name}', stuff)
        end
      EOS
      class_eval(<<-EOS, __FILE__, __LINE__) unless moniker.nil?
        def #{moniker}
          get_objects('#{elem_ns}', '#{name}', #{ext_class})
        end
        def #{moniker}=(stuff)
          #{name} = stuff
        end
      EOS
    end
    # Attribute accessor generator
    def self.element_attr_accessor(name)
      name = name.to_s
      name.tr!('-', '_')
      class_eval(<<-EOS, __FILE__, __LINE__)
        def #{name}
          get_attr('#{name}')
        end
        def #{name}=(value)
          set_attr('#{name}', value)
        end
      EOS
    end
    # You can generate attribute accessor at once.
    def self.element_attr_accessors(*names)
      names.each{ |n| element_attr_accessor(n) }
    end

    # Setup element.
    def initialize(params={})
      @ns = params.has_key?(:namespace) ? params[:namespace] \
          : self.class.element_ns       ? self.class.element_ns \
          :                               self.class.ns
      @elem = params.has_key?(:elem) ? params[:elem] : REXML::Element.new(self.class.element_name)
      if @ns.is_a?(Namespace)
        unless @ns.prefix.nil?
          @elem.add_namespace @ns.prefix, @ns.uri
        else
          @elem.add_namespace @ns.uri
        end
      else
        @elem.add_namespace @ns
      end
      params.keys.each do |key|
        setter = "#{key}=";
        send(setter.to_sym, params[key]) if respond_to?(setter.to_sym)
      end
    end
    # accessor for xml-element(REXML::Element) object.
    attr_reader :elem
    # This method allows you to handle extra-element such as you can't represent
    # with elements defined in Atom namespace.
    #
    #   entry = Atom::Entry.new
    #   entry.set('http://example/2007/mynamespace', 'foo', 'bar')
    #
    # Now your entry includes new element.
    # <foo xmlns="http://example/2007/mynamespace">bar</foo>
    #
    # You also can add attributes
    #
    #    entry.set('http://example/2007/mynamespace', 'foo', 'bar', { :myattr => 'attr1', :myattr2 => 'attr2' })
    #
    # And you can get following element from entry
    #
    #   <foo xmlns="http://example/2007/mynamespace" myattr="attr1" myattr2="attr2">bar</foo>
    #
    # Or using prefix,
    #
    #   entry = Atom::Entry.new
    #   ns = Atom::Namespace.new(:prefix => 'dc', :uri => 'http://purl.org/dc/elements/1.1/')
    #   entry.set(ns, 'subject', 'buz')
    #
    # Then your element contains
    #
    #   <dc:subject xmlns:dc="http://purl.org/dc/elements/1.1/">buz</dc:subject>
    #
    # And in case you need to handle more complex element, pass the REXML::Element object
    # which you customized as third argument instead of text-value.
    #
    #   custom_element = REXML::Element.new
    #   custom_child = REXML::Element.new('mychild')
    #   custom_child.add_text = 'child!'
    #   custom_element.add_element custom_child
    #   entry.set(ns, 'mynamespace', costom_element)
    #
    def set(ns, element_name, value="", attributes=nil)
      xpath = child_xpath(ns, element_name)
      @elem.elements.delete_all(xpath)
      add(ns, element_name, value, attributes)
    end
    # Same as 'set', but when a element-name confliction occurs,
    # append new element without overriding.
    def add(ns, element_name, value, attributes={})
      element = REXML::Element.new(element_name)
      if ns.is_a?(Namespace)
        unless ns.prefix.nil? || ns.prefix.empty?
          element.name = "#{ns.prefix}:#{element_name}"
          element.add_namespace ns.prefix, ns.uri unless @ns == ns || @ns == ns.uri
        else
          element.add_namespace ns.uri unless @ns == ns || @ns == ns.uri
        end
      else
        element.add_namespace ns unless @ns == ns || @ns.to_s == ns
      end
      if value.is_a?(Element)
        value.elem.each_element do |e|
          element.add e.deep_clone
        end
        value.elem.attributes.each_attribute do |a|
          unless a.name =~ /^xmlns(?:\:)?/
            element.add_attribute a
          end
        end
        element.text = value.elem.text unless value.elem.text.nil?
      else
        if value.is_a?(REXML::Element)
          element.add_element value.deep_clone
        else
          element.add_text value.to_s
        end
      end
      element.add_attributes attributes unless attributes.nil?
      @elem.add_element element
    end
    # Get indicated element.
    # If it matches multiple, returns first one.
    #
    #   elem = entry.get('http://example/2007/mynamespace', 'foo')
    #
    #   ns = Atom::Namespace.new(:prefix => 'dc', :uri => 'http://purl.org/dc/elements/1.1/')
    #   elem = entry.get(ns, 'subject')
    #
    def get(ns, element_name)
      getlist(ns, element_name).first
    end
    # Get indicated elements as array
    #
    #   ns = Atom::Namespace.new(:prefix => 'dc', :uri => 'http://purl.org/dc/elements/1.1/')
    #   elems = entry.getlist(ns, 'subject')
    #
    def getlist(ns, element_name)
      @elem.get_elements(child_xpath(ns, element_name))
    end
    # Get indicated elements as an object of the class you passed as thrid argument.
    #
    #   ns = Atom::Namespace.new(:uri => 'http://example.com/ns#')
    #   obj = entry.get_object(ns, 'mytag', MyClass)
    #   puts obj.class #MyClass
    #
    # MyClass should inherit Atom::Element
    #
    def get_object(ns, element_name, ext_class)
      elements = getlist(ns, element_name)
      return nil if elements.empty?
      ext_class.new(:namespace => ns, :elem => elements.first) 
    end
    # Get all indicated elements as an object of the class you passed as thrid argument.
    #
    #   entry.get_objects(ns, 'mytag', MyClass).each{ |obj|
    #     p obj.class #MyClass
    #   }
    #
    def get_objects(ns, element_name, ext_class)
      elements = getlist(ns, element_name)
      return [] if elements.empty?
      elements.collect do |e|
        ext_class.new(:namespace => ns, :elem => e) 
      end
    end
    # Get attribute value for indicated key
    def get_attr(name)
      @elem.attributes[name.to_s]
    end
    # Set attribute value for indicated key
    def set_attr(name, value)
      @elem.attributes[name.to_s] = value
    end
    # Convert to XML-Document and return it as string
    def to_s(*)
      doc = REXML::Document.new
      decl = REXML::XMLDecl.new("1.0", "utf-8")
      doc.add decl
      doc.add_element @elem
      doc.to_s
    end
    private
    # Get a xpath string to traverse child elements with namespace and name.
    def child_xpath(ns, element_name, attributes=nil)
      ns_uri = ns.is_a?(Namespace) ? ns.uri : ns
      unless !attributes.nil? && attributes.is_a?(Hash)
        "child::*[local-name()='#{element_name}' and namespace-uri()='#{ns_uri}']"
      else
        attr_str = attributes.collect{|key, val| "@#{key.to_s}='#{val}'"}.join(' and ')
        "child::*[local-name()='#{element_name}' and namespace-uri()='#{ns_uri}' and #{attr_str}]"
      end
    end
  end
  # = Atom::Person
  #
  # This class represents person construct
  # Use this for 'author' or 'contributor' elements.
  # You also can use Atom::Author or Atom::Contributor directly for each element,
  # But this class can be converted to each class's object easily
  # with 'to_author' or 'to_contributor' method.
  #
  # Example:
  #
  #   person = Atom::Person.new
  #   person.name = "John"
  #   person.email = "example@example.com"
  #   person.url = "http://example.com/"
  #   entry = Atom::Entry.new
  #   entry.add_authors person.to_author
  #   entry.add_contributor person.to_contributor
  #
  class Person < Element
    element_name :author
    element_text_accessors :name, :email, :uri
    # Convert to an Atom::Author object
    def to_author
      author = Author.new
      author.name = self.name
      author.email = self.email unless self.email.nil?
      author.uri = self.uri unless self.uri.nil?
      author
    end
    # Convert to an Atom::Contributor object
    def to_contributor
      contributor = Contributor.new
      contributor.name = self.name
      contributor.email = self.email unless self.email.nil?
      contributor.uri = self.uri unless self.uri.nil?
      contributor
    end
  end
  # = Atom::Author
  #
  # This class represents Author
  class Author < Person
    element_name :author
  end
  # = Atom::Contributor
  #
  # This class represents Contributor
  class Contributor < Person
    element_name :contributor
  end

  class Generator < Element
    element_name :generator
    element_attr_accessors :uri, :version
    def name
      @elem.text
    end
    def name=(name)
      @elem.text = name
    end
  end
  # = Atom::Link
  #
  # This class represents link element
  #
  # You can use these accessors
  #  * href
  #  * rel
  #  * type
  #  * hreflang
  #  * title
  #  * length
  #
  class Link < Element
    element_name :link
    element_attr_accessors :href, :rel, :type, :hreflang, :title, :length
    def to_replies_link
      RepliesLink.new(:elem => @elem)
    end
  end

  class RepliesLink < Link

    def initialize(params={})
      super(params)
      @elem.add_namespace(Namespace::THR.prefix, Namespace::THR.uri)
      set_attr('rel', 'replies')
    end

    def rel=(name)
    end

    def count
      num = get_attr('thr:count')
      num.nil?? nil : num.to_i
    end

    def count=(num)
      set_attr('thr:count', num.to_s)
    end

    def updated
      value = get_attr('thr:updated')
      value.nil?? nil : Time.iso8601(value)
    end

    def updated=(time)
      time = time.iso8601 if time.instance_of?(Time)
      set_attr('thr:updated', time)
    end

  end

  class ReplyTarget < Element
    element_ns Namespace::THR
    element_name 'in-reply-to'
    element_attr_accessors :href, :ref, :type, :source

    def id
      self.ref
    end

    def id=(ref)
      self.ref = ref
    end

  end

  # Category class
  class Category < Element
    element_name :category
    element_attr_accessors :term, :scheme, :label
  end
  # Content class
  class Content < Element

    element_name :content
    element_attr_accessors :type, :src

    def initialize(params={})
      super(params)
      #self.body = params[:body] if params.has_key?(:body)
      self.type = params[:type] if params.has_key?(:type)
    end

    def body=(value)

      if value =~ Regexp.new("^(?:
        [[:print:]]
        |[\xc0-\xdf][\x80-\xbf]
        |[\xe0-\xef][\x80-\xbf]{2}
        |[\xf0-\xf7][\x80-\xbf]{3}
        |[\xf8-\xfb][\x80-\xbf]{4}
        |[\xfc-\xfd][\x80-\xbf]{5}
        )*$", Regexp::EXTENDED, 'n')
      #if value =~ /^(?:
      #   [[:print:]]
      #  |[\xc0-\xdf][\x80-\xbf]
      #  |[\xe0-\xef][\x80-\xbf]{2}
      #  |[\xf0-\xf7][\x80-\xbf]{3}
      #  |[\xf8-\xfb][\x80-\xbf]{4}
      #  |[\xfc-\xfd][\x80-\xbf]{5}
      #  )*$/x
        copy = "<div xmlns=\"http://www.w3.org/1999/xhtml\">#{value}</div>"  
        is_valid = true
        begin
          node = REXML::Document.new(copy).elements[1][0]
        rescue
          is_valid = false
        end
        if is_valid && node.instance_of?(REXML::Element)
          @elem.add_element node
          self.type = 'xhtml'
        else
          @elem.add_text value
          self.type = (value =~ /^\s*</) ? 'html' : 'text'
        end
      else
        @elem.add_text([value].pack('m').chomp)
      end
    end

    def body
      if @body.nil?
        mode = self.type == 'xhtml'       ? 'xml'\
             : self.type =~ %r{[\/+]xml$} ? 'xml'\
             : self.type == 'html'        ? 'escaped'\
             : self.type == 'text'        ? 'escaped'\
             : self.type =~ %r{^text}     ? 'escaped'\
             :                              'base64'
        case(mode)
          when 'xml'
            unless @elem.elements.empty?
              if @elem.elements.size == 1 && @elem.elements[1].name == 'div'
                @body = @elem.elements[1].collect{ |c| c.to_s }.join('')
              else
                @body = @elem.collect{ |c| c.to_s }.join('')
              end
            else
              @body = @elem.text
            end
          when 'escaped'
            @body = @elem.text
          when 'base64'
            text = @elem.text
            @body = text.nil?? nil : text.unpack('m').first
          else
            @body = nil
        end
      end
      @body
    end
  end

  class RootElement < Element
    def initialize(params={})
      super(params)
      if params.has_key?(:stream)
        stream = params[:stream]
        @elem = REXML::Document.new(stream).root
      elsif params.has_key?(:doc)
        @elem = params[:doc].elements[1]
      end
      @ns = Namespace.new(:uri => @elem.namespace)
    end
  end

  class CoreElement < RootElement

    element_text_accessors :id, :title, :rights
    element_datetime_accessor :updated
    element_object_list_accessor :link,        Link,        :links
    element_object_list_accessor :category,    Category,    :categories
    element_object_list_accessor :author,      Author,      :authors
    element_object_list_accessor :contributor, Contributor, :contributors

    def self.element_link_accessor(type)
      type = type.to_s
      meth_name = [type.tr('-','_'), 'link'].join('_')
      class_eval(<<-EOS, __FILE__, __LINE__)

        def #{meth_name}
          selected = links.select{ |l| l.rel == '#{type}' }
          selected.empty? ? nil : selected.first.href
        end

        def #{meth_name}s
          links.select{ |l| l.rel == '#{type}' }.collect{ |l| l.href }
        end

        def add_#{meth_name}(href)
          l = Link.new
          l.href = href
          l.rel = '#{type}'
          add_link l
        end

        def #{meth_name}=(href)
          xpath = child_xpath(Namespace::ATOM, 'link', { :rel => '#{type}' })
          @elem.elements.delete_all(xpath)
          add_#{meth_name}(href)
        end
      EOS
    end

    def self.element_link_accessors(*types)
      types.flatten.each{ |type| element_link_accessor(type) }
    end

    element_link_accessors %w(self edit edit-media related enclosure via first previous next last)

    def alternate_links
      links.select{ |l| l.rel.nil? || l.rel == 'alternate' }.collect{ |l| l.href }
    end

    def alternate_link
      alternates = links.select{ |l| l.rel.nil? || l.rel == 'alternate' }
      alternates.empty? ? nil : alternates.first.href
    end

    def add_alternate_link(href)
      l = Link.new
      l.href = href
      l.rel = 'alternate'
      add_link l
    end

    def alternate_link=(href)
      xpath = child_xpath(Namespace::ATOM, 'link', { :rel => 'alternate' })
      @elem.elements.delete_all(xpath)
      add_alternate_link(href)
    end

    def initialize(params={})
      if params.has_key?(:uri) || params.has_key?(:file)
        target = params.has_key?(:uri)         ? URI.parse(params.delete(:uri)) \
               : params[:file].is_a?(Pathname) ? params.delete(:file) \
               :                                 Pathname.new(params.delete(:file))
        params[:stream] = target.open { |f| f.read }
      end
      super(params)
    end

  end

  class Control < Element
    element_ns Namespace::APP_WITH_PREFIX
    element_name :control
    element_text_accessor :draft
  end

  class Categories < Element
    element_ns Namespace::APP
    element_name :categories
    element_attr_accessors :href, :scheme, :fixed

    def category
      get_object(Namespace::ATOM_WITH_PREFIX, 'category', Category)
    end

    def category=(value)
      set(Namespace::ATOM_WITH_PREFIX, 'category', value)
    end

    def add_category(value)
      add(Namespace::ATOM_WITH_PREFIX, 'category', value)
    end

    def categories
      get_objects(Namespace::ATOM_WITH_PREFIX, 'category', Category)
    end

    def categories=(value)
      category = value
    end
  end

  class Collection < Element
    element_ns Namespace::APP
    element_name :collection
    element_attr_accessor :href
    element_text_list_accessor :accept, :accepts
    element_object_list_accessor :categories, Categories, :categories_list
    def title
      title = get(Namespace::ATOM_WITH_PREFIX, 'title')
      title.nil?? nil : title.text
    end
    def title=(value)
      set(Namespace::ATOM_WITH_PREFIX, 'title', value)
    end

  end

  class Workspace < Element
    element_ns Namespace::APP
    element_name :workspace
    element_object_list_accessor :collection, Collection, :collections
    def title
      title = get(Namespace::ATOM_WITH_PREFIX, 'title')
      title.nil?? nil : title.text
    end
    def title=(value)
      set(Namespace::ATOM_WITH_PREFIX, 'title', value)
    end
  end
  # = Atom::Service
  #
  # This class represents service document
  #
  class Service < RootElement
    element_ns Namespace::APP
    element_name :service
    element_object_list_accessor :workspace, Workspace, :workspaces
  end

  class Entry < CoreElement
    element_name :entry
    element_text_accessors :source, :summary
    element_datetime_accessor :published
    element_link_accessor :replies

    def links
      ls = super
      ls.collect do |l|
        l.rel == 'replies' ? l.to_replies_link : l
      end
    end

    def link
      l = super
      l.rel == 'replies' ? l.to_replies_link : l
    end

    def control
      get_object(Namespace::APP_WITH_PREFIX, 'control', Control)
    end

    def control=(control)
      set(Namespace::APP_WITH_PREFIX, 'control', control)
    end

    def add_control(control)
      add(Namespace::APP_WITH_PREFIX, 'control', control)
    end

    def controls
      get_objects(Namespace::APP_WITH_PREFIX, 'control', Control)
    end

    def controls=(control)
      control = control
    end

    def edited
      get(Namespace::APP_WITH_PREFIX, 'edited')
    end

    def edited=(value)
      set(Namespace::APP_WITH_PREFIX, 'edited', value)
    end

    def total
      value = get(Namespace::THR, 'total')
      value.nil?? nil : value.to_i
    end

    def total=(value)
      set(Namespace::THR, 'total', value.to_s)
    end

    def content
      get_object(@ns, 'content', Content)
    end

    def content=(value)
      unless value.is_a?(Content)
        value = Content.new(:body => value)
      end
      set(@ns, 'content', value)
    end

    def in_reply_to(value=nil)
      if value.nil?
        get_object(Namespace::THR, 'in-reply-to', ReplyTarget)
      else
        value = ReplyTarget.new(value) if value.is_a?(Hash)
        set(Namespace::THR, 'in-reply-to', value)
      end
    end

  end
  # Feed Class
  #
  class Feed < CoreElement
    element_name :feed
    element_text_accessors :icon, :logo, :subtitle
    element_object_list_accessor :entry, Entry, :entries

    def total_results
      value = get(Namespace::OPEN_SEARCH, 'totalResults')
      value.nil?? nil : value.text.to_i
    end

    def total_results=(num)
      set(Namespace::OPEN_SEARCH, 'totalResults', num.to_s)
    end

    def start_index
      value = get(Namespace::OPEN_SEARCH, 'startIndex')
      value.nil?? nil : value.text.to_i
    end

    def start_index=(num)
      set(Namespace::OPEN_SEARCH, 'startIndex', num.to_s)
    end

    def items_per_page
      value = get(Namespace::OPEN_SEARCH, 'itemsPerPage')
      value.nil?? nil : value.text.to_i
    end

    def items_per_page=(num)
      set(Namespace::OPEN_SEARCH, 'itemsPerPage', num.to_s)
    end

    def generator
       get_object(Namespace::ATOM, 'generator', Generator)
    end

    def generator=(gen)
      gen = gen.is_a?(Generator) ? gen : Generator.new(:name => gen)
      set(Namespace::ATOM, 'generator', gen)
    end
    
    def language
      @elem.attributes['xml:lang']
    end

    def language=(lang)
      #@elem.add_attribute 'lang', 'http://www.w3.org/XML/1998/Namespace'
      @elem.add_attribute 'xml:lang', lang
    end

    def version
      @elem.attributes['version']
    end

    def version=(ver)
      @elem.add_attribute 'version', ver
    end
  end
end
# = Atompub
#
module Atompub

  class RequestError       < StandardError; end #:nodoc:
  class AuthError          < RequestError ; end #:nodoc:
  class CacheNotFoundError < RequestError ; end #:nodoc:
  class ResponseError      < RequestError ; end #:nodoc:
  class MediaTypeError     < RequestError ; end #:nodoc:
  # = Atompub::CacheResource
  #
  # Cache resource that is stored by AbstractCache or it's subclass.
  # This class just has only three accessors.
  #
  # * etag
  # * last_modofied
  # * resource
  #
  class CacheResource
    attr_accessor :etag, :last_modified, :resource
    def initialize(params)
      @etag          = params[:etag]
      @last_modified = params[:last_modified]
      @resource      = params[:rc]
    end
  end
  # = Atompub::AbstractCache
  #
  # Cache storage for atompub networking.
  # In case the server that provieds AtomPub-API handles caching with
  # http headers, ETag or If-Modified-Since, you can handle them with this class.
  # But this class does nothing, use subclass that inherits this.
  #
  class AbstractCache
    # singleton closure
    @@singleton = nil
    # Get singleton instance.
    def self.instance
      @@singleton = self.new if @@singleton.nil?
      @@singleton
    end
    # initializer
    def initialize
    end
    # Get cache resource for indicated uri
    def get(uri)
      nil
    end
    # Store cache resource
    def put(uri, params)
    end
  end
  # = Atompub::SimpleCache
  #
  # Basic cache storage class.
  # Use Hash object to store data.
  class SimpleCache < AbstractCache
    # singleton closure
    @@singleton = nil
    # Get singleton instance
    def self.instance
      @@singleton = self.new if @@singleton.nil?
      @@singleton
    end
    # initializer
    def initialize
      @cache = Hash.new
    end
    # Pick cache resource from hash for indicated uri.
    def get(uri)
      @cache.has_key?(uri) ? @cache[uri] : nil
    end
    # Set cache resource into hash.
    def put(uri, params)
      @cache[uri] = CacheResource.new(params)
    end

  end

  class ServiceInfo

    def initialize(params)
      @collection = params[:collection]
      @allowed_categories = nil
      @accepts = nil
    end

    def allows_category?(test)
      return true if @collection.nil?
      categories_list = @collection.categories_list
      return true if categories_list.empty?
      return true if categories_list.all? { |cats| cats.fixed.nil? || cats.fixed != 'yes' }
      if @allowed_categories.nil?
        @allowed_categories = categories_list.collect do |cats|
          cats.categories.collect do |cat|
            scheme = cat.scheme || cats.scheme || nil
            new_cat = Atom::Category.new :term => cat.term
            new_cat.scheme = scheme unless scheme.nil?
            new_cat
          end
        end.flatten
      end
      return false if @allowed_categories.empty?
      @allowed_categories.any?{ |c| c.term == test.term && (c.scheme.nil? || (!c.scheme.nil? && c.scheme == test.scheme )) }
    end

    def accepts_media_type?(content_type)
      return true if @collection.nil?
      if @accepts.nil?
        @accepts = @collection.accepts.collect do |accept|
          accept.text.split(/[\s,]+/) 
        end.flatten
        @accepts << Atom::MediaType::ENTRY if @accepts.empty?
      end
      type = Atom::MediaType.new(content_type)
      @accepts.any?{ |a| type.is_a?(a) }
    end

  end

  class ServiceInfoStorage

    @@singleton = nil

    def self.instance
      @@singleton = self.new if @@singleton.nil?
      @@singleton
    end

    def initialize
      @info = Hash.new
    end

    def get(uri)
      @info.has_key?(uri) ? @info[uri] : nil
    end

    def put(uri, collection, client=nil)
      new_collection = clone_collection(collection, client)
      @info[uri] = ServiceInfo.new(:collection => new_collection)
    end

    private
    def clone_collection(collection, client=nil)
      coll = Atom::Collection.new
      coll.title = collection.title
      coll.href  = collection.href
      collection.accepts.each { |a| coll.add_accept a.text }
      collection.categories_list.each do |cats|
        unless cats.nil?
          new_cats = cats.href.nil?? clone_categories(cats) : get_categories(cats.href, client) 
          coll.categories = new_cats unless new_cats.nil?
        end
      end
      coll
    end

    def get_categories(uri, client=nil)
      client.nil?? nil : client.get_categories(uri)
    end

    def clone_categories(categories)
      cats = Atom::Categories.new
      cats.fixed  = categories.fixed
      cats.scheme = categories.scheme
      categories.categories.each do |c|
        new_c = Atom::Category.new
        new_c.term = c.term
        new_c.scheme = c.scheme
        new_c.label = c.label
        cats.add_category new_c
      end
      cats
    end
  end
  # = Atompub::Client
  #
  class Client
    # user agent
    attr_accessor :agent
    # request object for current networking context
    attr_reader :req
    alias_method :request, :req
    # response object for current networking context
    attr_reader :res
    alias_method :response, :res
    # resource object for current networking context
    attr_reader :rc
    alias_method :resource, :rc
    # Initializer
    #
    # * auth
    # * cache
    #
    def initialize(params={})
      unless params.has_key?(:auth)
        throw ArgumentError.new("Atompub::Client needs :auth as argument for constructor.")
      end
      @auth  = params.has_key?(:auth) && params[:auth].kind_of?(Auth::Abstract) ? params[:auth] : Auth::Abstract.new
      @cache = params.has_key?(:cache) && params[:cache].kind_of?(AbstractCache) ? params[:cache] : AbstractCache.instance
      @service_info = params.has_key?(:info) && params[:info].kind_of?(ServiceInfoStorage) ? params[:info] : ServiceInfoStorage.instance
      @http_class = Net::HTTP
      @agent = "Atompub::Client/#{AtomUtil::VERSION}"
    end
    # Set proxy if you need.
    #
    # Example:
    #
    #   client.use_proxy('http://myproxy/', 8080)
    #   client.use_proxy('http://myproxy/', 8080, 'myusername', 'mypassword')
    #
    def use_proxy(uri, port, user=nil, pass=nil)
      @http_class = Net::HTTP::Proxy(uri, port, user, pass)
    end
    # Get service document
    # This returns Atom::Service object.
    # see the document of Atom::Service in detail.
    #
    # Example:
    #
    #   service = client.get_service(service_uri)
    #   service.workspaces.each do |w|
    #     w.collections.each do |c|
    #       puts c.href
    #     end
    #   end
    #
    def get_service(service_uri)
      get_contents_except_resources(service_uri) do |res|
        #warn "Bad Content Type" unless Atom::MediaType::SERVICE.is_a?(@res['Content-Type'])
        @rc = Atom::Service.new :stream => @res.body
        @rc.workspaces.each do |workspace|
          workspace.collections.each do |collection|
            #@service_info.put(collection.href, collection, self) 
            @service_info.put(collection.href, collection) 
          end
        end
      end
      @rc
    end
    # Get categories
    # This returns Atom::Categories object.
    # see the document of Atom::Categories in detail.
    #
    # Example:
    #
    #
    def get_categories(categories_uri)
      get_contents_except_resources(categories_uri) do |res|
        #warn "Bad Content Type" unless Atom::MediaType::CATEGORIES.is_a?(@res['Content-Type'])
        @rc = Atom::Categories.new :stream => @res.body
      end
      @rc
    end
    # Get feed
    # This returns Atom::Feed object.
    # see the document of Atom::Feed in detail.
    #
    # Example:
    #
    def get_feed(feed_uri)
      get_contents_except_resources(feed_uri) do |res|
        #warn "Bad Content Type" unless Atom::MediaType::FEED.is_a?(@res['Content-Type'])
        @rc = Atom::Feed.new :stream => res.body
      end
      @rc
    end
    # Get entry
    #
    # Example:
    #
    #   entry = client.get_entry(entry_uri)
    #   puts entry.id
    #   puts entry.title
    #
    def get_entry(entry_uri)
      get_resource(entry_uri)
      unless @rc.instance_of?(Atom::Entry)
        raise ResponseError, "Response is not Atom Entry"
      end
      @rc
    end
    # Get media resource
    #
    # Example:
    #
    #   resource, content_type = client.get_media(media_uri)
    #
    def get_media(media_uri)
      get_resource(media_uri)
      if @rc.instance_of?(Atom::Entry)
        raise ResponseError, "Response is not Media Resource"
      end
      return @rc, @res.content_type
    end
    # Create new entry
    #
    # Example:
    #
    #   entry = Atom::Entry.new
    #   entry.title = 'foo'
    #   author = Atom::Author.new
    #   author.name = 'Lyo Kato'
    #   author.email = 'lyo.kato@gmail.com'
    #   entry.author = author
    #   entry_uri = client.create_entry(post_uri, entry)
    #
    def create_entry(post_uri, entry, slug=nil)
      unless entry.kind_of?(Atom::Entry)
        entry = Atom::Entry.new :stream => entry
      end
      service = @service_info.get(post_uri)
      unless entry.categories.all?{ |c| service.allows_category?(c) }
        raise RequestError, "Forbidden Category"
      end
      create_resource(post_uri, entry.to_s, Atom::MediaType::ENTRY.to_s, slug)
      @res['Location']
    end
    # Create new media resource
    #
    # Example:
    #
    #   media_uri = client.create_media(post_media_uri, 'myimage.jpg', 'image/jpeg')
    #
    def create_media(media_uri, file_path, content_type, slug=nil)
      file_path = Pathname.new(file_path) unless file_path.is_a?(Pathname)
      stream = file_path.open { |f| f.binmode; f.read }
      service = @service_info.get(media_uri)
      if service.nil?
        raise RequestError, "Service information not found. Get service document before you do create_media."
      end
      unless service.accepts_media_type?(content_type)
        raise RequestError, "Unsupported Media Type: #{content_type}"
      end
      create_resource(media_uri, stream, content_type, slug)
      @res['Location']
    end
    # Update entry
    #
    # Example:
    #
    #   entry = client.get_entry(resource_uri)
    #   entry.summary = "Changed Summary!"
    #   client.update_entry(entry)
    #
    def update_entry(edit_uri, entry)
      unless entry.kind_of?(Atom::Entry)
        entry = Atom::Entry.new :stream => entry
      end
      update_resource(edit_uri, entry.to_s, Atom::MediaType::ENTRY.to_s)
    end
    # Update media resource
    #
    # Example:
    #
    #   entry = client.get_entry(media_link_uri)
    #   client.update_media(entry.edit_media_link, 'newimage.jpg', 'image/jpeg')
    #
    def update_media(media_uri, file_path, content_type)
      file_path = Pathname.new(file_path) unless file_path.is_a?(Pathname)
      stream = file_path.open { |f| f.binmode; f.read }
      update_resource(media_uri, stream, content_type)
    end
    # Delete entry
    #
    # Example:
    #
    #   entry = client.get_entry(resource_uri)
    #   client.delete_entry(entry.edit_link)
    #
    def delete_entry(edit_uri)
      delete_resource(edit_uri) 
    end
    # Delete media
    #
    # Example:
    #
    #   entry = client.get_entry(resource_uri)
    #   client.delete_media(entry.edit_media_link)
    #
    def delete_media(media_uri)
      delete_resource(media_uri)
    end
    private
    # Set request headers those are required on each request accessing resources.
    def set_common_info(req)
      req['User-Agent'] = @agent
      @auth.authorize(req) 
    end
    # Get contents, for example, service-document, categories, and feed.
    def get_contents_except_resources(uri, &block)
      clear
      uri = URI.parse(uri)
      @req = Net::HTTP::Get.new uri.request_uri
      set_common_info(@req)
      @http_class.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        @res = http.request(@req)
        case @res
          when Net::HTTPOK
            block.call(@res) if block_given?
          else
            raise RequestError, "Failed to get contents. #{@res.code}"
        end
      end
    end
    # Get resouces(entry or media)
    def get_resource(uri)
      clear
      uri = URI.parse(uri)
      @req = Net::HTTP::Get.new uri.request_uri
      set_common_info(@req)
      cache = @cache.get(uri.to_s)
      unless cache.nil?
        @req['If-Modified-Since'] = cache.last_modified unless cache.last_modified.nil?
        @req['If-None-Match'] = cache.etag unless cache.etag.nil?
      end
      @http_class.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        @res = http.request(@req)
        case @res
          when Net::HTTPOK
            if Atom::MediaType::ENTRY.is_a?(@res['Content-Type'])
              @rc = Atom::Entry.new :stream => @res.body
            else
              @rc = @res.body
            end
            @cache.put uri.to_s, {
              :rc            => @rc,
              :last_modified => @res['Last-Modified'],
              :etag          => @res['ETag'] }
          when Net::HTTPNotModified
            unless cache.nil?
              @rc = cache.rc
            else
              raise CacheNotFoundError, "Got Not-Modified response, but has no cache."
            end
          else
            raise RequestError, "Failed to get content. #{@res.code}"
        end
      end
    end
    # Create new resources(entry or media)
    def create_resource(uri, r, content_type, slug=nil)
      clear
      uri = URI.parse(uri)
      #service = @service_info.get(uri.to_s)
      #unless service.accepts_media_type(content_type)
      #  raise UnsupportedMediaTypeError, "Unsupported media type: #{content_type}."
      #end
      @req = Net::HTTP::Post.new uri.request_uri
      @req['Content-Type'] = content_type
      @req['Slug'] = URI.encode(URI.decode(slug)) unless slug.nil?
      set_common_info(@req)
      @req.body = r
      @http_class.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        @res = http.request(@req)
        case @res
          when Net::HTTPSuccess
            #warn "Bad Status Code: #{@res.code}" unless @res.class == Net::HTTPCreated
            #warn "Bad Content Type: #{@res['Content-Type']}" unless Atom::MediaType::ENTRY.is_a?(@res['Content-Type'])
            if @res['Location'].nil?
              raise ResponseError, "No Location"
            end
            unless @res.body.nil?
              @rc = Atom::Entry.new :stream => @res.body
              @cache.put uri.to_s, {
                :rc            => @rc,
                :last_modified => @res['Last-Modified'],
                :etag          => @res['ETag']
              }
            end
          else
            error_message = @res.body.nil?? "#{@res.code}" : "#{@res.code} / #{@res.body}"
            raise RequestError, "Failed to create resource. #{error_message}"
        end
      end
    end
    # updated resources(entry or media)
    def update_resource(uri, r, content_type)
      clear
      uri = URI.parse(uri)
      @req = Net::HTTP::Put.new uri.request_uri
      @req['Content-Type'] = content_type
      cache = @cache.get(uri.to_s)
      unless cache.nil?
        @req['If-Not-Modified-Since'] = cache.last_modofied unless cache.last_modified.nil?
        @req['If-Match'] = cache.etag unless cache.etag.nil?
      end
      set_common_info(@req)
      @req.body = r
      @http_class.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        @res = http.request(@req)
        case @res
          when Net::HTTPSuccess
            #warn "Bad Status Code: #{@res.code}" unless @res.class == Net::HTTPOK || @res.class == Net::HTTPNoContent
            unless @res.body.nil?
              @rc = Atom::MediaType::ENTRY.is_a?(@res['Content-Type']) ? Atom::Entry.new(:stream => @res.body) : @res.body
              @cache.put uri.to_s, {
                :rc            => @rc,
                :etag          => @res['ETag'],
                :last_modified => @res['Last-Modified'] }
            end
          else
            raise RequestError, "Failed to update resource. #{@res.code}"
        end
      end
    end
    # Delete resources(entry or media)
    def delete_resource(uri)
      clear
      uri = URI.parse(uri)
      @req = Net::HTTP::Delete.new uri.request_uri
      set_common_info(@req)
      @http_class.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        @res = http.request(@req)
        case @res
          when Net::HTTPSuccess
            #warn "Bad Status Code: #{@res.code}" unless @res.class == Net::HTTPOK || @res.class == Net::HTTPNoContent
          else
            raise RequestError, "Failed to delete resource. #{@res.code}"
          end
      end
    end
    # clear objects which depend on each networking context.
    def clear
      @req = nil
      @res = nil
      @rc  = nil
    end
  end
  # Authentication classes
  module Auth
    class Abstract
      def initialize(params)
      end
      def authorize(req)
      end
    end
    # = Atompub::Auth::Wsse
    #
    # Class handles WSSE authentication
    # All you have to do is create this class's object with username and password,
    # and pass to Atompub::Client#new
    #
    # Usage:
    #
    #   auth = Atompub::Auth::Wsse.new :username => username, :password => password
    #   client = Atompub::Client.new :auth => auth
    #
    class Wsse < Abstract
      # initializer
      #
      # Set two parameters as hash
      # * username 
      # * password
      #
      # Usage:
      #
      #   auth = Atompub::Auth::Wsse.new :username => name, :password => pass
      #
      def initialize(params)
        @username, @password = params[:username], params[:password]
      end
      # Add credential info to Net::HTTP::Request object
      #
      # Usaage:
      #
      #   req = Net::HTTP::Get.new uri.request_uri
      #   auth.authorize(req)
      #
      def authorize(req)
        req['Authorization'] = 'WSSE profile="UsernameToken"'
        req['X-Wsse'] = gen_token
      end
      private
      # Generate username token for WSSE authentication
      def gen_token
        nonce = Array.new(10){rand(0x100000000)}.pack('I*')
        nonce_base64 = [nonce].pack('m').chomp
        now = Time.now.utc.iso8601
        digest = [Digest::SHA1.digest(nonce + now + @password)].pack('m').chomp
        sprintf(%Q<UsernameToken Username="%s", PasswordDigest="%s", Nonce="%s", Created="%s">,
          @username, digest, nonce_base64, now)
      end
    end
    # = Atompub::Auth::Basic
    #
    # Usage:
    #
    #   auth = Atompub::Auth::Basic.new :username => username, :password => password
    #   client = Atompub::Client.new :auth => auth
    #
    class Basic < Abstract
      # initializer
      #
      # Set two parameters as hash
      # * username 
      # * password
      #
      # Usage:
      #
      #   auth = Atompub::Auth::Basic.new :username => name, :password => pass
      #
      def initialize(params)
        @username, @password = params[:username], params[:password]
      end
      # Add credential info to Net::HTTP::Request object
      #
      # Usage:
      #
      #   req = Net::HTTP::Get.new uri.request_uri
      #   auth.authorize(req)
      #
      def authorize(req)
        req.basic_auth @username, @password
      end
    end
  end

end

