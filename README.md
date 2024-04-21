# rtests.nvim

## Introduction

This is a Neovim plugin that runs inline R tests (see package[`roxytest`](https://mikldk.github.io/roxytest/articles/introduction.html)) each time the an R file is saved and displays diagnostics about failing tests.

<img width="465" alt="Screenshot 2024-04-21 at 08 06 48" src="https://github.com/dreanod/rtests.nvim/assets/6531533/421c5196-cf5a-4698-ad27-fe68b4ba7da4">

## Installation

For the pluging to work the R package `rtestNvim` needs to be installed. 

```R
devtools::install_github("dreanod/rtestNvim")
```

Using Lazy:

```lua
{'dreanod/rtest.nvim'}
```

## Usage

Use the user commands `:RtestsOn` to activate the test on an R buffer and `:RtestsOff` to turn off the plugin.

