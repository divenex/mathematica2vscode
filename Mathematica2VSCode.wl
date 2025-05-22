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

processItem[TextData[elems_]] := StringJoin[processItem /@ Flatten[{elems}]];  (* Recursive *)

processItem[StyleBox[txt_String, "Input", ___]] := " `" <> StringTrim[txt] <> "` "

processItem[StyleBox[txt_String, FontSlant->"Italic", ___]] := " *" <> StringTrim[txt] <> "* "
    
processItem[StyleBox[txt_String, FontWeight->"Bold", ___]] := " **" <> StringTrim[txt] <> "** "

processItem[fmt_StyleBox] := ExportString[fmt, "HTMLFragment"]

processItem[ButtonBox[txt_String, ___, ButtonData->{___, URL[url_String], ___}, ___]] := 
    " [" <> txt <> "](" <> url <> ") "

processItem[expr_?(!FreeQ[#, _RasterBox]&)] := 
    ExportString[Image[First[
        Cases[expr, RasterBox[CompressedData[data__String], ___] :> Uncompress[data], Infinity]
    ], ColorSpace -> "RGB"], "HTMLFragment"]

(* Also includes a fix for ExportString bug producing TeX like \(\text{2$\sigma$r}\) or \(x{}^2\) *)
processItem[Cell[box_BoxData, ___] | box_BoxData] := 
    StringReplace[ExportString[box, "TeXFragment"], 
        {"\\text{" ~~ str__ ~~ "}" /; (StringContainsQ[str, "$"] && StringFreeQ[str, {"{", "}"}]) :> 
            StringDelete[str, "$"], "\\(" -> " $", "\\)" -> "$ ", "{}^" -> "^", "\r\n" -> ""}]

processItem[str_String] := str;

processItem[unknown_] := (Print["Unrecognized form: " <> ToString[unknown]]; "---UNPARSED---")

processText[cnt_, type_String] :=
    Switch[type, "Title", "# ", "Section", "---\n## ", "Subsection", "### ", "Item", "- ", _, ""] <> 
        StringReplace[processItem[cnt], "\n" -> "\r\n\r\n"]

processInput[_?(!FreeQ[#, _RasterBox]&)] := "---IMAGE---"

processInput[cnt_] := StringReplace[StringTake[
    ToString[ToExpression[cnt, StandardForm, HoldComplete], InputForm], {14, -2}], 
        ", Null, " | (", Null" ~~ EndOfString) -> "\r\n"]

processCell[style_String, Cell[cnt_, ___]] := Switch[style,
    "DisplayFormula" | "DisplayFormulaNumbered", 
                      <|"kind" -> 1, "languageId" -> "markdown", "value" -> StringReplace[processItem[cnt], "$" -> "$$"]|>,
    "Input" | "Code", <|"kind" -> 2, "languageId" -> "wolfram",  "value" -> processInput[cnt]|>,
    _,                <|"kind" -> 1, "languageId" -> "markdown", "value" -> processText[cnt, style]|>]

mergeMarkdownCells[cells_] := SequenceReplace[cells,
  {c__?(#["languageId"] === "markdown"&)} :> <|c, "value" -> StringRiffle[Lookup[{c}, "value"], "\r\n\r\n"]|>]
                                                                          
Mathematica2VSCode[inputFile_String?FileExistsQ] := Module[{cells},
    cells = NotebookImport[inputFile, Except["Output" | "Message"] -> (processCell[#1,#2]&)];    
    cells = mergeMarkdownCells[cells];     
    Export[FileBaseName[inputFile] <> ".vsnb", <|"cells"->cells|>, "JSON"]]

End[] 

EndPackage[]
