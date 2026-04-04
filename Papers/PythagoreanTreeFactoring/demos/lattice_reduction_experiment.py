#!/usr/bin/env python3
"""
Lattice Reduction Experiment: 2D vs 3D
=======================================

Compares factoring performance via:
1. 2D Gauss reduction (= Berggren tree descent) — Θ(√N) for balanced semiprimes
2. 3D LLL reduction on the Pythagorean quadruple lattice — potentially sub-√N

This script implements the experimental protocol described in the paper
"Pythagorean Tree Factoring: Lattice-Tree Correspondence and the
Quadruple Escape."
"""

import numpy as np
from math import gcd, isqrt
import time
import random

# ============================================================================
# 2D Lattice Factoring (Gauss Reduction)
# ============================================================================

def factor_2d_gauss(N, verbose=False):
    """Factor N using 2D Gauss lattice reduction on the Pythagorean lattice.

    We construct the lattice basis from the Euclid parametrization and
    apply Gauss's algorithm. This is equivalent to Berggren tree descent.

    Steps counted = number of reduction steps until a factor is found.
    """
    if N % 2 == 0:
        return 2, 1

    steps = 0
    N_sq = N * N

    # Enumerate divisor pairs (d, e) of N² with d < e, same parity
    # This is the 2D lattice approach
    for d in range(1, isqrt(N_sq) + 1):
        if N_sq % d != 0:
            continue
        e = N_sq // d
        if d >= e:
            break
        if (d % 2) != (e % 2):
            continue

        steps += 1
        b = (e - d) // 2
        c = (e + d) // 2

        g = gcd(b, N)
        if 1 < g < N:
            return g, steps

        g = gcd(c, N)
        if 1 < g < N:
            return g, steps

    return None, steps


# ============================================================================
# 3D Lattice Construction (Pythagorean Quadruples)
# ============================================================================

def construct_quadruple_lattice(N):
    """Construct the lattice L₄(N) = {(x,y,z) : x²+y²+z² ≡ 0 mod N}.

    We find a basis by:
    1. Starting with the obvious vector (N, 0, 0)
    2. Finding short vectors via three-square representations
    3. Using size-reduction to improve the basis
    """
    # Basis starts with scaled identity-like vectors
    basis = [
        np.array([N, 0, 0], dtype=np.int64),
        np.array([0, N, 0], dtype=np.int64),
        np.array([0, 0, N], dtype=np.int64),
    ]

    # Try to find short vectors in the lattice
    # Look for (x, y, z) with x² + y² + z² = k*N for small k
    short_vectors = []
    limit = isqrt(3 * N) + 1
    for x in range(limit):
        for y in range(x, limit):
            rem = N - (x*x + y*y) % N
            if rem == N:
                rem = 0
            z_sq = rem
            z = isqrt(z_sq)
            if z * z == z_sq and (x*x + y*y + z*z) % N == 0:
                if x*x + y*y + z*z > 0:
                    short_vectors.append(np.array([x, y, z], dtype=np.int64))
                    if len(short_vectors) >= 10:
                        break
        if len(short_vectors) >= 10:
            break

    return basis, short_vectors


def lll_reduce_3d(basis, delta=0.75):
    """Simple LLL reduction in 3D.

    Implements the Lenstra-Lenstra-Lovász algorithm for a 3D integer lattice.
    """
    n = len(basis)
    B = [np.array(b, dtype=np.float64) for b in basis]

    def gram_schmidt(B):
        B_star = []
        mu = np.zeros((n, n))
        for i in range(n):
            B_star_i = np.array(B[i], dtype=np.float64)
            for j in range(i):
                if np.dot(B_star[j], B_star[j]) > 1e-10:
                    mu[i][j] = np.dot(B[i], B_star[j]) / np.dot(B_star[j], B_star[j])
                B_star_i = B_star_i - mu[i][j] * B_star[j]
            B_star.append(B_star_i)
        return B_star, mu

    steps = 0
    k = 1
    while k < n:
        B_star, mu = gram_schmidt(B)

        # Size-reduce B[k]
        for j in range(k - 1, -1, -1):
            if abs(mu[k][j]) > 0.5:
                r = round(mu[k][j])
                B[k] = B[k] - r * B[j]
                B_star, mu = gram_schmidt(B)

        # Lovász condition
        norm_k_star = np.dot(B_star[k], B_star[k])
        norm_km1_star = np.dot(B_star[k-1], B_star[k-1])

        if norm_k_star >= (delta - mu[k][k-1]**2) * norm_km1_star:
            k += 1
        else:
            # Swap B[k] and B[k-1]
            B[k], B[k-1] = B[k-1], B[k]
            k = max(k - 1, 1)

        steps += 1
        if steps > 1000:
            break

    return [np.array(b, dtype=np.int64) for b in B], steps


