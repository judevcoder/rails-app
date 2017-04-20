require 'base64'

module ApplicationHelper

  def extract_emails string
    string.try(:scan, /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)
  end

  def current_FULLPATH
    request.original_fullpath
  end

  def base64_encode t
    Base64.strict_encode64(t)
  end

  def title(page_title = '1031 Exchange', options={})
    content_for(:title, page_title.to_s)
    content_tag(:h1, page_title, options)
  end

  def image_via_mimetype(mimetype)
    if mimetype.include?('pdf')
      'pdf.png'
    elsif mimetype.include?('doc')
      'doc.png'
    elsif mimetype.include?('docx')
      'docx.png';
    elsif mimetype.include?('wpd')
      'wpd.png';
    elsif mimetype.include?('xls')
      'xls.png';
    elsif mimetype.include?('ppt')
      'ppt.png';
    elsif mimetype.include?('image')
      'image-file.png'
    else
      'other.png'
    end
  end

  def xs_default
    "btn btn-default btn-xs buttons-margin"
  end

  def show_xs
    "btn btn-default btn-xs btn-primary buttons-margin"
  end

  def edit_xs
    "btn btn-default btn-xs btn-warning buttons-margin"
  end

  def delete_xs
    "btn btn-default btn-xs btn-danger buttons-margin"
  end

  def sumup_values val1, val2
    (val1 || 0) + (val2 || 0) rescue 0
  end

  def minp_values val1, val2
    (val1 || 0) - (val2 || 0) rescue 0
  end

  def override_active_record_errors(errors_hash, replace_keys = {})
    keys_with_order, new_h, messages = errors_hash.keys, {}, []
    replace_keys.each do |old_key, new_key|
      if keys_with_order.include? old_key
        errors_hash[new_key] = errors_hash.delete(old_key)
        keys_with_order.collect! { |k|
          if k == old_key
            k = new_key
          else
            k = k
          end
        }
      end
    end
    keys_with_order.each { |k| new_h[k] = errors_hash[k] }
    new_h.each { |k, v|
      if k.class == Symbol
        messages << "#{k.to_s.humanize.strip} #{v[0].to_s.strip}"
      else
        messages << "#{k.to_s.gsub("_", " ").strip} #{v[0].to_s.strip}"
      end
    }
    messages
  end

  def require_field
    '<span style="color: red; padding-left: 5px">*</span>'.html_safe
  end

  def remove_from_errors
    []
  end

  def transaction_message_filter(message)
    if message.include?('Purchase only closing date ')
      message.gsub('Purchase only closing date ', '')
    elsif message.include?('Purchase only qi funds ')
      message.gsub('Purchase only qi funds ', '')
    elsif message.include?('Purchaser entity ')
      message.gsub('Purchaser entity ', '')
    elsif message.include?('Seller entity ')
      message.gsub('Seller entity ', '')
    elsif message.include?('Seller first name Relinquishing ')
      message.sub('Seller first name ', '')
    elsif message.include?('Seller last name Relinquishing ')
      message.sub('Seller last name ', '')
    elsif message.include?('Purchaser first name Relinquishing ')
      message.sub('Purchaser first name ', '')
    elsif message.include?('Purchaser last name Relinquishing ')
      message.sub('Purchaser last name ', '')
    elsif message.include?('Seller first name Replacement ')
      message.sub('Seller first name ', '')
    elsif message.include?('Seller last name Replacement ')
      message.sub('Seller last name ', '')
    elsif message.include?('Purchaser first name Replacement ')
      message.sub('Purchaser first name ', '')
    elsif message.include?('Purchaser last name Replacement ')
      message.sub('Purchaser last name ', '')
    else
      message
    end
  end

  def gsub_error_message(message, gsubs=[])
    done = false
    until done do
      done = true if gsubs.blank?
      gsubs.each do |g|
        if message.include?(g)
          message.gsub!(g, '')
          done = true
        end
      end
    end
    message
  end

  def modify_query(url, options={})
    uri        = URI(url)
    query_hash = Rack::Utils.parse_query(uri.query)
    query_hash.merge!(options.stringify_keys)
    uri.query = Rack::Utils.build_query(query_hash)
    uri.to_s
  end

  def display_standard_table(resource_klass, collection = {}, options={})

    columns = (resource_klass.view_index_columns.collect { |t| t[:show] }.flatten + ['Action'])

    thead = content_tag :thead do
      content_tag :tr do
        columns.collect { |column| content_tag(:th, column) }.join().html_safe
      end
    end

    tbody = content_tag :tbody do
      collection.collect { |elem|
        content_tag :tr do
          (resource_klass.view_index_columns.collect { |column|
            content_tag(:td, (column[:eval] ? eval(column[:eval]) : elem.send(column[:call])))
          } + [content_tag(:td, (link_to 'Delete', elem.delete_url, class: 'btn btn-sm btn-danger margin-sm-left', method: :delete, data: { confirm: 'Are you sure ?' }))
          ]).join().html_safe
        end
      }.join().html_safe
    end

    content_tag :table, id: options[:table_id] do
      thead.concat(tbody)
    end
  end

  def owned_by(entity)
    case entity.entity_type.try(:name)
      when "LLC"
        entity.members.map { |m| ["#{m.name} - #{m.my_percentage}", m.entity.present? ? edit_entity_path(m.entity.key) : "#"] }
      when "LLP"
        entity.limited_partners.map { |m| ["#{m.name} - #{m.my_percentage}", m.entity.present? ? edit_entity_path(m.entity.key) : "#"] }
      when "Sole Proprietorship"
        [[entity.full_name, '#']]
      when "Power of Attorney"
        [[entity.full_name, '#']]
      when "Guardianship"
        [[entity.full_name, '#']]
      when "Trust"
        entity.beneficiaries.map { |m| ["#{m.name} - #{m.my_percentage}", m.entity.present? ? edit_entity_path(m.entity.key) : "#"] }
      when "Joint Tenancy with Rights of Survivorship (JTWROS)"
        [[]]
      when "Limited Partnership"
        entity.general_partners.map { |m| ["#{m.name} - #{m.my_percentage}", m.entity.present? ? edit_entity_path(m.entity.key) : "#"] } + entity.limited_partners.map { |m| ["#{m.name} - #{m.my_percentage}", m.entity.present? ? edit_entity_path(m.entity.key) : "#"] }
      when "Tenancy in Common"
        [[]]
      when "Corporation"
        entity.stockholders.map { |m| ["#{m.name} - #{m.percentage_of_ownership}", m.entity.present? ? edit_entity_path(m.entity.key) : "#"] }
      when "Partnership"
        entity.partners.map { |m| ["#{m.name} - #{m.my_percentage}", m.entity.present? ? edit_entity_path(m.entity.key) : "#"] }
      when "Tenancy by the Entirety"
        [[]]
      else
        [["", "#"]]
    end
  end

  def owns(entity)
    result = []

    if m = Member.find_by_entity_id(entity.id)
      e = m.super_entity
      result.push ["#{e.name} - #{m.my_percentage}", edit_entity_path(e.key)] unless e.nil?
    end

    if m = LimitedPartner.find_by_entity_id(entity.id)
      e = m.super_entity
      result.push ["#{e.name} - #{m.my_percentage}", edit_entity_path(e.key)] unless e.nil?
    end

    if m = Beneficiary.find_by_entity_id(entity.id)
      e = m.super_entity
      result.push ["#{e.name} - #{m.my_percentage}", edit_entity_path(e.key)] unless e.nil?
    end

    if m = GeneralPartner.find_by_entity_id(entity.id)
      e = m.super_entity
      result.push ["#{e.name} - #{m.my_percentage}", edit_entity_path(e.key)] unless e.nil?
    end

    if m = StockHolder.find_by_entity_id(entity.id)
      e = m.super_entity
      result.push ["#{e.name} - #{m.percentage_of_ownership}", edit_entity_path(e.key)] unless e.nil?
    end

    if m = Partner.find_by_entity_id(entity.id)
      e = m.super_entity
      result.push ["#{e.name} - #{m.my_percentage}", edit_entity_path(e.key)] unless e.nil?
    end

    return result
  end

  def first_name_of_entity(entity)
    case entity.entity_type.try(:name)
      when "LLC"
        entity.first_name
      when "LLP"
        entity.first_name
      when "Sole Proprietorship"
        entity.first_name
      when "Power of Attorney"
        entity.first_name2
      when "Guardianship"
        entity.guardian_first_name
      when "Trust"
        entity.first_name
      when "Joint Tenancy with Rights of Survivorship (JTWROS)"
        ""
      when "Limited Partnership"
        entity.first_name
      when "Tenancy in Common"
        ""
      when "Corporation"
        entity.first_name
      when "Partnership"
        entity.first_name
      when "Tenancy by the Entirety"
        ""
      when "Individual"
        entity.first_name
      else
        ""
    end
  end

  def last_name_of_entity(entity)
    case entity.entity_type.try(:name)
      when "LLC"
        entity.last_name
      when "LLP"
        entity.last_name
      when "Sole Proprietorship"
        entity.last_name
      when "Power of Attorney"
        entity.last_name2
      when "Guardianship"
        entity.guardian_last_name
      when "Trust"
        entity.last_name
      when "Joint Tenancy with Rights of Survivorship (JTWROS)"
        ""
      when "Limited Partnership"
        entity.last_name
      when "Tenancy in Common"
        ""
      when "Corporation"
        entity.last_name
      when "Partnership"
        entity.last_name
      when "Tenancy by the Entirety"
        ""
      when "Individual"
        entity.last_name
      else
        ""
    end
  end

  def client_entity(entity)
    case entity.entity_type.try(:name)
      when "Individual"
        entity.name
      when "LLC"
        entity.name
      when "LLP"
        entity.name
      when "Sole Proprietorship"
        entity.name2
      when "Power of Attorney"
        "#{entity.first_name2} #{entity.last_name2} POA for #{entity.first_name} #{entity.last_name}"
      when "Guardianship"
        "In re #{entity.full_name}, AIP"
      when "Trust"
        entity.name
      when "Joint Tenancy with Rights of Survivorship (JTWROS)"
        ""
      when "Limited Partnership"
        entity.name
      when "Tenancy in Common"
        ""
      when "Corporation"
        entity.name
      when "Partnership"
        entity.name
      when "Tenancy by the Entirety"
        ""
      else
        ""
    end
  end

  def options_html(type, is_person, super_entity)
    if type == "stockholder"
      if is_person == "true"
        result = "<option></option><optgroup label='Client Individuals'>"

        current_user.entities_list.where.not(id: super_entity).order(name: :asc).where(type_: [1, 2, 3, 4]).each do |entity|
          result += "<option value=#{entity.id} data-type='entity'>#{entity.name}</option>"
        end

        result += "</optgroup><optgroup label='Contact Individuals'>"

        Contact.all.where(is_company: true, contact_type: 'Client Participant', role: 'Corporate Stockholder').each do |contact|
          result += "<option value=#{contact.id} data-type='contact'>#{contact.name}</option>"
        end

        result += "</optgroup>"
        return result.html_safe
      else
        result = "<option></option><optgroup label='Client Entities'>"

        #Should exclude Individual, Tenancy in Common, Tenancy by the Entirety & Joint Tenancy
        current_user.entities_list.where.not(id: super_entity).order(name: :asc).where.not(type_: [1, 7, 8, 9]).each do |entity|
          result += "<option value=#{entity.id} data-type='entity'>#{entity.name}</option>"
        end

        result += "</optgroup><optgroup label='Contact Companies'>"

        Contact.all.where(is_company: true, contact_type: 'Client Participant', role: 'Corporate Stockholder').each do |contact|
          result += "<option value=#{contact.id} data-type='contact'>#{contact.name}</option>"
        end

        result += "</optgroup>"
        return result.html_safe
      end
    end
  end
end
