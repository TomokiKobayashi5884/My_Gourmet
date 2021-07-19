module DisplayList
    
    # 1ページあたりの表示件数
    PER = 15
    
    def display_list(page)
        page(page).per(PER)
    end
end
