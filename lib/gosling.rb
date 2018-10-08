%w(actor circle collision image_library polygon rect sprite transform inheritance_error initialization_error).each do |filename|
  require_relative "gosling/#{filename}.rb"
end

module Gosling
end
