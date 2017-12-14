# This simple script is used to decrypt a ciphertext that has been encrypted
# using a general hybrid encryption strategy with RSA and AES standards.
# For more information, check the poc-rsa-aes-encryption repository.

require "openssl"
require "base64"

MODEL_PATH = "model.txt"
RSA_SK_PATH = "private.pem"

file_content = []
File.open MODEL_PATH, "r" do |file|
  file.each_line { |line| file_content << line }
end

aes_key_base_64 = file_content[0]
aes_iv_base_64 = file_content[1]
content_base_64 = file_content[2]

rsa_private_key = OpenSSL::PKey::RSA.new File.read RSA_SK_PATH

rsa_encrypted_aes_key = Base64.decode64 aes_key_base_64
raw_aes_iv = Base64.decode64 aes_iv_base_64
aes_encrypted_content = Base64.decode64 content_base_64

aes_key = rsa_private_key.private_decrypt rsa_encrypted_aes_key

decipher = OpenSSL::Cipher::AES.new 128, :CBC
decipher.decrypt
decipher.key = aes_key
decipher.iv = raw_aes_iv

decrypted_content = decipher.update aes_encrypted_content
decrypted_content << decipher.final
puts decrypted_content
