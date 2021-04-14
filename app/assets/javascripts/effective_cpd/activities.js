const initialize_effective_cpd_activities = function() {
  const $obj = $('#cpd-statement-activities:not(.initialized)')

  if($obj.length > 0) {
    $(document).on('mousedown touchstart', function(event) { collapse_effective_cpd_activities() })
    $obj.addClass('initialized')
  }
};

// Collapse the New Activity and all Edit Activity forms
const collapse_effective_cpd_activities = function() {
  const $statement = $('#cpd-statement-activities')
  $statement.children('.activities-new').hide()

  const $activities = $statement.children('.activities-index')
  $activities.show()
  $activities.find('.statement-activity-content').show()
  $activities.find('.statement-activity-form').hide()
};

// When we click the New Activity button, use the whole screen
$(document).on('click', '[data-cpd-new-activity]', function(event) {
  event.preventDefault()
  event.stopPropagation()

  const $statement = $('#cpd-statement-activities')
  $statement.children('.activities-index').hide()
  $statement.children('.activities-new').show()
});

// When we click the Edit Activity
$(document).on('click', '[data-cpd-edit-activity]', function(event) {
  event.preventDefault()

  collapse_effective_cpd_activities()

  const $activity = $(event.currentTarget).closest('.statement-activity')
  $activity.children('.statement-activity-content').hide()
  $activity.children('.statement-activity-form').show()
});

// When we click outside the New Activity or Edit Activity
$(document).on('mousedown touchstart', '#cpd-statement-activities .activities-new', function(event) { event.stopPropagation() });
$(document).on('mousedown touchstart', '#cpd-statement-activities .statement-activity', function(event) { event.stopPropagation() });

// Initializers
$(document).ready(function() { initialize_effective_cpd_activities() });
$(document).on('turbolinks:load', function() { initialize_effective_cpd_activities() });
