Feature: Ticket attachments
  As a staff agent
  I want to upload and remove attachments on ticket edits so I can share files and retract them

  Background:
    Given the following tickets exist:
      | subject    | description        | requester_email      |
      | AttachMe   | Please attach file | testuser@example.com |

  Scenario: Staff uploads an attachment (non-JS)
    Given there is a user in the database with email "agent1@example.com" and role "staff" named "Agent One"
    And I log in with Google as uid "agent1", email "agent1@example.com", name "Agent One"
    And I go to the tickets list page
    And I am on the edit page for "AttachMe"
    When I attach the file "spec/fixtures/files/sample.txt"
    And I submit the ticket form
    Then I should be on the ticket page for "AttachMe"
    And I should see "Attachments"
    And I should see "sample.txt"

  Scenario: Staff removes an attachment (non-JS)
    Given there is a user in the database with email "agent2@example.com" and role "staff" named "Agent Two"
    And I log in with Google as uid "agent2", email "agent2@example.com", name "Agent Two"
    And I go to the tickets list page
    And I am on the edit page for "AttachMe"
    When I attach the file "spec/fixtures/files/sample.txt"
    And I submit the ticket form
    And I am on the edit page for "AttachMe"
    When I remove the attachment named "sample.txt"
    And I submit the ticket form
    Then I should be on the ticket page for "AttachMe"
    And I should not see "sample.txt"
