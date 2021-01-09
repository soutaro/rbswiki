module RBSWiki
  class Server
    attr_reader :wiki

    def initialize(wiki:)
      @wiki = wiki
    end

    def call(env)
      # @type var path: String
      path = env["PATH_INFO"].delete_prefix("/")
      # @type var method: String
      method = env["REQUEST_METHOD"]

      # @type var action: Actions::Base?
      action = nil

      case
      when path.end_with?("/_edit") && method == "GET"
        action = Actions::EditPageAction.new(env: env, wiki: wiki)
      when method == "POST"
        action = Actions::UpdatePageAction.new(env: env, wiki: wiki)
      when method == "GET"
        page_name = path.empty? ? "TopPage" : path
        if wiki.has_page?(page_name)
          action = Actions::ShowPageAction.new(env: env, wiki: wiki)
        else
          action = Actions::NewPageAction.new(env: env, wiki: wiki)
        end
      end

      if action
        action.run()
        [action.status_code, action.headers, [action.content.string]]
      else
        [404, { "CONTENT_TYPE" => "text/html" }, ["No route found"]]
      end
    end
  end
end
