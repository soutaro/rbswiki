module RBSWiki
  class Wiki
    def initialize
      @content = {}
    end

    def has_page?(name)
      @content.key?(name)
    end

    def find_page(name)
      if content = @content[name]
        Page.load(name: name, content: content)
      end
    end

    def update_page(name)
      page = find_page(name) || Page.empty(name: name)
      @content[name] = yield(page).content
    end

    def each_page(&block)
      if block
        @content.each do |name, content|
          yield Page.load(name: name, content: content)
        end
      else
        enum_for :each_page
      end
    end
  end
end
