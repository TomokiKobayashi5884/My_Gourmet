class Post < ApplicationRecord
    belongs_to :restaurant, optional: true
    belongs_to :genre
    belongs_to :user, optional: true
    has_many :comments, dependent: :destroy
    has_many :favorites, dependent: :destroy
    
    validates_associated :restaurant
    
    # バリデーション
    validates :title, length: { maximum: 30 }
    validates :content, length: { maximum: 250 }
    validates :image, presence: { message: "を選択してください" }
    validates :genre_id, presence: true
    validates :ate, inclusion: {in: [true, false]}
    
    #画像をアップロード用にImageUploaderクラスを使えるようにする
    mount_uploader :image, ImageUploader
    
    
    # ユーザーに食べたい物リストに登録されているか
    def favorited_by?(user)
        favorites.where(user_id: user.id).exists?
    end
    
    # 投稿検索用メソッド
    def self.keyword_search(keyword)
            Post.where("title LIKE ?", "%#{keyword}%")
    end
    
end
