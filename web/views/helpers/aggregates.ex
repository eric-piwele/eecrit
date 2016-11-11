defmodule Eecrit.Helpers.Aggregates do
  use Eecrit.Helpers.Tags

  def ul_list(class, do: items) do
    ul class: class do
      Enum.map items, &li/1
    end
  end

end
