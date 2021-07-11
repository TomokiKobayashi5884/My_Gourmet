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
