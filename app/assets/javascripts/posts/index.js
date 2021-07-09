
$(document).on('change', '#large_area_id', function() {
  return $.ajax({
    type: 'GET',
    url: '/posts/middle_area_select',
    data: {
      large_area_id: $(this).val()
    }
  }).done(function(data) {
    return $('.middle_area').html(data);
  });
});


// $('hot').on('click', () => {
//   location.href = 'https://898b191edb39450eba693d81ee597dc9.vfs.cloud9.ap-northeast-1.amazonaws.com/posts/new' + '?hot=hot'
// })