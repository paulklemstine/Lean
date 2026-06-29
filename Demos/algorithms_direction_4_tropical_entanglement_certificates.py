#!/usr/bin/env python3
"""
Tropical Entanglement Certificates — Algorithms

Implements the core algorithms from the research paper:
1. Tropical partition witness computation
2. Cross-support count computation  
3. Genuine tropical entanglement certification
4. State classification algorithm

All algorithms work with finite-dimensional quantum states represented
as amplitude tables (dictionaries or callables).

Complexity Analysis:
- tropical_partition_witness: O(d^{2n}) time, O(d^n) space
- cross_support_count: O(d^{2n}) time, O(d^n) space
- certify_genuine_entanglement: O(2^n * d^{2n}) time
"""

import numpy as np
from itertools import product as iterproduct
from typing import Callable, Dict, List, Tuple, Optional, Set
from dataclasses import dataclass


@dataclass
class WitnessResult:
    """Result of a tropical partition witness computation."""
    partition: frozenset
    witness_value: float
    cross_support: int
    is_positive: bool


@dataclass 
class EntanglementCertificate:
    """Full entanglement certification result."""
    n_parties: int
    state_name: str
    is_genuinely_entangled: bool
    partition_witnesses: List[WitnessResult]
    zero_cuts: List[frozenset]
    min_witness: float
    max_witness: float


def all_configs(n: int, d: int = 2) -> List[Tuple[int, ...]]:
    """
    Generate all configurations of n parties with local dimension d.
    
    Returns: List of d^n tuples, each of length n.
    Time: O(d^n), Space: O(d^n)
    """
    return list(iterproduct(range(d), repeat=n))


def mix_config(A: frozenset, s: tuple, t: tuple) -> tuple:
    """
    Mix two configurations along partition A.
    Takes A-components from s, complement from t.
    
    Time: O(n)
    """
    return tuple(s[i] if i in A else t[i] for i in range(len(s)))


def compute_tropical_partition_witness(
    n: int, A: frozenset, psi: Callable, d: int = 2
) -> float:
    """
    Compute the tropical partition witness W_trop(ψ, A).
    
    Algorithm:
        W = Σ_{s,t} max(|ψ(s)|·|ψ(t)| - |ψ(mix_A(s,t))|·|ψ(mix_A(t,s))|, 0)
    
    Args:
        n: Number of parties
        A: Subset of parties (frozenset of ints in {0,...,n-1})
        psi: Amplitude function s -> C
        d: Local dimension (default 2 for qubits)
    
    Returns:
        The tropical partition witness value (nonneg real)
    
    Time Complexity: O(d^{2n})
    Space Complexity: O(d^n) for storing configurations
    
    Properties (proved in Lean):
        - Always nonneg
        - Zero for product states across A
        - Positive for GHZ/W on nontrivial cuts
    """
    configs = all_configs(n, d)
    # Pre-compute magnitudes for efficiency
    mags = {s: abs(psi(s)) for s in configs}
    
    witness = 0.0
    for s in configs:
        ms = mags[s]
        if ms < 1e-15:  # Skip zero-amplitude configs in outer loop
            continue
        for t in configs:
            mt = mags[t]
            if mt < 1e-15:
                continue
            mix_st = mix_config(A, s, t)
            mix_ts = mix_config(A, t, s)
            val = ms * mt - mags.get(mix_st, abs(psi(mix_st))) * mags.get(mix_ts, abs(psi(mix_ts)))
            if val > 0:
                witness += val
    return witness


def compute_cross_support_count(
    n: int, A: frozenset, psi: Callable, d: int = 2
) -> int:
    """
    Count pairs in support where mixing produces out-of-support elements.
    
    Algorithm:
        Count |(s,t) : ψ(s)≠0, ψ(t)≠0, ψ(mix_A(s,t))=0 or ψ(mix_A(t,s))=0|
    
    Time Complexity: O(d^{2n})
    """
    configs = all_configs(n, d)
    support = [s for s in configs if abs(psi(s)) > 1e-12]
    
    count = 0
    for s in support:
        for t in support:
            m1 = abs(psi(mix_config(A, s, t)))
            m2 = abs(psi(mix_config(A, t, s)))
            if m1 < 1e-12 or m2 < 1e-12:
                count += 1
    return count


def nontrivial_partitions(n: int) -> List[frozenset]:
    """
    Generate all nonempty proper subsets of {0, ..., n-1}.
    These are the nontrivial bipartitions for entanglement analysis.
    
    Returns: List of 2^n - 2 frozensets
    """
    from itertools import combinations
    result = []
    for k in range(1, n):
        for combo in combinations(range(n), k):
            result.append(frozenset(combo))
    return result


