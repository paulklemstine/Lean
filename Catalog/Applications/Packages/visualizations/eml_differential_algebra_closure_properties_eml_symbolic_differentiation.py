def differentiate(expr):
    match expr:
        case Const(_): return Const(0)
        case Var(): return Const(1)
        case Add(a, b): return Add(differentiate(a), differentiate(b))
        case Mul(a, b): return Add(Mul(differentiate(a), b), Mul(a, differentiate(b)))
        case EML(a, b): return Sub(Mul(differentiate(a), EML(a, Const(1))), Div(differentiate(b), b))