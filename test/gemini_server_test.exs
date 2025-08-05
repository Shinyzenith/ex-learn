defmodule GLSLValidator do
  @validator "glslangValidator"

  def validate(code, shader_type \\ :frag) do
    ext =
      case shader_type do
        :frag -> "frag"
        :vert -> "vert"
        _ -> raise "Unknown shader type"
      end

    path = Path.join(System.tmp_dir!(), "test_shader.#{ext}")
    File.write!(path, code)

    {output, status} =
      System.cmd(@validator, ["-S", Atom.to_string(shader_type), path], stderr_to_stdout: true)

    if status == 0 do
      :ok
    else
      {:error, output}
    end
  end
end

defmodule GeminiServerTest do
  use ExUnit.Case

  defp strip_code_block(str) do
    Regex.replace(~r/^```glsl\s*([\s\S]*?)\s*```$/, str, "\\1")
  end

  test "Generated GLSL from Gemini" do
    glsl_code = GeminiServer.Client.generate_content("Swirling fire")

    res =
      glsl_code
      |> strip_code_block()

    IO.puts(res)

    case GLSLValidator.validate(res) do
      :ok ->
        assert true

      {:error, reason} ->
        flunk("GLSL compilation failed:\n#{reason}")
    end
  end
end