def certify_genuine_entanglement(
    n: int, psi: Callable, state_name: str = "unknown", d: int = 2
) -> EntanglementCertificate:
    """
    Full genuine tropical entanglement certification.
    
    Algorithm:
        1. Enumerate all 2^n - 2 nontrivial bipartitions
        2. Compute tropical partition witness for each
        3. Classify: genuinely entangled iff ALL witnesses > 0
    
    Args:
        n: Number of parties
        psi: Amplitude function
        state_name: Label for the state
        d: Local dimension
    
    Returns:
        EntanglementCertificate with full analysis
    
    Time Complexity: O(2^n · d^{2n})
    """
    partitions = nontrivial_partitions(n)
    results = []
    zero_cuts = []
    
    for A in partitions:
        w = compute_tropical_partition_witness(n, A, psi, d)
        cs = compute_cross_support_count(n, A, psi, d)
        is_pos = w > 1e-12
        results.append(WitnessResult(
            partition=A,
            witness_value=w,
            cross_support=cs,
            is_positive=is_pos
        ))
        if not is_pos:
            zero_cuts.append(A)
    
    witness_values = [r.witness_value for r in results]
    
    return EntanglementCertificate(
        n_parties=n,
        state_name=state_name,
        is_genuinely_entangled=len(zero_cuts) == 0,
        partition_witnesses=results,
        zero_cuts=zero_cuts,
        min_witness=min(witness_values) if witness_values else 0,
        max_witness=max(witness_values) if witness_values else 0
    )


def classify_state(cert: EntanglementCertificate) -> str:
    """
    Classify a state based on its entanglement certificate.
    
    Returns one of:
        - "genuinely entangled": positive witness on all cuts
        - "biseparable": zero on some cuts, positive on others
        - "fully separable": zero on all cuts
    """
    n_positive = sum(1 for r in cert.partition_witnesses if r.is_positive)
    n_total = len(cert.partition_witnesses)
    
    if n_positive == n_total:
        return "genuinely entangled"
    elif n_positive == 0:
        return "fully separable"
    else:
        return "biseparable"


# ─── Standard State Constructors ─────────────────────────────────────

def ghz_state(n: int) -> Callable:
    """GHZ state: |00...0⟩ + |11...1⟩ (unnormalized)."""
    def psi(s: tuple) -> complex:
        return 1.0 if (all(x == 0 for x in s) or all(x == 1 for x in s)) else 0.0
    return psi


def w_state(n: int) -> Callable:
    """W state: sum of single-excitation states (unnormalized)."""
    def psi(s: tuple) -> complex:
        return 1.0 if sum(s) == 1 else 0.0
    return psi


def product_state(n: int, amplitudes: Optional[List[List[complex]]] = None) -> Callable:
    """Product state: ψ(s) = ∏ᵢ φᵢ(sᵢ)."""
    if amplitudes is None:
        amplitudes = [[1/np.sqrt(2), 1/np.sqrt(2)]] * n
    def psi(s: tuple) -> complex:
        r = 1.0
        for i, si in enumerate(s):
            r *= amplitudes[i][si]
        return r
    return psi


def dicke_state(n: int, k: int) -> Callable:
    """Dicke state D(n,k): uniform superposition of weight-k configurations."""
    def psi(s: tuple) -> complex:
        return 1.0 if sum(s) == k else 0.0
    return psi


def random_state(n: int, d: int = 2, seed: int = 42) -> Callable:
    """Random pure state with complex Gaussian amplitudes."""
    rng = np.random.RandomState(seed)
    configs = list(iterproduct(range(d), repeat=n))
    amps = {}
    for s in configs:
        amps[s] = complex(rng.randn(), rng.randn())
    norm = np.sqrt(sum(abs(a)**2 for a in amps.values()))
    for s in amps:
        amps[s] /= norm
    def psi(s: tuple) -> complex:
        return amps.get(s, 0.0)
    return psi


# ─── Example Usage ───────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Entanglement Certificates — Algorithm Demonstrations\n")
    
    # Example 1: Certify GHZ-3
    cert = certify_genuine_entanglement(3, ghz_state(3), "GHZ-3")
    print(f"State: {cert.state_name}")
    print(f"Classification: {classify_state(cert)}")
    print(f"Min witness: {cert.min_witness:.4f}")
    print(f"Max witness: {cert.max_witness:.4f}")
    print()
    
    # Example 2: Certify product state
    cert = certify_genuine_entanglement(3, product_state(3), "Product-3")
    print(f"State: {cert.state_name}")
    print(f"Classification: {classify_state(cert)}")
    print(f"Min witness: {cert.min_witness:.6f}")
    print()
    
    # Example 3: Dicke states
    for k in range(4):
        cert = certify_genuine_entanglement(3, dicke_state(3, k), f"Dicke(3,{k})")
        print(f"State: {cert.state_name:>12}  Class: {classify_state(cert):>20}  "
              f"Min W: {cert.min_witness:.4f}  Max W: {cert.max_witness:.4f}")
    print()
    
    # Example 4: Random states
    for seed in range(5):
        cert = certify_genuine_entanglement(3, random_state(3, seed=seed), f"Random-{seed}")
        print(f"State: {cert.state_name:>12}  Class: {classify_state(cert):>20}  "
              f"Min W: {cert.min_witness:.6f}")
