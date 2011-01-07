require File.dirname(__FILE__) + '/spec_helper.rb'

describe Atom::Entry, "extended with Atom Threading" do

  it "should handle thread information collectly" do

    target = Atom::ReplyTarget.new
    target.id  = 'tag:example.org,2007:04:example'
    target.href = 'http://example.com/reply'
    target.type = 'text/xhtml'
    target.id.should  == 'tag:example.org,2007:04:example'
    target.href.should == 'http://example.com/reply'
    target.type.should == 'text/xhtml'

    entry = Atom::Entry.new
    entry.in_reply_to target

    xmlstring = entry.to_s
    xmlstring.should =~ %r{<thr:in-reply-to}
    xmlstring.should =~ %r{href='http://example.com/reply'}
    xmlstring.should =~ %r{type='text/xhtml'}
    xmlstring.should =~ %r{ref='tag:example.org,2007:04:example'}

    now = Time.now
    l = Atom::RepliesLink.new
    l.href = 'http://example.org/entry/1'
    l.count = 10
    l.updated = now

    entry.add_link l

    entry.alternate_link = 'http://example.org/alternate/entry/1'

    replies_link = entry.links.select{ |l| l.rel == 'replies' }.first
    replies_link.class.should == Atom::RepliesLink
    replies_link.href.should == 'http://example.org/entry/1'
    replies_link.count.should == 10

    alternate_link = entry.links.select{ |l| l.rel == 'alternate' }.first
    alternate_link.class.should_not == Atom::RepliesLink
    alternate_link.class.should == Atom::Link
    alternate_link.href.should == 'http://example.org/alternate/entry/1'
    
  end

end

