# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->

  $(document).on "click", "div.entity-object-action", ->
    val = $(this).text()
    id  = $(this).parent().attr("data-id")
    $("input[name$='entity_joint_tenancy[property_id]']").val(id)
    $("input[name$='entity_joint_tenancy[name]']").val(val)
    $(document).find("div#ResourceFormProperties").modal("hide")

  $(document).on "click", "a.resource-form-new-property", ->
    url = "/properties/new?ostatus=Purchased"
    $(this).closest('.autocomplete').hide()
    $.ajax
      type: "get"
      url: url
      dataType: "html"
      success: (val) ->
        $("div#ResourceFormNewProperty").find(".model-body").html(val)
        titleReset("Quick save entity")
      error: (e) ->
        console.log e
    $("div#ResourceFormNewProperty").modal()
    enable_datetimepicker_corporation()

  $(document).on "ajax:success", "a.entity-page-xhr, form.entity-page-xhr", (data, xhr, status)->
    name = $("#entity_joint_tenancy_property_id option:selected").text()
    if name 
      $('#edit-title-jt').html(name)
    if (typeof xhr) == "object" && xhr.redirect != undefined
      window.location.href = xhr.redirect+"?just_created="+xhr.just_created      
    else
      $.scrollTo(0)
      $.unblockUI()


