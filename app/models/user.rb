class User < ApplicationRecord
  has_many :posts
  has_many :comments
  has_many :favorites, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable
  
  extend DisplayList
  extend SwitchFlg
  
  validates :name, uniqueness: true, length: { maximum: 10 }, presence: true
  VALID_EMAIL_REGEX = /\A[\w+-.]+@[a-z\d-]+(.[a-z\d-]+)*.[a-z]+\z/i
  validates :email, uniqueness: true, presence: true, format: { with: VALID_EMAIL_REGEX }, length: { maximum: 70 }
  VALID_PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?\d)[a-z\d]+\z/i
  validates :password, presence: true, format: { with: VALID_PASSWORD_REGEX, message: "は半角英数字を両方使用してください" }, length: { minimum: 8 }, on: :create
  validates :password, presence: true, format: { with: VALID_PASSWORD_REGEX, message: "は半角英数字を両方使用してください" }, length: { minimum: 8 }, allow_blank: true, on: :update
  validates :agreement_terms, acceptance: true, on: :create
  validates :agreement_privacy, acceptance: true, on: :create
  
  def update_password(params, *options)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    result = update(params, *options)
    clean_up_passwords
    result
  end
  
  scope :search_by_keyword, -> (keyword) {
        where("id LIKE ? OR name LIKE ? OR email LIKE ?", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%") if keyword.present?
  }
end
