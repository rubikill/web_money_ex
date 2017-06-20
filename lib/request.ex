defmodule WebMoney.Request do
  alias WebMoney.Security

  @sandbox_api "https://apimerchant.webmoney.com.vn/sandbox"
  @prod_api "https://apimerchant.webmoney.com.vn/payment"

  @default_headers [
    {"Content-type", "application/json"},
    {"Authorization", Application.get_env(:web_money, :passcode)},
    {"X-Forwarded-Host", Application.get_env(:web_money, :host) || ""},
    {"X-Forwarded-For", Application.get_env(:web_money, :ip) || ""}
  ]

  defp process_url(endpoint) do
    if Application.get_env(:web_money, :mode) == "prod" do
      @prod_api <> endpoint
    else
      @sandbox_api <> endpoint
    end
  end

  @doc """
  %{
    "redirectURL" => "https://payment.webmoney.com.vn/WMVWsandbox?hashString=xy06zhiyd8spkAgVzNUGUWHdH_Yk5Sf0leaFOWp6Cz7pu1K1llEn8isVdnk7OpeK",
    "transactionID" => "32051"
  }
  """
  defp handle_response(%{"errorCode" => "0", "object" => object}) do
    {:ok, object}
  end

  defp handle_response(%{"errorCode" => status_code, "uiMessage" => ui_message}) do
    {:error, ui_message}
  end

  defp get(endpoint, headers) do
    HTTPoison.get process_url(endpoint), headers
  end

  defp post(endpoint, headers, body) do
    HTTPoison.post process_url(endpoint), Poison.encode!(body), headers
  end

  @doc """
  WebMoney.view_order "http://localhost:5000/checkout", [
    "mTransactionID": "1495443174100"
  ]
  """
  def view_order(current_url, body) do
    checksum = body
    |> Security.join_hash_text
    |> Security.hash_checksum

    headers = @default_headers ++ [{"Referer", current_url}]

    body = body ++ [checksum: checksum]
    |> Enum.into(%{})

    case post("/view-order", headers, body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response}} ->
        # Something looks like this
        # {:ok, %{
        #   "custAddress" => "Ho Chi Minh City",
        #   "custEmail" => "merchant@example.com",
        #   "custGender" => "M",
        #   "custName" => "Nguyen Van A",
        #   "custPhone" => "012345678",
        #   "description" => "Webmoney-transactionID: 1495443174100 - Ten khach hang: Nguyen Van A - Email: merchant@example.com - So dien thoai: 012345678 - Tong gia tri: 100",
        #   "invoiceID" => "",
        #   "status" => "WM_WAITING",
        #   "totalAmount" => 100,
        #   "transactionID" => "32049"
        #   }
        # }
        response
        |> Poison.decode!
        |> handle_response
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  WebMoney.create_order "http://localhost:5000/checkout", [
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
  """
  def create_order(current_url, body) do
    checksum = body
    |> Security.join_hash_text
    |> Security.hash_checksum

    headers = @default_headers ++ [{"Referer", current_url}]

    body = body ++ [checksum: checksum]
    |> Enum.into(%{})

    case post("/create-order", headers, body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response}} ->
        # Some things like this
        # {:ok, %{
        #   "redirectURL" => "https://payment.webmoney.com.vn/WMVWsandbox?hashString=MZ3IfgKyi5ESp8vx5HPbjtgMCmi5nrh1yYddDr5qNtRN2Yopn6YuKZkdHYT1OW3r",
        #    "transactionID" => "32052"
        #    }
        #  }
        response
        |> Poison.decode!
        |> handle_response
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
