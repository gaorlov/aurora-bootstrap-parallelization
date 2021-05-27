$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "zeitwerk"
require 'simplecov'
require 'ruby_dig'

loader = Zeitwerk::Loader.new
loader.log!
loader.push_dir( File.expand_path( "../../lib/", __FILE__) )
loader.setup
loader.eager_load

SimpleCov.start do
  add_filter "/test/"
end

class DummyFile
  def write( *args )
    puts( *args )
  end

  def close; end

end

require "minitest/autorun"
