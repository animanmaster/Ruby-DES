require 'des.rb'

class CBC
    attr_accessor :des, :iv, :data

    def initialize(des, iv, data)
        @des = des
        if(iv.instance_of? Array)
            @iv = iv
        else
            @iv = iv.to_bits
        end
        @data = data.to_bin
        raise "IV must be 8 bytes." unless @iv.size == 64
        self.add_pad(64)
    end

    def add_pad(multiple = 64)
        @data = @data.to_bits unless @data.instance_of? Array
        while(@data.size % multiple != 0)
            @data << '0'
        end
    end

    def encipher()
        blocks = @data.splitBlocks(64)
        cipherText = []
        l = @iv
        blocks.each do |block|
            bce = l.xor(block)
            cipherText << (l = @des.encrypt(bce))
        end
        cipherText.format(1)
    end

    def decipher()
        blocks = @data.splitBlocks(64)
        plainText = []
        l = @iv
        blocks.each do |block|
            bcd = @des.decrypt(block)
            plainText << (l.xor(bcd))
            l = block
        end
        plainText.pretty(8)
    end
end
