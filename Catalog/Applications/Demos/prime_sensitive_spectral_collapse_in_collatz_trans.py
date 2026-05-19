#!/usr/bin/env python3
"""
applications.py — Real-World Applications of the Spectral Collapse Framework

Demonstrates how the transfer operator / spectral gap methodology extends beyond
the Collatz conjecture to other domains:

1. Integer rewriting system termination detection
2. Pseudorandom number generator quality analysis
3. Cryptographic hash mixing verification
4. Network protocol convergence analysis
"""

import numpy as np
from typing import List, Dict, Tuple, Callable
from algorithms import AcceleratedCollatzMap, SpectralGapVerifier, OccupationMeasure


# ============================================================
# Application 1: General Integer Map Termination
# ============================================================

class IntegerMapAnalyzer:
    """
    Analyze termination properties of general integer maps using
    the spectral framework.

    Given a map f: ℤ → ℤ with a target fixed point, construct
    transition matrices on congruence classes and check spectral gaps.

    This generalizes the Collatz analysis to arbitrary ax+b maps:
        n ↦ (a·n + b) / p^{ν_p(a·n + b)}

    Example:
        >>> analyzer = IntegerMapAnalyzer()
        >>> # 5x+1 map (Collatz variant)
        >>> result = analyzer.analyze_axb(a=5, b=1, p=2, q=7)
        >>> print(f"Spectral gap: {result}")
    """

    def axb_map(self, n: int, a: int, b: int, p: int) -> int:
        """Compute (a*n + b) / p^{ν_p(a*n + b)}."""
        if n <= 0:
            return 1
        val = a * n + b
        if val <= 0:
            return 1
        while val % p == 0:
            val //= p
        return val

    def build_axb_matrix(self, a: int, b: int, p: int,
                         q: int, N: int = 5000) -> np.ndarray:
        """Build transition matrix for the ax+b map on odd residues mod q."""
        residues = [r for r in range(1, q) if r % p != 0]
        if not residues:
            residues = list(range(1, q))
        n_res = len(residues)
        idx = {r: i for i, r in enumerate(residues)}

        A = np.zeros((n_res, n_res), dtype=complex)
        col_totals = np.zeros(n_res)

        for m in range(1, N + 1):
            r_m = m % q
            if r_m not in idx:
                continue
            j = idx[r_m]

            t_m = self.axb_map(m, a, b, p)
            r_t = t_m % q
            if r_t not in idx:
                continue
            i = idx[r_t]

            A[i, j] += 1
            col_totals[j] += 1

        for j in range(n_res):
            if col_totals[j] > 0:
                A[:, j] /= col_totals[j]

        return A, residues

    def analyze_axb(self, a: int, b: int, p: int, q: int,
                    N: int = 5000) -> Dict[str, float]:
        """Full spectral analysis of an ax+b map."""
        A, residues = self.build_axb_matrix(a, b, p, q, N)
        eigenvalues = np.linalg.eigvals(A)
        rho = max(abs(eigenvalues)) if len(eigenvalues) > 0 else 0

        # Separate trivial and nontrivial eigenvalues
        sorted_eigs = sorted(abs(eigenvalues), reverse=True)

        return {
            'spectral_radius': rho,
            'second_eigenvalue': sorted_eigs[1] if len(sorted_eigs) > 1 else 0,
            'gap': 1.0 - (sorted_eigs[1] if len(sorted_eigs) > 1 else 0),
            'matrix_size': len(residues),
            'top_eigenvalues': sorted_eigs[:5]
        }


def demo_integer_maps():
    """Demonstrate spectral analysis on various integer maps."""
    print("=" * 60)
    print("APPLICATION 1: Integer Map Termination Analysis")
    print("=" * 60)
    print()

    analyzer = IntegerMapAnalyzer()

    maps = [
        (3, 1, 2, "3x+1 (Collatz)"),
        (5, 1, 2, "5x+1"),
        (3, 1, 3, "3x+1 mod 3"),
        (7, 1, 2, "7x+1"),
        (3, 5, 2, "3x+5"),
    ]

    for a, b, p, name in maps:
        print(f"  Map: n ↦ ({a}n+{b})/p^ν_p, p={p}")
        results = {}
        for q in [3, 5, 7, 11]:
            try:
                result = analyzer.analyze_axb(a, b, p, q, N=3000)
                results[q] = result
            except Exception:
                results[q] = None

        print(f"  {name}:")
        for q, r in results.items():
            if r:
                print(f"    q={q:>2}: ρ = {r['spectral_radius']:.4f}, "
                      f"gap = {r['gap']:.4f}, "
                      f"λ₂ = {r['second_eigenvalue']:.4f}")
        print()


