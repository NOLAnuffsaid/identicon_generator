defmodule IdenticonGenerator do
  @moduledoc """
  Documentation for IdenticonGenerator.
  """

  require Integer

  def main(input) do
    input
    |> hash_input()
    |> pick_color()
    |> build_grid()
    |> build_pixel_map()
    |> draw_image()
    |> save_image(input)
  end

  defp save_image(img, input) do
    File.write("#{input}.png", img)
  end

  defp draw_image(%IdenticonGenerator.Image{color: c, pixel_map: pxm}) do
    img = :egd.create(250, 250)
    fill = :egd.color(c)

    pxm
    |> Enum.reduce(img, fn {start, stop}, acc ->
         :egd.filledRectangle(acc, start, stop, fill)
         acc
       end)
    |> :egd.render()
  end

  defp pick_color(%IdenticonGenerator.Image{hex: [r, g, b | _rest]} = img) do
    %IdenticonGenerator.Image{img | color: {r, g, b}}
  end

  defp build_grid(%IdenticonGenerator.Image{hex: hex} = img) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.reduce([], fn [a, b | _] = row, acc -> acc ++ (row ++ [b, a]) end)
      |> Enum.with_index()
      |> Enum.filter(fn {n, _i} -> Integer.is_even(n) end)

    %IdenticonGenerator.Image{img | grid: grid}
  end

  defp build_pixel_map(%IdenticonGenerator.Image{grid: grid} = img) do
    pixel_map =
      Enum.map(grid, fn ({_c, i}) ->
        hz = rem(i, 5) * 50
        vert = div(i, 5) * 50

        top_left = {hz, vert}
        bottom_right = {hz + 50, vert + 50}

        {top_left, bottom_right}
      end)

    %IdenticonGenerator.Image{img | pixel_map: pixel_map}
  end

  defp hash_input(input) do
    %IdenticonGenerator.Image{ hex: :binary.bin_to_list :crypto.hash(:md5, input) }
  end
end
