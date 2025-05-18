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

processItem[StyleBox[text_String, "Input", ___]] := 
    " `" <> StringTrim[text] <> "` "

processItem[StyleBox[text_String, FontColor->RGBColor[r_,g_,b_], ___]] := 
    StringTemplate["<span style=\"color: rgba(`1`,`2`,`3`,1);\">`4`</span>"][
        255*r, 255*g, 255*b, text]
        
processItem[StyleBox[text_String, FontColor->color_, ___]] := 
    StringTemplate["<span style=\"color: `1`;\">`2`</span>"][color, text]

processItem[StyleBox[text_String, FontSlant->"Italic", ___]] := 
    " *" <> StringTrim[text] <> "* "
    
processItem[StyleBox[text_String, FontWeight->"Bold", ___]] := 
    " **" <> StringTrim[text] <> "** "

processItem[ButtonBox[text_String, ___, ButtonData->{___, URL[url_String], ___}, ___]] := 
    " [" <> StringTrim[text] <> "](" <> url <> ") "
        
processItem[text_String] := text

(* Includes a fix for an ExportString bug producing expressions like \(\text{$\sigma$}\) *)
processItem[Cell[box_BoxData, ___] | box_BoxData] := 
    StringReplace[StringReplace[ExportString[box, "TeXFragment"], 
        "\\text{" ~~ Shortest[str__] ~~ "}" /; StringContainsQ[str, "$"] :> 
            StringDelete[str, "$"]], {"\\(" | "\\)" -> "$", "\r\n" -> ""}]

processItem[other_] := (Print["Unrecognized form:" <> ToString[other]]; "---UNPARSED---")

head = <|"Title" -> "# ", "Section" -> "---\n## ", "Subsection" -> "### ", "Item" -> "- "|>

processContent[data_, type:Except["Input"]] :=
    Lookup[head, type, ""] <> StringReplace[
        If[StringQ[data], data, StringJoin[processItem /@ First[data]]], 
    "\n" -> "\r\n\r\n"]

processContent[content_, "Input"] :=
    StringReplace[StringReplace[
        ToString[ToExpression[content, StandardForm, HoldForm], InputForm],
        RegularExpression["^HoldForm\\[(.*)\\]$"] -> "$1"], ", Null, " -> "\r\n"]

processCell[styleName_String, Cell[cellContent_, ___]] :=
    Switch[styleName,
        "DisplayFormula",
        <|"kind" -> 1, "languageId" -> "markdown", "value" -> StringReplace[processItem[cellContent], "$" -> "$$"]|>,
        "Input",
        <|"kind" -> 2, "languageId" -> "wolfram", "value" -> processContent[cellContent, styleName]|>,
        _,
        <|"kind" -> 1, "languageId" -> "markdown", "value" -> processContent[cellContent, styleName]|>]

Mathematica2VSCode[inputFile_String?FileExistsQ] := 
    Module[{processedCells},
        processedCells = NotebookImport[inputFile, Except["Output"|"Message"] -> (processCell[#1,#2]&)];    
        processedCells = <|#, "value" -> ToString[#["value"]]|> & /@ processedCells;
        Export[FileBaseName[inputFile] <> ".vsnb", <|"cells" -> processedCells|>, "JSON"]
    ]

End[] 

EndPackage[]
