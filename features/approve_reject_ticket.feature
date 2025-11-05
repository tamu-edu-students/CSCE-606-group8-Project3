Feature: Staff approve or reject tickets
  As a staff (agent)
  I want to approve or reject tickets so requests can be processed or declined with a reason

  Background:
    Given the following tickets exist:
      | subject        | description         | requester_email       |
      | Approve Me     | Please approve me   | testuser@example.com  |

  Scenario: Staff approves a ticket
  Given there is a user in the database with email "agent1@example.com" and role "staff" named "Agent One"
  And I log in with Google as uid "agent1", email "agent1@example.com", name "Agent One"
    And I go to the tickets list page
  And I am on the ticket page for "Approve Me"
  When I approve the ticket
    Then I should see "Ticket approved."

  Scenario: Staff rejects a ticket with a reason
  Given there is a user in the database with email "agent2@example.com" and role "staff" named "Agent Two"
  And I log in with Google as uid "agent2", email "agent2@example.com", name "Agent Two"
    And I go to the tickets list page
  And I am on the ticket page for "Approve Me"
  When I reject the ticket with reason "Not enough information"
    Then I should see "Ticket rejected."
