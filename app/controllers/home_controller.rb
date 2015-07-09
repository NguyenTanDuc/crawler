require 'open-uri'

class HomeController < ApplicationController
  DEFAULT_URI = "http://www.green-japan.com"
  def index
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    page = agent.get(DEFAULT_URI)
    list_page = page.link_with(text: page.search("#gm_new a").text).click
    # @list_titles = list_page.search(".detail-head h2").collect(&:text)
    @list_link = list_page.search(".detail-btn a").map {|link| link["href"]}
    binding.pry
    until list_page.search("a.next_page").blank? do
      list_page = list_page.link_with(text:list_page.search("a.next_page").text).click
      @list_link += list_page.search(".detail-btn a").map {|link| link["href"]}.compact.uniq
    end

    @list_titles = []
    @list_link.each do |link|
      puts link
      new_page = agent.get(DEFAULT_URI + link)
      @list_titles += new_page.search("#com_title h2").collect(&:text)
    end
    binding.pry
    @list_titles.compact.uniq
    binding.pry
  end

  def take_link
  end

  def take_uri

  end

  def take_title

  end

end
