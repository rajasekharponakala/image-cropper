Feature: User

  In order to have users to crop an image, I need user

  @javascript
  Scenario: Add a user

  An admin should be able to add a user

    Given I am an admin
    And I am signed in
    When I visit the user page
    Then I should see a "New User" link
    When I click the "New User" link
    Then I should see a user form
    When I submit the user information
    Then I should see the user in the list
    And I should see a "current user" link
    When I click the "current user" link
    Then I should see a "Sign Out" link
    When I click the "Sign Out" link
    Then I should see a login form

  @javascript
  Scenario: Edit a user

  An admin should be able to edit a user

    Given I am an admin
    And I am signed in
    And there is 1 cropper
    When I visit the user page
    Then I should see the user in the list
    When I click the edit link in the user list
    Then I should see a user form
    When I submit the user information
    Then I should see the user in the list
    And I should see a "current user" link
    When I click the "current user" link
    And I should see a "Sign Out" link
    When I click the "Sign Out" link
    Then I should see a login form

  @javascript
  Scenario: Activate a user

  An admin should be able to activate a user

    Given I am an admin
    And I am signed in
    And there is 1 cropper
    And I "deactivate" the user
    When I visit the user page
    Then I should see the user in the list
    When I click the activate link in the user list
    Then I should see the user in the list
    And I should see a user "activated"
    And I should see a "current user" link
    When I click the "current user" link
    And I should see a "Sign Out" link
    When I click the "Sign Out" link
    Then I should see a login form

  @javascript
  Scenario: Deactivate a user

  An admin should be able to deactivate a user

    Given I am an admin
    And I am signed in
    And there is 1 cropper
    And I "activate" the user
    When I visit the user page
    Then I should see the user in the list
    When I click the activate link in the user list
    Then I should see the user in the list
    And I should see a user "deactivated"
    And I should see a "current user" link
    When I click the "current user" link
    And I should see a "Sign Out" link
    When I click the "Sign Out" link
    Then I should see a login form
