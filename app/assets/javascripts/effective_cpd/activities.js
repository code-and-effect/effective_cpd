// When we click the New Activity button, use the whole screen
$(document).on('click', '[data-cpd-new-activity]', function(event) {
  event.preventDefault()
  event.stopPropagation()

  console.log("NEW ACTIVITY")

  let $statement = $('#cpd-statement-activities')
  $statement.children('.activities-index').hide()
  $statement.children('.activities-new').show()
});

// Collapse the New Activity and all Edit Activity forms
let collapse_effective_cpd_activities = function() {
  console.log("COLLAPSE")

  let $statement = $('#cpd-statement-activities')
  $statement.children('.activities-new').hide()

  let $activities = $statement.children('.activities-index')
  $activities.show()
  $activities.find('.statement-activity-content').show()
  $activities.find('.statement-activity-form').hide()
};

// When we click the Edit Activity
$(document).on('click', '[data-cpd-edit-activity]', function(event) {
  console.log("EDIT ACTIVITY")

  event.preventDefault()

  collapse_effective_cpd_activities()

  let $activity = $(event.currentTarget).closest('.statement-activity')
  $activity.children('.statement-activity-content').hide()
  $activity.children('.statement-activity-form').show()
});

// When we click outside the New Activity or Edit Activity
$(document).on('click', '#cpd-statement-activities .activities-new', function(event) { event.stopPropagation() });
$(document).on('click', '#cpd-statement-activities .statement-activity', function(event) { event.stopPropagation() });

$(document).ready(function() {
  if($('#cpd-statement-activities').length > 0) {
    $(document).on('click', function(event) { collapse_effective_cpd_activities() })
  }
});
