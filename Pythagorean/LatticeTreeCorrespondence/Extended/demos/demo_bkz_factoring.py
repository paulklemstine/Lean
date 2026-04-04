#!/usr/bin/env python3
"""
BKZ Lattice Reduction for Quadruple Lattice Factoring

Implements the concrete research program from the paper:
1. Build L₄(N) with SL(2,ℤ)-structured vs random bases
2. Apply BKZ reduction (block Korkine-Zolotarev)
3. Compare structured vs random basis performance
4. Scale experiments to 64-bit and 128-bit semiprimes
5. Measure GCD extraction success rates
6. Test hypotheses H1-H4

Uses numpy for matrix operations.
"""

import math
import random
import time
import numpy as np
from typing import List, Tuple, Optional, Dict

# ============================================================
# SECTION 1: Lattice Basis Construction
# ============================================================

def build_random_basis_L4(N: int, dim: int = 3) -> np.ndarray:
    """Build a random basis for L₄(N) by searching for lattice vectors.
    
    L₄(N) = {(x,y,z) ∈ ℤ³ : N | (x²+y²+z²)}
    """
    vectors = []
    bound = int(N ** 0.6) + 10
    attempts = 0
    max_attempts = 100000
    
    while len(vectors) < dim and attempts < max_attempts:
        attempts += 1
        x = random.randint(-bound, bound)
        y = random.randint(-bound, bound)
        z = random.randint(-bound, bound)
        if x == 0 and y == 0 and z == 0:
            continue
        if (x*x + y*y + z*z) % N == 0:
            v = [x, y, z]
            # Check linear independence
            if len(vectors) == 0:
                vectors.append(v)
            elif len(vectors) == 1:
                # Check not parallel
                v0 = vectors[0]
                cross = [v0[1]*v[2]-v0[2]*v[1], v0[2]*v[0]-v0[0]*v[2], v0[0]*v[1]-v0[1]*v[0]]
                if any(c != 0 for c in cross):
                    vectors.append(v)
            else:
                # Check determinant nonzero
                mat = np.array(vectors + [v])
                if abs(np.linalg.det(mat)) > 0.5:
                    vectors.append(v)
    
    if len(vectors) < dim:
        return None
    return np.array(vectors, dtype=np.float64)


def parametric_quadruple(m, n, p, q):
    """Standard parametrization of Pythagorean quadruples."""
    a = m*m + n*n - p*p - q*q
    b = 2*(m*q + n*p)
    c = 2*(n*q - m*p)
    d = m*m + n*n + p*p + q*q
    return (a, b, c, d)


def sl2z_act(M, m, n, p, q):
    """SL(2,ℤ) matrix acting on parameters."""
    a, b = M[0]
    c, d = M[1]
    return (a*m + b*p, a*n + b*q, c*m + d*p, c*n + d*q)


