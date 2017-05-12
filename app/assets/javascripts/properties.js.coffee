$ ->
  $(document).on 'ajax:beforeSend', 'a.new-property', ->
    $.blockUI()

  $(document).on 'ajax:success', 'a.new-property', (data, xhr, status)->
    $('#NewProperty').find('.modal-content').html(xhr)
    $('#NewProperty').modal()
    enable_datetimepicker()
    $.unblockUI()

  $(document).on 'ajax:beforeSend', 'form.new_property', ->
    $.blockUI()

  $(document).on 'ajax:success', 'form.new_property', (data, xhr, status)->
    $('div.project-index').append(xhr)
    $('#NewProperty').modal('hide')
    $.unblockUI()

  $(document).on 'click', 'a.property-settings', ->
    position = $(this).position()
    $(this).parent().parent().find('#property-settings:first').toggle();
    $(this).parent().parent().find('#property-settings:first').css('left', (position.left - 100) + 'px');

  $(document).on 'click', (e)->
    if !$(e.target).hasClass('property-settings')
      container = $("#property-settings")
      if (!container.is(e.target) and (container.has(e.target).length == 0))
        container.hide();

  #      Inline EDIT
  $(document).on 'mouseover', '.property-heading-index', ->
    id = $(this).attr('data-id')
    $(document).find('.property-heading-index').editable '/properties/update/'+id,
      name: 'title'
      tooltip: 'click to edit..'
      indicator: 'Saving....'
      onblur : 'submit'
      callback: ->
#        fetch_action_checklist(pid)

  $(document).on 'mouseover', '.property-description-index', ->
    id = $(this).attr('data-id')
    $(document).find('.property-description-index').editable '/properties/update/'+id,
      type: 'textarea'
      name: 'description'
      tooltip: 'click to edit..'
      indicator: 'Saving....'
      onblur : 'submit'
      callback: ->


  $(document).on 'click', '.title', ->
    url = $(this).parent().attr('url')
    window.location.href = url if url.length > 0
  $(document).on 'click', 'input#property_location_street_address_from_county_tax_authorities_is', ->
    if this.checked
      $(document).find('#location_street_address_from_county_tax_authorities').show()
    else
      $(document).find('#location_street_address_from_county_tax_authorities').hide()

  setTitleValue = ->
    if $('#property_location_city').val().length > 0
      $(document).find('.tilte_basic_info').show()
      property_title = $('#property_tenant_is').val() + ', ' + $('#property_location_city').val()
      $('#property_title').val(property_title)

  titleHideShow = ->
    if $('#property_location_city').length > 0 && $('#property_location_city').val().length > 0
      $(document).find('.tilte_basic_info').show()
      setTitleValue()
    else
      #$(document).find('.tilte_basic_info').hide()
    return

  $(document).ready ->
    titleHideShow()

  $(document).on 'keyup', '#property_location_city', ->
    titleHideShow()

  $(document).on 'change', '#property_tenant_is', ->
    setTitleValue()

  $(document).on 'click', '.entity_owner', ->
    if this.value == "true"
      $('#person_owner').show()
      $('#entity_owner').hide()
    else
      $('#person_owner').hide()
      $('#entity_owner').show()

  $(document).on 'ifChecked', '#property_owner_person_is_true', ->
    #alert "is person"
    $(document).find('div.sale-tr-pr-detail').show()
    $(document).find('div.sale-tr-et-detail').hide()

  $(document).on 'ifChecked', '#property_owner_person_is_false', ->    
    #alert "is not a person"
    $(document).find('div.sale-tr-pr-detail').hide()
    $(document).find('div.sale-tr-et-detail').show() 
      
  $(document).on "click", "a.ownership-form-new-entity", ->
    if $('#status_poperty')[0].value == "Purchased"
      url = '/clients/new'
    else
      url = '/contacts/new'
    $(this).closest('.autocomplete').hide()
    $.ajax
      type: "get"
      url: url
      dataType: "html"
      success: (val) ->
        $("div#OwnershipFormNewEntity").find(".model-body").find(".OwnershipFormNewEntity").html(val)
      error: (e) ->
        console.log e
    $("div#OwnershipFormNewEntity").modal()

  
  $(document).on 'click', "a.resource-form-entity-pick-form-list", ->
    url = "/properties/xhr_list_dropdown"
    params = {person: $('.entity_owner')[0].checked, id: $('#property_id')[0].value }
    $.ajax
      type: "get"
      url: url
      data: params
      dataType: "html"
      success: (val) ->
        $("div#OwnershipFormNewEntity").find(".model-body").find(".OwnershipFormNewEntity").html(val)
      error: (e) ->
        console.log e
    $("div#OwnershipFormNewEntity").modal()
 
  $(document).on 'click', ".ind-entity-popup", ->
    $("div#OwnershipFormNewEntity").modal('hide');
    if $(this).data('klass') == "Person"
      $('#owner_entity_dropown_selection').html('<input autocomplete="off" id="property_owner_person_id" name="property[owner_person_id]" type="hidden">')
      $('#property_owner_person_id').val($(this).data('id'))
      $('#member_entity').val($(this).data('name'))
    else
      $('#owner_entity_dropown_selection').html('<input autocomplete="off" id="property_owner_entity_id" name="property[owner_entity_id]" type="hidden">')
      $('#property_owner_entity_id').val($(this).data('id'))
      $('#member_entity').val($(this).data('name'))