# ============================================================
# Application 2: PRNG Quality via Spectral Gap
# ============================================================

class PRNGSpectralAnalyzer:
    """
    Analyze pseudorandom number generator quality using spectral gaps.

    A good PRNG should have rapid mixing on all congruence classes,
    which corresponds to large spectral gaps in the transition matrix.
    Poor mixing = small spectral gap = detectable patterns.

    Example:
        >>> analyzer = PRNGSpectralAnalyzer()
        >>> gap = analyzer.analyze_lcg(a=1103515245, c=12345, m=2**16, q=7)
        >>> print(f"Mixing quality: {gap:.4f}")
    """

    def analyze_lcg(self, a: int, c: int, m: int,
                    q: int, N: int = 5000) -> Dict[str, float]:
        """
        Analyze a Linear Congruential Generator x_{n+1} = (a·x_n + c) mod m.
        Check spectral gap of the induced dynamics on residues mod q.
        """
        residues = list(range(q))
        n_res = len(residues)
        A = np.zeros((n_res, n_res), dtype=complex)
        col_totals = np.zeros(n_res)

        for x in range(min(N, m)):
            r_x = x % q
            next_x = (a * x + c) % m
            r_next = next_x % q

            A[r_next, r_x] += 1
            col_totals[r_x] += 1

        for j in range(n_res):
            if col_totals[j] > 0:
                A[:, j] /= col_totals[j]

        eigenvalues = np.linalg.eigvals(A)
        sorted_abs = sorted(abs(eigenvalues), reverse=True)

        return {
            'spectral_radius': sorted_abs[0],
            'second_eigenvalue': sorted_abs[1] if len(sorted_abs) > 1 else 0,
            'spectral_gap': 1.0 - sorted_abs[1] if len(sorted_abs) > 1 else 1.0,
            'mixing_time_est': int(1.0 / max(1.0 - sorted_abs[1], 0.001)) if len(sorted_abs) > 1 else 1
        }


def demo_prng_quality():
    """Demonstrate PRNG quality analysis via spectral gaps."""
    print("=" * 60)
    print("APPLICATION 2: PRNG Quality via Spectral Gaps")
    print("=" * 60)
    print()

    analyzer = PRNGSpectralAnalyzer()

    generators = [
        (1103515245, 12345, 2**16, "glibc (truncated)"),
        (6364136223846793005, 1442695040888963407, 2**16, "Knuth LCG (truncated)"),
        (65539, 0, 2**16, "RANDU (notoriously bad)"),
        (1664525, 1013904223, 2**16, "Numerical Recipes"),
    ]

    for a, c, m, name in generators:
        print(f"  {name}: x → ({a}x + {c}) mod {m}")
        for q in [3, 5, 7]:
            result = analyzer.analyze_lcg(a, c, m, q, N=min(m, 10000))
            quality = "Excellent" if result['spectral_gap'] > 0.5 else \
                      "Good" if result['spectral_gap'] > 0.1 else \
                      "Poor" if result['spectral_gap'] > 0.01 else "Very Poor"
            print(f"    mod {q}: gap = {result['spectral_gap']:.4f} ({quality}), "
                  f"mixing time ≈ {result['mixing_time_est']}")
        print()


# ============================================================
# Application 3: Collatz Orbit Statistics
# ============================================================

def demo_orbit_statistics():
    """Demonstrate orbit statistical analysis."""
    print("=" * 60)
    print("APPLICATION 3: Collatz Orbit Statistics & Equidistribution")
    print("=" * 60)
    print()

    T = AcceleratedCollatzMap()
    occ = OccupationMeasure()

    # Analyze orbit statistics for various starting points
    starts = [27, 31, 127, 511, 1023, 4095, 8191]

    print("  Orbit lengths and valuation statistics:")
    print(f"  {'n':>6} | {'Length':>6} | {'Mean ν₂':>8} | {'Max val':>10}")
    print("  " + "-" * 40)

    for n in starts:
        orbit = T.orbit(n)
        length = len(orbit) - 1

        # Valuation statistics
        valuations = [T.nu2(3 * m + 1) for m in orbit[:-1] if m > 0]
        mean_v = np.mean(valuations) if valuations else 0
        max_val = max(orbit)

        print(f"  {n:>6} | {length:>6} | {mean_v:>8.3f} | {max_val:>10}")

    print()

    # Equidistribution check
    print("  Equidistribution of orbits over residue classes:")
    for q in [3, 5, 7]:
        print(f"  mod {q}:")
        for n in [27, 127, 1023]:
            mu = occ.compute(n, q, K=100000)
            uniform = 1.0 / q
            max_dev = max(abs(mu[r] - uniform) for r in range(q))
            chi_sq = sum((mu[r] - uniform)**2 / uniform for r in range(q)) * q
            print(f"    n={n:>5}: max deviation = {max_dev:.4f}, "
                  f"χ² = {chi_sq:.4f}")
    print()


