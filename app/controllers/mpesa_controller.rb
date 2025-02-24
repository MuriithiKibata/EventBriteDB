class MpesaController < ApplicationController
    require 'base64'
    require 'rest-client'
    require 'json'
    


def stkpush
    Rails.logger.info "Received phone number: #{params[:phoneNumber]}"
    ticket = Ticket.find_by(phone_number: params[:phoneNumber], payment_status: false)
    puts ticket.phone_number
    # I'm trying to check if the ticket already exists or is nil
    if ticket.nil?
        Rails.logger.warn "No ticket found for phone number: #{params[:phoneNumber]}"
        render json: { error: "No ticket found for the provided phone number" }, status: :not_found
        return
    end

    # Proceed to get the total
    total_amount = ticket.price * ticket.quantity

    phoneNumber = ticket.phone_number
    amount = total_amount
    url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
    timestamp = "#{Time.now.strftime "%Y%m%d%H%M%S"}"
    business_short_code = ENV["MPESA_SHORTCODE"]
    password = Base64.strict_encode64("#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}")
    payload = {
    'BusinessShortCode': business_short_code,
    'Password': password,
    'Timestamp': timestamp,
    'TransactionType': "CustomerPayBillOnline",
    'Amount': amount,
    'PartyA': phoneNumber,
    'PartyB': business_short_code,
    'PhoneNumber': phoneNumber,
    'CallBackURL': "#{ENV["CALLBACK_URL"]}/callback_url",
    'AccountReference': 'HalalEventBrite',
    'TransactionDesc': "Payment for Codearn premium"
    }.to_json

    headers = {
    Content_type: 'application/json',
    Authorization: "Bearer #{get_access_token}"
    }

    response = RestClient::Request.new({
    method: :post,
    url: url,
    payload: payload,
    headers: headers
    }).execute do |response, request|
    case response.code
    when 500
    [ :error, JSON.parse(response.to_str) ]
    when 400
    [ :error, JSON.parse(response.to_str) ]
    when 200
    [ :success, JSON.parse(response.to_str) ]
    else
    fail "Invalid response #{response.to_str} received."
    end
    end
    render json: response
end


def stkquery
    url = "https://sandbox.safaricom.co.ke/mpesa/stkpushquery/v1/query"
    timestamp = "#{Time.now.strftime "%Y%m%d%H%M%S"}"
    business_short_code = ENV["MPESA_SHORTCODE"]
    password = Base64.strict_encode64("#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}")
    payload = {
    'BusinessShortCode': business_short_code,
    'Password': password,
    'Timestamp': timestamp,
    'CheckoutRequestID': params[:checkoutRequestID]
    }.to_json

    headers = {
    Content_type: 'application/json',
    Authorization: "Bearer #{ get_access_token }"
    }

    response = RestClient::Request.new({
    method: :post,
    url: url,
    payload: payload,
    headers: headers
    }).execute do |response, request|
    case response.code
    when 500
    [ :error, JSON.parse(response.to_str) ]
    when 400
    [ :error, JSON.parse(response.to_str) ]
    when 200
    [ :success, JSON.parse(response.to_str) ]
    else
    fail "Invalid response #{response.to_str} received."
    end
    end
    render json: response
end

private

def generate_access_token_request
    @url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
    @consumer_key = ENV['MPESA_CONSUMER_KEY']
    @consumer_secret = ENV['MPESA_CONSUMER_SECRET']
    @userpass = Base64::strict_encode64("#{@consumer_key}:#{@consumer_secret}")
    headers = {
        Authorization: "Bearer #{@userpass}"
    }
    res = RestClient::Request.execute(url: @url, method: :get, headers:{Authorization: "Basic #{@userpass}"})
    res
end

def get_access_token
    res = generate_access_token_request()
    if res.code != 200
        r = generate_access_token_request()
        if res.code != 200
            raise MpesaError('Unable to generate access token')
        end
    end
    body = JSON.parse(res, {symbolize_names: true})
    token = body[:access_token]
    return token
end
end