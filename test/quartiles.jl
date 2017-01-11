using PLplot
using Base.Test

@testset "Quartiles" begin
    odd_test = [1,2,3,4,5,6,7]
    even_test = [1,2,3,4,5,6,7,8]

    # D4: (n+1)*p = j + g
    q1, q2, q3 = PLplot.quartiles(odd_test, quartile=:average)
    @test q1 == 2.  
    @test q2 == 4.
    @test q3 == 6.
    q1, q2, q3 = PLplot.quartiles(even_test, quartile=:average)
    @test q1 == 2.25
    @test q2 == 4.5
    @test q3 == 6.75

    # D5: empirical 
    q1, q2, q3 = PLplot.quartiles(odd_test, quartile=:empirical)
    @test q1 == 2.  
    @test q2 == 4.
    @test q3 == 6.
    q1, q2, q3 = PLplot.quartiles(even_test, quartile=:empirical)
    @test q1 == 2.5
    @test q2 == 4.5
    @test q3 == 6.5

    # D6: hinges 
    q1, q2, q3 = PLplot.quartiles(odd_test, quartile=:tukey)
    @test q1 == 2.5  
    @test q2 == 4.
    @test q3 == 6.5
    q1, q2, q3 = PLplot.quartiles(even_test, quartile=:tukey)
    @test q1 == 2.5
    @test q2 == 4.5
    @test q3 == 7.5

    # D7: ideal 
    q1, q2, q3 = PLplot.quartiles(odd_test, quartile=:ideal)
    @test_approx_eq q1 2. + 2/12
    @test q2 == 4.
    @test_approx_eq q3 6. + 2/12
    q1, q2, q3 = PLplot.quartiles(even_test, quartile=:ideal)
    @test_approx_eq q1 2. + 5/12
    @test q2 == 4.5
    @test_approx_eq q3 7. + 5/12

    # D8: n*p + 1/2 = j + g 
    q1, q2, q3 = PLplot.quartiles(odd_test, quartile=:clevelend)
    @test q1 == 2.25
    @test q2 == 4.
    @test q3 == 5.75
    q1, q2, q3 = PLplot.quartiles(even_test, quartile=:clevelend)
    @test q1 == 2.5
    @test q2 == 4.5
    @test q3 == 6.5
end