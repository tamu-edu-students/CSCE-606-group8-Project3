@wip
Feature: Mock login works

  Scenario: Visiting home page while logged in
    Given I am on the home page
    Then I should see "Welcome"