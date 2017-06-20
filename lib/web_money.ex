defmodule WebMoney do
  alias WebMoney.Request

  def view_order(current_url, body) do
    Request.view_order(current_url, body)
  end
  def create_order(current_url, body) do
    Request.create_order(current_url, body)
  end
end
