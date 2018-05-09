@validate_page

Feature:

  Background:
    Given I create a new cart

  @test_1
  Scenario:  As a signed in user, I am able to add 2 items to my shopping cart, and can successfully complete the checkout process
    Given I go to the "home" page
    And I sign in as an existing user
    And I go to the "home" page
    And I select the item at "1" position
    And I see the product details frame for "faded_t-shirt"
    And I set the size to be "<size1>" in the product detail page and add it to my shopping cart
    And I continue shopping
    And I select the item at "2" position
    And I see the product details frame for "blouse"
    And I set the size to be "<size2>" in the product detail page and add it to my shopping cart
    When I view my basket
    Then the basket will contain the product "faded_t-shirt" in size "M" with a unit price of "$16.51"
    And the basket will contain the product "blouse" in size "M" with a unit price of "$27.00"
    And the product cost of my order will be "43.51"
    And the shipping cost of my order will be "2.00"
    And the total cost of my order will be "45.51"
    And I will be able to complete my purchase successfully
    And I will be able to log out

  @test_2
  Scenario: As a signed in user who has previously placed orders, I will be able to select an order and add a comment
    Given I go to the "home" page
    And I sign in as an existing user
    And I visit the my account page
    And I select to view "My Orders"
    And I select the most recent order
    And I create a message for the order item "1" as "wobble"
    When I submit my message
    Then my message will be saved under Messages
    And I will be able to log out

  @test_3
  Scenario: As a signed in user who has previously placed an order, I will be able to check that the item ordered is the correct colour
    Given I go to the "home" page
    And I sign in as an existing user
    And I visit the my account page
    And I select to view "My Orders"
    And I select the most recent order
    And the item "Faded Short Sleeve T-shirts" will be size "M" and the colour "Yellow"

  #(Login to the site using the above credentials)
  #From Test 2 create an assertion which will cause a fail (e.g. confirm the dress is red when in fact it is blue) and capture a screen-grab on fail using Selenium
  #(Logout)

