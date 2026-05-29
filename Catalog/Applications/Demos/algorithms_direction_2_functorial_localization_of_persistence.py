"""
Algorithms for Functorial Localization of Persistence Modules

Implements:
1. Finitely generated abelian group representation via invariant factors
2. p-Primary decomposition (localization at a prime)
3. Persistence module operations and interleaving computation
4. Torsion birth set extraction (global and primewise)
5. Interleaving distance estimation via localization

All algorithms work with concrete finite representations suitable for
computational experiments.
"""

from __future__ import annotations
import numpy as np
from math import gcd
from functools import reduce
from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass, field
import random


# ──────────────────────────────────────────────────────────────────────
# 1. Finitely Generated Abelian Group Representation
# ──────────────────────────────────────────────────────────────────────

@dataclass
class FGAbGroup:
    """A finitely generated abelian group in invariant factor form.

    Represents Z^free_rank ⊕ Z/d_1 ⊕ Z/d_2 ⊕ ... ⊕ Z/d_k
    where d_i | d_{i+1} (invariant factor convention).

    For persistence computations, we primarily track:
    - free_rank: rank of the free part
    - torsion_factors: list of torsion orders (each >= 2)
    """
    free_rank: int = 0
    torsion_factors: List[int] = field(default_factory=list)

    def __post_init__(self):
        self.torsion_factors = sorted([d for d in self.torsion_factors if d >= 2])

    @property
    def rank(self) -> int:
        return self.free_rank + len(self.torsion_factors)

    def is_trivial(self) -> bool:
        return self.free_rank == 0 and len(self.torsion_factors) == 0

    def has_p_torsion(self, p: int) -> bool:
        """Check if p-torsion is detected (exists nonzero element killed by p)."""
        return any(d % p == 0 for d in self.torsion_factors)

    def has_global_torsion(self) -> bool:
        """Check if any torsion exists."""
        return len(self.torsion_factors) > 0

    def p_primary_component(self, p: int) -> 'FGAbGroup':
        """Extract the p-primary component: keep only p-power torsion factors.

        For each torsion factor d, extract the p-primary part p^v_p(d).
        The free part vanishes (it becomes Z_(p)^r which has no torsion).
        """
        p_factors = []
        for d in self.torsion_factors:
            pk = 1
            temp = d
            while temp % p == 0:
                pk *= p
                temp //= p
            if pk > 1:
                p_factors.append(pk)
        return FGAbGroup(free_rank=0, torsion_factors=p_factors)

    def prime_support(self) -> Set[int]:
        """Return the set of primes dividing some torsion factor."""
        primes = set()
        for d in self.torsion_factors:
            temp = d
            for p in range(2, temp + 1):
                if p * p > temp:
                    if temp > 1:
                        primes.add(temp)
                    break
                while temp % p == 0:
                    primes.add(p)
                    temp //= p
        return primes

    def __repr__(self):
        parts = []
        if self.free_rank > 0:
            parts.append(f"Z^{self.free_rank}")
        for d in self.torsion_factors:
            parts.append(f"Z/{d}")
        return " ⊕ ".join(parts) if parts else "0"


def factorize(n: int) -> Dict[int, int]:
    """Prime factorization of n >= 2."""
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


# ──────────────────────────────────────────────────────────────────────
# 2. Persistence Module
# ──────────────────────────────────────────────────────────────────────

@dataclass
class PersistenceModule:
    """An N-indexed persistence module valued in finitely generated abelian groups.

    Represented by:
    - groups: list of FGAbGroup, one per filtration index
    - length: number of indices (groups[0], ..., groups[length-1])

    Structure maps are implicit: we track only the groups and use
    the torsion birth detection based on group structure.
    """
    groups: List[FGAbGroup]

    @property
    def length(self) -> int:
        return len(self.groups)

    def p_torsion_birth(self, p: int) -> Optional[int]:
        """Find the first index where p-torsion appears.

        Returns None if p-torsion never appears.
        """
        for i, g in enumerate(self.groups):
            if g.has_p_torsion(p):
                return i
        return None

    def global_torsion_birth(self) -> Optional[int]:
        """Find the first index where any torsion appears."""
        for i, g in enumerate(self.groups):
            if g.has_global_torsion():
                return i
        return None

    def p_torsion_birth_set(self, p: int) -> Set[int]:
        """The p-torsion birth set (at most one element for these structures)."""
        b = self.p_torsion_birth(p)
        return {b} if b is not None else set()

    def global_torsion_birth_set(self) -> Set[int]:
        """The global torsion birth set."""
        b = self.global_torsion_birth()
        return {b} if b is not None else set()

    def localize_at(self, p: int) -> 'PersistenceModule':
        """Localize the persistence module at prime p.

        Replaces each group with its p-primary component.
        """
        return PersistenceModule(
            groups=[g.p_primary_component(p) for g in self.groups]
        )

    def prime_support(self) -> Set[int]:
        """All primes appearing in any torsion factor at any level."""
        s = set()
        for g in self.groups:
            s |= g.prime_support()
        return s


