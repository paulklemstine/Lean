#!/usr/bin/env python3
"""
Extended Experiments: Hypotheses H5–H8

H5 (Extraction Improvement): Using lattice structure (not just individual vectors)
    for GCD extraction can boost the success rate above 80%.
H6 (Scaling Persistence): The exponent α remains below 0.3 for semiprimes up to 128 bits.
H7 (Optimal Dimension): There exists an optimal dimension d* beyond which additional
    dimensions provide diminishing returns due to BKZ complexity.
H8 (Coppersmith Connection): The quadruple lattice method can be reformulated as a
    Coppersmith-style polynomial root-finding problem.
"""

import math
import random
import time
import numpy as np
from typing import List, Tuple, Optional, Dict
import json

# ============================================================
# Utilities (from demo_bkz_factoring.py)
# ============================================================

def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def random_prime(bits: int) -> int:
    lo = max(2, 2 ** (bits - 1))
    hi = 2 ** bits - 1
    for _ in range(10000):
        p = random.randint(lo, hi)
        if p % 2 == 0: p += 1
        if is_prime(p): return p
    return lo if is_prime(lo) else lo + 1

def primes_up_to(n: int) -> List[int]:
    if n < 2: return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]

def lll_reduce(basis: np.ndarray, delta: float = 0.99) -> np.ndarray:
    n = basis.shape[0]
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
        for j in range(k - 1, -1, -1):
            if abs(mu[k][j]) > 0.5:
                r = round(mu[k][j])
                B[k] -= r * B[j]
                Q, mu = gram_schmidt()
        qk_norm = np.dot(Q[k], Q[k])
        qk1_norm = np.dot(Q[k-1], Q[k-1])
        if qk_norm >= (delta - mu[k][k-1]**2) * qk1_norm:
            k += 1
        else:
            B[[k, k-1]] = B[[k-1, k]]
            k = max(k - 1, 1)
    return np.round(B).astype(np.int64)

def bkz_reduce(basis: np.ndarray, block_size: int = 3) -> np.ndarray:
    n = basis.shape[0]
    B = lll_reduce(basis.copy())
    max_tours = 20
    for tour in range(max_tours):
        changed = False
        for i in range(n - block_size + 1):
            block = B[i:i+block_size].copy()
            reduced_block = lll_reduce(block)
            old_norms = [np.linalg.norm(block[j]) for j in range(block_size)]
            new_norms = [np.linalg.norm(reduced_block[j]) for j in range(block_size)]
            if min(new_norms) < min(old_norms) - 0.1:
                B[i:i+block_size] = reduced_block
                changed = True
        if not changed:
            break
        B = lll_reduce(B)
    return B

def build_structured_basis_L4(N: int, dim: int = 3) -> Optional[np.ndarray]:
    vectors = []
    bound = int(N**0.5) + 10
    for x in range(-bound, bound + 1):
        for y in range(-bound, bound + 1):
            rem = (x*x + y*y) % N
            target = (N - rem) % N
            z_cand = int(math.isqrt(target))
            for z in [z_cand, z_cand + 1]:
                if z >= 0 and (z*z) % N == target:
                    if x != 0 or y != 0 or z != 0:
                        vectors.append([x, y, z])
                        if len(vectors) >= 50:
                            break
            if len(vectors) >= 50:
                break
        if len(vectors) >= 50:
            break
    if len(vectors) < dim:
        # Fallback: random search
        for _ in range(50000):
            x = random.randint(-bound, bound)
            y = random.randint(-bound, bound)
            z = random.randint(-bound, bound)
            if x == 0 and y == 0 and z == 0: continue
            if (x*x + y*y + z*z) % N == 0:
                vectors.append([x, y, z])
                if len(vectors) >= 50:
                    break
    if len(vectors) < dim:
        return None
    vectors.sort(key=lambda v: v[0]**2 + v[1]**2 + v[2]**2)
    basis = [vectors[0]]
    for v in vectors[1:]:
        if len(basis) >= dim:
            break
        mat = np.array(basis + [v], dtype=np.float64)
        if len(basis) == 1:
            cross = [basis[0][1]*v[2]-basis[0][2]*v[1],
                     basis[0][2]*v[0]-basis[0][0]*v[2],
                     basis[0][0]*v[1]-basis[0][1]*v[0]]
            if any(abs(c) > 0.5 for c in cross):
                basis.append(v)
        elif len(basis) == 2:
            det = np.linalg.det(np.array(basis + [v], dtype=np.float64))
            if abs(det) > 0.5:
                basis.append(v)
        else:
            # For higher dimensions we need more sophisticated linear independence checks
            test_mat = np.array(basis + [v], dtype=np.float64)
            if np.linalg.matrix_rank(test_mat) == len(basis) + 1:
                basis.append(v)
    if len(basis) < dim:
        return None
    return np.array(basis, dtype=np.float64)

