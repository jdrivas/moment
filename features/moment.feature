Feature: We get help and error conditions from the app
  As a user I can get help from the command line app
  and I get appropriate messages when the commands are confusing

  Background:
    Given a directory named "site"
    Given an empty file named "site/index.html"

  Scenario: App runs help
    When I successfully run `moment --help`
    Then the stdout should contain "moment [global options] command [command options] [arguments...]"

  Scenario: App creates a default config file
    When I successfully run `moment init`
    Then the file ".moment.yaml" should contain ":environments:"

  Scenario: App can list the files on the site
    When I successfully run `moment files list`
    Then the stdout should contain "index.html"

  Scenario: App lists the endpoint from the command line if given.
    When I successfully run `moment deploy -n -e test-endpoint`
    Then the stdout should contain "test-endpoint"
