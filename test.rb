require 'cbc.rb'
require 'ebc.rb'
require 'bruteforce.rb'

key = DES_Key.new(0x5B5A57676A56676E)
des = DES.new(key)
ebc = EBC.new(des, "This is EBC encryption and decryption test!")
cbc = CBC.new(des, 0x0123456789abcdef, "This is CBC encryption and decryption test!")

puts "This is EBC encryption and decryption test!"
cipherText = ebc.encipher
ebc.data = cipherText
puts "Encrypted:"
puts Message.to_ascii(cipherText.format(1))
puts "Decrypted:"
puts Message.to_ascii(ebc.decipher.format(1))

puts

puts "This is CBC encryption and decryption test!"
cipherText = cbc.encipher
cbc.data = cipherText
puts "Encrypted:"
puts Message.to_ascii(cipherText.format(1))
puts "Decrypted:"
puts Message.to_ascii(cbc.decipher.format(1))

desebc = DESEBCAttack.new(cipherText)
desebc.attack
