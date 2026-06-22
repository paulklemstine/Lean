from __future__ import annotations

def compile_from_eml_only(e):
    """Reverse compiler D: EMLOnlyExpr -> EMLExpr (size <= 4 * size).
    Expands the sole transcendental node eml(a, b) into exp(a) - log(b)."""
    if isinstance(e, Const): return Const(e.c)
    if isinstance(e, Var):   return Var(e.i)
    if isinstance(e, Add):   return Add(compile_from_eml_only(e.a), compile_from_eml_only(e.b))
    if isinstance(e, Mul):   return Mul(compile_from_eml_only(e.a), compile_from_eml_only(e.b))
    if isinstance(e, Neg):   return Neg(compile_from_eml_only(e.a))
    if isinstance(e, Inv):   return Inv(compile_from_eml_only(e.a))
    if isinstance(e, Eml):   # eml(a, b) = exp(a) - log(b)
        return Add(Exp(compile_from_eml_only(e.a)),
                   Neg(Log(compile_from_eml_only(e.b))))
    raise TypeError(e)
