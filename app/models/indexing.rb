require 'open-uri'
require 'nokogiri'
require 'json'

class Indexing < ActiveRecord::Base

    PREFERED_TAGS = ["h1", "h2", "h3", "a"]

    def self.fetch_page(url)
        noko = Nokogiri::HTML(open(url))
        return noko
    end

    def self.get_tags(content, tag)
       content.xpath("//#{tag}")
    end

    def self.extract_text(tag)
        tag.text.strip.gsub(/\n/, " ")
    end

    def self.get_link(tag)
       tag[:href]
    end

    def self.extract_text_all(tags)
        tags.map do |t| 
            if not t[:href].nil?
                get_link(t)
            else 
                extract_text(t)
            end
        end.select {|t| not (t.empty? or t.nil?)}.uniq
    end

    def self.process_tag(content, tag)
        tags = get_tags(content, tag)
        return extract_text_all(tags)
    end

    def self.process_prefered(url)
        begin
            content = fetch_page(url)
            final = {}
            PREFERED_TAGS.map do |t|
                l = process_tag(content, t)
                final[t] = l
            end
            return {status: 200, msg: final}
        rescue Exception => e
            return {status: 404, msg: "error fetching page."}
        end
    end
    
    def self.save_to_redis(url, h)
        begin
            h.each do |k, v|
                $redis.hmset(url, k, v.to_json)
            end
            return {status: 201, msg: "successfully saved."}
        rescue Exception => e
            return {status: 500, msg: "error saving results."}
        end
    end
    
    def self.query(url)
        begin
            res = $redis.hgetall(url)
            puts res.inspect
            status = (res.nil? or res.empty?) ? 404 : 200
            res = res.map {|k, v| {k => JSON.parse(v)}}.reduce({}, :merge)
            if res.empty?
                res = "not found."
            end
            return {status: status, msg: res}
        rescue Exception => e
            return {status: 500, msg: "something wrong."}
        end
    end

end

