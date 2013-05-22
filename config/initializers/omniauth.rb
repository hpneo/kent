Rails.application.config.middleware.use OmniAuth::Builder do
  provider :gplus, '675569114873.apps.googleusercontent.com', 'CrPACCX1RROpfVtYkZt50Cxb', scope: 'email,profile'
end