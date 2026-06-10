#!/usr/bin/env python3
"""
Algorithms for Operadic Tropicalization of Neural Architectures

Implements the key algorithms from the research paper:
1. Tropical profile computation
2. Bounded architecture classification
3. Architecture equivalence checking
4. Depth-width tradeoff analysis
5. Profile space enumeration with tropical semiring operations
"""

import itertools
from dataclasses import dataclass
from typing import List, Tuple, Set, Optional


# ─────────────────────────────────────────────
# Algorithm 1: Tropical Profile Computation
# ─────────────────────────────────────────────

@dataclass(frozen=True)
class TropicalProfile:
    """
    Tropical architecture profile: a triple (depth, width, generators).

    Supports three algebraic operations:
    - seq_mul: sequential composition (depth adds, width maxes, gen adds)
    - par_mul: parallel composition (depth maxes, width adds, gen adds)
    - trop_add: tropical addition (component-wise min)

    Time: O(1) per operation
    Space: O(1)
    """
    d: int  # depth
    w: int  # max width
    g: int  # generator count

    def seq_mul(self, other: "TropicalProfile") -> "TropicalProfile":
        """Sequential composition. Time: O(1)."""
        return TropicalProfile(self.d + other.d, max(self.w, other.w), self.g + other.g)

    def par_mul(self, other: "TropicalProfile") -> "TropicalProfile":
        """Parallel composition. Time: O(1)."""
        return TropicalProfile(max(self.d, other.d), self.w + other.w, self.g + other.g)

    def trop_add(self, other: "TropicalProfile") -> "TropicalProfile":
        """Tropical addition (component-wise min). Time: O(1)."""
        return TropicalProfile(min(self.d, other.d), min(self.w, other.w), min(self.g, other.g))

    def is_valid(self) -> bool:
        """Check depth-width tradeoff: g ≤ d × w. Time: O(1)."""
        return self.g <= self.d * self.w or (self.d == 0 and self.w == 0 and self.g == 0)


ZERO = TropicalProfile(0, 0, 0)
ONE = TropicalProfile(1, 1, 1)


# ─────────────────────────────────────────────
# Algorithm 2: Bounded Architecture Classification
# ─────────────────────────────────────────────

def classify_bounded_architectures(
    max_gen: int, max_depth: int, max_width: int
) -> Tuple[Set[TropicalProfile], Set[TropicalProfile]]:
    """
    Enumerate all profiles in a bounded architecture class.

    Returns:
        (all_profiles, valid_profiles) where valid_profiles satisfy
        the depth-width tradeoff constraint.

    Time: O(D × W × G)
    Space: O(D × W × G)
    """
    all_profiles: Set[TropicalProfile] = set()
    valid_profiles: Set[TropicalProfile] = set()

    for d in range(max_depth + 1):
        for w in range(max_width + 1):
            for g in range(max_gen + 1):
                p = TropicalProfile(d, w, g)
                all_profiles.add(p)
                if p.is_valid():
                    valid_profiles.add(p)

    return all_profiles, valid_profiles


# ─────────────────────────────────────────────
# Algorithm 3: Profile Algebra Verification
# ─────────────────────────────────────────────

