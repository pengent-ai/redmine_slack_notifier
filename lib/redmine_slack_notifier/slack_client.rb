# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module RedmineSlackNotifier
  class SlackClient
    def post(webhook_url, payload)
      uri = URI.parse(webhook_url)

      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      req.body = JSON.generate(payload)

      Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == "https")) do |http|
        http.request(req)
      end
    end
  end
end
