from __future__ import annotations
from dataclasses import dataclass
from typing import Optional

# (reuses Term, Var, Lam, App, subst0 from the complete-development algorithm)

@dataclass(frozen=True)
class BTApprox: ...
@dataclass(frozen=True)
class BTBot(BTApprox): ...
@dataclass(frozen=True)
class BTNode(BTApprox):
    head: int
    args: tuple

def head_reduce(t: Term) -> Optional[Term]:
    if isinstance(t, App) and isinstance(t.fn, Lam):
        return subst0(t.arg, t.fn.body)
    if isinstance(t, App):
        r = head_reduce(t.fn)
        return App(r, t.arg) if r is not None else None
    return None

def extract_head(t: Term) -> Optional[tuple]:
    if isinstance(t, Var):
        return (t.idx, [])
    if isinstance(t, App):
        h = extract_head(t.fn)
        if h is None:
            return None
        n, args = h
        return (n, args + [t.arg])
    return None

def bohm_approx(fuel: int, t: Term) -> BTApprox:
    if fuel == 0:
        return BTBot()
    hr = head_reduce(t)
    if hr is not None:
        return bohm_approx(fuel - 1, hr)
    eh = extract_head(t)
    if eh is not None:
        hd, args = eh
        return BTNode(hd, tuple(bohm_approx(fuel - 1, a) for a in args))
    return BTBot()
