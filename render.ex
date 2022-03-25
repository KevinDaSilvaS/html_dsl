defmodule Template2 do
  import Html
  def render do
    markup do
      html do
        body do
          table [id: "oi", class: "abc"] do
            tr do
              for id <- 1..10 do
                td do: text(id)
              end
            end
          end
          div do
            text("Nested Content")
          end
        end
        style do
          text(".abc {
            background-color: blue;
          }")
        end
      end
    end
  end
end
