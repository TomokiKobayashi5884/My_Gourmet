// 利用規約とプライバシーポリシーのチェックボックス両方をチェックすると新規会員登録ボタンを押せるように
$('#user_agreement_terms, #user_agreement_privacy').on('change', () => {
    if ( $('#user_agreement_terms').prop('checked') && $('#user_agreement_privacy').prop('checked') ) {
        $('.registration-btn').prop('disabled', false);
    }else {
        $('.registration-btn').prop('disabled', true);
    };
});

// 利用規約とプライバシーポリシーのリンクを押したときは対応するモーダルの内容に書き換える
$('#terms_of_servise').on('click', () => {
    console.log('-----------click');
    $('#agreementModalLabel').text('利用規約');
    $('.terms_of_servise_text').show();
    $('.privacy_policy_text').hide();
    $('#agreement').modal();
});
$('#privacy_policy').on('click', () => {
    console.log('-----------privacy_policy');
    $('#agreementModalLabel').text('プライバシーポリシー');
    $('.privacy_policy_text').show();
    $('.terms_of_servise_text').hide();
    $('#agreement').modal();
});

// モーダル閉じるボタン
$('#close').on('click', () => {
    $("#agreement").modal("hide");
    $('body').removeClass('modal-open');　　　　　
    $('.modal-backdrop').remove();
});