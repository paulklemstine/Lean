#!/usr/bin/env python3
"""
Algorithms for Holographic Gravity Codes

Type-hinted implementations of the key algorithms:
1. Holographic code construction
2. Singleton bound verification
3. Syndrome computation and weight calculation
4. Greedy entanglement wedge reconstruction
5. Page curve computation
6. Holographic entropy cone checking
"""

from dataclasses import dataclass
from typing import List, Tuple, Dict, Optional, Set, FrozenSet
import math


@dataclass(frozen=True)
class HolographicCodeParams:
    """Parameters for a holographic code [[n, k, d]]."""
    n: int  # boundary qubits
    k: int  # logical qubits
    d: int  # code distance


def verify_singleton_bound(params: HolographicCodeParams) -> bool:
    """Check if code parameters satisfy the quantum Singleton bound: k + 2d ≤ n + 2."""
    return params.k + 2 * params.d <= params.n + 2


def is_saturated(params: HolographicCodeParams) -> bool:
    """Check if the code saturates the Singleton bound (MDS-like)."""
    return params.k + 2 * params.d == params.n + 2


def code_rate(params: HolographicCodeParams) -> float:
    """Compute the code rate k/n."""
    return params.k / params.n if params.n > 0 else 0.0


def redundancy(params: HolographicCodeParams) -> int:
    """Compute the redundancy n - k."""
    return params.n - params.k


def erasure_capacity(params: HolographicCodeParams) -> int:
    """Maximum number of erasures the code can correct: d - 1."""
    return params.d - 1


def construct_ads3_code(m: int) -> HolographicCodeParams:
    """Construct AdS₃ code parameters: [[6m, 4m+2, m]]."""
    return HolographicCodeParams(n=6*m, k=4*m+2, d=m)


def construct_from_planck_params(
    area_planck: int, geodesic_planck: int
) -> Optional[HolographicCodeParams]:
    """Construct holographic code from spacetime parameters.

    Args:
        area_planck: A/ℓ_P² (must be divisible by 4)
        geodesic_planck: L/ℓ_P (must be even)

    Returns:
        HolographicCodeParams or None if constraints not met.
    """
    if area_planck % 4 != 0 or geodesic_planck % 2 != 0:
        return None
    n = area_planck
    k = area_planck // 4
    d = geodesic_planck // 2
    params = HolographicCodeParams(n=n, k=k, d=d)
    if not verify_singleton_bound(params):
        return None
    return params


# --- Syndrome Computation ---

@dataclass
class Syndrome:
    """A syndrome measurement for a holographic code."""
    bits: List[bool]

    @property
    def weight(self) -> int:
        """Number of true (non-trivial) syndrome bits."""
        return sum(self.bits)

    @property
    def is_flat(self) -> bool:
        """Whether the syndrome indicates flat spacetime (all false)."""
        return self.weight == 0


def compute_syndrome(
    error_pattern: List[int], parity_check: List[List[int]]
) -> Syndrome:
    """Compute the syndrome of an error pattern given a parity-check matrix.

    Args:
        error_pattern: Binary error vector (0s and 1s)
        parity_check: Binary parity-check matrix (list of rows)

    Returns:
        Syndrome with bits = H · e (mod 2)
    """
    bits = []
    for row in parity_check:
        dot = sum(r * e for r, e in zip(row, error_pattern)) % 2
        bits.append(bool(dot))
    return Syndrome(bits=bits)


# --- Greedy Entanglement Wedge Reconstruction ---

def greedy_wedge_assignment(
    n: int, region_sizes: List[int]
) -> Dict[int, int]:
    """Greedy entanglement wedge reconstruction algorithm.

    Assigns bulk points to boundary regions. Each region of size s
    can reconstruct min(s, n-s) bulk points.

    Args:
        n: Total boundary size
        region_sizes: Size of each boundary region (must sum to n)

    Returns:
        Dictionary mapping region index to number of assigned bulk points
    """
    assert sum(region_sizes) == n, "Region sizes must sum to n"
    assignment: Dict[int, int] = {}
    for i, s in enumerate(region_sizes):
        assignment[i] = min(s, n - s)
    return assignment


def total_reconstruction_capacity(n: int, region_sizes: List[int]) -> int:
    """Total number of reconstructable bulk points."""
    assignment = greedy_wedge_assignment(n, region_sizes)
    return sum(assignment.values())


# --- Page Curve ---

def page_curve(n: int) -> List[int]:
    """Compute the discrete Page curve for n qubits.

    Returns S(m) = min(m, n-m) for m = 0, 1, ..., n.
    """
    return [min(m, n - m) for m in range(n + 1)]


