class DES_Key
    
end

class CBC
    attr_accessor :des, :iv, :data

    def initialize(des, iv, data)
        @des = des;
        @iv = iv;
        @data = data;
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
        #@key = to_bit_array(key);
    end

    def encrypt(plaintext)
        blocks = get_blocks(plaintext);
    end

    def decrypt(ciphertext)

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
    
    def to_bit_array(num)
        if input.is_a?(String)
            raise "Key must contain bytes." unless input.bytesize.eql?(8)
        elsif input.is_a?(Array)
            raise "Key must be exactly 64 bits." unless input.size.eql?(64)

        Array.new(num.size * 8) { |i| num[i] }.reverse
        end
    end

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

#Experimenting with Ruby:
#GOOD STUFF!

puts 1[0];
puts 1[-1];

1.print_bits
65532.print_bits
7.print_bits

num = 10000000000000
num.print_bits
puts 7[0]
puts 7[-1]

puts 0xFF.size
puts "a".force_encoding("us-ascii").bytes.to_a

