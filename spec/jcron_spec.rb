require 'jcron'

describe Jcron do
  it "md5 returns an md5 checksum of the argument" do
    Jcron::md5('abcd').should == 'e2fc714c4727ee9395f324cd2e7f331f'
  end
  
  it "short_isotime returns iso8601 time without seconds" do
    time = Time.utc(2012,1,1,12,15)
    Jcron::short_isotime(time).should == '2012-01-01T12:15Z'
  end
  
end