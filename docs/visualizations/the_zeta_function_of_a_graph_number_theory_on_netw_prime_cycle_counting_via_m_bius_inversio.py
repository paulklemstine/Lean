"""
Algorithms for Graph Zeta Functions
====================================

Implements the core algorithms from the research paper on Ihara zeta functions.

Algorithms:
1. Ihara determinant computation via eigenvalue decomposition
2. Ramanujan graph verification
3. Prime cycle counting via Möbius inversion
4. Graph RH verification (zero location)
5. Kesten-McKay distribution comparison
"""

import numpy as np
from numpy.linalg import eigvalsh, det
from typing import List, Tuple, Optional


# ============================================================
# Algorithm 1: Ihara Determinant via Eigenvalue Decomposition
# ============================================================
# Time: O(n³) for eigenvalue computation
# Space: O(n²)

def ihara_determinant_eigenvalue(A: np.ndarray, u: float) -> float:
    """Compute det(I - uA + qu²I) using eigenvalue decomposition.

    For a (q+1)-regular graph with eigenvalues λ₁,...,λₙ:
        det((1+qu²)I - uA) = ∏ᵢ (1 + qu² - uλᵢ)

    Args:
        A: Adjacency matrix (n×n, symmetric, non-negative)
        u: Complex variable (real number)

    Returns:
        The Ihara determinant value

    Complexity: O(n³) for eigendecomposition, O(n) for product
    """
    eigenvalues = eigvalsh(A)
    q_plus_1 = A.sum(axis=1)[0]
    q = q_plus_1 - 1

    product = 1.0
    for lam in eigenvalues:
        product *= (1 + q * u**2 - u * lam)
    return product


def ihara_determinant_direct(A: np.ndarray, u: float) -> float:
    """Compute det(I - uA + qu²I) directly via matrix determinant.

    Args:
        A: Adjacency matrix (n×n)
        u: Complex variable

    Returns:
        The Ihara determinant

    Complexity: O(n³) for determinant
    """
    n = A.shape[0]
    degrees = A.sum(axis=1)
    q_plus_1 = degrees[0]
    q = q_plus_1 - 1
    I = np.eye(n)
    M = (1 + q * u**2) * I - u * A
    return det(M)


# ============================================================
# Algorithm 2: Ramanujan Graph Verification
# ============================================================
# Time: O(n³)
# Space: O(n²)

def verify_ramanujan(A: np.ndarray, tol: float = 1e-10) -> Tuple[bool, dict]:
    """Verify whether a regular graph is Ramanujan.

    A (q+1)-regular graph is Ramanujan if all non-trivial eigenvalues
    satisfy |λ| ≤ 2√q. The trivial eigenvalues are ±(q+1).

    Args:
        A: Adjacency matrix
        tol: Numerical tolerance

    Returns:
        (is_ramanujan, info_dict) where info_dict contains:
            - regularity: the degree q+1
            - eigenvalues: sorted eigenvalues
            - nontrivial: non-trivial eigenvalues
            - bound: the Ramanujan bound 2√q
            - max_nontrivial: maximum |λ| among non-trivial eigenvalues
            - margin: bound - max_nontrivial (positive if Ramanujan)

    Complexity: O(n³) for eigendecomposition
    """
    n = A.shape[0]
    degrees = A.sum(axis=1)

    # Check regularity
    q_plus_1 = degrees[0]
    if not np.allclose(degrees, q_plus_1, atol=tol):
        return False, {"error": "Graph is not regular"}

    q = q_plus_1 - 1
    bound = 2 * np.sqrt(q)

    eigenvalues = np.sort(eigvalsh(A))[::-1]
    nontrivial = [ev for ev in eigenvalues if abs(abs(ev) - q_plus_1) > tol]
    max_nt = max(abs(ev) for ev in nontrivial) if nontrivial else 0

    is_ram = max_nt <= bound + tol

    info = {
        "regularity": int(q_plus_1),
        "q": q,
        "eigenvalues": eigenvalues,
        "nontrivial": np.array(nontrivial),
        "bound": bound,
        "max_nontrivial": max_nt,
        "margin": bound - max_nt,
    }

    return is_ram, info