# ============================================================
# Application 4: Convergence Rate Estimation
# ============================================================

def demo_convergence_rates():
    """Demonstrate how spectral gaps predict convergence rates."""
    print("=" * 60)
    print("APPLICATION 4: Spectral Gap → Convergence Rate Prediction")
    print("=" * 60)
    print()

    verifier = SpectralGapVerifier()

    print("  Spectral gap scan over moduli and weight parameters:")
    print(f"  {'q':>4} | {'s':>5} | {'ρ_max':>8} | {'gap':>8} | {'Convergence rate':>16}")
    print("  " + "-" * 55)

    for q in [3, 5, 7, 11, 13]:
        for s in [0.3, 0.5, 0.8]:
            result = verifier.verify(q, s=s, N=3000)
            if result.has_gap:
                rate = -np.log(result.max_nontrivial_radius) if result.max_nontrivial_radius > 0 else float('inf')
                print(f"  {q:>4} | {s:>5.1f} | {result.max_nontrivial_radius:>8.4f} | "
                      f"{result.gap_size:>8.4f} | {rate:>16.4f}")

    print()
    print("  Larger gap → faster convergence → stronger mixing")
    print("  Rate = -log(ρ_max) measures exponential convergence speed")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  APPLICATIONS: Spectral Methods in Integer Dynamics      ║")
    print("╚" + "═" * 58 + "╝")
    print()

    demo_integer_maps()
    demo_prng_quality()
    demo_orbit_statistics()
    demo_convergence_rates()

    print("All applications completed successfully.")


#!/usr/bin/env python3
"""
demo.py — Numerical Demonstrations: Collatz Transfer Operators & Spectral Analysis

This script demonstrates the key mathematical ideas behind the spectral collapse
criterion for Collatz termination:

1. The accelerated Collatz map and its orbit structure
2. Transfer operator matrices on congruence quotients
3. Character-twisted spectral analysis
4. Spectral radius computation and gap verification

Each demonstration makes the abstract mathematics tangible with concrete examples.
"""

import numpy as np
from typing import List, Tuple, Dict
import sys


# ============================================================
# §1. Accelerated Collatz Map
# ============================================================

def nu2(n: int) -> int:
    """Compute the 2-adic valuation of n: the largest k such that 2^k | n."""
    if n == 0:
        return float('inf')
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k


def accelerated_collatz(n: int) -> int:
    """
    The accelerated Collatz map on odd positive integers:
    T(n) = (3n+1) / 2^{ν₂(3n+1)}

    This always maps an odd positive integer to another odd positive integer.

    >>> accelerated_collatz(1)
    1
    >>> accelerated_collatz(3)
    5
    >>> accelerated_collatz(5)
    1
    """
    assert n > 0 and n % 2 == 1, f"Input must be odd positive, got {n}"
    val = 3 * n + 1
    v = nu2(val)
    result = val >> v  # divide by 2^v
    assert result % 2 == 1, f"Result should be odd, got {result}"
    return result


def collatz_orbit(n: int, max_steps: int = 100) -> List[int]:
    """Compute the accelerated Collatz orbit of n until it reaches 1 or max_steps."""
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current == 1:
            break
        # If n is even, apply standard Collatz to make it odd first
        if current % 2 == 0:
            while current % 2 == 0:
                current //= 2
            orbit.append(current)
            if current == 1:
                break
        current = accelerated_collatz(current)
        orbit.append(current)
    return orbit


