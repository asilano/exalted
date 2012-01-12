require 'int_test_helper'

class ContributeControlTest < ActionController::IntegrationTest
  setup do
    # Pre-define single resolution encounter
    @enc = EncounterFile.new(
        :author => 'Alan',
        :author_link => 'http://www.example.com/alan',
        :text => "Someone's dug a very deep pit here.

Perhaps it was a Heffalump.",
        :adventure => :random,     
        :xp_bracket => :medium_low)
        
    @res = EncounterFile::Resolution.new(
        :text => 'Jump over it',
        :test => 'Str + Ath vs 2')
        
    @res.success = EncounterFile::Resolution::Outcome.new(
        :text => "You land clear and nimbly on the other side. That'll show the Heffalump",
        :effect => "None")
        
    @res.failure = EncounterFile::Resolution::Outcome.new(
        :text => "You don't quite make it and land painfully in the pit. At least you climb out before the Heffalump gets back.",
        :effect => "-1B")
        
    @enc.resolutions = [@res]
    
    # Pre-define single encounter adventure
    @adv = AdventureFile.new(
        :title => "Avoiding the Heffalump",
        :summary => 'You think a Heffalump\'s chasing you. Can you make your escape?',
        :author => 'Alan',
        :author_link => 'http://www.example.com/alan',
        :xp_bracket => :medium_low)
    @adv.encounter_names = ["very_deep_pit"]
    @adv.aux_encounter_names = []
        
  end

  should "add valid encounter with single resolution" do
    # Navigate to Random Encounter contribute page
    visit '/'
    click_on 'contributing encounters or adventures'
    click_link 'Random Encounter!'
    assert page.has_content? 'New Encounter'           
    
    # Fill in Encounter form
    fill_in 'Author', :with => @enc.author
    fill_in 'Author link', :with => @enc.author_link
    fill_in 'Title', :with => "Very Deep Pit"
    fill_in 'Text', :with => @enc.text
    fill_in 'Number of Resolutions', :with => 1
    select @enc.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Resolutions'
    
    # Check Resolution form shows us the encounter so far
    assert page.has_content? "Add Resolution to Encounter 'Very Deep Pit'"
    @enc.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    # Fill in Resolution form
    fill_in 'encounter_file_resolution_text', :with => @res.text
    fill_in 'encounter_file_resolution_test', :with => @res.test
    fill_in 'encounter_file_resolution_success_text', :with => @res.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => @res.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => @res.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => @res.failure.effect
    
    click_button 'Add Resolution'

    # Check feedback and email
    assert page.has_css?('.flash.notice')
    assert page.find('.flash.notice').has_content? "'Very Deep Pit' sent for approval"
    email = ActionMailer::Base.deliveries.shift
    assert_same_elements ['chowlett09+exaltedcontribute@gmail.com'], email.to
    assert_equal "New Encounter contributed", email.subject    
    assert_match("New Encounter 'Very Deep Pit' contributed by #{@enc.author}", email.body.to_s)    
    assert_match(@enc.to_yaml, email.body.to_s)       
  end
  
  should "add valid encounter with image and multiple resolutions" do     
    # Update encounter definition
    local_enc = @enc.dup
    local_enc.image = Image.new(
        :file => 'http://img.example.com/foo.png',
        :artist => 'Pablo Picasso',
        :licence => 'Exalted Mini')
                   
    res_b = EncounterFile::Resolution.new(
        :text => 'Walk around it',
        :test => 'Dex + Sur vs 2')
        
    res_b.success = EncounterFile::Resolution::Outcome.new(
        :text => "It's not a big hole, and you navigate around it without any difficulty.",
        :effect => "None")
        
    res_b.failure = EncounterFile::Resolution::Outcome.new(
        :text => "Astonishingly, you manage to trip over a tree root and land on your face.
        
Ouch.",
        :effect => "-1B")
        
    res_b.botch = EncounterFile::Resolution::Outcome.new(
        :text => "Astonishingly, you manage to trip over a tree root and fall into the pit, head first.",
        :effect => "-2L")
        
    local_enc.resolutions << res_b
    
    # Navigate and fill in Encounter
    visit '/contribute'
    click_link 'Random Encounter!'
    assert page.has_content? 'New Encounter'
    
    fill_in 'Author', :with => local_enc.author
    fill_in 'Author link', :with => local_enc.author_link
    fill_in 'Title', :with => "Very Deep Pit"
    fill_in 'Text', :with => local_enc.text
    fill_in 'Number of Resolutions', :with => 2
    fill_in 'Image link', :with => local_enc.image.file
    fill_in 'Image artist', :with => local_enc.image.artist
    fill_in 'Image licence', :with => local_enc.image.licence
    select local_enc.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Resolutions'
    
    # Submit Resolution 1
    assert page.has_content? "Add Resolution to Encounter 'Very Deep Pit'"
    local_enc.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    fill_in 'encounter_file_resolution_text', :with => @res.text
    fill_in 'encounter_file_resolution_test', :with => @res.test
    fill_in 'encounter_file_resolution_success_text', :with => @res.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => @res.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => @res.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => @res.failure.effect
    
    click_button 'Add Resolution'

    # Submit Resolutions 2
    assert page.has_css?('.flash.notice')
    assert page.find('.flash.notice').has_content? "Resolution added"
    assert page.has_content? "Add Resolution to Encounter 'Very Deep Pit'"
    
    assert page.has_css? '.encounter'
    enc_elm = page.find('.encounter')
    local_enc.text.lines.each {|l| l.strip!; assert enc_elm.has_content? l}
    assert enc_elm.has_content? @res.text
    assert enc_elm.has_button? "Do It!"
    
    fill_in 'encounter_file_resolution_text', :with => res_b.text
    fill_in 'encounter_file_resolution_test', :with => res_b.test
    fill_in 'encounter_file_resolution_success_text', :with => res_b.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => res_b.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => res_b.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => res_b.failure.effect
    fill_in 'encounter_file_resolution_botch_text', :with => res_b.botch.text
    fill_in 'encounter_file_resolution_botch_effect', :with => res_b.botch.effect
    
    click_button 'Add Resolution'

    # Check result and email
    assert page.has_css?('.flash.notice')
    assert page.find('.flash.notice').has_content? "'Very Deep Pit' sent for approval"
    email = ActionMailer::Base.deliveries.shift
    assert_same_elements ['chowlett09+exaltedcontribute@gmail.com'], email.to
    assert_equal "New Encounter contributed", email.subject    
    assert_match("New Encounter 'Very Deep Pit' contributed by #{local_enc.author}", email.body.to_s)
    assert_match(local_enc.to_yaml, email.body.to_s)    
  end
  
  should "reject invalid encounter" do
    visit '/clear_session'
    visit '/contribute'
    click_link 'Random Encounter!'
    assert page.has_content? 'New Encounter'            
    
    # Every required attribute missing. No author, text or title. Can't unselect XP Bracket
    #fill_in 'Author', :with => enc.author
    fill_in 'Author link', :with => @enc.author_link
    #fill_in 'Title', :with => "Very Deep Pit"
    #fill_in 'Text', :with => enc.text
    fill_in 'Number of Resolutions', :with => 1
    select @enc.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Resolutions'
    
    assert page.has_css? '#errorExplanation'
    
    %w<Author Text Title>.each do |field|
      assert page.find('#errorExplanation').has_content?("#{field} can't be blank")
    end
    
    # Invalid number of resolutions - too low
    fill_in 'Author', :with => @enc.author
    fill_in 'Author link', :with => @enc.author_link
    fill_in 'Title', :with => "Very Deep Pit"
    fill_in 'Text', :with => @enc.text
    fill_in 'Number of Resolutions', :with => 0
    select @enc.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Resolutions'
    
    assert page.has_css? '#errorExplanation'
    assert page.find('#errorExplanation').has_content?("Number of Resolutions must be at least 1")
    
    # Invalid number of resolutions - too high
    fill_in 'Author', :with => @enc.author
    fill_in 'Author link', :with => @enc.author_link
    fill_in 'Title', :with => "Very Deep Pit"
    fill_in 'Text', :with => @enc.text
    fill_in 'Number of Resolutions', :with => 6
    select @enc.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Resolutions'
    
    assert page.has_css? '#errorExplanation'
    assert page.find('#errorExplanation').has_content?("Number of Resolutions must be at most 5")
    
    # Image supplied but no artist and licence
    fill_in 'Author', :with => @enc.author
    fill_in 'Author link', :with => @enc.author_link
    fill_in 'Title', :with => "Very Deep Pit"
    fill_in 'Text', :with => @enc.text
    fill_in 'Number of Resolutions', :with => 1
    select @enc.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    fill_in 'Image link', :with => "http://img.example.com"
    
    click_button 'Next - Define Resolutions'
    
    assert page.has_css? '#errorExplanation'
    assert page.find('#errorExplanation').has_content?("Image artist can't be blank if an Image link is specified")
    assert page.find('#errorExplanation').has_content?("Image licence can't be blank if an Image link is specified")
  end
  
  should "reject invalid resolution" do
    visit '/contribute'
    click_link 'Random Encounter!'
    assert page.has_content? 'New Encounter'
        
    fill_in 'Author', :with => @enc.author
    fill_in 'Author link', :with => @enc.author_link
    fill_in 'Title', :with => "Very Deep Pit"
    fill_in 'Text', :with => @enc.text
    fill_in 'Number of Resolutions', :with => 1
    select @enc.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Resolutions'
    
    assert page.has_content? "Add Resolution to Encounter 'Very Deep Pit'"
    @enc.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    # Every required attribute missing
    #fill_in 'encounter_file_resolution_text', :with => res.text
    #fill_in 'encounter_file_resolution_test', :with => res.test
    #fill_in 'encounter_file_resolution_success_text', :with => res.success.text
    #fill_in 'encounter_file_resolution_success_effect', :with => res.success.effect
    #fill_in 'encounter_file_resolution_failure_text', :with => res.failure.text
    #fill_in 'encounter_file_resolution_failure_effect', :with => res.failure.effect
    
    click_button 'Add Resolution'
    
    assert page.has_css? '#errorExplanation'
    
    %w<Text Test>.each do |field|
      assert page.find('#errorExplanation').has_content?("#{field} can't be blank")
    end
    
    %w<Success Failure>.product(%w<Text Effect>).each do |field|
      assert page.find('#errorExplanation').has_content?("#{field[0]} - #{field[1]} can't be blank")
    end
    
    # Botch text only present
    fill_in 'encounter_file_resolution_text', :with => @res.text
    fill_in 'encounter_file_resolution_test', :with => @res.test
    fill_in 'encounter_file_resolution_success_text', :with => @res.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => @res.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => @res.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => @res.failure.effect
    fill_in 'encounter_file_resolution_botch_text', :with => "Botched"
    
    click_button 'Add Resolution'
    
    assert page.has_css? '#errorExplanation'
    assert page.find('#errorExplanation').has_content?("Botch must have both Text and Effect, or neither")
    
    # Botch effect only present
    fill_in 'encounter_file_resolution_text', :with => @res.text
    fill_in 'encounter_file_resolution_test', :with => @res.test
    fill_in 'encounter_file_resolution_success_text', :with => @res.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => @res.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => @res.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => @res.failure.effect
    fill_in 'encounter_file_resolution_botch_text', :with => ""
    fill_in 'encounter_file_resolution_botch_effect', :with => "Botched"
    
    click_button 'Add Resolution'
    
    assert page.has_css? '#errorExplanation'
    assert page.find('#errorExplanation').has_content?("Botch must have both Text and Effect, or neither")
    
    # Check can still submit correct resolution after failures
    fill_in 'encounter_file_resolution_text', :with => @res.text
    fill_in 'encounter_file_resolution_test', :with => @res.test
    fill_in 'encounter_file_resolution_success_text', :with => @res.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => @res.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => @res.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => @res.failure.effect
    fill_in 'encounter_file_resolution_botch_text', :with => ""
    fill_in 'encounter_file_resolution_botch_effect', :with => ""
    
    click_button 'Add Resolution'

    assert page.has_css?('.flash.notice')
    assert page.find('.flash.notice').has_content? "'Very Deep Pit' sent for approval"
    email = ActionMailer::Base.deliveries.shift
    assert_same_elements ['chowlett09+exaltedcontribute@gmail.com'], email.to
    assert_equal "New Encounter contributed", email.subject    
    assert_match("New Encounter 'Very Deep Pit' contributed by #{@enc.author}", email.body.to_s)
    assert_match(@enc.to_yaml, email.body.to_s)    
  end
  
  should "disallow new resolution when no encounter in session" do
    visit "/contribute/new_resolution"
    
    assert_equal '/contribute/new_encounter', current_path
    
    assert page.has_css?('.flash.alert')
    assert page.find('.flash.alert').has_content? "You need to be editing an Encounter to add a Resolution"
  end
  
  should "add valid adventure with one single resolution encounter" do
    # Navigate to Adventure contribution page
    visit '/contribute'
    click_link 'Adventure!'
    assert page.has_content? 'New Adventure'
    
    # Fill in Adventure details
    fill_in 'Author', :with => @adv.author
    fill_in 'Author link', :with => @adv.author_link
    fill_in 'Title', :with => @adv.title
    fill_in 'Summary', :with => @adv.summary
    fill_in 'Number of Encounters', :with => 1
    select @adv.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Encounter Types'
    
    # Define disposition of encounter(s)
    select 'Fixed', :from => 'Encounter 1'
    click_button 'Next - Define Fixed Encounters'
    
    # Define single fixed encounter
    assert page.has_content? "Add Encounter to '#{@adv.title}'"
    @adv.summary.lines.each {|l| assert page.has_content? l}
    assert page.has_button? "Start Adventure"
    
    assert page.has_content? "Define the fixed Encounter in slot #1"
    fill_in 'Title', :with => "Very Deep Pit"
    fill_in 'Text', :with => @enc.text
    fill_in 'Number of Resolutions', :with => 1
    #select @enc.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Resolutions'
    
    # Check Resolution form shows us the encounter so far
    assert page.has_content? "Add Resolution to Encounter 'Very Deep Pit'"
    @enc.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    # Fill in Resolution form
    fill_in 'encounter_file_resolution_text', :with => @res.text
    fill_in 'encounter_file_resolution_test', :with => @res.test
    fill_in 'encounter_file_resolution_success_text', :with => @res.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => @res.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => @res.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => @res.failure.effect
    
    click_button 'Add Resolution'
    
    # Check result and email
    assert page.has_css?('.flash.notice')
    assert page.find('.flash.notice').has_content? "'#{@adv.title}' sent for approval"
    email = ActionMailer::Base.deliveries.shift
    assert_same_elements ['chowlett09+exaltedcontribute@gmail.com'], email.to
    assert_equal "New Adventure contributed", email.subject    
    assert_match("New Adventure '#{@adv.title}' contributed by #{@adv.author}", email.body.to_s)
    assert_match(@adv.to_yaml, email.body.to_s) 
    enc = @enc.dup
    enc.adventure = @adv.title.parameterize('_')
    enc.xp_bracket = @adv.xp_bracket
    assert_match(enc.to_yaml, email.body.to_s)
    
  end
  
  should "add valid adventure with multiple single res encounters" do
    adv = @adv.dup
    adv.num_encounters = 3
    adv.encounter_names += [:random, 'heffalump_and_woozle']
    
    enc_1 = @enc.dup
    enc_1.adventure = @adv.title.parameterize('_')
    enc_1.xp_bracket = @adv.xp_bracket
    
    enc_2 = EncounterFile.new(
        :author => 'Alan',
        :author_link => 'http://www.example.com/alan',
        :text => "Oh no! The Heffalump brought a Woozle along for support!",
        :adventure => adv.title.parameterize('_'),     
        :xp_bracket => adv.xp_bracket)
        
    res = EncounterFile::Resolution.new(
        :text => 'Charm them both',
        :test => 'Man + Pre vs 3')
        
    res.success = EncounterFile::Resolution::Outcome.new(
        :text => "You bring them under your thrall; then break their necks!",
        :effect => "None")
        
    res.failure = EncounterFile::Resolution::Outcome.new(
        :text => "All you get is a squint, followed by a painful beating.",
        :effect => "-2L")
        
    enc_2.resolutions = [res]
    
    # Navigate to Adventure contribution page
    visit '/contribute'
    click_link 'Adventure!'
    assert page.has_content? 'New Adventure'
    
    # Fill in Adventure details
    fill_in 'Author', :with => adv.author
    fill_in 'Author link', :with => adv.author_link
    fill_in 'Title', :with => adv.title
    fill_in 'Summary', :with => adv.summary
    fill_in 'Number of Encounters', :with => 3
    select adv.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Encounter Types'
    
    # Define disposition of encounter(s)
    select 'Fixed', :from => 'Encounter 1'
    select 'Random', :from => 'Encounter 2'
    select 'Fixed', :from => 'Encounter 3'
    click_button 'Next - Define Fixed Encounters'
    
    # Define first fixed encounter
    assert page.has_content? "Add Encounter to '#{adv.title}'"
    adv.summary.lines.each {|l| assert page.has_content? l}
    assert page.has_button? "Start Adventure"
    
    assert page.has_content? "Define the fixed Encounter in slot #1"
    fill_in 'Title', :with => "Very Deep Pit"
    fill_in 'Text', :with => enc_1.text
    fill_in 'Number of Resolutions', :with => 1
    #select enc_1.xp_bracket.to_s.titleize, :from => 'XP Bracket'   
    
    click_button 'Next - Define Resolutions'
    
    # Check Resolution form shows us the encounter so far
    assert page.has_content? "Add Resolution to Encounter 'Very Deep Pit'"
    enc_1.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    # Fill in Resolution form
    fill_in 'encounter_file_resolution_text', :with => @res.text
    fill_in 'encounter_file_resolution_test', :with => @res.test
    fill_in 'encounter_file_resolution_success_text', :with => @res.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => @res.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => @res.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => @res.failure.effect
    
    click_button 'Add Resolution'
    
    # Define second fixed encounter
    assert page.has_content? "Add Encounter to '#{adv.title}'"
    adv.summary.lines.each {|l| assert page.has_content? l}
    assert page.has_button? "Start Adventure"
    enc_1.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    assert page.has_content? "Define the fixed Encounter in slot #3"
    fill_in 'Title', :with => "Heffalump and Woozle"
    fill_in 'Text', :with => enc_2.text
    fill_in 'Number of Resolutions', :with => 1
    #select enc_2.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Resolutions'
    
    # Check Resolution form shows us the encounter so far
    assert page.has_content? "Add Resolution to Encounter 'Heffalump and Woozle'"
    enc_2.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    # Fill in Resolution form
    fill_in 'encounter_file_resolution_text', :with => res.text
    fill_in 'encounter_file_resolution_test', :with => res.test
    fill_in 'encounter_file_resolution_success_text', :with => res.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => res.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => res.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => res.failure.effect
    
    click_button 'Add Resolution'
    
    # Check result and email
    assert page.has_css?('.flash.notice')
    assert page.find('.flash.notice').has_content? "'#{adv.title}' sent for approval"
    email = ActionMailer::Base.deliveries.shift
    assert_same_elements ['chowlett09+exaltedcontribute@gmail.com'], email.to
    assert_equal "New Adventure contributed", email.subject    
    assert_match("New Adventure '#{adv.title}' contributed by #{adv.author}", email.body.to_s)
    assert_match(adv.to_yaml, email.body.to_s) 
    
    assert_match("very_deep_pit:\n#{enc_1.to_yaml}", email.body.to_s)
    assert_match("heffalump_and_woozle:\n#{enc_2.to_yaml}", email.body.to_s)
  end
  
  should "add valid adventure with multiple complex encounters" do
    adv = @adv.dup
    adv.num_encounters = 3
    adv.encounter_names += [:random, 'heffalump_and_woozle']
    
    enc_1 = @enc.dup
    enc_1.adventure = adv.title.parameterize('_')
    enc_1.xp_bracket = adv.xp_bracket
    
    enc_1.image = Image.new(
        :file => 'http://img.example.com/foo.png',
        :artist => 'Pablo Picasso',
        :licence => 'Exalted Mini')
                   
    res_b = EncounterFile::Resolution.new(
        :text => 'Walk around it',
        :test => 'Dex + Sur vs 2')
        
    res_b.success = EncounterFile::Resolution::Outcome.new(
        :text => "It's not a big hole, and you navigate around it without any difficulty.",
        :effect => "None")
        
    res_b.failure = EncounterFile::Resolution::Outcome.new(
        :text => "Astonishingly, you manage to trip over a tree root and land on your face.
        
Ouch.",
        :effect => "-1B")
        
    res_b.botch = EncounterFile::Resolution::Outcome.new(
        :text => "Astonishingly, you manage to trip over a tree root and fall into the pit, head first.",
        :effect => "-2L")
        
    enc_1.resolutions << res_b
    
    enc_2 = EncounterFile.new(
        :author => 'Alan',
        :author_link => 'http://www.example.com/alan',
        :text => "Oh no! The Heffalump brought a Woozle along for support!",
        :adventure => adv.title.parameterize('_'),     
        :xp_bracket => adv.xp_bracket)
        
    res_2a = EncounterFile::Resolution.new(
        :text => 'Charm them both',
        :test => 'Man + Pre vs 3')
        
    res_2a.success = EncounterFile::Resolution::Outcome.new(
        :text => "You bring them under your thrall; then break their necks!",
        :effect => "None")
        
    res_2a.failure = EncounterFile::Resolution::Outcome.new(
        :text => "You succeed, but get a splitting headache from squinting.",
        :effect => "-1L")
        
    res_2a.botch = EncounterFile::Resolution::Outcome.new(
        :text => "All you get is a squint, followed by a painful beating.",
        :effect => "-2L")
        
    res_2b = EncounterFile::Resolution.new(
        :text => 'Punch them',
        :test => 'Str + Mel/MA vs 3')
        
    res_2b.success = EncounterFile::Resolution::Outcome.new(
        :text => "You land a viscious punch. Ha! If only your knuckles didn't hurt",
        :effect => "-1B")
        
    res_2b.failure = EncounterFile::Resolution::Outcome.new(
        :text => "You beat them off, but bruise your knuckles",
        :effect => "-2B")           
        
    enc_2.resolutions = [res_2a, res_2b]
    
    # Navigate to Adventure contribution page
    visit '/contribute'
    click_link 'Adventure!'
    assert page.has_content? 'New Adventure'
    
    # Fill in Adventure details
    fill_in 'Author', :with => adv.author
    fill_in 'Author link', :with => adv.author_link
    fill_in 'Title', :with => adv.title
    fill_in 'Summary', :with => adv.summary
    fill_in 'Number of Encounters', :with => 3
    select adv.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Encounter Types'
    
    # Define disposition of encounter(s)
    select 'Fixed', :from => 'Encounter 1'
    select 'Random', :from => 'Encounter 2'
    select 'Fixed', :from => 'Encounter 3'
    click_button 'Next - Define Fixed Encounters'
    
    # Define first fixed encounter
    assert page.has_content? "Add Encounter to '#{adv.title}'"
    adv.summary.lines.each {|l| assert page.has_content? l}
    assert page.has_button? "Start Adventure"
    
    assert page.has_content? "Define the fixed Encounter in slot #1"
    fill_in 'Title', :with => "Very Deep Pit"
    fill_in 'Text', :with => enc_1.text
    fill_in 'Number of Resolutions', :with => 2
    fill_in 'Image link', :with => enc_1.image.file
    fill_in 'Image artist', :with => enc_1.image.artist
    fill_in 'Image licence', :with => enc_1.image.licence
    #select enc_1.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Resolutions'
    
    # Check Resolution form shows us the encounter so far
    assert page.has_content? "Add Resolution to Encounter 'Very Deep Pit'"
    enc_1.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    # Fill in Resolution form
    fill_in 'encounter_file_resolution_text', :with => @res.text
    fill_in 'encounter_file_resolution_test', :with => @res.test
    fill_in 'encounter_file_resolution_success_text', :with => @res.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => @res.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => @res.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => @res.failure.effect
    
    click_button 'Add Resolution'
    
    # Submit Resolution 2
    assert page.has_css?('.flash.notice')
    assert page.find('.flash.notice').has_content? "Resolution added"
    assert page.has_content? "Add Resolution to Encounter 'Very Deep Pit'"
    
    assert page.has_css? '.encounter'
    enc_elm = page.find('.encounter')
    enc_1.text.lines.each {|l| l.strip!; assert enc_elm.has_content? l}
    assert enc_elm.has_content? @res.text
    assert enc_elm.has_button? "Do It!"
    
    fill_in 'encounter_file_resolution_text', :with => res_b.text
    fill_in 'encounter_file_resolution_test', :with => res_b.test
    fill_in 'encounter_file_resolution_success_text', :with => res_b.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => res_b.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => res_b.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => res_b.failure.effect
    fill_in 'encounter_file_resolution_botch_text', :with => res_b.botch.text
    fill_in 'encounter_file_resolution_botch_effect', :with => res_b.botch.effect
    
    click_button 'Add Resolution'

    # Define second fixed encounter
    assert page.has_content? "Add Encounter to '#{adv.title}'"
    adv.summary.lines.each {|l| assert page.has_content? l}
    assert page.has_button? "Start Adventure"
    enc_1.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    assert page.has_content? "Define the fixed Encounter in slot #3"
    fill_in 'Title', :with => "Heffalump and Woozle"
    fill_in 'Text', :with => enc_2.text
    fill_in 'Number of Resolutions', :with => 2
    #select enc_2.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Resolutions'
    
    # Check Resolution form shows us the encounter so far
    assert page.has_content? "Add Resolution to Encounter 'Heffalump and Woozle'"
    enc_2.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    # Fill in Resolution form
    fill_in 'encounter_file_resolution_text', :with => res_2a.text
    fill_in 'encounter_file_resolution_test', :with => res_2a.test
    fill_in 'encounter_file_resolution_success_text', :with => res_2a.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => res_2a.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => res_2a.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => res_2a.failure.effect
    fill_in 'encounter_file_resolution_botch_text', :with => res_2a.botch.text
    fill_in 'encounter_file_resolution_botch_effect', :with => res_2a.botch.effect
    
    click_button 'Add Resolution'
    
    # Submit Resolution 2
    assert page.has_css?('.flash.notice')
    assert page.find('.flash.notice').has_content? "Resolution added"
    
    assert page.has_content? "Add Resolution to Encounter 'Heffalump and Woozle'"
    assert page.has_css? '.encounter'
    enc_elm = page.find('.encounter')
    enc_2.text.lines.each {|l| l.strip!; assert enc_elm.has_content? l}
    assert enc_elm.has_content? res_2a.text
    assert enc_elm.has_button? "Do It!"
    
    # Fill in Resolution form
    fill_in 'encounter_file_resolution_text', :with => res_2b.text
    fill_in 'encounter_file_resolution_test', :with => res_2b.test
    fill_in 'encounter_file_resolution_success_text', :with => res_2b.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => res_2b.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => res_2b.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => res_2b.failure.effect    
    
    click_button 'Add Resolution'
    
    # Check result and email
    assert page.has_css?('.flash.notice')
    assert page.find('.flash.notice').has_content? "'#{adv.title}' sent for approval"
    email = ActionMailer::Base.deliveries.shift
    assert_same_elements ['chowlett09+exaltedcontribute@gmail.com'], email.to
    assert_equal "New Adventure contributed", email.subject    
    assert_match("New Adventure '#{adv.title}' contributed by #{adv.author}", email.body.to_s)
    assert_match(adv.to_yaml, email.body.to_s) 
    
    assert_match("very_deep_pit:\n#{enc_1.to_yaml}", email.body.to_s)
    assert_match("heffalump_and_woozle:\n#{enc_2.to_yaml}", email.body.to_s)
  end
  
  should "add valid adventure with auxiliary encounters" do
    adv = @adv.dup
    adv.num_aux_encounters = 1
    adv.aux_encounter_names = ["heffalump_and_woozle", "heffalump_and_two_woozles"]
    
    enc_1 = @enc.dup
    enc_1.adventure = adv.title.parameterize('_')
    enc_1.xp_bracket = adv.xp_bracket
    
    enc_1.image = Image.new(
        :file => 'http://img.example.com/foo.png',
        :artist => 'Pablo Picasso',
        :licence => 'Exalted Mini')
                   
    res_b = EncounterFile::Resolution.new(
        :text => 'Walk around it',
        :test => 'Dex + Sur vs 2')
        
    res_b.success = EncounterFile::Resolution::Outcome.new(
        :text => "It's not a big hole, and you navigate around it without any difficulty.",
        :effect => "None")
        
    res_b.failure = EncounterFile::Resolution::Outcome.new(
        :text => "Astonishingly, you manage to trip over a tree root and land on your face.
        
Ouch.",
        :effect => "-1B")
        
    res_b.botch = EncounterFile::Resolution::Outcome.new(
        :text => "Astonishingly, you manage to trip over a tree root and fall into the pit, head first.",
        :effect => "-2L")
        
    enc_1.resolutions << res_b
    
    enc_2 = EncounterFile.new(
        :author => 'Alan',
        :author_link => 'http://www.example.com/alan',
        :text => "Oh no! The Heffalump brought a Woozle along for support!",
        :adventure => adv.title.parameterize('_'),     
        :xp_bracket => adv.xp_bracket)
        
    res_2a = EncounterFile::Resolution.new(
        :text => 'Charm them both',
        :test => 'Man + Pre vs 3')
        
    res_2a.success = EncounterFile::Resolution::Outcome.new(
        :text => "You bring them under your thrall; then break their necks!",
        :effect => "None")
        
    res_2a.failure = EncounterFile::Resolution::Outcome.new(
        :text => "You succeed, but get a splitting headache from squinting.",
        :effect => "-1L")
        
    res_2a.botch = EncounterFile::Resolution::Outcome.new(
        :text => "All you get is a squint, followed by a painful beating.",
        :effect => "-2L")
        
    res_2b = EncounterFile::Resolution.new(
        :text => 'Punch them',
        :test => 'Str + Mel/MA vs 3')
        
    res_2b.success = EncounterFile::Resolution::Outcome.new(
        :text => "You land a viscious punch. Ha! If only your knuckles didn't hurt",
        :effect => "-1B")
        
    res_2b.failure = EncounterFile::Resolution::Outcome.new(
        :text => "You beat them off, but bruise your knuckles",
        :effect => "-2B")           
        
    enc_2.resolutions = [res_2a, res_2b]
    
    enc_3 = EncounterFile.new(
        :author => 'Alan',
        :author_link => 'http://www.example.com/alan',
        :text => "Oh no! The Heffalump brought TWO Woozles along for support!",
        :adventure => adv.title.parameterize('_'),     
        :xp_bracket => adv.xp_bracket,
        :notes => "Or Wizzles, as it may be")
        
    res_3 = EncounterFile::Resolution.new(
        :text => 'Charm them all',
        :test => 'Man + Pre vs 5')
        
    res_3.success = EncounterFile::Resolution::Outcome.new(
        :text => "You bring them under your thrall; then break their necks!",
        :effect => "None")
        
    res_3.failure = EncounterFile::Resolution::Outcome.new(
        :text => "You succeed, but get a splitting headache from squinting.",
        :effect => "-2L")
        
    enc_3.resolutions = [res_3]
    
    # Navigate to Adventure contribution page
    visit '/contribute'
    click_link 'Adventure!'
    assert page.has_content? 'New Adventure'
    
    # Fill in Adventure details
    fill_in 'Author', :with => adv.author
    fill_in 'Author link', :with => adv.author_link
    fill_in 'Title', :with => adv.title
    fill_in 'Summary', :with => adv.summary
    fill_in 'Number of Encounters', :with => 1
    fill_in 'Number of Auxiliary Encounters', :with => 2
    select adv.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Encounter Types'
    
    # Define disposition of encounter(s)
    select 'Fixed', :from => 'Encounter 1'
    click_button 'Next - Define Fixed Encounters'
    
    # Define first fixed encounter
    assert page.has_content? "Add Encounter to '#{adv.title}'"
    adv.summary.lines.each {|l| assert page.has_content? l}
    assert page.has_button? "Start Adventure"
    
    assert page.has_content? "Define the fixed Encounter in slot #1"
    fill_in 'Title', :with => "Very Deep Pit"
    fill_in 'Text', :with => enc_1.text
    fill_in 'Number of Resolutions', :with => 2
    fill_in 'Image link', :with => enc_1.image.file
    fill_in 'Image artist', :with => enc_1.image.artist
    fill_in 'Image licence', :with => enc_1.image.licence
    #select enc_1.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Resolutions'
    
    # Check Resolution form shows us the encounter so far
    assert page.has_content? "Add Resolution to Encounter 'Very Deep Pit'"
    enc_1.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    # Fill in Resolution form
    fill_in 'encounter_file_resolution_text', :with => @res.text
    fill_in 'encounter_file_resolution_test', :with => @res.test
    fill_in 'encounter_file_resolution_success_text', :with => @res.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => @res.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => @res.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => @res.failure.effect
    
    click_button 'Add Resolution'
    
    # Submit Resolution 2
    assert page.has_css?('.flash.notice')
    assert page.find('.flash.notice').has_content? "Resolution added"
    assert page.has_content? "Add Resolution to Encounter 'Very Deep Pit'"
    
    assert page.has_css? '.encounter'
    enc_elm = page.find('.encounter')
    enc_1.text.lines.each {|l| l.strip!; assert enc_elm.has_content? l}
    assert enc_elm.has_content? @res.text
    assert enc_elm.has_button? "Do It!"
    
    fill_in 'encounter_file_resolution_text', :with => res_b.text
    fill_in 'encounter_file_resolution_test', :with => res_b.test
    fill_in 'encounter_file_resolution_success_text', :with => res_b.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => res_b.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => res_b.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => res_b.failure.effect
    fill_in 'encounter_file_resolution_botch_text', :with => res_b.botch.text
    fill_in 'encounter_file_resolution_botch_effect', :with => res_b.botch.effect
    
    click_button 'Add Resolution'

    # Define first auxilliary encounter
    assert page.has_content? "Add Auxiliary Encounter to '#{adv.title}'"
    adv.summary.lines.each {|l| assert page.has_content? l}
    assert page.has_button? "Start Adventure"
    enc_1.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    assert page.has_content? "Define the 1st Auxiliary Encounter"
    fill_in 'Title', :with => "Heffalump and Woozle"
    fill_in 'Text', :with => enc_2.text
    fill_in 'Number of Resolutions', :with => 2
    #select enc_2.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Resolutions'
    
    # Check Resolution form shows us the encounter so far
    assert page.has_content? "Add Resolution to Encounter 'Heffalump and Woozle'"
    enc_2.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    # Fill in Resolution form
    fill_in 'encounter_file_resolution_text', :with => res_2a.text
    fill_in 'encounter_file_resolution_test', :with => res_2a.test
    fill_in 'encounter_file_resolution_success_text', :with => res_2a.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => res_2a.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => res_2a.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => res_2a.failure.effect
    fill_in 'encounter_file_resolution_botch_text', :with => res_2a.botch.text
    fill_in 'encounter_file_resolution_botch_effect', :with => res_2a.botch.effect
    
    click_button 'Add Resolution'
    
    # Submit Resolution 2
    assert page.has_css?('.flash.notice')
    assert page.find('.flash.notice').has_content? "Resolution added"
    
    assert page.has_content? "Add Resolution to Encounter 'Heffalump and Woozle'"
    assert page.has_css? '.encounter'
    enc_elm = page.find('.encounter')
    enc_2.text.lines.each {|l| l.strip!; assert enc_elm.has_content? l}
    assert enc_elm.has_content? res_2a.text
    assert enc_elm.has_button? "Do It!"
    
    # Fill in Resolution form
    fill_in 'encounter_file_resolution_text', :with => res_2b.text
    fill_in 'encounter_file_resolution_test', :with => res_2b.test
    fill_in 'encounter_file_resolution_success_text', :with => res_2b.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => res_2b.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => res_2b.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => res_2b.failure.effect    
    
    click_button 'Add Resolution'
    
    # Define second auxilliary encounter
    assert page.has_content? "Add Auxiliary Encounter to '#{adv.title}'"
    adv.summary.lines.each {|l| assert page.has_content? l}
    assert page.has_button? "Start Adventure"
    enc_1.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    assert page.has_content? "Define the 2nd Auxiliary Encounter"
    fill_in 'Title', :with => "Heffalump and Two Woozles"
    fill_in 'Text', :with => enc_3.text
    fill_in 'Number of Resolutions', :with => 1
    #select enc_2.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    fill_in 'Notes', :with => enc_3.notes
    
    click_button 'Next - Define Resolutions'
    
    # Check Resolution form shows us the encounter so far
    assert page.has_content? "Add Resolution to Encounter 'Heffalump and Two Woozles'"
    enc_3.text.lines.each {|l| l.strip!; assert page.has_content? l}
    assert page.has_button? "Do It!"
    
    # Fill in Resolution form
    fill_in 'encounter_file_resolution_text', :with => res_3.text
    fill_in 'encounter_file_resolution_test', :with => res_3.test
    fill_in 'encounter_file_resolution_success_text', :with => res_3.success.text
    fill_in 'encounter_file_resolution_success_effect', :with => res_3.success.effect
    fill_in 'encounter_file_resolution_failure_text', :with => res_3.failure.text
    fill_in 'encounter_file_resolution_failure_effect', :with => res_3.failure.effect
    fill_in 'encounter_file_resolution_botch_text', :with => res_3.botch.text
    fill_in 'encounter_file_resolution_botch_effect', :with => res_3.botch.effect
    
    click_button 'Add Resolution'
    
    # Check result and email
    assert page.has_css?('.flash.notice')
    assert page.find('.flash.notice').has_content? "'#{adv.title}' sent for approval"
    email = ActionMailer::Base.deliveries.shift
    assert_same_elements ['chowlett09+exaltedcontribute@gmail.com'], email.to
    assert_equal "New Adventure contributed", email.subject    
    assert_match("New Adventure '#{adv.title}' contributed by #{adv.author}", email.body.to_s)
    assert_match(adv.to_yaml, email.body.to_s) 
    
    assert_match("very_deep_pit:\n#{enc_1.to_yaml}", email.body.to_s)
    assert_match("heffalump_and_woozle:\n#{enc_2.to_yaml}", email.body.to_s)    
    assert_match("heffalump_and_two_woozles:\n#{enc_3.to_yaml}", email.body.to_s)
  end
  
  should "reject invalid adventure" do
    # Navigate to Adventure contribution page
    visit '/contribute'
    click_link 'Adventure!'
    assert page.has_content? 'New Adventure'
    
    # Every required attribute missing. No author, summary or title. Can't unselect XP Bracket
    #fill_in 'Author', :with => @adv.author
    #fill_in 'Author link', :with => @adv.author_link
    #fill_in 'Title', :with => @adv.title
    #fill_in 'Summary', :with => @adv.summary
    fill_in 'Number of Encounters', :with => 1
    select @adv.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Encounter Types'
    
    assert page.has_css? '#errorExplanation'
    
    %w<Author Summary Title>.each do |field|
      assert page.find('#errorExplanation').has_content?("#{field} can't be blank")
    end
    
    # Invalid number of encounters - too low
    fill_in 'Author', :with => @adv.author
    fill_in 'Author link', :with => @adv.author_link
    fill_in 'Title', :with => @adv.title
    fill_in 'Summary', :with => @adv.summary
    fill_in 'Number of Encounters', :with => -2
    select @adv.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Encounter Types'
    
    assert page.has_css? '#errorExplanation'
    assert page.find('#errorExplanation').has_content?("Number of Encounters must be at least 1")
    
    # Invalid number of encounters - too high
    fill_in 'Author', :with => @adv.author
    fill_in 'Author link', :with => @adv.author_link
    fill_in 'Title', :with => @adv.title
    fill_in 'Summary', :with => @adv.summary
    fill_in 'Number of Encounters', :with => 20
    select @adv.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Encounter Types'
    
    assert page.has_css? '#errorExplanation'
    assert page.find('#errorExplanation').has_content?("Number of Encounters must be at most 15")
    
    # Invalid number of aux encounters - too high
    fill_in 'Author', :with => @adv.author
    fill_in 'Author link', :with => @adv.author_link
    fill_in 'Title', :with => @adv.title
    fill_in 'Summary', :with => @adv.summary
    fill_in 'Number of Encounters', :with => 1
    fill_in 'Number of Auxiliary Encounters', :with => 20
    select @adv.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    click_button 'Next - Define Encounter Types'
    
    assert page.has_css? '#errorExplanation'
    assert page.find('#errorExplanation').has_content?("Number of Auxiliary Encounters must be at most 15")
    
    # Image present but no artist or licence
    fill_in 'Author', :with => @adv.author
    fill_in 'Author link', :with => @adv.author_link
    fill_in 'Title', :with => @adv.title
    fill_in 'Summary', :with => @adv.summary
    fill_in 'Number of Encounters', :with => 2
    select @adv.xp_bracket.to_s.titleize, :from => 'XP Bracket'
    
    fill_in 'Image link', :with => "http://img.example.com"
        
    click_button 'Next - Define Encounter Types'
    
    assert page.has_css? '#errorExplanation'
    assert page.find('#errorExplanation').has_content?("Image artist can't be blank if an Image link is specified")
    assert page.find('#errorExplanation').has_content?("Image licence can't be blank if an Image link is specified")
  end

  should "disallow encounter types when no adventure in session" do
    visit "/contribute/encounter_types"
    
    assert_equal '/contribute/new_adventure', current_path
    
    assert page.has_css?('.flash.alert')
    assert page.find('.flash.alert').has_content? "You need to be editing an Adventure to set the type of each Encounter"
  end
  
  context "with javascript" do
    setup do
      Capybara.current_driver = :selenium
    end    
    
    should "be able to define a random encounter on one page" do
      visit new_encounter_path
           
      assert page.has_content? 'New Encounter'                 
    
      # Fill in Encounter form
      fill_in 'Author', :with => @enc.author
      fill_in 'Author link', :with => @enc.author_link
      fill_in 'Title', :with => "Very Deep Pit"
      fill_in 'Text', :with => @enc.text
      wait_until { page.has_no_css?("label", :text => "Number of Resolutions", :visible => true) }
      select @enc.xp_bracket.to_s.titleize, :from => 'XP Bracket'
      
      # Check there are no Resolution fields at present, then add one.
      assert page.has_no_content?("Effect")
      click_button("Add Resolution")
      wait_until { page.has_content? "Effect" }
      
      within(page.first('.collapse_group[data-name="Resolution fields"]')) do
        fill_in 'encounter_file_resolutions__text', :with => @res.text
        fill_in 'encounter_file_resolutions__test', :with => @res.test
        fill_in 'encounter_file_resolutions___success_text', :with => @res.success.text
        fill_in 'encounter_file_resolutions___success_effect', :with => @res.success.effect
        fill_in 'encounter_file_resolutions___failure_text', :with => @res.failure.text
        fill_in 'encounter_file_resolutions___failure_effect', :with => @res.failure.effect
      end
      
      # Hide the filled-in resolution
      find(".collapser", :text => "Resolution fields").find('.closer').click
      wait_until { page.has_no_css?("#encounter_file_resolutions__text", :visible => true) }
      
      # Add a second resolution
      local_enc = @enc.dup
                     
      res_b = EncounterFile::Resolution.new(
          :text => 'Walk around it',
          :test => 'Dex + Sur vs 2')
          
      res_b.success = EncounterFile::Resolution::Outcome.new(
          :text => "It's not a big hole, and you navigate around it without any difficulty.",
          :effect => "None")
          
      res_b.failure = EncounterFile::Resolution::Outcome.new(
          :text => "Astonishingly, you manage to trip over a tree root and land on your face.
          
  Ouch.",
          :effect => "-1B")
          
      res_b.botch = EncounterFile::Resolution::Outcome.new(
          :text => "Astonishingly, you manage to trip over a tree root and fall into the pit, head first.",
          :effect => "-2L")
          
      local_enc.resolutions << res_b
      
      click_button("Add Resolution")
      wait_until { page.has_content? "Effect" }
      
      within(page.first('.collapse_group[data-name="Resolution fields"]', :visible => true)) do
        fill_in 'encounter_file_resolutions__text', :with => res_b.text
        fill_in 'encounter_file_resolutions__test', :with => res_b.test
        fill_in 'encounter_file_resolutions___success_text', :with => res_b.success.text
        fill_in 'encounter_file_resolutions___success_effect', :with => res_b.success.effect
        fill_in 'encounter_file_resolutions___failure_text', :with => res_b.failure.text
        fill_in 'encounter_file_resolutions___failure_effect', :with => res_b.failure.effect
        fill_in 'encounter_file_resolutions___botch_text', :with => res_b.botch.text
        fill_in 'encounter_file_resolutions___botch_effect', :with => res_b.botch.effect
      end
      
      # Submit encounter
      click_button("Submit Encounter")
 
      # Check result and email
      assert page.has_css?('.flash.notice')
      assert page.find('.flash.notice').has_content? "'Very Deep Pit' sent for approval"
      email = ActionMailer::Base.deliveries.shift
      assert_same_elements ['chowlett09+exaltedcontribute@gmail.com'], email.to
      assert_equal "New Encounter contributed", email.subject    
      assert_match("New Encounter 'Very Deep Pit' contributed by #{local_enc.author}", email.body.to_s)
      assert_match(local_enc.to_yaml, email.body.to_s)    
 
    end
  end
end