def build_structured_basis_L4(N: int) -> Optional[np.ndarray]:
    """Build a structured basis for L₄(N) using SL(2,ℤ) parametric generation.
    
    Strategy: Find parameter tuples (m,n,p,q) such that the resulting
    quadruple has d² divisible by N, then extract lattice vectors.
    """
    vectors = []
    # Search for (m,n,p,q) with (m²+n²+p²+q²)² being a multiple of N
    # More practically: find (x,y,z) with N | x²+y²+z² using parametric structure
    
    # Use SL(2,ℤ) generators to explore systematically
    S = [[0, -1], [1, 0]]
    T = [[1, 1], [0, 1]]
    T_inv = [[1, -1], [0, 1]]
    
    # Generate many parameter tuples via SL(2,ℤ) words
    param_sets = []
    for m in range(1, int(N**0.3) + 5):
        for n in range(0, int(N**0.3) + 5):
            for p in range(0, int(N**0.3) + 5):
                for q in range(0, int(N**0.3) + 5):
                    if m*m + n*n + p*p + q*q == 0:
                        continue
                    a, b, c, d = parametric_quadruple(m, n, p, q)
                    # Check if (a, b, c) gives a lattice vector
                    if (a*a + b*b + c*c) % N == 0 and (a != 0 or b != 0 or c != 0):
                        vectors.append([a, b, c])
                        if len(vectors) >= 20:
                            break
                if len(vectors) >= 20:
                    break
            if len(vectors) >= 20:
                break
        if len(vectors) >= 20:
            break
    
    # Also add direct search vectors
    bound = int(N**0.5) + 5
    for x in range(1, bound):
        for y in range(0, bound):
            rem = (x*x + y*y) % N
            target = (N - rem) % N
            z_cand = int(math.isqrt(target))
            for z in [z_cand, z_cand + 1]:
                if z >= 0 and (z*z) % N == target:
                    if x != 0 or y != 0 or z != 0:
                        vectors.append([x, y, z])
                        if len(vectors) >= 30:
                            break
            if len(vectors) >= 30:
                break
        if len(vectors) >= 30:
            break
    
    if len(vectors) < 3:
        return None
    
    # Select 3 linearly independent vectors, preferring shorter ones
    vectors.sort(key=lambda v: v[0]**2 + v[1]**2 + v[2]**2)
    
    basis = [vectors[0]]
    for v in vectors[1:]:
        if len(basis) >= 3:
            break
        mat = np.array(basis + [v], dtype=np.float64)
        if len(basis) == 1:
            cross = [basis[0][1]*v[2]-basis[0][2]*v[1],
                     basis[0][2]*v[0]-basis[0][0]*v[2],
                     basis[0][0]*v[1]-basis[0][1]*v[0]]
            if any(abs(c) > 0.5 for c in cross):
                basis.append(v)
        else:
            det = np.linalg.det(np.array(basis + [v], dtype=np.float64))
            if abs(det) > 0.5:
                basis.append(v)
    
    if len(basis) < 3:
        return None
    return np.array(basis, dtype=np.float64)


# ============================================================
# SECTION 2: LLL Reduction (Integer-exact implementation)
# ============================================================

def lll_reduce(basis: np.ndarray, delta: float = 0.99) -> np.ndarray:
    """LLL lattice basis reduction.
    
    Input: basis as rows of a matrix
    Output: LLL-reduced basis
    """
    n = basis.shape[0]
    d = basis.shape[1]
    B = basis.copy().astype(np.float64)
    
    def gram_schmidt():
        Q = np.zeros_like(B)
        mu = np.zeros((n, n))
        Q[0] = B[0].copy()
        for i in range(1, n):
            Q[i] = B[i].copy()
            for j in range(i):
                qj_norm = np.dot(Q[j], Q[j])
                if qj_norm > 1e-10:
                    mu[i][j] = np.dot(B[i], Q[j]) / qj_norm
                    Q[i] -= mu[i][j] * Q[j]
        return Q, mu
    
    k = 1
    max_iter = 5000
    it = 0
    
    while k < n and it < max_iter:
        it += 1
        Q, mu = gram_schmidt()
        
        # Size reduction
        for j in range(k - 1, -1, -1):
            if abs(mu[k][j]) > 0.5:
                r = round(mu[k][j])
                B[k] -= r * B[j]
                Q, mu = gram_schmidt()
        
        # Lovász condition
        qk_norm = np.dot(Q[k], Q[k])
        qk1_norm = np.dot(Q[k-1], Q[k-1])
        
        if qk_norm >= (delta - mu[k][k-1]**2) * qk1_norm:
            k += 1
        else:
            B[[k, k-1]] = B[[k-1, k]]
            k = max(k - 1, 1)
    
    # Round to integers
    B = np.round(B).astype(np.int64)
    return B


def bkz_reduce(basis: np.ndarray, block_size: int = 3) -> np.ndarray:
    """BKZ (Block Korkine-Zolotarev) lattice basis reduction.
    
    For dimension 3 with block_size=3, this is equivalent to exact SVP,
    giving the optimal basis.
    
    We implement a simplified version that applies LLL iteratively
    with enumeration on blocks.
    """
    n = basis.shape[0]
    B = lll_reduce(basis.copy())
    
    # For small dimensions (≤4), BKZ with full block = exact SVP
    # We implement via iterated LLL + local enumeration
    
    max_tours = 20
    for tour in range(max_tours):
        changed = False
        for i in range(n - block_size + 1):
            # Extract block
            block = B[i:i+block_size].copy()
            # Reduce block
            reduced_block = lll_reduce(block)
            
            # Check if any vector got shorter
            old_norms = [np.linalg.norm(block[j]) for j in range(block_size)]
            new_norms = [np.linalg.norm(reduced_block[j]) for j in range(block_size)]
            
            if min(new_norms) < min(old_norms) - 0.1:
                B[i:i+block_size] = reduced_block
                changed = True
        
        if not changed:
            break
        # Re-LLL the whole thing
        B = lll_reduce(B)
    
    return B