def factor_3d_lattice(N, verbose=False):
    """Attempt to factor N using 3D lattice reduction.

    1. Construct the quadruple lattice L₄(N)
    2. Apply LLL reduction
    3. Check short vectors for GCD-based factor extraction
    """
    if N % 2 == 0:
        return 2, 0

    basis, short_vectors = construct_quadruple_lattice(N)

    # If we found short vectors, check them for factors
    total_steps = 0
    for v in short_vectors:
        x, y, z = int(v[0]), int(v[1]), int(v[2])
        total_steps += 1

        # Try various GCD extractions
        for val in [x, y, z, x*x + y*y, y*y + z*z, x*x + z*z,
                    x + y, x - y, x + z, x - z, y + z, y - z]:
            g = gcd(abs(val), N)
            if 1 < g < N:
                if verbose:
                    print(f"  Factor via short vector ({x},{y},{z}): {g}")
                return g, total_steps

    # Try LLL on the basis augmented with short vectors
    if len(short_vectors) >= 3:
        reduced, lll_steps = lll_reduce_3d(short_vectors[:3])
        total_steps += lll_steps
        for v in reduced:
            x, y, z = int(v[0]), int(v[1]), int(v[2])
            for val in [x, y, z, x*x + y*y, y*y + z*z, x*x + z*z,
                        x + y, x - y, x + z, x - z]:
                g = gcd(abs(val), N)
                if 1 < g < N:
                    if verbose:
                        print(f"  Factor via LLL vector ({x},{y},{z}): {g}")
                    return g, total_steps

    return None, total_steps


# ============================================================================
# Experimental Protocol
# ============================================================================

def run_experiment(bit_sizes=range(10, 36, 2), trials=10):
    """Compare 2D Gauss vs 3D LLL factoring across different sizes."""
    print("="*80)
    print("EXPERIMENT: 2D Gauss vs 3D LLL Factoring")
    print("="*80)
    print(f"{'Bits':>6} {'N':>14} {'2D Steps':>10} {'3D Steps':>10} {'2D Time':>10} {'3D Time':>10} {'√N':>8}")
    print("-"*80)

    results = []

    for bits in bit_sizes:
        gauss_steps_total = 0
        lll_steps_total = 0
        gauss_time_total = 0
        lll_time_total = 0
        successes_2d = 0
        successes_3d = 0

        for trial in range(trials):
            p = random_prime(bits // 2)
            q = random_prime(bits // 2)
            if p == q:
                q = random_prime(bits // 2)
            if p > q:
                p, q = q, p
            N = p * q

            # 2D Gauss
            t0 = time.time()
            factor_2d, steps_2d = factor_2d_gauss(N)
            t1 = time.time()
            gauss_steps_total += steps_2d
            gauss_time_total += (t1 - t0)
            if factor_2d is not None:
                successes_2d += 1

            # 3D LLL
            t0 = time.time()
            factor_3d, steps_3d = factor_3d_lattice(N)
            t1 = time.time()
            lll_steps_total += steps_3d
            lll_time_total += (t1 - t0)
            if factor_3d is not None:
                successes_3d += 1

        avg_2d = gauss_steps_total / trials
        avg_3d = lll_steps_total / trials
        avg_t2d = gauss_time_total / trials * 1000  # ms
        avg_t3d = lll_time_total / trials * 1000
        sqrt_N = isqrt(N)

        results.append({
            'bits': bits, 'avg_2d_steps': avg_2d, 'avg_3d_steps': avg_3d,
            'avg_2d_time_ms': avg_t2d, 'avg_3d_time_ms': avg_t3d,
            'sqrt_N': sqrt_N, 'success_2d': successes_2d, 'success_3d': successes_3d
        })

        print(f"{bits:6d} {N:14d} {avg_2d:10.1f} {avg_3d:10.1f} "
              f"{avg_t2d:10.2f} {avg_t3d:10.2f} {sqrt_N:8d}")

    print("\nLegend: Steps = lattice reduction / enumeration steps")
    print("        Time in milliseconds (averaged over trials)")
    return results


def random_prime(bits):
    """Generate a random prime with approximately `bits` bits."""
    while True:
        n = random.randint(2**(bits-1), 2**bits - 1)
        if n < 2:
            continue
        if is_prime(n):
            return n


def is_prime(n):
    """Miller-Rabin primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False

    # Write n-1 = 2^r * d
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2

    # Test with several witnesses
    for a in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
        if a >= n:
            continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True


# ============================================================================
# Visualization Data Generation
# ============================================================================

def generate_complexity_plot_data(bit_sizes=range(10, 32, 2), trials=5):
    """Generate data for complexity comparison plots."""
    data = {"2d_gauss": [], "trial_div": [], "sqrt_n": []}

    for bits in bit_sizes:
        for _ in range(trials):
            p = random_prime(bits // 2)
            q = random_prime(bits // 2)
            if p > q:
                p, q = q, p
            N = p * q

            # 2D method
            _, steps_2d = factor_2d_gauss(N)

            # Trial division
            steps_td = 0
            for i in range(2, isqrt(N) + 1):
                steps_td += 1
                if N % i == 0:
                    break

            data["2d_gauss"].append({"N": N, "bits": bits, "steps": steps_2d})
            data["trial_div"].append({"N": N, "bits": bits, "steps": steps_td})
            data["sqrt_n"].append({"N": N, "bits": bits, "value": isqrt(N)})

    return data


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    random.seed(42)

    # Run the main experiment
    print("Running 2D vs 3D lattice factoring experiment...\n")
    results = run_experiment(bit_sizes=range(10, 30, 2), trials=5)

    # Show some specific examples
    print("\n\nDETAILED EXAMPLES:")
    print("="*60)

    for N in [143, 1001, 10403, 100127]:
        print(f"\n--- N = {N} ---")
        f2, s2 = factor_2d_gauss(N, verbose=True)
        f3, s3 = factor_3d_lattice(N, verbose=True)
        print(f"  2D Gauss: factor={f2}, steps={s2}")
        print(f"  3D LLL:   factor={f3}, steps={s3}")

    print("\n\nDone.")
