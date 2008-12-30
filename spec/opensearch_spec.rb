require File.dirname(__FILE__) + '/spec_helper.rb'

describe Atom::Feed, "extended with openSearch namespace" do

  it "should handle openSearch namespace collectly" do
    feed = Atom::Feed.new
    feed.total_results = 30
    feed.items_per_page = 10
    feed.start_index = 1

    feed.total_results.should == 30
    feed.items_per_page.should == 10
    feed.start_index.should == 1

    xmlstring = feed.to_s
    xmlstring.should =~ %r{<openSearch:totalResults}
    xmlstring.should =~ %r{<openSearch:itemsPerPage}
    xmlstring.should =~ %r{<openSearch:startIndex}
  end

end

