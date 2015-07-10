require 'open-uri'

class HomeController < ApplicationController
  BASE_URL = "http://www.green-japan.com"
  def index
    @array_hash_job = []
    @array_hash_company = []

    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    page = agent.get(BASE_URL)
    list_page = page.link_with(text: page.at("#gm_new a").text).click
    @list_job_link = list_page.search(".detail-btn a").map {|link| link["href"]}
    @list_company_link = list_page.search("a[href^='/company/']").map {|link| link["href"]}

    until list_page.at("a.next_page").blank? do
      list_page = list_page.link_with(text: ">").click
      @list_job_link += list_page.search(".detail-btn a").map {|link| link["href"]}
      @list_company_link += list_page.search("a[href^='/company/']").map {|link| link["href"]}
    end

    @list_company_link.each do |link_company|
      @company_detail = []
      company_page = agent.get(BASE_URL + link_company)
      @company_detail += company_page.search(".tb_com_data tr")
      get_company @company_detail
    end

    @list_job_link.each do |link_job|
      @job_detail = []
      job_page = agent.get(BASE_URL + link_job)
      @job_name = job_page.at("#com_title h2").text
      @job_detail += job_page.search(".tb_com_data tr")
      get_job @job_detail, @job_name
    end

    render text: "Finished"
  end

  # def take_all_job agent, list_job_link
  #   @job_detail = []
  #   list_job_link.each do |link_job|
  #     job_page = agent.get(BASE_URL + link_job)
  #     @job_detail += job_page.search(".tb_com_data tr")
  #     get_job @job_detail
  #   end
  # end

  def get_job job_detail, job_name
    @hash_job = Hash.new
    @job_detail = job_detail
    @job_detail.each do |row|
      col_left = row.search("td")[0]
      col_right = row.search("td")[1]
      case col_left.text
        when "職種名"
          @hash_job[:job_type] = col_right.text
        when "勤務地"
          @hash_job[:work_address] = /(【勤務地詳細】)(.*)/.match(col_right.text)[2]
        when "仕事内容"
          @hash_job[:job_info] = col_right.text
        when "応募資格"
          @hash_job[:requirement] = col_right.text
        when "勤務時間"
          @hash_job[:work_time] = col_right.text
        when "想定年収（給与詳細）"
          @hash_job[:salary] = !/(\d+万円(\S+万円)?)/.match(col_right.text).blank? ? /(\d+万円(\S+万円)?)/.match(col_right.text.sub "■", " ")[0] : "TBD"
        when "休日/休暇"
          @hash_job[:holiday] = col_right.text
        when "待遇・福利厚生"
          @hash_job[:treatment] = col_right.text
      end
    end
    @hash_job[:job_name] = job_name
    # JoberWorker.perform_async @hash_job
    # @array_hash_job << @hash_job
    insert_job @hash_job
  end

  def insert_job hash_job
    @job = Job.new hash_job
    @job.save
  end

  # def take_all_company agent, list_company_link
  #   @company_detail = []
  #   list_company_link.each do |link_company|
  #     company_page = agent.get(BASE_URL + link_company)
  #     @company_detail += company_page.search(".tb_com_data tr")
  #     get_company @company_detail
  #   end
  # end

  def get_company company_detail
    @hash_company = Hash.new
    @company_detail = company_detail
    @company_detail.each_with_index do |row, num|
      col_left = row.search("td")[0]
      col_right = row.search("td")[1]
      case col_left.text
        when "会社名"
          @hash_company[:company_name] = col_right.text
        when "本社所在地"
          stringer col_right.text
        # when "業界"
        #   @hash_company[:category] = col_right.text
      end
    end
    # CompanyWorker.perform_async @hash_company
    # @array_hash_company << @hash_company
    insert_company @hash_company
  end

  def stringer col_right
    if col_right.start_with? "〒"
      address = /(^\S*\d\s?)(\S+?[都|道|府|県|市]\s?)(\S+\W\d\d?)\s?(.*)/.match(col_right.gsub "　", " ")
      if address.blank?
        binding.pry
        @hash_company[:address1] = "TBD"
        @hash_company[:address2] = "TBD"
        @hash_company[:address3] = "TBD"
      else
        @hash_company[:postal_code] = address[1]
        @hash_company[:address1] = address[2]
        @hash_company[:address2] = address[3]
        @hash_company[:address3] = address[4]
      end
    else
      if col_right.include? "■"
        spliter = col_right.split "■"
        return stringer spliter[0]
      end
      spliter = col_right.gsub("　", " ").split " "
      case spliter.length
      when 1
        address = /(^\S+?[都|道|府|県]\s?)(\S+?[市|区|町|村])?(\S+\d\W\d+?)\s?(.*)/.match(spliter[0])
        @hash_company[:address1] = address[1]
        @hash_company[:address2] = address[2]
        @hash_company[:address3] = address[3]
      when 2
        city_pre = /(^\S+?[都|道|府|県]\s?)(\S+?[市|区|町|村])?(\S+\d\W\d\d?)/.match(spliter[0])
        @hash_company[:address1] = city_pre[1]
        @hash_company[:address2] = city_pre[2]
        @hash_company[:address3] = spliter[1]
        unless /[市]/.match(city_pre[1]).blank?
          @hash_company[:address1] = nil
          @hash_company[:address2] = city_pre[1] + city_pre[2]
        end
      when 3
        binding.pry
        if /\W+/.match(spliter[2]).blank?
          newtext = spliter[0] + " " + spliter[1] + spliter[2]
          return stringer newtext
        end
        if /[都|道|府|県]/.match(spliter[0]).blank?
          newtext = spliter[0] + spliter[1] + " " + spliter[2]
          return stringer newtext
        end
        newtext = spliter[0] + spliter[1] + " " + spliter[2]
        return stringer newtext
      else
        newtext = spliter[0] + " " + spliter[1] + "_" + spliter[2] + "_" + spliter[3]
        return stringer newtext
      end
    end
  end

  def insert_company hash_company
    @company = Company.new hash_company
    @company.save
  end
end
