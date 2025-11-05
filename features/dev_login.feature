@dev_only
Feature: Dev quick login via /dev_login/:uid
  In order to quickly impersonate seeded users during development
  As a developer
  I want to use the /dev_login/:uid endpoint to initiate OmniAuth and sign in

  Background:
    # OmniAuth test mode and defaults are configured under features/support

  Scenario: Sign in as seeded agent1 via dev_login
    Given a Google user exists with uid "agent1", email "support.agent@example.com", name "Support Agent 1", role "staff"
    When I visit the dev login path for uid "agent1"
    Then I should be on the home page
    And I should see the dev login message "Signed in as Support Agent 1"

  Scenario: Unknown uid redirects with alert
    When I visit the dev login path for uid "unknown-user"
    Then I should be on the home page
    And I should see the dev login message "No user found for UID unknown-user"
