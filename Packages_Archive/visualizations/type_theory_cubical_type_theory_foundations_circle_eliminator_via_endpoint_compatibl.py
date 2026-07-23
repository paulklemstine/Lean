from dataclasses import dataclass
from typing import Callable, TypeVar
X = TypeVar("X")

@dataclass(frozen=True)
class Circle:
    rep: float  # canonical representative in [0, 1)

def loop(t: float) -> Circle:
    """Canonical interval map into the circle; glues endpoint 1 to 0."""
    return Circle(0.0 if abs(t - 1.0) <= 1e-12 else t)

def circle_rec(f: Callable[[float], X], h: bool) -> Callable[[Circle], X]:
    """Circle.rec': lift an interval map f with f(0)=f(1) (toll h) to S^1 -> X."""
    if not h:
        raise ValueError("endpoint toll f(0)=f(1) not satisfied")
    def induced(c: Circle) -> X:
        return f(c.rep)
    return induced
