class User < ApplicationRecord
  has_many :posts, dependent: :destroy

  # create accessible attributes for virtual columns
  attr_accessor :remember_token, :activation_token, :reset_token

  before_save   :downcase_email             # callback, like a trigger
  before_create :create_activation_digest

  validates :name, presence: true, length: {maximum: 50}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  # the allow_nil is for updates; has_secure_password catches nil passwords
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  has_secure_password

  # return the digest of the given string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ?
                       BCrypt::Engine::MIN_COST :
                            BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # create a remember token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token    # set the remember_token attribute
    update_attribute(:remember_digest, User.digest(remember_token))  # update the User record with the hash
  end

  def forget
    update_attribute(:remember_digest, nil)   # update the user record with a nil remember digest
  end

  # return true if the given token matches the given digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # sets the activation flag and timestamp
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # send the activation email request to the users email address
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # defines a post feed
  def feed
    Post.where("user_id = ?", id)
  end

  private

    def downcase_email
      self.email = email.downcase
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
