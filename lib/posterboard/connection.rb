require 'httparty'
require 'json'

module Posterboard
  class Connection
    include HTTParty
    base_uri 'http://www.posterous.com/api/2'
    # default behavior is to query the API key upon initialization
    def initialize(username, password)
      Connection.basic_auth username, password
      # get the API token
      response = Connection.get('/auth/token')
      Connection.default_params :api_token => response['api_token']
    end
  
    # try to find posts on a site with a name that matches the method name
    # posts are returned as an array of hashes each with a :title and :body
    def method_missing(name)
      site = sites.find { |site| site['name'] == name.to_s }
      # => TODO : Error checking that site is valid and has "id".
      response = Connection.get("/users/me/sites/#{site["id"]}/posts")
      posts = [] 
      ::JSON.parse(response.body).each do |body|  
        post = {}
        post[:title] = body['title']
        post[:body] = body['body_full']
        posts << post
      end
      posts
    end

    private

    def sites
      Connection.get('/users/me/sites')
    end
  end
end
