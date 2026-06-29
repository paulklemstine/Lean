"""
demo.py — Arrow-Depth Is Insufficient: Semantic State Complexity for Simple Types
================================================================================

Numerical demonstrations of the main results from the formal development:

  Theorem 1 : tsb(A) = complexity(A)                       (same recurrence)
  Theorem 2 : depth(A) <= complexity(A)
  Theorem 3 : ChainTy(A)  =>  tsb(A) <= 3^(depth(A)+1)     (singly exponential)
  Theorem 4 : depth(bushy(n)) = n
  Theorem 5 : tsb(bushy(n+1)) = (tsb(bushy(n)) + 1)^2
  Theorem 6 : 2^(2^n) <= tsb(bushy(n)) + 1                 (doubly exponential)
  Theorem 7 : no constant c gives tsb(A) <= c^(depth(A)+1) for all A
  Theorem 8 : tsb(A) + 1 <= 2^(size(A))                    (universal ceiling)

Everything is self-contained: no imports beyond the standard library, and every
helper is inlined. Run with `python3 demo.py`.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Union


# ---------------------------------------------------------------------------
# Simple types:  Ty ::= o | A -> B
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Ty:
    """A simple type.

    If `arg is None and res is None` the type is the base type `o`.
    Otherwise it is the arrow type `arg -> res`.
    """
    arg: Optional["Ty"] = None
    res: Optional["Ty"] = None

    @property
    def is_base(self) -> bool:
        return self.arg is None and self.res is None


def base() -> Ty:
    """The base type o."""
    return Ty(None, None)


def arrow(a: Ty, b: Ty) -> Ty:
    """The function type a -> b."""
    return Ty(a, b)


# ---------------------------------------------------------------------------
# Structural measures
# ---------------------------------------------------------------------------

def depth(t: Ty) -> int:
    """Arrow-nesting depth.  depth(o)=0, depth(A->B)=1+max(depth A, depth B)."""
    if t.is_base:
        return 0
    assert t.arg is not None and t.res is not None
    return 1 + max(depth(t.arg), depth(t.res))


def size(t: Ty) -> int:
    """Constructor count.  size(o)=1, size(A->B)=1+size A+size B."""
    if t.is_base:
        return 1
    assert t.arg is not None and t.res is not None
    return 1 + size(t.arg) + size(t.res)


def arrow_width(t: Ty) -> int:
    """Total number of arrow constructors."""
    if t.is_base:
        return 0
    assert t.arg is not None and t.res is not None
    return 1 + arrow_width(t.arg) + arrow_width(t.res)


def complexity(t: Ty) -> int:
    """Multiplicative complexity.  c(o)=1, c(A->B)=(c A+1)(c B+1)."""
    if t.is_base:
        return 1
    assert t.arg is not None and t.res is not None
    return (complexity(t.arg) + 1) * (complexity(t.res) + 1)


def tsb(t: Ty) -> int:
    """Type state bound.  tsb(o)=1, tsb(A->B)=(tsb A+1)(tsb B+1)."""
    if t.is_base:
        return 1
    assert t.arg is not None and t.res is not None
    return (tsb(t.arg) + 1) * (tsb(t.res) + 1)


def is_chain(t: Ty) -> bool:
    """ChainTy: right-spined arrows whose every left argument is the base type."""
    if t.is_base:
        return True
    assert t.arg is not None and t.res is not None
    return t.arg.is_base and is_chain(t.res)


def predicted_bound(t: Ty) -> int:
    """Size-certified ceiling 2^size - 1 (Corollary 8.1)."""
    return 2 ** size(t) - 1


# ---------------------------------------------------------------------------
# Canonical type families
# ---------------------------------------------------------------------------

def chain(d: int) -> Ty:
    """The chain o -> o -> ... -> o of depth d (a function pipeline)."""
    t = base()
    for _ in range(d):
        t = arrow(base(), t)
    return t


def bushy(n: int) -> Ty:
    """bushy(0)=o, bushy(n+1)=bushy(n)->bushy(n): balanced binary arrow tree."""
    t = base()
    for _ in range(n):
        t = arrow(t, t)
    return t


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_state_bound_equals_complexity(max_n: int = 6) -> None:
    """Theorem 1: tsb and complexity agree on every type we sample."""
    print("=" * 72)
    print("Theorem 1:  tsb(A) = complexity(A)")
    print("=" * 72)
    samples = [base(), arrow(base(), base()), chain(3), bushy(3),
               arrow(bushy(2), chain(2))]
    for t in samples:
        assert tsb(t) == complexity(t)
        print(f"  size={size(t):3d}  depth={depth(t):2d}  "
              f"tsb={tsb(t):>12d}  complexity={complexity(t):>12d}  OK")
    print()


def demo_depth_le_complexity() -> None:
    """Theorem 2: depth(A) <= complexity(A) everywhere."""
    print("=" * 72)
    print("Theorem 2:  depth(A) <= complexity(A)")
    print("=" * 72)
    for t in [base(), chain(5), bushy(4), arrow(bushy(2), chain(3))]:
        assert depth(t) <= complexity(t)
        print(f"  depth={depth(t):3d}  <=  complexity={complexity(t):>12d}  OK")
    print()


def demo_chain_singly_exponential(max_d: int = 10) -> None:
    """Theorem 3: chains stay under 3^(depth+1) (singly exponential)."""
    print("=" * 72)
    print("Theorem 3:  ChainTy(A)  =>  tsb(A) <= 3^(depth(A)+1)")
    print("=" * 72)
    print(f"  {'depth':>5} {'tsb(chain)':>14} {'3^(d+1)':>16} "
          f"{'closed 3*2^d-2':>16}")
    for d in range(max_d + 1):
        t = chain(d)
        assert is_chain(t)
        bound = 3 ** (depth(t) + 1)
        closed = 3 * 2 ** d - 2
        assert tsb(t) <= bound and tsb(t) == closed
        print(f"  {d:>5} {tsb(t):>14} {bound:>16} {closed:>16}")
    print()


def demo_bushy_doubly_exponential(max_n: int = 6) -> None:
    """Theorems 4-6: bushy depth, squaring recurrence, 2^(2^n) lower bound."""
    print("=" * 72)
    print("Theorems 4-6:  bushy depth = n,  tsb(bushy(n+1))=(tsb+1)^2,")
    print("               and  2^(2^n) <= tsb(bushy(n)) + 1")
    print("=" * 72)
    print(f"  {'n':>2} {'depth':>5} {'tsb(bushy n)':>22} {'2^(2^n) lower':>22}")
    prev: Optional[int] = None
    for n in range(max_n + 1):
        t = bushy(n)
        assert depth(t) == n                              # Theorem 4
        if prev is not None:                             # Theorem 5
            assert tsb(t) == (prev + 1) ** 2
        lower = 2 ** (2 ** n)
        assert lower <= tsb(t) + 1                        # Theorem 6
        shown = str(tsb(t)) if tsb(t) < 10 ** 18 else f"{tsb(t):.3e} (huge)"
        lshown = str(lower) if lower < 10 ** 18 else f"{lower:.3e} (huge)"
        print(f"  {n:>2} {depth(t):>5} {shown:>22} {lshown:>22}")
        prev = tsb(t)
    print()


def demo_impossibility(c_values: tuple = (2, 5, 100, 10 ** 6)) -> None:
    """Theorem 7: for any fixed c, some bushy type breaks tsb <= c^(depth+1)."""
    print("=" * 72)
    print("Theorem 7:  NO constant c gives tsb(A) <= c^(depth(A)+1) for all A")
    print("=" * 72)
    for c in c_values:
        n = 0
        while True:
            t = bushy(n)
            if tsb(t) > c ** (depth(t) + 1):
                print(f"  c={c:>9}:  bushy({n}) breaks it  "
                      f"(tsb={tsb(t):.3e} > c^(depth+1)={float(c)**(n+1):.3e})")
                break
            n += 1
            if n > 40:  # safety; never reached in practice
                raise RuntimeError("unexpected")
    print("  => every candidate constant c is defeated by a tall enough bush.\n")


def demo_size_ceiling(max_n: int = 6) -> None:
    """Theorem 8 / Cor 8.1: tsb(A)+1 <= 2^size(A) for every type."""
    print("=" * 72)
    print("Theorem 8:  tsb(A) + 1 <= 2^size(A)   (universal, size-certified)")
    print("=" * 72)
    families = [("chain", chain), ("bushy", bushy)]
    for name, fam in families:
        print(f"  {name}:")
        for k in range(max_n + 1):
            t = fam(k)
            assert tsb(t) + 1 <= 2 ** size(t)
            assert tsb(t) <= predicted_bound(t)
            ratio = (tsb(t) + 1) / 2 ** size(t)
            print(f"    k={k:>2}  size={size(t):>3}  tsb+1={tsb(t) + 1:>22}  "
                  f"<= 2^size  (fill ratio {ratio:.3f})")
    print()


def demo_width_depth_tradeoff(budget: int = 4) -> None:
    """Same depth, different width: the engine behind the impossibility."""
    print("=" * 72)
    print("Width-depth tradeoff: equal depth, wildly different complexity")
    print("=" * 72)
    d = budget
    c, b = chain(d), bushy(d)
    print(f"  depth(chain({d}))  = {depth(c)},  width={arrow_width(c):>3},  "
          f"size={size(c):>3},  tsb={tsb(c)}")
    print(f"  depth(bushy({d}))  = {depth(b)},  width={arrow_width(b):>3},  "
          f"size={size(b):>3},  tsb={tsb(b)}")
    print(f"  Same depth {d}; bush is larger by a factor of {tsb(b)//tsb(c):,}.")
    print()


def main() -> None:
    print("\nArrow-Depth Is Insufficient — numerical demonstrations\n")
    demo_state_bound_equals_complexity()
    demo_depth_le_complexity()
    demo_chain_singly_exponential()
    demo_bushy_doubly_exponential()
    demo_impossibility()
    demo_size_ceiling()
    demo_width_depth_tradeoff()
    print("All assertions passed: the formal results hold on every sampled type.")


if __name__ == "__main__":
    main()
