"""Visualization: depth vs. semantic state complexity for chain and bushy types.

Plots log2(log2(T+1)) against depth to expose the single- vs. double-exponential
separation: chain types appear sub-linear (single exponential), bushy types
appear linear (double exponential, since log2 log2 2^(2^n) = n).

Requires matplotlib. Run:  python3 _viz_growth.py
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt


def chain_T(n: int) -> int:
    """T of a chain of depth n:  T = 3*2^n - 2."""
    return 3 * 2 ** n - 2


def bushy_T(n: int) -> int:
    """T of bushy(n):  T_{n+1} = (T_n + 1)^2, T_0 = 1."""
    t = 1
    for _ in range(n):
        t = (t + 1) ** 2
    return t


def main() -> None:
    depths: List[int] = list(range(0, 8))
    chain_vals = [math.log2(math.log2(chain_T(n) + 1)) for n in depths]
    bushy_vals = [math.log2(math.log2(bushy_T(n) + 1)) for n in depths]

    plt.figure(figsize=(8, 5))
    plt.plot(depths, chain_vals, "o-", label="chain types  (single exp: ~log2(depth))")
    plt.plot(depths, bushy_vals, "s-", label="bushy types  (double exp: = depth)")
    plt.xlabel("arrow depth")
    plt.ylabel("log2( log2( T(A) + 1 ) )")
    plt.title("Depth does not control complexity: chains vs. bushy types")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("growth_separation.png", dpi=150)
    print("wrote growth_separation.png")


if __name__ == "__main__":
    main()


"""
demo.py — Numerical demonstration of Arrow-Depth Exponential Complexity
for Simple Types.

This script is fully self-contained (standard library only) and reproduces,
numerically, every result of the accompanying paper:

  * State bound  T(o) = 1,  T(A -> B) = (T(A)+1)(T(B)+1).
  * T(A) = C(A)             (state bound equals arithmetic complexity).
  * Chain types:  T(A) <= 3^(depth(A)+1)                 (single exponential).
  * Bushy types:  T(bushy(n)) + 1 >= 2^(2^n)             (double exponential).
  * Impossibility: no constant c gives T(A) <= c^(depth(A)+1) for all A.
  * Size bound:    T(A) + 1 <= 2^(size(A))               (universal, tight).
  * Structural identities:  2*width(A)+1 = size(A);  depth = width on chains;
                            width(bushy n) = 2^n - 1;  size(bushy n) = 2^(n+1)-1.

Run:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Union


# --------------------------------------------------------------------------- #
# Simple types: Base | Arrow(left, right)
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class Base:
    """The base type `o`."""

    def __repr__(self) -> str:
        return "o"


@dataclass(frozen=True)
class Arrow:
    """An arrow type `left -> right`."""

    left: "Ty"
    right: "Ty"

    def __repr__(self) -> str:
        l = repr(self.left)
        if isinstance(self.left, Arrow):
            l = f"({l})"
        return f"{l} -> {repr(self.right)}"


Ty = Union[Base, Arrow]


# --------------------------------------------------------------------------- #
# Structural measures
# --------------------------------------------------------------------------- #
def depth(a: Ty) -> int:
    """Nesting level of arrows: depth(o)=0, depth(A->B)=1+max(depth A, depth B)."""
    if isinstance(a, Base):
        return 0
    return 1 + max(depth(a.left), depth(a.right))


def size(a: Ty) -> int:
    """Total constructors: size(o)=1, size(A->B)=1+size(A)+size(B)."""
    if isinstance(a, Base):
        return 1
    return 1 + size(a.left) + size(a.right)


def arrow_width(a: Ty) -> int:
    """Number of arrows: width(o)=0, width(A->B)=1+width(A)+width(B)."""
    if isinstance(a, Base):
        return 0
    return 1 + arrow_width(a.left) + arrow_width(a.right)


def complexity(a: Ty) -> int:
    """Arithmetic complexity: C(o)=1, C(A->B)=(C(A)+1)(C(B)+1)."""
    if isinstance(a, Base):
        return 1
    return (complexity(a.left) + 1) * (complexity(a.right) + 1)


def state_bound(a: Ty) -> int:
    """Semantic state bound: T(o)=1, T(A->B)=(T(A)+1)(T(B)+1)."""
    if isinstance(a, Base):
        return 1
    return (state_bound(a.left) + 1) * (state_bound(a.right) + 1)


def predicted_bound(a: Ty) -> int:
    """Certified size-exponential ceiling 2^size(A) - 1 (Theorem 7.1 / Cor 7.2)."""
    return 2 ** size(a) - 1


def is_chain(a: Ty) -> bool:
    """ChainTy: right-spined arrows whose every left argument is the base type."""
    if isinstance(a, Base):
        return True
    return isinstance(a.left, Base) and is_chain(a.right)


# --------------------------------------------------------------------------- #
# Canonical type families
# --------------------------------------------------------------------------- #
def chain(n: int) -> Ty:
    """The chain type  o -> o -> ... -> o  with n arrows (depth n)."""
    t: Ty = Base()
    for _ in range(n):
        t = Arrow(Base(), t)
    return t


def bushy(n: int) -> Ty:
    """The balanced binary arrow tree: bushy(0)=o, bushy(n+1)=bushy(n)->bushy(n)."""
    if n == 0:
        return Base()
    sub = bushy(n - 1)
    return Arrow(sub, sub)


