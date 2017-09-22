module ZBase32

  ALPHABET = 'ybndrfg8ejkmcpqxot1uwisza345h769'.split('').freeze

  def self.encode32(bin_string)
    bin_string.scan(/[01]{1,5}/).map do |bits|
      ALPHABET[bits.ljust(5, '0').to_i(2)]
    end.join
  end

  def self.decode32(enc)
    bin = enc.split('').map do |char|
      ALPHABET.index(char).to_s(2).rjust(5, '0')
    end.join
    bin[0, (8 * (bin.length / 8))]
     # .sub /10*$/ ,'1'
  end

end
