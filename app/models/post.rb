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
    validates :ate, inclusion: { in: [ true, false ] }
    
    #画像をアップロード用にImageUploaderクラスを使えるようにする
    mount_uploader :image, ImageUploader
    
     extend DisplayList
    
    # ユーザーに食べたい物リストに登録されているか
    def favorited_by?(user)
        favorites.where(user_id: user.id).exists?
    end
    
    # キーワードで投稿検索する用
    scope :search_by_keyword, -> (keyword) {
        where("title LIKE ? OR content LIKE ?", "%#{keyword}%", "%#{keyword}%") if keyword.present?
    }
    
    scope :search_by_large_area, -> (restaurant_id) {
        where(restaurant_id: restaurant_id) if restaurant_id.present?
    }
    
    scope :search_by_middle_area, -> (restaurant_id) {
        where(restaurant_id: restaurant_id) if restaurant_id.present?
    }
    
    scope :search_by_genre, -> (genre_id) {
        where(genre_id: genre_id.strip) if genre_id.present?
    }
    
    
    # 投稿検索（admin）用
    scope :search_by_user, -> (user_info) {
        where("user_id LIKE ?", "%#{user_info}%") if user_info.present?
    }
    
    scope :search_by_restaurant, -> (restaurant_id) {
        where(restaurant_id: restaurant_id) if restaurant_id.present?
    }
end
