require File.dirname(__FILE__) + '/spec_helper.rb'

describe Atom::Namespace, "namespace object" do

  it "should handle accessor collectly" do
    my_ns = Atom::Namespace.new :uri => 'http://example.org/ns', :prefix => 'ex'
    my_ns.prefix.should == 'ex'
    my_ns.uri.should == 'http://example.org/ns'
    my_ns.to_s.should == 'http://example.org/ns'
  end

  it "should handle major namespaces as constans" do
    Atom::Namespace::ATOM.prefix.should be_nil
    Atom::Namespace::ATOM.uri.should == 'http://www.w3.org/2005/Atom'
    Atom::Namespace::ATOM_WITH_PREFIX.prefix.should == 'atom'
    Atom::Namespace::ATOM_WITH_PREFIX.uri.should == 'http://www.w3.org/2005/Atom'
    Atom::Namespace::OBSOLETE_ATOM.prefix.should be_nil
    Atom::Namespace::OBSOLETE_ATOM.uri.should == 'http://purl.org/atom/ns#'
    Atom::Namespace::OBSOLETE_ATOM_WITH_PREFIX.prefix.should == 'atom'
    Atom::Namespace::OBSOLETE_ATOM_WITH_PREFIX.uri.should == 'http://purl.org/atom/ns#'
    Atom::Namespace::APP.prefix.should be_nil
    Atom::Namespace::APP.uri.should == 'http://www.w3.org/2007/app'
    Atom::Namespace::APP_WITH_PREFIX.prefix.should == 'app'
    Atom::Namespace::APP_WITH_PREFIX.uri.should == 'http://www.w3.org/2007/app'
    Atom::Namespace::OBSOLETE_APP.prefix.should be_nil
    Atom::Namespace::OBSOLETE_APP.uri.should == 'http://purl.org/atom/app#'
    Atom::Namespace::OBSOLETE_APP_WITH_PREFIX.prefix.should == 'app'
    Atom::Namespace::OBSOLETE_APP_WITH_PREFIX.uri.should == 'http://purl.org/atom/app#'
    Atom::Namespace::OPEN_SEARCH.prefix.should == 'openSearch'
    Atom::Namespace::OPEN_SEARCH.uri.should == 'http://a9.com/-/spec/opensearchrss/1.1/'
    Atom::Namespace::FOAF.prefix.should == 'foaf'
    Atom::Namespace::FOAF.uri.should == 'http://xmlns.com/foaf/0.1'
    Atom::Namespace::DC.prefix.should == 'dc'
    Atom::Namespace::DC.uri.should == 'http://purl.org/dc/elements/1.1/'
    Atom::Namespace::RDF.prefix.should == 'rdf'
    Atom::Namespace::RDF.uri.should == 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
  end

end

