class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  
  # def comment_build
  #   comment.build
  # end
    
end
