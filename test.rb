require 'cbc.rb'
require 'bruteforce.rb'

key = DES_Key.new(0x0123456789abcdef)
des = DES.new(key)
cbc = CBC.new(des, 0x0123456789abcdef, "Now is the time for all .")

#puts Message.to_ascii(cbc.encipher())
puts cbc.encipher()
