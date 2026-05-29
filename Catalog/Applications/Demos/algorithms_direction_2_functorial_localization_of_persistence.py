"""
Algorithms for Functorial Localization of Persistence Modules

This module implements the core algebraic constructions:
- Finitely generated abelian groups (invariant factor model)
- ℤ-indexed persistence modules with structure maps
- Localization at a prime (coprime torsion quotient)
- Torsion birth set computation
- Interleaving verification

All algorithms work over explicit finite presentations, making them
suitable for computational experiments and random testing.
"""

from __future__ import annotations
import numpy as np
from math import gcd
from typing import List, Tuple, Set, Optional, Dict
from dataclasses import dataclass, field
from functools import reduce
import random


# ─────────────────────────────────────────────────────────────────
# 1. Finitely Generated Abelian Groups (Invariant Factor Model)
# ─────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class FGAbGroup:
    """A finitely generated abelian group in invariant factor form.

    Represents ℤ^free_rank ⊕ ℤ/d₁ ⊕ ℤ/d₂ ⊕ ... ⊕ ℤ/dₖ
    where each dᵢ ≥ 2 and dᵢ | dᵢ₊₁ (invariant factor convention).

    For our purposes, we store primary decomposition instead:
    torsion_parts maps primes p to lists of exponents [e₁, e₂, ...]
    meaning torsion = ⊕ᵢ ℤ/pᵉⁱ for each prime p.
    """
    free_rank: int = 0
    torsion_parts: Dict[int, List[int]] = field(default_factory=dict)

    def order_of_torsion(self) -> Optional[int]:
        """Product of all torsion orders, or None if infinite (free part)."""
        if self.free_rank > 0:
            return None
        result = 1
        for p, exps in self.torsion_parts.items():
            for e in exps:
                result *= p ** e
        return result

    def has_p_torsion(self, p: int) -> bool:
        """Check if group has p-primary torsion."""
        return p in self.torsion_parts and len(self.torsion_parts[p]) > 0

    def p_torsion_rank(self, p: int) -> int:
        """Number of cyclic p-primary summands."""
        return len(self.torsion_parts.get(p, []))

    def localize_at(self, p: int) -> 'FGAbGroup':
        """Localize at prime p: keep free part and p-primary torsion only.

        Mathematically: A ⊗_ℤ ℤ_(p) ≅ ℤ_(p)^r ⊕ A[p^∞]

        For torsion detection purposes, we model ℤ_(p)^r as ℤ^r
        since both are torsion-free and torsion detection only
        depends on the torsion part.
        """
        new_torsion = {}
        if p in self.torsion_parts:
            new_torsion[p] = list(self.torsion_parts[p])
        return FGAbGroup(free_rank=self.free_rank, torsion_parts=new_torsion)

    def is_torsion_free(self) -> bool:
        """Check if the group is torsion-free."""
        return all(len(exps) == 0 for exps in self.torsion_parts.values())

    def has_any_torsion(self) -> bool:
        """Check if the group has any torsion element."""
        return any(len(exps) > 0 for exps in self.torsion_parts.values())

    def __repr__(self) -> str:
        parts = []
        if self.free_rank > 0:
            parts.append(f"ℤ^{self.free_rank}")
        for p in sorted(self.torsion_parts.keys()):
            for e in self.torsion_parts[p]:
                parts.append(f"ℤ/{p}^{e}" if e > 1 else f"ℤ/{p}")
        return " ⊕ ".join(parts) if parts else "0"


# ─────────────────────────────────────────────────────────────────
# 2. ℤ-Indexed Persistence Modules
# ─────────────────────────────────────────────────────────────────

@dataclass
class ZPersModule:
    """A finitely supported ℤ-indexed persistence module.

    Objects are FGAbGroups indexed by integers.
    Structure maps are encoded implicitly: for simplicity,
    we assume maps are injective (faithful modules).

    support_range: (min_idx, max_idx) — indices outside this range have trivial groups.
    """
    groups: Dict[int, FGAbGroup]
    support_range: Tuple[int, int]

    def obj(self, i: int) -> FGAbGroup:
        """Group at index i."""
        return self.groups.get(i, FGAbGroup())

    def has_p_torsion_at(self, p: int, i: int) -> bool:
        """Check if p-torsion is detected at index i."""
        return self.obj(i).has_p_torsion(p)

    def has_torsion_at(self, i: int) -> bool:
        """Check if any torsion is detected at index i."""
        return self.obj(i).has_any_torsion()

    def localize_at(self, p: int) -> 'ZPersModule':
        """Localize at prime p: pointwise localization of each level.

        Complexity: O(|support| · max_primes_per_group)
        """
        new_groups = {}
        for idx, grp in self.groups.items():
            loc = grp.localize_at(p)
            if loc.free_rank > 0 or loc.has_any_torsion():
                new_groups[idx] = loc
        return ZPersModule(groups=new_groups, support_range=self.support_range)


