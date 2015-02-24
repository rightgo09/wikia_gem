require "httparty"
require "oj"
require "wikia/response/activity"
require "wikia/response/article"
require "wikia/response/navigation"
require "wikia/response/recommendation"
require "wikia/response/related_page"

module Wikia
  class Client
    class Config
      attr_reader :domain, :debug
      def initialize(domain:, debug:)
        @domain = domain
        @debug = debug
      end
    end

    def initialize(domain: "www", debug: false)
      @config = Config.new(domain: domain, debug: debug)
    end

    def activity
      @activity ||= V1::Activity.new(@config)
    end

    def articles
      @articles ||= V1::Articles.new(@config)
    end

    def navigation
      @navigation ||= V1::Navigation.new(@config)
    end

    def recommendations
      @recommendations ||= V1::Recommendations.new(@config)
    end

    def related_pages
      @related_pages ||= V1::RelatedPages.new(@config)
    end

    class HttpNotSuccessException < Exception; end

    module V1
      V = "/v1"

      class Base
        def initialize(config)
          @domain = config.domain
          @debug = config.debug
        end

        API_URI_BASE = "http://%s.wikia.com/api"

        def build_uri(path)
          (API_URI_BASE % @domain) + V + path
        end

        def http_get(path, query = {})
          http_request(:get, path, query)
        end

        def http_request(method, path, query)
          uri = build_uri(path)
          $stderr.puts "#{method.to_s.upcase} #{uri} #{query}" if @debug

          start_time = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
          response = HTTParty.send(method, uri, query: query)
          end_time = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
          response_time = (end_time - start_time) / 1000.0

          if @debug
            $stderr.puts "======= response"
            $stderr.puts "time: #{response_time} sec."
            $stderr.puts "code: #{response.code}"
            $stderr.puts "body: #{response.body}"
            $stderr.puts "================"
          end

          if response.code != 200
            raise HttpNotSuccessException, "Response code: #{response.code}, body: #{response.body}"
          end

          response
        end
      end

      class Activity < Base
        URI_PATH = {
          latest_activity: "/Activity/LatestActivity",
          recently_changed_articles: "/Activity/RecentlyChangedArticles",
        }

        def latest_activity(query = {})
          response = http_get(URI_PATH[:latest_activity], query)
          Response::Activity::ActivityResponseResult.new(Oj.load(response.body))
        end

        def recently_changed_articles(query = {})
          response = http_get(URI_PATH[:recently_changed_articles], query)
          Response::Activity::ActivityResponseResult.new(Oj.load(response.body))
        end
      end

      class Articles < Base
        URI_PATH = {
          as_simple_json: "/Articles/AsSimpleJson",
          details: "/Articles/Details",
          list: "/Articles/List",
          most_linked: "/Articles/MostLinked",
          new: "/Articles/New",
          popular: "/Articles/Popular",
          top: "/Articles/Top",
          top_by_hub: "/Articles/TopByHub",
        }

        def as_simple_json(query = {})
          response = http_get(URI_PATH[:as_simple_json], query)
          Response::Article::ContentResult.new(Oj.load(response.body))
        end

        def details(query = {})
          response = http_get(URI_PATH[:details], query)
          Response::Article::ExpandedArticleResultSet.new(Oj.load(response.body))
        end

        def list(query = {})
          response = http_get(URI_PATH[:list], query)
          data = Oj.load(response.body)
          if query.has_key?(:expand) && query[:expand] == 1
            Response::Article::ExpandedListArticleResultSet.new(data)
          else
            Response::Article::UnexpandedListArticleResultSet.new(data)
          end
        end

        def most_linked(query = {})
          response = http_get(URI_PATH[:most_linked], query)
          data = Oj.load(response.body)
          if query.has_key?(:expand) && query[:expand] == 1
            Response::Article::ExpandedMostLinkedResultSet.new(data)
          else
            Response::Article::UnexpandedMostLinkedResultSet.new(data)
          end
        end

        def new(query = {})
          response = http_get(URI_PATH[:new], query)
          Response::Article::NewArticleResultSet.new(Oj.load(response.body))
        end

        def popular(query = {})
          response = http_get(URI_PATH[:popular], query)
          data = Oj.load(response.body)
          if query.has_key?(:expand) && query[:expand] == 1
            Response::Article::ExpandedArticleResultSet.new(data)
          else
            Response::Article::PopularListArticleResultSet.new(data)
          end
        end

        def top(query = {})
          response = http_get(URI_PATH[:top], query)
          data = Oj.load(response.body)
          if query.has_key?(:expand) && query[:expand] == 1
            Response::Article::ExpandedArticleResultSet.new(data)
          else
            Response::Article::UnexpandedArticleResultSet.new(data)
          end
        end

        def top_by_hub(query = {})
          response = http_get(URI_PATH[:top_by_hub], query)
          Response::Article::HubArticleResultSet.new(Oj.load(response.body))
        end
      end

      class Navigation < Base
        URI_PATH = {
          data: "/Navigation/Data",
        }

        def data(query = {})
          response = http_get(URI_PATH[:data], query)
          Response::Navigation::NavigationResultSet.new(Oj.load(response.body))
        end
      end

      class Recommendations < Base
        URI_PATH = {
          for_article: "/Recommendations/ForArticle",
        }

        def for_article(query = {})
          response = http_get(URI_PATH[:for_article], query)
          Response::Recommendation::RecommendationsResultSet.new(Oj.load(response.body))
        end
      end

      class RelatedPages < Base
        URI_PATH = {
          list: "/RelatedPages/List",
        }

        def list(query = {})
          response = http_get(URI_PATH[:list], query)
          Response::RelatedPage::RelatedPages.new(Oj.load(response.body))
        end
      end
    end
  end
end
