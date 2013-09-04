Feature: We can build a site from a very basic php templating framework.
  As a user I want to build my static site with a template and have the
  build take place automatically on deploy.

  Background:
    Given a directory named "site"
    Given a directory named "site/bindings"
    Given a file named "site/template.php" with:
    """
    <?php
    if ($argv[1]) {
      $p = $argv[1];
    } 
    include("bindings/" . $p . ".php");
    ?>
    <!DOCTYPE html>
    <html>
      <head>  </head>
      <body>
        <div class=header><?php echo isset($header) ? $header : ""; ?></div>
        <div class=main><?php echo isset($body) ? $body : ""; ?></div>
        <div class=footer><?php echo isset($footer) ? $footer : ""; ?></div>
      </body>
    </html>
    """
    Given a file named "site/bindings/index.php" with:
    """
    <?php
    $header = <<< EOT
    <h1>Hello Simple PHP</h1>
    EOT;
    $body = <<< EOT
    <p>This is the body of a SimplePHP file.</p>
    EOT;
    $footer = <<< EOT
    <h4>This is the footer</h4>
    EOT;
    ?>


    """

  Scenario: App builds a simple_php file.
    When I successfully run `moment build  -t simple_php`
    Then a file named "site/index.html" should exist
    And the file "site/index.html" should contain:
    """
    <h1>Hello Simple PHP</h1>
    """
    And the file "site/index.html" should contain:
    """
    <p>This is the body of a SimplePHP file.</p>
    """
    And the file "site/index.html" should contain:
    """
    <h4>This is the footer</h4>
    """

