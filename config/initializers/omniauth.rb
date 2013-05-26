Rails.application.config.middleware.use OmniAuth::Builder do
  provider :gplus, '675569114873.apps.googleusercontent.com', 'CrPACCX1RROpfVtYkZt50Cxb', scope: 'email,profile'

  if Rails.env.development?
    provider :twitter 'w6tL3GXJJ2K9FEoLe9joWg', 'UNN5XS31U5Hb6jTtP9D2dAHmVWsM7HwhuJmBdZ20w'
  else
    provider :twitter, '8im91zCgJ1jaTQJ9152SYg', 'w9YQ84ELW7SjrtTvSW02qHoPxPHiKxQxIYpLnOpTJ8'
  end
end