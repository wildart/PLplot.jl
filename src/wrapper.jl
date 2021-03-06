const PLINT = Cint
const PLUINT = Cuint
const PLFLT = Cdouble
const PLSTR = Cstring

immutable Grid
    xgp::Ptr{PLFLT}
    ygp::Ptr{PLFLT}
    zgp::Ptr{PLFLT}
    nx::PLINT
    ny::PLINT
    nz::PLINT
    xg::Vector{PLFLT}
    yg::Vector{PLFLT}
    zg::Vector{PLFLT}
end
Grid(x::Vector{PLFLT}, y::Vector{PLFLT}, z=zeros(PLFLT,0)) =
    Grid(pointer(x), pointer(y), pointer(z), length(x), length(y), length(z), x, y, z)
function Grid(nx, ny, nz=0)
    x = zeros(PLFLT,nx)
    y = zeros(PLFLT,ny)
    z = zeros(PLFLT,nz)
    Grid(pointer(x), pointer(y), pointer(z), PLINT(nx), PLINT(ny), PLINT(nz), x, y, z)
end

recurs_type(dt::DataType) = dt <: Ptr ? Expr(:curly, :Ptr, recurs_type(dt.parameters[1])) : Symbol(dt)

plfuncs = [
( :pl_setcontlabelformat    ,( PLINT, PLINT ) ),
( :pl_setcontlabelparam     ,( PLFLT, PLFLT, PLFLT, PLINT ) ),
( :pladv                    ,( PLINT, ) ),
( :plarc                    ,( PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLINT ) ),
( :plaxes                   ,( PLFLT, PLFLT, PLSTR, PLFLT, PLINT, PLSTR, PLFLT, PLINT ) ),
( :plbin                    ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, PLINT ) ),
( :plbop                    ,() ),
( :plbox                    ,( PLSTR, PLFLT, PLINT, PLSTR, PLFLT, PLINT ) ),
( :plbox3                   ,( PLSTR, PLSTR, PLFLT, PLINT, PLSTR, PLSTR, PLFLT, PLINT, PLSTR, PLSTR, PLFLT, PLINT ) ),
( :plbtime                  ,( PLINT, PLINT, PLINT, PLINT, PLINT, PLFLT, PLFLT ) ),
( :plcalc_world             ,( PLFLT, PLFLT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLINT} ) ),
( :plclear                  ,() ),
( :plcol0                   ,( PLINT, ) ),
( :plcol1                   ,( PLFLT, ) ),
( :plcolorbar               ,( Ptr{PLFLT}, Ptr{PLFLT}, PLINT, PLINT, PLFLT, PLFLT, PLFLT, PLFLT, PLINT, PLINT, PLINT, PLFLT, PLFLT, PLINT, PLFLT, PLINT, Ptr{PLINT}, Ptr{PLSTR}, PLINT, Ptr{PLSTR}, Ptr{PLFLT}, Ptr{PLINT}, Ptr{PLINT}, Ptr{Ptr{PLFLT}} ) ),
( :plconfigtime             ,( PLFLT, PLFLT, PLFLT, PLINT, PLINT, PLINT, PLINT, PLINT, PLINT, PLINT, PLFLT ) ),
( :plcont                   ,( Ptr{Ptr{PLFLT}}, PLINT, PLINT, PLINT, PLINT, PLINT, PLINT, Ptr{PLFLT}, PLINT, Ptr{Void}, Ptr{Void} ) ),
( :plcpstrm                 ,( PLINT, PLINT ) ),
( :plctime                  ,( PLINT, PLINT, PLINT, PLINT, PLINT, PLFLT, Ptr{PLFLT} ) ),
( :plend                    ,() ),
( :plend1                   ,() ),
( :plenv                    ,( PLFLT, PLFLT, PLFLT, PLFLT, PLINT, PLINT ) ),
( :plenv0                   ,( PLFLT, PLFLT, PLFLT, PLFLT, PLINT, PLINT ) ),
( :pleop                    ,() ),
( :plerrx                   ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plerry                   ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plfamadv                 ,() ),
( :plfill                   ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT} ), ),
( :plfill3                  ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plflush                  ,() ),
( :plfont                   ,( PLINT, ) ),
( :plfontld                 ,( PLINT, ) ),
( :plgchr                   ,( Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plgcol0                  ,( PLINT, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT} ) ),
( :plgcol0a                 ,( PLINT, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLFLT} ) ),
( :plgcolbg                 ,( Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT} ) ),
( :plgcolbga                ,( Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLFLT} ) ),
( :plgcompression           ,( PLINT, ) ),
( :plgdev                   ,( PLSTR, ) ),
( :plgdidev                 ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plgdiori                 ,( Ptr{PLFLT}, ) ),
( :plgdiplt                 ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plgdrawmode              ,() ),
( :plgfam                   ,( Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT} ) ),
( :plgfci                   ,( Ptr{PLUINT}, ) ),
( :plgfnam                  ,( PLSTR, ) ),
( :plgfont                  ,( Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT} ) ),
( :plglevel                 ,( Ptr{PLINT}, ) ),
( :plgpage                  ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT} ) ),
( :plgra                    ,() ),
( :plgradient               ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, PLFLT ) ),
( :plgriddata               ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, PLINT, Ptr{PLFLT}, PLINT, Ptr{PLFLT}, PLINT, Ptr{Ptr{PLFLT}}, PLINT, PLFLT ) ),
( :plgspa                   ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plgstrm                  ,( Ptr{PLINT}, ) ),
( :plgver                   ,( PLSTR, ) ),
( :plgvpd                   ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plgvpw                   ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plgxax                   ,( Ptr{PLINT}, Ptr{PLINT} ) ),
( :plgyax                   ,( Ptr{PLINT}, Ptr{PLINT} ) ),
( :plgzax                   ,( Ptr{PLINT}, Ptr{PLINT} ) ),
( :plhist                   ,( PLINT, Ptr{PLFLT}, PLFLT, PLFLT, PLINT, PLINT) ),
( :plhlsrgb                 ,( PLFLT, PLFLT, PLFLT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plimage                  ,( Ptr{Ptr{PLFLT}}, PLINT, PLINT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plimagefr                ,( Ptr{Ptr{PLFLT}}, PLINT, PLINT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, Ptr{Void}, Ptr{Void} ) ),
( :plinit                   ,() ),
( :pljoin                   ,( PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :pllab                    ,( PLSTR, PLSTR, PLSTR ) ),
( :pllegend                 ,( Ptr{PLFLT}, Ptr{PLFLT}, PLINT, PLINT, PLFLT, PLFLT, PLFLT, PLINT, PLINT, PLINT, PLINT, PLINT, PLINT, Ptr{PLINT}, PLFLT, PLFLT, PLFLT, PLFLT, Ptr{PLINT}, Ptr{PLSTR}, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLFLT}, Ptr{PLINT}, Ptr{PLFLT}, Ptr{PLINT}, Ptr{PLSTR} ) ),
( :pllightsource            ,( PLFLT, PLFLT, PLFLT ) ),
( :plline                   ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plline3                  ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :pllsty                   ,( PLINT, ) ),
( :plmap                    ,( Ptr{Void}, PLSTR, PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plmapline                ,( Ptr{Void}, PLSTR, PLFLT, PLFLT, PLFLT, PLFLT, Ptr{PLINT}, PLINT ) ),
( :plmapstring              ,( Ptr{Void}, PLSTR, PLSTR, PLFLT, PLFLT, PLFLT, PLFLT, Ptr{PLINT}, PLINT ) ),
( :plmaptex                 ,( Ptr{Void}, PLSTR, PLFLT, PLFLT, PLFLT, PLSTR, PLFLT, PLFLT, PLFLT, PLFLT, PLINT ) ),
( :plmapfill                ,( Ptr{Void}, PLSTR, PLFLT, PLFLT, PLFLT, PLFLT, Ptr{PLINT}, PLINT ) ),
( :plmeridians              ,( Ptr{Void}, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plmesh                   ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{Ptr{PLFLT}}, PLINT, PLINT, PLINT ) ),
( :plmeshc                  ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{Ptr{PLFLT}}, PLINT, PLINT, PLINT, Ptr{PLFLT}, PLINT) ),
( :plmkstrm                 ,( PLINT, ) ),
( :plmtex                   ,( PLSTR, PLFLT, PLFLT, PLFLT, PLSTR ) ),
( :plmtex3                  ,( PLSTR, PLFLT, PLFLT, PLFLT, PLSTR ) ),
( :plot3d                   ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{Ptr{PLFLT}}, PLINT, PLINT, PLINT, PLINT ) ),
( :plot3dc                  ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{Ptr{PLFLT}}, PLINT, PLINT, PLINT, Ptr{PLFLT}, PLINT ) ),
( :plot3dcl                 ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{Ptr{PLFLT}}, PLINT, PLINT, PLINT, Ptr{PLFLT}, PLINT, PLINT, PLINT, Ptr{PLINT}, Ptr{PLINT} ) ),
( :plpat                    ,( PLINT, Ptr{PLINT}, Ptr{PLINT} ) ),
( :plpath                   ,( PLINT, PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plpoin                   ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, PLINT ) ),
( :plpoin3                  ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, PLINT ) ),
( :plpoly3                  ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLINT}, PLINT ) ),
( :plprec                   ,( PLINT, PLINT ) ),
( :plpsty                   ,( PLINT, ) ),
( :plptex                   ,( PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLSTR ) ),
( :plptex3                  ,( PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLSTR ) ),
( :plreplot                 ,() ),
( :plschr                   ,( PLFLT, PLFLT ) ),
( :plscmap0                 ,( Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT}, PLINT ) ),
( :plscmap0a                ,( Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLFLT}, PLINT ) ),
( :plscmap0n                ,( PLINT, ) ),
( :plscmap1                 ,( Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT}, PLINT ) ),
( :plscmap1a                ,( Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLFLT}, PLINT ) ),
( :plscmap1l                ,( PLINT, PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLINT} ) ),
( :plscmap1la               ,( PLINT, PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLINT} ) ),
( :plscmap1n                ,( PLINT, ) ),
( :plscmap1_range           ,( PLFLT, PLFLT ) ),
( :plgcmap1_range           ,( Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plscol0                  ,( PLINT, PLINT, PLINT, PLINT ) ),
( :plscol0a                 ,( PLINT, PLINT, PLINT, PLINT, PLFLT ) ),
( :plscolbg                 ,( PLINT, PLINT, PLINT ) ),
( :plscolbga                ,( PLINT, PLINT, PLINT, PLFLT ) ),
( :plscolor                 ,( PLINT, ) ),
( :plscompression           ,( PLINT, ) ),
( :plsdev                   ,( PLSTR, ) ),
( :plsdidev                 ,( PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plsdimap                 ,( PLINT, PLINT, PLINT, PLINT, PLFLT, PLFLT ) ),
( :plsdiori                 ,( PLFLT, ) ),
( :plsdiplt                 ,( PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plsdiplz                 ,( PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plsesc                   ,( Cchar, ) ),
( :plsetopt                 ,( PLSTR, PLSTR ) ),
( :plsfam                   ,( PLINT, PLINT, PLINT ) ),
( :plsfci                   ,( PLUINT, ) ),
( :plsfnam                  ,( PLSTR, ) ),
( :plsfont                  ,( PLINT, PLINT, PLINT ) ),
( :plshade                  ,( Ptr{Ptr{PLFLT}}, PLINT, PLINT, Ptr{Void}, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLINT, PLFLT, PLFLT, PLINT, PLFLT, PLINT, PLFLT, Ptr{Void}, PLINT, Ptr{Void}, Ptr{Void} ) ),
( :plshade1                 ,( Ptr{PLFLT}, PLINT, PLINT, Ptr{Void}, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLINT, PLFLT, PLFLT, PLINT, PLFLT, PLINT, PLFLT, Ptr{Void}, PLINT, Ptr{Void}, Ptr{Void} ) ),
( :plshades                 ,( Ptr{Ptr{PLFLT}}, PLINT, PLINT, Ptr{Void}, PLFLT, PLFLT, PLFLT, PLFLT, Ptr{PLFLT}, PLINT, PLFLT, PLINT, PLFLT, Ptr{Void}, PLINT, Ptr{Void}, Ptr{Void} ) ),
( :plsdrawmode              ,( PLINT, ) ),
( :plslabelfunc             ,( Ptr{Void}, Ptr{Void} ) ),
( :plsmaj                   ,( PLFLT, PLFLT ) ),
( :plsmem                   ,( PLINT, PLINT, Ptr{Void} ) ),
( :plsmin                   ,( PLFLT, PLFLT ) ),
( :plsori                   ,( PLINT, ) ),
( :plspage                  ,( PLFLT, PLFLT, PLINT, PLINT, PLINT, PLINT ) ),
( :plspal0                  ,( PLSTR, ) ),
( :plspal1                  ,( PLSTR, PLINT ) ),
( :plspause                 ,( PLINT, ) ),
( :plsstrm                  ,( PLINT, ) ),
( :plssub                   ,( PLINT, PLINT ) ),
( :plssym                   ,( PLFLT, PLFLT ) ),
( :plstar                   ,( PLINT, PLINT ) ),
( :plstart                  ,( PLSTR, PLINT, PLINT ) ),
( :plstransform             ,( Ptr{Void}, Ptr{Void} ) ),
( :plstring                 ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, PLSTR ) ),
( :plstring3                ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, PLSTR ) ),
( :plstripa                 ,( PLINT, PLINT, PLFLT, PLFLT ) ),
( :plstripc                 ,( Ptr{PLINT}, PLSTR, PLSTR, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLINT, PLINT, PLINT, PLINT, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLSTR}, PLSTR, PLSTR, PLSTR ) ),
( :plstripd                 ,( PLINT, ) ),
( :plstyl                   ,( PLINT, Ptr{PLINT}, Ptr{PLINT} ) ),
( :plsurf3d                 ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{Ptr{PLFLT}}, PLINT, PLINT, PLINT, Ptr{PLFLT}, PLINT ) ),
( :plsurf3dl                ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{Ptr{PLFLT}}, PLINT, PLINT, PLINT, Ptr{PLFLT}, PLINT, PLINT, PLINT, Ptr{PLINT}, Ptr{PLINT} ) ),
( :plsvect                  ,( Ptr{PLFLT}, Ptr{PLFLT}, PLINT, PLINT ) ),
( :plsvpa                   ,( PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plsxax                   ,( PLINT, PLINT ) ),
( :plsyax                   ,( PLINT, PLINT ) ),
( :plsym                    ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, PLINT ) ),
( :plszax                   ,( PLINT, PLINT ) ),
( :pltext                   ,() ),
( :pltimefmt                ,( PLSTR, ) ),
( :plvasp                   ,( PLFLT, ) ),
( :plvect                   ,( Ptr{Ptr{PLFLT}}, Ptr{Ptr{PLFLT}}, PLINT, PLINT, PLFLT, Ptr{Void}, Ptr{Void} ) ),
( :plvpas                   ,( PLFLT, PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plvpor                   ,( PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plvsta                   ,() ),
( :plw3d                    ,( PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plwidth                  ,( PLFLT, ) ),
( :plwind                   ,( PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plxormod                 ,( PLINT, Ptr{PLINT} ) ),
( :plgpcnt                  ,( Ptr{PLINT}, ) ),
]

blk = quote end
for (func, arg_types) in plfuncs
    _arg_types = Expr(:tuple, [recurs_type(a) for a in arg_types]...)
    _args_in = Any[ Symbol(string('a',x)) for (x,t) in enumerate(arg_types) ]
    _fname = "c_"*string(func)
    push!(blk.args, :($(func)($(_args_in...)) = ccall( ($_fname, $libplplot ), Void, $_arg_types, $(_args_in...) )) )
    push!(blk.args, nothing)
end
eval(blk)

# transformation functions
blk = quote end
for (func, arg_types) in  [
( :pltr0                    ,( PLFLT, PLFLT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{Void}) ),
( :pltr1                    ,( PLFLT, PLFLT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{Void}) ),
( :pltr2                    ,( PLFLT, PLFLT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{Void}) ),
]
    _arg_types = Expr(:tuple, [recurs_type(a) for a in arg_types]...)
    _args_in = Any[ Symbol(string('a',x)) for (x,t) in enumerate(arg_types) ]
    _fname = string(func)
    push!(blk.args, :($(func)($(_args_in...)) = ccall( ($_fname, $libplplot ), Void, $_arg_types, $(_args_in...) )) )
    push!(blk.args, nothing)
end
eval(blk)

function devices(ndevs = 30)
    menustrs = fill(convert(Cstring, convert(Ptr{UInt8}, C_NULL)), ndevs)
    devnames = fill(convert(Cstring, convert(Ptr{UInt8}, C_NULL)), ndevs)
    p_ndev = Ref{Cint}(ndevs)
    ccall((:plgDevs, libplplot ), Void,
           (Ptr{Ptr{Cstring}}, Ptr{Ptr{Cstring}}, Ptr{Cint}),
            Ref{Ptr{Cstring}}(pointer(menustrs)),
            Ref{Ptr{Cstring}}(pointer(devnames)), p_ndev )
    ndevs = p_ndev[]
    devices = map(s->Symbol(unsafe_string(s)), devnames[1:ndevs])
    devmenus = map(unsafe_string, menustrs[1:ndevs])
    return Dict(zip(devices, devmenus))
end

function verison()
    pver = convert(Ptr{Cchar}, Libc.malloc(80))
    plgver(convert(Cstring, pver))
    ver = unsafe_string(pver)
    Libc.free(pver)
    return VersionNumber(ver)
end


@enum(PL_POSITION, POSITION_LEFT     = Cint(0x01),
                   POSITION_RIGHT    = Cint(0x02),
                   POSITION_TOP      = Cint(0x04),
                   POSITION_BOTTOM   = Cint(0x08),
                   POSITION_INSIDE   = Cint(0x10),
                   POSITION_OUTSIDE  = Cint(0x20),
                   POSITION_VIEWPORT = Cint(0x40),
                   POSITION_SUBPAGE  = Cint(0x80))

"""Flags used for position argument of both legend and colorbar"""
PL_POSITION

@enum(PL_LEGEND,LEGEND_NONE         = Cint(0x01),
                LEGEND_COLOR_BOX    = Cint(0x02),
                LEGEND_LINE         = Cint(0x04),
                LEGEND_SYMBOL       = Cint(0x08),
                LEGEND_TEXT_LEFT    = Cint(0x10),
                LEGEND_BACKGROUND   = Cint(0x20),
                LEGEND_BOUNDING_BOX = Cint(0x40),
                LEGEND_ROW_MAJOR    = Cint(0x80))

"""Flags used for legend parameters"""
PL_LEGEND
