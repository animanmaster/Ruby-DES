require 'des.rb'
require 'cbc.rb'

class Message
    def self.to_ascii(binary_str)
        binary_str.gsub(/\s/,'').gsub(/([01]{8})/) { |b| b.to_i(2).chr }
    end

    def self.checkValidity(message)
        message = to_ascii(message)
        counter = 0;
        file = File.new("/home/remococco/code/java/HillCipher/src/hillcipher/bruteforce/dictionaries/english-words.all", "r")
        while (line = file.gets)
            if(message.include? line)
                counter += 1
            end
        end
        file.close
        if(counter >= 10)
            puts message
        end
    end
end

class DESCBCAttack
    attr_accessor :key, :iv, :cipherText
    
    def initialize(cipherText)
        @key = '00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000'.to_bits
        @iv = '00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000'.to_bits
        @cipherText = cipherText
    end

    def attack()
        begin
            des = DES.new(@key)
            begin
                cbc = CBC.new(des, @iv, @cipherText).decipher
                Message.checkValidity(cbc)
                @iv.increment
            end until @iv.exhaustedIncreases()
            @key.increment
        end until @key.exhaustedIncreases()
    end
end

