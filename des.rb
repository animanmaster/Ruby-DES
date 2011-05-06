class String
    def to_bits
        bitarr = []
        self.each_char { |c| bitarr << c.to_i if c=='0' || c=='1' }
        bitarr
    end

    def to_bin
        bitarr = []
        self.each_byte { |byte| 
            if(byte != 0.to_ba)
                bitarr << byte.to_ba
            end
        }
        helper(bitarr.flatten!.format(8))
    end

    def helper(str) 
        bitarray = []
        str.split(' ').each { |block|
            if(block != '00000000')
                bitarray << block
            end
        }
        bitarray.format(8)
    end
end

class Array
    def rotate_left(amount)
        self[amount, self.length] + self[0, amount]
    end

    def pretty(n = 8)
        (0...self.length / n).each { |i| 
            print self[(n * i) ... (n * i) + n].to_s,  
            " " 
            puts 
        }
    end

    def format(n = 8)
        s=""
        self.each_with_index { |bit, i| s += bit.to_s; s += ' ' if (i + 1) % n == 0 }
        s
    end


    def splitBlocks(size)
        arr = []
        subarr = []
        self.each { |a|
            subarr << a
            if subarr.length == size
                arr << subarr
                subarr = []
            end
        }
        arr
    end 
    
    def xor(b)
        i = 0
        self.map { |a|
            i += 1
            a ^ b[i - 1]
        }
    end
                  
    def increment()
        (0 .. self.size - 1).each do |i|
            if(self[i] == 0)
                self[i] = 1
                break
            else
                self[i] = 0
            end
        end
    end

    def exhaustedIncreases()
        (0 ... self.size).each do |i|
            if(self[i] == 0)
                False
            end
        end
        True
    end
end

class DES_Key
    #Create an accessor for the key, but not a mutator.
    attr_accessor :key, :kplus, :kn

    @@PC1 = [
        57, 49, 41, 33, 25, 17, 9,
        1, 58, 50, 42, 34, 26, 18,
        10, 2, 59, 51, 43, 35, 27,
        19, 11, 3, 60, 52, 44, 36,
        63, 55, 47, 39, 31, 23, 15,
        7, 62, 54, 46, 38, 30, 22,
        14, 6, 61, 53, 45, 37, 29,
        21, 13, 5, 28, 20, 12, 4
    ]

    @@PC2 = [
        14, 17, 11, 24, 1, 5,
        3, 28, 15, 6, 21, 10,
        23, 19, 12, 4, 26, 8,
        16, 7, 27, 20, 13, 2,
        41, 52, 31, 37, 47, 55,
        30, 40, 51, 45, 33, 48,
        44, 49, 39, 56, 34, 53,
        46, 42, 50, 36, 29, 32
    ]

    def initialize(key)
        if(key.is_a? Array)
            @key = key
        else
            @key = to_bit_array(key)
        end
        expandKey
    end

    def inspect
        to_s
    end

    def to_s
        s = ""
        (0...8).each { |i|
            s << @key[(8*i)...(8*i)+8].to_s << " "
        }
        return s
    end

    private

    def expandKey
        #K+ is the permuted key using only 56 bits of the original.
        @kplus = []
        @@PC1.map { |bit| 
            @kplus << @key[bit - 1]
        }
        
        #C_n and D_n form the 16 subkeys to use. 
        c0, d0 = @kplus[0...28], @kplus[28..56]
        cn, dn = [c0], [d0]
        puts "c0 = #{c0}, d0 = #{d0}"
        shifts = [1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1]
        i = 1
        shifts.each { |shift|
            cn << cn.last.rotate_left(shift)
            dn << dn.last.rotate_left(shift)
            puts "c#{i} = #{cn.last}, d#{i} = #{dn.last}"
            i+=1
        }

        #generate and store all the subkeys
        @kn = []

        (1..16).each { |n|
            cndn = cn[n] + dn[n]
            kn = [] 
            @@PC2.map { |bit|
                kn << cndn[bit - 1]
            }
            @kn << kn
            print "k#{n} = "
            kn.pretty(6)
        }
    end
    
    def to_bit_array(input)
        bitarr = []
        if input.is_a? String
            raise "Key must be a hex string of 8 bytes (16 characters)." unless input.length.eql?(16)
            bitarr = to_bit_array(input.to_i(16))
        elsif input.is_a? Integer
            bitarr = Array.new(input.size * 8) { |i| input[i] }.reverse
        end
        return bitarr
    end

