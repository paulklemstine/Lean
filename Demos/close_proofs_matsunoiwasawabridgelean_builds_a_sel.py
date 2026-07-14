"""
demo.py
=======

Numerical demonstrations for

    "The Kernel-Cover Characterization of the Weighted Davenport Constant"

This script is completely self-contained (standard library only) and can be
run directly:

    python3 demo.py

It concretely realizes the abstract model of the paper for the case of a
finite cyclic group  G = Z/mZ  with  F = G.  In that setting every group
homomorphism  F -> G  is multiplication by a fixed element  a in Z/mZ, so a
"weight set"  W  is just a subset of  Z/mZ,  and a length-n "choice of weights"
is a tuple  (a_0, ..., a_{n-1})  with each  a_i in {0} U W.

For a sequence  x = (x_0, ..., x_{n-1})  in (Z/mZ)^n  the induced universal
homomorphism evaluates to

    Phi(a)(x) = sum_i a_i * x_i   (mod m).

The *kernel-cover property* at length n says: for EVERY sequence x there is a
valid weighting a (each a_i in {0} U W, at least one a_i nonzero) with
Phi(a)(x) = 0.  The weighted Davenport constant  D_W(Z/mZ)  is the least n with
this property.

The demos below verify, purely by brute force enumeration:

  1. The classical bridge:  with W = {1}, the kernel-cover property at length n
     is exactly "every length-n sequence has a nonempty zero-sum subsequence",
     and the least such n is exactly m  (the classical Davenport constant).
  2. Monotonicity of the kernel-cover property in n.
  3. Weighted Davenport constants for various weight sets shrink as the weight
     set grows.
  4. The set-cover reformulation: the kernel-cover property holds iff the union
     of the kernels of the valid induced homomorphisms is the whole group F^n.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Tuple


# ---------------------------------------------------------------------------
# Core model over a cyclic group Z/mZ (F = G = Z/mZ, homs = multiplications)
# ---------------------------------------------------------------------------


def valid_weightings(weight_set: Sequence[int], n: int, m: int) -> Iterable[Tuple[int, ...]]:
    """Enumerate all valid length-n weightings for a given weight set.

    A weighting is a tuple ``a`` of length ``n`` with each ``a_i`` in
    ``{0} U weight_set`` (reduced mod m) and at least one ``a_i`` nonzero.
    """
    alphabet: List[int] = sorted({0} | {w % m for w in weight_set})
    for a in product(alphabet, repeat=n):
        if any(coord % m != 0 for coord in a):
            yield a


def phi(a: Sequence[int], x: Sequence[int], m: int) -> int:
    """Evaluate the induced universal homomorphism Phi(a) at x, mod m."""
    return sum(ai * xi for ai, xi in zip(a, x)) % m


def sequence_is_covered(
    x: Sequence[int], weight_set: Sequence[int], m: int
) -> Optional[Tuple[int, ...]]:
    """Return a valid weighting witnessing Phi(a)(x) = 0, or None if none exists."""
    for a in valid_weightings(weight_set, len(x), m):
        if phi(a, x, m) == 0:
            return a
    return None


def kernel_cover(weight_set: Sequence[int], n: int, m: int) -> bool:
    """Decide the kernel-cover property at length n by brute force."""
    for x in product(range(m), repeat=n):
        if sequence_is_covered(x, weight_set, m) is None:
            return False
    return True


def weighted_davenport(weight_set: Sequence[int], m: int, n_max: int = 12) -> Optional[int]:
    """Least n with the kernel-cover property, i.e. the weighted Davenport constant."""
    for n in range(1, n_max + 1):
        if kernel_cover(weight_set, n, m):
            return n
    return None


# ---------------------------------------------------------------------------
# Classical bridge: zero-sum subsequences (weight set W = {1})
# ---------------------------------------------------------------------------


def has_zero_sum_subsequence(x: Sequence[int], m: int) -> bool:
    """True iff some nonempty subset of x sums to 0 mod m."""
    n = len(x)
    for mask in range(1, 1 << n):
        s = sum(x[i] for i in range(n) if (mask >> i) & 1) % m
        if s == 0:
            return True
    return False


def bridge_holds_at(n: int, m: int) -> bool:
    """Check kernel_cover({1}, n) <-> every length-n sequence has a zero-sum subsequence."""
    for x in product(range(m), repeat=n):
        covered = sequence_is_covered(x, [1], m) is not None
        zero_sum = has_zero_sum_subsequence(x, m)
        if covered != zero_sum:
            return False
    return True


# ---------------------------------------------------------------------------
# Set-cover reformulation
# ---------------------------------------------------------------------------


def kernel_of(a: Sequence[int], m: int) -> FrozenSet[Tuple[int, ...]]:
    """The kernel (as a set of tuples in (Z/mZ)^n) of the homomorphism Phi(a)."""
    n = len(a)
    return frozenset(x for x in product(range(m), repeat=n) if phi(a, x, m) == 0)


def union_of_kernels_is_everything(weight_set: Sequence[int], n: int, m: int) -> bool:
    """Check that the union of kernels of valid induced homs is all of (Z/mZ)^n."""
    union: set = set()
    for a in valid_weightings(weight_set, n, m):
        union |= kernel_of(a, m)
    return len(union) == m ** n


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_classical_davenport() -> None:
    print("=" * 70)
    print("Demo 1:  Classical Davenport constant  D_{1}(Z/mZ) = m")
    print("=" * 70)
    for m in range(2, 7):
        d = weighted_davenport([1], m)
        status = "OK" if d == m else "MISMATCH"
        print(f"  Z/{m}Z:  weighted Davenport constant D = {d}   (expected {m})  [{status}]")
    print()


def demo_bridge() -> None:
    print("=" * 70)
    print("Demo 2:  Bridge  kernel-cover({1}, n)  <->  zero-sum subsequence exists")
    print("=" * 70)
    for m in range(2, 6):
        ok = all(bridge_holds_at(n, m) for n in range(1, m + 2))
        print(f"  Z/{m}Z:  equivalence verified for all tested n  [{'OK' if ok else 'FAIL'}]")
    print()


def demo_monotonicity() -> None:
    print("=" * 70)
    print("Demo 3:  Monotonicity of the kernel-cover property in n")
    print("=" * 70)
    for m in (4, 5, 6):
        for w in ([1], [1, m - 1]):
            row = [kernel_cover(w, n, m) for n in range(1, m + 2)]
            # once True it must stay True
            mono = all((not row[i]) or row[i + 1] for i in range(len(row) - 1))
            print(f"  Z/{m}Z, W={w}:  cover(n) for n=1..{m+1} -> {row}  monotone={mono}")
    print()


def demo_weighted_constants() -> None:
    print("=" * 70)
    print("Demo 4:  Weighted Davenport constants shrink as the weight set grows")
    print("=" * 70)
    for m in (5, 6, 7):
        units = [a for a in range(1, m) if _gcd(a, m) == 1]
        rows = [
            ("{1}", [1]),
            ("{1,-1}", sorted({1 % m, (m - 1) % m})),
            ("units", units),
            ("all nonzero", list(range(1, m))),
        ]
        print(f"  Z/{m}Z:")
        for name, w in rows:
            d = weighted_davenport(w, m)
            print(f"      W = {name:<12}  D_W = {d}")
    print()


def demo_set_cover() -> None:
    print("=" * 70)
    print("Demo 5:  Set-cover reformulation matches the pointwise property")
    print("=" * 70)
    for m in (3, 4, 5):
        for n in range(1, 4):
            a = kernel_cover([1], n, m)
            b = union_of_kernels_is_everything([1], n, m)
            print(f"  Z/{m}Z, n={n}:  pointwise={a}  union-of-kernels=covers-all={b}  agree={a==b}")
    print()


def _gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return a


def main() -> None:
    demo_classical_davenport()
    demo_bridge()
    demo_monotonicity()
    demo_weighted_constants()
    demo_set_cover()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
