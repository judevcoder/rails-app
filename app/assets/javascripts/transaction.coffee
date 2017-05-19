
$ ->
  # Global Variables
  selected_offer_acceptance_tab = $(document).find($(document).find('#offer_list li.active a').attr('href'))
  last_counteroffer = 0         # 0: client's' counteroffer, 1: counter party's counteroffer 

  # Sale
  $(document).on 'ifChecked', '#transaction_seller_person_is_true', ->
    $(document).find('div.sale-tr-pr-detail').show()
    $(document).find('div.sale-tr-et-detail').hide()

  $(document).on 'ifChecked', '#transaction_seller_person_is_false', ->
    if this.checked
      $(document).find('div.sale-tr-pr-detail').hide();
      $(document).find('div.sale-tr-et-detail').show();  
  
  $(document).on 'click', '#save-and-next', ->
    

  # Purchase
  $(document).on 'ifChecked', '#transaction_purchaser_person_is_true', ->
    if this.checked
      $(document).find('div.purchase-tr-pr-detail').show();
      $(document).find('div.purchase-tr-et-detail').hide();

  $(document).on 'ifChecked', '#transaction_purchaser_person_is_false', ->
    if this.checked
      $(document).find('div.purchase-tr-pr-detail').hide();
      $(document).find('div.purchase-tr-et-detail').show(); 
  

  sale_pre_loi_text = (seller)-> '<strong>Congratulations!</strong> You have just initiated a 1031 Exchange on behalf of <strong>'+seller+'</strong>. You can now identify the ' +
    ' property that you wish to relinquish, hire a Qualified Intermediary, set a sales price and input a broker. Please ' +
    'be sure to input the progress of your Exchange by updating the Status dropdown. All changes will be updated in ' +
    ' Status Tab'

  sale_loi_to_psa = -> '<strong>Congratulations!</strong> You have found a potential buyer for the property that you wish to ' +
    'relinquish. Please fill out the Prospective Purchaser and use the Document tab to create a compelling competitive Letter ' +
    'of intent to entice the buyer into snapping up your "hot to trot" property!. if the buyer accepts the terms of the ' +
    'LOI, negotiate a Purchase Sale Agreement with the buyer and enter its terms into the Term tab, Don`t hesitate to begin ' +
    'to use the Purchase tab to start measuring up prospective Replacement properties. it`s always good to think ahead! Once ' +
    'you are in contract, change Status dropdown to Inspection Period!'

  sale_inspection_period = -> 'Now you are in the process of Relinquishing your Property! Make sure that you have properly filled out ' +
    'all the Terms of the PSA especially the Date of the Contract and all relevant deadlines as in the payment of required ' +
    'deposits and -- most centrally importantly: <br/> <strong>THE DATE THAT THE INSPECTION PERIOD ENDS</strong><br/> ' +
    'Once that day passes, the Buyer can no longer get his or her money back. Also make sure to contact of Tenant to get an Estoppel ' +
    'Certificate or a waiver of the Right of First Refusal if such provisions exists in the contract. '

  sale_inspection_period_closing = -> '<strong>Congratulations!</strong> Now that the contract has `hardening`, the Buyer can ' +
    'no longer get his or her deposit money back! Now it`s time to work intensively in the Documents Tab to make sure that you have ' +
    'provided all necessary Documents to the Buyer and have acquired the necessary authorizations and corporate or entity documents ' +
    'from Buyer if necessary '

  sale_closing_date_set = -> '<strong>You are almost there!</strong> To get to this point, you must have filled out the Closing ' +
    'date in the Terms Tab. Now it`s time to fill out the Closing Statement and get it counter-signed by the other side. ' +
    'Make sure your buyer`s QI has the correct wire instructions for your Title Company! Also, as soon as the contract closes ' +
    ', update the Status Tab to Post Closing. Now your 45 days indentification and 180 days completion deadlines are ' +
    'ticking away. Can`t you hear the sound, tick tock, tick tock, tick tock ... '

  sale_post_closing = -> 'App enters Purchase Mode'

  try
    # if getJsonFromUrl()['status_alert'] == 'Sale+Pre+LOI'
    #   seller = $(document).find('input#entity_info').val()
    #   sweet_alert_text_success(sale_pre_loi_text(seller))
    # else if getJsonFromUrl()['status_alert'] == 'Sale+LOI+to+PSA'
    #   sweet_alert_text_success(sale_loi_to_psa())
    # else if getJsonFromUrl()['status_alert'] == 'Sale+Inspection+Period'
    #   sweet_alert_text_success(sale_inspection_period())
    # else if getJsonFromUrl()['status_alert'] == 'Sale+Inspection+Period+to+Closing'
    #   sweet_alert_text_success(sale_inspection_period_closing())
    # else if getJsonFromUrl()['status_alert'] == 'Sale+Closing+Date+Set'
    #   sweet_alert_text_success(sale_closing_date_set())
    # else if getJsonFromUrl()['status_alert'] == 'Sale+Post+Closing'
    #   sweet_alert_text_success(sale_post_closing())

  catch

  purchase_pre_loi_text = (purchaser) -> "<strong>Congratulations!</strong>  You have just initiated a 1031 Exchange
                            on behalf of " + purchaser + ". You can now identify the property
                            that you wish to purchase to replace the one that you relinquished,
                            Please be sure to input the contact info for your Qualified Intermediary, and
                            input the progress of your Exchange  by updating the Status dropdown.
                            All changes will be updated in the Status Tab"

  purchase_loi_to_psa = -> "<strong>Congratulations!</strong>  You have found a potential seller for a property
                          property that you wish to purchase to replace the one that you
                          relinquished.  Please fill out the Prospective Seller and use the Document tab to
                          create a compelling competitive Letter of Intent to entice this seller
                          into selling you this valuable property!  If the seller
                          accepts the terms of the LOI, negotiate a Purchase Sale Agreement
                          with the seller and enter its terms into the Terms tab.  Once
                          you are in contract, change Status dropdown to Inspection Period!"

  purchase_inspection_period = -> "Now you are in the process of Replacing your Relinquished Property!  Make sure
                                that you have properly filled out all the Terms of the PSA especially the
                                Date of the Contract and all relevant deadlines as in the payment of
                                required deposits and -- most centrally importantly :<br />
                                                <strong>THE DATE THAT THE INSPECTION PERIOD ENDS</strong>
                                <br />Once that day passes, you can no longer get your money back.  Go to the
                                Documents and Personnel Tabs and start hiring your Due Diligence Professionals.
                                Also make sure that the Seller contacts the Tenant to get an Estoppel Certificate
                                or a waiver of the Right of First Refusal if such a provision exists in the contract."

  purchase_inspection_period_closing = -> 'Well there’s no going back now, at least not without ditching your initial deposit!
                                        Now it’s time to work intensively in the Documents Tab and with your Title Insurance
                                        Company to make sure that you get as a clean a Title Insurance policy as possible.
                                        As soon as you have a Closing Date set with the Seller, fill it out in the Terms Tab and
                                        update the Status Tab to ‘Closing Date Set'

  purchase_closing_date_set = -> 'You are almost there!  To get to this point, you must have filled out the
                                Closing Date in the Terms Tab. Now it’s time to fill out the
                                Closing Statement and get it counter-signed by the other side.
                                Make sure your  QI has the correct wire instructions for your
                                Title Company and the Title Company has the correct wire
                                instructions for the Seller!  Also, as soon as the contract closes, update the Status
                                Tab to Post Closing.'

  try
    # if getJsonFromUrl()['status_alert'] == 'Purchase+Pre+LOI'
    #   purchaser = $(document).find('input#entity_info').val()
    #   sweet_alert_text_success(purchase_pre_loi_text(purchaser))
    # else if getJsonFromUrl()['status_alert'] == 'Purchase+LOI+to+PSA'
    #   sweet_alert_text_success(purchase_loi_to_psa())
    # else if getJsonFromUrl()['status_alert'] == 'Purchase+Inspection+Period'
    #   sweet_alert_text_success(purchase_inspection_period())
    # else if getJsonFromUrl()['status_alert'] == 'Purchase+Inspection+Period+to+Closing'
    #   sweet_alert_text_success(purchase_inspection_period_closing())
    # else if getJsonFromUrl()['status_alert'] == 'Purchase+Closing+Date+Set'
    #   sweet_alert_text_success(purchase_closing_date_set())

  catch


  $(document).on "click", "a.new-transaction", ->
    typewatch ->
      $(document).find("div#TransactionTypeList").show()
    , 10
  
  $(document).on "click", ".main_menu span.manual_delete_property", (e)->
    e.preventDefault()
    elem = $(this)
    actionurl = '/xhr/manual_delete_transaction_property'
    $.ajax
      url: actionurl
      type: 'post'
      dataType: 'html'
      data: {main_id: $(this).data('tran-mainid'), property_id: $(this).data('tran-propid'), type: $(this).data('tran-type')}
      success: (data) ->
        $('#sidebar-menu').html(data)
        # if(data)
        #   elem.parent().parent().remove()
        # $.notify "Success!", "success"
        # else
        #   $.notify "Failed!", "error"
          
