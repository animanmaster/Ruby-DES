
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
            a.to_i ^ b[i - 1].to_i
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

    def permute(table)
        permuted = []
        table.map { |index| permuted << self[index-1] }
        return permuted
    end
end



class Integer
    def to_bits
        Array.new(self.size * 8) { |i| self[i] }.reverse
    end

    def print_bits
        print to_ba
        puts
    end
    
    def to_ba
        Array.new(self.size * 8) { |i| self[i] }.reverse
    end
end

class String
    def to_bits
        bitarr = []
        self.each_char { |c| bitarr << c.to_i if c=='0' || c=='1' }
        bitarr
    end

    def to_bin
        bitarr = []
        self.each_byte { |byte| 
            bitarr << byte.to_ba
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

