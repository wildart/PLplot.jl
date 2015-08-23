typealias PLINT Cint
typealias PLFLT Cdouble
typealias PLSTR Cstring

recurs_type(dt::DataType) = dt <: Ptr ? Expr(:curly, :Ptr, recurs_type(dt.parameters[1])) : symbol(dt)

for (func, arg_types) in [
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
# ( :plcolorbar               c_plcolorbar
# ( :plconfigtime             c_plconfigtime( PLFLT scale, PLFLT offset1, PLFLT offset2, PLINT ccontrol, PLINT ifbtime_offset, PLINT year, PLINT month, PLINT day, PLINT hour, PLINT min, PLFLT sec );
# ( :plcont                   c_plcont( const PLFLT * const *f, PLINT nx, PLINT ny, PLINT kx, PLINT lx, PLINT ky, PLINT ly, const PLFLT *clevel, PLINT nlevel, Void ( *pltr )( PLFLT, PLFLT, PLFLT *, PLFLT *, PLPointer ), PLPointer pltr_data );
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
# ( :plgfci                   c_plgfci( PLUNICODE *p_fci );
( :plgfnam                  ,( PLSTR, ) ),
( :plgfont                  ,( Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT} ) ),
( :plglevel                 ,( Ptr{PLINT}, ) ),
( :plgpage                  ,( Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT} ) ),
( :plgra                    ,() ),
( :plgradient               ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, PLFLT ) ),
# ( :plgriddata               c_plgriddata( const PLFLT *x, const PLFLT *y, const PLFLT *z, PLINT npts, const PLFLT *xg, PLINT nptsx, const PLFLT *yg, PLINT nptsy, PLFLT **zg, PLINT type, PLFLT data );
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
# ( :plimage                  c_plimage
# ( :plimagefr                c_plimagefr
( :plinit                   ,() ),
( :pljoin                   ,( PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :pllab                    ,( PLSTR, PLSTR, PLSTR ) ),
# ( :pllegend                 c_pllegend
( :pllightsource            ,( PLFLT, PLFLT, PLFLT ) ),
( :plline                   ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :plline3                  ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT} ) ),
( :pllsty                   ,( PLINT, ) ),
( :plmap                    ,( Ptr{Void}, PLSTR, PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plmapline                ,( Ptr{Void}, PLSTR, PLFLT, PLFLT, PLFLT, PLFLT, Ptr{PLINT}, PLINT ) ),
( :plmapstring              ,( Ptr{Void}, PLSTR, PLSTR, PLFLT, PLFLT, PLFLT, PLFLT, Ptr{PLINT}, PLINT ) ),
( :plmaptex                 ,( Ptr{Void}, PLSTR, PLFLT, PLFLT, PLFLT, PLSTR, PLFLT, PLFLT, PLFLT, PLFLT, PLINT ) ),
( :plmapfill                ,( Ptr{Void}, PLSTR, PLFLT, PLFLT, PLFLT, PLFLT, Ptr{PLINT}, PLINT ) ),
# ( :plmeridians              c_plmeridians
# ( :plmesh                   c_plmesh( const PLFLT *x, const PLFLT *y, const PLFLT * const *z, PLINT nx, PLINT ny, PLINT opt );
# ( :plmeshc                  c_plmeshc( const PLFLT *x, const PLFLT *y, const PLFLT * const *z, PLINT nx, PLINT ny, PLINT opt, const PLFLT *clevel, PLINT nlevel );
( :plmkstrm                 ,( PLINT, ) ),
( :plmtex                   ,( Cstring, PLFLT, PLFLT, PLFLT, Cstring ) ),
( :plmtex3                  ,( Cstring, PLFLT, PLFLT, PLFLT, Cstring ) ),
# ( :plot3d                   c_plot3d
# ( :plot3dc                  c_plot3dc
# ( :plot3dcl                 c_plot3dcl
# ( :plparseopts              c_plparseopts( int *p_argc, const char **argv, PLINT mode );
( :plpat                    ,( PLINT, Ptr{PLINT}, Ptr{PLINT} ) ),
( :plpath                   ,( PLINT, PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plpoin                   ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, PLINT ) ),
( :plpoin3                  ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, PLINT ) ),
( :plpoly3                  ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLINT}, PLINT ) ),
( :plprec                   ,( PLINT, PLINT ) ),
( :plpsty                   ,( PLINT, ) ),
( :plptex                   ,( PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLSTR ) ),
( :plptex3                  ,( PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLSTR ) ),
# ( :plreplot                 c_plreplot
# ( :plrgbhls                 c_plrgbhls
# ( :plschr                   c_plschr
( :plscmap0                 ,( Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT}, PLINT ) ),
( :plscmap0a                ,( Ptr{PLINT}, Ptr{PLINT}, Ptr{PLINT}, Ptr{PLFLT}, PLINT ) ),
( :plscmap0n                ,( PLINT, ) ),
# ( :plscmap1                 c_plscmap1
# ( :plscmap1a                c_plscmap1a
# ( :plscmap1l                c_plscmap1l
# ( :plscmap1la               c_plscmap1la
# ( :plscmap1n                c_plscmap1n
# ( :plscmap1_range           c_plscmap1_range
# ( :plgcmap1_range           c_plgcmap1_range
( :plscol0                  ,( PLINT, PLINT, PLINT, PLINT ) ),
( :plscol0a                 ,( PLINT, PLINT, PLINT, PLINT, PLFLT ) ),
( :plscolbg                 ,( PLINT, PLINT, PLINT ) ),
( :plscolbga                ,( PLINT, PLINT, PLINT, PLFLT ) ),
( :plscolor                 ,( PLINT, ) ),
( :plscompression           ,( PLINT, ) ),
( :plsdev                   ,( PLSTR, ) ),
# ( :plsdidev                 c_plsdidev
# ( :plsdimap                 c_plsdimap
# ( :plsdiori                 c_plsdiori
# ( :plsdiplt                 c_plsdiplt
# ( :plsdiplz                 c_plsdiplz
# ( :plseed                   c_plseed
# ( :plsesc                   c_plsesc
# ( :plsetopt                 c_plsetopt
# ( :plsfam                   c_plsfam
# ( :plsfci                   c_plsfci
# ( :plsfnam                  c_plsfnam
# ( :plsfont                  c_plsfont
# ( :plshade                  c_plshade
# ( :plshade1                 c_plshade1
# ( :plshades                 c_plshades
# ( :plslabelfunc             c_plslabelfunc
( :plsmaj                   ,( PLFLT, PLFLT ) ),
( :plsmem                   ,( PLINT, PLINT, Ptr{Void} ) ),
( :plsmem                   ,( PLINT, PLINT, Ptr{Void} ) ),
( :plsmin                   ,( PLFLT, PLFLT ) ),
( :plsdraode                ,( PLINT, ) ),
( :plsori                   ,( PLINT, ) ),
# ( :plspage                  c_plspage
# ( :plspal0                  c_plspal0
# ( :plspal1                  c_plspal1
( :plspause                 ,( PLINT, ) ),
( :plsstrm                  ,( PLINT, ) ),
( :plssub                   ,( PLINT, PLINT ) ),
( :plssym                   ,( PLFLT, PLFLT ) ),
( :plstar                   ,( PLINT, PLINT ) ),
( :plstart                  ,( PLSTR, PLINT, PLINT ) ),
# ( :plstransform             c_plstransform
( :plstring                 ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, PLSTR ) ),
( :plstring3                ,( PLINT, Ptr{PLFLT}, Ptr{PLFLT}, Ptr{PLFLT}, PLSTR ) ),
( :plstripa                 ,( PLINT, PLINT, PLFLT, PLFLT ) ),
( :plstripc                 ,( Ptr{PLINT}, Cstring, Cstring, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLFLT, PLINT, PLINT, PLINT, PLINT, Ptr{PLINT}, Ptr{PLINT}, Ptr{Cstring}, Cstring, Cstring, Cstring ) ),
( :plstripd                 ,( PLINT, ) ),
( :plstyl                   ,( PLINT, Ptr{PLINT}, Ptr{PLINT} ) ),
# ( :plsurf3d                 c_plsurf3d
# ( :plsurf3dl                c_plsurf3dl
# ( :plsvect                  c_plsvect
( :plsvpa                   ,( PLFLT, PLFLT, PLFLT, PLFLT ) ),
# ( :plsxax                   c_plsxax
( :plsyax                   ,( PLINT, PLINT ) ),
# ( :plsym                    c_plsym
# ( :plszax                   c_plszax
# ( :pltext                   c_pltext
# ( :pltimefmt                c_pltimefmt
# ( :plvasp                   c_plvasp
# ( :plvect                   c_plvect
# ( :plvpas                   c_plvpas
( :plvpor                   ,( PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plvsta                   ,() ),
# ( :plw3d                    c_plw3d
( :plwidth                  ,( PLFLT, ) ),
( :plwind                   ,( PLFLT, PLFLT, PLFLT, PLFLT ) ),
( :plxormod                 ,( PLINT, Ptr{PLINT} ) )
]
    _arg_types = Expr(:tuple, [recurs_type(a) for a in arg_types]...)
    _args_in = Any[ symbol(string('a',x)) for (x,t) in enumerate(arg_types) ]
    _fname = "c_"*string(func)
    eval(quote
        $(func)($(_args_in...)) = ccall( ($_fname, libplplot ), Void, $_arg_types, $(_args_in...) )
    end)
end