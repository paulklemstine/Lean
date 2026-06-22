from __future__ import annotations
import math

def eval_eml_only(e, env):
    """Total evaluator honoring junk conventions: log(y<=0)=0, inv(0)=0."""
    if isinstance(e, Const): return e.c
    if isinstance(e, Var):   return env[e.i]
    if isinstance(e, Add):   return eval_eml_only(e.a, env) + eval_eml_only(e.b, env)
    if isinstance(e, Mul):   return eval_eml_only(e.a, env) * eval_eml_only(e.b, env)
    if isinstance(e, Neg):   return -eval_eml_only(e.a, env)
    if isinstance(e, Inv):
        v = eval_eml_only(e.a, env); return 1.0 / v if v != 0.0 else 0.0
    if isinstance(e, Eml):
        x = eval_eml_only(e.a, env); y = eval_eml_only(e.b, env)
        return math.exp(x) - (math.log(y) if y > 0.0 else 0.0)
    raise TypeError(e)
