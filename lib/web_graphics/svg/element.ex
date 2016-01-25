defmodule WebGraphics.SVG.Element do
  @moduledoc """
  The `Element` module provides common behaviour for all SVG elements. When we
  call `use WebGraphics.SVG.Element` a few macros are imported and a simple DSL
  becomes available.

  ### Example

  ```elixir
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
  ```
  """

  @doc """
  Defines an alias `alternative` for the given `name`. This is just for convenience
  so we don't have to type long attribute/style names.
  """
  defmacro attr_alias(name, alternative) do
    quote do
      def attr_alias(unquote(name)), do: unquote(alternative)
    end
  end

  @doc """
  Defines a handler for the 
  """
  defmacro attr_handler(name, body) do
    quote do
      def attr_handler(unquote(name), var!(value)) do
        unquote(body[:do])
      end
    end
  end

  @doc """
  Specifies the default attributes for the element. The attributes can then be overriten
  on specific elements.
  """
  defmacro default_attrs(attrs) do
    quote do
      # For now, the given `attrs` is returned. Only that.
      def default_attrs, do: unquote(attrs)
    end
  end

  @doc """
  """
  defmacro tag(tag, body) do
    quote do
      unquote(body[:do])

      @doc """
      Returns the tag specified by the user. The tag must be a valid SVG element such as
      rect, circle or path. This function is called by the rener function in the 
      ElementBuilder module.
      """
      def get_tag, do: unquote(tag)

      @doc """
      Default implementation for the `attr_alias` function. Attribute aliasing works by
      defining multiple functions with pattern matching, and this function is the "match all"
      that just returns the given key.
      """
      def attr_alias(key), do: key

      @doc """
      Default implementation for the `attr_handler` function. Attribute handling works by
      defining multiple functions with pattern matching, and this function is the "match all"
      that just returns the given value.
      """
      def attr_handler(_, val), do: val
    end
  end

  defmacro __using__(opts) do

    # We need the module because each element has it's own aliases and handlers.
    # And those are just functions in the module with pattern matching.
    module = __CALLER__.module

    # The given tag will be used to render the element. For example, if tag is `:rect`
    # the rendered element will be <rect ... />.
    tag = opts[:tag]

    quote do
      import WebGraphics.SVG.Element

      @doc """
      Returns a simple map with the given `attrs` and `:_module` that is a reference
      to the module that this function was called. This is necessary because each
      module defines different attribute aliases and handlers, and we need a way to
      get call those.

      It's possible to build up from the returned map using the functions in the
      `WebGraphics.SVG.Element` module, such as `attr` and `style`. After you're done
      setting up the element
      """
      def elm(attrs \\ %{}) do 
        mod = unquote(module)
        initial_attrs = case function_exported?(mod, :default_attrs, 0) do
          true  -> apply(mod, :default_attrs, []) |> Enum.into(%{}) |> Map.put(:_module, mod)
          false -> %{_module: mod}
        end
        Enum.reduce(attrs, initial_attrs, fn {key, val}, attrs ->
          WebGraphics.SVG.ElementBuilder.attr(attrs, key, val)
        end)
      end
    end
  end
end
