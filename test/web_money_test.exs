defmodule WebMoneyTest do
  use ExUnit.Case
  doctest WebMoney

  test "create_order" do
    {status_code, response} = WebMoney.create_order "http://localhost:5000", [
      "mTransactionID": "1495443174100",
      "totalAmount": "1",
      "custName": "Nguyen Van A",
      "custAddress": "Ho Chi Minh City",
      "custGender": "M",
      "custEmail": "merchant@example.com",
      "custPhone": "012345678",
      "resultURL": "http:\/\/localhost\/success.php",
      "description": "Mua hàng tại merchant ABC",
      "clientIP": "::1",
      "userAgent": "Mozilla\/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/58.0.3029.110 Safari\/537.36"
    ]
    assert status_code == :ok
    assert is_map(response)
  end

  test "view_order" do
    {status_code, response} = WebMoney.create_order "http://localhost:5000", [
      "mTransactionID": "1495443174100",
      "totalAmount": "1",
      "custName": "Nguyen Van A",
      "custAddress": "Ho Chi Minh City",
      "custGender": "M",
      "custEmail": "merchant@example.com",
      "custPhone": "012345678",
      "resultURL": "http:\/\/localhost\/success.php",
      "description": "Mua hàng tại merchant ABC",
      "clientIP": "::1",
      "userAgent": "Mozilla\/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/58.0.3029.110 Safari\/537.36"
    ]
    assert status_code == :ok
    assert is_map(response)

    {view_order_status_code, view_order_response} = WebMoney.view_order "http://localhost:5000/checkout", [
      "mTransactionID": "1495443174100"
    ]

    assert view_order_status_code == :ok
    assert is_map(view_order_response)
  end
end
