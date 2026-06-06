#!/usr/bin/env python3
"""
Thermodynamic Proof Complexity — Core Algorithms

Type-hinted implementations of the key algorithms from the ProofEnergetics framework.
"""

import math
from dataclasses import dataclass
from typing import List, Optional, Callable


@dataclass
class ProofEnergetics:
    """The ProofEnergetics structure: thermodynamic cost landscape of a proof system.
    
    Attributes:
        b: Alphabet size (≥ 2)
        T: Temperature (> 0, in k_B = 1 units for theory; physical units for applications)
        cum_count: Cumulative theorem count function C(n)
    """
    b: int
    T: float
    cum_count: Callable[[int], int]
    
    def __post_init__(self) -> None:
        assert self.b >= 2, f"Alphabet size must be ≥ 2, got {self.b}"
        assert self.T > 0, f"Temperature must be > 0, got {self.T}"
    
    def spectrum(self, n: int) -> int:
        """Proof spectrum S(n): theorems whose shortest proof has length exactly n."""
        if n == 0:
            return self.cum_count(0)
        return self.cum_count(n) - self.cum_count(n - 1)
    
    def landauer_cost(self, n: int) -> float:
        """Landauer cost of a proof of length n bits."""
        return n * self.T * math.log(2)
    
    def partition_fn(self, beta: float, N: int) -> float:
        """Proof partition function Z(β, N) = Σ S(k)·exp(-β·k)."""
        return sum(
            self.spectrum(k) * math.exp(-beta * k)
            for k in range(N + 1)
        )
    
    def free_energy(self, beta: float, N: int) -> float:
        """Proof free energy F(β, N) = -ln(Z)/β."""
        if beta == 0:
            return 0.0
        Z = self.partition_fn(beta, N)
        if Z <= 0:
            return float('inf')
        return -math.log(Z) / beta
    
    def proof_entropy(self, n: int) -> float:
        """Proof-theoretic entropy H(n) = log(S(n)) / log(b^n)."""
        s = self.spectrum(n)
        if s <= 0 or n <= 0:
            return 0.0
        return math.log(s) / (n * math.log(self.b))
    
    def total_spectrum_cost(self, N: int) -> float:
        """Total weighted cost Σ S(k)·cost(k)."""
        return sum(
            self.spectrum(k) * self.landauer_cost(k)
            for k in range(N + 1)
        )
    
    def chaitin_bound(self, n: int) -> int:
        """Maximum theorems provable with cost ≤ landauer_cost(n): b^(n+1)."""
        return self.b ** (n + 1)
    
    def has_hard_theorems(self, n: int, total: Optional[int] = None) -> bool:
        """Check if there exist theorems requiring proof length > n.
        
        Returns True if total theorems > b^(n+1), by Chaitin Cost Theorem.
        """
        if total is None:
            # Try to estimate total from a large N
            total = self.cum_count(10 * n)
        return total > self.chaitin_bound(n)


def compute_spectrum(cum_count: List[int]) -> List[int]:
    """Compute proof spectrum from cumulative counts.
    
    Algorithm: S(0) = C(0), S(n) = C(n) - C(n-1)
    Time complexity: O(N)
    Space complexity: O(N)
    """
    if not cum_count:
        return []
    spectrum = [cum_count[0]]
    for i in range(1, len(cum_count)):
        spectrum.append(cum_count[i] - cum_count[i - 1])
    return spectrum


def compute_partition_function(
    spectrum: List[int], 
    beta: float
) -> float:
    """Compute proof partition function Z(β, N).
    
    Algorithm: Direct summation Z = Σ S(k)·exp(-β·k)
    Time complexity: O(N)
    Numerically stable for all β ≥ 0.
    """
    return sum(s * math.exp(-beta * k) for k, s in enumerate(spectrum))


def find_chaitin_threshold(
    b: int, 
    total_theorems: int
) -> int:
    """Find the Chaitin threshold: smallest n where b^(n+1) ≥ total_theorems.
    
    Below this threshold, there provably exist theorems requiring 
    proof length > n, by the Chaitin Cost Theorem.
    
    Algorithm: Binary search on n
    Time complexity: O(log(log(total_theorems)))
    """
    if total_theorems <= 0:
        return 0
    # n such that b^(n+1) >= total_theorems
    # n+1 >= log_b(total_theorems)
    # n >= log_b(total_theorems) - 1
    n = max(0, math.ceil(math.log(total_theorems) / math.log(b)) - 1)
    while b ** (n + 1) < total_theorems:
        n += 1
    return n


def compute_entropy_profile(
    pe: ProofEnergetics, 
    N: int
) -> List[float]:
    """Compute the proof-theoretic entropy profile H(0), H(1), ..., H(N).
    
    Algorithm: Direct computation from spectrum
    Time complexity: O(N)
    """
    return [pe.proof_entropy(n) for n in range(N + 1)]


def detect_phase_transition(
    entropy_profile: List[float], 
    threshold: float = 0.5
) -> Optional[int]:
    """Detect phase transition in entropy profile.
    
    Returns the first index where entropy drops below threshold,
    or None if no transition is detected.
    
    Algorithm: Linear scan
    Time complexity: O(N)
    """
    for i, h in enumerate(entropy_profile):
        if i > 0 and h < threshold:
            return i
    return None


def sorting_proof_energetics(n: int, T: float = 1.0) -> ProofEnergetics:
    """Create ProofEnergetics for sorting n elements.
    
    Models sorting as a proof system where:
    - Theorems = permutations (n! total)
    - Proofs = comparison sequences (binary strings)
    - C(k) = min(n!, 2^(k+1))
    """
    n_fact = math.factorial(n)
    return ProofEnergetics(
        b=2,
        T=T,
        cum_count=lambda k, nf=n_fact: min(nf, 2 ** (k + 1))
    )


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    # Create a binary proof system with 10000 theorems
    pe = ProofEnergetics(
        b=2,
        T=300,  # room temperature
        cum_count=lambda n: min(10000, 2 ** (n + 1))
    )
    
    print("ProofEnergetics Example")
    print(f"  Alphabet: {pe.b}")
    print(f"  Temperature: {pe.T}K")
    print()
    
    # Spectrum analysis
    for n in range(15):
        s = pe.spectrum(n)
        h = pe.proof_entropy(n)
        cost = pe.landauer_cost(n)
        print(f"  Level {n:>2d}: spectrum={s:>6d}, entropy={h:.3f}, cost={cost:.2e}")
    
    print()
    
    # Chaitin threshold
    threshold = find_chaitin_threshold(2, 10000)
    print(f"  Chaitin threshold: n={threshold}")
    print(f"  Meaning: theorems exist requiring > {threshold} bits")
    print(f"  Minimum cost of hard theorems: {pe.landauer_cost(threshold + 1):.4e}")
    
    print()
    
    # Partition function
    for beta in [0, 0.5, 1.0, 5.0]:
        Z = pe.partition_fn(beta, 14)
        F = pe.free_energy(beta, 14)
        print(f"  Z(β={beta:.1f}) = {Z:.2f}, F = {F:.4f}")