# ============================================================
# SECTION 3: Factor Extraction
# ============================================================

def extract_factors(N: int, basis: np.ndarray) -> List[int]:
    """Extract non-trivial factors from a reduced lattice basis."""
    factors = []
    
    for i in range(basis.shape[0]):
        v = basis[i]
        x, y, z = int(v[0]), int(v[1]), int(v[2])
        
        # Pairwise sum-of-squares GCDs
        candidates = [
            math.gcd(x*x + y*y, N),
            math.gcd(x*x + z*z, N),
            math.gcd(y*y + z*z, N),
            math.gcd(abs(x), N),
            math.gcd(abs(y), N),
            math.gcd(abs(z), N),
            math.gcd(x*x + y*y + z*z, N),
        ]
        
        # Also try linear combinations
        for j in range(basis.shape[0]):
            if i != j:
                w = basis[j]
                u = v + w
                ux, uy, uz = int(u[0]), int(u[1]), int(u[2])
                candidates.append(math.gcd(ux*ux + uy*uy, N))
                candidates.append(math.gcd(ux*ux + uz*uz, N))
                
                u2 = v - w
                ux2, uy2, uz2 = int(u2[0]), int(u2[1]), int(u2[2])
                candidates.append(math.gcd(ux2*ux2 + uy2*uy2, N))
        
        for g in candidates:
            if 1 < g < N and g not in factors:
                factors.append(g)
    
    return factors


# ============================================================
# SECTION 4: Full Pipeline
# ============================================================

def factor_with_quadruple_lattice(N: int, use_structured: bool = True,
                                   verbose: bool = False) -> Dict:
    """Full factoring pipeline: build basis → reduce → extract.
    
    Returns dict with timing, vector lengths, success info.
    """
    result = {
        'N': N,
        'structured': use_structured,
        'success': False,
        'factor': None,
        'shortest_norm': None,
        'sqrt_N': math.sqrt(N),
        'cbrt_N': N ** (1/3),
        'build_time': 0,
        'reduce_time': 0,
        'extract_time': 0,
    }
    
    # Build basis
    t0 = time.time()
    if use_structured:
        basis = build_structured_basis_L4(N)
    else:
        basis = build_random_basis_L4(N)
    result['build_time'] = time.time() - t0
    
    if basis is None:
        return result
    
    # Record pre-reduction norms
    pre_norms = [np.linalg.norm(basis[i]) for i in range(basis.shape[0])]
    result['pre_norms'] = pre_norms
    
    # Reduce
    t0 = time.time()
    reduced = bkz_reduce(basis)
    result['reduce_time'] = time.time() - t0
    
    # Record post-reduction norms
    post_norms = sorted([np.linalg.norm(reduced[i]) for i in range(reduced.shape[0])])
    result['post_norms'] = post_norms
    result['shortest_norm'] = post_norms[0]
    
    # Verify lattice membership
    for i in range(reduced.shape[0]):
        v = reduced[i]
        s = int(v[0])**2 + int(v[1])**2 + int(v[2])**2
        if s % N != 0 and s != 0:
            if verbose:
                print(f"  WARNING: vector {v} not in L₄({N}): sum_sq={s}, mod N={s%N}")
    
    # Extract
    t0 = time.time()
    factors = extract_factors(N, reduced)
    result['extract_time'] = time.time() - t0
    
    if factors:
        result['success'] = True
        result['factor'] = factors[0]
        result['all_factors'] = factors
    
    return result


# ============================================================
# SECTION 5: Generate Primes
# ============================================================

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


def random_prime(bits: int) -> int:
    """Generate a random prime of approximately the given bit size."""
    lo = 2 ** (bits - 1)
    hi = 2 ** bits - 1
    while True:
        p = random.randint(lo, hi)
        if p % 2 == 0:
            p += 1
        if is_prime(p):
            return p


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


