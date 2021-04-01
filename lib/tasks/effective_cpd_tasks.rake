# bundle exec rake effective_cpd:seed
namespace :effective_cpd do
  task seed: :environment do
    load "#{__dir__}/../../db/seeds.rb"
  end
end
