let switchEditUserInfo = (textClass, inputClass, labelClass) => {
        if ( $(textClass).css('display') == 'block' ) {
            $(labelClass).text("キャンセル");
            $(textClass).collapse('hide');
            $(inputClass).collapse('show');
        }
        else {
            $(labelClass).text("編集");
            $(textClass).collapse('show');
            $(inputClass).collapse('hide');
        };
    };
    

// 会員情報更新時にエラーがあった場合、エラーメッセージと入力フォームを表示
$(window).on('load', function() {
    if ($('#user_name').hasClass('is-invalid')) {
        $('.userNameEditLabel').trigger('click');
        $('.userNameEditLabel').remove();
    }
});

$(window).on('load', function() {
    if ($('#user_email').hasClass('is-invalid')) {
        $('.userEmailEditLabel').trigger('click');
        $('.userEmailEditLabel').remove();
    }
});