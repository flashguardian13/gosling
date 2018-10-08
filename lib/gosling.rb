Dir.glob(File.join(File.dirname(__FILE__), 'gosling/*.rb')).each { |file| require_relative file }

module Gosling
end
