Feature: List Tickets
  As a user
  So that I can view my submitted requests
  I want to see a list of all tickets

  Background:
    Given the following tickets exist:
      | subject        | description           |
      | Login Issue  | Cannot access account |
      | Bug Report   | App crashes sometimes |

  Scenario: Viewing all submitted tickets
    Given I log in with Google as uid "12345", email "testuser@example.com", name "Test User"
    When I go to the tickets list page
    Then I should see "Login Issue"
    And I should see "Bug Report"
