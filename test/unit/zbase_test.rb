$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'minitest/autorun'
require 'zbase32'

class Zbase32Test < Minitest::Test
  def test_samples
    samples.each do |k, v|
      assert_equal k, decode(v)
      assert_equal v, encode(k)
    end
  end

  protected

  def samples
    {
      '111100001011111111000111' => '6n9hq',
      '110101000111101000000100' => '4t7ye',
      wkd_sample => 'iy9q119eutrkn8s1mk4r39qejnbu3n5q'
    }
  end

  def wkd_sample
    'a83ee94be89c48a11ed25ab44cfdc848833c8b6e'.to_i(16).to_s(2)
  end

  def encode(string)
    ZBase32.encode32 string
  end

  def decode(enc)
    ZBase32.decode32 enc
  end
end
