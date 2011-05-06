require 'des.rb'

class EBC
    attr_writer :des, :data

    def initialize(des, data)
        @des = des
        if data.instance_of? String
            @data = data.to_bin
            self.add_pad(64)
        else
            @data = data
        end
    end

    def add_pad(multiple = 64)
        @data = @data.to_bits unless @data.instance_of? Array
        while(@data.size % multiple != 0)
            @data << 0
        end
    end

    def encipher()
        blocks = @data.splitBlocks(64)
        cipherText = []
        blocks.each do |block|
            cipherText << @des.encrypt(block)
        end
        cipherText
    end

    def decipher()
        @data = @data[0]
        blocks = @data.splitBlocks(64)
        plainText = []
        blocks.each do |block|
            plainText << @des.decrypt(block)
        end
        plainText
    end
end