# ============================================================
# Algorithm 3: Prime Cycle Counting via Möbius Inversion
# ============================================================
# Time: O(L² · n³) where L is max_len
# Space: O(n²)

def moebius_function(n: int) -> int:
    """Compute the Möbius function μ(n).

    μ(n) = 1 if n is a product of an even number of distinct primes
    μ(n) = -1 if n is a product of an odd number of distinct primes
    μ(n) = 0 if n has a squared prime factor

    Complexity: O(√n) for trial division
    """
    if n == 1:
        return 1
    factors = []
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def divisors(n: int) -> List[int]:
    """Return all positive divisors of n."""
    divs = []
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)


def prime_cycle_count(A: np.ndarray, max_len: int) -> float:
    """Compute the prime cycle counting function Π_G(max_len).

    Uses Möbius inversion on closed walk counts:
        π_k = (1/k) Σ_{d|k} μ(d) · Tr(A^{k/d})

    The total count is Π_G(L) = Σ_{k=1}^{L} π_k.

    Args:
        A: Adjacency matrix
        max_len: Maximum cycle length

    Returns:
        Total number of prime cycles of length ≤ max_len

    Complexity: O(L · d(L) · n³) where d(L) is the max number of divisors
    """
    total = 0.0
    for k in range(1, max_len + 1):
        inner = 0.0
        for d in divisors(k):
            mu = moebius_function(d)
            if mu != 0:
                trace = np.trace(np.linalg.matrix_power(A, k // d))
                inner += mu * trace
        total += inner / k
    return total


def prime_cycle_spectrum(A: np.ndarray, max_len: int) -> List[float]:
    """Compute π_k for each k from 1 to max_len.

    Returns the individual prime cycle counts at each length.
    """
    spectrum = []
    for k in range(1, max_len + 1):
        inner = 0.0
        for d in divisors(k):
            mu = moebius_function(d)
            if mu != 0:
                trace = np.trace(np.linalg.matrix_power(A, k // d))
                inner += mu * trace
        spectrum.append(inner / k)
    return spectrum


# ============================================================
# Algorithm 4: Graph Riemann Hypothesis Verification
# ============================================================
# Time: O(n³)
# Space: O(n²)

def verify_graph_rh(A: np.ndarray, tol: float = 1e-10) -> Tuple[bool, dict]:
    """Verify the Riemann Hypothesis for the Ihara zeta function.

    The RH for ζ_G states: all zeros of ζ_G(u)⁻¹ that are not ±1
    satisfy |u| = q^{-1/2}.

    For a (q+1)-regular graph, this is equivalent to the Ramanujan condition:
    all non-trivial eigenvalues satisfy |λ| ≤ 2√q.

    The zeros of det((1+qu²)I - uA) are u = (λ ± √(λ²-4q))/(2q),
    and |u| = 1/√q iff |λ| ≤ 2√q.

    Args:
        A: Adjacency matrix of a regular graph
        tol: Numerical tolerance

    Returns:
        (rh_holds, info) where info contains zero locations and analysis

    Complexity: O(n³) for eigendecomposition
    """
    eigenvalues = eigvalsh(A)
    q_plus_1 = A.sum(axis=1)[0]
    q = q_plus_1 - 1

    zeros = []
    for lam in eigenvalues:
        disc = lam**2 - 4 * q
        if disc < 0:
            # Complex zeros: u = (λ ± i√(4q-λ²))/(2q)
            real_part = lam / (2 * q)
            imag_part = np.sqrt(-disc) / (2 * q)
            u_abs = np.sqrt(real_part**2 + imag_part**2)
            zeros.append({
                "eigenvalue": lam,
                "u_modulus": u_abs,
                "type": "complex",
                "on_critical_line": abs(u_abs - 1/np.sqrt(q)) < tol,
            })
        else:
            # Real zeros
            u1 = (lam + np.sqrt(disc)) / (2 * q)
            u2 = (lam - np.sqrt(disc)) / (2 * q)
            zeros.append({
                "eigenvalue": lam,
                "u_values": (u1, u2),
                "type": "real",
                "on_critical_line": False,
            })

    rh_holds = all(
        z.get("on_critical_line", True) or abs(abs(z["eigenvalue"]) - q_plus_1) < tol
        for z in zeros
    )

    return rh_holds, {
        "q": q,
        "critical_radius": 1/np.sqrt(q) if q > 0 else float('inf'),
        "zeros": zeros,
    }


# ============================================================
# Algorithm 5: Kesten-McKay Distribution
# ============================================================

def kesten_mckay_density(x: float, q: float) -> float:
    """Compute the Kesten-McKay spectral density for a (q+1)-regular graph.

    The density on [-2√q, 2√q] is:
        ρ(x) = (q+1)√(4q - x²) / (2π(q+1)² - x²))

    This is the limiting spectral distribution for random regular graphs
    (analogous to the semicircle law for random matrices).

    Args:
        x: Point at which to evaluate
        q: Regularity parameter (degree = q+1)

    Returns:
        The density value (0 outside the support)
    """
    if abs(x) >= 2 * np.sqrt(q):
        return 0.0
    numerator = (q + 1) * np.sqrt(4 * q - x**2)
    denominator = 2 * np.pi * ((q + 1)**2 - x**2)
    return numerator / denominator


def spectral_histogram_comparison(A: np.ndarray, bins: int = 50) -> dict:
    """Compare the empirical spectral distribution with Kesten-McKay.

    Args:
        A: Adjacency matrix
        bins: Number of histogram bins

    Returns:
        Dictionary with empirical and theoretical distributions
    """
    eigenvalues = eigvalsh(A)
    q_plus_1 = A.sum(axis=1)[0]
    q = q_plus_1 - 1

    nontrivial = [ev for ev in eigenvalues if abs(abs(ev) - q_plus_1) > 1e-10]

    x_range = np.linspace(-2*np.sqrt(q) - 0.5, 2*np.sqrt(q) + 0.5, 200)
    km_density = [kesten_mckay_density(x, q) for x in x_range]

    return {
        "eigenvalues": eigenvalues,
        "nontrivial": np.array(nontrivial),
        "x_range": x_range,
        "km_density": np.array(km_density),
        "q": q,
        "bound": 2 * np.sqrt(q),
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    from demo import adjacency_matrix_petersen, paley_graph

    print("=== Ramanujan Verification ===")
    A = adjacency_matrix_petersen()
    is_ram, info = verify_ramanujan(A)
    print(f"Petersen graph: Ramanujan = {is_ram}")
    print(f"  q = {info['q']}, bound = {info['bound']:.4f}, "
          f"max |λ_nt| = {info['max_nontrivial']:.4f}")

    print("\n=== Graph RH Verification ===")
    rh, rh_info = verify_graph_rh(A)
    print(f"RH holds: {rh}")
    print(f"Critical radius: {rh_info['critical_radius']:.6f}")

    print("\n=== Prime Cycle Spectrum ===")
    spectrum = prime_cycle_spectrum(A, 10)
    for k, val in enumerate(spectrum, 1):
        print(f"  π_{k} = {val:.2f}")

    print("\n=== Paley Graph Verification ===")
    for q_val in [5, 13, 17, 29]:
        A_p = paley_graph(q_val)
        is_ram, info = verify_ramanujan(A_p)
        rh, _ = verify_graph_rh(A_p)
        print(f"  Paley({q_val}): Ramanujan={is_ram}, RH={rh}, margin={info['margin']:.4f}")
