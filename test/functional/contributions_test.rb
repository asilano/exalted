require 'test_helper'

class ContributionsTest < ActionMailer::TestCase
  test "random_enc" do
    mail = Contributions.random_enc
    assert_equal "Random enc", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "adventure" do
    mail = Contributions.adventure
    assert_equal "Adventure", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
