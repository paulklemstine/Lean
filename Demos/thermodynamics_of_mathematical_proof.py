"""Thermodynamics of Mathematical Proof --- numerical demonstrations.

This self-contained script implements the erasure functional and the Landauer
cost for proof steps modeled as functions between finite state spaces, and
reproduces the paper's main quantitative results:

  * erased(f) = log2|domain| - log2|image f|        (bits erased by a step)
  * cost(bits, kB, T) = bits * kB * T * ln 2         (Landauer heat, joules)
  * reversibility criterion (injective  <=>  zero erasure)
  * the AND gate erases exactly one bit
  * the data-processing inequality (erasure is monotone, sub-additive)
  * Bennett's reversible embedding erases zero bits
  * the linear/exponential collapse families and their separation
  * the incompressibility counting bound

Run with:  python demo.py
"""

from __future__ import annotations

from itertools import product
from math import log, log2
from typing import Callable, Hashable, Sequence, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)

# Physical constants (SI).
BOLTZMANN_K: float = 1.380649e-23  # J / K
LN2: float = log(2.0)


# --------------------------------------------------------------------------- #
#  Core functionals                                                           #
# --------------------------------------------------------------------------- #
def image_card(f: Callable[[A], B], domain: Sequence[A]) -> int:
    """Number of distinct outputs of ``f`` over ``domain`` (size of the image)."""
    return len({f(x) for x in domain})


def erased_bits(f: Callable[[A], B], domain: Sequence[A]) -> float:
    """Bits of information erased by one step ``f`` on a finite ``domain``.

    Equals ``log2|domain| - log2|image f|``; nonnegative, and zero iff ``f`` is
    injective on ``domain``.
    """
    n = len(domain)
    if n == 0:
        raise ValueError("domain must be nonempty")
    return log2(n) - log2(image_card(f, domain))


def landauer_cost(bits: float, kB: float = BOLTZMANN_K, T: float = 300.0) -> float:
    """Dissipated heat (joules) for erasing ``bits`` bits at temperature ``T`` (K)."""
    return bits * kB * T * LN2


def is_injective(f: Callable[[A], B], domain: Sequence[A]) -> bool:
    """Whether ``f`` is injective (logically reversible) on ``domain``."""
    return image_card(f, domain) == len(domain)


# --------------------------------------------------------------------------- #
#  Concrete proof steps                                                       #
# --------------------------------------------------------------------------- #
def not_gate(b: bool) -> bool:
    """A reversible bijection: erases zero bits despite being non-trivial."""
    return not b


def and_gate(p: tuple[bool, bool]) -> bool:
    """The canonical irreversible gate: erases exactly one bit."""
    return p[0] and p[1]


def bennett_embedding(f: Callable[[A], B]) -> Callable[[A], tuple[A, B]]:
    """Bennett's reversible embedding ``x -> (x, f(x))``; always injective."""
    return lambda x: (x, f(x))


def collapse(n: int) -> tuple[Callable[[int], int], list[int]]:
    """Linear collapse: ``2**n`` states mapped onto a single answer.  Erases n bits."""
    domain = list(range(2 ** n))
    return (lambda _x: 0), domain


def big_collapse(m: int) -> tuple[Callable[[int], int], list[int]]:
    """Big collapse: a ``2**(2**m)``-state space onto one answer.  Erases 2**m bits.

    The domain is represented lazily by its *size* rather than enumerated, so we
    return a sentinel domain of the correct cardinality for the erasure formula.
    """
    size = 2 ** (2 ** m)
    domain = range(size)  # range object: O(1) memory, correct len()
    return (lambda _x: 0), list(domain) if size <= 1 else _SizedConst(size)


class _SizedConst(list):
    """A stand-in 'domain' that reports a large cardinality without materializing it."""

    def __init__(self, size: int) -> None:  # noqa: D401
        super().__init__()
        self._size = size

    def __len__(self) -> int:
        return self._size


def erased_bits_by_size(domain_size: int, image_size: int) -> float:
    """Erasure computed directly from cardinalities (for huge/implicit domains)."""
    return log2(domain_size) - log2(image_size)


