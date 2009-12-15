#!/usr/bin/env perl

use WarningsToBrowser;

print "Content-type: text/html; charset=utf-8\n\n";

warn "foobar";

print <<'HTML';
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml"> 
<head> 
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 
    <meta http-equiv="Content-Style-Type" content="text/css"/>
</head>
<body id="container">
    本文
</body>
</html>