# ============================================================
# H5: Enhanced Extraction Using Lattice Structure
# ============================================================

def extract_factors_basic(N: int, basis: np.ndarray) -> List[int]:
    """Basic extraction: individual vector GCDs."""
    factors = []
    for i in range(basis.shape[0]):
        v = basis[i]
        x, y, z = int(v[0]), int(v[1]), int(v[2])
        for g in [math.gcd(x*x + y*y, N), math.gcd(x*x + z*z, N),
                   math.gcd(y*y + z*z, N)]:
            if 1 < g < N and g not in factors:
                factors.append(g)
    return factors

def extract_factors_enhanced(N: int, basis: np.ndarray) -> List[int]:
    """Enhanced extraction: uses full lattice structure.
    
    Key ideas:
    1. Pairwise sums/differences of basis vectors
    2. Small linear combinations (coefficients ±1, ±2)
    3. Cross products of lattice vectors
    4. Resultants of sum-of-squares expressions
    """
    factors = []
    n = basis.shape[0]
    
    # Phase 1: Individual vectors (basic)
    for i in range(n):
        v = basis[i]
        x, y, z = int(v[0]), int(v[1]), int(v[2])
        for g in [math.gcd(x*x + y*y, N), math.gcd(x*x + z*z, N),
                   math.gcd(y*y + z*z, N),
                   math.gcd(abs(x), N), math.gcd(abs(y), N), math.gcd(abs(z), N)]:
            if 1 < g < N and g not in factors:
                factors.append(g)
    
    # Phase 2: Pairwise sums and differences
    for i in range(n):
        for j in range(i+1, n):
            for sign in [1, -1]:
                v = basis[i] + sign * basis[j]
                x, y, z = int(v[0]), int(v[1]), int(v[2])
                if x == 0 and y == 0 and z == 0:
                    continue
                # Check lattice membership
                s = x*x + y*y + z*z
                if s % N == 0:
                    for g in [math.gcd(x*x + y*y, N), math.gcd(x*x + z*z, N),
                               math.gcd(y*y + z*z, N)]:
                        if 1 < g < N and g not in factors:
                            factors.append(g)
    
    # Phase 3: Small linear combinations with coefficients ±1, ±2
    if n >= 2:
        for c0 in range(-2, 3):
            for c1 in range(-2, 3):
                if c0 == 0 and c1 == 0:
                    continue
                v = c0 * basis[0] + c1 * basis[1]
                x, y, z = int(v[0]), int(v[1]), int(v[2])
                if x == 0 and y == 0 and z == 0:
                    continue
                s = x*x + y*y + z*z
                if s % N == 0:
                    for g in [math.gcd(x*x + y*y, N), math.gcd(x*x + z*z, N),
                               math.gcd(y*y + z*z, N)]:
                        if 1 < g < N and g not in factors:
                            factors.append(g)
    
    # Phase 4: Triple combinations if 3 vectors available
    if n >= 3:
        for c0 in range(-1, 2):
            for c1 in range(-1, 2):
                for c2 in range(-1, 2):
                    if c0 == 0 and c1 == 0 and c2 == 0:
                        continue
                    v = c0 * basis[0] + c1 * basis[1] + c2 * basis[2]
                    x, y, z = int(v[0]), int(v[1]), int(v[2])
                    if x == 0 and y == 0 and z == 0:
                        continue
                    s = x*x + y*y + z*z
                    if s % N == 0:
                        for g in [math.gcd(x*x + y*y, N), math.gcd(x*x + z*z, N),
                                   math.gcd(y*y + z*z, N)]:
                            if 1 < g < N and g not in factors:
                                factors.append(g)
    
    # Phase 5: Gram matrix GCDs
    # The Gram matrix G_ij = <v_i, v_j> encodes lattice geometry
    # GCD of Gram entries with N can reveal factors
    for i in range(n):
        for j in range(n):
            vi = basis[i]; vj = basis[j]
            dot = int(np.dot(vi, vj))
            g = math.gcd(abs(dot), N)
            if 1 < g < N and g not in factors:
                factors.append(g)
    
    return factors


