require "date"

module Wikia
  module Response
    module Article
      class OriginalDimension
        attr_reader :width, :height
        def initialize(original_dimension)
          if original_dimension
            @width = original_dimension["width"]
            @height = original_dimension["height"]
          end
        end
      end
      class Revision
        attr_reader :id, :user, :user_id, :timestamp
        def initialize(revision)
          @id = revision["id"]
          @user = revision["user"]
          @user_id = revision["user_id"]
          @timestamp = ::Time.at(revision["timestamp"].to_i)
        end
      end
      class ExpandedArticle
        attr_reader :original_dimensions, :url, :ns, :abstract, :thumbnail, :revision, :id, :title, :type, :comments
        def initialize(item)
          @original_dimensions = OriginalDimension.new(item["original_dimensions"])
          @url = item["url"]
          @ns = item["ns"]
          @abstract = item["abstract"]
          @thumbnail = item["thumbnail"]
          @revision = Revision.new(item["revision"])
          @id = item["id"]
          @title = item["title"]
          @type = item["type"]
          @comments = item["comments"]
        end
      end
      class UnexpandedArticle
        attr_reader :id, :title, :url, :ns
        def initialize(item)
          @id = item["id"]
          @title = item["title"]
          @url = item["url"]
          @ns = item["ns"]
        end
      end

      class ContentResult
        class Section
          class Content
            class Element
              attr_reader :text, :elements
              def initialize(element)
                @text = element["text"]
                @elements = element["elements"]
              end
            end
            attr_reader :type, :text, :elements
            def initialize(content)
              @type = content["type"]
              @text = content["text"]
              @elements = (content["elements"] || []).map{|element| Element.new(element)}
            end
          end
          class Image
            attr_reader :src, :caption
            def initialize(image)
              @src = image["src"]
              @caption = image["caption"]
            end
          end
          attr_reader :title, :level, :content, :images
          def initialize(section)
            @title = section["title"]
            @level = section["level"]
            @content = section["content"].map{|content| Content.new(content)}
            @images = section["images"].map{|image| Image.new(image)}
          end
        end
        attr_reader :sections
        def initialize(data)
          @sections = data["sections"].map{|section| Section.new(section)}
        end
      end
      class ExpandedArticleResultSet
        attr_reader :items, :basepath
        def initialize(data)
          if data["items"].is_a?(Array)
            @items = data["items"].map{|item| ExpandedArticle.new(item)}
          elsif data["items"].is_a?(Hash)
            @items = data["items"].map{|id, item| [id, ExpandedArticle.new(item)]}.to_h
          end
          @basepath = data["basepath"]
        end
      end
      class UnexpandedListArticleResultSet
        attr_reader :items, :offset, :basepath
        def initialize(data)
          @items = data["items"].map{|item| UnexpandedArticle.new(item)}
          @offset = data["offset"]
          @basepath = data["basepath"]
        end
      end
      class ExpandedListArticleResultSet
        attr_reader :items, :offset, :basepath
        def initialize(data)
          @items = data["items"].map{|item| ExpandedArticle.new(item)}
          @offset = data["offset"]
          @basepath = data["basepath"]
        end
      end
      class UnexpandedMostLinkedResultSet
        class UnexpandedMostLinked
          attr_reader :url, :ns, :id, :title, :backlink_cnt
          def initialize(item)
            @url = item["url"]
            @ns = item["ns"]
            @id = item["id"]
            @title = item["title"]
            @backlink_cnt = item["backlink_cnt"]
          end
        end
        attr_reader :items, :basepath
        def initialize(data)
          @items = data["items"].map{|item| UnexpandedMostLinked.new(item)}
          @basepath = data["basepath"]
        end
      end
      class ExpandedMostLinkedResultSet
        class ExpandedMostLinked
          attr_reader :url, :ns, :abstract, :revision, :id, :title, :type, :backlink_cnt, :comments
          def initialize(item)
            @url = item["url"]
            @ns = item["ns"]
            @abstract = item["abstract"]
            @revision = Revision.new(item["revision"])
            @id = item["id"]
            @title = item["title"]
            @type = item["type"]
            @backlink_cnt = item["backlink_cnt"]
            @comments = item["comments"]
          end
        end
        attr_reader :items, :basepath
        def initialize(data)
          @items = data["items"].map{|item| ExpandedMostLinked.new(item)}
          @basepath = data["basepath"]
        end
      end
      class NewArticleResultSet
        class NewArticle
          class Creator
            attr_reader :avatar, :name
            def initialize(creator)
              @avatar = creator["avatar"]
              @name = creator["name"]
            end
          end
          attr_reader :quality, :original_dimensions, :url, :ns, :abstract, :creator, :thumbnail, :creation_date, :id, :title
          def initialize(item)
            @quality = item["quality"]
            @original_dimensions = OriginalDimension.new(item["original_dimensions"])
            @url = item["url"]
            @ns = item["ns"]
            @abstract = item["abstract"]
            @creator = Creator.new(item["creator"])
            @thumbnail = item["thumbnail"]
            @creation_date = ::DateTime._strptime(item["creation_date"], "%Y%m%d%H%M%S")
            @id = item["id"]
            @title = item["title"]
          end
        end
        attr_reader :items, :basepath
        def initialize(data)
          @items = data["items"].map{|item| NewArticle.new(item)}
          @basepath = data["basepath"]
        end
      end
      class PopularListArticleResultSet
        class PopularListArticle
          attr_reader :id, :title, :url
          def initialize(item)
            @id = item["id"]
            @title = item["title"]
            @url = item["url"]
          end
        end
        attr_reader :items, :basepath
        def initialize(data)
          @items = data["items"].map{|item| PopularListArticle.new(item)}
          @basepath = data["basepath"]
        end
      end
      class UnexpandedArticleResultSet
        attr_reader :items, :basepath
        def initialize(data)
          @items = data["items"].map{|item| UnexpandedArticle.new(item)}
          @basepath = data["basepath"]
        end
      end
      class HubArticleResultSet
        class HubArticleResult
          class Wikia
            attr_reader :id, :name, :language, :domain
            def initialize(wiki)
              @id = wiki["id"]
              @name = wiki["name"]
              @language = wiki["language"]
              @domain = wiki["domain"]
            end
          end
          class HubArticle
            attr_reader :id, :ns
            def initialize(article)
              @id = article["id"]
              @ns = article["ns"]
            end
          end
          attr_reader :wiki, :articles
          def initialize(item)
            @wiki = Wikia.new(item["wiki"])
            @articles = item["articles"].map{|article| HubArticle.new(article)}
          end
        end
        attr_reader :items
        def initialize(data)
          @items = data["items"].map{|item| HubArticleResult.new(item)}
        end
      end
    end
  end
end
