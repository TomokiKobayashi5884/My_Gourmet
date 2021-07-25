class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  
  validates :content, presence: { message: "を入力してください" }, length: { maximum: 150 }
  
  extend DisplayList
  
  scope :search_by_keyword, -> (keyword) {
        where("id LIKE ? OR content LIKE ?", "%#{keyword}%", "%#{keyword}%") if keyword.present?
  }
  
  scope :search_by_user, -> (user_id) {
        where(user_id: user_id) if user_id.present?
  }
  
  scope :search_by_post, -> (post_id) {
        where(post_id: post_id) if post_id.present?
  }
    
end
