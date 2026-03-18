class ApplicationController < ActionController::Base
  include AsyncRequestManager
  include ExceptionHandler
  include ParamsHandler
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def render_error(identifier, message: nil, meta: nil, status: :bad_request)
    resolved_message =
      message.presence ||
      I18n.t("errors.messages.#{identifier}", default: identifier.to_s)

    error = { message: resolved_message, identifier: identifier.to_s }
    error[:meta] = meta if meta.present?

    render json: { errors: [error] }, status: status
  end

  def utility_code_header
    @utility_code_header ||= request.headers['Utility-ID']
  end

  def utility
    raise ActionController::ParameterMissing, 'Utility-ID header' if utility_code_header.nil?
    utility_code = sanitized_utility_code(utility_code_header)
    @utility ||= Utility.find_by!(code: utility_code)
  end

  def sanitized_utility_code(utility_code_header)
    Integer(utility_code_header)
  rescue ArgumentError
    nil
  end

  def validation_error(resource)
    details = resource.errors.details

    blank_fields =
      details.select { |_attr, errs| errs.any? { |e| e[:error] == :blank } }.keys.map(&:to_s)

    if blank_fields.any?
      return render_error(
        :missing_required_fields,
        message: "Missing required fields: #{blank_fields.join(', ')}",
        meta: { fields: blank_fields },
        status: :bad_request
      )
    end

    if details[:note_type]&.any? { |e| e[:error] == :inclusion }
      return render_error(
        :invalid_note_type,
        message: 'El tipo de nota no es válido',
        meta: { allowed: Note.note_types.keys },
        status: :unprocessable_entity
      )
    end

    if resource.errors[:content].any? { |msg| msg.to_s.include?('words long or less') }
      limit = resource.book.utility.short_note_length
      return render_error(
        :content_too_long,
        message: "Una reseña no puede superar las #{limit} palabras",
        status: :unprocessable_entity
      )
    end

    render_error(
      :unprocessable_entity,
      message: resource.errors.full_messages.first || 'Validation failed',
      status: :unprocessable_entity
    )
  end

  def render_resource(resource)
    resource.errors.empty? ? resource_created(resource) : validation_error(resource)
  end

  def resource_created(resource)
    render json: resource, status: :created
  end

  def access_denied(exception)
    reset_session
    redirect_to '/admin/login', alert: exception.message
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name document_number])
  end
end
