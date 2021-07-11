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


// モーダル内のページネーション
$('.paginateButton').on('click', function() {
  // 選択したページの情報を検索フォームにセットして送信
  var startNum = $(this).val();
  var page = $(this).text().trim();
  console.log(startNum);
  console.log(page);
  
  $('#current_page').val(page);
  $('#start_num').val((startNum * 10) - 9);
  
  Rails.fire($('#start_num').parent()[0], 'submit');
  
  // モーダル上部にスクロール
  $('html, body, #exampleModalLong').animate({ scrollTop: 0 }, 500);
});
