# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "click", "div.entity-object-action", ->
  val = $(this).text()
  id  = $(this).parent().attr("data-id")
  $("input[name$='entity_joint_tenancy[property_id]']").val(id)
  $("input[name$='entity_joint_tenancy[name]']").val(val)
  $(document).find("div#ResourceFormProperties").modal("hide")
