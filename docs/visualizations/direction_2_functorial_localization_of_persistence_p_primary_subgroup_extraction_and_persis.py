#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Functorial Localization of Persistence Modules

Implements the core algorithms described in the research paper:
1. p-Primary subgroup extraction
2. Persistence module localization
3. Torsion birth set computation
4. Interleaving distance estimation
5. Prime decomposition analysis

All algorithms operate on finitely generated abelian groups in invariant
factor (Smith normal form) representation.
"""

from typing import List, Dict, Set, Tuple, Optional
from collections import defaultdict
import math


# ──────────────────────────────────────────────────────────────────────
# Algorithm 1: Prime Factorization and p-adic Valuation
# ──────────────────────────────────────────────────────────────────────

def prime_factorization(n: int) -> Dict[int, int]:
    """Compute the prime factorization of n.
    
    Returns dict mapping prime -> exponent.
    Time complexity: O(sqrt(n))
    Space complexity: O(log n)
    
    >>> prime_factorization(60)
    {2: 2, 3: 1, 5: 1}
    """
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = 1
    return factors


def p_adic_valuation(n: int, p: int) -> int:
    """Compute v_p(n), the p-adic valuation of n.
    
    Time complexity: O(log_p(n))
    
    >>> p_adic_valuation(72, 2)
    3
    >>> p_adic_valuation(72, 3)
    2
    """
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def p_primary_part(n: int, p: int) -> int:
    """Compute p^{v_p(n)}, the p-primary part of n.
    
    >>> p_primary_part(60, 2)
    4
    >>> p_primary_part(60, 3)
    3
    >>> p_primary_part(60, 7)
    1
    """
    return p ** p_adic_valuation(n, p)


# ──────────────────────────────────────────────────────────────────────
# Algorithm 2: Finitely Generated Abelian Group Operations
# ──────────────────────────────────────────────────────────────────────

class InvariantFactorGroup:
    """Finitely generated abelian group in invariant factor form.
    
    Represents Z^r ⊕ Z/d_1 ⊕ ... ⊕ Z/d_k where d_1 | d_2 | ... | d_k.
    
    Attributes:
        free_rank: The rank r of the free part
        invariant_factors: List [d_1, ..., d_k] of invariant factors
    """
    
    def __init__(self, free_rank: int = 0, invariant_factors: List[int] = None):
        self.free_rank = free_rank
        self.invariant_factors = sorted(invariant_factors or [])
    
    def order(self) -> Optional[int]:
        """Finite order of the group, or None if infinite."""
        if self.free_rank > 0:
            return None
        if not self.invariant_factors:
            return 1
        result = 1
        for d in self.invariant_factors:
            result *= d
        return result
    
    def torsion_rank(self) -> int:
        """Number of torsion summands."""
        return len(self.invariant_factors)
    
    def has_p_torsion(self, p: int) -> bool:
        """Check if p-torsion exists: ∃ nonzero a with p·a = 0.
        
        This holds iff some invariant factor is divisible by p.
        Time complexity: O(k) where k = number of invariant factors.
        """
        return any(d % p == 0 for d in self.invariant_factors)
    
    def p_primary_subgroup(self, p: int) -> 'InvariantFactorGroup':
        """Extract the p-primary torsion subgroup A[p^∞].
        
        Algorithm: For each invariant factor d_i, extract p^{v_p(d_i)}.
        The result is ⊕ Z/p^{v_p(d_i)} for those i where v_p(d_i) > 0.
        
        Time complexity: O(k · log(d_max))
        Space complexity: O(k)
        
        >>> g = InvariantFactorGroup(1, [12, 60])
        >>> g.p_primary_subgroup(2)
        Z/4 ⊕ Z/4
        >>> g.p_primary_subgroup(3)
        Z/3 ⊕ Z/3
        """
        p_parts = []
        for d in self.invariant_factors:
            pk = p_primary_part(d, p)
            if pk > 1:
                p_parts.append(pk)
        return InvariantFactorGroup(free_rank=0, invariant_factors=p_parts)
    
    def localize_at(self, p: int) -> 'InvariantFactorGroup':
        """Compute A ⊗_Z Z_{(p)}: localization at prime p.
        
        Algorithm:
        - Free part Z^r → Z_{(p)}^r (keep free rank)
        - Z/d_i → Z/p^{v_p(d_i)} (keep only p-primary torsion)
        
        This is the key localization operation. For torsion detection,
        only the p-primary torsion survives.
        
        Time complexity: O(k · log(d_max))
        """
        return InvariantFactorGroup(
            free_rank=self.free_rank,
            invariant_factors=self.p_primary_subgroup(p).invariant_factors
        )
    
    def prime_support(self) -> Set[int]:
        """Set of primes dividing any invariant factor.
        
        Time complexity: O(k · sqrt(d_max))
        """
        primes = set()
        for d in self.invariant_factors:
            primes.update(prime_factorization(d).keys())
        return primes
    
    def __repr__(self):
        parts = []
        if self.free_rank > 0:
            parts.append(f"Z^{self.free_rank}" if self.free_rank > 1 else "Z")
        for d in self.invariant_factors:
            parts.append(f"Z/{d}")
        return " ⊕ ".join(parts) if parts else "0"


# ──────────────────────────────────────────────────────────────────────
# Algorithm 3: Persistence Module Localization
# ──────────────────────────────────────────────────────────────────────

class FinitePersistenceModule:
    """Finitely supported N-indexed persistence module.
    
    Each level is an InvariantFactorGroup. Structure maps are assumed
    injective (faithful interleaving model).
    
    Attributes:
        levels: Dict mapping index -> InvariantFactorGroup
    """
    
    def __init__(self, levels: Dict[int, InvariantFactorGroup]):
        self.levels = {i: g for i, g in levels.items() if not (g.free_rank == 0 and not g.invariant_factors)}
        self.support = sorted(self.levels.keys())
    
    def obj(self, i: int) -> InvariantFactorGroup:
        return self.levels.get(i, InvariantFactorGroup())
    
    def localize_at(self, p: int) -> 'FinitePersistenceModule':
        """Apply localization at p levelwise.
        
        Algorithm: For each level i, compute obj(i) ⊗ Z_{(p)}.
        This is the functorial localization L_p(F).
        
        Time complexity: O(n · k · log(d_max))
        where n = number of levels, k = max torsion rank, d_max = max inv factor.
        """
        return FinitePersistenceModule({
            i: g.localize_at(p) for i, g in self.levels.items()
        })
    
    def p_primary_submodule(self, p: int) -> 'FinitePersistenceModule':
        """Extract p-primary torsion submodule (= LocalizedAtPrime p F).
        
        This is the formal counterpart of the Lean definition LocalizedAtPrime.
        Each level is the p-primary torsion subgroup.
        """
        return FinitePersistenceModule({
            i: g.p_primary_subgroup(p) for i, g in self.levels.items()
        })
    
    def p_torsion_birth(self, p: int) -> Optional[int]:
        """First index where p-torsion appears.
        
        Time complexity: O(n · k)
        """
        for i in self.support:
            if self.obj(i).has_p_torsion(p):
                return i
        return None
    
    def global_torsion_birth(self) -> Optional[int]:
        """First index where any torsion appears.
        
        Time complexity: O(n)
        """
        for i in self.support:
            if self.obj(i).torsion_rank() > 0:
                return i
        return None
    
    def p_torsion_birth_set(self, p: int) -> Set[int]:
        b = self.p_torsion_birth(p)
        return {b} if b is not None else set()
    
    def torsion_birth_set(self) -> Set[int]:
        b = self.global_torsion_birth()
        return {b} if b is not None else set()
    
    def prime_support(self) -> Set[int]:
        """Union of prime supports across all levels."""
        primes = set()
        for g in self.levels.values():
            primes.update(g.prime_support())
        return primes
    
    def birth_set_distance(self, other: 'FinitePersistenceModule', p: int) -> Optional[int]:
        """Hausdorff distance between p-torsion birth sets."""
        b1 = self.p_torsion_birth(p)
        b2 = other.p_torsion_birth(p)
        if b1 is None and b2 is None:
            return 0
        if b1 is None or b2 is None:
            return None  # infinite distance
        return abs(b1 - b2)
    
    def __repr__(self):
        lines = ["PersistenceModule:"]
        for i in self.support:
            lines.append(f"  [{i}] → {self.obj(i)}")
        return "\n".join(lines)


# ──────────────────────────────────────────────────────────────────────
# Algorithm 4: Birth Set Identification Verification
# ──────────────────────────────────────────────────────────────────────

def verify_birth_set_identification(F: FinitePersistenceModule, p: int) -> bool:
    """Verify Theorem 2: PTorsionBirthSet(p, F) = TorsionBirthSet(L_p(F)).
    
    Algorithm:
    1. Compute PTorsionBirthSet(p, F): first index with p-torsion in F
    2. Compute LocalizedAtPrime(p, F): p-primary submodule of F
    3. Compute TorsionBirthSet of the localized module
    4. Check equality
    
    Time complexity: O(n · k · log(d_max))
    """
    p_birth_set = F.p_torsion_birth_set(p)
    localized = F.p_primary_submodule(p)
    localized_birth_set = localized.torsion_birth_set()
    return p_birth_set == localized_birth_set


# ──────────────────────────────────────────────────────────────────────
# Algorithm 5: Interleaving Distance Estimation
# ──────────────────────────────────────────────────────────────────────

def estimate_interleaving_distance(F: FinitePersistenceModule,
                                    G: FinitePersistenceModule) -> int:
    """Estimate the interleaving distance using torsion birth data.
    
    Lower bound: max over primes p of |birth_p(F) - birth_p(G)|.
    
    This uses the stability theorem: if d_I(F,G) = δ, then
    |birth_p(F) - birth_p(G)| ≤ δ for all p.
    
    Time complexity: O(n · k · sqrt(d_max))
    """
    primes = F.prime_support() | G.prime_support()
    if not primes:
        return 0
    
    max_dist = 0
    for p in primes:
        d = F.birth_set_distance(G, p)
        if d is not None:
            max_dist = max(max_dist, d)
    
    return max_dist


def search_improvement_candidates(F: FinitePersistenceModule,
                                   G: FinitePersistenceModule) -> Dict[int, int]:
    """Search for primes where localization improves the interleaving distance.
    
    Returns dict mapping prime -> localized distance, for primes where
    the localized distance is strictly less than the global distance.
    
    This implements the search for Conjecture (Strict Witness Improvement).
    """
    global_dist = estimate_interleaving_distance(F, G)
    improvements = {}
    
    primes = F.prime_support() | G.prime_support()
    for p in primes:
        LF = F.p_primary_submodule(p)
        LG = G.p_primary_submodule(p)
        loc_dist = estimate_interleaving_distance(LF, LG)
        if loc_dist < global_dist:
            improvements[p] = loc_dist
    
    return improvements


# ──────────────────────────────────────────────────────────────────────
# Algorithm 6: Prime Decomposition Analysis
# ──────────────────────────────────────────────────────────────────────

def prime_decomposition_analysis(F: FinitePersistenceModule) -> Dict:
    """Analyze the prime decomposition structure of a persistence module.
    
    Returns a dictionary containing:
    - prime_support: set of primes appearing in torsion
    - birth_spectrum: dict mapping prime -> birth index
    - global_birth: global torsion birth index
    - localized_modules: dict mapping prime -> localized module
    - consistency: whether global birth = min of primewise births
    
    Time complexity: O(n · k · sqrt(d_max))
    """
    primes = F.prime_support()
    birth_spectrum = {}
    localized_modules = {}
    
    for p in sorted(primes):
        birth_spectrum[p] = F.p_torsion_birth(p)
        localized_modules[p] = F.p_primary_submodule(p)
    
    global_birth = F.global_torsion_birth()
    prime_births = [b for b in birth_spectrum.values() if b is not None]
    min_prime_birth = min(prime_births) if prime_births else None
    
    return {
        'prime_support': primes,
        'birth_spectrum': birth_spectrum,
        'global_birth': global_birth,
        'localized_modules': localized_modules,
        'consistency': global_birth == min_prime_birth,
    }


# ──────────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Example: Module with mixed torsion
    F = FinitePersistenceModule({
        0: InvariantFactorGroup(free_rank=1),
        1: InvariantFactorGroup(free_rank=1, invariant_factors=[6]),
        2: InvariantFactorGroup(free_rank=1, invariant_factors=[6, 4]),
        3: InvariantFactorGroup(free_rank=2, invariant_factors=[12, 60]),
    })
    
    print("Module F:")
    print(F)
    print()
    
    # Verify birth set identification for each prime
    for p in [2, 3, 5]:
        result = verify_birth_set_identification(F, p)
        print(f"Birth set identification at p={p}: {'✓' if result else '✗'}")
    
    print()
    
    # Prime decomposition analysis
    analysis = prime_decomposition_analysis(F)
    print(f"Prime support: {analysis['prime_support']}")
    print(f"Birth spectrum: {analysis['birth_spectrum']}")
    print(f"Global birth: {analysis['global_birth']}")
    print(f"Consistent: {analysis['consistency']}")
