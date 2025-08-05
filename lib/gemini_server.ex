defmodule GeminiServer do
  use Application

  def start(_type, _args) do
    port = 5000
    IO.puts("Starting server on port #{port}")
    Plug.Cowboy.http(GeminiServer.Router, [], port: port)
  end
end

defmodule GeminiServer.Router do
  use Plug.Router

  plug(CORSPlug, origin: "*")
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: JSON)
  plug(:dispatch)

  post "/prompt" do
    prompt = conn.body_params["prompt"]
    response = GeminiServer.Client.generate_content(prompt)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, JSON.encode!(%{response: response}))
  end
end

defmodule GeminiServer.Client do
  @base_url "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
  @external_resource "system_prompt.md"
  @system_prompt File.read!("system_prompt.md")

  def generate_content(prompt) do
    api_key = System.get_env("GEMINI_API_KEY")

    headers = [
      {"Content-Type", "application/json"},
      {"X-goog-api-key", api_key}
    ]

    body = %{
      system_instruction: %{
        parts: [
          %{text: @system_prompt}
        ]
      },
      contents: [
        %{
          parts: [
            %{text: prompt}
          ]
        }
      ]
    }

    {:ok, response} =
      HTTPoison.post(@base_url, JSON.encode!(body), headers, recv_timeout: 1000_000)

    {:ok, parsed} = JSON.decode(response.body)

    parsed["candidates"]
    |> List.first()
    |> get_in(["content", "parts"])
    |> List.first()
    |> Map.get("text")
  end

  def clean_json(json_string) do
    Regex.replace(
      ~r/"text":\s*"(.*?)```glsl\\n(.*?)\\n```(.*?)"/s,
      json_string,
      fn _, before, code, rest ->
        cleaned_code =
          code
          |> String.replace("\\", "\\\\")
          |> String.replace("\"", "\\\"")

        "\"text\": \"#{before}#{cleaned_code}#{rest}\""
      end
    )
  end
end
