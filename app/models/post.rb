class Post < ApplicationRecord
    belongs_to :restaurant, optional: true
    belongs_to :genre
    belongs_to :user, optional: true
    has_many :comments, dependent: :destroy
    has_many :favorites, dependent: :destroy
   
    
    #画像をアップロード用にImageUploaderクラスを使えるようにする
    mount_uploader :image, ImageUploader
    
    # attr_accessor :genre_code
    
    # ユーザーに食べたい物リストに登録されているか
    def favorited_by?(user)
        favorites.where(user_id: user.id).exists?
    end
    
end
