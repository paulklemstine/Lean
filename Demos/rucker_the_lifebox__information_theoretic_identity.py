"""
The Lifebox: Information-Theoretic Identity — numerical demonstrations.

This self-contained script illustrates the five core results:

  1. Person-equivalence is functional equivalence (an equivalence relation).
  2. Finite stimulus space  =>  person-equivalence is DECIDABLE, via the
     distinguishing-stimulus set.
  3. Infinite stimulus space  =>  NO finite test certifies equivalence:
     for any finite probe set we build two systems that agree on it but differ.
  4. No-cloning: no LINEAR map C on k^2 satisfies C(x) = x (x) x for all x
     (demonstrated over the rationals via the failing cross terms).
  5. Identity counting: identities describable in b bits number exactly 2**b.

Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, Dict, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1 & 2. Person-equivalence and finite-state decidability
# ---------------------------------------------------------------------------

def distinguishing_stimuli(
    f: Callable[[int], object],
    g: Callable[[int], object],
    inputs: Sequence[int],
) -> List[int]:
    """Return the finite set of inputs on which f and g disagree."""
    return [i for i in inputs if f(i) != g(i)]


def person_equivalent_finite(
    f: Callable[[int], object],
    g: Callable[[int], object],
    inputs: Sequence[int],
) -> bool:
    """Decide person-equivalence over a FINITE stimulus space.

    Theorem: f ~ g  <=>  the distinguishing-stimulus set is empty.
    """
    return len(distinguishing_stimuli(f, g, inputs)) == 0


def demo_finite_decidability() -> None:
    print("=" * 68)
    print("1-2. Finite-state person-equivalence is DECIDABLE")
    print("=" * 68)
    stimuli = list(range(8))  # a finite mind with 8 possible stimuli

    f = lambda i: (i * i) % 3
    g = lambda i: (i * i) % 3          # same behavior, different "code"
    h = lambda i: (i * i) % 3 if i != 5 else 99  # differs at i = 5

    print(f"stimulus space = {stimuli}")
    print(f"f ~ g ? {person_equivalent_finite(f, g, stimuli)}  (expected True)")
    print(f"f ~ h ? {person_equivalent_finite(f, h, stimuli)}  (expected False)")
    print(f"distinguishing stimuli of (f,h) = "
          f"{distinguishing_stimuli(f, h, stimuli)}")
    print()


# ---------------------------------------------------------------------------
# 3. No finite test over an infinite stimulus space
# ---------------------------------------------------------------------------

def build_impostor(probe_set: Sequence[int]) -> Tuple[
    Callable[[int], bool], Callable[[int], bool], int
]:
    """Given a finite probe set S subset of N, construct f != g agreeing on S.

    g is constant False; f is False everywhere except at some n not in S.
    Returns (f, g, n).
    """
    n = 0
    S = set(probe_set)
    while n in S:            # find n outside S (possible: S finite, N infinite)
        n += 1
    g = lambda i: False
    f = lambda i, _n=n: (i == _n)
    return f, g, n


def demo_no_finite_test() -> None:
    print("=" * 68)
    print("3. Infinite stimulus space: NO finite test certifies identity")
    print("=" * 68)
    for probe_set in ([0, 1, 2, 3], list(range(0, 20, 2)), [7, 42, 100]):
        f, g, n = build_impostor(probe_set)
        agree_on_probes = all(f(i) == g(i) for i in probe_set)
        differ_at_n = f(n) != g(n)
        print(f"probes={probe_set}")
        print(f"   agree on all probes? {agree_on_probes}   "
              f"differ at n={n}? {differ_at_n}")
    print("   => every finite battery of tests is fooled by an impostor.")
    print()


# ---------------------------------------------------------------------------
# 4. No-cloning theorem (linear-algebra obstruction)
# ---------------------------------------------------------------------------

Vec2 = Tuple[Fraction, Fraction]
# A tensor in k^2 (x) k^2 is stored as a 2x2 coefficient dict indexed (a,b).
Tensor = Dict[Tuple[int, int], Fraction]


def tensor_product(x: Vec2, y: Vec2) -> Tensor:
    """Elementary tensor x (x) y as a 2x2 coefficient table."""
    return {(a, b): x[a] * y[b] for a in (0, 1) for b in (0, 1)}


def tensor_add(t: Tensor, s: Tensor) -> Tensor:
    return {k: t.get(k, Fraction(0)) + s.get(k, Fraction(0))
            for k in set(t) | set(s)}


def demo_no_cloning() -> None:
    print("=" * 68)
    print("4. No-cloning: linearity contradicts x -> x (x) x")
    print("=" * 68)
    e1: Vec2 = (Fraction(1), Fraction(0))
    e2: Vec2 = (Fraction(0), Fraction(1))
    s: Vec2 = (Fraction(1), Fraction(1))  # e1 + e2

    # A hypothetical linear cloner must satisfy C(e1+e2) = C(e1) + C(e2).
    linear_side = tensor_add(tensor_product(e1, e1), tensor_product(e2, e2))
    # The cloning definition instead demands C(e1+e2) = (e1+e2)(x)(e1+e2).
    clone_side = tensor_product(s, s)

    print("C(e1)+C(e2)  coefficients :", dict(sorted(linear_side.items())))
    print("(e1+e2)(x)(e1+e2) coeffs  :", dict(sorted(clone_side.items())))
    diff = {k: clone_side.get(k, Fraction(0)) - linear_side.get(k, Fraction(0))
            for k in set(clone_side) | set(linear_side)}
    print("difference (cross terms)  :", dict(sorted(diff.items())))
    print("cross terms e1(x)e2 + e2(x)e1 are nonzero => NO linear cloner.")
    print()


# ---------------------------------------------------------------------------
# 5. Counting identities
# ---------------------------------------------------------------------------

def count_identities(b: int) -> int:
    """Number of identities describable in b bits: exactly 2**b."""
    return 2 ** b


def enumerate_identities(b: int) -> List[Tuple[bool, ...]]:
    """Explicitly list all bit-vector identities of length b."""
    return [tuple(bool(v) for v in bits) for bits in product((0, 1), repeat=b)]


def demo_counting() -> None:
    print("=" * 68)
    print("5. Identities in b bits number exactly 2**b")
    print("=" * 68)
    for b in range(0, 6):
        listed = enumerate_identities(b)
        assert len(listed) == count_identities(b)
        print(f"b={b}: 2**b = {count_identities(b):>3}   "
              f"(enumerated {len(listed)})")
    import math
    bits = 10 ** 15
    digits = int(bits * math.log10(2)) + 1  # decimal digits of 2**bits
    print(f"\nLifebox bound: identities in 10^15 bits = 2^(10^15)")
    print(f"   this integer has about {digits:,} decimal digits "
          f"(finite, but astronomically large).")
    print()


def main() -> None:
    demo_finite_decidability()
    demo_no_finite_test()
    demo_no_cloning()
    demo_counting()


if __name__ == "__main__":
    main()
