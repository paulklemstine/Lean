#!/usr/bin/env python3
"""
Demo 5: p-adic Convergence & Finite Field Periodicity

Hypothesis 5: The Berggren tree modulo p has period dividing p² - 1,
connecting oracle theory to finite field arithmetic.

We test:
1. Periodicity of the Berggren tree mod p for small primes
2. Structure of the tree over F_p
3. Connection to the multiplicative group F_p²*
4. p-adic valuations of hypotenuses

Author: Meta-Oracle Research Program
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict
import os
from math import gcd

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'figures')
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Berggren matrices (integer)
B1 = np.array([[ 1, -2,  2], [ 2, -1,  2], [ 2, -2,  3]])
B2 = np.array([[ 1,  2,  2], [ 2,  1,  2], [ 2,  2,  3]])
B3 = np.array([[-1,  2,  2], [-2,  1,  2], [-2,  2,  3]])
MATRICES = [B1, B2, B3]
MATRIX_NAMES = ['B₁', 'B₂', 'B₃']


def mat_mod(M, p):
    """Matrix modulo p."""
    return M % p


def mat_mul_mod(A, B, p):
    """Matrix multiplication modulo p."""
    return (A @ B) % p


def mat_pow_mod(M, n, p):
    """Matrix power modulo p using repeated squaring."""
    size = M.shape[0]
    result = np.eye(size, dtype=int) % p
    base = M % p
    while n > 0:
        if n % 2 == 1:
            result = mat_mul_mod(result, base, p)
        base = mat_mul_mod(base, base, p)
        n //= 2
    return result


def find_matrix_period_mod_p(M, p, max_iter=10000):
    """Find the smallest k such that M^k ≡ I (mod p)."""
    size = M.shape[0]
    identity = np.eye(size, dtype=int) % p
    M_mod = M % p
    
    current = M_mod.copy()
    for k in range(1, max_iter + 1):
        if np.array_equal(current, identity):
            return k
        current = mat_mul_mod(current, M_mod, p)
    
    return None  # No period found within max_iter


def find_triple_period_mod_p(M, triple, p, max_iter=10000):
    """Find the smallest k such that M^k · triple ≡ triple (mod p)."""
    t = np.array(triple) % p
    M_mod = M % p
    
    current = (M_mod @ t) % p
    for k in range(1, max_iter + 1):
        if np.array_equal(current, t):
            return k
        current = (M_mod @ current) % p
    
    return None


def analyze_periods():
    """Find periods of each Berggren matrix mod p for various primes."""
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    
    print("══════ MATRIX PERIODS MOD p ══════")
    print(f"{'p':>4} {'p²-1':>7} | ", end='')
    for name in MATRIX_NAMES:
        print(f'{name:>8}', end=' ')
    print(f"| {'All divide p²-1?':>18}")
    print("-" * 65)
    
    period_data = defaultdict(list)
    divides_count = 0
    total_count = 0
    
    for p in primes:
        p2m1 = p * p - 1
        periods = []
        all_divide = True
        
        for M in MATRICES:
            period = find_matrix_period_mod_p(M, p)
            periods.append(period)
            if period is not None:
                if p2m1 % period != 0:
                    all_divide = False
            period_data[p].append(period)
        
        print(f"{p:>4} {p2m1:>7} | ", end='')
        for per in periods:
            if per is not None:
                print(f"{per:>8}", end=' ')
            else:
                print(f"{'??':>8}", end=' ')
        total_count += 1
        if all_divide:
            divides_count += 1
        print(f"| {'✓ YES' if all_divide else '✗ NO':>18}")
    
    print(f"\nHypothesis confirmed for {divides_count}/{total_count} primes tested")
    
    return primes, period_data


def analyze_triple_orbits(p=7):
    """Analyze orbit structure of triples mod p."""
    print(f"\n══════ ORBIT STRUCTURE MOD {p} ══════")
    
    triple = np.array([3, 4, 5])
    
    for M, name in zip(MATRICES, MATRIX_NAMES):
        orbit = []
        t = np.array(triple) % p
        orbit.append(tuple(t))
        current = (M % p @ t) % p
        
        steps = 0
        while not np.array_equal(current, t) and steps < 200:
            orbit.append(tuple(current))
            current = ((M % p) @ current) % p
            steps += 1
        
        print(f"\n  {name} orbit of (3,4,5) mod {p} (period={len(orbit)}):")
        for i, o in enumerate(orbit):
            a, b, c = o
            check = (a**2 + b**2) % p == (c**2) % p
            print(f"    Step {i}: {o}  a²+b²≡c²? {'✓' if check else '✗'} (mod {p})")


def plot_period_analysis(primes, period_data):
    """Visualize the period structure."""
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    
    # 1. Periods vs p²-1
    ax = axes[0][0]
    for i, (name, color) in enumerate(zip(MATRIX_NAMES, ['#e74c3c', '#2ecc71', '#3498db'])):
        periods = [period_data[p][i] for p in primes if period_data[p][i] is not None]
        valid_primes = [p for p in primes if period_data[p][i] is not None]
        ax.scatter(valid_primes, periods, s=80, c=color, label=name, zorder=5, edgecolors='black')
    
    ax.plot(primes, [p**2 - 1 for p in primes], 'k--', alpha=0.4, label='p²-1')
    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_ylabel('Matrix Order mod p', fontsize=12)
    ax.set_title('Matrix Period vs p² - 1', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # 2. Period / (p²-1) ratio
    ax = axes[0][1]
    for i, (name, color) in enumerate(zip(MATRIX_NAMES, ['#e74c3c', '#2ecc71', '#3498db'])):
        ratios = []
        valid_primes = []
        for p in primes:
            per = period_data[p][i]
            if per is not None and per > 0:
                ratios.append((p**2 - 1) / per)
                valid_primes.append(p)
        ax.scatter(valid_primes, ratios, s=80, c=color, label=name, zorder=5, edgecolors='black')
    
    ax.set_xlabel('Prime p', fontsize=12)
    ax.set_ylabel('(p²-1) / period', fontsize=12)
    ax.set_title('Divisibility Factor', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # 3. p-adic valuations of hypotenuses in the tree
    ax = axes[1][0]
    # Generate many triples and look at p-adic valuations
    from collections import deque
    root = np.array([3, 4, 5])
    hypotenuses = []
    queue = deque([(root, 0)])
    while queue:
        t, d = queue.popleft()
        if d > 10:
            continue
        hypotenuses.append(int(t[2]))
        for M in MATRICES:
            child = M @ t
            if all(x > 0 for x in child):
                queue.append((child, d + 1))
    
    # p-adic valuation for p=2,3,5
    for p, color in [(2, '#e74c3c'), (3, '#2ecc71'), (5, '#3498db')]:
        vals = []
        for h in hypotenuses[:200]:
            v = 0
            n = h
            while n % p == 0:
                v += 1
                n //= p
            vals.append(v)
        ax.hist(vals, bins=range(max(vals)+2), alpha=0.5, color=color, 
               label=f'v_{p}(c)', edgecolor='white')
    
    ax.set_xlabel(f'p-adic valuation', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('p-adic Valuations of Hypotenuses', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # 4. Tree mod p visualization (heatmap)
    ax = axes[1][1]
    p = 7
    # Create heatmap of (a mod p, b mod p) occurrences
    grid = np.zeros((p, p))
    for h_idx, h in enumerate(hypotenuses[:500]):
        # Get the triple
        pass
    
    # Instead: show period as function of p
    all_periods = []
    test_primes = list(range(2, 50))
    for tp in test_primes:
        if all(tp % i != 0 for i in range(2, int(tp**0.5)+1)) and tp > 1:
            per = find_matrix_period_mod_p(B2, tp)
            if per:
                all_periods.append((tp, per, tp**2-1))
    
    if all_periods:
        ps, pers, p2m1s = zip(*all_periods)
        ax.bar(range(len(ps)), pers, color='#3498db', alpha=0.7, label='Period of B₂')
        ax.bar(range(len(ps)), p2m1s, color='#e74c3c', alpha=0.3, label='p²-1')
        ax.set_xticks(range(len(ps)))
        ax.set_xticklabels([str(p) for p in ps], rotation=45, fontsize=8)
        ax.set_xlabel('Prime p', fontsize=12)
        ax.set_ylabel('Period', fontsize=12)
        ax.set_title('B₂ Period vs p²-1', fontsize=14, fontweight='bold')
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3, axis='y')
    
    plt.suptitle('p-adic Analysis of the Berggren Tree', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'padic_analysis.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved padic_analysis.png")


def gf_structure(p=5):
    """Analyze the Berggren matrices over GF(p)."""
    print(f"\n══════ STRUCTURE OVER GF({p}) ══════")
    
    for M, name in zip(MATRICES, MATRIX_NAMES):
        M_mod = M % p
        print(f"\n  {name} mod {p}:")
        print(f"    {M_mod}")
        
        # Characteristic polynomial coefficients
        det = int(round(np.linalg.det(M_mod.astype(float)))) % p
        tr = int(np.trace(M_mod)) % p
        print(f"    det ≡ {det} (mod {p})")
        print(f"    tr  ≡ {tr} (mod {p})")
        
        # Order in GL(3, F_p)
        period = find_matrix_period_mod_p(M, p)
        gl3_order = (p**3 - 1) * (p**3 - p) * (p**3 - p**2)
        print(f"    order = {period}")
        print(f"    |GL(3,F_{p})| = {gl3_order}")
        if period and gl3_order % period == 0:
            print(f"    order divides |GL(3,F_{p})|: ✓")


if __name__ == '__main__':
    print("=" * 60)
    print("  p-ADIC CONVERGENCE & FINITE FIELD PERIODICITY")
    print("=" * 60)
    
    # 1. Period analysis
    primes, period_data = analyze_periods()
    
    # 2. Orbit analysis
    analyze_triple_orbits(p=7)
    
    # 3. Visualization
    plot_period_analysis(primes, period_data)
    
    # 4. GF structure
    gf_structure(p=5)
    
    print("\n✓ p-adic analysis complete!")
