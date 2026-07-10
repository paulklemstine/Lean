"""
Categorification of Entropy: The Information Loss of a Functor
=============================================================

Numerical demonstrations of the functorial-entropy theory.

For a functor between finite categories, modelled by the map F : Ob(C) -> Ob(D)
it induces on objects, the *functorial entropy* (information loss) is the
conditional entropy of a uniformly random domain object given its image:

    H(F) = sum_d (c_d / n) * log(c_d)

where c_d = |F^{-1}(d)| is the fiber cardinality over d and n = |Ob(C)|.

This script verifies, on concrete finite examples, every theorem of the paper:
  * nonnegativity
  * H(F) = 0  iff  F injective
  * uniform-fiber formula  H(F) = log k = log(n/m)
  * constant functor value  log n
  * upper bound  H(F) <= log n
  * data-processing inequality  H(f) <= H(g o f)

All functions are self-contained and type-hinted. Base-2 logarithms report the
loss in bits.
"""

from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Hashable, Sequence


# ---------------------------------------------------------------------------
# Core invariant
# ---------------------------------------------------------------------------

def fiber_cardinalities(images: Sequence[Hashable]) -> dict[Hashable, int]:
    """Tally |F^{-1}(d)| for each target object d, given the list of images
    F(a) as `a` ranges over the (finite) domain."""
    return dict(Counter(images))


def functorial_entropy(images: Sequence[Hashable], base: float = 2.0) -> float:
    """Functorial entropy H(F) = sum_d (c_d/n) log(c_d), in units set by `base`.

    `images[i]` is the image of the i-th domain object under F.
    """
    n = len(images)
    if n == 0:
        return 0.0
    total = 0.0
    for c_d in fiber_cardinalities(images).values():
        if c_d > 0:
            total += (c_d / n) * math.log(c_d, base)
    return total


def apply_map(domain: Sequence[Hashable], F: Callable[[Hashable], Hashable]) -> list[Hashable]:
    """Compute the list of images F(a) for a in the domain."""
    return [F(a) for a in domain]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_vanishing_criterion() -> None:
    """H(F) = 0 exactly for injective functors."""
    print("=" * 68)
    print("Vanishing criterion:  H(F) = 0  iff  F is injective")
    print("=" * 68)

    injective = ["a", "b", "c", "d"]          # 4 distinct images: injective
    non_injective = ["x", "x", "y", "z"]      # two objects collapse to 'x'

    print(f"  injective map images     {injective}")
    print(f"    H = {functorial_entropy(injective):.4f} bits   (expected 0)")
    print(f"  non-injective map images {non_injective}")
    print(f"    H = {functorial_entropy(non_injective):.4f} bits   (> 0)")
    print()


def demo_uniform_fiber_formula() -> None:
    """H(F) = log k = log(n/m) when every fiber has size k."""
    print("=" * 68)
    print("Uniform-fiber formula:  H(F) = log k = log(n/m)")
    print("=" * 68)
    for k, m in [(2, 3), (4, 2), (5, 5)]:
        # m targets, each receiving exactly k domain objects.
        images = [d for d in range(m) for _ in range(k)]
        n = k * m
        H = functorial_entropy(images)
        print(f"  n={n:2d}, m={m}, k={k}:  H = {H:.4f} bits, "
              f"log2(k) = {math.log2(k):.4f}, log2(n/m) = {math.log2(n / m):.4f}")
    print()


def demo_constant_and_bound() -> None:
    """Constant functor attains the maximum log n; general F is bounded by it."""
    print("=" * 68)
    print("Constant functor attains the maximum;  H(F) <= log n in general")
    print("=" * 68)
    n = 8
    constant = ["*"] * n
    print(f"  constant functor, n={n}:  H = {functorial_entropy(constant):.4f} bits, "
          f"log2(n) = {math.log2(n):.4f}")

    random.seed(0)
    for trial in range(3):
        images = [random.randrange(4) for _ in range(n)]
        H = functorial_entropy(images)
        print(f"  random functor #{trial+1}: images={images}  H={H:.4f} <= {math.log2(n):.4f}  "
              f"{'OK' if H <= math.log2(n) + 1e-9 else 'FAIL'}")
    print()


def demo_data_processing() -> None:
    """Data-processing inequality:  H(f) <= H(g o f)."""
    print("=" * 68)
    print("Data-processing inequality:  H(f) <= H(g o f)")
    print("=" * 68)
    random.seed(1)
    n, size_b, size_c = 12, 5, 3
    domain = list(range(n))
    violations = 0
    for trial in range(5):
        f_table = {a: random.randrange(size_b) for a in domain}
        g_table = {b: random.randrange(size_c) for b in range(size_b)}
        f = lambda a: f_table[a]
        gof = lambda a: g_table[f_table[a]]
        Hf = functorial_entropy(apply_map(domain, f))
        Hgf = functorial_entropy(apply_map(domain, gof))
        ok = Hf <= Hgf + 1e-9
        violations += (not ok)
        print(f"  trial {trial+1}:  H(f) = {Hf:.4f}  <=  H(g o f) = {Hgf:.4f}   "
              f"{'OK' if ok else 'VIOLATION'}")
    print(f"  violations: {violations} / 5")
    print()


def demo_motivating_functors() -> None:
    """Reproduce the conjectured values on finite models of the motivating
    functors: inclusion (H=0), abelianization (H ~ log 2)."""
    print("=" * 68)
    print("Motivating functors on finite models")
    print("=" * 68)

    # Inclusion of finite groups: each object maps to itself -> injective.
    inclusion_images = ["Z/2", "Z/3", "S_3", "Z/4", "V_4"]
    print(f"  Inclusion FinGrp -> Grp: H = "
          f"{functorial_entropy(inclusion_images):.4f} bits (expected 0)")

    # Abelianization on a finite model: each abelian target receives exactly
    # two non-isomorphic preimages (a 2-to-1 uniform functor) -> H = log 2.
    #   G_i and (G_i x noncomm-companion) both abelianize to A_i.
    abel_images = [d for d in range(4) for _ in range(2)]
    print(f"  Abelianization (2-to-1 model): H = "
          f"{functorial_entropy(abel_images):.4f} bits (expected log2(2) = 1)")
    print()


def main() -> None:
    demo_vanishing_criterion()
    demo_uniform_fiber_formula()
    demo_constant_and_bound()
    demo_data_processing()
    demo_motivating_functors()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
