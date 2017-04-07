$ ->
  $(document).on 'click', "#client_is_person_false", ->
    if this.checked
      $(".contact").html('Contact');
      $("input#client_entity").parent().parent().show();
      sort_select_options($(document).find("select#client_state")[0], false)

  $(document).on 'click', "#client_is_person_true", ->
    if this.checked
      $(".contact").html('&nbsp;');
      $("input#client_entity").parent().parent().hide();
      sort_select_options($(document).find("select#client_state")[0], true)

  $(document).on "click", "a.client-form-new-entity", ->
    val = $(document).find("input#client_entity").val()
    url = '/entities/new?val='+val
    $(this).closest('.autocomplete').hide()
    $.ajax
      type: "get"
      url: url
      dataType: "html"
      success: (val) ->
        $("div#ClientFormNewEntity").find(".model-body").html(val)
      error: (e) ->
        console.log e
    $("div#ClientFormNewEntity").modal()

  $("a.client-form-entity-pick-form-list").on 'click', ->
    url = "/entities/xhr_list"
    $.ajax
      type: "get"
      url: url
      dataType: "html"
      success: (val) ->
        $("div#ClientFormEntityPickFormList").find('.model-body').html(val)
      error: (e) ->
        console.log e
    $("div#ClientFormEntityPickFormList").modal()

  $(document).on 'click', 'div.entity-object-action', ->
    $("input#client_entity_id").val($(this).parent().attr("data-id"))
    $("input#client_entity").val($(this).parent().find(".object-text").text())
    try
      json = JSON.parse $(this).parent().find(".object-json").text()
      $(document).find("input#client_first_name").val(json.first_name)
      $(document).find("input#client_last_name").val(json.last_name)
      $(document).find("input#client_phone1").val(json.phone1)
      $(document).find("input#client_phone2").val(json.phone2)
      $(document).find("input#client_fax").val(json.fax)
      $(document).find("input#client_email").val(json.email)
      $(document).find("input#client_postal_address").val(json.postal_address)
      $(document).find("input#client_city").val(json.city)
      $(document).find("input#client_state").find('option:selected').removeAttr("selected");
      $(document).find("input#client_state, option[value='"+json.state+"']").attr("selected", "selected")
      $(document).find("input#client_zip").val(json.zip)
    catch

    $("div.ind-entity-popup").removeClass('selected')
    $(this).parent().addClass('selected')
    setTimeout(->
      $(document).find("div#ClientFormEntityPickFormList").modal("hide")
    , 500)    

  $(document).on 'ajax:beforeSend', 'form#new_entity', ->
    $.blockUI()

  $(document).on 'ajax:success', 'form#new_entity', (data, xhr, status)->
    url = "/entities/"+xhr
    $.ajax
      type: "get"
      url: url
      dataType: "json"
      success: (val) ->
        $("input#client_entity_id").val(val.id)
        $("input#client_entity").val(val.name)
        $("div#ClientFormNewEntity").modal("hide")
        $.unblockUI()
      error: (e) ->
        console.log e

  $(document).on 'ajax:error', 'form#new_entity', (data, xhr, status)->
    $("div#ClientFormNewEntity").find('.model-body').html(xhr.responseText)
    $.unblockUI()