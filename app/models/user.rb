class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :authentication_token
  attr_accessible :first_name, :last_name
  attr_accessible :provider, :uid

  has_many :feeds
  has_many :posts, through: :feeds

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def import_feeds(subscriptions)
    existing_feeds = self.feeds.to_a
    subscriptions.each do |subscription|
      if existing_feeds.none? { |f| f.url == subscription['xmlUrl'] }
        self.feeds.create({
          title: subscription['title'],
          description: subscription['text'],
          format: subscription['type'],
          url: subscription['xmlUrl'],
          home_url: subscription['htmlUrl']
        })
      end
    end

    self.feeds
  end

  def self.find_duplicated_from_omniauth(omniauth_hash)
    email = omniauth_hash[:info][:email]
    provider = omniauth_hash[:provider]
    uid = omniauth_hash[:uid] || omniauth_hash[:extra][:raw_info][:id]

    (email && provider && uid) && where(email: email).where('provider != ? AND uid != ?', provider, uid).count > 0
  end

  def self.from_omniauth(omniauth_hash)
    email = omniauth_hash[:info][:email] || "kent-#{Time.zone.now.to_i}@kent.herokuapp.com"
    provider = omniauth_hash[:provider]
    uid = omniauth_hash[:uid] || omniauth_hash[:extra][:raw_info][:id]

    user = where(provider: provider, uid: uid).limit(1).first

    if user.nil?
      user = User.new
      user.email = email
      user.password = Time.zone.now.to_i.to_s
      user.password_confirmation = user.password
      user.provider = provider
      user.uid = uid
      user.first_name = omniauth_hash[:info][:first_name]
      user.last_name = omniauth_hash[:info][:last_name]

      user.save
    end

    user
  end
end
