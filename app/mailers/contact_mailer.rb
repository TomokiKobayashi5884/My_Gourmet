class ContactMailer < ApplicationMailer
    
    def send_mail(contact)
        @contact = contact
        # 送信先のメールアドレス
        mail to: ENV["TOMAIL"],
        subject: "【お問い合わせ】" + @contact.subject
    end
end
