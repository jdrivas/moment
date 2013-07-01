Feature: Deploy from a git repo that is copied over locally.
  As a user I can deploy from the command line by localy cloning the specified
  branch of a git repository and then pushing those files to the specified endpoint.

  Background:
    Given a file named ".moment.yaml" with:
    """
   :environments:
      :staging:
        :endpoint: moment-site
        :repo: git@github.com:jdrivas/moment-test-site.git
    """

  Scenario: Deploy with git should create the local repo
    When I successfully run `moment deploy -g`
    Then the following files should exist:
      | /tmp/moment.git.clone |

