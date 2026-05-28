"""
Algorithms for Functorial Localization of Persistence Modules

Implements the core algebraic constructions for computing localized persistence
modules, torsion birth sets, and interleaving distances.

Mathematical background:
  For a finitely generated abelian group A ≅ ℤ^r ⊕ ⊕_i ℤ/n_i ℤ,
  localization at a prime p gives:
    A ⊗_ℤ ℤ_(p) ≅ ℤ_(p)^r ⊕ A[p^∞]
  where A[p^∞] is the p-primary torsion subgroup.
  Only p-primary torsion survives; all q-torsion for q ≠ p vanishes.
"""

from __future__ import annotations
import math
import random
from dataclasses import dataclass, field
from typing import List, Tuple, Set, Optional, Dict
from collections import defaultdict


# ---------------------------------------------------------------------------
# Finitely Generated Abelian Group representation
# ---------------------------------------------------------------------------

@dataclass
class FGAbGroup:
    """A finitely generated abelian group in invariant factor form.

    Represented as ℤ^free_rank ⊕ ⊕_i ℤ/torsion_coeffs[i].
    Each torsion coefficient is ≥ 2.
    """
    free_rank: int
    torsion_coeffs: List[int]  # each ≥ 2

    def __post_init__(self):
        self.torsion_coeffs = sorted([c for c in self.torsion_coeffs if c >= 2])

    @property
    def rank(self) -> int:
        return self.free_rank + len(self.torsion_coeffs)

    def has_p_torsion(self, p: int) -> bool:
        """Check if p-torsion is detected: ∃ nonzero a with p·a = 0."""
        for c in self.torsion_coeffs:
            if c % p == 0:
                return True
        return False

    def has_global_torsion(self) -> bool:
        """Check if any torsion exists."""
        return len(self.torsion_coeffs) > 0

    def prime_support(self) -> Set[int]:
        """Return set of primes p such that p-torsion is detected."""
        primes = set()
        for c in self.torsion_coeffs:
            for p in prime_factors(c):
                primes.add(p)
        return primes

    def localize_at(self, p: int) -> 'FGAbGroup':
        """Localize at prime p.

        Mathematically: A ⊗_ℤ ℤ_(p).
        Concretely: keep free part, keep only p-primary torsion summands.

        For ℤ/nℤ with n = p^a · m (gcd(m,p)=1):
          ℤ/nℤ ⊗ ℤ_(p) ≅ ℤ/p^a ℤ

        So we replace each torsion coefficient n by its p-part p^(v_p(n)).
        If v_p(n) = 0, the summand vanishes.
        """
        new_torsion = []
        for c in self.torsion_coeffs:
            pk = p_part(c, p)
            if pk > 1:
                new_torsion.append(pk)
        return FGAbGroup(free_rank=self.free_rank, torsion_coeffs=new_torsion)

    def __repr__(self) -> str:
        parts = []
        if self.free_rank > 0:
            parts.append(f"ℤ^{self.free_rank}")
        for c in self.torsion_coeffs:
            parts.append(f"ℤ/{c}")
        return " ⊕ ".join(parts) if parts else "0"


# ---------------------------------------------------------------------------
# Number-theoretic utilities
# ---------------------------------------------------------------------------

def prime_factors(n: int) -> List[int]:
    """Return the list of prime factors of n (with repetition)."""
    factors = []
    d = 2
    while d * d <= abs(n):
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if abs(n) > 1:
        factors.append(abs(n))
    return factors


def distinct_prime_factors(n: int) -> Set[int]:
    """Return the set of distinct prime factors of n."""
    return set(prime_factors(n))


def p_part(n: int, p: int) -> int:
    """Return the p-part of n: the largest power of p dividing n."""
    result = 1
    while n % p == 0:
        result *= p
        n //= p
    return result


def is_prime(n: int) -> bool:
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


