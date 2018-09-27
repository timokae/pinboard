defmodule Pinboard.Email do
  import Bamboo.Email

  def test_mail(email, list) do
    new_email(
      from: "no-reply@pinboard.com",
      to: email,
      subject: "Test Email",
      text_body: generate_text(list),
      html_body: generate_html(list)
    )
  end

  defp generate_text([head|tail]) do
    text = """
      #{head.date} #{head.name}
      #{head.content}
      \n
      \n
    """
    text <> generate_text(tail)
  end
  defp generate_text([]), do: ""

  defp generate_html([head|tail]) do
    text = """
    <h3><strong>#{head.date}</strong> - <a href="#{head.href}">#{head.name}</a></h3>
    <p>#{head.content}</p>
    <br>
    <br>
    """

    text <> generate_html(tail)
  end
  defp generate_html([]), do: ""

end
