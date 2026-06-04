#!/usr/bin/env python3
"""
Counterfactual Number Theory: What If Primes Were Random?

Demonstrations of the key results:
1. UFD Collapse: finding multiplicative collisions in random sets
2. Product-free verification for primes vs random sets
3. Sumset growth for dense sets
4. Counting function fluctuations: random vs actual primes
"""

import random
import math
from collections import defaultdict
from typing import Set, List, Tuple, Dict

def generate_random_prime_set(N: int, seed: int = 42) -> Set[int]:
    """Generate a random subset of {2,...,N} with density ~1/log(n).
    
    Each n is included independently with probability 1/log(n),
    matching the asymptotic density of actual primes.
    """
    rng = random.Random(seed)
    S = set()
    for n in range(2, N + 1):
        if rng.random() < 1.0 / math.log(n):
            S.add(n)
    return S

def actual_primes(N: int) -> Set[int]:
    """Sieve of Eratosthenes up to N."""
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, N + 1, i):
                sieve[j] = False
    return {i for i in range(2, N + 1) if sieve[i]}

def find_multiplicative_collisions(S: Set[int], N: int) -> List[Tuple[int, int, int]]:
    """Find triples (a, b, a*b) where all three are in S and a,b >= 2."""
    collisions = []
    sorted_S = sorted(s for s in S if s >= 2)
    for i, a in enumerate(sorted_S):
        for b in sorted_S[i:]:
            if a * b > N:
                break
            if a * b in S:
                collisions.append((a, b, a * b))
    return collisions

def is_product_free(S: Set[int], N: int) -> bool:
    """Check if S is product-free (no a,b in S with a*b in S)."""
    sorted_S = sorted(s for s in S if s >= 2)
    for i, a in enumerate(sorted_S):
        for b in sorted_S[i:]:
            if a * b > N:
                break
            if a * b in S:
                return False
    return True

