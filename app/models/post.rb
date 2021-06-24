class Post < ApplicationRecord
    belongs_to :restaurant, optional: true
    belongs_to :genre
    belongs_to :user, optional: true
   
    
    #画像をアップロード用にImageUploaderクラスを使えるようにする
    mount_uploader :image, ImageUploader
    
    # attr_accessor :genre_code
    
end
