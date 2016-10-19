using PLplot
using Base.Test

@testset "General" begin
    @test PLplot.verison() == v"5.11.1"
end


if isdefined(:Colors)
    @testset "Themes" begin
        @test size(PLplot.distinguishable_theme()) == (16,3)
        @test size(PLplot.gadfly_theme()) == (16,3)
        @test size(PLplot.color_theme()) == (16,3)

        @test PLplot.THEME == PLplot.gadfly_theme()
        PLplot.theme!()
        @test PLplot.THEME === nothing
    end
end
