"""
demo.py — Numerical demonstration of arrow-depth complexity for simple types.

This script reproduces, with concrete numbers, the main results of
"Arrow-Depth Insufficiency and Size-Exponential Sharpness for the Semantic
State Complexity of Simple Types":

    * typeStateBound coincides with `complexity`            (Theorem 4.1)
    * depth <= complexity                                   (Corollary 4.2)
    * chain types: typeStateBound(A) <= 3^(depth+1)         (Theorem 4.3)
    * bushy depth = n                                       (Theorem 4.4)
    * bushy recurrence: tsb(bushy(n+1)) = (tsb(bushy n)+1)^2(Theorem 4.5)
    * bushy lower bound: 2^(2^n) <= tsb(bushy n)+1          (Theorem 4.6)
    * impossibility: no constant c with tsb <= c^(depth+1)  (Theorem 4.7)
    * size bound: tsb(A)+1 <= 2^size(A)                     (Theorem 4.8)
    * width-size identity: 2*arrowWidth+1 = size            (Theorem 5.1)
    * bushy invariants: width=2^n-1, size=2^(n+1)-1         (Theorem 5.4)

Everything is self-contained and uses only the standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Union


# ---------------------------------------------------------------------------
# Simple types:  A, B ::= base | arrow A B
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Base:
    """The single base type."""
    pass


@dataclass(frozen=True)
class Arrow:
    """A function type `dom -> cod`."""
    dom: "Ty"
    cod: "Ty"


Ty = Union[Base, Arrow]


# ---------------------------------------------------------------------------
# Structural measures (all O(size) post-order traversals)
# ---------------------------------------------------------------------------

def depth(a: Ty) -> int:
    """Arrow depth: 0 for base, 1 + max(depth dom, depth cod) for arrow."""
    if isinstance(a, Base):
        return 0
    return 1 + max(depth(a.dom), depth(a.cod))


def size(a: Ty) -> int:
    """Number of constructors: 1 for base, 1 + size dom + size cod for arrow."""
    if isinstance(a, Base):
        return 1
    return 1 + size(a.dom) + size(a.cod)


def complexity(a: Ty) -> int:
    """Multiplicative complexity measure (Definition 2.4)."""
    if isinstance(a, Base):
        return 1
    return (complexity(a.dom) + 1) * (complexity(a.cod) + 1)


def type_state_bound(a: Ty) -> int:
    """Semantic state bound (Definition 2.5), same recurrence as complexity."""
    if isinstance(a, Base):
        return 1
    return (type_state_bound(a.dom) + 1) * (type_state_bound(a.cod) + 1)


def arrow_width(a: Ty) -> int:
    """Number of arrow constructors (Definition 2.6)."""
    if isinstance(a, Base):
        return 0
    return 1 + arrow_width(a.dom) + arrow_width(a.cod)


def predicted_bound(a: Ty) -> int:
    """Certified, size-computable upper bound 2^size - 1 (Definition 3.3)."""
    return 2 ** size(a) - 1


# ---------------------------------------------------------------------------
# The two probing families
# ---------------------------------------------------------------------------

def chain(d: int) -> Ty:
    """Chain type of depth d:  base -> base -> ... -> base  (d arrows)."""
    a: Ty = Base()
    for _ in range(d):
        a = Arrow(Base(), a)
    return a


def is_chain(a: Ty) -> bool:
    """ChainTy predicate: right-spine with every left argument equal to base."""
    if isinstance(a, Base):
        return True
    return isinstance(a.dom, Base) and is_chain(a.cod)


def bushy(n: int) -> Ty:
    """Balanced binary arrow tree: bushy(0)=base, bushy(n+1)=bushy n -> bushy n."""
    a: Ty = Base()
    for _ in range(n):
        a = Arrow(a, a)
    return a


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_canonicity() -> None:
    print("=" * 70)
    print("Theorem 4.1 / 4.2:  typeStateBound = complexity,  depth <= complexity")
    print("=" * 70)
    samples = [
        Base(),
        Arrow(Base(), Base()),
        Arrow(Arrow(Base(), Base()), Base()),
        bushy(3),
        chain(4),
    ]
    for a in samples:
        tsb, cx, dp = type_state_bound(a), complexity(a), depth(a)
        assert tsb == cx, "typeStateBound must equal complexity"
        assert dp <= cx, "depth must be <= complexity"
        print(f"  tsb={tsb:>8}  complexity={cx:>8}  depth={dp:>3}  (tsb==cx: {tsb==cx})")
    print()


def demo_chains() -> None:
    print("=" * 70)
    print("Theorem 4.3:  chains are SINGLY exponential -- tsb <= 3^(depth+1)")
    print("=" * 70)
    print(f"  {'depth':>5} {'tsb':>8} {'3^(d+1)':>12} {'<=?':>5}")
    for d in range(7):
        a = chain(d)
        assert is_chain(a)
        tsb = type_state_bound(a)
        ceil = 3 ** (depth(a) + 1)
        assert tsb <= ceil
        print(f"  {depth(a):>5} {tsb:>8} {ceil:>12} {str(tsb <= ceil):>5}")
    print()


def demo_bushes() -> None:
    print("=" * 70)
    print("Theorems 4.4-4.6:  bushes are DOUBLY exponential -- 2^(2^n) <= tsb+1")
    print("=" * 70)
    print(f"  {'n':>3} {'depth':>5} {'tsb':>12} {'tsb+1':>12} {'2^(2^n)':>12} {'>=?':>5}")
    prev = None
    for n in range(6):
        a = bushy(n)
        assert depth(a) == n, "bushy depth must equal n"
        tsb = type_state_bound(a)
        tower = 2 ** (2 ** n)
        assert tower <= tsb + 1
        if prev is not None:  # recurrence check
            assert tsb == (prev + 1) ** 2, "bushy recurrence tsb=(prev+1)^2"
        prev = tsb
        print(f"  {n:>3} {depth(a):>5} {tsb:>12} {tsb+1:>12} {tower:>12} {str(tower <= tsb+1):>5}")
    print()


def demo_impossibility(max_c: int = 6) -> None:
    print("=" * 70)
    print("Theorem 4.7:  no constant c gives  tsb(A) <= c^(depth+1)  for all A")
    print("=" * 70)
    for c in range(1, max_c + 1):
        # find a bushy witness that breaks the candidate constant c
        witness = None
        for n in range(0, 40):
            a = bushy(n)
            if type_state_bound(a) > c ** (depth(a) + 1):
                witness = n
                break
        assert witness is not None, "every c must be defeated"
        a = bushy(witness)
        print(f"  c={c}: defeated by bushy({witness})  "
              f"tsb={type_state_bound(a)} > c^(depth+1)={c ** (depth(a) + 1)}")
    print()


def demo_size_bound() -> None:
    print("=" * 70)
    print("Theorem 4.8 / Cor 4.9:  tsb(A)+1 <= 2^size(A)  (saturated by bushes)")
    print("=" * 70)
    print(f"  {'type':>14} {'tsb':>12} {'tsb+1':>12} {'2^size':>14} {'pred':>14}")
    cases = [("base", Base()),
             ("a->a", Arrow(Base(), Base())),
             ("chain(4)", chain(4)),
             ("bushy(3)", bushy(3)),
             ("bushy(4)", bushy(4))]
    for name, a in cases:
        tsb = type_state_bound(a)
        cap = 2 ** size(a)
        assert tsb + 1 <= cap
        assert tsb <= predicted_bound(a)
        print(f"  {name:>14} {tsb:>12} {tsb+1:>12} {cap:>14} {predicted_bound(a):>14}")
    # bushes match the ORDER of the bound: double-exp in depth = single-exp in size
    print()
    print("  Order check (Theorem 5.4): for bushy(n), size = 2^(n+1)-1, so the")
    print("  double-exponential-in-depth lower bound 2^(2^n) <= tsb+1 is exactly")
    print("  a SINGLE exponential in size -- matching the order of 2^size:")
    print(f"  {'n':>3} {'tsb+1':>14} {'2^(2^n) (lower)':>18} {'2^size (upper)':>18}")
    for n in range(5):
        a = bushy(n)
        lo = 2 ** (2 ** n)
        hi = 2 ** size(a)
        assert lo <= type_state_bound(a) + 1 <= hi
        print(f"  {n:>3} {type_state_bound(a)+1:>14} {lo:>18} {hi:>18}")
    print()


def demo_width_identity() -> None:
    print("=" * 70)
    print("Theorems 5.1 / 5.3 / 5.4:  width-size identity and bushy invariants")
    print("=" * 70)
    for a in [Base(), chain(3), bushy(3), Arrow(Arrow(Base(), Base()), Base())]:
        assert 2 * arrow_width(a) + 1 == size(a), "2*width+1 = size"
    for d in range(5):  # chains: depth == width
        assert depth(chain(d)) == arrow_width(chain(d))
    print("  width-size identity 2*arrowWidth+1 = size: verified on all samples")
    print("  chains satisfy depth == arrowWidth: verified")
    print(f"  {'n':>3} {'width=2^n-1':>12} {'size=2^(n+1)-1':>16}")
    for n in range(6):
        a = bushy(n)
        assert arrow_width(a) == 2 ** n - 1
        assert size(a) == 2 ** (n + 1) - 1
        print(f"  {n:>3} {arrow_width(a):>12} {size(a):>16}")
    print()


def main() -> None:
    demo_canonicity()
    demo_chains()
    demo_bushes()
    demo_impossibility()
    demo_size_bound()
    demo_width_identity()
    print("All numerical checks passed: depth is insufficient, size is sharp.")


if __name__ == "__main__":
    main()