def demo_accelerated_collatz():
    """Demonstrate the accelerated Collatz map on several starting values."""
    print("=" * 60)
    print("DEMO 1: Accelerated Collatz Map T(n) = (3n+1)/2^{ν₂(3n+1)}")
    print("=" * 60)
    print()

    test_values = [1, 3, 5, 7, 9, 11, 13, 15, 27, 31, 127, 255]
    print(f"{'n':>6} | {'T(n)':>6} | {'ν₂(3n+1)':>8} | {'3n+1':>8}")
    print("-" * 40)
    for n in test_values:
        val = 3 * n + 1
        v = nu2(val)
        tn = accelerated_collatz(n)
        print(f"{n:>6} | {tn:>6} | {v:>8} | {val:>8}")

    print()
    print("Orbits of selected starting values:")
    for start in [7, 27, 31, 127]:
        orbit = collatz_orbit(start)
        steps = len(orbit) - 1
        print(f"  T^k({start}): {' → '.join(map(str, orbit[:15]))}{'...' if len(orbit) > 15 else ''}")
        print(f"    Reaches 1 in {steps} steps")
    print()


# ============================================================
# §2. Congruence Transition Matrices
# ============================================================

def build_transition_matrix(q: int) -> np.ndarray:
    """
    Build the transition matrix for accelerated Collatz on odd residues mod q.

    For each odd residue class r mod q, compute T(r) mod q and record the
    transition. Returns a matrix A where A[i,j] > 0 if residue j can map
    to residue i.
    """
    odd_residues = [r for r in range(q) if r % 2 == 1]
    n = len(odd_residues)
    idx = {r: i for i, r in enumerate(odd_residues)}
    A = np.zeros((n, n), dtype=complex)

    for r in odd_residues:
        # For this residue, try all possible representatives
        # and average the transition weights
        count = 0
        targets = {}
        for rep in range(r, 10 * q, q):  # representatives of r mod q
            if rep == 0 or rep % 2 == 0:
                continue
            t = accelerated_collatz(rep)
            t_mod = t % q
            if t_mod in idx:
                targets[t_mod] = targets.get(t_mod, 0) + 1
                count += 1

        if count > 0:
            for t_mod, c in targets.items():
                A[idx[t_mod], idx[r]] = c / count

    return A, odd_residues


def demo_transition_matrices():
    """Demonstrate transition matrices for small moduli."""
    print("=" * 60)
    print("DEMO 2: Congruence Transition Matrices")
    print("=" * 60)
    print()

    for q in [3, 5, 7, 9]:
        A, residues = build_transition_matrix(q)
        eigenvalues = np.linalg.eigvals(A)
        spectral_radius = max(abs(eigenvalues))

        print(f"Modulus q = {q}, odd residues: {residues}")
        print(f"  Transition matrix ({len(residues)}×{len(residues)}):")
        for i, ri in enumerate(residues):
            row = [f"{A[i,j].real:.2f}" for j in range(len(residues))]
            print(f"    [{', '.join(row)}]  ← class {ri}")
        print(f"  Eigenvalues: {[f'{e:.4f}' for e in sorted(eigenvalues, key=abs, reverse=True)]}")
        print(f"  Spectral radius: {spectral_radius:.6f}")
        print()


# ============================================================
# §3. Character-Twisted Spectral Analysis
# ============================================================