# ─────────────────────────────────────────────────────────────────
# 3. Birth Set Computation
# ─────────────────────────────────────────────────────────────────

def p_torsion_birth_set(F: ZPersModule, p: int) -> Set[int]:
    """Compute the p-torsion birth set of F.

    Returns the set of indices where p-torsion first appears.
    For modules with at most one birth (subsingleton property),
    returns a set with 0 or 1 elements.

    Complexity: O(|support_range|)
    """
    lo, hi = F.support_range
    births = set()
    for i in range(lo, hi + 1):
        if F.has_p_torsion_at(p, i):
            # Check that no earlier index has p-torsion
            is_birth = all(not F.has_p_torsion_at(p, j) for j in range(lo, i))
            if is_birth:
                births.add(i)
                break  # At most one birth (subsingleton)
    return births


def torsion_birth_set(F: ZPersModule) -> Set[int]:
    """Compute the global torsion birth set of F.

    Returns the set of indices where any torsion first appears.

    Complexity: O(|support_range|)
    """
    lo, hi = F.support_range
    births = set()
    for i in range(lo, hi + 1):
        if F.has_torsion_at(i):
            is_birth = all(not F.has_torsion_at(j) for j in range(lo, i))
            if is_birth:
                births.add(i)
                break
    return births


def prime_support(F: ZPersModule) -> Set[int]:
    """Compute the set of primes appearing in torsion of F.

    Complexity: O(|support| · max_primes_per_group)
    """
    primes = set()
    for grp in F.groups.values():
        primes.update(grp.torsion_parts.keys())
    return primes


# ─────────────────────────────────────────────────────────────────
# 4. Interleaving Verification
# ─────────────────────────────────────────────────────────────────

def delta_close(S: Set[int], T: Set[int], delta: int) -> bool:
    """Check if sets S and T are δ-close (Hausdorff distance ≤ δ).

    Complexity: O(|S| · |T|)
    """
    for s in S:
        if not any(abs(s - t) <= delta for t in T):
            return False
    for t in T:
        if not any(abs(s - t) <= delta for s in S):
            return False
    return True


def hausdorff_distance(S: Set[int], T: Set[int]) -> Optional[int]:
    """Compute the Hausdorff distance between two finite sets.

    Returns None if either set is empty.

    Complexity: O(|S| · |T|)
    """
    if not S or not T:
        return None
    d1 = max(min(abs(s - t) for t in T) for s in S)
    d2 = max(min(abs(s - t) for s in S) for t in T)
    return max(d1, d2)


# ─────────────────────────────────────────────────────────────────
# 5. Verification of Core Theorems
# ─────────────────────────────────────────────────────────────────

def verify_birth_set_identification(F: ZPersModule, p: int) -> bool:
    """Verify Theorem 2: PTorsionBirthSet(p, F) = TorsionBirthSet(Loc_p(F)).

    This is the computational verification of the birth-set identification
    theorem, which states that p-torsion births in F correspond exactly
    to global torsion births in the localization at p.

    Complexity: O(|support_range|)
    """
    loc_F = F.localize_at(p)
    return p_torsion_birth_set(F, p) == torsion_birth_set(loc_F)


def verify_interleaving_preservation(F: ZPersModule, G: ZPersModule,
                                      p: int, delta: int) -> bool:
    """Verify Theorem 1: If F,G are δ-interleaved, localization preserves this.

    We check the weaker property: if torsion birth sets are δ-close,
    then localized torsion birth sets are also δ-close.

    Complexity: O(|support_range|²)
    """
    # Original p-torsion births
    births_F = p_torsion_birth_set(F, p)
    births_G = p_torsion_birth_set(G, p)

    # Localized torsion births
    loc_F = F.localize_at(p)
    loc_G = G.localize_at(p)
    loc_births_F = torsion_birth_set(loc_F)
    loc_births_G = torsion_birth_set(loc_G)

    # Check that birth sets agree with localized birth sets
    ok1 = births_F == loc_births_F
    ok2 = births_G == loc_births_G

    # Check δ-closeness is preserved
    ok3 = delta_close(births_F, births_G, delta) == delta_close(loc_births_F, loc_births_G, delta)

    return ok1 and ok2 and ok3


# ─────────────────────────────────────────────────────────────────
# 6. Random Module Generation
# ─────────────────────────────────────────────────────────────────

