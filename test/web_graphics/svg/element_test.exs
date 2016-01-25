defmodule Sample do
  use WebGraphics.SVG.Element

  tag :rect do
    attr_alias :foo, :bar

    default_attrs my_default: "web"

    attr_handler :size do
      [width: value, height: value]
    end

    attr_handler :foo_plus_two do
      [foo: value + 2]
    end
  end
end

defmodule WebGraphics.SVG.ElementTest do
  use ExUnit.Case, async: true
  import WebGraphics.SVG.ElementBuilder

  test "has the module in the elm map" do
    assert %{_module: Sample} = Sample.elm
  end

  test "has attributes specified in `default_attrs`" do
    assert %{my_default: "web"} = Sample.elm
  end

  test "has all atributes specified in the elm function" do
    data = Sample.elm x: 10, y: 20
    assert %{x: 10, y: 20} = data
  end

  test "adds attributes with the `attr` function" do
    data = Sample.elm(x: 10, y: 20) |> attr(:custom, 30)
    assert data.custom == 30
   end

   test "adds attributes with multiple calls to `attr`" do
     data = Sample.elm |> attr(:x, 10) |> attr(:y, 20)
     assert %{x: 10, y: 20} = data
   end

   test "overrides the previous value when calling `attr` twice" do
     data = Sample.elm |> attr(:x, 10) |> attr(:x, 15)
     assert %{x: 15} = data
   end

   test "uses the attribute alias if found" do
     data = Sample.elm foo: 10
     assert %{bar: 10} = data
   end

   test "uses the attribute alias with the `attr` function" do
     data = Sample.elm |> attr(:foo, 10)
     assert %{bar: 10} = data
   end

   test "uses the handler if one is found" do
     data = Sample.elm size: 5
     assert %{width: 5, height: 5} = data
   end

   test "uses the handler with the `attr` function" do
     data = Sample.elm |> attr(:size, 5)
     assert %{width: 5, height: 5} = data
   end

   test "uses a handler that returns an attribute with an alias" do
     data = Sample.elm |> attr(:foo_plus_two, 10)
     # foo_plus_two returns the value + 2 to the key `foo`, which is aliased to `bar`.
     assert %{bar: 12} = data
   end

   test "sets the attribute class with the `class` function" do
     data = Sample.elm |> class("my-class")
     assert %{class: "my-class"} = data
   end

   test "sets the attribute id with the `id` function" do
     data = Sample.elm |> id("my-id")
     assert %{id: "my-id"} = data
   end

   test "adds an style attribute with the `style` function" do
     data = Sample.elm |> style("fill", "red")
     assert %{"fill" => "red"} = data.style
   end

   test "adds styles with each `style` function call" do
     data = Sample.elm |> style("fill", "red") |> style("stroke", "black")
     assert %{"fill" => "red", "stroke" => "black"} = data.style
   end

   test "adds style with a map of attributes" do
     data = Sample.elm |> style(%{"fill" => "red", "stroke" => "black"})
     assert %{"fill" => "red", "stroke" => "black"} = data.style
   end

   test "styles with multiple calls to `style` with a map" do
     data = Sample.elm |> style(%{"fill" => "red"}) |> style(%{"stroke" => "black"})
     assert %{"fill" => "red", "stroke" => "black"} = data.style
   end
end
