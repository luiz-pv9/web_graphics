defmodule Square do
  use WebGraphics.SVG.Element

  tag :rect do
    attr_alias :w, :width
    attr_alias :h, :height

    attr_handler :size do
      [w: value, h: value]
    end
  end
end

defmodule WebGraphics.SVG.Element.RenderTest do
  use ExUnit.Case, async: true
  use WebGraphics.SVG.ElementBuilder

  test "renders an element without attributes" do
    html = Square.elm |> render()
    assert "<rect />" == html
  end

  test "renders an element with a single attribute" do
    html = Square.elm(hey: "there") |> render()
    assert "<rect hey=\"there\" />" == html
  end

  test "renders an element with multiple attributes" do
    html = Square.elm(f: 10, g: 20) |> render()
    assert "<rect f=\"10\" g=\"20\" />" == html
  end

  test "renders an element with attribute with multiple values" do
    html = Square.elm |> style(f: 10, g: 20) |> render()
    assert "<rect style=\"f=10; g=20;\" />" == html
  end
  
  test "renders an element from attributes with handler" do
    html = Square.elm(size: 10) |> render()
    assert "<rect height=\"10\" width=\"10\" />" == html
  end

  # Although is not valid to have a <rect> with a body, this is just
  # for testing purposes.
  
  test "renders an element with a function body" do
    html = Square.elm |> render_with(fn _ -> "hello" end)
    assert "<rect>hello</rect>" == html
  end

  test "renders an element with a string body" do
    html = Square.elm |> render_with("hello")
    assert "<rect>hello</rect>" == html
  end

  test "renders an element inside another element" do
    html = Square.elm
      |> render_with(fn _p ->
        Square.elm |> render()
      end)
    assert "<rect><rect /></rect>" == html
  end

  test "renders an element with attributes from the parent" do
    html = Square.elm(width: 10) |> render_with(fn p ->
      Square.elm(width: p.width + 2) |> render()
    end)
    assert "<rect width=\"10\"><rect width=\"12\" /></rect>" == html
  end
end