# Negotiations Step in Sale Wizard
  # - Offer and Acceptance
  $(document).on 'click', '.nav-tabs #new_offer', (e)->
    e.preventDefault()
    id = $('#offer_list').children().length
    tabId = 'offer_' + id + '_content'
    $(this).closest('li').before '<li><a data-toggle="tab" aria-expanded="true" href="#offer_' + id + '_content">Offer '+ id + ' <span class="fa fa-times"></span></a></li>'
    $('#offer_and_acceptance_section .tab-content').append '<div class="tab-pane" id="' + tabId + '">' + $('#offer_and_acceptance_template').html() + '</div>'
    $('#offer_list li:nth-child(' + id + ') a').click()
    
    initialize_editable_currency_field()
    initialize_editable_date_field()

  $(document).on 'click', '#offer_list li span', (e)->
    anchor = $(this).parent('a')
    $(anchor.attr('href')).remove()
    $(this).parent().parent().remove()
    $("#offer_list li").children('a').first().click()
  # - Taks list
  $(document).on 'ifChanged', '.to_do .field_list .task_status', (e)->
    if this.checked
      $(this).parent().parent().parent().addClass('done')
    else
      $(this).parent().parent().parent().removeClass('done')
  # Enable 2nd Deposit
  $(document).on 'ifChanged', '#enable-2nd-deposit', ->
    if this.checked
      $(this).parents().parent().parent().find('.right .form-control').prop( "disabled", false )
      $(this).parent().siblings('.vertical-line').css({"border-color": "#3082ee"})
    else
      $(this).parent().parent().parent().find('.right .form-control').prop( "disabled", "disabled" )
      $(this).parent().siblings('.vertical-line').css({"border-color": '#777'})

  $(document).on 'click', (e) ->
    container = $("div#TransactionTypeList")
    if (!container.is(e.target) && (container.has(e.target).length == 0))
      container.hide();

  $(document).on 'nested:fieldAdded', (event) ->
    field = event.field
    $(document).find(field.find('.input-mask-currency')).inputmask
      alias: 'currency',
      rightAlign: false,
      prefix: ''

  # Offer and Acceptance Part
  initialize_editable_date_field = ->
    $(document).find('.editable-date').editable
      combodate: { maxYear: 2100, minYear: 2000 } 
  
  initialize_editable_date_field()

  initialize_editable_currency_field = ->
    $(document).find('.editable-currency').editable
      type: 'text',
      tpl: '<input class="input-mask-currency" type="text">'
  
  initialize_editable_currency_field()

  $(document).on "focus", "input.input-mask-currency", ->
    $(this).inputmask
      alias: 'currency',
      rightAlign: false,
      prefix: '$ ',
      removeMaskOnSubmit: true
  
  $(document).on 'click', '#offer_list li a', (e)->
    selected_offer_acceptance_tab = $(document).find($(this).attr('href'))

  $(document).on "click", ".add_client_counteroffer", (e) -> 
    e.preventDefault()
    add_row_html = '<tr>
                      <td width="200"> 
                          <span class="editable-date" data-type="combodate" data-value="" data-format="YYYY-MM-DD" data-viewformat="MM/DD/YYYY"></span>
                      </td>'
    if last_counteroffer                      
      add_row_html += '<td width="400"> 
                           <span>Counter Party\'s Counter</span>
                       </td>'
      $(this).text('Client Counter')
      last_counteroffer = 0
    else
      add_row_html += '<td width="400"> 
                           <span>Client\'s Counter</span>
                       </td>'
      $(this).text('Buyer Counter')
      last_counteroffer = 1

    add_row_html += '<td>  
                          <span class="green editable-currency" data-type="text" data-value=""></span>
                      </td>
                  </tr>'
    selected_offer_acceptance_tab.find('.counteroffer_history tr.last_row').before(add_row_html)
    initialize_editable_currency_field()
    initialize_editable_date_field()
  
  # Click Accept offer 
  $(document).on "click", ".btn_accept_counteroffer", (e) ->
    e.preventDefault()
    location = $(this).attr('href')
    dialog = $(document).find('#accept_counteroffer')
    $.ajax
        type: "get"
        url: location
        dataType: "html"
        success: (val) ->
          dialog.find('.modal-body').html(val)
          dialog.modal()
        error: (e) ->
          console.log e
    
  $(document).on 'ajax:complete', '#accept_counteroffer form', (event, data, status, xhr)->
    console.log status, data, xhr
    if status
      $.notify "Success!", "success"
      selected_offer_acceptance_tab.find('.btn_accept_counteroffer').removeClass('btn-default green border-green')
                                                  .addClass('btn-success')
                                                  .attr('disabled', 'disabled')
                                                  .text('Counter Accepted')
      selected_offer_acceptance_tab.find('.add_client_counteroffer').removeClass('red border-red')
                                                  .attr('disabled', 'disabled')
      
      $('#negotions_tab a#relinquishing_purchaser').click()                                                 
    else
      $.notify "Failed!", "error"


  # Show modal for submenu of top menu
  $(document).on 'click', '.top-header ul li a > span', (e)->
    e.preventDefault()
    if($(this).attr('id') == 'add-client')
      $.ajax
        type: "POST"
        url: "/xhr/entity_type_list"
        dataType: "html"
        success: (val) ->
          $(document).find("#md-add-client .modal-body").html(val);
        error: (e) ->
          console.log e
    
    modal_id = '#md-' + $(this).attr('id')
    $(modal_id).modal()