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

def arrow_width(t: Ty) -> int:
    if t.is_base:
        return 0
    return 1 + arrow_width(t.arg) + arrow_width(t.res)

def regime(t: Ty) -> str:
    """Algorithm C: classify a type's growth regime from depth vs size."""
    d, s = depth(t), size(t)
    if s == 2 * d + 1:           # linear size in depth -> chain-like
        return "singly-exponential (chain-like)"
    if s == 2 ** (d + 1) - 1:    # maximal size at the depth -> bushy
        return "doubly-exponential (bushy)"
    return f"intermediate (bushiness score {s / max(d,1):.2f})"

if __name__ == "__main__":
    for t in (chain(4), bushy(4), arrow(bushy(2), chain(2))):
        print(f"depth={depth(t)} size={size(t)} width={arrow_width(t)} -> {regime(t)}")