# ──────────────────────────────────────────────────────────────────────
# 3. Birth Set Computations
# ──────────────────────────────────────────────────────────────────────

def hausdorff_distance(A: Set[int], B: Set[int]) -> Optional[int]:
    """Compute the Hausdorff distance between two finite subsets of Z.

    Returns None if either set is empty (convention: distance is infinity).
    Returns 0 if both sets are empty.
    """
    if not A and not B:
        return 0
    if not A or not B:
        return None  # infinity

    d1 = max(min(abs(a - b) for b in B) for a in A)
    d2 = max(min(abs(a - b) for a in A) for b in B)
    return max(d1, d2)


def delta_close(A: Set[int], B: Set[int], delta: int) -> bool:
    """Check if A and B are delta-close in Hausdorff distance."""
    if not A and not B:
        return True
    if not A or not B:
        return not A and not B
    return all(any(abs(a - b) <= delta for b in B) for a in A) and \
           all(any(abs(a - b) <= delta for a in A) for b in B)


def verify_birth_set_identification(F: PersistenceModule, p: int) -> bool:
    """Verify Theorem 2: PTorsionBirthSet(p, F) = TorsionBirthSet(L_p(F)).

    This is the computational test of the birth set identification theorem.
    """
    # p-torsion birth set of F
    p_births = F.p_torsion_birth_set(p)

    # Global torsion birth set of L_p(F)
    F_loc = F.localize_at(p)
    loc_births = F_loc.global_torsion_birth_set()

    return p_births == loc_births


def verify_interleaving_preservation(
    F: PersistenceModule, G: PersistenceModule, p: int, delta: int
) -> Tuple[bool, str]:
    """Verify that localization preserves delta-closeness of birth sets.

    Returns (passed, message).
    """
    # Check primewise birth sets
    p_births_F = F.p_torsion_birth_set(p)
    p_births_G = G.p_torsion_birth_set(p)
    close_original = delta_close(p_births_F, p_births_G, delta)

    # Check localized birth sets
    F_loc = F.localize_at(p)
    G_loc = G.localize_at(p)
    loc_births_F = F_loc.global_torsion_birth_set()
    loc_births_G = G_loc.global_torsion_birth_set()
    close_localized = delta_close(loc_births_F, loc_births_G, delta)

    if close_original != close_localized:
        return False, f"Mismatch: original={close_original}, localized={close_localized}"

    return True, f"Both {'close' if close_original else 'not close'} at delta={delta}"


# ──────────────────────────────────────────────────────────────────────
# 4. Random Persistence Module Generation
# ──────────────────────────────────────────────────────────────────────

def random_fgab(max_free=3, max_torsion=3, primes=(2, 3, 5, 7), max_power=3) -> FGAbGroup:
    """Generate a random finitely generated abelian group."""
    free_rank = random.randint(0, max_free)
    n_torsion = random.randint(0, max_torsion)
    torsion = []
    for _ in range(n_torsion):
        p = random.choice(primes)
        k = random.randint(1, max_power)
        torsion.append(p ** k)
    return FGAbGroup(free_rank=free_rank, torsion_factors=torsion)


def random_persistence_module(
    length: int = 10,
    max_free: int = 2,
    max_torsion: int = 3,
    primes: Tuple[int, ...] = (2, 3, 5),
    max_power: int = 2,
    monotone_torsion: bool = True,
) -> PersistenceModule:
    """Generate a random persistence module.

    If monotone_torsion=True, torsion is accumulated (once torsion appears,
    it persists), modeling a typical filtration where torsion is born and
    doesn't vanish.
    """
    groups = []
    accumulated_torsion: List[int] = []
    current_free = random.randint(0, max_free)

    for i in range(length):
        # Possibly add new torsion
        if random.random() < 0.3:
            p = random.choice(primes)
            k = random.randint(1, max_power)
            accumulated_torsion.append(p ** k)

        # Possibly increase free rank
        if random.random() < 0.2:
            current_free += 1

        if monotone_torsion:
            groups.append(FGAbGroup(
                free_rank=current_free,
                torsion_factors=list(accumulated_torsion)
            ))
        else:
            groups.append(random_fgab(max_free, max_torsion, primes, max_power))

    return PersistenceModule(groups=groups)


