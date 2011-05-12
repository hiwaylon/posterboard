require 'spec_helper'

describe Posterboard::Connection do
  before do
    username = 'user'
    password = 'pass'
    stub_request(:get, "http://#{username}:#{password}@www.posterous.com/api/2/auth/token")
    stub_request(:get, "http://#{username}:#{password}@www.posterous.com/api/2/auth/token?api_token=")
    stub_request(:get, "http://#{username}:#{password}@www.posterous.com/api/2/users/me/sites?api_token=").
      to_return(:status => 200, 
                :body => [{"id" => "1234", "name" => "your_site_name"}, {"id" => "5678", "name" => "another_site_name"}])
    stub_request(:get, "http://#{username}:#{password}@www.posterous.com/api/2/users/me/sites/1234/posts?api_token=").
      to_return(:status => 200, 
                :body => [{:title => "ad litora", :body_full => "lorem ipsum"}, {:title => "sociosqu torquent", :body_full => "dolor set"}].to_json)
    @connection = Posterboard::Connection.new(username, password)
  end
  
  context "when accessing sites by name" do
    it "should find a site by name" do
      @connection.your_site_name.should_not be_nil
    end
  end
  
  context "when accessing posts" do
    it "should provide post enumeration" do
      @connection.your_site_name.each do |post|
        post.should_not be_nil
      end
    end

    it "should should give access to the posts' data" do
      @connection.your_site_name.each do |post|
        post.title.should_not be_nil
        post.body.should_not be_nil
      end
    end
  end

  context "when something goes wrong" do
    it "should raise an error when requesting a site that does not exist" do
      stub_request(:get, "http://user:pass@www.posterous.com/api/2/users/me/sites?api_token=").
        to_return(:status => 200, 
                  :body => [{"id" => "5432", "name" => "this_one"}, {"id" => "9876", "name" => "that_one"}])
      
      lambda {@connection.but_not_this}.should raise_error(Posterboard::SiteNotFoundError)
    end

    it "should raise an error when the API returns a site without an id" do
      stub_request(:get, "http://user:pass@www.posterous.com/api/2/users/me/sites?api_token=").
        to_return(:status => 200, 
                  :body => [{"id" => "99", "name" => "a_good_one"}, {"name" => "bad_site", "pointless" => "parameter"}])
      
      lambda {@connection.bad_site}.should raise_error(Posterboard::MissingSiteIDError)
    end
  end

end