def primitive_root(p: int) -> int:
    """Find a primitive root mod p (p prime)."""
    for g in range(2, p):
        if all(pow(g, (p-1)//q, p) != 1 for q in prime_factors(p-1)):
            return g
    return -1


def prime_factors(n: int) -> List[int]:
    """Return prime factors of n."""
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            if d not in factors:
                factors.append(d)
            n //= d
        d += 1
    if n > 1 and n not in factors:
        factors.append(n)
    return factors


def dirichlet_characters(q: int) -> List[Dict[int, complex]]:
    """
    Compute all Dirichlet characters mod q (simplified for prime q).
    Returns a list of dictionaries mapping residues to character values.
    """
    if q <= 1:
        return [{}]

    chars = []
    # Trivial character
    trivial = {a: 1.0 + 0j for a in range(q) if a % q != 0}
    trivial[0] = 0j
    chars.append(trivial)

    # For prime q, use powers of a primitive root
    if all(q % p != 0 for p in range(2, int(q**0.5) + 1)) and q > 1:
        g = primitive_root(q)
        if g > 0:
            for k in range(1, q - 1):
                chi = {}
                chi[0] = 0j
                for j in range(q - 1):
                    a = pow(g, j, q)
                    chi[a] = np.exp(2j * np.pi * k * j / (q - 1))
                chars.append(chi)

    return chars


def twisted_transition_matrix(q: int, chi: Dict[int, complex]) -> np.ndarray:
    """
    Build the character-twisted transition matrix.

    Entry (i,j) of the twisted matrix is A[i,j] * χ(j) where A is the
    untwisted transition matrix and χ is a Dirichlet character.
    """
    A, residues = build_transition_matrix(q)
    n = len(residues)
    A_twisted = np.zeros((n, n), dtype=complex)

    for i in range(n):
        for j in range(n):
            r = residues[j]
            chi_val = chi.get(r % q, 0j)
            A_twisted[i, j] = A[i, j] * chi_val

    return A_twisted, residues


def demo_character_twist():
    """Demonstrate character-twisted spectral analysis."""
    print("=" * 60)
    print("DEMO 3: Character-Twisted Spectral Analysis")
    print("=" * 60)
    print()

    for q in [3, 5, 7]:
        print(f"Modulus q = {q}:")
        chars = dirichlet_characters(q)
        print(f"  Number of characters: {len(chars)}")

        for k, chi in enumerate(chars):
            A_twisted, residues = twisted_transition_matrix(q, chi)
            eigenvalues = np.linalg.eigvals(A_twisted)
            rho = max(abs(eigenvalues)) if len(eigenvalues) > 0 else 0

            label = "trivial" if k == 0 else f"χ_{k}"
            is_gap = rho < 1.0 - 1e-10
            status = "✓ GAP" if is_gap else "✗ NO GAP"
            print(f"  {label}: ρ(L_χ) = {rho:.6f}  {status}")

        print()


# ============================================================
# §4. Spectral Gap Verification
# ============================================================

def collatz_weight(s: float, m: int) -> float:
    """Compute the transfer weight 2^{-s·ν₂(3m+1)}."""
    v = nu2(3 * m + 1)
    return 2.0 ** (-s * v)


def demo_spectral_gap():
    """Demonstrate spectral gap computation for various parameters."""
    print("=" * 60)
    print("DEMO 4: Spectral Gap Verification")
    print("=" * 60)
    print()

    print("Transfer weights 2^{-s·ν₂(3n+1)} for s = 0.5:")
    s = 0.5
    for n in [1, 3, 5, 7, 9, 11, 13, 15]:
        v = nu2(3 * n + 1)
        w = collatz_weight(s, n)
        print(f"  n={n:>3}: ν₂(3n+1)={v}, weight = {w:.6f}")

    print()
    print("Spectral radii of twisted transition matrices (varying s):")
    print(f"{'q':>4} | {'s':>5} | {'ρ(trivial)':>12} | {'max ρ(nontriv)':>14} | {'Gap?':>6}")
    print("-" * 55)

    for q in [3, 5, 7]:
        chars = dirichlet_characters(q)
        for s_val in [0.0, 0.3, 0.5, 0.8, 1.0]:
            trivial_rho = 0
            max_nontriv_rho = 0

            for k, chi in enumerate(chars):
                A_tw, _ = twisted_transition_matrix(q, chi)
                eigs = np.linalg.eigvals(A_tw)
                rho = max(abs(eigs)) if len(eigs) > 0 else 0

                if k == 0:
                    trivial_rho = rho
                else:
                    max_nontriv_rho = max(max_nontriv_rho, rho)

            gap = "Yes" if max_nontriv_rho < 1.0 - 1e-6 else "No"
            print(f"{q:>4} | {s_val:>5.1f} | {trivial_rho:>12.6f} | {max_nontriv_rho:>14.6f} | {gap:>6}")
    print()


# ============================================================
# §5. Orbit Distribution Analysis
# ============================================================

def demo_orbit_distribution():
    """Demonstrate how orbits distribute over residue classes."""
    print("=" * 60)
    print("DEMO 5: Orbit Distribution Over Residue Classes")
    print("=" * 60)
    print()

    q = 5
    print(f"Distribution of Collatz orbits over residues mod {q}:")
    print()

    for start in [7, 27, 127, 511]:
        orbit = collatz_orbit(start, max_steps=200)
        # Count residue visits
        counts = {}
        for x in orbit:
            r = x % q
            counts[r] = counts.get(r, 0) + 1

        total = len(orbit)
        print(f"  Starting at n = {start} (orbit length {total}):")
        for r in sorted(counts.keys()):
            freq = counts[r] / total
            bar = '█' * int(freq * 40)
            print(f"    mod {q} ≡ {r}: {counts[r]:>4} visits ({freq:.3f}) {bar}")
        print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  COLLATZ TRANSFER OPERATORS: SPECTRAL ANALYSIS DEMOS    ║")
    print("╚" + "═" * 58 + "╝")
    print()

    demo_accelerated_collatz()
    demo_transition_matrices()
    demo_character_twist()
    demo_spectral_gap()
    demo_orbit_distribution()

    print("All demos completed successfully.")
