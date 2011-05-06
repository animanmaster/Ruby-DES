require 'cbc.rb'
key = DES_Key.new(0x0123456789abcdef)
des = DES.new(key)
cbc = CBC.new(des, 0x0123456789abcdef, "Now is the time for all .")


puts cbc.encipher()

