require 'open-uri'

class HomeController < ApplicationController
  def index
    agent = Mechanize.new
    page = agent.get("http://vnexpress.net")
    @list_news = page.search("ul.list_news li")
    @title = @list_news.search(".title_news a.txt_link").collect(&:text)
    @description = @list_news.search(".news_lead").collect(&:text)
    @links = @list_news.search("a.txt_link").map {|link| link['href']}
    @images = @list_news.search(".thumb img").map {|src| src['src']}
    # page2 = page.link_with(text: @title[0]).click
  end
end
