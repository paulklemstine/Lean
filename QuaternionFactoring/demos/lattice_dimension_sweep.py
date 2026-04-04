#!/usr/bin/env python3
"""
Lattice Dimension Sweep Experiment
====================================

Systematically tests how factoring performance varies with lattice dimension.
Measures:
1. Shortest vector length vs dimension
2. Factoring success rate vs dimension
3. Computation time vs dimension
4. Optimal dimension determination

Usage:
    python lattice_dimension_sweep.py
"""

import math
import random
import time
from typing import List, Tuple, Optional

random.seed(12345)


def isprime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i+2) == 0: return False
        i += 6
    return True


def vector_norm(v):
    return math.sqrt(sum(x*x for x in v))


def dot(u, v):
    return sum(a*b for a, b in zip(u, v))


def lll_reduce(basis, delta=0.99):
    n = len(basis)
    if n == 0: return basis
    B = [list(v) for v in basis]
    dim = len(B[0])

    def gram_schmidt(B):
        n = len(B)
        Q = [list(b) for b in B]
        mu = [[0.0]*n for _ in range(n)]
        for i in range(n):
            for j in range(i):
                d = dot(Q[j], Q[j])
                mu[i][j] = dot(B[i], Q[j]) / d if d != 0 else 0
                Q[i] = [Q[i][k] - mu[i][j]*Q[j][k] for k in range(dim)]
        return Q, mu

    k = 1
    max_iter = 1000
    iters = 0
    while k < n and iters < max_iter:
        iters += 1
        Q, mu = gram_schmidt(B)
        for j in range(k-1, -1, -1):
            if abs(mu[k][j]) > 0.5:
                r = round(mu[k][j])
                B[k] = [B[k][i] - r*B[j][i] for i in range(dim)]
                Q, mu = gram_schmidt(B)
        lhs = dot(Q[k], Q[k])
        rhs = (delta - mu[k][k-1]**2) * dot(Q[k-1], Q[k-1])
        if lhs >= rhs:
            k += 1
        else:
            B[k], B[k-1] = B[k-1], B[k]
            k = max(k-1, 1)

    return [[round(x) for x in v] for v in B]


def build_lattice_nd(N: int, dim: int) -> List[List[int]]:
    """Build a dim-dimensional lattice for sum-of-d-squares ≡ 0 (mod N)."""
    solutions = []
    limit = min(int(N**0.5) + 1, 100)

    # Search for solutions
    if dim == 2:
        for x in range(limit):
            for y in range(1, limit):
                if (x*x + y*y) % N == 0:
                    solutions.append([x, y])
                    if len(solutions) >= dim: break
            if len(solutions) >= dim: break
    elif dim == 3:
        for x in range(limit):
            for y in range(limit):
                for z in range(1, limit):
                    if (x*x + y*y + z*z) % N == 0:
                        solutions.append([x, y, z])
                        if len(solutions) >= dim: break
                if len(solutions) >= dim: break
            if len(solutions) >= dim: break
    elif dim == 4:
        for a in range(limit):
            for b in range(limit):
                for c in range(limit):
                    for d in range(1, limit):
                        if (a*a + b*b + c*c + d*d) % N == 0:
                            solutions.append([a, b, c, d])
                            if len(solutions) >= dim: break
                    if len(solutions) >= dim: break
                if len(solutions) >= dim: break
            if len(solutions) >= dim: break
    else:
        # General: random search
        for _ in range(dim * 100):
            v = [random.randint(0, N-1) for _ in range(dim)]
            s = sum(x*x for x in v) % N
            if s == 0 and any(x != 0 for x in v):
                solutions.append(v)
                if len(solutions) >= dim: break

    # Pad with N-scaled vectors
    while len(solutions) < dim:
        v = [0] * dim
        v[len(solutions) % dim] = N
        solutions.append(v)

    return solutions[:dim]


def enhanced_extract(N: int, vectors: List[List[int]]) -> Optional[int]:
    for v in vectors:
        for x in v:
            if x != 0:
                g = math.gcd(abs(x), N)
                if 1 < g < N: return g
        s = sum(x*x for x in v)
        if s > 0:
            g = math.gcd(s, N)
            if 1 < g < N: return g
        for i in range(len(v)):
            for j in range(i+1, len(v)):
                s2 = v[i]**2 + v[j]**2
                if s2 > 0:
                    g = math.gcd(s2, N)
                    if 1 < g < N: return g
    # Linear combos
    for i in range(len(vectors)):
        for j in range(i+1, len(vectors)):
            for a in range(-2, 3):
                for b in range(-2, 3):
                    if a == 0 and b == 0: continue
                    combo = [a*vectors[i][k] + b*vectors[j][k] for k in range(len(vectors[0]))]
                    s = sum(x*x for x in combo)
                    if s > 0:
                        g = math.gcd(s, N)
                        if 1 < g < N: return g
    return None


