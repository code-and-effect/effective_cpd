const initialize_effective_cpd_activities = function() {
  const $obj = $('.cpd-statement-activities:not(.initialized)')

  if($obj.length > 0) {
    $(document).on('mousedown touchstart', function(event) { collapse_effective_cpd_activities() })

    // When we click outside the New Activity or Edit Activity
    $(document).on('mousedown touchstart', '.activities-new', function(event) { event.stopPropagation() });
    $(document).on('mousedown touchstart', '.statement-activity', function(event) { event.stopPropagation() });

    $obj.addClass('initialized')
  }
};

// Collapse the New Activity and all Edit Activity forms
const collapse_effective_cpd_activities = function() {
  const $activities = $('#cpd-statement-activities')
  $activities.children('.activities-new').hide()
  $activities.children('.activities-index').show()

  const $statementActivities = $('.cpd-statement-activities')
  $statementActivities.find('.statement-activity-content').show()
  $statementActivities.find('.statement-activity-form').hide()
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

// Initializers
$(document).ready(function() { initialize_effective_cpd_activities() });
$(document).on('turbolinks:load', function() { initialize_effective_cpd_activities() });