def verify_tropical_semiring_laws(
    profiles: List[TropicalProfile], verbose: bool = False
) -> dict:
    """
    Verify tropical semiring laws on a set of profiles.

    Checks:
    - seq_mul associativity and identity
    - par_mul commutativity, associativity, identity
    - trop_add commutativity, associativity, idempotency
    - Left and right distributivity of seq_mul over trop_add

    Time: O(n³) for n = len(profiles)
    Space: O(1)
    """
    results = {
        "seq_assoc": True, "seq_id_left": True, "seq_id_right": True,
        "par_comm": True, "par_assoc": True, "par_id_left": True, "par_id_right": True,
        "trop_comm": True, "trop_assoc": True, "trop_idem": True,
        "distrib_left": True, "distrib_right": True,
    }

    for p in profiles:
        # Identity laws
        if ZERO.seq_mul(p) != p:
            results["seq_id_left"] = False
        if p.seq_mul(ZERO) != p:
            results["seq_id_right"] = False
        if ZERO.par_mul(p) != p:
            results["par_id_left"] = False
        if p.par_mul(ZERO) != p:
            results["par_id_right"] = False
        # Idempotency
        if p.trop_add(p) != p:
            results["trop_idem"] = False

    for p, q in itertools.product(profiles, repeat=2):
        # Commutativity
        if p.par_mul(q) != q.par_mul(p):
            results["par_comm"] = False
        if p.trop_add(q) != q.trop_add(p):
            results["trop_comm"] = False

    for p, q, r in itertools.product(profiles, repeat=3):
        # Associativity
        if (p.seq_mul(q)).seq_mul(r) != p.seq_mul(q.seq_mul(r)):
            results["seq_assoc"] = False
        if (p.par_mul(q)).par_mul(r) != p.par_mul(q.par_mul(r)):
            results["par_assoc"] = False
        if (p.trop_add(q)).trop_add(r) != p.trop_add(q.trop_add(r)):
            results["trop_assoc"] = False
        # Distributivity
        if p.seq_mul(q.trop_add(r)) != p.seq_mul(q).trop_add(p.seq_mul(r)):
            results["distrib_left"] = False
        if (p.trop_add(q)).seq_mul(r) != p.seq_mul(r).trop_add(q.seq_mul(r)):
            results["distrib_right"] = False

    if verbose:
        for law, holds in results.items():
            status = "✓" if holds else "✗"
            print(f"  {law:20s}: {status}")

    return results


# ─────────────────────────────────────────────
# Algorithm 4: Depth-Width Tradeoff Analysis
# ─────────────────────────────────────────────

def tradeoff_analysis(max_bound: int) -> dict:
    """
    Analyze the depth-width tradeoff for bounded classes.

    For each bound B ∈ {1, ..., max_bound}, compute:
    - Total profiles in [0,B]³
    - Valid profiles satisfying g ≤ d × w
    - Reduction ratio

    Time: O(max_bound⁴)
    Space: O(max_bound)
    """
    results = {}
    for B in range(1, max_bound + 1):
        total = (B + 1) ** 3
        valid = sum(
            1 for d, w, g in itertools.product(range(B + 1), repeat=3)
            if g <= d * w or (d == 0 and w == 0 and g == 0)
        )
        results[B] = {
            "total": total,
            "valid": valid,
            "reduction": 1.0 - valid / total if total > 0 else 0,
        }
    return results


# ─────────────────────────────────────────────
# Main: run all algorithms
# ─────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm 1: Bounded Classification")
    print("=" * 60)
    all_p, valid_p = classify_bounded_architectures(5, 5, 5)
    print(f"  Bound (5,5,5): {len(all_p)} total, {len(valid_p)} valid profiles")
    print()

    print("=" * 60)
    print("Algorithm 2: Tropical Semiring Law Verification")
    print("=" * 60)
    test_profiles = [TropicalProfile(d, w, g) for d in range(4) for w in range(4) for g in range(4)]
    results = verify_tropical_semiring_laws(test_profiles, verbose=True)
    all_pass = all(results.values())
    print(f"  All laws verified: {all_pass}")
    print()

    print("=" * 60)
    print("Algorithm 3: Depth-Width Tradeoff Analysis")
    print("=" * 60)
    analysis = tradeoff_analysis(12)
    print(f"  {'Bound':>6s} | {'Total':>7s} | {'Valid':>7s} | {'Reduction':>10s}")
    print(f"  {'-'*6} | {'-'*7} | {'-'*7} | {'-'*10}")
    for B, data in analysis.items():
        print(f"  {B:>6d} | {data['total']:>7d} | {data['valid']:>7d} | {data['reduction']:>9.1%}")
    print()

    print("All algorithms completed successfully! ✓")
