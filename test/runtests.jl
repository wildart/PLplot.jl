using PLplot
using Base.Test

@test PLplot.verison() == v"5.11.1"
