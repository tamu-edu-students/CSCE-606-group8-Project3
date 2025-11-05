Feature: Ticket privacy
  As a requester
  I should only be able to see my own tickets
  And agents/admins should be able to see all tickets

  Background:
    Given OmniAuth is in test mode
    And I am on the home page

  Scenario: Requester sees only their own tickets in the list
    And the Google mock returns uid "viewer-1", email "viewer@example.com", name "Viewer"
    When I click "Login with Google"
    And the following tickets exist:
      | subject                     | description              | status | priority | category         | requester_email    |
      | My Ticket A                 | A                        | open   | medium   | Technical Issue  | viewer@example.com |
      | Other User Ticket           | B                        | open   | medium   | Technical Issue  | other@example.com  |
    And I go to the tickets list page
    Then I should see "My Ticket A" in the ticket list
    And I should not see "Other User Ticket" in the ticket list

  Scenario: Agent sees all tickets in the list
    Given a Google user exists with uid "agent-1", email "agent1@example.com", name "Support Agent 1", role "staff"
    And the Google mock returns uid "agent-1", email "agent1@example.com", name "Support Agent 1"
    When I click "Login with Google"
    And the following tickets exist:
      | subject                     | description              | status | priority | category         | requester_email    |
      | My Ticket A                 | A                        | open   | medium   | Technical Issue  | viewer@example.com |
      | Other User Ticket           | B                        | open   | medium   | Technical Issue  | other@example.com  |
    And I go to the tickets list page
    Then I should see "My Ticket A" in the ticket list
    And I should see "Other User Ticket" in the ticket list