def page_time(n: int) -> int:
    """The Page time: when entropy is maximized."""
    return n // 2


# --- Holographic Entropy Cone ---

@dataclass
class ThreePartyEntropy:
    """Entropy vector for a 3-party system."""
    S_A: float
    S_B: float
    S_C: float
    S_AB: float
    S_AC: float
    S_BC: float


def check_subadditivity(E: ThreePartyEntropy) -> Tuple[bool, str]:
    """Check all subadditivity constraints."""
    checks = [
        (E.S_AB <= E.S_A + E.S_B, "S(AB) ≤ S(A) + S(B)"),
        (E.S_AC <= E.S_A + E.S_C, "S(AC) ≤ S(A) + S(C)"),
        (E.S_BC <= E.S_B + E.S_C, "S(BC) ≤ S(B) + S(C)"),
    ]
    all_pass = all(c[0] for c in checks)
    report = "\n".join(f"  {'✓' if ok else '✗'} {msg}" for ok, msg in checks)
    return all_pass, report


def check_ssa(E: ThreePartyEntropy) -> Tuple[bool, str]:
    """Check strong subadditivity constraints."""
    checks = [
        (E.S_A + E.S_BC <= E.S_AB + E.S_AC + 1e-10,
         "S(A) + S(BC) ≤ S(AB) + S(AC)"),
        (E.S_B + E.S_AC <= E.S_AB + E.S_BC + 1e-10,
         "S(B) + S(AC) ≤ S(AB) + S(BC)"),
    ]
    all_pass = all(c[0] for c in checks)
    report = "\n".join(f"  {'✓' if ok else '✗'} {msg}" for ok, msg in checks)
    return all_pass, report


def check_ssa_rigidity(E: ThreePartyEntropy) -> Tuple[bool, str]:
    """Check SSA rigidity constraints."""
    checks = [
        (E.S_A <= E.S_AB + E.S_AC - E.S_BC + 1e-10,
         "S(A) ≤ S(AB) + S(AC) - S(BC)"),
        (E.S_B <= E.S_AB + E.S_BC - E.S_AC + 1e-10,
         "S(B) ≤ S(AB) + S(BC) - S(AC)"),
        (E.S_A + E.S_B <= 2 * E.S_AB + 1e-10,
         "S(A) + S(B) ≤ 2·S(AB)"),
    ]
    all_pass = all(c[0] for c in checks)
    report = "\n".join(f"  {'✓' if ok else '✗'} {msg}" for ok, msg in checks)
    return all_pass, report


def mutual_information(E: ThreePartyEntropy, party1: str, party2: str) -> float:
    """Compute mutual information I(X:Y) = S(X) + S(Y) - S(XY)."""
    entropies = {
        'A': E.S_A, 'B': E.S_B, 'C': E.S_C,
        'AB': E.S_AB, 'AC': E.S_AC, 'BC': E.S_BC
    }
    S_X = entropies[party1]
    S_Y = entropies[party2]
    joint_key = ''.join(sorted(set(party1 + party2)))
    S_XY = entropies.get(joint_key, S_X + S_Y)  # fallback to SA if needed
    return S_X + S_Y - S_XY


# --- Rate Convergence Analysis ---

def rate_convergence_analysis(max_m: int = 100) -> List[Tuple[int, float, float]]:
    """Analyze rate convergence for AdS₃ code family.

    Returns list of (m, rate, error_bound) tuples.
    """
    results = []
    for m in range(1, max_m + 1):
        params = construct_ads3_code(m)
        rate = code_rate(params)
        error = abs(rate - 2/3)
        bound = 1 / (3 * m)
        assert error <= bound + 1e-15, f"Bound violated at m={m}"
        results.append((m, rate, bound))
    return results


if __name__ == "__main__":
    # Quick verification
    print("AdS₃ code family verification:")
    for m in [1, 5, 10, 50, 100]:
        params = construct_ads3_code(m)
        print(f"  m={m:3d}: [[{params.n}, {params.k}, {params.d}]], "
              f"rate={code_rate(params):.6f}, "
              f"saturated={is_saturated(params)}, "
              f"erasure_cap={erasure_capacity(params)}")

    print("\nPage curve (n=10):", page_curve(10))
    print(f"Page time (n=10): {page_time(10)}")

    print("\nEntropy cone check:")
    E = ThreePartyEntropy(S_A=1.0, S_B=1.0, S_C=0.5,
                          S_AB=1.5, S_AC=1.2, S_BC=1.3)
    ok, report = check_ssa_rigidity(E)
    print(report)
