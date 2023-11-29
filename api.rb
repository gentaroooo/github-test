require 'net/http'
require 'json'
require 'uri'

# Personal Access Token と リポジトリ情報を設定
token = 'YOUR_PERSONAL_ACCESS_TOKEN'
repo_owner = 'REPO_OWNER'
repo_name = 'REPO_NAME'

# GitHubのプルリクエストリストを取得するためのAPIエンドポイント
# pr_uri = URI("https://api.github.com/repos/#{repo_owner}/#{repo_name}/pulls?state=open")
pr_uri = URI("https://api.github.com/repos/#{repo_name}/pulls?state=open")

# レビュー情報を取得するための関数
def fetch_reviews(uri, token)
  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "token #{token}"
    response = http.request(request)
    JSON.parse(response.body)
  end
end

Net::HTTP.start(pr_uri.host, pr_uri.port, use_ssl: true) do |http|
  request = Net::HTTP::Get.new(pr_uri)
  request['Authorization'] = "token #{token}"
  response = http.request(request)
  pull_requests = JSON.parse(response.body)

  pull_requests.each do |pr|
    reviews_uri = URI(pr['url'] + '/reviews')
    reviews = fetch_reviews(reviews_uri, token)
    approved_reviews = reviews.select { |review| review['state'] == 'APPROVED' }

    approved_reviews.each do |review|
      puts "PR Number: #{pr['number']}, Review ID: #{review['id']}, Approved at: #{review['submitted_at']}"
    end
  end
end
