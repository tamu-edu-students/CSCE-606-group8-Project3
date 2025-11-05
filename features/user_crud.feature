Feature: Users CRUD
  As a sysadmin
  I want to manage users
  So that I can control access to the system

  Background:
    Given OmniAuth is in test mode



  # --- SYSADMIN-ONLY ACTIONS ---

  Scenario: Sysadmin sees New User and creates a user successfully
    Given there is a user in the database with email "root@example.com" and role "sysadmin" named "Root"
    And I log in with Google as uid "root-uid", email "root@example.com", name "Root"
    When I visit the users index
    And I click "New User"
    And I fill in "Email" with "newuser@example.com"
    And I fill in "Name" with "New User"
    And I select "Staff" from "Role"
    And I fill in "Provider" with "google_oauth2"
    And I fill in "Uid" with "uid-123"
    And I press "Create User"
    Then I should see "User created."
    And I should see "newuser@example.com"
    And I should see "staff"

  Scenario: Sysadmin gets validation errors on create
    Given there is a user in the database with email "root@example.com" and role "sysadmin" named "Root"
    And I log in with Google as uid "root-uid", email "root@example.com", name "Root"
    When I visit the new user page
    And I fill in "Name" with "No Email"
    And I press "Create User"
    Then I should see "prohibited this user from being saved:"
    And I should see "Email can't be blank"
    And I should see "Provider can't be blank"
    And I should see "Uid can't be blank"

  Scenario: Sysadmin edits a user (including role) and updates successfully
    Given there is a user in the database with email "root@example.com" and role "sysadmin" named "Root"
    And there is a user in the database with email "editme@example.com" and role "user" named "Edit Me"
    And I log in with Google as uid "root-uid", email "root@example.com", name "Root"
    When I visit the edit page for user with email "editme@example.com"
    And I fill in "Name" with "Edited Name"
    And I select "Staff" from "Role"
    And I press "Update User"
    Then I should see "User updated."
    And I should see "Edited Name"
    And I should see "staff"

  Scenario: Sysadmin deletes a user
    Given there is a user in the database with email "root@example.com" and role "sysadmin" named "Root"
    And there is a user in the database with email "deleteme@example.com" and role "user" named "Delete Me"
    And I log in with Google as uid "root-uid", email "root@example.com", name "Root"
    When I visit the users index
    And I delete the user with email "deleteme@example.com"
    Then I should see "User deleted."
    And I should not see "deleteme@example.com"


