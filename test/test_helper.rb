require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end

require 'minitest/autorun'
require 'minitest/spec'

$LOAD_PATH << File.expand_path('../../lib', __FILE__)
require 'threadlocal'
