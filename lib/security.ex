defmodule WebMoney.Security do
  @doc """
  Join all properties values from model as string
  """
  def join_hash_text(array) do
    s = Enum.reduce array, "", fn {k, v}, acc ->
      acc <> to_string(v)
    end

    s <> Application.get_env(:web_money, :merchant_code) <> Application.get_env(:web_money, :passcode)
  end

  @doc """
  Hash checksum from string, with secret key as salt
  Concatenates all property, except checksum, then uses hash_hmac with secret key
  """
  def hash_checksum(data_raw) do
    # IO.inspect "data_raw before hash"
    # IO.inspect data_raw
    :crypto.hmac(:sha, Application.get_env(:web_money, :secret_key), data_raw)
    |> Base.encode16
    |> String.Casing.upcase
  end

  @doc """
    Validates checksum
  """
  def validate_checksum(checksum, data_raw) do
    checksum == hash_checksum(data_raw)
  end
end
