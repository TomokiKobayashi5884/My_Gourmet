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
