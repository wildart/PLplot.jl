using PLplot
using Base.Test

plplot_ver = PLplot.verison()
println(plplot_ver)
@test plplot_ver <= v"5.11.1"
