@api @nobrowser
Feature: I am able to check the responses from the APIs

  Background:
    Given I wait "1" seconds to let things settle

  @get_users_list
  Scenario: I will not GET the list of all users
    Given I GET "/api/users?page=1"
    Then the JSON response code should be "200"
    And the JSON should have text matching value "1" at path "page"
    And the JSON should have text matching value "3" at path "per_page"

  @get_single_user_found
  Scenario: I will be able to GET a single user
    Given I GET "/api/users/2"
    Then the JSON response code should be "200"
    And the returned user details should contain text matching value "2" at path "id"
    And the returned user details should contain text matching value "Janet" at path "first_name"
    And the returned user details should contain text matching value "Weaver" at path "last_name"
    And the returned user details should contain text matching value "https://s3.amazonaws.com/uifaces/faces/twitter/josephstein/128.jpg" at path "avatar"

  @get_single_user_not_found
  Scenario: I will be not be able to GET a single user when they do not exist
    Given I GET "/api/users/23"
    Then the JSON response code should be "404"

  @get_resource_list
  Scenario: I will GET the list of all resources
    Given I GET "/api/uknown"
    Then the JSON response code should be "200"
    And the JSON should have text matching value "1" at path "page"
    And the JSON should have text matching value "3" at path "per_page"
    And the JSON should have text matching value "4" at path "total_pages"
    And the JSON should have text matching value "12" at path "total"
    And the returned resource details should contain text matching value "1" at path "id" for resource "0"
    And the returned resource details should contain text matching value "cerulean" at path "name" for resource "0"
    And the returned resource details should contain text matching value "#98B2D1" at path "color" for resource "0"
    And the returned resource details should contain text matching value "2000" at path "year" for resource "0"
    And the returned resource details should contain text matching value "15-4020" at path "pantone_value" for resource "0"
    And the returned resource details should contain text matching value "2" at path "id" for resource "1"
    And the returned resource details should contain text matching value "fuchsia rose" at path "name" for resource "1"
    And the returned resource details should contain text matching value "#C74375" at path "color" for resource "1"
    And the returned resource details should contain text matching value "2001" at path "year" for resource "1"
    And the returned resource details should contain text matching value "17-2031" at path "pantone_value" for resource "1"
    And the returned resource details should contain text matching value "3" at path "id" for resource "2"
    And the returned resource details should contain text matching value "true red" at path "name" for resource "2"
    And the returned resource details should contain text matching value "#BF1932" at path "color" for resource "2"
    And the returned resource details should contain text matching value "2002" at path "year" for resource "2"
    And the returned resource details should contain text matching value "19-1664" at path "pantone_value" for resource "2"

  @get_resource_single
  Scenario: I will GET the list of a single resource
    Given I GET "/api/uknown/2"
    Then the JSON response code should be "200"
    And the returned user details should contain text matching value "2" at path "id"
    And the returned user details should contain text matching value "fuchsia rose" at path "name"
    And the returned user details should contain text matching value "2001" at path "year"
    And the returned user details should contain text matching value "#C74375" at path "color"
    And the returned user details should contain text matching value "17-2031" at path "pantone_value"

  @get_single_resource_not_found
  Scenario: I will not be able to GET a single resource when the id does not exist
    Given I GET "/api/unknown/23"
    Then the JSON response code should be "404"

  @create_new_user
  Scenario: I can POST a request to create a new user
    Given I POST the request to create a new user at path "/api/users" with name "morpheus" and role "leader"
    Then the JSON response code should be "201"

  @update_existing_user
  Scenario: I can PUT a request to update a user
    Given I PUT the request to update user at path "/api/users/2" with name "morpheus" and role "zion resident"
    Then the JSON response code should be "200"

  @delete_existing_user
  Scenario: I can DELETE an existing user
    Given I DELETE the user at path "/api/users/2"
    Then the JSON response code should be "204"

