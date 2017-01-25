defmodule Celeste.API.AssemblageView do
  def render("index.json", %{assemblages: assemblages}) do
    %{
      assemblages: assemblages |> Enum.map(&short(&1))
    }
  end

  def render("short_show.json", %{assemblage: assemblage}) do
    %{
      assemblage: short(assemblage)
    }
  end

  def render("show.json", %{assemblage: assemblage}) do
    %{
      assemblage: Map.merge(
        short(assemblage),
        %{
          file_ids: assemblage.files |> Enum.map(& &1.id)
        }
      ),
      assemblies: (assemblage.parent_assemblies ++ assemblage.child_assemblies) |> Enum.map(&assembly/1),
      assemblages: (assemblage.parent_assemblages ++ assemblage.child_assemblages) |> Enum.map(&short/1),
      files: assemblage.files |> Enum.map(&file/1)
    }
  end

  def short(assemblage) do
    %{
      id: assemblage.id,
      name: assemblage.name,
      kind: assemblage.kind,
    }
  end

  def file(file) do
    %{
      id: file.id,
      sha256: file |> Celeste.File.link_param,
      mime: file.mime,
      name: Path.basename(file.path)
    }
  end

  def assembly(assembly) do
    %{
      assemblage_id: assembly.assemblage_id,
      child_assemblage_id: assembly.child_assemblage_id,
      kind: assembly.kind
    }
  end
end