module Wikia
  module Response
    module Recommendation
      class RecommendationsResultSet
        class RecommendationItem
          class Media
            attr_reader :duration, :original_width, :thumb_url, :video_key, :original_height
            def initialize(media)
              @duration = media["duration"]
              @original_width = media["originalWidth"]
              @thumb_url = media["thumbUrl"]
              @video_key = media["videoKey"]
              @original_height = media["originalHeight"]
            end
          end
          attr_reader :source, :url, :description, :media, :title, :type
          def initialize(item)
            @source = item["source"]
            @url = item["url"]
            @description = item["description"]
            @media = Media.new(item["media"])
            @title = item["title"]
            @type = item["type"]
          end
        end
        attr_reader :items
        def initialize(data)
          @items = data["items"].map{|item| RecommendationItem.new(item)}
        end
      end
    end
  end
end