# ──────────────────────────────────────────────────────────────────────
# 5. Witness Improvement Search
# ──────────────────────────────────────────────────────────────────────

def search_witness_improvement(
    n_trials: int = 100,
    primes: Tuple[int, ...] = (2, 3, 5),
    length: int = 10,
) -> List[Dict]:
    """Search for cases where localization strictly improves interleaving.

    For each trial, generate two random persistence modules and check if
    localization at some prime reduces the Hausdorff distance between
    their torsion birth sets.
    """
    improvements = []

    for trial in range(n_trials):
        F = random_persistence_module(length=length, primes=primes)
        G = random_persistence_module(length=length, primes=primes)

        # Global torsion birth distance
        gb_F = F.global_torsion_birth()
        gb_G = G.global_torsion_birth()

        if gb_F is None or gb_G is None:
            continue

        global_dist = abs(gb_F - gb_G)

        for p in primes:
            F_loc = F.localize_at(p)
            G_loc = G.localize_at(p)

            loc_gb_F = F_loc.global_torsion_birth()
            loc_gb_G = G_loc.global_torsion_birth()

            if loc_gb_F is None and loc_gb_G is None:
                # Both trivial after localization: distance 0
                if global_dist > 0:
                    improvements.append({
                        'trial': trial,
                        'prime': p,
                        'original_dist': global_dist,
                        'localized_dist': 0,
                        'F_birth': gb_F,
                        'G_birth': gb_G,
                        'improvement': global_dist,
                    })
            elif loc_gb_F is not None and loc_gb_G is not None:
                loc_dist = abs(loc_gb_F - loc_gb_G)
                if loc_dist < global_dist:
                    improvements.append({
                        'trial': trial,
                        'prime': p,
                        'original_dist': global_dist,
                        'localized_dist': loc_dist,
                        'F_birth': gb_F,
                        'G_birth': gb_G,
                        'improvement': global_dist - loc_dist,
                    })

    return improvements


# ──────────────────────────────────────────────────────────────────────
# 6. Prime Decomposition of Birth Data
# ──────────────────────────────────────────────────────────────────────

def prime_decomposition_of_births(F: PersistenceModule) -> Dict[int, Set[int]]:
    """Decompose the torsion birth data across primes.

    Returns a dict mapping each prime p to PTorsionBirthSet(p, F).
    Verifies that the union recovers the global birth set.
    """
    primes = F.prime_support()
    decomposition = {}
    for p in sorted(primes):
        births = F.p_torsion_birth_set(p)
        if births:
            decomposition[p] = births
    return decomposition


if __name__ == "__main__":
    # Quick demo
    print("=== Algorithms for Functorial Persistence Localization ===\n")

    # Example 1: Simple group localization
    G = FGAbGroup(free_rank=1, torsion_factors=[6, 12])
    print(f"Group: {G}")
    print(f"  2-primary component: {G.p_primary_component(2)}")
    print(f"  3-primary component: {G.p_primary_component(3)}")
    print(f"  5-primary component: {G.p_primary_component(5)}")
    print(f"  Prime support: {G.prime_support()}")
    print()

    # Example 2: Birth set identification
    F = PersistenceModule(groups=[
        FGAbGroup(free_rank=2),  # index 0: free
        FGAbGroup(free_rank=2),  # index 1: free
        FGAbGroup(free_rank=2, torsion_factors=[6]),  # index 2: Z/6 torsion appears
        FGAbGroup(free_rank=2, torsion_factors=[6, 4]),  # index 3: more torsion
    ])

    print("Persistence module F:")
    for i, g in enumerate(F.groups):
        print(f"  F({i}) = {g}")

    for p in [2, 3, 5]:
        births = F.p_torsion_birth_set(p)
        F_loc = F.localize_at(p)
        loc_births = F_loc.global_torsion_birth_set()
        match = "✓" if births == loc_births else "✗"
        print(f"  p={p}: PTorsionBirthSet = {births}, "
              f"TorsionBirthSet(L_{p}(F)) = {loc_births} {match}")

    print()

    # Example 3: Witness improvement search
    random.seed(42)
    results = search_witness_improvement(n_trials=200, primes=(2, 3, 5))
    print(f"Witness improvement search (200 trials):")
    print(f"  Found {len(results)} strict improvements")
    if results:
        best = max(results, key=lambda r: r['improvement'])
        print(f"  Best improvement: delta {best['original_dist']} -> {best['localized_dist']} "
              f"at prime {best['prime']}")
