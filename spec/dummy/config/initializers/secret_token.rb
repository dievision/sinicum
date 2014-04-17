# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
if Rails.version.to_i < 4
  Dummy::Application.config.secret_token = '41ced020ad6b064ae1bd7c28a628aae9a4b18a245e11ca95e476b34fb836a7d8fd5b698e1e8d8784c354e914d06ee0ee6a7a76119cdd8f921209742de085ee20'
else
  Dummy::Application.config.secret_key_base = 'f3d51c0a9e3ecf0b6770c27c7e0725c4c50e61258f3385312131f06b473075533e77d16bfe88e1047a71fd1c5854c936171bd3594d85ef98cd9b22aef4362fe4'
end