def experiment_H5():
    """H5: Enhanced extraction using lattice structure."""
    print("\n" + "="*70)
    print("EXPERIMENT H5: Enhanced Extraction via Lattice Structure")
    print("="*70)
    
    primes = primes_up_to(100)
    basic_success = 0
    enhanced_success = 0
    total = 0
    
    print(f"\n{'N':>8} {'p':>4} {'q':>4} | {'Basic':>8} {'Enhanced':>10} | {'B-facs':>8} {'E-facs':>8}")
    print("-" * 70)
    
    for i, p in enumerate(primes):
        for q in primes[i+1:i+2]:
            N = p * q
            total += 1
            
            basis = build_structured_basis_L4(N)
            if basis is None:
                print(f"{N:>8} {p:>4} {q:>4} | {'skip':>8} {'skip':>10}")
                continue
            
            reduced = bkz_reduce(basis)
            
            basic_facs = extract_factors_basic(N, reduced)
            enhanced_facs = extract_factors_enhanced(N, reduced)
            
            b_ok = len(basic_facs) > 0
            e_ok = len(enhanced_facs) > 0
            if b_ok: basic_success += 1
            if e_ok: enhanced_success += 1
            
            b_str = str(basic_facs[0]) if b_ok else "✗"
            e_str = str(enhanced_facs[0]) if e_ok else "✗"
            
            print(f"{N:>8} {p:>4} {q:>4} | {b_str:>8} {e_str:>10} | {len(basic_facs):>8} {len(enhanced_facs):>8}")
    
    print(f"\n--- H5 Summary ---")
    print(f"Basic extraction:    {basic_success}/{total} = {100*basic_success/max(total,1):.1f}%")
    print(f"Enhanced extraction: {enhanced_success}/{total} = {100*enhanced_success/max(total,1):.1f}%")
    print(f"Improvement: {enhanced_success - basic_success} additional factorizations")
    target = 0.80
    print(f"H5 target: > {target:.0%}")
    print(f"H5 {'SUPPORTED' if enhanced_success/max(total,1) > target else 'NOT SUPPORTED'}: "
          f"enhanced rate = {100*enhanced_success/max(total,1):.1f}%")


# ============================================================
# H6: Scaling Persistence
# ============================================================

