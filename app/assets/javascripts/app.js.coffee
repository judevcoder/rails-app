$ ->
  $(document).on 'click', 'input#object_select', ->
    checkbox_recheck()

  checkbox_recheck = ->
    data = ''
    $.each $(document).find('input#object_select'), ->
      data = "#{data}#{$(this).data('id')}," if this.checked

    $(document).find('input#multi_delete_objects').val(data)

  $(document).on 'click', 'a#multi_delete_objects_valid', (e)->
    if $(document).find('input#multi_delete_objects').val().length == 0
      swal('please select at least one checkbox')
    else
      $(document).find('input#multi_delete_objects_submit').trigger('click')

  $(document).on 'click', 'input#object_all', ->
    checked = this.checked
    $.each $(document).find('input#object_select'), ->
      $(this).prop('checked', checked)

    typewatch ->
      checkbox_recheck()
    , 200


  $(document).on 'click', 'input.manually_date', ->
    input_object = $(document).find("input##{$(this).data('class')}")
    unless input_object.data('name')
      input_object.data('name', input_object.attr('name'))

    $("select.#{$(this).data('class')}").each ->
      select_object = $(this)
      unless select_object.data('name')
        select_object.data('name', select_object.attr('name'))

    if this.checked
      input_object.show()
      input_object.attr('name', input_object.data('name'))

      $("select.#{$(this).data('class')}").each ->
        select_object = $(this)
        select_object.hide()
        select_object.attr('name', null)

    else

      $("select.#{$(this).data('class')}").each ->
        select_object = $(this)
        select_object.show()
        select_object.attr('name', select_object.data('name'))

      input_object.hide()
      input_object.attr('name', null)

  selectize_single = ->
    $(document).find('select.selectize-single').selectize
      create: false
      sortField: 'text'  

  selectize_single_contact = ->
    $(document).find('select.selectize-single-contact').selectize
      create: false
      sortField: 'text'
      onChange: (value) ->
        if (!value.length)
          return
        else
          $.blockUI()
          typewatch ->
            if value == 'Counter-Party'
              $(document).find('#contact-role_wrapper').hide()
            else
              $(document).find('#contact-role_wrapper').show()
              if value == 'Personnel'
                $(document).find('#cp-role-wrapper').hide()
                $(document).find('#per-role-wrapper').show()
              else
                $(document).find('#cp-role-wrapper').show()
                $(document).find('#per-role-wrapper').hide()
            $.unblockUI()
          , 500


  selectize_single()
  selectize_single_contact()

  $(document).ajaxComplete ->
    selectize_single()
    selectize_single_contact()
