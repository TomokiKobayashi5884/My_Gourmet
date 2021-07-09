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



// 都道府県選択後に市区町村を表示
// $(document).on("change", "#middle_area_select", function() {
//   return $.ajax({
//     type: "GET",
//     url: "/posts/middle_area_serect",
//     data: {
//       large_area_id: $(this).val()
//     }
//   }).done(function(data) {
//     return $('#middle_area_select').html(data);
//   });
// });


$(document).on('turbolinks:load', function() {
 $(document).on('change', '#large_area_selected', function() {
  let large_areaVal = $('#large_area_selected').val();
  if (large_areaVal !== "") {
  let selectedTemplate = $(`#middle-area-of-large-area${large_areaVal}`);
  $('#large_area_selected').after(selectedTemplate.html());
  };
 });
});


$(document).on('turbolinks:load', function() {
 //HTMLが読み込まれた時の処理
 let large_areaVal = $('#large_area_selected').val();
 //一度目に検索した内容がセレクトボックスに残っている時用のif文
 if (large_areaVal !== "") {
  let selectedTemplate = $(`#middle-area-of-large-area${large_areaVal}`);
  $('#middle_area').remove();
  $('#large_area_selected').after(selectedTemplate.html());
 };

 //先ほどビューファイルに追加したもともとある子要素用のセレクトボックスのHTML
 let defaultMiddleAreaSelect = `<select name="middle_area" id="middle_area">
<option value>市区町村を選択してください</option>
</select>`;

 $(document).on('change', '#large_area_selected', function() {
  let large_areaVal = $('#large_area_selected').val();
  //親要素のセレクトボックスが変更されてvalueに値が入った場合の処理
  if (large_areaVal !== "") {
   let selectedTemplate = $(`#middle-area-of-large-area${large_areaVal}`);
   //デフォルトで入っていた子要素のセレクトボックスを削除
   $('#middle_area').remove();
   $('#large_area_selected').after(selectedTemplate.html());
  }else {
   //親要素のセレクトボックスが変更されてvalueに値が入っていない場合（include_blankの部分を選択している場合）
   $('#middle_area').remove();
   $('#large_area_selected').after(defaultMiddleAreaSelect);
  };
 });
});