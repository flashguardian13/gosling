%w(actor circle collision image_library polygon rect sprite text_renderer transform).each do |filename|
  require_relative "gosling/#{filename}.rb"
end

module Gosling
end
