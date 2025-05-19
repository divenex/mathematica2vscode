(* ::Package:: *)
(* :Name: Mathematica2VSCode *)
(* :Author: https://github.com/divenex *)
(* :Date: 2025-05-18 *)
(* :Summary: Converts Mathematica notebooks (.nb) to VSCode Notebook format (.vsnb) *)
(* :Context: Mathematica2VSCode` *)
(* :Package Version: 1.0 *)
(* :Mathematica Version: 12.0+ *)
(* :Copyright: (c) 2025 divenex (https://github.com/divenex) *)

ClearAll["Mathematica2VSCode`*", "Mathematica2VSCode`Private`*"]  (* Clean everything upon reloading *)

BeginPackage["Mathematica2VSCode`"];

Mathematica2VSCode::usage = "Mathematica2VSCode[inputFile] 
    converts a Mathematica notebook (.nb) specified by inputFile to VSCode Notebook (.vsnb) format.
    The output file is saved to the same location as the input file but with .vsnb extension.
    Returns the path to the created .vsnb file upon success, or $Failed if conversion fails.";

Begin["`Private`"];

processItem[StyleBox[txt_String, "Input", ___]] := " `" <> StringTrim[txt] <> "` "

processItem[StyleBox[txt_String, FontColor->RGBColor[r_,g_,b_], ___]] := 
    StringTemplate["<span style=\"color: rgba(`1`,`2`,`3`,1);\">`4`</span>"][255*r, 255*g, 255*b, txt]

processItem[StyleBox[txt_String, FontSlant->"Italic", ___]] := " *" <> StringTrim[txt] <> "* "
    
processItem[StyleBox[txt_String, FontWeight->"Bold", ___]] := " **" <> StringTrim[txt] <> "** "

processItem[ButtonBox[txt_String, ___, ButtonData->{___, URL[url_String], ___}, ___]] := 
    " [" <> txt <> "](" <> url <> ") "
        
processItem[txt_String] := txt

(* Includes a fix for an ExportString bug producing expressions like \(\text{$\sigma$}\) *)
processItem[Cell[box_BoxData, ___] | box_BoxData] := 
    StringReplace[ExportString[box, "TeXFragment"], 
        {"\\text{" ~~ Shortest[str__] ~~ "}" /; StringContainsQ[str, "$"] :> 
            StringDelete[str, "$"], "\\(" | "\\)" -> "$", "\r\n" -> ""}]

processItem[other_] := (Print["Unrecognized form:" <> ToString[other]]; "---UNPARSED---")

processContent[cnt_, type:Except["Input"]] :=
    Lookup[<|"Title" -> "# ", "Section" -> "---\n## ", "Subsection" -> "### ", "Item" -> "- "|>, type, ""] <> 
        StringReplace[If[StringQ[cnt], cnt, StringJoin[processItem /@ First[cnt]]], "\n" -> "\r\n\r\n"]

processContent[cnt_, "Input"] :=
    StringReplace[StringTake[ToString[ToExpression[cnt, StandardForm, HoldComplete], InputForm], {14, -2}], ", Null, " -> "\r\n"]

processCell[style_String, Cell[cnt_, ___]] := Switch[style,
    "DisplayFormula", <|"kind" -> 1, "languageId" -> "markdown", "value" -> StringReplace[processItem[cnt], "$" -> "$$"]|>,
    "Input", <|"kind" -> 2, "languageId" -> "wolfram", "value" -> processContent[cnt, style]|>,
    _, <|"kind" -> 1, "languageId" -> "markdown", "value" -> processContent[cnt, style]|>]

Mathematica2VSCode[inputFile_String?FileExistsQ] := Module[{cells},
    cells = NotebookImport[inputFile, Except["Output"|"Message"] -> (processCell[#1,#2]&)];    
    cells = <|#, "value"->ToString[#["value"]]|> & /@ cells;
    Export[FileBaseName[inputFile] <> ".vsnb", <|"cells"->cells|>, "JSON"]
]

End[] 

EndPackage[]
