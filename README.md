# Mathematica2VSCode: Mathematica Notebooks to VSCode

Converts Mathematica notebooks (.nb) to Visual Studio Code (VSCode) Notebook format (.vsnb or .wlnb).

## ⚠️ Repository Deprecated

This repository has been **deprecated** and is no longer maintained. 

I have replaced this function with a more general solution: **[Mathematica2Jupyter](https://github.com/divenex/mathematica2jupyter)** which converts Mathematica Notebooks (`.nb`) into either:
- Jupyter Notebooks (`.ipynb`) 
- VSCode Notebooks (`.vsnb`/`.wlnb`)

The new unified function provides the same VSCode conversion functionality plus Jupyter support with a cleaner, more maintainable codebase.

### Migration Guide
Replace calls to `Mathematica2VSCode[file]` with:
- `Mathematica2Jupyter[file, "vsnb"]` for VSCode notebooks
- `Mathematica2Jupyter[file, "ipynb"]` for Jupyter notebooks (default)

Please update your workflows to use the new repository.
