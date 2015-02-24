module Wikia
  module Response
    module RelatedPage
      class RelatedPages
        class RelatedPage
          class ImgOriginalDimension
            attr_reader :width, :height
            def initialize(img_original_dimensions)
              if img_original_dimensions
                @width = img_original_dimensions["width"]
                @height = img_original_dimensions["height"]
              end
            end
          end
          attr_reader :url, :title, :id, :img_url, :img_original_dimensions, :text
          def initialize(related_page)
            @url = related_page["url"]
            @title = related_page["title"]
            @id = related_page["id"]
            @img_original_dimensions = ImgOriginalDimension.new(related_page["img_original_dimensions"])
            @text = related_page["text"]
          end
        end
        attr_reader :items, :basepath
        def initialize(data)
          @items = data["items"].map{|id, items| [id, items.map{|item| RelatedPage.new(item)}]}.to_h
          @basepath = data["basepath"]
        end
      end
    end
  end
end