end

class CBC
    attr_accessor :des, :iv, :data

    def initialize(des, iv, data)
        @des = des
        if(iv.instance_of? Array)
            @iv = iv
        else
            @iv = iv.to_bits
        end
        @data = data
        raise "IV must be 8 bytes." unless @iv.size == 64
        self.add_pad(64)
    
        puts @des.key.format(8)
        puts @iv.format(8)
        puts @data.format(8)
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
        blocks.size.do { |block|
            bce = l.xor(block)
            cipherText << (l = @des.encrypt(bce))
        }
        cipherText.pretty(8)
    end

    def decipher()
        blocks = @data.splitBlocks(64)
        plainText = []
        l = @iv
        blocks.size.do { |block|
            bcd = @des.decrypt(block)
            plainText << (l.xor(bcd))
            l = block
        }
        plainText.pretty(8)
    end
end

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

class Block
    attr_accessor :bits

end

class DES
    #Create an accessor for the key, but not a mutator.
    attr_accessor :key

    @@IP = [
            58,	50,	42,	34,	26,	18,	10,	2,
            60,	52,	44,	36,	28,	20,	12,	4,
            62,	54,	46,	38,	30,	22,	14,	6,
            64,	56,	48,	40,	32,	24,	16,	8,
            57,	49,	41,	33,	25,	17,	 9,	1,
            59,	51,	43,	35,	27,	19,	11,	3,
            61,	53,	45,	37,	29,	21,	13,	5,
            63,	55,	47,	39,	31,	23,	15,	7
    ]

    @@IP_INVERSE = [
            40,	8,	48,	16,	56,	24,	64,	32,
            39,	7,	47,	15,	55,	23,	63,	31,
            38,	6,	46,	14,	54,	22,	62,	30,
            37,	5,	45,	13,	53,	21,	61,	29,
            36,	4,	44,	12,	52,	20,	60,	28,
            35,	3,	43,	11,	51,	19,	59,	27,
            34,	2,	42,	10,	50,	18,	58,	26,
            33,	1,	41,	9,	49,	17,	57,	25
    ]

    public
    #The following are public methods
    
    def initialize(key)
        raise "IllegalArgumentException: expecting an instance of the DES_Key class." unless key.instance_of? DES_Key
        @key = key
    end

    def encrypt(plaintext_block)
        if plaintext_block.is_a? String
            plaintext_block = plaintext_block.hex
        end

        plaintext_block.is_a? Integer
            

    end

    def decrypt(ciphertext_block)

    end

    protected

    def get_blocks(str)
        raise "Cannot break up anything but a String." unless str.is_a?(String)
        size = str.bytesize / 8
        padding = str.bytesize % 8
        size += 1 unless padding == 0

        blocks = Array.new(size)
#        str.each_byte { |byte|
            
#        }

    end

    private
    #The following are private methods
    

    def to_byte_array(num) 
        result = [] 
        begin 
            result << (num & 0xff) 
            num >>= 8 
        end until (num == 0 || num == -1) && (result.last[7] == num[7]) 
        result.reverse 
    end
    
end

class Integer
    def to_ba
        Array.new(self.size * 8) { |i| self[i] }.reverse
    end

    def print_bits
        print to_ba
        puts
    end
end

#puts DES_Key.new(0x133457799BBCDFF1)
test = "00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000".to_bits

message = "0100100001100101011011000110110001101111"

str = "This is a sentence."

puts str.to_bin

puts Message.to_ascii(str.to_bin)
#puts String.instance_methods(false)
