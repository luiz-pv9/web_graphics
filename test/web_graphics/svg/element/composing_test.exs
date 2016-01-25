defmodule Circle do
  use WebGraphics.SVG.Element

  tag :circle do
  end
end

defmodule WebGraphics.SVG.Element.ComposingTest do
  use ExUnit.Case, async: true
end
