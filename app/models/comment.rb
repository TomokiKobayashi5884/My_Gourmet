class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  
  validates :content, presence: { message: "を入力してください" }, length: { maximum: 150 }
    
end