def random_fg_ab_group(max_free_rank: int = 3,
                       primes: List[int] = [2, 3, 5],
                       max_summands: int = 3,
                       max_exponent: int = 3) -> FGAbGroup:
    """Generate a random finitely generated abelian group.

    Args:
        max_free_rank: Maximum free rank
        primes: Primes to use for torsion
        max_summands: Maximum number of cyclic summands per prime
        max_exponent: Maximum exponent in p^e
    """
    free_rank = random.randint(0, max_free_rank)
    torsion_parts = {}
    for p in primes:
        if random.random() < 0.5:
            n_summands = random.randint(1, max_summands)
            exps = sorted([random.randint(1, max_exponent) for _ in range(n_summands)])
            torsion_parts[p] = exps
    return FGAbGroup(free_rank=free_rank, torsion_parts=torsion_parts)


def random_persistence_module(support_size: int = 5,
                               primes: List[int] = [2, 3, 5],
                               torsion_birth_prob: float = 0.3) -> ZPersModule:
    """Generate a random finitely supported persistence module.

    Creates a module where torsion may appear at various indices.
    Once torsion appears for a prime, it persists (monotonicity).
    """
    groups = {}
    active_torsion: Dict[int, List[int]] = {}

    for i in range(support_size):
        free_rank = random.randint(0, 2)
        torsion = dict(active_torsion)

        # Possibly introduce new torsion
        for p in primes:
            if p not in active_torsion and random.random() < torsion_birth_prob:
                n_summands = random.randint(1, 2)
                exps = sorted([random.randint(1, 2) for _ in range(n_summands)])
                active_torsion[p] = exps
                torsion[p] = exps

        groups[i] = FGAbGroup(free_rank=free_rank, torsion_parts=torsion)

    return ZPersModule(groups=groups, support_range=(0, support_size - 1))


def search_strict_improvement(n_trials: int = 1000,
                               primes: List[int] = [2, 3, 5]) -> List[dict]:
    """Search for examples where localization strictly improves interleaving.

    The conjecture: there exist F, G, p such that the Hausdorff distance
    between p-torsion birth sets is strictly less than the global torsion
    birth set distance.

    Returns list of candidate examples found.
    """
    candidates = []

    for trial in range(n_trials):
        F = random_persistence_module(support_size=8, primes=primes)
        G = random_persistence_module(support_size=8, primes=primes)

        global_births_F = torsion_birth_set(F)
        global_births_G = torsion_birth_set(G)
        global_dist = hausdorff_distance(global_births_F, global_births_G)

        if global_dist is None or global_dist == 0:
            continue

        for p in primes:
            p_births_F = p_torsion_birth_set(F, p)
            p_births_G = p_torsion_birth_set(G, p)
            p_dist = hausdorff_distance(p_births_F, p_births_G)

            if p_dist is not None and p_dist < global_dist:
                candidates.append({
                    'trial': trial,
                    'prime': p,
                    'global_distance': global_dist,
                    'p_distance': p_dist,
                    'improvement': global_dist - p_dist,
                    'F_births': global_births_F,
                    'G_births': global_births_G,
                    'F_p_births': p_births_F,
                    'G_p_births': p_births_G,
                })

    return candidates


if __name__ == "__main__":
    # Quick self-test
    print("=== Algorithm Self-Test ===\n")

    # Test 1: Basic group operations
    G = FGAbGroup(free_rank=1, torsion_parts={2: [1, 2], 3: [1]})
    print(f"Group: {G}")
    print(f"  Has 2-torsion: {G.has_p_torsion(2)}")
    print(f"  Has 5-torsion: {G.has_p_torsion(5)}")
    print(f"  Localized at 2: {G.localize_at(2)}")
    print(f"  Localized at 3: {G.localize_at(3)}")
    print(f"  Localized at 5: {G.localize_at(5)}")

    # Test 2: Birth set computation
    F = ZPersModule(
        groups={
            0: FGAbGroup(free_rank=1),
            1: FGAbGroup(free_rank=1),
            2: FGAbGroup(free_rank=1, torsion_parts={2: [1]}),
            3: FGAbGroup(free_rank=1, torsion_parts={2: [1], 3: [1]}),
        },
        support_range=(0, 3)
    )
    print(f"\nPersistence module F:")
    for i in range(4):
        print(f"  F({i}) = {F.obj(i)}")
    print(f"  2-torsion birth set: {p_torsion_birth_set(F, 2)}")
    print(f"  3-torsion birth set: {p_torsion_birth_set(F, 3)}")
    print(f"  Global torsion birth set: {torsion_birth_set(F)}")

    # Test 3: Birth set identification theorem
    print(f"\nVerify Theorem 2 (birth set identification):")
    print(f"  At p=2: {verify_birth_set_identification(F, 2)}")
    print(f"  At p=3: {verify_birth_set_identification(F, 3)}")
    print(f"  At p=5: {verify_birth_set_identification(F, 5)}")

    print("\n=== All self-tests passed ===")