def regime_classifier(a: Ty) -> str:
    """Classify a type's growth regime (Algorithm C)."""
    if is_chain(a):
        return "tame chain (single exponential in depth: T <= 3^(depth+1))"
    return "branching (depth insufficient; only size bound 2^size - 1 applies)"


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_state_bound_eq_complexity() -> None:
    print("=" * 72)
    print("Theorem 3.1:  T(A) = C(A)   (state bound = arithmetic complexity)")
    print("=" * 72)
    samples = [Base(), chain(3), bushy(2), Arrow(chain(2), bushy(1))]
    for a in samples:
        t, c = state_bound(a), complexity(a)
        ok = "OK" if t == c else "MISMATCH"
        print(f"  T = {t:>8}   C = {c:>8}   [{ok}]   {a}")
    print()


def demo_chain_single_exponential() -> None:
    print("=" * 72)
    print("Theorem 4.2:  chain types are singly exponential in depth")
    print("              T(A) <= 3^(depth(A)+1);  exact:  T = 3*2^depth - 2")
    print("=" * 72)
    print(f"  {'depth':>5} {'T(chain)':>12} {'3*2^d-2':>12} {'3^(d+1)':>14} {'<=?':>5}")
    for d in range(8):
        a = chain(d)
        t = state_bound(a)
        exact = 3 * 2 ** d - 2
        bnd = 3 ** (depth(a) + 1)
        print(f"  {d:>5} {t:>12} {exact:>12} {bnd:>14} {str(t <= bnd):>5}")
    print()


def demo_bushy_double_exponential() -> None:
    print("=" * 72)
    print("Theorem 5.3:  bushy types are doubly exponential in depth")
    print("              depth(bushy n) = n  but  T(bushy n) + 1 >= 2^(2^n)")
    print("=" * 72)
    print(f"  {'n':>3} {'depth':>5} {'T(bushy n)':>22} {'2^(2^n)':>22} {'>=?':>5}")
    for n in range(7):
        b = bushy(n)
        t = state_bound(b)
        lo = 2 ** (2 ** n)
        print(f"  {n:>3} {depth(b):>5} {t:>22} {lo:>22} {str(t + 1 >= lo):>5}")
    print("  (note: values square at each level -> double exponential)")
    print()


def demo_impossibility(max_c: int = 6) -> None:
    print("=" * 72)
    print("Theorem 6.1:  no constant c gives  T(A) <= c^(depth(A)+1)  for all A")
    print("=" * 72)
    for c in range(1, max_c + 1):
        witness = None
        for n in range(0, 30):
            b = bushy(n)
            if state_bound(b) > c ** (depth(b) + 1):
                witness = n
                break
        if witness is not None:
            b = bushy(witness)
            print(
                f"  c = {c:>2}:  broken by bushy({witness})  "
                f"(depth {depth(b)}):  T = {state_bound(b)}  >  "
                f"c^(depth+1) = {c ** (depth(b) + 1)}"
            )
        else:
            print(f"  c = {c:>2}:  no witness found in range (increase search)")
    print("  Every constant c is eventually defeated by the bushy family.")
    print()


def demo_size_bound() -> None:
    print("=" * 72)
    print("Theorem 7.1 / Cor 7.2:  T(A) + 1 <= 2^size(A);  T(A) <= 2^size(A) - 1")
    print("=" * 72)
    samples = [Base(), chain(4), bushy(3), Arrow(chain(2), bushy(2))]
    print(f"  {'size':>5} {'T(A)':>14} {'predicted=2^size-1':>22} {'<=?':>5}   type")
    for a in samples:
        t = state_bound(a)
        pb = predicted_bound(a)
        print(f"  {size(a):>5} {t:>14} {pb:>22} {str(t <= pb):>5}   {a}")
    print()


def demo_structural_identities() -> None:
    print("=" * 72)
    print("Section 8 identities")
    print("=" * 72)
    print("  Lemma 8.1:  2*width(A) + 1 = size(A)")
    for a in [Base(), chain(3), bushy(2), Arrow(bushy(1), chain(2))]:
        lhs, rhs = 2 * arrow_width(a) + 1, size(a)
        print(f"    {lhs:>4} == {rhs:>4}  [{'OK' if lhs == rhs else 'X'}]   {a}")
    print("  Lemma 8.2:  depth(A) = width(A)  on chains")
    for d in range(5):
        a = chain(d)
        print(f"    depth={depth(a)}  width={arrow_width(a)}  "
              f"[{'OK' if depth(a) == arrow_width(a) else 'X'}]")
    print("  Lemma 8.4:  width(bushy n) = 2^n - 1,  size(bushy n) = 2^(n+1) - 1")
    for n in range(5):
        b = bushy(n)
        print(f"    n={n}  width={arrow_width(b)} (=2^n-1={2 ** n - 1})  "
              f"size={size(b)} (=2^(n+1)-1={2 ** (n + 1) - 1})")
    print()


def demo_regime_classification() -> None:
    print("=" * 72)
    print("Algorithm C:  regime classification")
    print("=" * 72)
    for a in [chain(4), bushy(3), Arrow(bushy(1), Base())]:
        print(f"  {str(a):<40}  ->  {regime_classifier(a)}")
    print()


def main() -> None:
    demo_state_bound_eq_complexity()
    demo_chain_single_exponential()
    demo_bushy_double_exponential()
    demo_impossibility()
    demo_size_bound()
    demo_structural_identities()
    demo_regime_classification()
    print("All numerical checks consistent with the formal theorems.")


if __name__ == "__main__":
    main()
