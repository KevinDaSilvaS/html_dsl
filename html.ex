defmodule Html do

  @external_resource tags_path = Path.join([__DIR__, "tags.txt"])
  @tags (for line <- File.stream!(tags_path, [], :line) do
    line |> String.trim() |> String.to_atom()
  end)

  for tag <- @tags do
    defmacro unquote(tag)(args \\ [], do: inner) do
      tag = unquote(tag)
      quote do
        tag(unquote(tag), unquote(args), do: unquote(inner))
      end
    end
  end

  defmacro markup(do: block) do
    quote do
      import Kernel, except: [div: 2]
      {:ok, var!(buffer, Html)} = start_buffer []
      unquote block
      result = render var!(buffer, Html)
      :ok = stop_buffer var!(buffer, Html)
      result
    end
  end

  @spec start_buffer(any) :: {:error, any} | {:ok, pid}
  def start_buffer(state), do: Agent.start_link(fn -> state end)

  def stop_buffer(buff), do: Agent.stop(buff)

  def put_buffer(buff, content), do: Agent.update(buff, &([content | &1]))

  def render(buff), do: Agent.get(buff, &(&1) |> Enum.reverse() |> Enum.join())

  defmacro tag(name, args \\ [], do: inner) do
    quote do
      put_buffer var!(buffer, Html), "<#{unquote(name)} #{parse_args(unquote(args))}>"
      unquote(inner)
      put_buffer var!(buffer, Html), "</#{unquote(name)}>"
    end
  end

  def parse_args(args) do
    Enum.map(args, fn {attr, value} -> "#{attr}=\"#{value}\""end)
    |> Enum.reduce("", fn acc, v -> "#{acc} #{v}" end)
  end
  defmacro text(string) do
    quote do: put_buffer(var!(buffer, Html), to_string(unquote(string)))
  end
end
