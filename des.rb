require 'additions.rb'

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
        (0...8).each { |i| s << @key[(8*i)...(8*i)+8].to_s << " " }
        return s
    end

    private

    def expandKey
        #K+ is the permuted key using only 56 bits of the original.
        @kplus = @key.permute(@@PC1)
        
        #C_n and D_n form the 16 subkeys to use. 
        c0, d0 = @kplus[0...28], @kplus[28...56]
        cn, dn = [c0], [d0]
        shifts = [1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1]
        shifts.each { |shift|
            cn << cn.last.rotate_left(shift)
            dn << dn.last.rotate_left(shift)
        }

        #generate and store all the subkeys
        @kn = [c0 + d0]

        (1..16).each { |n|
            cndn = cn[n] + dn[n]
            kn =  cndn.permute(@@PC2)
            @kn << kn
        }
    end
    
    def to_bit_array(input)
        bitarr = if input.is_a? Array then input else [] end
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
        perform_des(1.upto(16), plaintext_block)
    end

    def decrypt(ciphertext_block)
        perform_des(16.downto(1), ciphertext_block)
    end


    private

    @@E = [
        32, 1, 2, 3, 4, 5,
        4, 5, 6, 7, 8, 9,
        8, 9, 10, 11, 12, 13,
        12, 13, 14, 15, 16, 17,
        16, 17, 18, 19, 20, 21,
        20, 21, 22, 23, 24, 25,
        24, 25, 26, 27, 28, 29,
        28, 29, 30, 31, 32, 1
    ]

    @@S1 = [
        14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7,
        0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8,
        4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0,
        15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13
    ]

    @@S2 = [
        15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10,
        3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5,
        0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15,
        13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9
    ]

    @@S3 = [
        10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8,
        13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1,
        13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7,
        1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12
    ]

    @@S4 = [
        7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15,
        13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9,
        10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4,
        3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14
    ]

    @@S5 = [
        2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9,
        14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6,
        4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14,
        11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3
    ]

    @@S6 = [
       12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11,
       10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8,
       9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6,
       4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13
    ]
    
    @@S7 = [
        4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1,
        13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6,
        1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
        6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12
    ]

    @@S8 = [
        13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7,
        1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2,
        7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
        2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11
    ]

    @@S_BOXES = [@@S1, @@S2, @@S3, @@S4, @@S5, @@S6, @@S7, @@S8]

    @@P = [
        16, 7, 20, 21,
        29, 12, 28, 17,
        1, 15, 23, 26,
        5, 18, 31, 10,
        2, 8, 24, 14,
        32, 27, 3, 9,
        19, 13, 30, 6,
        22, 11, 4, 25
    ]

    def perform_des(key_order, input_block)
        data = if input_block.is_a? Array then input_block else [] end
        if input_block.is_a? String
            input_block.each_byte { |byte| data += byte.to_bits }
        end

        raise "Expected data length of 64 bits, received #{data.length} bits of data: #{data}" unless data.length == 64
        

        #permute the text using IP
        permuted = data.permute(@@IP)

        l0, r0 = permuted[0...32], permuted[32...64]

        last_l, last_r = l0, r0

        key_order.each { |n|
            ln = last_r
            rn = last_l.xor(f(last_r, @key.kn[n]))
            last_l, last_r  = ln, rn
        }

        (last_r + last_l).permute(@@IP_INVERSE)
    end

    def e(r_block)
        r_block.permute(@@E)
    end

    def f(r_block, key)
        r = e(r_block)
        xored = key.xor(r)

        result = []
        (0...8).each do |i|
            b = xored[i*6...i*6+6]
            result << s(i, b)
        end

        result.flatten!.permute(@@P)
    end

    def s(i, b)
        row = [b.first, b.last].to_s.to_i(2)
        col = b[1...b.length-1].to_s.to_i(2)
        @@S_BOXES[i][row * 16 + col].to_bits.last(4)
    end

end

key = DES_Key.new(0x133457799BBCDFF1)
des = DES.new(key)
puts des.encrypt(0x0123456789ABCDEF.to_bits).to_s.to_i(2).to_s(16)
puts des.decrypt(0x85e813540f0ab405.to_bits).to_s.to_i(2).to_s(16)
#puts DES_Key.new(0x133457799BBCDFF1)
#test = "00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000".to_bits

#key = DES_Key.new(0x5B5A57676A56676E)
#plainText = 0x675A69675E5A6B5A

#des = DES.new(key)
#puts des.encrypt(plainText)

#message = "0100100001100101011011000110110001101111"

#str = "This is a sentence."
#puts str.to_bin
#puts Message.to_ascii(str.to_bin)
#puts String.instance_methods(false)
