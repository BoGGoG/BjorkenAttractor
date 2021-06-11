using MathLink

function math2Expr(symb::MathLink.WSymbol)
    Symbol(symb.name)
end
function math2Expr(num::Number)
    num
end
function math2Expr(expr::MathLink.WExpr)
    if expr.head.name=="Times"
        return Expr(:call, :*, map(math2Expr,expr.args)...)
    elseif expr.head.name=="Plus"
        return Expr(:call, :+,map(math2Expr,expr.args)...)
    elseif expr.head.name=="Power"
        return Expr(:call, :^, map(math2Expr,expr.args)...)
    elseif expr.head.name=="Rational"
        return  Expr(:call, ://, map(math2Expr,expr.args)...)
    else
        return Expr(:call, Symbol(expr.head.name), map(math2Expr,expr.args)...)
    end
end

macro genfun(expr,args)
    :($(Expr(:tuple,args.args...))->$expr)
end
genfun(expr,args) = :(@genfun $expr [$(args...)]) |> eval

# working with W``` ``` expression
DEQMath = W```(-t^(1/3) u^3 - u^4/(3 t^(2/3)) + u^5/(9 t^(5/3)) - (5 u^6)/(81 t^(8/3)) - u^7 Ss[u] - t^(1/3) u^4 Xi[t] - (u^6 Xi[t])/(9 t^(5/3)))/u^2
/.{Ss[u] -> Ss, Xi[t] -> Xi}``` |>weval
DEQJu = math2Expr(DEQMath);
DEQJuFun=genfun(DEQJu, [:t, :u, :Ss, :Xi]);
DEQJuFun(1,0.5, 0.5, 0.1)

# not working with string
MathString = "-t^(1/3) u^3"
MathStringSymbol = MathLink.WSymbol(MathString)
MathEval = weval(MathStringSymbol)
math2Expr(MathEval)


DEQ1Math = weval(W```Get["MathFile.wls"]```)
DEQ1Ju = math2Expr(DEQ1Math)
DEQ1JuFun = genfun(DEQ1Ju, [:t, :u, :Ss, :Xi])
DEQ1JuFun(1,0.5, 0.5, 0.1)
