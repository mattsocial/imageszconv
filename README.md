# Image Size Converter

Simple script for converting images to different sizes.

Currently just scales and center crops the images.

## Installation

1. Install Julia 1.3 or greater 
2. https://github.com/mattsocial/imageszconv
3. Then download or clone.

## Usage

### Configure

Put your images in the `sources` folder.

Edit `config.yml` and specify your output resolutions. Ex:

```yaml
inputDir: sources

output:
    -
        dir: steam
        size: 200x200
    - 
        dir: bigger
        size: 400x400
```

### Windows

Open the `Julia` REPL (hit the `Windows Key` and type `Julia` to find it), then run the following (it may take a while to startup):

```bash
julia> include("path/to/imageszconv/app.jl")
```

Note the very first time you run it, it will take a very long time (~5-10 mins). Afterwards it should start a lot quicker (~30 seconds).

You can keep the `Julia` REPL open and run the last line again to re-run it (you can hit the Up arrow and then Enter to run previous line again). It will run faster after it's initially be loaded.