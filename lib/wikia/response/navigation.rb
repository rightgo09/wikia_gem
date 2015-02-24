module Wikia
  module Response
    module Navigation
      class NavigationResultSet
        class NavigationItem
          class WikiaItem
            class ChildrenItem
              attr_reader :text, :href
              def initialize(children)
                @text = children["text"]
                @href = children["href"]
              end
            end
            attr_reader :text, :href, :children
            def initialize(wikia)
              @text = wikia["text"]
              @href = wikia["href"]
              @children = wikia["children"].map{|children| ChildrenItem.new(children)}
            end
          end
          attr_reader :wikia, :wiki
          def initialize(navigation)
            @wikia = navigation["wikia"].map{|wikia| WikiaItem.new(wikia)}
            @wiki = navigation["wiki"].map{|wiki| WikiaItem.new(wiki)}
          end
        end
        attr_reader :navigation
        def initialize(data)
          @navigation = NavigationItem.new(data["navigation"])
        end
      end
    end
  end
end