# ---------------------------------------------------------------------------
# Persistence Module (Filtration Family)
# ---------------------------------------------------------------------------

@dataclass
class PersistenceModule:
    """A finite persistence module: sequence of FGAbGroups with structure maps.

    For simplicity, we model each group by its invariant factor decomposition.
    Structure maps are modeled implicitly: we assume injective maps that
    preserve the torsion structure (embedding of summands).

    Attributes:
        groups: list of FGAbGroup, indexed by ℕ from 0 to len-1.
        length: number of levels.
    """
    groups: List[FGAbGroup]

    @property
    def length(self) -> int:
        return len(self.groups)

    def p_torsion_birth(self, p: int) -> Optional[int]:
        """Find the index where p-torsion first appears.

        Returns None if p-torsion is never detected.
        """
        for i, g in enumerate(self.groups):
            if g.has_p_torsion(p):
                return i
        return None

    def global_torsion_birth(self) -> Optional[int]:
        """Find the index where any torsion first appears."""
        for i, g in enumerate(self.groups):
            if g.has_global_torsion():
                return i
        return None

    def p_torsion_birth_set(self, p: int) -> Set[int]:
        """The p-torsion birth set (at most one element for our model)."""
        b = self.p_torsion_birth(p)
        return {b} if b is not None else set()

    def global_torsion_birth_set(self) -> Set[int]:
        """The global torsion birth set."""
        b = self.global_torsion_birth()
        return {b} if b is not None else set()

    def localize_at(self, p: int) -> 'PersistenceModule':
        """Localize the persistence module at prime p.

        Applies localization level-wise: each group A_i is replaced by
        A_i ⊗_ℤ ℤ_(p), which keeps only p-primary torsion.
        """
        return PersistenceModule(
            groups=[g.localize_at(p) for g in self.groups]
        )

    def prime_support(self) -> Set[int]:
        """All primes that appear in any torsion coefficient at any level."""
        support = set()
        for g in self.groups:
            support |= g.prime_support()
        return support

    def torsion_birth_spectrum(self) -> Dict[int, Optional[int]]:
        """Compute the full primewise birth spectrum.

        Returns a dict mapping each prime p in the support to the
        index where p-torsion first appears.
        """
        return {p: self.p_torsion_birth(p) for p in self.prime_support()}

    def __repr__(self) -> str:
        lines = []
        for i, g in enumerate(self.groups):
            lines.append(f"  Level {i}: {g}")
        return "PersistenceModule:\n" + "\n".join(lines)


# ---------------------------------------------------------------------------
# Interleaving and Distance
# ---------------------------------------------------------------------------

def hausdorff_distance(A: Set[int], B: Set[int]) -> int:
    """Compute the Hausdorff distance between two finite subsets of ℕ.

    Returns 0 if both sets are empty.
    Returns infinity (represented as 10**9) if one is empty and the other is not.
    """
    if not A and not B:
        return 0
    if not A or not B:
        return 10**9  # infinity surrogate

    d1 = max(min(abs(a - b) for b in B) for a in A)
    d2 = max(min(abs(a - b) for a in A) for b in B)
    return max(d1, d2)


def sets_are_delta_close(A: Set[int], B: Set[int], delta: int) -> bool:
    """Check if A and B are δ-close in the Hausdorff sense."""
    return hausdorff_distance(A, B) <= delta


def interleaving_distance_upper_bound(F: PersistenceModule,
                                       G: PersistenceModule) -> int:
    """Compute an upper bound on the interleaving distance.

    Uses the global torsion birth sets as a proxy.
    The actual interleaving distance requires checking all possible shift maps.
    """
    A = F.global_torsion_birth_set()
    B = G.global_torsion_birth_set()
    return hausdorff_distance(A, B)


