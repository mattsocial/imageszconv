
using Test
import ImageSizeConverter

@testset "Image Conversion: scale + cropping" begin 

    @testset "No cropping when same ratio" begin
        (ratio, ch, cw) = ImageSizeConverter.scale_and_center_crop_image(1600, 800, 1600 / 3, 800 / 3)
        @test round(ratio; digits=3) == 0.333
        @test ch == 1
        @test cw == 1
    end

    @testset "Correct cropping when same size" begin
        (ratio, ch, cw) = ImageSizeConverter.scale_and_center_crop_image(1600, 800, 1600, 800)
        @test round(ratio; digits=3) == 1.0
        @test ch == 1
        @test cw == 1
    end

    @testset "Correct cropping when bigger" begin
        (ratio, ch, cw) = ImageSizeConverter.scale_and_center_crop_image(1600, 800, 1600 * 2, 800 * 2)
        @test round(ratio; digits=3) == 2.0
        @test ch == 1
        @test cw == 1
    end

    @testset "Correct cropping for height" begin
        (ratio, ch, cw) = ImageSizeConverter.scale_and_center_crop_image(1600, 800, 400, 400)
        @test round(ratio; digits=3) == 0.5
        @test ch == 200
        @test cw == 1
    end

    @testset "Correct cropping for width" begin
        (ratio, ch, cw) = ImageSizeConverter.scale_and_center_crop_image(600, 900, 300, 300)
        @test round(ratio; digits=3) == 0.5
        @test ch == 1
        @test cw == 75
    end
end
