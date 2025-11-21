require "net/http"
require "uri"
require "json"

class GeminiClient
  # ✅ モデル＆バージョンを 2.0 + v1beta に変更
  GEMINI_API_ENDPOINT =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

  def initialize(api_key: ENV["GEMINI_API_KEY"])
    @api_key = api_key
    raise "GEMINI_API_KEY is not set" if @api_key.blank?
  end

  def generate_text(prompt)
    uri = URI.parse("#{GEMINI_API_ENDPOINT}?key=#{@api_key}")

    headers = { "Content-Type" => "application/json" }

    body = {
      contents: [
        {
          parts: [
            { text: prompt }
          ]
        }
      ]
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise "Gemini API error: #{response.code} #{response.body}"
    end

    json = JSON.parse(response.body)
    json.dig("candidates", 0, "content", "parts", 0, "text")
  end
end