xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do

  xml.channel do
    xml.title PAGE_TITLE
    xml.link  HOMEPAGE
    xml.description "Talks Schedule for #{PAGE_TITLE}"


    @rooms.each do |room|
      room.talks.by_day.by_time.each do |talk|
        xml.item do
          xml.day         "#{talk.day.strftime("%A %m/%d")}"
          xml.title       "#{room.name} - #{talk_time(talk)} - #{talk.name}"
          xml.description talk.description
          xml.pubDate     talk.updated_at.to_s(:rfc822)
          xml.link        nil
        end
      end
    end

    @sponsors.each do |sponsor|
      xml.item do
        xml.title       sponsor.name
        xml.description sponsor.name
        xml.pubDate     sponsor.updated_at.to_s(:rfc822)
        xml.link        sponsor.homepage
      end
    end

  end
end
