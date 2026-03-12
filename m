let
    // data stazena z virtualpro.cz
    Zdroj = Excel.Workbook(File.Contents("C:\Users\Student\Downloads\data.xlsx"), null, true),
    data1_Sheet = Zdroj{[Item="data1",Kind="Sheet"]}[Data],
    #"Záhlaví se zvýšenou úrovní" = Table.PromoteHeaders(data1_Sheet, [PromoteAllScalars=true]),
    #"Připojený dotaz" = Table.Combine({#"Záhlaví se zvýšenou úrovní", data2}),
    #"Odebrané ostatní sloupce" = Table.SelectColumns(#"Připojený dotaz",{"lokalita", "datum", "srazky"}),
    #"Změněný typ" = Table.TransformColumnTypes(#"Odebrané ostatní sloupce",{{"lokalita", type text}, {"datum", type date}, {"srazky", type number}}),
    #"Vložené: Rok" = Table.AddColumn(#"Změněný typ", "rok", each Date.Year([datum]), Int64.Type),
    #"Vložené: Měsíc" = Table.AddColumn(#"Vložené: Rok", "mesic", each Date.Month([datum]), Int64.Type),
    #"Podmíněný sloupec je přidaný" = Table.AddColumn(#"Vložené: Měsíc", "typ_pocasi", each if [srazky] = null then "nevyplneno" else if [srazky] = 0 then "neprselo" else "prselo", type text),
    #"Byl extrahován text před oddělovačem." = Table.TransformColumns(#"Podmíněný sloupec je přidaný", {{"lokalita", each Text.BeforeDelimiter(_, ","), type text}}),
    #"Vyčištěný text" = Table.TransformColumns(#"Byl extrahován text před oddělovačem.",{{"lokalita", Text.Clean, type text}}),
    #"Oříznutý text" = Table.TransformColumns(#"Vyčištěný text",{{"lokalita", Text.Trim, type text}}),
    #"Text velkými písmeny" = Table.TransformColumns(#"Oříznutý text",{{"typ_pocasi", Text.Upper, type text}}),
    #"Sloučené dotazy" = Table.NestedJoin(#"Text velkými písmeny", {"lokalita"}, dim_geo, {"lokalita"}, "dim_geo", JoinKind.LeftOuter),
    #"Rozbalené dim_geo" = Table.ExpandTableColumn(#"Sloučené dotazy", "dim_geo", {"zeme"}, {"zeme"})
in
    #"Rozbalené dim_geo"
