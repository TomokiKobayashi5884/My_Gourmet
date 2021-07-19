module ApplicationHelper
    
    def resource_is_user?
        request.fullpath == "/login"
    end
end
