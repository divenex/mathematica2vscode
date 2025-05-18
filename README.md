# Mathematica2VSCode Wolfram Package

Converts Mathematica notebooks (.nb) to VSCode Notebook format (.vsnb).

## Author

[divenex](https://github.com/divenex)

## Date

2025-05-18

## Summary

This Wolfram Language package provides a function to convert Mathematica notebooks (`.nb` files) into VSCode Notebook files (`.vsnb`). This allows for easier viewing and interaction with Mathematica notebook content within the VSCode environment, leveraging its native notebook interface.

The conversion handles various cell types including:
*   Input cells (Wolfram Language code)
*   Text cells (Title, Section, Subsection, Item)
*   Styled text (bold, italic, font color)
*   Hyperlinks
*   TeX-like formulas (DisplayFormula)

## Package Version

1.0

## Mathematica Version

Requires Mathematica 12.0 or newer.

## Copyright

(c) 2025 divenex (https://github.com/divenex)

## Function

### `Mathematica2VSCode[inputFile]`

**Usage:**

`Mathematica2VSCode[inputFile]`

**Details:**

*   `inputFile`: A string representing the full path to the Mathematica notebook (`.nb`) file you want to convert.
*   The function converts the specified Mathematica notebook to the VSCode Notebook (`.vsnb`) format.
*   The output `.vsnb` file is saved in the same directory as the input file, with the same base name but a `.vsnb` extension.
*   Returns the absolute path to the created `.vsnb` file upon successful conversion.
*   Returns `$Failed` if the conversion fails (e.g., if the input file does not exist).

## How to Use

1.  **Load the Package:**
    Make sure the `Mathematica2VSCode.wl` file is in a location where Mathematica can find it (e.g., your working directory, a directory in `$Path`, or install it as a package).
    Then, load the package into your Mathematica session:
    ```wolfram
    Get["path/to/Mathematica2VSCode.wl"] 
    (* Or if installed/in $Path *)
    Needs["Mathematica2VSCode`"]
    ```

2.  **Convert a Notebook:**
    Call the `Mathematica2VSCode` function with the path to your `.nb` file:
    ```wolfram
    Mathematica2VSCode["C:\Users\YourName\Documents\MyNotebook.nb"]
    ```
    Or using a relative path if appropriate:
    ```wolfram
    SetDirectory[NotebookDirectory[]]; (* Or any other relevant directory *)
    Mathematica2VSCode["MyNotebook.nb"]
    ```

3.  **Open in VSCode:**
    The converted `.vsnb` file will be created in the same directory as the original `.nb` file. You can then open this `.vsnb` file with VSCode. Ensure you have appropriate extensions for viewing VSCode notebooks and potentially for Wolfram Language syntax highlighting if your `.vsnb` contains Wolfram Language code cells.

## Example

```wolfram
(* Assuming mathematica2vscode.wl is in the current working directory or $Path *)
Needs["Mathematica2VSCode`"]

(* Specify the path to your Mathematica notebook *)
notebookPath = "C:\Path\To\Your\Mathematica\Notebooks\Example.nb";

(* Convert the notebook *)
convertedFile = Mathematica2VSCode[notebookPath]

(* Check the result *)
If[convertedFile === $Failed,
  Print["Conversion failed."],
  Print["Notebook converted successfully to: ", convertedFile]
]
```

## Screenshot

![Image](https://i.sstatic.net/6HQZpO8B.png)

## Notes

*   The conversion process attempts to map Mathematica cell styles (Title, Section, Input, etc.) to appropriate Markdown or code cells in the VSCode Notebook format.
*   Some complex or highly customized Mathematica notebook features might not be perfectly translated.
*   The package includes a fix for a known `ExportString` bug that can affect the rendering of TeX fragments containing `$`.

## Inspiration

This package was inspired by the approach described in [Converting Wolfram Notebooks to Markdown](https://practicalwolf.com/2020/04/02/converting-wolfram-notebooks-to-markdown.html).
