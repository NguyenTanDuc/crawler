require 'open-uri'

class HomeController < ApplicationController
  def index
    agent = Mechanize.new
    page = agent.get("http://vnexpress.net/")
    @list_news = page.search("ul.list_news li")
    @list_title = []
    @list_description = []
    @list_news.each do |anews|
      @list_title << anews.search(".title_news a")
      @list_description << anews.search(".news_lead")
    end
    binding.pry
  end
end
