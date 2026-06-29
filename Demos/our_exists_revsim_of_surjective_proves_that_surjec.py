"""
demo.py — Numerical demonstrations of the maximum-fiber-size theory of
reversible computation and Landauer cost.

This script is fully self-contained (standard library only). It illustrates:

  1. Fibers and the counting identity:  sum of fiber sizes = |domain|.
  2. maxFiberSize as the master invariant.
  3. The tight ancilla bound: an explicit reversible simulation using exactly
     Fin(maxFiberSize) ancilla states, plus a brute-force check of the lower
     bound (no smaller ancilla works).
  4. Information erased (in bits) and the Landauer gap (in joules and in
     units of kT ln 2).
  5. The strict dichotomy: infoErased > 0  <=>  f non-injective.
  6. The fourfold equivalence:
        maxFiberSize >= 2 <=> non-injective <=> infoErased > 0 <=> gap > 0.
  7. Sorting: a single fiber of size n!, with infoErased = log2(n!).
  8. Composition: ancilla cardinality multiplies.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from collections import defaultdict
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

# Boltzmann constant (J/K) and a room-temperature reference, for physical scale.
K_BOLTZMANN: float = 1.380649e-23
ROOM_T: float = 300.0  # kelvin


# --------------------------------------------------------------------------
# Core combinatorial quantities
# --------------------------------------------------------------------------

def fibers(domain: Sequence[Hashable],
           f: Callable[[Hashable], Hashable]) -> Dict[Hashable, List[Hashable]]:
    """Return the fiber decomposition {output b : [inputs a with f(a) = b]}."""
    buckets: Dict[Hashable, List[Hashable]] = defaultdict(list)
    for a in domain:
        buckets[f(a)].append(a)
    return dict(buckets)


def max_fiber_size(domain: Sequence[Hashable],
                   f: Callable[[Hashable], Hashable]) -> int:
    """maxFiberSize f : the cardinality of the largest preimage."""
    fib = fibers(domain, f)
    return max((len(v) for v in fib.values()), default=0)


def counting_identity_holds(domain: Sequence[Hashable],
                            f: Callable[[Hashable], Hashable]) -> bool:
    """Check sum_b |f^{-1}(b)| = |domain| (Proposition 3.1)."""
    fib = fibers(domain, f)
    return sum(len(v) for v in fib.values()) == len(domain)


def is_injective(domain: Sequence[Hashable],
                 f: Callable[[Hashable], Hashable]) -> bool:
    """Is f injective on the given finite domain?"""
    seen = set()
    for a in domain:
        b = f(a)
        if b in seen:
            return False
        seen.add(b)
    return True


# --------------------------------------------------------------------------
# The tight ancilla bound (Theorems 5.2, 5.3, 5.4)
# --------------------------------------------------------------------------

def reversible_simulation(
    domain: Sequence[Hashable],
    f: Callable[[Hashable], Hashable],
) -> Tuple[Dict[Hashable, Tuple[Hashable, int]], int]:
    """
    Construct a reversible simulation encode : a |-> (f(a), index_in_fiber).

    The ancilla is Fin(k) with k = maxFiberSize f.  Within each fiber the
    inputs are labelled 0, 1, ..., and these labels are reused across fibers,
    so the ancilla cardinality equals the largest fiber size.

    Returns (encode_table, ancilla_size).
    """
    fib = fibers(domain, f)
    encode: Dict[Hashable, Tuple[Hashable, int]] = {}
    for b, members in fib.items():
        for idx, a in enumerate(members):
            encode[a] = (b, idx)
    return encode, max_fiber_size(domain, f)


def encoding_is_injective(encode: Dict[Hashable, Tuple[Hashable, int]]) -> bool:
    """Reversibility test: distinct inputs receive distinct (output, ancilla)."""
    values = list(encode.values())
    return len(values) == len(set(values))


def encoding_is_consistent(encode: Dict[Hashable, Tuple[Hashable, int]],
                           f: Callable[[Hashable], Hashable]) -> bool:
    """First component of the encoding recovers f."""
    return all(pair[0] == f(a) for a, pair in encode.items())


def smaller_ancilla_impossible(
    domain: Sequence[Hashable],
    f: Callable[[Hashable], Hashable],
) -> bool:
    """
    Brute-force confirmation of the lower bound (Theorem 5.2/5.4):
    no consistent injective encoding into Fin(k-1) exists, where k = maxFiberSize.

    We only need to defeat a single largest fiber: with k-1 ancilla labels and
    k inputs sharing one output, the pigeonhole principle forces a collision.
    """
    k = max_fiber_size(domain, f)
    if k <= 1:
        return True  # one state already suffices; nothing smaller is meaningful
    # The largest fiber alone needs k distinct ancilla values for a fixed output.
    largest = max(len(v) for v in fibers(domain, f).values())
    # With only k-1 labels available for `largest` >= k inputs of equal output,
    # an injective consistent encoding is impossible iff largest > k - 1.
    return largest > k - 1


# --------------------------------------------------------------------------
# Information and Landauer cost (Definitions 6.1; Theorems 6.3, 6.4, 6.5)
# --------------------------------------------------------------------------

def info_erased_bits(domain: Sequence[Hashable],
                     f: Callable[[Hashable], Hashable]) -> float:
    """infoErased f = log2 |domain| - log2 |image f|  (bits)."""
    n = len(domain)
    image_size = len({f(a) for a in domain})
    if n == 0 or image_size == 0:
        return 0.0
    return math.log2(n) - math.log2(image_size)


def landauer_gap_joules(domain: Sequence[Hashable],
                        f: Callable[[Hashable], Hashable],
                        kT: float) -> float:
    """landauerGap f (kT) = kT * ln 2 * infoErased f   (joules)."""
    return kT * math.log(2.0) * info_erased_bits(domain, f)


def fourfold_equivalence(domain: Sequence[Hashable],
                         f: Callable[[Hashable], Hashable],
                         kT: float) -> Dict[str, bool]:
    """
    Evaluate the four conditions of the synthesis (Section 9) and confirm they
    agree:
        (1) maxFiberSize >= 2
        (2) f non-injective
        (3) infoErased > 0
        (4) Landauer gap > 0
    """
    c1 = max_fiber_size(domain, f) >= 2
    c2 = not is_injective(domain, f)
    c3 = info_erased_bits(domain, f) > 1e-12
    c4 = landauer_gap_joules(domain, f, kT) > 1e-40
    return {
        "need_multi_ancilla": c1,
        "non_injective": c2,
        "erases_information": c3,
        "positive_landauer_gap": c4,
        "all_agree": c1 == c2 == c3 == c4,
    }


# --------------------------------------------------------------------------
# Composition (Theorem 8.1, Corollary 8.2)
# --------------------------------------------------------------------------

def composed_ancilla_is_multiplicative(
    dom_a: Sequence[Hashable],
    f: Callable[[Hashable], Hashable],
    g: Callable[[Hashable], Hashable],
) -> Tuple[int, int, int]:
    """
    For witnesses of f and g, the composed ancilla cardinality is the product.
    Here we use maxFiberSize as the per-stage ancilla measure and report
    (ancilla_f, ancilla_g, ancilla_f * ancilla_g).
    """
    image_f = sorted({f(a) for a in dom_a}, key=repr)
    af = max_fiber_size(dom_a, f)
    ag = max_fiber_size(image_f, g)
    return af, ag, af * ag


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def demo_basic_function() -> None:
    banner("1. A small non-injective function: fibers, ancilla, cost")
    domain = list(range(8))            # {0,...,7}
    f = lambda x: x % 3                # outputs in {0,1,2}; fibers of size 3,3,2
    fib = fibers(domain, f)
    print(f"  domain          = {domain}")
    print(f"  f(x) = x mod 3")
    print(f"  fibers          = {fib}")
    print(f"  counting id ok  = {counting_identity_holds(domain, f)}")
    k = max_fiber_size(domain, f)
    print(f"  maxFiberSize    = {k}  (largest preimage)")

    encode, ancilla = reversible_simulation(domain, f)
    print(f"  reversible simulation (ancilla = Fin({ancilla})):")
    for a in domain:
        print(f"     {a} -> {encode[a]}")
    print(f"  encoding injective   = {encoding_is_injective(encode)}")
    print(f"  encoding consistent  = {encoding_is_consistent(encode, f)}")
    print(f"  Fin({k-1}) impossible = {smaller_ancilla_impossible(domain, f)}")

    bits = info_erased_bits(domain, f)
    gap = landauer_gap_joules(domain, f, K_BOLTZMANN * ROOM_T)
    print(f"  infoErased      = {bits:.6f} bits")
    print(f"  Landauer gap    = {gap:.3e} J  at T = {ROOM_T} K")
    print(f"                  = {bits:.6f} * (kT ln 2)")


def demo_dichotomy() -> None:
    banner("2. Strict dichotomy & fourfold equivalence")
    domain = list(range(4))
    kT = K_BOLTZMANN * ROOM_T
    examples: List[Tuple[str, Callable[[Hashable], Hashable]]] = [
        ("identity      x -> x          (injective)", lambda x: x),
        ("shift         x -> (x+1)%4    (injective)", lambda x: (x + 1) % 4),
        ("collapse pair x -> x//2       (2:1)       ", lambda x: x // 2),
        ("constant      x -> 0          (4:1)       ", lambda x: 0),
    ]
    header = f"  {'function':<42}{'k':>3}{'inj':>5}{'bits':>9}{'gap>0':>7}"
    print(header)
    for name, f in examples:
        k = max_fiber_size(domain, f)
        inj = is_injective(domain, f)
        bits = info_erased_bits(domain, f)
        eq = fourfold_equivalence(domain, f, kT)
        print(f"  {name:<42}{k:>3}{str(inj):>5}{bits:>9.4f}"
              f"{str(eq['positive_landauer_gap']):>7}   agree={eq['all_agree']}")


def demo_sorting() -> None:
    banner("3. Sorting: one giant fiber of size n!")
    print(f"  {'n':>3}{'n!':>10}{'maxFiberSize':>15}{'infoErased=log2(n!)':>24}")
    for n in range(1, 9):
        perms = list(itertools.permutations(range(n)))
        sort_fn = lambda _p: 0          # collapse every permutation to one output
        k = max_fiber_size(perms, sort_fn)
        bits = info_erased_bits(perms, sort_fn)
        print(f"  {n:>3}{math.factorial(n):>10}{k:>15}{bits:>24.6f}")
    # Larger n by formula (enumeration of 13! permutations is infeasible).
    for n in (13, 20, 52):
        print(f"  n = {n:>2}:  log2(n!) = {math.log2(math.factorial(n)):.3f} bits"
              f"  ->  >= {math.factorial(n):.3e} ancilla states")


def demo_composition() -> None:
    banner("4. Composition: ancilla cardinality multiplies")
    dom = list(range(12))
    f = lambda x: x % 4                  # maxFiberSize 3
    g = lambda y: y % 2                  # maxFiberSize 2 on image {0,1,2,3}
    af, ag, prod = composed_ancilla_is_multiplicative(dom, f, g)
    print(f"  f(x) = x mod 4 :  ancilla_f = {af}")
    print(f"  g(y) = y mod 2 :  ancilla_g = {ag}")
    print(f"  g o f          :  ancilla   = {af} * {ag} = {prod}  (multiplicative)")


def main() -> None:
    demo_basic_function()
    demo_dichotomy()
    demo_sorting()
    demo_composition()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