def run_dimension_sweep():
    """Main experiment: sweep dimensions 2-5 for various N sizes."""
    print("╔" + "═"*68 + "╗")
    print("║" + "LATTICE DIMENSION SWEEP EXPERIMENT".center(68) + "║")
    print("╚" + "═"*68 + "╝")

    # Generate test semiprimes at different scales
    scales = [
        ("8-bit",  50, 300),
        ("10-bit", 200, 1200),
        ("12-bit", 1000, 5000),
        ("14-bit", 4000, 20000),
    ]

    dims = [2, 3, 4]
    trials_per = 30

    for scale_name, lo, hi in scales:
        print(f"\n{'─'*70}")
        print(f"Scale: {scale_name} semiprimes (N ∈ [{lo}, {hi}])")
        print(f"{'─'*70}")
        print(f"  {'dim':>4s}  {'success':>8s}  {'avg||v||':>10s}  {'avg||v||/√N':>12s}  {'avg_time':>10s}")

        for dim in dims:
            successes = 0
            norms = []
            times = []

            for trial in range(trials_per):
                # Generate semiprime
                primes_pool = [p for p in range(max(2, int(lo**0.5)//2), int(hi**0.5)+1) if isprime(p)]
                if len(primes_pool) < 2:
                    continue
                while True:
                    p = random.choice(primes_pool)
                    q = random.choice(primes_pool)
                    N = p * q
                    if p != q and lo <= N <= hi:
                        break

                t0 = time.time()
                basis = build_lattice_nd(N, dim)
                reduced = lll_reduce(basis)
                factor = enhanced_extract(N, reduced)
                elapsed = time.time() - t0
                times.append(elapsed)

                if factor is not None:
                    successes += 1

                nz = [vector_norm(v) for v in reduced if any(x != 0 for x in v)]
                if nz:
                    norms.append(min(nz) / math.sqrt(N))

            avg_norm_ratio = sum(norms) / len(norms) if norms else float('nan')
            avg_norm = sum(n * math.sqrt(500) for n in norms) / len(norms) if norms else float('nan')
            avg_time = sum(times) / len(times) * 1000 if times else float('nan')
            rate = f"{successes}/{trials_per}"
            print(f"  {dim:4d}  {rate:>8s}  {avg_norm:10.3f}  {avg_norm_ratio:12.4f}  {avg_time:8.1f}ms")


def scaling_exponent_by_dimension():
    """Measure the scaling exponent α for each dimension."""
    print("\n" + "="*70)
    print("SCALING EXPONENT α BY DIMENSION")
    print("="*70)

    dims = [2, 3, 4]

    for dim in dims:
        print(f"\n  Dimension {dim}:")
        log_N = []
        log_v = []

        for bits in range(6, 16, 2):
            norms = []
            N_vals = []
            primes_pool = [p for p in range(2**(bits//2-1), 2**(bits//2)) if isprime(p)]
            if len(primes_pool) < 2:
                continue

            for _ in range(20):
                p = random.choice(primes_pool)
                q = random.choice(primes_pool)
                if p == q: continue
                N = p * q
                basis = build_lattice_nd(N, dim)
                reduced = lll_reduce(basis)
                nz = [vector_norm(v) for v in reduced if any(x != 0 for x in v)]
                if nz:
                    norms.append(min(nz))
                    N_vals.append(N)

            if norms:
                avg_N = sum(N_vals) / len(N_vals)
                avg_norm = sum(norms) / len(norms)
                alpha = math.log(avg_norm) / math.log(avg_N) if avg_N > 1 else 0
                log_N.append(math.log(avg_N))
                log_v.append(math.log(avg_norm))
                print(f"    bits={bits:2d}: α = {alpha:.3f}  (avg_N={avg_N:.0f}, avg||v||={avg_norm:.2f})")

        # Fit overall α
        if len(log_N) >= 2:
            n = len(log_N)
            sx = sum(log_N); sy = sum(log_v)
            sxx = sum(x*x for x in log_N)
            sxy = sum(x*y for x, y in zip(log_N, log_v))
            alpha_fit = (n*sxy - sx*sy) / (n*sxx - sx*sx) if (n*sxx - sx*sx) != 0 else 0
            print(f"    Fitted α = {alpha_fit:.4f}")


if __name__ == "__main__":
    run_dimension_sweep()
    scaling_exponent_by_dimension()
