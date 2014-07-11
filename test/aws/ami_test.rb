require_relative '../test_helper'

class AMITest < Minitest::Test
  def test_creates_ec2_instance
    Elbas::AMI.create do |ami|
      p ami
    end
  end
end