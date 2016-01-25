defmodule WebGraphics.SVG.ElementBuilder do
  @moduledoc """
  This module exposes the API for declaring 
  """

  @ignored_attributes [:_module]

  defmacro __using__(_) do
    quote do
      import WebGraphics.SVG.ElementBuilder
    end
  end

  @doc """
  Adds the given `key` and `val` to the `elm` map. The key is checked
  for possible handlers and aliases.

  A map is returned with the modified element including the new attribute.
  """
  def attr(elm, key, val) do
    handled_val = apply(elm._module, :attr_handler, [key, val])
    if is_list(handled_val) or is_map(handled_val) do
      Enum.reduce(handled_val, elm, fn {key, val}, attrs ->
        attr(attrs, key, val)
      end)
    else
      Map.put(elm, apply(elm._module, :attr_alias, [key]), handled_val)
    end
  end

  @doc """
  Adds the given `key` and `val` to the elm's style property. This function
  can be called multiple times with different style properties.

  ### Example
  ```
  rect(x: 10, y: 10) |> style("fill", "red") |> style("stroke", "blue")
  ```
  """
  def style(elm, key, val) do
    if Map.has_key?(elm, :style) do
      new_style = Map.put(elm.style, key, val)
      %{elm | style: new_style}
    else
      style = %{key => val}
      Map.put(elm, :style, style)
    end
  end

  @doc """
  Alternative to `style`, so we can pass a map of properties to the element.
  
  ### Example

  ```elixir
  rect(x: 10, y: 10) |> style(%{"fill" => "blue", "stroke" => "black"})
  ```
  """
  def style(elm, styles) do
    Enum.reduce(styles, elm, fn {key, val}, elm ->
      style(elm, key, val)
    end)
  end

  @doc """
  Adds the given `val` to the `id` property in the elm.

  ### Example

  ```elixir
  rect(x: 10, y: 10) |> id("my-id")
  ```
  """
  def id(elm, val), do: attr(elm, :id, val)

  @doc """
  Adds the given `val` to the `class` property in the elm.

  ### Example

  ```elixir
  rect(x: 5, y: 5) |> class("my-class my-other-class")
  ```
  """
  def class(elm, val), do: attr(elm, :class, val)

  @doc """
  Renders the given `elm` to a valid SVG string.
  """
  def render(elm) do
    tag = apply(elm._module, :get_tag, [])
    opening_tag = "<" <> Atom.to_string(tag) <> " "
    closing_tag = "/>"
    rendered_attrs = render_attrs(elm)

    # We make this check just to output a pretier tag with an empty
    # space between the last attribute and the closing "/>" tag.
    case String.length(rendered_attrs) > 0 do
      true -> opening_tag <> rendered_attrs <> " " <> closing_tag
      false -> opening_tag <> closing_tag
    end
  end

  def render_with(elm, body) do
    tag = apply(elm._module, :get_tag, [])
    opening_tag = "<" <> Atom.to_string(tag)
    closing_tag = "</" <> Atom.to_string(tag) <> ">"
    rendered_attrs = render_attrs(elm)

    # We make this check just to output a pretier tag. For example, the
    # following tag has an attribute ("width") so we print a space between
    # `rect` and the first property.
    #
    # <rect width="10">...</rect>
    #
    # If the tag has no attributes, the output should be:
    #
    # <rect>...</rect> 
    # 
    # instead of (notice the whitespace after the tag name):
    #
    # <rect >...</rect>
    opening_elm = if String.length(rendered_attrs) > 0 do
      opening_elm = opening_tag <> " " <> rendered_attrs <> ">"
    else
      opening_elm = opening_tag <> ">"
    end

    content = cond do
      is_function(body) -> body.(elm)
      is_bitstring(body) -> body
      true -> ""
    end
    opening_elm <> content <> closing_tag
  end

  def render_attrs(elm) do
    elm
    |> Enum.map(fn {key, val} ->
      case Enum.find(@ignored_attributes, &(&1 == key)) do
        nil -> render_attr(key, val)
        key -> nil
      end
    end)
    |> Enum.filter(fn val -> val end)
    |> Enum.join(" ")
  end

  def render_attr(key, val) do
    if is_atom(key), do: key = Atom.to_string(key)
    case is_list(val) or is_map(val) do
      false -> key <> "=\"" <> to_string(val) <> "\""
      true  -> key <> "=\"" <> render_values(val) <> "\""
    end
  end

  def render_values(values) do
    values
    |> Enum.map(fn {key, val} -> to_string(key) <> "=" <> to_string(val) <> ";" end)
    |> Enum.join(" ")
  end
end
