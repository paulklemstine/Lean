def transcendence_depth(expr):
    match expr:
        case Const(_) | Var(): return 0
        case Add(a,b) | Mul(a,b): return max(transcendence_depth(a), transcendence_depth(b))
        case Exp(a) | Log(a): return 1 + transcendence_depth(a)
        case EML(a,b): return 1 + max(transcendence_depth(a), transcendence_depth(b))