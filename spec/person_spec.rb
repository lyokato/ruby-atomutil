require File.dirname(__FILE__) + '/spec_helper.rb'

describe Atom::Person, "builds" do

  before do
    @person = Atom::Person.new
  end

  it "should set and get name" do
    @person.name = "Lyo Kato"
    @person.name.should == "Lyo Kato"
  end

  it "should set and get email" do
    @person.email = "lyo.kato@gmail.com"
    @person.email.should == "lyo.kato@gmail.com"
  end

  it "should set and get uri" do
    @person.uri = "http://www.lyokato.net/"
    @person.uri.should == "http://www.lyokato.net/"
  end

  it "should build xml" do
    @person.name = "Lyo Kato"
    @person.email = "lyo.kato@gmail.com"
    @person.uri = "http://www.lyokato.net/"
    person_xml = @person.to_s
    person_xml.should =~ /<author(?: xmlns='http:\/\/www\.w3\.org\/2005\/Atom')?>/
    person_xml.should =~ /<name(?: xmlns='http:\/\/www\.w3\.org\/2005\/Atom')?>Lyo Kato<\/name>/
    person_xml.should =~ /<email(?: xmlns='http:\/\/www\.w3\.org\/2005\/Atom')?>lyo\.kato\@gmail\.com<\/email>/
  end

  it "should be converted to Author" do
    @person.name = "Lyo Kato"
    @person.email = "lyo.kato@gmail.com"
    @person.uri = "http://www.lyokato.net/"
    author = @person.to_author
    author.should be_instance_of(Atom::Author)
    author.name.should == "Lyo Kato"
    author_xml = author.to_s
    author_xml.should =~ /<author(?: xmlns='http:\/\/www\.w3\.org\/2005\/Atom')?>/
    author_xml.should =~ /<name(?: xmlns='http:\/\/www\.w3\.org\/2005\/Atom')?>Lyo Kato<\/name>/
    author_xml.should =~ /<email(?: xmlns='http:\/\/www\.w3\.org\/2005\/Atom')?>lyo\.kato\@gmail\.com<\/email>/
  end

  it "should be converted to Contributor" do
    @person.name = "Lyo Kato"
    @person.email = "lyo.kato@gmail.com"
    @person.uri = "http://www.lyokato.net/"
    contributor = @person.to_contributor
    contributor.should be_instance_of(Atom::Contributor)
    contributor.name.should == "Lyo Kato"
    contributor_xml = contributor.to_s
    contributor_xml.should =~ /<contributor(?: xmlns='http:\/\/www\.w3\.org\/2005\/Atom')>/
    contributor_xml.should =~ /<name(?: xmlns='http:\/\/www\.w3\.org\/2005\/Atom')?>Lyo Kato<\/name>/
    contributor_xml.should =~ /<email(?: xmlns='http:\/\/www\.w3\.org\/2005\/Atom')?>lyo\.kato\@gmail\.com<\/email>/
  end

end

