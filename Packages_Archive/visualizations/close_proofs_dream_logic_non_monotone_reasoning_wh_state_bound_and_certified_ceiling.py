from dataclasses import dataclass
from typing import Optional

@dataclass(frozen=True)
class Ty:
    arg: Optional["Ty"] = None
    res: Optional["Ty"] = None
    @property
    def is_base(self) -> bool:
        return self.arg is None and self.res is None

def base() -> Ty:
    return Ty(None, None)

def arrow(a: Ty, b: Ty) -> Ty:
    return Ty(a, b)

def depth(t: Ty) -> int:
    if t.is_base:
        return 0
    return 1 + max(depth(t.arg), depth(t.res))

def size(t: Ty) -> int:
    if t.is_base:
        return 1
    return 1 + size(t.arg) + size(t.res)

def tsb(t: Ty) -> int:
    if t.is_base:
        return 1
    return (tsb(t.arg) + 1) * (tsb(t.res) + 1)

def chain(d: int) -> Ty:
    t = base()
    for _ in range(d):
        t = arrow(base(), t)
    return t

def bushy(n: int) -> Ty:
    t = base()
    for _ in range(n):
        t = arrow(t, t)
    return t

def state_bound(t: Ty) -> int:
    """Algorithm A: compute tsb(A) by structural recursion (linear in size)."""
    return tsb(t)

def certified_ceiling(t: Ty) -> int:
    """Algorithm B: 2^size - 1, a guaranteed upper bound on tsb (Cor 8.1)."""
    return 2 ** size(t) - 1

if __name__ == "__main__":
    for t in (chain(4), bushy(4)):
        assert state_bound(t) <= certified_ceiling(t)
        print(f"size={size(t):2d}  tsb={state_bound(t):8d}  ceiling={certified_ceiling(t)}")
