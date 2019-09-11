require 'minitest/autorun'
#require '~/sonic-pi/app/server/ruby/lib/sonicpi/lang/sound.rb'
require "~/ziffers/ziffers.rb"

describe Ziffers do

describe 'Figure out how to include Sonic pi methods' do
  it 'is impossible to' do
    getNoteFromDgr(1,:c,:major).must_equal 60
  end
end

end
