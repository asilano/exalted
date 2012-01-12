class ContributionsMailer < ActionMailer::Base
  default from: "chowlett09@gmail.com",
          to: "chowlett09+exaltedcontribute@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contributions.random_enc.subject
  #
  def random_enc encounter
    @encounter = encounter

    mail subject: "New Encounter contributed"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contributions.adventure.subject
  #
  def adventure adventure
    @adventure = adventure

    mail subject: "New Adventure contributed"
  end
end
