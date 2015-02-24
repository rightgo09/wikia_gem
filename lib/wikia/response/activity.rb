module Wikia
  module Response
    module Activity
      class ActivityResponseResult
        class ActivityResponseItem
          attr_reader :article, :user, :revision_id, :timestamp
          def initialize(item)
            @article = item["article"]
            @user = item["user"]
            @revision_id = item["revisionId"]
            @timestamp = ::Time.at(item["timestamp"])
          end
        end
        attr_reader :items, :basepath
        def initialize(data)
          @items = data["items"].map{|item| ActivityResponseItem.new(item)}
          @basepath = data["basepath"]
        end
      end
    end
  end
end
