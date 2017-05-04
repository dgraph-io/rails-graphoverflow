require 'net/http'
require 'uri'
require 'json'

class DgraphClient
  def initialize(baseURL = 'http://127.0.0.1:8080')
    @endpointURI = URI.parse("#{baseURL}/query")
  end

  def do(query)
    res = post_query(query)
    return JSON.parse(res.body, {symbolize_names: true})
  end

  private

  def post_query(query)
    http = Net::HTTP.new(@endpointURI.host, @endpointURI.port)
    request = Net::HTTP::Post.new(@endpointURI.request_uri)
    request.body = query

    http.request(request)
  end
end