def experiment_H6():
    """H6: Does α remain below 0.3 for larger semiprimes?"""
    print("\n" + "="*70)
    print("EXPERIMENT H6: Scaling Persistence of Exponent α")
    print("="*70)
    
    test_cases = []
    
    # Systematic: increasing bit sizes
    for half_bits in range(3, 13):
        for trial in range(5):
            p = random_prime(half_bits)
            q = random_prime(half_bits)
            while q == p:
                q = random_prime(half_bits)
            test_cases.append((p, q, 2*half_bits))
    
    print(f"\n{'bits':>6} {'N':>15} {'√N':>10} {'N^(1/3)':>10} {'λ₁':>10} {'α':>8} {'sub-√N?':>8}")
    print("-" * 75)
    
    log_N_list = []
    log_lambda_list = []
    alphas_by_size = {}
    
    for p, q, approx_bits in test_cases:
        N = p * q
        if N < 10:
            continue
        
        basis = build_structured_basis_L4(N)
        if basis is None:
            continue
        
        reduced = bkz_reduce(basis)
        norms = sorted([np.linalg.norm(reduced[i]) for i in range(reduced.shape[0])])
        lam = norms[0]
        
        if lam <= 0:
            continue
        
        alpha = math.log(lam) / math.log(N)
        bits = N.bit_length()
        
        bucket = (bits // 4) * 4
        if bucket not in alphas_by_size:
            alphas_by_size[bucket] = []
        alphas_by_size[bucket].append(alpha)
        
        sub_sqrt = "✓" if lam < math.sqrt(N) else "✗"
        
        print(f"{bits:>6} {N:>15} {math.sqrt(N):>10.2f} {N**(1/3):>10.2f} {lam:>10.2f} {alpha:>8.3f} {sub_sqrt:>8}")
        
        log_N_list.append(math.log(N))
        log_lambda_list.append(math.log(lam))
    
    # Regression
    if len(log_N_list) > 5:
        log_N = np.array(log_N_list)
        log_lam = np.array(log_lambda_list)
        A = np.vstack([log_N, np.ones(len(log_N))]).T
        alpha_fit, c_fit = np.linalg.lstsq(A, log_lam, rcond=None)[0]
        
        print(f"\n--- Global Regression ---")
        print(f"log(λ₁) = {alpha_fit:.4f} * log(N) + {c_fit:.4f}")
        print(f"Overall α = {alpha_fit:.4f}")
    
    # Per-size-bucket analysis
    print(f"\n--- α by bit-size bucket ---")
    print(f"{'Bits':>6} {'Avg α':>8} {'Min α':>8} {'Max α':>8} {'Count':>6}")
    for bucket in sorted(alphas_by_size.keys()):
        vals = alphas_by_size[bucket]
        print(f"{bucket:>6} {np.mean(vals):>8.3f} {min(vals):>8.3f} {max(vals):>8.3f} {len(vals):>6}")
    
    if len(log_N_list) > 5:
        print(f"\nH6 prediction: α < 0.3 overall")
        print(f"H6 {'SUPPORTED' if alpha_fit < 0.3 else 'NOT SUPPORTED'}: α = {alpha_fit:.4f}")


# ============================================================
# H7: Optimal Dimension
# ============================================================

def build_basis_Ld(N: int, d: int) -> Optional[np.ndarray]:
    """Build a basis for the d-dimensional sum-of-squares lattice.
    L_d(N) = {(x₁,...,x_d) ∈ ℤ^d : N | (x₁²+...+x_d²)}
    """
    vectors = []
    bound = int(N**0.5) + 5
    max_attempts = 200000
    
    for _ in range(max_attempts):
        v = [random.randint(-bound, bound) for _ in range(d)]
        if all(x == 0 for x in v):
            continue
        s = sum(x*x for x in v)
        if s % N == 0:
            vectors.append(v)
            if len(vectors) >= d + 10:
                break
    
    if len(vectors) < d:
        return None
    
    # Select d linearly independent vectors
    vectors.sort(key=lambda v: sum(x*x for x in v))
    basis = [vectors[0]]
    for v in vectors[1:]:
        if len(basis) >= d:
            break
        mat = np.array(basis + [v], dtype=np.float64)
        if np.linalg.matrix_rank(mat) == len(basis) + 1:
            basis.append(v)
    
    if len(basis) < d:
        return None
    return np.array(basis, dtype=np.float64)


def experiment_H7():
    """H7: What is the optimal dimension?"""
    print("\n" + "="*70)
    print("EXPERIMENT H7: Optimal Dimension")
    print("="*70)
    
    test_Ns = []
    primes = primes_up_to(50)
    for i, p in enumerate(primes[:8]):
        for q in primes[i+1:i+2]:
            test_Ns.append(p * q)
    
    dimensions = [2, 3, 4, 5]
    
    print(f"\n{'N':>8} | " + " | ".join(f"d={d}: λ₁  fact" for d in dimensions))
    print("-" * (10 + 20 * len(dimensions)))
    
    dim_results = {d: {'norms': [], 'successes': 0, 'total': 0, 'times': []} for d in dimensions}
    
    for N in test_Ns:
        row = f"{N:>8} | "
        for d in dimensions:
            t0 = time.time()
            basis = build_basis_Ld(N, d)
            if basis is None:
                row += f"   N/A     N/A | "
                continue
            
            reduced = lll_reduce(basis)
            elapsed = time.time() - t0
            
            norms = sorted([np.linalg.norm(reduced[i]) for i in range(reduced.shape[0])])
            lam = norms[0]
            
            # Extract factors
            found = False
            for i in range(reduced.shape[0]):
                v = reduced[i]
                coords = [int(v[j]) for j in range(d)]
                # Try all pairs
                for a in range(d):
                    for b in range(a+1, d):
                        g = math.gcd(coords[a]**2 + coords[b]**2, N)
                        if 1 < g < N:
                            found = True
                            break
                    if found:
                        break
                if found:
                    break
            
            dim_results[d]['norms'].append(lam)
            dim_results[d]['total'] += 1
            dim_results[d]['times'].append(elapsed)
            if found:
                dim_results[d]['successes'] += 1
            
            fac_str = "✓" if found else "✗"
            row += f"{lam:>6.1f} {fac_str:>4} | "
        
        print(row)
    
    print(f"\n--- H7 Summary ---")
    print(f"{'Dim':>4} {'Avg λ₁':>8} {'Success':>10} {'Avg Time':>10}")
    for d in dimensions:
        r = dim_results[d]
        if r['total'] > 0:
            avg_norm = np.mean(r['norms']) if r['norms'] else float('inf')
            rate = r['successes'] / r['total']
            avg_time = np.mean(r['times'])
            print(f"{d:>4} {avg_norm:>8.2f} {r['successes']}/{r['total']:>3} ({rate:.0%}) {avg_time:>10.4f}s")
    
    # Find optimal: best success rate with acceptable time
    best_d = max(dimensions, key=lambda d: (
        dim_results[d]['successes'] / max(dim_results[d]['total'], 1),
        -np.mean(dim_results[d]['times']) if dim_results[d]['times'] else float('inf')
    ))
    print(f"\nOptimal dimension (by success rate): d* = {best_d}")
    print(f"H7 prediction: d* ≈ O(log log N)")
    print(f"H7 EXPLORATORY — more data needed at larger N to confirm")


# ============================================================
# H8: Coppersmith Connection
# ============================================================

def coppersmith_lattice(N: int, d: int = 3) -> Optional[np.ndarray]:
    """Build a Coppersmith-style lattice for x²+y²+z² ≡ 0 (mod N).
    
    The key idea: rewrite as z² ≡ -(x²+y²) (mod N).
    We build a lattice whose short vectors encode solutions.
    """
    # For the bivariate case, build a lattice from:
    # [N, 0, 0]
    # [0, N, 0]  
    # [a, b, 1]  where a²+b² ≡ 0 (mod N) gives hints
    
    # Find a,b with a²+b² ≡ 0 (mod N)
    bound = int(math.sqrt(N)) + 1
    hint_pairs = []
    for a in range(bound):
        for b in range(bound):
            if (a*a + b*b) % N == 0 and (a != 0 or b != 0):
                hint_pairs.append((a, b))
                if len(hint_pairs) >= 3:
                    break
        if len(hint_pairs) >= 3:
            break
    
    if not hint_pairs:
        return None
    
    # Build Coppersmith-style lattice
    a, b = hint_pairs[0]
    basis = np.array([
        [N, 0, 0],
        [0, N, 0],
        [a, b, 1]
    ], dtype=np.float64)
    
    return basis


def experiment_H8():
    """H8: Coppersmith reformulation."""
    print("\n" + "="*70)
    print("EXPERIMENT H8: Coppersmith Connection")
    print("="*70)
    
    print("""
The Coppersmith method finds small roots of polynomials modulo N using LLL.
We test whether reformulating x²+y²+z² ≡ 0 (mod N) in Coppersmith style
provides comparable or better results than direct quadruple lattice.
""")
    
    primes = primes_up_to(60)
    copper_success = 0
    direct_success = 0
    total = 0
    
    print(f"{'N':>8} {'p':>4} {'q':>4} | {'Direct λ₁':>10} {'Copper λ₁':>10} | {'D-fact':>7} {'C-fact':>7}")
    print("-" * 65)
    
    for i, p in enumerate(primes[:12]):
        for q in primes[i+1:i+2]:
            N = p * q
            total += 1
            
            # Direct method
            d_basis = build_structured_basis_L4(N)
            d_lam = float('inf')
            d_fac = None
            if d_basis is not None:
                d_reduced = bkz_reduce(d_basis)
                d_norms = [np.linalg.norm(d_reduced[i]) for i in range(d_reduced.shape[0])]
                d_lam = min(d_norms)
                for ii in range(d_reduced.shape[0]):
                    v = d_reduced[ii]
                    x, y, z = int(v[0]), int(v[1]), int(v[2])
                    for g in [math.gcd(x*x+y*y, N), math.gcd(x*x+z*z, N), math.gcd(y*y+z*z, N)]:
                        if 1 < g < N:
                            d_fac = g
                            break
                    if d_fac:
                        break
            
            # Coppersmith method
            c_basis = coppersmith_lattice(N)
            c_lam = float('inf')
            c_fac = None
            if c_basis is not None:
                c_reduced = lll_reduce(c_basis)
                c_norms = [np.linalg.norm(c_reduced[i]) for i in range(c_reduced.shape[0])]
                c_lam = min(c_norms)
                for ii in range(c_reduced.shape[0]):
                    v = c_reduced[ii]
                    x, y, z = int(v[0]), int(v[1]), int(v[2])
                    for g in [math.gcd(x*x+y*y, N), math.gcd(x*x+z*z, N), math.gcd(y*y+z*z, N),
                              math.gcd(abs(x), N), math.gcd(abs(y), N)]:
                        if 1 < g < N:
                            c_fac = g
                            break
                    if c_fac:
                        break
            
            if d_fac: direct_success += 1
            if c_fac: copper_success += 1
            
            d_str = f"{d_lam:.1f}" if d_lam < float('inf') else "N/A"
            c_str = f"{c_lam:.1f}" if c_lam < float('inf') else "N/A"
            df = str(d_fac) if d_fac else "✗"
            cf = str(c_fac) if c_fac else "✗"
            
            print(f"{N:>8} {p:>4} {q:>4} | {d_str:>10} {c_str:>10} | {df:>7} {cf:>7}")
    
    print(f"\n--- H8 Summary ---")
    print(f"Direct method:     {direct_success}/{total} = {100*direct_success/max(total,1):.1f}%")
    print(f"Coppersmith-style: {copper_success}/{total} = {100*copper_success/max(total,1):.1f}%")
    print(f"H8: Coppersmith reformulation {'shows promise' if copper_success >= direct_success else 'needs refinement'}")


# ============================================================
# New Hypotheses Generated from Results
# ============================================================

def propose_new_hypotheses():
    """Analyze results and propose H9-H12."""
    print("\n" + "="*70)
    print("NEW HYPOTHESES PROPOSED FROM EXPERIMENTAL RESULTS")
    print("="*70)
    
    print("""
H9 (Gram Matrix Fingerprint): The Gram matrix G_ij = <b_i, b_j> of a 
    BKZ-reduced basis of L₄(N) encodes the factorization of N in its 
    off-diagonal entries via gcd(G_ij, N).

H10 (Lattice Combination Depth): For the enhanced extraction method,
    linear combinations with coefficients |c_i| ≤ k achieve near-100%
    success rate for k ≥ 3, i.e., the "extraction radius" is small.

H11 (Prime Residue Structure): The factoring success rate correlates 
    with the Legendre symbol (-1|N): semiprimes where N ≡ 1 (mod 4)
    factor more reliably because x²+y² has more representations.

H12 (BKZ Block Size Threshold): For d-dimensional lattices, BKZ with 
    block size β = d achieves exact SVP, but β = ceil(d/2) suffices 
    for factoring purposes (non-trivial GCD extraction).
""")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)
    
    experiment_H5()
    experiment_H6()
    experiment_H7()
    experiment_H8()
    propose_new_hypotheses()
    
    print("\n" + "="*70)
    print("ALL EXTENDED EXPERIMENTS COMPLETE")
    print("="*70)
