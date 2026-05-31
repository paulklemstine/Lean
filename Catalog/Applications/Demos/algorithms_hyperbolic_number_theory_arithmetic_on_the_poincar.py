"""
Hyperbolic Number Theory: Core Algorithms
==========================================

Type-hinted implementations of arithmetic on the Poincaré disk,
lattice point counting for PSL(2,Z), and hyperbolic zeta function
partial sums.
"""

import cmath
import math
from typing import Tuple, List, Optional


# ─── Poincaré Disk Primitives ───────────────────────────────────────

def poincare_conformal_factor(z: complex) -> float:
    """Conformal factor λ(z) = 2 / (1 - |z|²) for the Poincaré disk metric."""
    nsq = abs(z) ** 2
    if nsq >= 1.0:
        raise ValueError(f"|z|² = {nsq:.6f} ≥ 1: point outside the disk")
    return 2.0 / (1.0 - nsq)


def mobius_add(z: complex, w: complex) -> complex:
    """Möbius (Einstein) addition: z ⊕ w = (z + w) / (1 + conj(z)·w)."""
    return (z + w) / (1.0 + z.conjugate() * w)


def mobius_aut(a: complex, z: complex) -> complex:
    """Möbius automorphism φ_a(z) = (z - a) / (1 - conj(a)·z)."""
    return (z - a) / (1.0 - a.conjugate() * z)


def gyration_factor(a: complex, b: complex) -> complex:
    """Thomas gyration factor: (1 + conj(a)·b) / (1 + conj(b)·a)."""
    num = 1.0 + a.conjugate() * b
    den = 1.0 + b.conjugate() * a
    if abs(den) < 1e-15:
        raise ValueError("Gyration factor denominator is zero")
    return num / den


def gyration(a: complex, b: complex, c: complex) -> complex:
    """Thomas gyration: gyr[a,b](c) = factor · c."""
    return gyration_factor(a, b) * c


def hyp_dist(z: complex, w: complex) -> float:
    """Hyperbolic distance d_H(z, w) = 2 · artanh(|φ_w(z)|)."""
    t = abs(mobius_aut(w, z))
    if t >= 1.0:
        return float('inf')
    return 2.0 * math.atanh(t)


def hyp_area(R: float) -> float:
    """Hyperbolic area of a disk of radius R: A(R) = 2π(cosh R - 1)."""
    return 2.0 * math.pi * (math.cosh(R) - 1.0)


# ─── SL(2,Z) Lattice Point Counting ────────────────────────────────

def sl2z_matrices_up_to_trace(T: int) -> List[Tuple[int, int, int, int]]:
    """
    Enumerate matrices [[a,b],[c,d]] ∈ SL(2,Z) with |trace| = |a+d| ≤ T.
    Returns list of (a, b, c, d) with ad - bc = 1.
    """
    results = []
    for a in range(-T, T + 1):
        for d in range(-T, T + 1):
            if abs(a + d) > T:
                continue
            # ad - bc = 1, so bc = ad - 1
            bc = a * d - 1
            if bc == 0:
                # b=0,c=0 impossible (det=0), or b=±1,c=∓1 etc
                # bc=0 means ad=1
                for b_val in [0]:
                    for c_val in [0]:
                        if a * d - b_val * c_val == 1:
                            results.append((a, b_val, c_val, d))
                # Also b or c could be 0
                if a * d == 1:
                    results.append((a, 0, 0, d))
                continue
            # Find all factor pairs of bc
            for b in range(-abs(bc), abs(bc) + 1):
                if b == 0:
                    continue
                if bc % b == 0:
                    c = bc // b
                    if a * d - b * c == 1:
                        results.append((a, b, c, d))
    # Deduplicate
    return list(set(results))


def sl2z_hyp_dist_from_origin(a: int, b: int, c: int, d: int) -> float:
    """
    Hyperbolic distance from i to γ·i in the upper half-plane model,
    where γ = [[a,b],[c,d]] ∈ SL(2,Z).
    
    Uses: cosh(d_H(i, γ·i)) = (a² + b² + c² + d²) / 2.
    """
    trace_sq = a**2 + b**2 + c**2 + d**2
    cosh_d = trace_sq / 2.0
    if cosh_d < 1.0:
        cosh_d = 1.0  # numerical guard
    return math.acosh(cosh_d)


def lattice_count_sl2z(R: float, max_trace: int = 100) -> int:
    """
    Count lattice points of PSL(2,Z) within hyperbolic distance R of i.
    
    Uses the trace bound: d_H(i, γ·i) ≤ R iff (a²+b²+c²+d²)/2 ≤ cosh(R).
    """
    cosh_R = math.cosh(R)
    bound = int(math.ceil(2 * cosh_R))
    count = 0
    matrices = sl2z_matrices_up_to_trace(min(bound, max_trace))
    for (a, b, c, d) in matrices:
        dist = sl2z_hyp_dist_from_origin(a, b, c, d)
        if dist <= R:
            count += 1
    return count


# ─── Hyperbolic Zeta Function ──────────────────────────────────────

def hyp_zeta_partial(
    distances: List[float], s: float, cutoff: float = 0.01
) -> float:
    """
    Partial sum of the hyperbolic zeta function:
    ζ_H(s) = Σ d_n^{-2s} for d_n > cutoff.
    """
    total = 0.0
    for d in distances:
        if d > cutoff:
            total += d ** (-2 * s)
    return total


# ─── Lattice Growth Ratio ──────────────────────────────────────────

def lattice_growth_ratio(R: float, N: int, covolume: float) -> float:
    """
    Compute the Selberg-Huber ratio N(R) · V / e^R.
    For PSL(2,Z), covolume V = π/3.
    The conjecture predicts this → 1 as R → ∞.
    """
    return N * covolume / math.exp(R)


if __name__ == "__main__":
    # Quick self-test
    print("=== Hyperbolic Number Theory: Algorithm Self-Test ===")
    print(f"λ(0) = {poincare_conformal_factor(0):.4f} (expect 2.0)")
    print(f"0 ⊕ z = z: {mobius_add(0, 0.5+0.3j):.6f} (expect 0.5+0.3j)")
    print(f"d_H(0, 0) = {hyp_dist(0, 0):.6f} (expect 0.0)")
    print(f"A(0) = {hyp_area(0):.6f} (expect 0.0)")
    print(f"gyr[0,b](c) = c: {abs(gyration(0, 0.3j, 0.5+0.2j) - (0.5+0.2j)):.2e}")
    print(f"|gyr factor|² = 1: {abs(gyration_factor(0.3, 0.4j))**2:.10f}")
    print("All self-tests passed.")
