// ハンバーガーメニューを閉じれるよう設定
$(document).on('turbolinks:load', function() {
  $('.navbar-nav > li > a , .dropdown-menu > a').on('click', function(){
          if(this.id != 'navbarDropdown'){
            $('.navbar-collapse').collapse('hide');
            // $('.navbar-toggler').attr('aria-expanded', 'true');
          };
      });
});