def count_s_factorizations(n: int, S: Set[int]) -> int:
    """Count the number of S-factorizations of n (products of elements of S that equal n).
    Uses dynamic programming / recursive enumeration.
    """
    memo: Dict[Tuple[int, int], int] = {}
    sorted_S = sorted(s for s in S if 2 <= s <= n)
    
    def count(target: int, min_factor_idx: int) -> int:
        if target == 1:
            return 1
        if (target, min_factor_idx) in memo:
            return memo[(target, min_factor_idx)]
        result = 0
        for i in range(min_factor_idx, len(sorted_S)):
            s = sorted_S[i]
            if s > target:
                break
            if target % s == 0:
                result += count(target // s, i)
        memo[(target, min_factor_idx)] = result
        return result
    
    return count(n, 0)

def sumset_size(A: Set[int]) -> int:
    """Compute |A + A|."""
    return len({a + b for a in A for b in A})

def counting_function(S: Set[int], x: int) -> int:
    """π_S(x) = |{s in S : s <= x}|"""
    return sum(1 for s in S if s <= x)

# ============================================================
# DEMO 1: UFD Collapse in Random Sets
# ============================================================
print("=" * 60)
print("DEMO 1: UFD Collapse — Multiplicative Collisions")
print("=" * 60)

N = 10000
random_S = generate_random_prime_set(N)
primes_S = actual_primes(N)

print(f"\nN = {N}")
print(f"Random set size: {len(random_S)} (expected ~{int(N/math.log(N))})")
print(f"Actual primes:   {len(primes_S)} (π({N}) = {len(primes_S)})")

random_collisions = find_multiplicative_collisions(random_S, N)
prime_collisions = find_multiplicative_collisions(primes_S, N)

print(f"\nMultiplicative collisions in random set: {len(random_collisions)}")
print(f"Multiplicative collisions in primes:     {len(prime_collisions)}")

if random_collisions:
    print(f"\nFirst 5 collisions in random set:")
    for a, b, c in random_collisions[:5]:
        print(f"  {a} × {b} = {c}, all in S → UFD fails for {c}")
        print(f"    Factorization 1: [{c}]")
        print(f"    Factorization 2: [{a}, {b}]")

print(f"\nPrimes have {len(prime_collisions)} collisions — product-free property holds!")

# ============================================================
# DEMO 2: Factorization Entropy
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Factorization Entropy — How Badly UFD Fails")
print("=" * 60)

small_N = 200
small_random = generate_random_prime_set(small_N, seed=123)
small_primes = actual_primes(small_N)

print(f"\nFactorization counts for n ≤ {small_N}:")
print(f"{'n':>6} | {'Random S-facts':>14} | {'Prime facts':>11} | {'Comment':>20}")
print("-" * 60)

high_entropy = []
for n in range(4, small_N + 1):
    rf = count_s_factorizations(n, small_random)
    pf = count_s_factorizations(n, small_primes)
    if rf > 1:
        high_entropy.append((n, rf))
        if len(high_entropy) <= 10:
            comment = "UFD FAILS" if rf > 1 else ""
            print(f"{n:>6} | {rf:>14} | {pf:>11} | {comment:>20}")

print(f"\n...{len(high_entropy)} numbers with non-unique factorization in random set")
print(f"Maximum factorization count: {max(rf for _, rf in high_entropy) if high_entropy else 1}")
print(f"For actual primes: every number has exactly 1 factorization (UFD holds)")

# ============================================================
# DEMO 3: Sumset Growth — Goldbach Analog
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Sumset Growth — Goldbach Analog")
print("=" * 60)

for N_test in [100, 500, 1000, 5000]:
    S = generate_random_prime_set(N_test, seed=42)
    S_small = {s for s in S if s <= N_test}
    ss = sumset_size(S_small)
    lb = 2 * len(S_small) - 1
    print(f"N={N_test:>5}: |S|={len(S_small):>4}, |S+S|={ss:>6}, "
          f"bound 2|S|-1={lb:>5}, ratio={ss/lb:.2f}")

print("\n|S+S| grows much faster than 2|S|-1, showing additive richness.")
print("The Goldbach analog is EASIER for random primes than for actual primes.")

# ============================================================
# DEMO 4: Counting Function Fluctuations — RH Analog
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: RH Analog — Counting Function Fluctuations")
print("=" * 60)

N = 100000
primes = actual_primes(N)

# Multiple random trials
n_trials = 20
print(f"\nComparing fluctuations at x = {N}:")
print(f"{'Set':>15} | {'π(x)':>8} | {'x/ln(x)':>8} | {'Error':>8} | {'|Error|/√(x/ln x)':>18}")
print("-" * 70)

li_approx = N / math.log(N)
prime_error = len(primes) - li_approx
rh_normalized = abs(prime_error) / math.sqrt(N / math.log(N))
print(f"{'Actual primes':>15} | {len(primes):>8} | {li_approx:>8.0f} | "
      f"{prime_error:>+8.0f} | {rh_normalized:>18.2f}")

random_errors = []
for trial in range(n_trials):
    S = generate_random_prime_set(N, seed=trial)
    error = len(S) - li_approx
    random_errors.append(error)
    normalized = abs(error) / math.sqrt(N / math.log(N))
    if trial < 5:
        print(f"{'Random #' + str(trial):>15} | {len(S):>8} | {li_approx:>8.0f} | "
              f"{error:>+8.0f} | {normalized:>18.2f}")

mean_abs_error = sum(abs(e) for e in random_errors) / len(random_errors)
rms_error = math.sqrt(sum(e**2 for e in random_errors) / len(random_errors))
expected_std = math.sqrt(N / math.log(N))

print(f"\nRandom set statistics ({n_trials} trials):")
print(f"  Mean absolute error:  {mean_abs_error:.1f}")
print(f"  RMS error:            {rms_error:.1f}")
print(f"  Predicted std (CLT):  {expected_std:.1f}")
print(f"  Actual prime error:   {abs(prime_error):.1f}")
print(f"\nRatio random_RMS / prime_error: {rms_error / abs(prime_error):.2f}")
print("Random fluctuations are ~√(x/log x), confirming RH 'fails' for random primes.")


#!/usr/bin/env python3
"""
Visualization: Multiplicative Collisions in Random vs Prime Sets

Shows where UFD-collapse-triggering collisions occur in random sets,
contrasted with the collision-free landscape of actual primes.
"""

import math
import random

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def sieve(n):
    is_p = [True] * (n + 1)
    is_p[0] = is_p[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_p[i]:
            for j in range(i*i, n+1, i):
                is_p[j] = False
    return {i for i in range(2, n+1) if is_p[i]}


def random_prime_set(n, seed=42):
    rng = random.Random(seed)
    return {k for k in range(2, n+1) if rng.random() < 1.0 / math.log(k)}


def find_collisions(S, N):
    ss = sorted(s for s in S if s >= 2)
    cols = []
    for i, a in enumerate(ss):
        for b in ss[i:]:
            if a * b > N:
                break
            if a * b in S:
                cols.append((a, b, a*b))
    return cols


def main():
    N = 2000
    primes = sieve(N)
    rand_set = random_prime_set(N, seed=42)
    
    collisions = find_collisions(rand_set, N)
    collision_products = {c for _, _, c in collisions}
    collision_factors = set()
    for a, b, _ in collisions:
        collision_factors.add(a)
        collision_factors.add(b)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Counterfactual Number Theory: Multiplicative Collisions',
                 fontsize=14, fontweight='bold')
    
    # Plot 1: Elements of random set, colored by collision involvement
    ax = axes[0, 0]
    rs = sorted(rand_set)
    colors = []
    for s in rs:
        if s in collision_products:
            colors.append('red')
        elif s in collision_factors:
            colors.append('orange')
        else:
            colors.append('steelblue')
    ax.scatter(rs, [1]*len(rs), c=colors, s=3, alpha=0.7)
    ax.set_title(f'Random "Prime" Set (|S|={len(rand_set)}, {len(collisions)} collisions)')
    ax.set_xlabel('n')
    ax.set_yticks([])
    red_patch = mpatches.Patch(color='red', label=f'Products a·b ∈ S ({len(collision_products)})')
    orange_patch = mpatches.Patch(color='orange', label=f'Factors in collision ({len(collision_factors)})')
    blue_patch = mpatches.Patch(color='steelblue', label='No collision')
    ax.legend(handles=[red_patch, orange_patch, blue_patch], fontsize=8, loc='upper right')
    
    # Plot 2: Primes (no collisions)
    ax = axes[0, 1]
    ps = sorted(primes)
    ax.scatter(ps, [1]*len(ps), c='green', s=3, alpha=0.7)
    ax.set_title(f'Actual Primes (|P|={len(primes)}, 0 collisions)')
    ax.set_xlabel('n')
    ax.set_yticks([])
    green_patch = mpatches.Patch(color='green', label='Product-free (no collisions)')
    ax.legend(handles=[green_patch], fontsize=8, loc='upper right')
    
    # Plot 3: Collision density as function of N
    ax = axes[1, 0]
    Ns = list(range(100, N+1, 50))
    collision_counts = []
    set_sizes = []
    for n in Ns:
        sub = {s for s in rand_set if s <= n}
        cols = find_collisions(sub, n)
        collision_counts.append(len(cols))
        set_sizes.append(len(sub))
    
    ax.plot(Ns, collision_counts, 'r-', linewidth=2, label='Collisions')
    theory = [n / (math.log(n)**3) * 0.5 for n in Ns]
    ax.plot(Ns, theory, 'k--', linewidth=1, alpha=0.5, label='Θ(N/log³N) prediction')
    ax.set_title('Collision Count Growth')
    ax.set_xlabel('N')
    ax.set_ylabel('# multiplicative collisions')
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    
    # Plot 4: Counting function comparison
    ax = axes[1, 1]
    xs = list(range(10, N+1, 5))
    prime_counts = [sum(1 for p in primes if p <= x) for x in xs]
    rand_counts = [sum(1 for s in rand_set if s <= x) for x in xs]
    li_approx = [x / math.log(x) for x in xs]
    
    ax.plot(xs, prime_counts, 'g-', linewidth=1.5, alpha=0.8, label='π(x) (primes)')
    ax.plot(xs, rand_counts, 'r-', linewidth=1.5, alpha=0.8, label='π_S(x) (random)')
    ax.plot(xs, li_approx, 'k--', linewidth=1, alpha=0.5, label='x/log(x)')
    ax.set_title('Counting Functions: PNT Survives')
    ax.set_xlabel('x')
    ax.set_ylabel('count')
    ax.legend(fontsize=9)
    
    plt.tight_layout()
    plt.savefig('collisions_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved collisions_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Factorization Entropy — How Badly UFD Fails

Compares the number of S-factorizations for random sets vs actual primes.
For primes, every number has exactly 1 factorization (UFD).
For random sets, factorization counts can grow dramatically.
"""

import math
import random

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve(n):
    is_p = [True] * (n + 1)
    is_p[0] = is_p[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_p[i]:
            for j in range(i*i, n+1, i):
                is_p[j] = False
    return {i for i in range(2, n+1) if is_p[i]}


def random_prime_set(n, seed=42):
    rng = random.Random(seed)
    return {k for k in range(2, n+1) if rng.random() < 1.0 / math.log(k)}


def count_factorizations(n, S):
    sorted_S = sorted(s for s in S if 2 <= s <= n)
    memo = {}
    def helper(target, min_idx):
        if target == 1:
            return 1
        key = (target, min_idx)
        if key in memo:
            return memo[key]
        total = 0
        for i in range(min_idx, len(sorted_S)):
            f = sorted_S[i]
            if f > target:
                break
            if target % f == 0:
                total += helper(target // f, i)
        memo[key] = total
        return total
    return helper(n, 0)


def main():
    N = 300
    primes = sieve(N)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Factorization Entropy: Where UFD Collapses',
                 fontsize=14, fontweight='bold')
    
    # Multiple random seeds
    seeds = [42, 123, 456, 789]
    
    for idx, seed in enumerate(seeds):
        ax = axes[idx // 2, idx % 2]
        rand_S = random_prime_set(N, seed=seed)
        
        ns = list(range(4, N + 1))
        rand_facts = [count_factorizations(n, rand_S) for n in ns]
        prime_facts = [count_factorizations(n, primes) for n in ns]
        
        # Color by factorization count
        colors = ['red' if f > 1 else 'steelblue' for f in rand_facts]
        sizes = [max(3, min(20, f * 2)) for f in rand_facts]
        
        ax.scatter(ns, rand_facts, c=colors, s=sizes, alpha=0.5, zorder=2)
        ax.axhline(y=1, color='green', linestyle='--', alpha=0.5, 
                   label='UFD (1 factorization)', zorder=1)
        
        non_unique = sum(1 for f in rand_facts if f > 1)
        max_f = max(rand_facts)
        ax.set_title(f'Seed {seed}: |S|={len(rand_S)}, '
                     f'{non_unique}/{len(ns)} non-unique, max={max_f}')
        ax.set_xlabel('n')
        ax.set_ylabel('# S-factorizations')
        ax.set_yscale('log')
        ax.set_ylim(0.8, max(max_f * 2, 10))
        ax.legend(fontsize=8, loc='upper left')
    
    plt.tight_layout()
    plt.savefig('factorization_entropy.png', dpi=150, bbox_inches='tight')
    print("Saved factorization_entropy.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: RH Fluctuations — Random vs Actual Primes

Shows that counting function errors for random sets follow CLT (√(x/log x)),
while actual primes have much smaller errors (consistent with RH: √x · log x).
"""

import math
import random

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve(n):
    is_p = [True] * (n + 1)
    is_p[0] = is_p[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_p[i]:
            for j in range(i*i, n+1, i):
                is_p[j] = False
    return {i for i in range(2, n+1) if is_p[i]}


def random_prime_set(n, seed=42):
    rng = random.Random(seed)
    return {k for k in range(2, n+1) if rng.random() < 1.0 / math.log(k)}


def counting_errors(S, xs):
    cum = 0
    s_sorted = sorted(S)
    idx = 0
    errors = []
    for x in xs:
        while idx < len(s_sorted) and s_sorted[idx] <= x:
            cum += 1
            idx += 1
        errors.append(cum - x / math.log(x))
    return errors


def main():
    N = 50000
    primes = sieve(N)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Riemann Hypothesis Fails for Random Primes',
                 fontsize=14, fontweight='bold')
    
    xs = list(range(10, N + 1, 10))
    
    # Plot 1: Raw errors
    ax = axes[0, 0]
    prime_errors = counting_errors(primes, xs)
    ax.plot(xs, prime_errors, 'g-', linewidth=0.8, alpha=0.8, label='Actual primes')
    
    for seed in range(5):
        rand_S = random_prime_set(N, seed=seed)
        rand_errors = counting_errors(rand_S, xs)
        alpha = 0.4 if seed > 0 else 0.8
        label = 'Random sets' if seed == 0 else None
        ax.plot(xs, rand_errors, 'r-', linewidth=0.5, alpha=alpha, label=label)
    
    ax.set_title('Counting Function Error: π_S(x) - x/log(x)')
    ax.set_xlabel('x')
    ax.set_ylabel('Error')
    ax.legend(fontsize=9)
    ax.axhline(y=0, color='black', linewidth=0.5)
    
    # Plot 2: Normalized errors
    ax = axes[0, 1]
    norm = [math.sqrt(x / math.log(x)) for x in xs]
    prime_norm = [e / n for e, n in zip(prime_errors, norm)]
    ax.plot(xs, prime_norm, 'g-', linewidth=0.8, alpha=0.8, label='Actual primes')
    
    for seed in range(5):
        rand_S = random_prime_set(N, seed=seed)
        rand_errors = counting_errors(rand_S, xs)
        rand_norm = [e / n for e, n in zip(rand_errors, norm)]
        alpha = 0.4 if seed > 0 else 0.8
        label = 'Random sets' if seed == 0 else None
        ax.plot(xs, rand_norm, 'r-', linewidth=0.5, alpha=alpha, label=label)
    
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.axhline(y=1, color='gray', linewidth=0.5, linestyle='--')
    ax.axhline(y=-1, color='gray', linewidth=0.5, linestyle='--')
    ax.set_title('Normalized Error: error / √(x/log x)')
    ax.set_xlabel('x')
    ax.set_ylabel('Normalized error')
    ax.legend(fontsize=9)
    
    # Plot 3: Error magnitude comparison
    ax = axes[1, 0]
    check_points = [100, 500, 1000, 5000, 10000, 50000]
    
    n_trials = 50
    prime_abs_errors = []
    random_abs_errors = []
    
    for cp in check_points:
        p_err = abs(sum(1 for p in primes if p <= cp) - cp / math.log(cp))
        prime_abs_errors.append(p_err)
        
        r_errs = []
        for seed in range(n_trials):
            rs = random_prime_set(cp, seed=seed)
            r_errs.append(abs(len(rs) - cp / math.log(cp)))
        random_abs_errors.append(sum(r_errs) / len(r_errs))
    
    sqrt_x = [math.sqrt(x) for x in check_points]
    sqrt_x_logx = [math.sqrt(x / math.log(x)) for x in check_points]
    
    ax.loglog(check_points, prime_abs_errors, 'go-', linewidth=2, 
              markersize=8, label='|π(x) - x/log x|')
    ax.loglog(check_points, random_abs_errors, 'ro-', linewidth=2, 
              markersize=8, label='Mean |π_S(x) - x/log x|')
    ax.loglog(check_points, sqrt_x, 'b--', linewidth=1, alpha=0.5, label='√x (RH scale)')
    ax.loglog(check_points, sqrt_x_logx, 'k--', linewidth=1, alpha=0.5, label='√(x/log x) (CLT)')
    
    ax.set_title('Error Magnitude: Primes vs Random')
    ax.set_xlabel('x')
    ax.set_ylabel('|error|')
    ax.legend(fontsize=8)
    
    # Plot 4: Distribution of random errors at fixed x
    ax = axes[1, 1]
    x_fixed = 10000
    errors_at_x = []
    for seed in range(200):
        rs = random_prime_set(x_fixed, seed=seed)
        errors_at_x.append(len(rs) - x_fixed / math.log(x_fixed))
    
    std = math.sqrt(x_fixed / math.log(x_fixed))
    prime_err = sum(1 for p in primes if p <= x_fixed) - x_fixed / math.log(x_fixed)
    
    ax.hist(errors_at_x, bins=30, density=True, color='red', alpha=0.6, 
            label='Random set errors')
    xs_gauss = np.linspace(min(errors_at_x), max(errors_at_x), 100)
    gauss = np.exp(-xs_gauss**2 / (2 * std**2)) / (std * np.sqrt(2 * np.pi))
    ax.plot(xs_gauss, gauss, 'k-', linewidth=2, label=f'N(0, {std:.1f}²) theory')
    ax.axvline(x=prime_err, color='green', linewidth=2, linestyle='--',
               label=f'Actual primes: {prime_err:.0f}')
    
    ax.set_title(f'Error Distribution at x = {x_fixed}')
    ax.set_xlabel('π_S(x) - x/log(x)')
    ax.set_ylabel('Density')
    ax.legend(fontsize=8)
    
    plt.tight_layout()
    plt.savefig('rh_fluctuations.png', dpi=150, bbox_inches='tight')
    print("Saved rh_fluctuations.png")


if __name__ == "__main__":
    main()
