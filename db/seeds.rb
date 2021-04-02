puts "Running effective_cpd seeds"

now = Time.zone.now

# if Rails.env.test?
#   Effective::CpdCycle.delete_all
#   Effective::CpdCategory.delete_all
#   Effective::CpdActivity.delete_all
#   Effective::CpdRule.delete_all
# end

# Build the first CpdCycle
cycle = Effective::CpdCycle.create!(
  title: "#{now.year} Continuing Professional Development",
  start_at: now.beginning_of_year,
  end_at: now.end_of_year,
  required_score: 100,
  all_steps_content: "<div>All Steps Content</div>",
  start_content: "<div>Start Content</div>",
  activities_content: "<div>Activities Content</div>",
  submit_content: "<div>Submit Content</div>",
  complete_content: "<div>Complete Content</div>"
)

# Professional Practice
category = Effective::CpdCategory.create!(
  title: 'Professional Practice',
  body: "A registrant who is actively practicing applied biology (performing technical work) or influencing (having some effect on how the professional is practiced) the practice of applied biology. <em>Note: Points claimed in this category cannot also be claimed under the Management category</em>",
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: category,
  credit_description: 'Upto a maximum of 20 claimable points per CPD year. Points cannot be carried forward to future years.',
  max_credits_per_cycle: 20
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Practicing applied biology',
  amount_label: 'points',
)

Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 0
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Influencing the practice of applied biology',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 0
)

# Management
category = Effective::CpdCategory.create!(
  title: 'Management',
  body: "The management, evaluation, direction/supervision of professionals; and the management, evaluation and direction/management of projects or activities being carried out by professionals <em>Note: Points claimed in this category cannot also be claimed under the Professional Practice category.</em>",
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: category,
  credit_description: 'Upto a maximum of 20 claimable points per CPD year. Points cannot be carried forward to future years.',
  max_credits_per_cycle: 20
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Assessment and evaluation of professionals who are conducting applied biology',
  body: "e.g. determining who is best for the particular work.",
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 0
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Overseeing projects or activities',
  body: "e.g. reviewing professional documents being carried out by professionals.",
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 0
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Establishing financial (cost assessments) and time limits for projects, and scope of projects',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 0
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Other',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 0
)

# Formal Learning
category = Effective::CpdCategory.create!(
  title: 'Formal Learning',
  body: "Learning that has academic or technical credit, and may include assignments or examinations to evaluate learning that assists a registrant in practicing due diligence with regards to clients and their professional requirements; and to maintain, enhance or to develop practice competence in areas of practice.",
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: category,
  credit_description: 'Upto a maximum of 35 claimable points per CPD year. Points may be carried over upto a maximum of 2 years after the year in which they were earned.',
  max_credits_per_cycle: 35
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'From post-secondary education institutes, suppliers, employers, government or professional associations',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Online, in classroom settings, a combination, or other methods',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 2
)

# Informal Learning
category = Effective::CpdCategory.create!(
  title: 'Informal Learning',
  body: "Learning that has academic or technical credit, and may include assignments or examinations to evaluate learning that assists a registrant in practicing due diligence with regards to clients and their professional requirements; and to maintain, enhance or to develop practice competence in areas of practice.",
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: category,
  credit_description: 'Upto a maximum of 15 claimable points per CPD year. Points may be carried over upto a maximum of 2 years after the year in which they were earned.',
  max_credits_per_cycle: 15
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Self-directed studies',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Attendance at conferences, seminars, workshops, technical presentations, clinics',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Formalized and structured on the job training',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Attendance at meetings of technical, professional or managerial associations or societies',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Structured discussion of technical or professional issues with peers',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 2
)

# Presentations
category = Effective::CpdCategory.create!(
  title: 'Presentations',
  body: "<div>Lecture/talk/speech that is of a technical and/or professional nature that are outside the normal daily job function(s)</div>",
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: category,
  credit_description: 'Upto a maximum of 15 claimable points per CPD year. Points may be carried over upto a maximum of 2 years after the year in which they were earned.',
  max_credits_per_cycle: 15
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Conference, symposium, workshop, seminar meeting, course, training session, lunch presentations',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Post-secondary education institutes, employers, government, professional associations, public organizations',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Other',
  amount_label: 'points',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_cycles_can_carry_forward: 2
)

# Contributions to Knowledge
category = Effective::CpdCategory.create!(
  title: 'Contributions to Knowledge',
  body: "Activities which expand or develop new biological and/or technical/scientific knowledge in the biological profession are recognized that are outside the normal daily job function(s).",
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: category,
  credit_description: 'Upto a maximum of 30 claimable points per CPD year. Points may be carried over upto a maximum of 2 years after the year in which they were earned.',
  max_credits_per_cycle: 30
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Development of published standards, practices, codes',
  amount_label: 'standard, practice, code',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: '10 * amount',
  credit_description: '1 publication equals 10 CPD points',
  max_credits_per_cycle: 10,
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Development of published policy(ies), reference(s), guidelines(s), guidance(s)',
  amount_label: 'standard, practice, guideline',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: '10 * amount',
  credit_description: '1 publication equals 10 CPD points',
  max_credits_per_cycle: 10,
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Publication of papers in scientific peer-reviewed journals',
  amount_label: 'hour',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 hour equals 1 CPD point',
  max_credits_per_cycle: 15,
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Publication of articles in non-peer-reviewed journals',
  amount_label: 'article',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: '5 * amount',
  credit_description: '1 article equals 5 CPD point',
  max_credits_per_cycle: 10,
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Publication of a books, a book chapter',
  amount_label: 'book or book chapter',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: '10 * amount',
  credit_description: '1 book or book chapter equals 10 CPD point',
  max_credits_per_cycle: 10,
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Peer-review of manuscripts for a scientific journal',
  amount_label: 'hour',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 hour equals 1 CPD point',
  max_credits_per_cycle: 10,
  max_cycles_can_carry_forward: 2
)

# Service to the Community and the Profession
category = Effective::CpdCategory.create!(
  title: 'Service to the Community and the Profession',
  body: "Activities that promote peer interaction, provide exposure to new ideas and technologies; enhance the profession and serve the public interest.",
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: category,
  credit_description: 'Upto a maximum of 10 points per mentee or position per CPD year. Points may be carried over upto a maximum of 2 years after the year in which they were earned.',
  max_credits_per_cycle: nil
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Appointment as a mentor to an in-training registrant, a less experienced applied biology professional, student',
  amount_label: 'mentee',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: '10 * amount',
  credit_description: '1 mentee equals 10 CPD point',
  max_credits_per_cycle: nil,
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Service as an appointed and/or elected biology professional on a public, government, non-government and non-profit organization Board, Council, Committee, Working group etc.',
  amount_label: 'appointed position',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: '10 * amount',
  credit_description: '1 appointed position equals 10 CPD point',
  max_credits_per_cycle: nil,
  max_cycles_can_carry_forward: 2
)

activity = Effective::CpdActivity.create!(
  cpd_category: category,
  title: 'Other',
  amount_label: 'point',
)
Effective::CpdRule.create!(
  cpd_cycle: cycle,
  ruleable: activity,
  formula: 'amount',
  credit_description: '1 point equals 1 CPD point',
  max_credits_per_cycle: nil,
  max_cycles_can_carry_forward: 2
)

puts "All Done"
