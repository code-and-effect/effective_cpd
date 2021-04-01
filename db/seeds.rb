now = Time.zone.now

Effective::CpdCycle.all.delete_all

# Build the CpdCycle
cycle = Effective::CpdCycle.create!(
  title: "#{now.year} Continuing Professional Development",
  start_at: now.beginning_of_year,
  end_at: now.end_of_year,
  required_score: 0,
  all_steps_content: "<div>All Steps Content</div>",
  start_content: "<div>Start Content</div>",
  activities_content: "<div>Activities Content</div>",
  submit_content: "<div>Submit Content</div>",
  complete_content: "<div>Complete Content</div>"
)

# Professional Practice
category = cycle.cpd_categories.create!(
  title: 'Professional Practice',
  body: "<div>A registrant who is actively practicing applied biology (performing technical work) or influencing (having some effect on how the professional is practiced) the practice of applied biology. <em>Note: Points claimed in this category cannot also be claimed under the Management category</em></div>",
  max_credits_per_cycle: 20
)

category.cpd_activities.create!(
  title: 'Practicing applied biology',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 0
)

category.cpd_activities.create!(
  title: 'Influencing the practice of applied biology',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 0
)

# Management
category = cycle.cpd_categories.create!(
  title: 'Management',
  body: "<div>The management, evaluation, direction/supervision of professionals; and the management, evaluation and direction/management of projects or activities being carried out by professionals <em>Note: Points claimed in this category cannot also be claimed under the Professional Practice category.</em><div>",
  max_credits_per_cycle: 20
)

category.cpd_activities.create!(
  title: 'Assessment and evaluation of professionals who are conducting applied biology',
  body: "<div>e.g. determining who is best for the particular work.</div>",
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 0
)

category.cpd_activities.create!(
  title: 'Overseeing projects or activities',
  body: "<div>e.g. reviewing professional documents being carried out by professionals.</div>",
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 0
)

category.cpd_activities.create!(
  title: 'Establishing financial (cost assessments) and time limits for projects, and scope of projects',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 0
)

category.cpd_activities.create!(
  title: 'Other',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 0
)

# Formal Learning
category = cycle.cpd_categories.create!(
  title: 'Formal Learning',
  body: "<div>Learning that has academic or technical credit, and may include assignments or examinations to evaluate learning that assists a registrant in practicing due diligence with regards to clients and their professional requirements; and to maintain, enhance or to develop practice competence in areas of practice.<div>",
  max_credits_per_cycle: 35
)

category.cpd_activities.create!(
  title: 'From post-secondary education institutes, suppliers, employers, government or professional associations',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Online, in classroom settings, a combination, or other methods',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 2
)

# Informal Learning
category = cycle.cpd_categories.create!(
  title: 'Informal Learning',
  body: "<div>Learning that has academic or technical credit, and may include assignments or examinations to evaluate learning that assists a registrant in practicing due diligence with regards to clients and their professional requirements; and to maintain, enhance or to develop practice competence in areas of practice.<div>",
  max_credits_per_cycle: 15
)

category.cpd_activities.create!(
  title: 'Self-directed studies',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Attendance at conferences, seminars, workshops, technical presentations, clinics',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Formalized and structured on the job training',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Attendance at meetings of technical, professional or managerial associations or societies',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Structured discussion of technical or professional issues with peers',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 2
)

# Presentations
category = cycle.cpd_categories.create!(
  title: 'Presentations',
  body: "<div>Lecture/talk/speech that is of a technical and/or professional nature that are outside the normal daily job function(s)</div>",
  max_credits_per_cycle: 15
)

category.cpd_activities.create!(
  title: 'Conference, symposium, workshop, seminar meeting, course, training session, lunch presentations',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Post-secondary education institutes, employers, government, professional associations, public organizations',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Other',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 2
)

# Contributions to Knowledge
category = cycle.cpd_categories.create!(
  title: 'Contributions to Knowledge',
  body: "<div>Activities which expand or develop new biological and/or technical/scientific knowledge in the biological profession are recognized that are outside the normal daily job function(s).</div>",
  max_credits_per_cycle: 30
)

category.cpd_activities.create!(
  title: 'Development of published standards, practices, codes',
  formula: '10 * amount',
  amount_label: 'standard, practice, code',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Development of published policy(ies), reference(s), guidelines(s), guidance(s)',
  formula: '10 * amount',
  amount_label: 'standard, practice, guideline',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Publication of papers in scientific peer-reviewed journals',
  formula: 'amount',
  amount_label: 'hour',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Publication of articles in non-peer-reviewed journals',
  formula: '5 * amount',
  amount_label: 'article',
  max_credits_per_cycle: 10,
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Publication of a books, a book chapter',
  formula: '10 * amount',
  amount_label: 'book or book chapter',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Peer-review of manuscripts for a scientific journal',
  formula: 'amount',
  amount_label: 'hour',
  max_cycles_can_carry_forward: 2
)

# Service to the Community and the Profession
category = cycle.cpd_categories.create!(
  title: 'Service to the Community and the Profession',
  body: "<div>Activities that promote peer interaction, provide exposure to new ideas and technologies; enhance the profession and serve the public interest.<div>",
  max_credits_per_cycle: nil
)

category.cpd_activities.create!(
  title: 'Appointment as a mentor to an in-training registrant, a less experienced applied biology professional, student',
  formula: 'amount * 10',
  amount_label: 'mentee',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Service as an appointed and/or elected biology professional on a public, government, non-government and non-profit organization Board, Council, Committee, Working group etc.',
  formula: 'amount * 10',
  amount_label: 'position',
  max_cycles_can_carry_forward: 2
)

category.cpd_activities.create!(
  title: 'Other',
  formula: 'amount',
  amount_label: 'points',
  max_cycles_can_carry_forward: 2
)

puts "All Done"