def p_interleaving_distance_bound(F: PersistenceModule,
                                   G: PersistenceModule,
                                   p: int) -> int:
    """Upper bound on interleaving distance of localized modules.

    Computed as the Hausdorff distance between p-torsion birth sets.
    """
    A = F.p_torsion_birth_set(p)
    B = G.p_torsion_birth_set(p)
    return hausdorff_distance(A, B)


# ---------------------------------------------------------------------------
# Random Persistence Module Generation
# ---------------------------------------------------------------------------

def random_fgab_group(max_rank: int = 3,
                      max_torsion_summands: int = 3,
                      primes: List[int] = None,
                      max_power: int = 3) -> FGAbGroup:
    """Generate a random finitely generated abelian group.

    Args:
        max_rank: maximum free rank.
        max_torsion_summands: maximum number of torsion summands.
        primes: list of primes to use for torsion coefficients.
        max_power: maximum prime power exponent.
    """
    if primes is None:
        primes = [2, 3, 5]

    free_rank = random.randint(0, max_rank)
    n_torsion = random.randint(0, max_torsion_summands)
    torsion = []
    for _ in range(n_torsion):
        p = random.choice(primes)
        k = random.randint(1, max_power)
        torsion.append(p ** k)
    return FGAbGroup(free_rank=free_rank, torsion_coeffs=torsion)


def random_persistence_module(length: int = 5,
                               max_rank: int = 2,
                               max_torsion: int = 3,
                               primes: List[int] = None,
                               growing: bool = True) -> PersistenceModule:
    """Generate a random persistence module.

    If growing=True, torsion can only appear or grow along the filtration
    (modeling injective structure maps that may introduce new torsion).
    """
    if primes is None:
        primes = [2, 3, 5]

    groups = []
    current_torsion: List[int] = []
    current_free_rank = random.randint(0, max_rank)

    for _ in range(length):
        # Possibly add new torsion summands
        if growing and random.random() < 0.4:
            p = random.choice(primes)
            k = random.randint(1, 3)
            current_torsion.append(p ** k)

        groups.append(FGAbGroup(
            free_rank=current_free_rank,
            torsion_coeffs=list(current_torsion)
        ))

    return PersistenceModule(groups=groups)


# ---------------------------------------------------------------------------
# Verification Algorithms
# ---------------------------------------------------------------------------

def verify_birth_identification(F: PersistenceModule, p: int) -> bool:
    """Verify Theorem 2: PTorBirth(p, F) = GlobTorBirth(LocalizedAtPrime(p, F)).

    Returns True if the identification holds.

    Mathematical content:
      The p-torsion birth set of F should equal the global torsion
      birth set of the localized module L_p(F), because localization
      at p kills all q-torsion for q ≠ p, leaving exactly p-primary torsion.
    """
    L = F.localize_at(p)
    ptor_birth = F.p_torsion_birth_set(p)
    glob_birth_loc = L.global_torsion_birth_set()
    return ptor_birth == glob_birth_loc


def verify_interleaving_preservation(F: PersistenceModule,
                                      G: PersistenceModule,
                                      p: int,
                                      delta: int) -> bool:
    """Verify Theorem 1: localization preserves δ-closeness.

    If PTorBirth(p,F) and PTorBirth(p,G) are δ-close,
    then GlobTorBirth(L_p(F)) and GlobTorBirth(L_p(G)) should also be δ-close.
    """
    LF = F.localize_at(p)
    LG = G.localize_at(p)

    ptor_F = F.p_torsion_birth_set(p)
    ptor_G = G.p_torsion_birth_set(p)
    glob_LF = LF.global_torsion_birth_set()
    glob_LG = LG.global_torsion_birth_set()

    close_original = sets_are_delta_close(ptor_F, ptor_G, delta)
    close_localized = sets_are_delta_close(glob_LF, glob_LG, delta)

    # By Theorem 1, if the original is δ-close, so should the localized version
    # By Theorem 2, these are the same sets, so they should be equivalent
    return close_original == close_localized


