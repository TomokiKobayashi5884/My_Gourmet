// 画像プレビュー
function handleImage(image) {
    let reader = new FileReader();
    reader.onload = function() {
        let imagePreview = document.getElementById("post-image-preview");
        imagePreview.src = reader.result;
        imagePreview.className += "img-fluid";
    };
    reader.readAsDataURL(image[0]);
}


// 画像アップロード後、エラー発生した場合、画像アップロードのrequired属性を外す
$(window).on('load', function() {
    if ($('#post-image-preview').hasClass('img')) {
        $('#post_image').removeAttr('required');
    }
});


// 都道府県選択後に関連エリアをプルダウンに表示(newとedit用)
$(document).on('change', '#post_restaurant_large_area_code', function() {
  return $.ajax({
    type: 'GET',
    url: '/posts/middle_area_select_for_ne',
    data: {
      large_area_code: $(this).val()
    }
  }).done(function(data) {
    return $('.middle_area').html(data);
  });
});


// 都道府県選択後に関連エリアをプルダウンに表示(ホットペッパーで検索の部分用)
$(document).on('change', '#large_area_selected', function() {
  return $.ajax({
    type: 'GET',
    url: '/posts/middle_area_select',
    data: {
      large_area_code: $(this).val()
    }
  }).done(function(data) {
    return $('.middle_area_select').html(data);
  });
});


// モーダル内のページネーション（ホットペッパー検索部分）
$('.paginateButton').on('click', function() {
  // 選択したページの情報を検索フォームにセットして送信
  var startNum = $(this).val();
  var page = $(this).text().trim();
  console.log(startNum);
  console.log(page);
  
  $('#current_page').val(page);
  $('#start_num').val( ( startNum * 10 ) - 9 );
  
  Rails.fire($('#start_num').parent()[0], 'submit');
  
  // モーダル上部にスクロール
  var scroll = $('#scroll').offset().top;
  var all_scroll = $(window).scrollTop();
  console.log(all_scroll);
  console.log(scroll);
  // $('html, body, #exampleModalLong').scrollTop(500);
  $('html, body, #exampleModalLong').animate({ scrollTop: 0 }, 500);
});

// 検索条件を変更し、検索ボタンを押した場合は1ページ目に戻る
$('#keyword, #large_area_selected, #restaurant_middle_area_code, #genre_selected').on('change', function() {
  $('#search_hotpepper').on('click', function() {
    $('#current_page').val('1');
    $('#start_num').val('1');
  });
});