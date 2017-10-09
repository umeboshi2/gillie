<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="pyramid web application">
    <meta name="author" content="Pylons Project">
    <link rel="shortcut icon" href="{{request.static_url('gillie:static/pyramid-16x16.png')}}">
    <link rel="stylesheet" type="text/css" href="${csspath}/font-awesome.css"/>
    <link rel="stylesheet" type="text/css" href="${csspath}/bootstrap-${basecolor}.css"/>
    <link href="https://fonts.googleapis.com/css?family=Architects+Daughter" rel="stylesheet" type="text/css">
    <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro" rel="stylesheet" type="text/css">
    <link href="https://fonts.googleapis.com/css?family=Rambla" rel="stylesheet" type="text/css">
    <link href="https://fonts.googleapis.com/css?family=Play" rel="stylesheet" type="text/css">
    <script type="text/javascript" charset="utf-8" src="${req.webpack().get_bundle('vendor')[0]['url']}"></script>
    <script type="text/javascript" charset="utf-8" src="${req.webpack().get_bundle('common')[0]['url']}"></script>
    <script type="text/javascript" charset="utf-8" src="${req.webpack().get_bundle(appname)[0]['url']}"></script>
  </head>
  <body>
  </body>
</html>
