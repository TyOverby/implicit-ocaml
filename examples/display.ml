open! Core

let display ~tests ~scenes =
  let scenes =
    scenes
    |> List.map ~f:(fun name ->
           sprintf
             {|
    <h2>%s</h2>
    <img src="./%s.svg"></img>|}
             name
             name)
    |> String.concat ~sep:"\n"
  in
  let tests =
    tests
    |> List.map ~f:(fun name ->
           sprintf
             {|
    <h2>%s</h2>
    <img src="./%s.connected.svg"></img>|}
             name
             name)
    |> String.concat ~sep:"\n"
  in
  sprintf
    {|
<html>
<head>
</head>
<body>
<h1> Scenes </h1> 
%s
<h1> Tests </h1> 
%s
</body>
</html>
|}
    scenes
    tests
;;
