# Be sure to restart your server when you modify this file.

#Exalted::Application.config.session_store :cookie_store, :key => '_exalted_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
Exalted::Application.config.session_store :active_record_store, :key => '_exalted_session', :secret =>'45917a7541897610ad913121e070f9662a0ac3d0a7301d27de7495143021af18d4698d03ac05b3b2b5d039f94c2f9096e605eed39ac7758f32e58c9f30e9e2db'
 
