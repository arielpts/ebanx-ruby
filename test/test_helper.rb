require 'ebanx'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'pry'

class MiniTest::Spec
  def ebanx
    Ebanx.tap do |e|
      # Merchant "Automated Testing"
      e.integration_key = 'f2bb784c3b422874672fe1342a9be8b98134682e1ae4d3a228489c2628e36eaaa256cf3862b419dc4c5d12cd6733468aa4ba'
      e.test_mode       = true
    end
  end
end