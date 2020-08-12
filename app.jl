cd(@__DIR__)

using Pkg

Pkg.activate("ImageSizeConverter")
Pkg.instantiate()

import ImageSizeConverter

ImageSizeConverter.run()
println("Done.")