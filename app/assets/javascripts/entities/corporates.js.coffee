$ ->
  $(document).on 'click', "input[id$=_is_person_false]", ->
    if this.checked
      $(document).find(".contact").html('Contact');
      $(document).find("input[id$=_entity]").parent().show();

      $.ajax
        type: "POST"
        url: "/xhr/clients_options_html"
        data: {is_person: "false", id: $("select[id$=_temp_id]").attr("data-id"), cid: $("#cid").val(), client_type: $("select[id$=_temp_id]").attr("data-clienttype")}
        dataType: "html"
        success: (val) ->
          $(document).find("select[id$=_temp_id]").html(val);
        error: (e) ->
          console.log e

      sort_select_options($(document).find("select[id$=_state]")[0], false)

  $(document).on 'click', "input[id$=_is_person_true]", ->
    if this.checked
      $(document).find(".contact").html('&nbsp;');
      $(document).find("input[id$=_entity]").parent().hide();

      $.ajax
        type: "POST"
        url: "/xhr/clients_options_html"
        data: {is_person: "true", id: $("select[id$=_temp_id]").attr("data-id"), cid: $("#cid").val(), client_type: $("select[id$=_temp_id]").attr("data-clienttype")}
        dataType: "html"
        success: (val) ->
          $(document).find("select[id$=_temp_id]").html(val);
        error: (e) ->
          console.log e

      sort_select_options($(document).find("select[id$=_state]")[0], true)

  $(document).on 'click', "select[id$=_temp_id]", ->
    currentType = $(this).find("option:selected").attr('data-type');

    if currentType == "contact"
      oldType = "entity_id";
    else
      oldType = "contact_id";

    currentName = $(this).attr("name");
    $(this).attr("name", currentName.replace(oldType, currentType + "_id"));

  $(document).on "click", "a.resource-form-new-entity", ->
    url = '/entities/new?stockholder=true'
    $(this).closest('.autocomplete').hide()
    $.ajax
      type: "get"
      url: url
      dataType: "html"
      success: (val) ->
        $("div#ResourceFormNewEntity").find(".model-body").html(val)
        titleReset("Quick save entity")
        enable_datetimepicker_corporation()
        change_entity_type_($(document).find("select#entity_type_")[0])
      error: (e) ->
        console.log e
    $("div#ResourceFormNewEntity").modal()

  $(document).on 'click', "a.resource-form-entity-pick-form-list", ->
    url = "/entities/xhr_list?stockholder=true"
    $.ajax
      type: "get"
      url: url
      dataType: "html"
      success: (val) ->
        $(document).find("div#ResourceFormEntityPickFormList").find('.model-body').html(val)
      error: (e) ->
        console.log e
    $(document).find("div#ResourceFormEntityPickFormList").modal()

  $(document).on "ajax:beforeSend", "form.new-entity-resource", ->
    $.blockUI()

  $(document).on "ajax:success", "form.new-entity-resource", (data, xhr, status)->
    url = "/entities/"+xhr
    $.ajax
      type: "get"
      url: url
      dataType: "json"
      success: (val) ->
        $("input[id$=_entity_id]").val(val.id)
        $("input[id$=_entity]").val(val.name)
        $("div#ResourceFormNewEntity").modal("hide")
        $.unblockUI()
      error: (e) ->
        console.log e

  $(document).on "ajax:error", "form.new-entity-resource", (data, xhr, status)->
    $("div#ResourceFormNewEntity").find(".model-body").html(xhr.responseText)
    enable_datetimepicker_corporation()
    change_entity_type_($(document).find("select#entity_type_")[0])
    $.unblockUI()

  $(document).on 'click', 'div.entity-object-action-resource', ->
    $(document).find("input[id$=_entity_id]").val($(this).parent().attr("data-id"))
    $(document).find("input[id$=_entity]").val($(this).parent().find(".object-text").text())
    try
      json = JSON.parse $(this).parent().find(".object-json").text()
      $(document).find("input[id$=_first_name]").val(json.first_name)
      $(document).find("input[id$=_last_name]").val(json.last_name)
      $(document).find("input[id$=_phone1]").val(json.phone1)
      $(document).find("input[id$=_phone2]").val(json.phone2)
      $(document).find("input[id$=_fax]").val(json.fax)
      $(document).find("input[id$=_email]").val(json.email)
      $(document).find("input[id$=_postal_address]").val(json.postal_address)
      $(document).find("input[id$=_city]").val(json.city)
      $(document).find("input[id$=_state]").find('option:selected').removeAttr("selected");
      $(document).find("input[id$=_state], option[value='"+json.state+"']").attr("selected", "selected")
      $(document).find("input[id$=_zip]").val(json.zip)
    catch

    $(document).find("div.ind-entity-popup").removeClass('selected')
    $(this).parent().addClass('selected')
    setTimeout(->
      $(document).find("div#ResourceFormEntityPickFormList").modal("hide")
    , 500)

  $(document).on "keypress keyup keydown click change", "#entity_number_of_assets", ->
    setTimeout(->
      try
        total_val = parseInt($(document).find("#entity_number_of_assets").val())
      catch
        total_val = 0
      try
        remaining_val = parseInt($(document).find("input[type='hidden']#instant_remaining_number_of_assets").val())
      catch
        remaining_val = 0
      total_val = 0 if isNaN(total_val)
      remaining_val = 0 if isNaN(remaining_val)
      $(document).find("input[type='text']#instant_remaining_number_of_assets").val(total_val - remaining_val)
    , 300)

  $(document).on "keypress keyup keydown click change", "input[id$=_my_percentage]", ->
    remaining_number_of_assets_cal(300, this)

  remaining_number_of_assets_cal = (timeout, self)->
    setTimeout(->

      current_value                             = $(self).val()
      remaining_number_of_assets_text           = $(document).find("input[type='text'][id$=remaining_number_of_assets]")
      remaining_number_of_assets_hidden         = $(document).find("input[type='hidden'][id$=remaining_number_of_assets]")
      remaining_number_of_assets_hidden_warning = $(document).find("input[type='hidden'][id$=remaining_number_of_assets_warning]")

      try
        total_val = parseInt(current_value)
      catch
        total_val = 0

      try
        remaining_val = parseInt(remaining_number_of_assets_hidden.val())
      catch
        remaining_val = 0

      try
        init_val = parseInt(remaining_number_of_assets_text.data('init'))
      catch
        init_val = 0

      total_val     = 0 if isNaN(total_val)
      remaining_val = 0 if isNaN(remaining_val)
      init_val      = 0 if isNaN(init_val)
      val_insert    = ((remaining_val + init_val) - total_val)
      val_insert    = remaining_number_of_assets_hidden_warning.val() if val_insert < 0

      remaining_number_of_assets_text.val(val_insert)
    , timeout)

  enable_datetimepicker_corporation()

  $(document).on "ajax:beforeSend", "a.entity-page-xhr, form.entity-page-xhr", ->
    if $(this).attr("href") != undefined
      $(document).find("a.entity-page-xhr").removeClass("active");
      $(this).addClass("active");
      window.history.pushState("next", "page", $(this).attr("href"));
    $.blockUI()

  $(document).on "ajax:success", "a.entity-page-xhr, form.entity-page-xhr", (data, xhr, status)->
    if (typeof xhr) == "object" && xhr.redirect != undefined
      window.location.href = xhr.redirect+"?just_created="+xhr.just_created
    else
      console.log(xhr)
      $(document).find("div.corporate-contact-form").html(xhr)
      manage_jsGrid_UI()
      enable_datetimepicker_corporation()
      $.scrollTo(0)
      $.unblockUI()

  hashquery = queryString.parse(location.search)
  if hashquery.xhr != undefined
    $(document).find("a[href='"+hashquery.xhr+"']:first").trigger("click");

  $(document).on "click", "input[id$='is_honorific']", ->
    stock_holder_honorific_fun(this)

  stock_holder_honorific_fun = (self)->
    if self.checked
      $(self).parent().parent().find("div.part3").show()
    else
      $(self).parent().parent().find("div.part3").hide()

  $(document).on "change", "select#entity_type_", ->
    change_entity_type_(this)

  change_entity_type_ = (self) ->
    if $("option:selected", self).val() == "1"
      $(document).find(".is-corporation").show()
    else
      $(document).find(".is-corporation").hide()
