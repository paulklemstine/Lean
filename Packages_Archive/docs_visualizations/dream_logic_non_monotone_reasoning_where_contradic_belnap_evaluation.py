from enum import Enum
from typing import Union

class Belnap(Enum):
    F = "F"; N = "N"; B = "B"; T = "T"

def tmeet(a: Belnap, b: Belnap) -> Belnap:
    F, N, B, T = Belnap.F, Belnap.N, Belnap.B, Belnap.T
    table = {(F,F):F,(F,N):F,(F,B):F,(F,T):F,(N,F):F,(N,N):N,(N,B):F,(N,T):N,
             (B,F):F,(B,N):F,(B,B):B,(B,T):B,(T,F):F,(T,N):N,(T,B):B,(T,T):T}
    return table[(a,b)]

def tjoin(a: Belnap, b: Belnap) -> Belnap:
    F, N, B, T = Belnap.F, Belnap.N, Belnap.B, Belnap.T
    table = {(F,F):F,(F,N):N,(F,B):B,(F,T):T,(N,F):N,(N,N):N,(N,B):T,(N,T):T,
             (B,F):B,(B,N):T,(B,B):B,(B,T):T,(T,F):T,(T,N):T,(T,B):T,(T,T):T}
    return table[(a,b)]

def bneg(a: Belnap) -> Belnap:
    return {Belnap.T: Belnap.F, Belnap.F: Belnap.T, Belnap.B: Belnap.B, Belnap.N: Belnap.N}[a]

def designated(a: Belnap) -> bool:
    return a in (Belnap.T, Belnap.B)

# Formula AST
Formula = Union[str, tuple]

def evaluate(formula: Formula, valuation: dict[str, Belnap]) -> Belnap:
    """Evaluate a formula under a Belnap valuation."""
    if isinstance(formula, str):
        return valuation[formula]
    op = formula[0]
    if op == 'not':
        return bneg(evaluate(formula[1], valuation))
    elif op == 'and':
        return tmeet(evaluate(formula[1], valuation), evaluate(formula[2], valuation))
    elif op == 'or':
        return tjoin(evaluate(formula[1], valuation), evaluate(formula[2], valuation))
    raise ValueError(f"Unknown operator: {op}")

# Example: evaluate (p AND NOT p) OR q
val = {'p': Belnap.B, 'q': Belnap.F}
formula = ('or', ('and', 'p', ('not', 'p')), 'q')
result = evaluate(formula, val)
print(f"(p ∧ ¬p) ∨ q with p=B, q=F: {result.value} (designated: {designated(result)})")
print(f"Explosion would require this to be designated for ALL q — but with q=N:")
val2 = {'p': Belnap.B, 'q': Belnap.N}
result2 = evaluate(formula, val2)
print(f"(p ∧ ¬p) ∨ q with p=B, q=N: {result2.value} (designated: {designated(result2)})")