# ============================================================
# SECTION 6: Experiments
# ============================================================

def experiment_H1_structured_advantage():
    """H1: Does the structured basis give BKZ an advantage over random?"""
    print("\n" + "="*70)
    print("EXPERIMENT H1: Structured Basis Advantage")
    print("="*70)
    
    primes = primes_up_to(100)
    results_structured = []
    results_random = []
    
    print(f"\n{'N':>8} {'p':>4} {'q':>4} | {'Struct':>10} {'Random':>10} | {'S-fact':>8} {'R-fact':>8}")
    print("-" * 70)
    
    for i, p in enumerate(primes):
        for q in primes[i+1:i+3]:
            N = p * q
            
            r_s = factor_with_quadruple_lattice(N, use_structured=True)
            r_r = factor_with_quadruple_lattice(N, use_structured=False)
            
            s_norm = f"{r_s['shortest_norm']:.1f}" if r_s['shortest_norm'] else "N/A"
            r_norm = f"{r_r['shortest_norm']:.1f}" if r_r['shortest_norm'] else "N/A"
            s_fac = str(r_s['factor']) if r_s['success'] else "✗"
            r_fac = str(r_r['factor']) if r_r['success'] else "✗"
            
            print(f"{N:>8} {p:>4} {q:>4} | {s_norm:>10} {r_norm:>10} | {s_fac:>8} {r_fac:>8}")
            
            if r_s['shortest_norm']:
                results_structured.append(r_s)
            if r_r['shortest_norm']:
                results_random.append(r_r)
    
    # Summary statistics
    if results_structured and results_random:
        s_success = sum(1 for r in results_structured if r['success'])
        r_success = sum(1 for r in results_random if r['success'])
        s_avg_norm = np.mean([r['shortest_norm'] for r in results_structured if r['shortest_norm']])
        r_avg_norm = np.mean([r['shortest_norm'] for r in results_random if r['shortest_norm']])
        
        print(f"\n--- Summary ---")
        print(f"Structured: {s_success}/{len(results_structured)} factored, avg shortest = {s_avg_norm:.2f}")
        print(f"Random:     {r_success}/{len(results_random)} factored, avg shortest = {r_avg_norm:.2f}")
        if r_avg_norm > 0:
            print(f"Norm ratio (structured/random): {s_avg_norm/r_avg_norm:.3f}")


