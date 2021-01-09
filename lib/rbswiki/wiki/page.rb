module RBSWiki
  class Wiki
    class Page
      attr_reader :name, :content

      def initialize(name:, content:, new_page:)
        @name = name
        @content = content
        @new_page = new_page
      end

      def new?
        @new_page
      end

      def self.empty(name:)
        new(name: name, content: "", new_page: true)
      end

      def self.load(name:, content:)
        new(name: name, content: content, new_page: false)
      end

      def update(content:)
        self.class.new(name: name, content: content, new_page: new?)
      end
    end
  end
end
