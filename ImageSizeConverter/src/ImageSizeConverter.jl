module ImageSizeConverter

using Images, FileIO, ImageTransformations
import YAML

FilePath = String
Width = Int
Height = Int
Ratio = Float64
ImageSize = Union{Tuple{Width, Height}, Ratio}

struct FileToWrite
    input::FilePath
    output::Array{Tuple{FilePath, ImageSize}}
end

struct OutConfig
    dir::String
    size::ImageSize
end

struct Config
    src::String
    out::Array{OutConfig}
end

struct ConfigMissingError <: Exception
    msg :: String
end

struct InvalidImageSize <: Exception
    msg :: String
end

struct InvalidConfig <: Exception
    msg :: String
end

function parse_size_str(sizes::String) :: ImageSize
    sizes = strip(sizes)
    image_match = match(r"^([0-9]+)([/x]{1})([0-9]+)$", sizes)
    if image_match !== nothing
        a = parse(Int, image_match[1])
        b = parse(Int, image_match[3])
        if image_match[2] == "x"
            return (a, b)
        else
            return a / convert(Float64, b)
        end
    end
    throw(InvalidImageSize("Invalid image size must be either wxh (ex. 2000x300) or ratio (ex. 1/2)")) 
end

function parse_config() :: Config
    configpath = "./config.yml"
    if !isfile(configpath)
        throw(ConfigMissingError("Could not find config.yml file"))
    end
    try
        data = YAML.load(open(configpath))
        Config(
            data["inputDir"],
            [OutConfig(o["dir"], parse_size_str(o["size"])) for o in data["output"] ]
            )
    catch e
        throw(InvalidConfig("Config is invalid"))
    end
end

function config_to_file_plan(cfg::Config) :: Array{FileToWrite}
    images = [
        p for p in readdir(cfg.src)
        if isfile(joinpath(cfg.src, p)) && p != ".gitkeep"
    ]
    out = []
    for img in images
        src = joinpath(cfg.src, img)
        outpaths = [(joinpath(p.dir, img), p.size) for p in cfg.out]
        out = push!(out, FileToWrite(src, outpaths))
    end
    return out
end

function img_test()
    img = load("sources/testing.jpg")
    (h, w) = size(img)
    scale_and_center_crop_image(h, w, 200, 200)
end

function scale_and_center_crop_image(h, w, desiredh, desiredw)
    ratioh = desiredh / h
    ratiow = desiredw / w
    ratio = ratioh > ratiow ? ratioh : ratiow
    newh = ratio * h
    neww = ratio * w

    croph = newh > desiredh ? trunc(Int, (newh - desiredh) / 2.0) : 1
    cropw = neww > desiredw ? trunc(Int, (neww - desiredw) / 2.0) : 1

    (ratio, croph, cropw)
end

function process_image(img, sz::ImageSize)
        if !(sz isa Tuple)
            return imresize(img, ratio=sz)
        end
        (h, w) = size(img)
        desiredh = sz[2]
        desiredw = sz[1]
        (scale_ratio, croph, cropw) = scale_and_center_crop_image(h, w, desiredh, desiredw)
        img_small = imresize(img, ratio=scale_ratio)
        return img_small[croph:desiredh, cropw:desiredw]
end

function convert_images(f::FileToWrite)
    img = load(f.input)
    for (outfile, sz) in f.output
        if isfile(outfile)
            rm(outfile)
        end
        img_small = process_image(img, sz)
        save(outfile, img_small)
    end
end

function run()
    cfg = parse_config()
    for o in cfg.out
        if !isdir(o.dir)
            mkdir(o.dir)
        end
    end
    plan = config_to_file_plan(cfg)
    for p in plan
        convert_images(p)
    end
end

end # module
