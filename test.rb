require 'cbc.rb'
require 'bruteforce.rb'

key = DES_Key.new(0x0123456789abcdef)
des = DES.new(key)
cbc = CBC.new(des, 0x0123456789abcdef, "Hello")

#puts Message.to_ascii(cbc.encipher())
cipherText = cbc.encipher
puts cipherText

cbc = CBC.new(des, 0x0123456789abcdef, cipherText)

puts cbc.decipher
