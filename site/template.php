<?php
# to run this from the command line to get the binding-file: 
# php -f tempalte.php <binding>
#
#
if ($argv[1]) {
  $p = $argv[1];
} 
include('bindings/' . $p . '.php');
?>
<!DOCTYPE html>
<html>
<head>
</head>
<body>
<div class=$headerText><?php echo isset($header) ? $header : ''; ?></div>
<div class=main><?php echo isset($body) ? $body : ''; ?></div>
<div class=footer><?php echo isset($footer) ? $footer : ''; ?></div>
</body>
</html>
