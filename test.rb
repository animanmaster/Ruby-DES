require 'cbc.rb'
require 'ebc.rb'
require 'bruteforce.rb'

key = DES_Key.new(0x5B5A57676A56676E)
des = DES.new(key)
cbc = CBC.new(des, 0x0123456789abcdef, "Hello")
ebc = EBC.new(des, "gZig^ZkZ")

#puts Message.to_ascii(cbc.encipher())
cipherText = ebc.encipher
#puts cipherText.pack('B*')
puts ['0','1','1'].pack('B*')

#ebc = EBC.new(des, cipherText)
ebc.data = cipherText
puts ebc.decipher.format(1)
