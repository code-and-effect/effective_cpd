// In the New Activity Form
$(document).on('click', '[data-cpd-show-activity]', function(event) {
  event.preventDefault()

  let $obj = $(event.currentTarget)
  let $form = $obj.siblings('.statement-activity-form')
  let $tabContent = $obj.closest('.tab-content').children('.statement-activity-content')

  $tabContent.html($form.html())
  $tabContent.siblings('.active').removeClass('active')
  $tabContent.addClass('active')
});

$(document).on('click', '[data-cpd-back-activity]', function(event) {
  event.preventDefault()

  let $activities = $(event.currentTarget).closest('.activities-new')
  let anchor = $activities.find('.nav[role=tablist]').find('a.nav-link.active').first().attr('href')

  $(anchor).siblings('.active').removeClass('active').end().addClass('active')
});

$(document).on('effective-form:success', '.cpd-statement-activity-form', function() {
  if(window.Turbolinks) {
    Turbolinks.visit(window.location.toString(), {action: 'replace'})
  } else {
    window.location.reload()
  }
});
