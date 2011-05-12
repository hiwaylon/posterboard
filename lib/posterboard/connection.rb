require 'httparty'
require 'json'
require 'logger'

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

      @logger = ::Logger.new(STDOUT)
      @logger.level = ::Logger::DEBUG
      @logger.debug("Created logger")
    end
  
    # try to find posts on a site with a name that matches the method name
    # posts are returned as an array of hashes each with a :title and :body
    def method_missing(name)
      @logger.debug "Looking for site (#{name})."
      site = sites.find do |site| 
        @logger.debug "Found (#{site["name"]})."
        site['name'] == name.to_s
      end
      raise SiteNotFoundError unless site
      raise MissingSiteIDError, "Is the Posterous service broken?" unless site.key? "id"
      response = Connection.get("/users/me/sites/#{site["id"]}/posts")
      posts = []
      ::JSON.parse(response.body).each do |body|  
        # => TODO: BlankSlate and define these as methods on post, i.e. post.title, or use OpenStruct
        post = OpenStruct.new
        post.title = body['title']
        post.body = body['body_full']
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
