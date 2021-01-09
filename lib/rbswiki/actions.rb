module RBSWiki
  module Actions
    class Base
      attr_reader :env
      attr_reader :wiki
      attr_accessor :status_code
      attr_reader :headers
      attr_reader :content

      def initialize(env:, wiki:)
        @env = env
        @wiki = wiki
        @status_code = 200
        @headers = { "CONTENT_TYPE" => "text/html" }
        @content = StringIO.new
      end

      def path
        env["PATH_INFO"].delete_prefix("/")
      end

      def method
        env["REQUEST_METHOD"]
      end

      def page_name
        if path.empty?
          "TopPage"
        else
          path.delete_suffix("/_edit")
        end
      end

      def run()

      end
    end

    module FormHelper
      def edit_form(url:, content:)
        <<-FORM
<form action="#{url}" method="post">
  <textarea name="content" rows="40" style="width: 100%;">#{content}</textarea><br>
  <input type="submit" value="Save">
</form>
        FORM
      end
    end

    class EditPageAction < Base
      def run
        page = wiki.find_page(page_name) or raise "Unknown page: #{page_name}"

        content.print(<<-CONTENT)
<html>
<head>
  <title>RBSWiki: #{page_name}</title>
</head>
<body>
  <h1>Edit Page: #{page_name}</h1>
  #{edit_form(url: "/#{page_name}", content: page.content)}
</body>
</html>
        CONTENT
      end
    end

    class NewPageAction < Base
      def run
        content.print(<<-CONTENT)
<html>
<head>
  <title>RBSWiki: #{page_name}</title>
</head>
<body>
  <h1>New Page: #{page_name}</h1>
  #{edit_form(content: "", url: path)}
</body>
</html>
        CONTENT
      end
    end

    class ShowPageAction < Base
      def run
        content.print(<<-CONTENT)
<html>
<head>
  <title>RBSWiki: #{page_name}</title>
</head>
<body>
  <h1>#{page_name}</h1>
  <a href="#{page_name}/_edit">Edit</a>
  <hr>
  <div style="white-space: pre-wrap;">#{render_page}</div>
</body>
</html>
        CONTENT
      end

      def render_page
        page = wiki.find_page(page_name) or raise

        page.content.gsub(/\[(\w+)\]/) do |pattern|
          "<a href='/#{$1}'>#{$1}</a>"
        end
      end
    end

    class UpdatePageAction < Base
      def run
        body = Hash[URI.decode_www_form(post_body)]

        wiki.update_page(page_name) {|page| page.update(content: body["content"]) }

        self.status_code = 303
        self.headers["Location"] = path
      end

      def post_body
        env["rack.input"].read
      end
    end
  end
end
