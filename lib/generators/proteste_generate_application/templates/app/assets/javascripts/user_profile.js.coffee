$("#btn-my-profile").click (e) ->
  e.preventDefault()
  $("#my_profile").modal().css
    width: "700px"
    "margin-left": ->
      -($(this).width() / 2)

$('#btn-edit-password-in-profile').click (e) ->
  e.preventDefault()
  $("#my_profile").modal('hide')
  $("#edit_password").modal('show')