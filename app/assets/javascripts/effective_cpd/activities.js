$(document).on('click', '[data-cpd-show-activity]', function(event) {
  event.preventDefault();

  var $obj = $(event.currentTarget);
  var $form = $obj.siblings('.statement-activity-form');
  var $tabContent = $obj.closest('.tab-content').children('.statement-activity-content');

  $tabContent.html($form.html());
  $tabContent.siblings('.active').removeClass('active');
  $tabContent.addClass('active');
});

$(document).on('effective-form:success', '.cpd-statement-activity-form', function() {
  if(window.Turbolinks) {
    Turbolinks.visit(window.location.toString(), {action: 'replace'});
  } else {
    window.location.reload();
  }
});
