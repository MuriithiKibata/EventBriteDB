require 'base64'
require 'rest-client'

class MpesaService
  class MpesaError < StandardError; end

  def initialize(phone_number:, amount:)
    @phone_number = phone_number
    @amount = amount
    @business_short_code = ENV["MPESA_SHORTCODE"]
    @passkey = ENV["MPESA_PASSKEY"]
    @callback_url = "#{ENV["CALLBACK_URL"]}/callback_url"
  end

  def stkpush
    payload = generate_payload
    headers = {
      Content_type: 'application/json',
      Authorization: "Bearer #{get_access_token}"
    }

    response = RestClient::Request.execute(
      method: :post,
      url: stk_push_url,
      payload: payload,
      headers: headers
    ) do |response, _request|
      handle_response(response)
    end

    response
  rescue StandardError => e
    raise MpesaError, "STK Push failed: #{e.message}"
  end

  private

  def generate_payload
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    password = Base64.strict_encode64("#{@business_short_code}#{@passkey}#{timestamp}")

    {
      'BusinessShortCode': @business_short_code,
      'Password': password,
      'Timestamp': timestamp,
      'TransactionType': "CustomerPayBillOnline",
      'Amount': @amount,
      'PartyA': @phone_number,
      'PartyB': @business_short_code,
      'PhoneNumber': @phone_number,
      'CallBackURL': @callback_url,
      'AccountReference': 'Codearn',
      'TransactionDesc': "Payment for Codearn premium"
    }.to_json
  end

  def stk_push_url
    "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
  end

  def get_access_token
    response = generate_access_token_request
    if response.code != 200
      raise MpesaError, 'Unable to generate access token'
    end

    body = JSON.parse(response.body, symbolize_names: true)
    body[:access_token]
  end

  def generate_access_token_request
    url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
    userpass = Base64.strict_encode64("#{ENV['MPESA_CONSUMER_KEY']}:#{ENV['MPESA_CONSUMER_SECRET']}")

    RestClient::Request.execute(
      url: url,
      method: :get,
      headers: { Authorization: "Basic #{userpass}" }
    )
  end

  def handle_response(response)
    case response.code
    when 500, 400
      { status: :error, body: JSON.parse(response.body) }
    when 200
      { status: :success, body: JSON.parse(response.body) }
    else
      raise MpesaError, "Unexpected response: #{response.body}"
    end
  end
end