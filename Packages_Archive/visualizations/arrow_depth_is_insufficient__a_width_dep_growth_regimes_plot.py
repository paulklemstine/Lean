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

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

def make_plot(path: str = "growth_regimes.png", max_n: int = 6) -> None:
    """Plot chain (singly-exp) vs bushy (doubly-exp) tsb against depth,
    with the size-certified ceiling 2^size - 1, on a log scale."""
    ds = list(range(max_n + 1))
    chain_y = [tsb(chain(d)) for d in ds]
    bushy_y = [tsb(bushy(n)) for n in ds]
    ceil_y = [2 ** size(bushy(n)) - 1 for n in ds]
    plt.figure(figsize=(8, 5))
    plt.plot(ds, chain_y, "o-", label="chain tsb (singly exp in depth)")
    plt.plot(ds, bushy_y, "s-", label="bushy tsb (doubly exp in depth)")
    plt.plot(ds, ceil_y, "--", label="size ceiling 2^size - 1 (bushy)")
    plt.yscale("log")
    plt.xlabel("arrow depth")
    plt.ylabel("type state bound (log scale)")
    plt.title("Depth is insufficient: same depth, different complexity")
    plt.legend()
    plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig(path, dpi=130)
    print(f"wrote {path}")

if __name__ == "__main__":
    make_plot()
