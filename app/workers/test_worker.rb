require 'httparty'
require 'json'

class TestWorker
  include Sidekiq::Worker

  def execute
    response = HTTParty.get('https://openlibrary.org/api/books?bibkeys=ISBN:0385472579&format=json&jscmd=data')
    [200, JSON.parse(response.body)]
  end
end