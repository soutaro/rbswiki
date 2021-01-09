require 'rack'
require "rbswiki"

use Rack::ShowExceptions

wiki = RBSWiki::Wiki.new

wiki.update_page("TopPage") do |page|
  page.update(content: <<CONTENT)
Welcome to RBSWiki!

This is a simple wiki page to demostrate RBS programming.

About [RBSwiki]
CONTENT
end
run RBSWiki::Server.new(wiki: wiki)
