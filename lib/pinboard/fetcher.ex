defmodule Pinboard.Fetcher do

  def token do
    login_url       = "https://meinebo.hochschule-bochum.de/login.html"
    user            = System.get_env("USER") |> URI.encode_www_form
    password        = System.get_env("PASSWORD") |> URI.encode_www_form
    login_parameter = "?logintype=login&pass=#{password}&pid=59&redirect_url=&submit=Anmelden&user=#{user}"

    {:ok, response} = HTTPoison.post(
      login_url <> login_parameter,
      [],
      %{"Content-Type" => "application/x-www-form-urlencoded"}
    )

    response
    |> Map.get(:headers)
    |> Enum.into(%{})
    |> Map.get("Set-Cookie")
  end

  def fetch(token) do
    url = "https://meinebo.hochschule-bochum.de/intern/pinnwand.html"
    headers = [ "Cookie": token ]

    {:ok, response} = HTTPoison.get(url, headers)

    response
    |> Map.get(:body)
  end

end
