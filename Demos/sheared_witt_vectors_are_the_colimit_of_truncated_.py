"""
Numerical demonstrations for:

    Sheared Witt Vectors as the Filtered Colimit of Truncated Witt Vectors

We model a filtered colimit of rings as a directed union of subrings of the
polynomial ring K[X_0, X_1, X_2, ...], filtered by variable index:

    S_i = { polynomials using only the variables X_0, ..., X_i }.

The three phenomena we illustrate are:

  (A) TRUNCATED preservation: a truncated Witt vector (finitely many
      coordinates) whose coordinates lie in the union always lifts to a single
      stage S_i.

  (B) NAIVE failure: the full Witt vector of variables, x_k = X_k, has every
      coordinate in the union yet lifts to NO single stage.

  (C) SHEARED repair: a finitely supported Witt vector (eventually 0) whose
      coordinates lie in the union always lifts to a single stage.

Everything is self-contained; run with `python demo.py`.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple

# A monomial is a frozen mapping variable-index -> exponent (>0), as a sorted
# tuple of (index, exponent) pairs. A polynomial is a mapping monomial ->
# rational coefficient (here: float for simplicity).
Monomial = Tuple[Tuple[int, int], ...]


@dataclass(frozen=True)
class Poly:
    """A polynomial in the variables X_0, X_1, ... over the rationals."""

    terms: Dict[Monomial, float]

    def variables(self) -> frozenset[int]:
        """The set of variable indices actually occurring in this polynomial."""
        used: set[int] = set()
        for mono, coeff in self.terms.items():
            if coeff == 0:
                continue
            for var_index, exponent in mono:
                if exponent > 0:
                    used.add(var_index)
        return frozenset(used)

    def stage(self) -> int:
        """Least i with self in S_i (= max variable index used); -1 if constant."""
        vs = self.variables()
        return max(vs) if vs else -1

    def in_stage(self, i: int) -> bool:
        """Membership in S_i = {f : variables(f) subset {0,...,i}}."""
        return all(v <= i for v in self.variables())

    def __add__(self, other: "Poly") -> "Poly":
        result: Dict[Monomial, float] = dict(self.terms)
        for mono, coeff in other.terms.items():
            result[mono] = result.get(mono, 0.0) + coeff
        return Poly({m: c for m, c in result.items() if c != 0})

    def __mul__(self, other: "Poly") -> "Poly":
        result: Dict[Monomial, float] = {}
        for m1, c1 in self.terms.items():
            for m2, c2 in other.terms.items():
                mono = _merge_monomials(m1, m2)
                result[mono] = result.get(mono, 0.0) + c1 * c2
        return Poly({m: c for m, c in result.items() if c != 0})


def _merge_monomials(m1: Monomial, m2: Monomial) -> Monomial:
    """Multiply two monomials by adding exponents variable-wise."""
    exps: Dict[int, int] = {}
    for v, e in m1:
        exps[v] = exps.get(v, 0) + e
    for v, e in m2:
        exps[v] = exps.get(v, 0) + e
    return tuple(sorted((v, e) for v, e in exps.items() if e > 0))


def const(c: float) -> Poly:
    """The constant polynomial c (lives in every stage)."""
    return Poly({(): c}) if c != 0 else Poly({})


def X(k: int) -> Poly:
    """The variable X_k."""
    return Poly({((k, 1),): 1.0})


ZERO = Poly({})


# ---------------------------------------------------------------------------
# Algorithm: lift finitely many colimit coordinates to a single stage.
# This realizes Theorem A (truncated) and Theorem C (sheared).
# ---------------------------------------------------------------------------
def lift_to_single_stage(coords: List[Poly]) -> Tuple[int, List[Poly]]:
    """
    Given finitely many polynomials each lying in the union (every polynomial
    does), return (i, coords) where i is the least stage containing all of them.

    Implements the 'finite merging' lemma: the common stage is the max of the
    per-coordinate stages.
    """
    stages = [c.stage() for c in coords]
    i = max([s for s in stages], default=-1)
    i = max(i, 0)
    assert all(c.in_stage(i) for c in coords), "lift must land every coordinate"
    return i, coords


def naive_lift_stage_or_none(
    coeff, max_search: int
) -> Optional[int]:
    """
    Attempt to lift an INFINITE Witt vector (given as a coordinate function
    coeff: k -> Poly) to a single stage, searching candidate stages 0..max_search.

    Returns the stage index if some candidate contains every coordinate up to a
    safe horizon, else None. For the variable vector this always returns None:
    candidate stage i fails at coordinate k = i + 1.
    """
    for i in range(max_search + 1):
        # Check coordinates well beyond i; a genuine lift must contain them all.
        horizon = i + 5
        if all(coeff(k).in_stage(i) for k in range(horizon + 1)):
            return i
    return None


def obstruction_witness(coeff, i: int) -> Optional[int]:
    """
    For candidate stage i, return a coordinate index k certifying that the Witt
    vector does NOT lie in stage i (variables of coeff(k) escape {0..i}), or None.
    """
    for k in range(i + 5):
        if not coeff(k).in_stage(i):
            return k
    return None


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_truncated_preservation() -> None:
    print("=" * 70)
    print("Demo A: Truncated Witt vectors preserve the filtered colimit")
    print("=" * 70)
    # A truncated Witt vector of length 4 over the union: coordinates use
    # various variables, but there are only finitely many of them.
    coords = [
        const(3.0) + X(2),                 # uses X_2   -> stage 2
        X(0) * X(5),                       # uses X_0,X_5 -> stage 5
        X(1),                              # uses X_1   -> stage 1
        const(7.0),                        # constant   -> stage -1
    ]
    for k, c in enumerate(coords):
        print(f"  coord[{k}] uses variables {sorted(c.variables())}, "
              f"least stage {c.stage()}")
    i, lifted = lift_to_single_stage(coords)
    print(f"  --> ALL coordinates lift to the single stage S_{i}")
    print(f"      (every coordinate in S_{i}: "
          f"{all(c.in_stage(i) for c in lifted)})")
    print()


def demo_naive_failure() -> None:
    print("=" * 70)
    print("Demo B: The full Witt vector of variables lifts to NO stage")
    print("=" * 70)
    coeff = X  # the variable vector: coordinate k is X_k

    print("  Every coordinate lies in the union: coord k = X_k is in S_k.")
    for k in range(5):
        print(f"    coord[{k}] = X_{k} in S_{k}: {coeff(k).in_stage(k)}")

    print("  But no single stage contains the whole vector:")
    for i in range(5):
        witness = obstruction_witness(coeff, i)
        print(f"    stage S_{i} fails at coordinate k = {witness} "
              f"(X_{witness} needs variable {witness} > {i})")

    result = naive_lift_stage_or_none(coeff, max_search=20)
    print(f"  --> global lift search over stages 0..20 returns: {result} "
          f"(None == failure, as predicted)")
    print()


def demo_sheared_repair() -> None:
    print("=" * 70)
    print("Demo C: Finitely supported (sheared) Witt vectors DO lift")
    print("=" * 70)
    # A sheared Witt vector: nonzero prefix, then eventually zero.
    N = 4  # support cutoff: coord k = 0 for k >= N
    prefix = [X(3), const(2.0) + X(0), X(7), X(1)]

    def coeff(k: int) -> Poly:
        return prefix[k] if k < N else ZERO

    print(f"  Support cutoff N = {N}; coordinates k >= {N} are all 0.")
    nonzero = [coeff(k) for k in range(N)]
    for k in range(N + 3):
        c = coeff(k)
        tag = "0" if c.terms == {} else f"vars {sorted(c.variables())}"
        print(f"    coord[{k}] : {tag}")
    i, _ = lift_to_single_stage(nonzero)
    all_in = all(coeff(k).in_stage(i) for k in range(N + 50))
    print(f"  --> finite support => finitely many nonzero coords merge into S_{i}")
    print(f"      (all coordinates, including the zero tail, in S_{i}: {all_in})")
    print()


def demo_contrast() -> None:
    print("=" * 70)
    print("Demo D: Finite support is the exact dividing line")
    print("=" * 70)
    print("  The failing vector x_k = X_k is the MINIMAL violation:")
    print("  coordinate k sits at stage k, drifting outward with no cutoff.")
    print("  Truncating it at any N recovers a liftable sheared vector:")
    for N in (1, 3, 6):
        def coeff(k: int, N: int = N) -> Poly:
            return X(k) if k < N else ZERO
        nonzero = [coeff(k) for k in range(N)]
        i, _ = lift_to_single_stage(nonzero)
        print(f"    cutoff N = {N}:  lifts to stage S_{i}")
    print()


if __name__ == "__main__":
    demo_truncated_preservation()
    demo_naive_failure()
    demo_sheared_repair()
    demo_contrast()
    print("All demonstrations completed.")
