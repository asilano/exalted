FactoryGirl.define do

  factory :user do  
    email 'example@example.com'
    password {|u| u.email[0,6]}
    password_confirmation {|u| u.email[0,6]}
  end
  
  # factory :encounter_file do
    # author 'Alan'
    # text 'Someone\'s dug a very deep pit here.

# Perhaps it was a Heffalump.'
    # adventure :random     
    # xp_bracket 'low'

    # factory :single_res_enc do
      # resolutions [resolution]
      # author_link 'www.example.com/alan'
      # xp_bracket 'Medium'
    # end
  # end
    
  # factory :resolution, :class => EncounterFile::Resolution do
    # text 'Jump over it'
    # test 'Str + Ath vs 2'
    # success
    # failure
  # end
  
  # factory :success, :class => EncounterFile::Resolution::Outcome do
    # text 'You land clear and nimbly on the other side. That\'ll show the Heffalump'
    # effect 'None'
  # end
  
  # factory :failure, :class => EncounterFile::Resolution::Outcome do
    # text 'You don\'t quite make it and land painfully in the pit. At least you climb out before the Heffalump gets back.'
    # effect '-1B'
  # end
end