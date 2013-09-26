Feature: Supports named environments.
  As a user I can configure environments like 'production' or 'staging'
  with paramaters like the endpoint and repo to pull files from.

  Scenario Outline: No environments defined
    When I run <command>
    Then the stderr should contain <error-message>
    And it should fail with:
    """
    deploy
    """

    Examples:
      | command                 | error-message                   |
      | `moment deploy -g`      | "Didn't specify an environment" | 
      | `moment deploy staging` | "can't find \"staging\""        |

  Scenario Outline: Define environment in .moment.yaml file.
    Given a directory named "site"
    Given an empty file named "site/index.html"
    Given a file named ".moment.yaml" with:
    """
    :environments:
      :staging:
        :endpoint: moment_cucumber_site
        :repo: git@github.com:jdrivas/moment-test-site.git
        :branch: cuke_branch
    """
    When I run <command>
    Then the <stream> should contain <message>

    Examples:
      | command                       | stream | message                                         |
      | `moment deploy -n production` | stderr | "Couldn't find specified environment: \"production\""     |
      | `moment deploy -n staging`    | stdout | "moment_cucumber_site"                          |
      | `moment deploy -n staging`    | stdout | "index.html"                                    |
      | `moment deploy -ng staging`   | stdout | "git@github.com:jdrivas/moment-test-site.git"   |
      | `moment deploy -ng staging`   | stdout | "cuke_branch"                                   |
      | `moment deploy -ne cuke_end`  | stdout | "cuke_end"                                      |
      | `moment deploy -nge cuke_end staging` | stdout | "cuke_end"                              |
      | `moment deploy -l`            | stdout | "staging"                                       |

  Scenario Outline: Fail without required information
    Given a directory named "site"
    Given an empty file named "site/index.html"
    Given a file named ".moment.yaml" with:
    """
    :environments:
      :staging:
        :repo: git@github.com:jdrivas/moment-test-site.git
    """
    When I run <command>
    Then the <stream> should contain <message>

    Examples:
      | command                       | stream | message       |
      | `moment deploy -ng staging`   | stderr | "Missing endpoint"     |
      | `moment deploy -n staging`    | stderr | "Missing endpoint" |

  Scenario Outline: Catch errors when no repo is specified, even if an environment is.
    Given a directory named "site"
    Given an empty file named "site/index.html"
    Given a file named ".moment.yaml" with:
    """
    :environments:
      :staging:
        :bogus: value
        :endpoint: an-endpoint
    """
    When I run <command>
    Then the <stream> should contain <message>

    Examples:
      | command                       | stream | message               |
      | `moment deploy -ng staging`   | stderr | "Missing repo"        |

