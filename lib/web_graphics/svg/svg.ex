defmodule WebGraphics.SVG.SVG do
  @moduledoc """
  The SVG element is the parent wrapper for all 
  """

  use WebGraphics.SVG.Element

  tag :svg do
    default_attrs %{
      "version" => "1.1",
      "baseProfile" => "full",
      "xmlns" => "http://www.w3.org/2000/svg"
    }

    attr_alias :w, :width
    attr_alias :h, :height
  end
end
