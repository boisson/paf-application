$(document).ready ->
  $("#side_accordion .nav.nav-list li.active").each ->
    $(this).parent().parent().parent().addClass "in"