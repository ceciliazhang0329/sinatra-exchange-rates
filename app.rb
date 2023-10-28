require 'sinatra'
require 'sinatra/reloader' if development?
require 'http'
require 'json'

helpers do
  def fetch_api_data(endpoint, params = {})
    api_url = "https://api.exchangerate.host/#{endpoint}?access_key=#{ENV['EXCHANGE_RATE_KEY']}"
    params.each { |key, value| api_url += "&#{key}=#{value}" }
    response = HTTP.get(api_url)
    JSON.parse(response.to_s)
  end
end

get('/') do
  data = fetch_api_data('list')
  @symbols = data['currencies']
  erb(:homepage)
end

get('/:from_currency') do
  @original_currency = params['from_currency']
  data = fetch_api_data('list')
  @symbols = data['currencies']
  erb(:currency)
end

get('/:from_currency/:to_currency') do
  @original_currency = params['from_currency']
  @destination_currency = params['to_currency']

  if @original_currency == @destination_currency
    @conversion_rate = 1
  else
    data = fetch_api_data('live', source: @original_currency, currencies: @destination_currency)
    quote_key = "#{@original_currency}#{@destination_currency}"
    @conversion_rate = data['quotes'].fetch(quote_key, nil)
  end
  
  erb(:conversion)
end