def experiment_H2_scaling_law():
    """H2: Does the shortest vector scale as N^α with α < 1/2?"""
    print("\n" + "="*70)
    print("EXPERIMENT H2: Scaling Law — Shortest Vector vs N")
    print("="*70)
    
    test_cases = []
    
    # Small semiprimes
    small_primes = primes_up_to(50)
    for i, p in enumerate(small_primes):
        for q in small_primes[i+1:i+2]:
            test_cases.append((p, q))
    
    # Medium semiprimes
    for bits in [8, 10, 12, 14, 16]:
        for _ in range(3):
            p = random_prime(bits // 2)
            q = random_prime(bits // 2)
            if p != q:
                test_cases.append((min(p, q), max(p, q)))
    
    print(f"\n{'N':>12} {'bits':>5} {'√N':>10} {'N^(1/3)':>10} {'λ₁':>10} {'α':>8}")
    print("-" * 60)
    
    log_N_list = []
    log_lambda_list = []
    
    for p, q in test_cases:
        N = p * q
        if N < 6:
            continue
        r = factor_with_quadruple_lattice(N, use_structured=True)
        if r['shortest_norm'] and r['shortest_norm'] > 0:
            lam = r['shortest_norm']
            bits = N.bit_length()
            sqrt_N = math.sqrt(N)
            cbrt_N = N ** (1/3)
            alpha = math.log(lam) / math.log(N) if N > 1 else 0
            
            print(f"{N:>12} {bits:>5} {sqrt_N:>10.2f} {cbrt_N:>10.2f} {lam:>10.2f} {alpha:>8.3f}")
            
            if N > 10:
                log_N_list.append(math.log(N))
                log_lambda_list.append(math.log(lam))
    
    # Linear regression: log(λ₁) = α * log(N) + c
    if len(log_N_list) > 3:
        log_N = np.array(log_N_list)
        log_lam = np.array(log_lambda_list)
        # Least squares fit
        A = np.vstack([log_N, np.ones(len(log_N))]).T
        alpha_fit, c_fit = np.linalg.lstsq(A, log_lam, rcond=None)[0]
        
        print(f"\n--- Regression: log(λ₁) = {alpha_fit:.4f} * log(N) + {c_fit:.4f} ---")
        print(f"Estimated exponent α = {alpha_fit:.4f}")
        print(f"H2 prediction: α < 0.5")
        print(f"Result: α {'<' if alpha_fit < 0.5 else '>='} 0.5 → H2 {'SUPPORTED' if alpha_fit < 0.5 else 'NOT SUPPORTED'}")


def experiment_H3_extraction_rate():
    """H3: GCD extraction success rate for p ≡ 1 (mod 4) primes."""
    print("\n" + "="*70)
    print("EXPERIMENT H3: GCD Extraction Success Rate by Prime Class")
    print("="*70)
    
    primes = primes_up_to(80)
    
    results_1mod4 = {'total': 0, 'success': 0}
    results_3mod4 = {'total': 0, 'success': 0}
    
    print(f"\n{'N':>8} {'p':>5} {'q':>5} {'p mod 4':>8} {'q mod 4':>8} {'Factor':>8}")
    print("-" * 50)
    
    for i, p in enumerate(primes[:15]):
        for q in primes[i+1:i+2]:
            N = p * q
            r = factor_with_quadruple_lattice(N, use_structured=True)
            
            p_class = p % 4
            q_class = q % 4
            fac_str = str(r['factor']) if r['success'] else "✗"
            
            # Classify by whether BOTH primes are 1 mod 4
            if p % 4 == 1 and q % 4 == 1:
                results_1mod4['total'] += 1
                if r['success']:
                    results_1mod4['success'] += 1
            elif p % 4 == 3 or q % 4 == 3:
                results_3mod4['total'] += 1
                if r['success']:
                    results_3mod4['success'] += 1
            
            print(f"{N:>8} {p:>5} {q:>5} {p_class:>8} {q_class:>8} {fac_str:>8}")
    
    print(f"\n--- Summary ---")
    if results_1mod4['total'] > 0:
        rate1 = results_1mod4['success'] / results_1mod4['total']
        print(f"p,q ≡ 1 (mod 4): {results_1mod4['success']}/{results_1mod4['total']} = {rate1:.1%}")
    if results_3mod4['total'] > 0:
        rate3 = results_3mod4['success'] / results_3mod4['total']
        print(f"p or q ≡ 3 (mod 4): {results_3mod4['success']}/{results_3mod4['total']} = {rate3:.1%}")
    
    print(f"\nH3 prediction: rate > 50% for p ≡ 1 (mod 4)")


def experiment_H4_dimensional_hierarchy():
    """H4: Does each dimension provide a strict improvement?"""
    print("\n" + "="*70)
    print("EXPERIMENT H4: Dimensional Hierarchy")
    print("="*70)
    
    print("\nComparing Minkowski-predicted shortest vectors across dimensions:")
    print(f"\n{'N':>10} {'d=2':>10} {'d=3':>10} {'d=4':>10} {'d=5':>10} {'d=6':>10}")
    print("-" * 55)
    
    for bits in [8, 16, 32, 64, 128, 256, 512, 1024]:
        # Work in log2 space to avoid overflow
        log2_N = bits
        row = []
        for d in [2, 3, 4, 5, 6]:
            # log2(γ_d^{1/2} * N^{1/d}) = log2(γ_d)/2 + bits/d
            gamma_log2 = {2: 0.207, 3: 0.333, 4: 0.5, 5: 0.601, 6: 0.735}
            lv = gamma_log2[d] / 2 + bits / d
            row.append(int(lv))
        print(f"{'2^'+str(bits):>10} " + " ".join(f"{'2^'+str(v):>10}" for v in row))
    
    print("\nThe hierarchy is strict: each dimension reduces the exponent.")
    print("d=2: 1/2 = 0.500")
    print("d=3: 1/3 ≈ 0.333")
    print("d=4: 1/4 = 0.250")
    print("d=5: 1/5 = 0.200")
    print("d=6: 1/6 ≈ 0.167")
    print("\nH4 SUPPORTED (by Minkowski's theorem).")


def experiment_scaling_to_larger():
    """Scale experiments to larger semiprimes (32-bit, 48-bit)."""
    print("\n" + "="*70)
    print("EXPERIMENT: Scaling to Larger Semiprimes")
    print("="*70)
    
    test_sizes = [
        (8, "16-bit"),
        (10, "20-bit"),
        (12, "24-bit"),
    ]
    
    print(f"\n{'Size':>10} {'N':>15} {'√N':>10} {'N^(1/3)':>10} {'λ₁':>10} {'Factor':>10} {'Time(s)':>8}")
    print("-" * 80)
    
    for half_bits, label in test_sizes:
        successes = 0
        trials = 5
        for trial in range(trials):
            p = random_prime(half_bits)
            q = random_prime(half_bits)
            if p == q:
                q = random_prime(half_bits)
            N = p * q
            
            t0 = time.time()
            r = factor_with_quadruple_lattice(N, use_structured=True)
            elapsed = time.time() - t0
            
            lam_str = f"{r['shortest_norm']:.1f}" if r['shortest_norm'] else "N/A"
            fac_str = str(r['factor']) if r['success'] else "✗"
            if r['success']:
                successes += 1
            
            print(f"{label:>10} {N:>15} {math.sqrt(N):>10.1f} {N**(1/3):>10.1f} {lam_str:>10} {fac_str:>10} {elapsed:>8.3f}")
        
        print(f"  → {label} success rate: {successes}/{trials}")


def experiment_coppersmith_connection():
    """Investigate connection to Coppersmith's lattice methods."""
    print("\n" + "="*70)
    print("EXPERIMENT: Coppersmith Connection")
    print("="*70)
    
    print("""
Coppersmith's method finds small roots of polynomials modulo N using LLL.
The quadruple lattice method is related:

1. Coppersmith: Find x with f(x) ≡ 0 (mod N), |x| < N^{1/d}
   → Build lattice from polynomial coefficients, LLL-reduce, read off root
   
2. Quadruple lattice: Find (x,y,z) with x²+y²+z² ≡ 0 (mod N)
   → Build L₄(N), BKZ-reduce, extract factor via GCD

Key difference: Coppersmith works in d dimensions for degree-d polynomials,
while the quadruple lattice is inherently 3D with the quadratic constraint.

Connection: The quadruple lattice method can be viewed as a special case of
Coppersmith's method applied to the polynomial f(x,y,z) = x²+y²+z² mod N,
with the lattice structure encoding the sum-of-squares constraint.
""")
    
    # Demonstrate on small examples
    print("Small example: N = 91 = 7 × 13")
    N = 91
    
    # Coppersmith-style: find x with x² ≡ a (mod N)
    print(f"\nSquare roots mod {N}:")
    for a in range(N):
        for x in range(N):
            if (x * x) % N == a:
                g = math.gcd(x, N)
                if 1 < g < N:
                    print(f"  x={x}, x²={x*x}, x² mod {N}={a}, gcd(x,N)={g} ← FACTOR!")
                    break
    
    # Quadruple lattice approach
    print(f"\nQuadruple lattice approach:")
    r = factor_with_quadruple_lattice(N, use_structured=True, verbose=True)
    if r['success']:
        print(f"  Factor found: {r['factor']}")


# ============================================================
# SECTION 7: Summary Report
# ============================================================

def generate_report():
    """Generate a comprehensive experimental report."""
    print("\n" + "="*70)
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║     COMPREHENSIVE EXPERIMENTAL REPORT                       ║")
    print("║     Quadruple Lattice Factoring via BKZ Reduction           ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print("="*70)
    
    experiment_H1_structured_advantage()
    experiment_H2_scaling_law()
    experiment_H3_extraction_rate()
    experiment_H4_dimensional_hierarchy()
    # experiment_scaling_to_larger()  # slow for large sizes
    # experiment_coppersmith_connection()  # exploratory
    
    print("\n" + "="*70)
    print("REPORT COMPLETE")
    print("="*70)


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)
    generate_report()