def search_strict_improvement(F: PersistenceModule,
                               G: PersistenceModule,
                               p: int) -> Optional[Tuple[int, int]]:
    """Search for strict witness improvement under localization.

    Returns (global_dist, local_dist) if local_dist < global_dist,
    or None if no improvement found.

    This tests the conjecture that localization can strictly improve
    interleaving witnesses by filtering out irrelevant torsion.
    """
    global_dist = interleaving_distance_upper_bound(F, G)
    local_dist = p_interleaving_distance_bound(F, G, p)

    if local_dist < global_dist:
        return (global_dist, local_dist)
    return None


def prime_decomposition_verification(F: PersistenceModule) -> bool:
    """Verify the cross-domain theorem: global torsion births decompose over primes.

    For each index in the global torsion birth set, verify that
    there exists a prime p such that p-torsion is born at or before that index.
    """
    glob_birth = F.global_torsion_birth()
    if glob_birth is None:
        return True  # vacuously true

    # Check: ∃ p prime, ∃ j ∈ PTorBirth(p,F), j ≤ glob_birth
    for p in F.prime_support():
        ptor = F.p_torsion_birth(p)
        if ptor is not None and ptor <= glob_birth:
            return True

    return False


# ---------------------------------------------------------------------------
# Analysis Functions
# ---------------------------------------------------------------------------

def analyze_localization(F: PersistenceModule) -> Dict:
    """Full analysis of a persistence module under localization at all primes.

    Returns a dictionary with:
      - prime_support: set of primes in the module
      - birth_spectrum: dict of p -> birth index
      - localized_modules: dict of p -> localized module info
      - birth_identification_verified: bool
    """
    support = F.prime_support()
    results = {
        'prime_support': support,
        'birth_spectrum': {},
        'localized_births': {},
        'identification_verified': True,
    }

    for p in sorted(support):
        results['birth_spectrum'][p] = F.p_torsion_birth(p)
        L = F.localize_at(p)
        results['localized_births'][p] = L.global_torsion_birth()
        if not verify_birth_identification(F, p):
            results['identification_verified'] = False

    return results


if __name__ == "__main__":
    print("=== Functorial Localization Algorithms ===\n")

    # Example 1: Manual construction
    print("--- Example 1: ℤ/6ℤ group ---")
    A = FGAbGroup(free_rank=0, torsion_coeffs=[6])
    print(f"Group: {A}")
    print(f"2-torsion: {A.has_p_torsion(2)}")
    print(f"3-torsion: {A.has_p_torsion(3)}")
    print(f"5-torsion: {A.has_p_torsion(5)}")
    print(f"Localized at 2: {A.localize_at(2)}")
    print(f"Localized at 3: {A.localize_at(3)}")
    print(f"Localized at 5: {A.localize_at(5)}")
    print(f"Prime support: {A.prime_support()}")

    # Example 2: Persistence module
    print("\n--- Example 2: Growing persistence module ---")
    F = PersistenceModule(groups=[
        FGAbGroup(1, []),         # Level 0: ℤ
        FGAbGroup(1, []),         # Level 1: ℤ
        FGAbGroup(1, [6]),        # Level 2: ℤ ⊕ ℤ/6
        FGAbGroup(1, [6, 4]),     # Level 3: ℤ ⊕ ℤ/6 ⊕ ℤ/4
        FGAbGroup(1, [6, 4, 9]), # Level 4: ℤ ⊕ ℤ/6 ⊕ ℤ/4 ⊕ ℤ/9
    ])
    print(F)
    print(f"\nPrime support: {F.prime_support()}")
    print(f"Birth spectrum: {F.torsion_birth_spectrum()}")

    analysis = analyze_localization(F)
    print(f"Birth identification verified: {analysis['identification_verified']}")
    for p in sorted(analysis['prime_support']):
        print(f"  p={p}: original birth={analysis['birth_spectrum'][p]}, "
              f"localized birth={analysis['localized_births'][p]}")
