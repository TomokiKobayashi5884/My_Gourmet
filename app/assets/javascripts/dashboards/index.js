$('#_date_1i, #_date_2i').on('change', () => {
    console.log('-------------index');
    $('.month-form').submit();
    // Rails.fire($('#_month_1i').parent()[0], 'submit');
});