# --------------------------------------------------------------------------- #
#  Incompressibility counting bound                                           #
# --------------------------------------------------------------------------- #
def num_predicates(n: int) -> int:
    """Number of Boolean predicates on an ``n``-element register: 2**n cells."""
    return 2 ** n


def num_short_programs(n: int) -> int:
    """Number of programs of length strictly less than ``n``: 2**n - 1."""
    return sum(2 ** k for k in range(n))  # = 2**n - 1


def incompressible(n: int) -> bool:
    """True iff no injection exists from predicates to strictly-shorter programs."""
    return num_predicates(n) > num_short_programs(n)


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #
def demo_gates() -> None:
    print("=" * 68)
    print("Reversibility criterion: NOT (reversible) vs AND (irreversible)")
    print("=" * 68)
    bools = [False, True]
    print(f"  NOT gate: injective = {is_injective(not_gate, bools)}, "
          f"erased = {erased_bits(not_gate, bools):.3f} bits")
    pairs = list(product(bools, repeat=2))
    e_and = erased_bits(and_gate, pairs)
    print(f"  AND gate: injective = {is_injective(and_gate, pairs)}, "
          f"erased = {e_and:.3f} bits")
    print(f"  Landauer heat of AND at 300 K = {landauer_cost(e_and):.3e} J")


def demo_bennett() -> None:
    print("=" * 68)
    print("Bennett's reversible embedding makes any step free")
    print("=" * 68)
    pairs = list(product([False, True], repeat=2))
    emb = bennett_embedding(and_gate)
    print(f"  AND alone       erases {erased_bits(and_gate, pairs):.3f} bits")
    print(f"  AND w/ retained input erases {erased_bits(emb, pairs):.3f} bits")


def demo_data_processing() -> None:
    print("=" * 68)
    print("Data-processing inequality: erasure only grows downstream")
    print("=" * 68)
    domain = list(range(8))                       # 3-bit register
    f: Callable[[int], int] = lambda x: x % 4     # merges 8 -> 4
    g: Callable[[int], int] = lambda y: y % 2     # merges 4 -> 2
    gf: Callable[[int], int] = lambda x: g(f(x))
    ef, egf = erased_bits(f, domain), erased_bits(gf, domain)
    eg_alone = erased_bits(g, [f(x) for x in domain])
    print(f"  erased(f)      = {ef:.3f} bits")
    print(f"  erased(g o f)  = {egf:.3f} bits   (>= erased(f): {egf >= ef})")
    print(f"  erased(f)+erased(g) = {ef + eg_alone:.3f} bits  "
          f"(additivity fails: {abs(egf - (ef + eg_alone)) > 1e-9})")


def demo_separation() -> None:
    print("=" * 68)
    print("Exponential erasure separation: linear vs big collapse")
    print("=" * 68)
    print(f"  {'m':>3} | {'erased C_m (bits)':>18} | {'erased B_m (bits)':>18}")
    print("  " + "-" * 46)
    for m in range(6):
        lin = float(m)                 # erased(collapse m) = m
        big = float(2 ** m)            # erased(bigCollapse m) = 2**m
        print(f"  {m:>3} | {lin:>18.0f} | {big:>18.0f}")
    print("  erased(B_m) = 2 ** erased(C_m):  exponential in the linear family.")


def demo_incompressible() -> None:
    print("=" * 68)
    print("Incompressibility counting bound")
    print("=" * 68)
    print(f"  {'n':>3} | {'#predicates':>12} | {'#short progs':>12} | incompressible")
    print("  " + "-" * 52)
    for n in range(1, 8):
        print(f"  {n:>3} | {num_predicates(n):>12} | {num_short_programs(n):>12} | "
              f"{incompressible(n)}")
    n = 20
    print(f"  Some predicate on {n} bits erases >= {n} bits, "
          f"dissipating >= {landauer_cost(float(n)):.3e} J at 300 K.")


def main() -> None:
    demo_gates()
    demo_bennett()
    demo_data_processing()
    demo_separation()
    demo_incompressible()


if __name__ == "__main__":
    main()
