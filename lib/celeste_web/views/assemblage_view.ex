defmodule CelesteWeb.AssemblageView do
  use Celeste.Web, :view

  alias Celeste.Assemblage
  alias Celeste.File, as: CFile

  def wikipedia_path(topic) do
    "https://en.wikipedia.org/wiki/#{String.replace(topic, " ", "_")}"
  end

  def composers_list(conn, [_, _] = composers), do: do_composers_list(conn, composers, " and ")
  def composers_list(conn, composers), do: do_composers_list(conn, composers, ", ")

  defp do_composers_list(conn, composers, sep) do
    composers
    |> Enum.map(&assemblage_link(conn, &1))
    |> Enum.intersperse(sep)
  end

  def composition_row(conn, composition) do
    [
      tags_row(tags_with_keys(composition, ~w|creation_date|), "primary"),
      full_assemblage_name(conn, composition, link: true)
    ]
    |> Enum.intersperse(" ")
  end

  def composed_by(conn, composition) do
    composers = Celeste.Assemblage.parent_assemblages_of_kind(composition, "composed", "person") |> Celeste.Repo.all

    who = [
      "composed by ",
      composers_list(conn, composers)
    ]

    case tags_with_keys(composition, ~w|creation_date|) do
      [] ->
        who
      [date_tag] ->
        [who, " in ", date_tag.value]
    end
  end

  def tags_with_keys(assemblage, keys) do
    assemblage.tags |> Enum.filter(&Enum.member?(keys, &1.key))
  end

  def tags_without_keys(assemblage, keys) do
    assemblage.tags |> Enum.reject(&Enum.member?(keys, &1.key))
  end

  def full_assemblage_name(conn, a, opts \\ %{})
  def full_assemblage_name(conn, %Assemblage{kind: "composition"} = composition, opts) do
    name =
      cond do
        opts[:link] -> assemblage_link(conn, composition)
        true -> composition.name
      end
    case tags_with_keys(composition, ~w|tonality|) do
      [] -> [name]
      [tag] -> [name, " in #{tag.value}"]
    end
  end
  def full_assemblage_name(_, assemblage, _), do: assemblage.name

  def tags_row(tags, class \\ "info") do
    tags
    |> Enum.map(&tag_label(&1, class))
    |> Enum.intersperse(" ")
  end

  def tag_label(tag, class) do
    content_tag :span, tag.value, class: "label label-#{class}"
  end

  defp assemblage_link(conn, assemblage) do
    link(assemblage.name, to: assemblage_path(conn, :show, assemblage.id))
  end

  def file_row(conn, file) do
    {icons, text} =
      cond do
        Regex.match?(~r/\.mp3$/, file.path) ->
          icons = [
            link(content_tag(:i, nil, class: "fa fa-fw fa-play"), to: "", class: "button play-file"),
          ]
          title =
            if file.id3v2 do
              "#{CFile.id3(file, "TRCK")}. #{CFile.id3(file, "TIT2")}"
            else
              Path.basename(file.path)
            end
          {icons, title}
        Regex.match?(~r/\.jpg/, file.path) ->
          {[content_tag(:i, nil, class: "fa fa-fw fa-photo")],
           link(Path.basename(file.path), to: file_path(conn, :show, CFile.link_param(file)))}
        true ->
          {[content_tag(:i, nil, class: "fa fa-fw fa-file")],
           link(Path.basename(file.path), to: file_path(conn, :show, CFile.link_param(file)))}
      end

    content_tag(:tr, data: [file: CFile.link_param(file)]) do
      content_tag(:td) do
        [icons, " ", text]
      end
    end
  end
end