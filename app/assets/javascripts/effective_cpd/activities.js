// When we click the New Activity button, use the whole screen
$(document).on('click', '[data-cpd-new-activity]', function(event) {
  event.preventDefault()
  event.stopPropagation()

  let $activities = $(event.currentTarget).closest('#cpd-statement-activities')

  $activities.children('.activities-index').hide()
  $activities.children('.activities-new').show()
});

$(document).on('click', '.activities-new', function(event) { event.stopPropagation() });

let collapse_effective_cpd_activities = function() {
  let $activities = $('#cpd-statement-activities')

  $activities.children('.activities-new').hide()
  $activities.children('.activities-index').show()

  // $('.activity-new').hide()
  // $('.activities-index').first()
  //   .find('tr.expanded').removeClass('expanded')
  //   .end()
  //   .find('tr.activity-details').hide()
  //   .end()
  // .show()
};

$(document).on('turbolinks:load', function() {
  if($('#cpd-statement-activities').length > 0) {
    $(document).on('click', function() { collapse_effective_cpd_activities() })
  }
});

$(document).ready(function() {
  if($('#cpd-statement-activities').length > 0) {
    $(document).on('click', function(event) { collapse_effective_cpd_activities() })
  }
});
