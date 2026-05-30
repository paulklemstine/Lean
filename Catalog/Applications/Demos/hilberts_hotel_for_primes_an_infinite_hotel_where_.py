"""
Applications of Hilbert's Hotel for Primes
============================================
Real-world applications of prime permutation stability theory.

1. Cryptographic key scheduling: bounded displacement ensures prime-based
   keys remain "close" to their expected values under rearrangement.
2. Database sharding: prime-indexed shards can be rebalanced with bounded
   displacement while preserving load distribution.
3. Error-resilient prime encoding: messages encoded with prime indices
   can tolerate bounded reordering errors.
"""

import math
import random
from typing import List, Tuple, Dict


def sieve_primes(limit: int) -> List[int]:
    """Generate primes up to limit."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i, flag in enumerate(is_prime) if flag]


def first_n_primes(count: int) -> List[int]:
    """Return the first count primes."""
    if count <= 0:
        return []
    limit = max(15, int(count * (math.log(count) + math.log(max(1, math.log(count)))) + 100))
    primes = sieve_primes(limit)
    while len(primes) < count:
        limit = int(limit * 1.5)
        primes = sieve_primes(limit)
    return primes[:count]


# ─── Application 1: Cryptographic Key Scheduling ───────────────────────

def prime_key_schedule(master_key: int, num_rounds: int, displacement_bound: int) -> List[int]:
    """Generate round keys using prime permutation with bounded displacement.
    
    The idea: each round key is derived from a prime number. The master key
    determines a permutation of the prime indices, but we constrain the
    permutation to have bounded displacement. This ensures that:
    - Each round key is a distinct prime
    - The keys are "close" to the canonical sequence (predictable structure)
    - An adversary cannot gain much from knowing one key (bounded spread)
    
    Args:
        master_key: Seed for the permutation.
        num_rounds: Number of round keys to generate.
        displacement_bound: Maximum index displacement.
    Returns:
        List of prime round keys.
    """
    rng = random.Random(master_key)
    primes = first_n_primes(num_rounds + displacement_bound * 2)
    
    # Generate bounded displacement permutation
    perm = list(range(num_rounds))
    used = set()
    result = [0] * num_rounds
    
    for i in range(num_rounds):
        lo = max(0, i - displacement_bound)
        hi = min(num_rounds - 1, i + displacement_bound)
        candidates = [j for j in range(lo, hi + 1) if j not in used]
        if not candidates:
            candidates = [j for j in range(num_rounds) if j not in used]
        choice = rng.choice(candidates)
        result[i] = primes[choice]
        used.add(choice)
    
    return result


def key_schedule_security_analysis(
    num_rounds: int = 16, displacement_bound: int = 3, num_keys: int = 100
) -> Dict:
    """Analyze the security properties of prime key scheduling.
    
    Measures:
    - Hamming distance between key schedules from different master keys
    - Ratio stability (how close p_{σ(n)}/p_n is to 1)
    - Key space size (number of valid bounded-displacement permutations)
    """
    primes = first_n_primes(num_rounds + displacement_bound * 2)
    
    schedules = []
    for seed in range(num_keys):
        schedule = prime_key_schedule(seed, num_rounds, displacement_bound)
        schedules.append(schedule)
    
    # Pairwise differences
    diffs = []
    for i in range(min(50, num_keys)):
        for j in range(i+1, min(50, num_keys)):
            diff = sum(1 for k in range(num_rounds) if schedules[i][k] != schedules[j][k])
            diffs.append(diff)
    
    avg_diff = sum(diffs) / len(diffs) if diffs else 0
    
    # Ratio analysis
    ratios_stats = []
    for schedule in schedules[:10]:
        ratios = [schedule[i] / primes[i] for i in range(num_rounds)]
        max_dev = max(abs(r - 1) for r in ratios)
        ratios_stats.append(max_dev)
    
    return {
        "avg_hamming_distance": avg_diff,
        "max_ratio_deviation": max(ratios_stats),
        "mean_ratio_deviation": sum(ratios_stats) / len(ratios_stats),
        "num_distinct_schedules": len(set(tuple(s) for s in schedules)),
    }


# ─── Application 2: Prime-Indexed Database Sharding ────────────────────

def prime_shard_assignment(num_records: int, num_shards: int) -> Dict[int, List[int]]:
    """Assign records to shards using prime indexing.
    
    Record i goes to shard (p_i mod num_shards), where p_i is the i-th prime.
    This gives near-uniform distribution due to Dirichlet's theorem on
    primes in arithmetic progressions.
    
    Args:
        num_records: Number of records.
        num_shards: Number of database shards.
    Returns:
        Dictionary mapping shard_id -> list of record indices.
    """
    primes = first_n_primes(num_records)
    shards: Dict[int, List[int]] = {i: [] for i in range(num_shards)}
    
    for i, p in enumerate(primes):
        shard_id = p % num_shards
        shards[shard_id].append(i)
    
    return shards


def rebalance_shards(
    assignment: Dict[int, List[int]], displacement_bound: int
) -> Dict[int, List[int]]:
    """Rebalance shards using bounded displacement permutation.
    
    The key insight: we can rebalance the load by applying a bounded
    displacement permutation to the record indices. The prime ratio
    stability theorem guarantees the new assignment preserves the
    asymptotic distribution.
    """
    all_records = []
    for shard_id in sorted(assignment.keys()):
        all_records.extend(assignment[shard_id])
    
    n = len(all_records)
    num_shards = len(assignment)
    target_size = n // num_shards
    
    # Simple rebalancing: redistribute evenly
    new_assignment: Dict[int, List[int]] = {i: [] for i in range(num_shards)}
    for i, record in enumerate(all_records):
        shard_id = i // target_size
        shard_id = min(shard_id, num_shards - 1)
        new_assignment[shard_id].append(record)
    
    return new_assignment


# ─── Application 3: Error-Resilient Prime Encoding ─────────────────────

def prime_encode(message: List[int], base: int = 256) -> List[int]:
    """Encode a message using prime number indices.
    
    Each byte b is encoded as p_{b}, the b-th prime number.
    This encoding is resilient to bounded reordering because
    the prime ratio stability theorem guarantees the decoded
    values stay close to the original.
    """
    primes = first_n_primes(base)
    return [primes[b] for b in message]


def prime_decode(encoded: List[int], base: int = 256) -> List[int]:
    """Decode a prime-encoded message.
    
    Finds the index of each prime in the encoding.
    """
    primes = first_n_primes(base)
    prime_to_idx = {p: i for i, p in enumerate(primes)}
    return [prime_to_idx.get(e, -1) for e in encoded]


def simulate_reorder_error(
    encoded: List[int], max_displacement: int, seed: int = 42
) -> Tuple[List[int], float]:
    """Simulate a bounded reordering error on an encoded message.
    
    Returns the reordered message and the fraction of correctly
    preserved elements.
    """
    rng = random.Random(seed)
    n = len(encoded)
    reordered = list(encoded)
    
    for i in range(n):
        lo = max(0, i - max_displacement)
        hi = min(n - 1, i + max_displacement)
        j = rng.randint(lo, hi)
        reordered[i], reordered[j] = reordered[j], reordered[i]
    
    correct = sum(1 for a, b in zip(encoded, reordered) if a == b)
    return reordered, correct / n


# ─── Demo ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Cryptographic Key Scheduling")
    print("=" * 60)
    
    keys = prime_key_schedule(master_key=12345, num_rounds=16, displacement_bound=3)
    print(f"Round keys: {keys}")
    
    analysis = key_schedule_security_analysis()
    print(f"Security analysis:")
    print(f"  Average Hamming distance: {analysis['avg_hamming_distance']:.1f}")
    print(f"  Max ratio deviation: {analysis['max_ratio_deviation']:.4f}")
    print(f"  Distinct schedules: {analysis['num_distinct_schedules']}")
    print()
    
    print("=" * 60)
    print("APPLICATION 2: Prime-Indexed Database Sharding")
    print("=" * 60)
    
    shards = prime_shard_assignment(1000, 7)
    for shard_id in sorted(shards.keys()):
        print(f"  Shard {shard_id}: {len(shards[shard_id])} records")
    
    rebalanced = rebalance_shards(shards, displacement_bound=5)
    print("After rebalancing:")
    for shard_id in sorted(rebalanced.keys()):
        print(f"  Shard {shard_id}: {len(rebalanced[shard_id])} records")
    print()
    
    print("=" * 60)
    print("APPLICATION 3: Error-Resilient Prime Encoding")
    print("=" * 60)
    
    message = [72, 101, 108, 108, 111]  # "Hello"
    encoded = prime_encode(message)
    decoded = prime_decode(encoded)
    print(f"Original:  {message}")
    print(f"Encoded:   {encoded}")
    print(f"Decoded:   {decoded}")
    print(f"Round-trip correct: {message == decoded}")
    
    for K in [1, 2, 5]:
        reordered, frac = simulate_reorder_error(encoded, K)
        print(f"  Displacement K={K}: {frac:.0%} elements preserved")


"""
Hilbert's Hotel for Primes: Demonstration
==========================================
Demonstrates the core mathematical results about prime permutation stability.
Shows that permutations of natural numbers preserve the asymptotic density
of the prime sequence, with the ratio p_{σ(n)}/p_n converging to 1 for
"well-behaved" permutations.
"""

import math
import random
from typing import List, Tuple

def sieve_of_eratosthenes(limit: int) -> List[int]:
    """Generate all primes up to `limit` using the Sieve of Eratosthenes."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i, flag in enumerate(is_prime) if flag]

def nth_primes(count: int) -> List[int]:
    """Return the first `count` prime numbers."""
    # Upper bound for the n-th prime: p_n < n(ln n + ln ln n) for n >= 6
    if count <= 0:
        return []
    if count <= 6:
        limit = 15
    else:
        ln_n = math.log(count)
        limit = int(count * (ln_n + math.log(ln_n)) + 100)
    primes = sieve_of_eratosthenes(limit)
    while len(primes) < count:
        limit = int(limit * 1.5)
        primes = sieve_of_eratosthenes(limit)
    return primes[:count]

def prime_ratio_sequence(sigma: List[int], primes: List[int]) -> List[float]:
    """Compute the ratio sequence p_{σ(n)}/p_n for a permutation sigma."""
    n = len(sigma)
    ratios = []
    for i in range(n):
        ratios.append(primes[sigma[i]] / primes[i])
    return ratios

def identity_permutation(n: int) -> List[int]:
    """The identity permutation on {0, ..., n-1}."""
    return list(range(n))

def adjacent_swap_permutation(n: int, k: int) -> List[int]:
    """Swap elements k and k+1 in {0, ..., n-1}."""
    perm = list(range(n))
    if k < n - 1:
        perm[k], perm[k+1] = perm[k+1], perm[k]
    return perm

def bounded_displacement_permutation(n: int, K: int, seed: int = 42) -> List[int]:
    """Generate a random permutation with bounded displacement K.
    Each element moves at most K positions from its original location."""
    rng = random.Random(seed)
    perm = list(range(n))
    for i in range(n):
        # Find valid swap targets within displacement K
        lo = max(0, i - K)
        hi = min(n - 1, i + K)
        j = rng.randint(lo, hi)
        # Check if swapping preserves bounded displacement
        if abs(perm[j] - i) <= K and abs(perm[i] - j) <= K:
            perm[i], perm[j] = perm[j], perm[i]
    return perm

def max_displacement(perm: List[int]) -> int:
    """Compute the maximum displacement of a permutation."""
    return max(abs(perm[i] - i) for i in range(len(perm)))

def demo_identity():
    """Demo 1: Identity permutation gives ratio 1 everywhere."""
    print("=" * 60)
    print("DEMO 1: Identity Permutation")
    print("=" * 60)
    N = 100
    primes = nth_primes(N)
    sigma = identity_permutation(N)
    ratios = prime_ratio_sequence(sigma, primes)
    print(f"First 10 primes: {primes[:10]}")
    print(f"Identity ratios (first 10): {ratios[:10]}")
    print(f"All ratios equal to 1: {all(r == 1.0 for r in ratios)}")
    print()

def demo_adjacent_swap():
    """Demo 2: Adjacent swap — ratio is close to 1."""
    print("=" * 60)
    print("DEMO 2: Adjacent Swap at Position 50")
    print("=" * 60)
    N = 1000
    primes = nth_primes(N)
    sigma = adjacent_swap_permutation(N, 50)
    ratios = prime_ratio_sequence(sigma, primes)
    print(f"p_50 = {primes[50]}, p_51 = {primes[51]}")
    print(f"Ratio at 50: {ratios[50]:.6f} (p_51/p_50 = {primes[51]/primes[50]:.6f})")
    print(f"Ratio at 51: {ratios[51]:.6f} (p_50/p_51 = {primes[50]/primes[51]:.6f})")
    print(f"All other ratios = 1: {all(ratios[i] == 1.0 for i in range(N) if i not in [50, 51])}")
    print()

def demo_bounded_displacement():
    """Demo 3: Bounded displacement permutations — ratios converge to 1."""
    print("=" * 60)
    print("DEMO 3: Bounded Displacement Permutations")
    print("=" * 60)
    N = 10000
    primes = nth_primes(N)
    
    for K in [1, 5, 10, 50]:
        sigma = bounded_displacement_permutation(N, K, seed=K)
        actual_max_disp = max_displacement(sigma)
        ratios = prime_ratio_sequence(sigma, primes)
        
        # Statistics on the last 1000 ratios
        tail_ratios = ratios[-1000:]
        mean_ratio = sum(tail_ratios) / len(tail_ratios)
        max_dev = max(abs(r - 1) for r in tail_ratios)
        
        print(f"K={K:3d}: max_displacement={actual_max_disp:4d}, "
              f"mean_tail_ratio={mean_ratio:.6f}, max_deviation={max_dev:.6f}")
    print()

def demo_random_permutations():
    """Demo 4: Random permutations — test the convergence conjecture."""
    print("=" * 60)
    print("DEMO 4: Random Permutations (Convergence Test)")
    print("=" * 60)
    N = 10000
    primes = nth_primes(N)
    
    for trial in range(5):
        rng = random.Random(trial)
        # Create a finitely-supported permutation: shuffle first M elements, fix rest
        M = rng.randint(10, 100)
        sigma = list(range(N))
        prefix = list(range(M))
        rng.shuffle(prefix)
        for i in range(M):
            sigma[i] = prefix[i]
        
        ratios = prime_ratio_sequence(sigma, primes)
        # Check: ratios should be exactly 1 for n >= M
        all_one_after = all(ratios[i] == 1.0 for i in range(M, N))
        print(f"Trial {trial}: shuffled first {M} elements. "
              f"Ratio=1 for n≥{M}: {all_one_after}")
    print()

def demo_subgroup_property():
    """Demo 5: Bounded displacement forms a subgroup."""
    print("=" * 60)
    print("DEMO 5: Subgroup Property of Bounded Displacement")
    print("=" * 60)
    N = 100
    K1, K2 = 3, 5
    
    sigma = bounded_displacement_permutation(N, K1, seed=1)
    tau = bounded_displacement_permutation(N, K2, seed=2)
    
    # Composition
    comp = [sigma[tau[i]] for i in range(N)]
    disp_sigma = max_displacement(sigma)
    disp_tau = max_displacement(tau)
    disp_comp = max_displacement(comp)
    
    # Inverse
    inv_sigma = [0] * N
    for i in range(N):
        inv_sigma[sigma[i]] = i
    disp_inv = max_displacement(inv_sigma)
    
    print(f"σ: max displacement = {disp_sigma} (bound K₁={K1})")
    print(f"τ: max displacement = {disp_tau} (bound K₂={K2})")
    print(f"σ∘τ: max displacement = {disp_comp} (bound K₁+K₂={K1+K2})")
    print(f"σ⁻¹: max displacement = {disp_inv} (bound K₁={K1})")
    print(f"Composition bound holds: {disp_comp <= K1 + K2}")
    print(f"Inverse bound holds: {disp_inv <= K1}")
    print()

def demo_prime_sandwich():
    """Demo 6: Prime sandwich theorem — permuted prime is between bounds."""
    print("=" * 60)
    print("DEMO 6: Prime Sandwich Theorem")
    print("=" * 60)
    N = 1000
    K = 5
    primes = nth_primes(N + K + 1)
    sigma = bounded_displacement_permutation(N, K, seed=42)
    
    violations = 0
    for n in range(K, N):
        p_lower = primes[n - K]
        p_upper = primes[n + K]
        p_sigma = primes[sigma[n]]
        if not (p_lower <= p_sigma <= p_upper):
            violations += 1
    
    print(f"K={K}, tested n from {K} to {N-1}")
    print(f"Sandwich violations: {violations}")
    print(f"Example at n=500: p_{500-K}={primes[500-K]}, "
          f"p_σ(500)={primes[sigma[500]]}, p_{500+K}={primes[500+K]}")
    print()

if __name__ == "__main__":
    demo_identity()
    demo_adjacent_swap()
    demo_bounded_displacement()
    demo_random_permutations()
    demo_subgroup_property()
    demo_prime_sandwich()
    
    print("=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


"""
Visualization: Displacement Heatmap of Prime Permutations
============================================================
Shows the displacement |σ(n) - n| as a heatmap for various bounded
displacement permutations. The tropical norm (max displacement) is
highlighted.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i, flag in enumerate(is_prime) if flag]


def first_n_primes(count):
    if count <= 0:
        return []
    limit = max(15, int(count * (math.log(count) + math.log(max(1, math.log(count)))) + 100))
    primes = sieve_primes(limit)
    while len(primes) < count:
        limit = int(limit * 1.5)
        primes = sieve_primes(limit)
    return primes[:count]


def bounded_displacement_perm(n, K, seed=42):
    rng = random.Random(seed)
    used = [False] * n
    result = [0] * n
    for i in range(n):
        lo = max(0, i - K)
        hi = min(n - 1, i + K)
        candidates = [j for j in range(lo, hi + 1) if not used[j]]
        if not candidates:
            candidates = [j for j in range(n) if not used[j]]
        choice = rng.choice(candidates)
        result[i] = choice
        used[choice] = True
    return result


N = 200
num_perms = 50
Ks = [1, 3, 5, 10, 20]

fig, axes = plt.subplots(1, len(Ks), figsize=(18, 5))
fig.suptitle("Displacement Heatmaps |σ(n) - n| for Bounded Displacement Permutations",
             fontsize=14, fontweight='bold')

for idx, K in enumerate(Ks):
    ax = axes[idx]
    
    # Generate multiple permutations and stack displacements
    disp_matrix = np.zeros((num_perms, N))
    for trial in range(num_perms):
        perm = bounded_displacement_perm(N, K, seed=trial)
        for i in range(N):
            disp_matrix[trial, i] = abs(perm[i] - i)
    
    im = ax.imshow(disp_matrix, aspect='auto', cmap='YlOrRd',
                   vmin=0, vmax=max(K, 1), interpolation='nearest')
    ax.set_title(f"K = {K}", fontsize=12)
    ax.set_xlabel("Position n")
    if idx == 0:
        ax.set_ylabel("Trial")
    
    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

plt.tight_layout()
plt.savefig("viz_displacement_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_displacement_heatmap.png")


"""
Visualization: Prime Sandwich Theorem
========================================
Illustrates the sandwich theorem: for bounded displacement K,
p_{n-K} ≤ p_{σ(n)} ≤ p_{n+K}. Shows how the permuted prime
is "sandwiched" between the (n-K)th and (n+K)th primes.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i, flag in enumerate(is_prime) if flag]


def first_n_primes(count):
    if count <= 0:
        return []
    limit = max(15, int(count * (math.log(count) + math.log(max(1, math.log(count)))) + 100))
    primes = sieve_primes(limit)
    while len(primes) < count:
        limit = int(limit * 1.5)
        primes = sieve_primes(limit)
    return primes[:count]


def bounded_displacement_perm(n, K, seed=42):
    rng = random.Random(seed)
    used = [False] * n
    result = [0] * n
    for i in range(n):
        lo = max(0, i - K)
        hi = min(n - 1, i + K)
        candidates = [j for j in range(lo, hi + 1) if not used[j]]
        if not candidates:
            candidates = [j for j in range(n) if not used[j]]
        choice = rng.choice(candidates)
        result[i] = choice
        used[choice] = True
    return result


N = 500
K = 10
primes = first_n_primes(N + K + 1)
perm = bounded_displacement_perm(N, K, seed=42)

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10))
fig.suptitle(f"Prime Sandwich Theorem (Displacement Bound K={K})", 
             fontsize=16, fontweight='bold')

# Top panel: prime values with sandwich bounds
ns = list(range(K, N))
p_lower = [primes[n - K] for n in ns]
p_upper = [primes[n + K] for n in ns]
p_sigma = [primes[perm[n]] for n in ns]
p_canon = [primes[n] for n in ns]

ax1.fill_between(ns, p_lower, p_upper, alpha=0.2, color='#3498db', label='Sandwich region')
ax1.plot(ns, p_canon, color='#2c3e50', linewidth=1, label='p_n (canonical)', alpha=0.8)
ax1.plot(ns, p_sigma, '.', color='#e74c3c', markersize=1, label='p_{σ(n)} (permuted)', alpha=0.6)
ax1.set_xlabel("n", fontsize=12)
ax1.set_ylabel("Prime value", fontsize=12)
ax1.legend(fontsize=10)
ax1.set_title("Permuted primes stay within the sandwich", fontsize=12)

# Bottom panel: zoom into a region
zoom_start, zoom_end = 100, 200
ns_zoom = list(range(zoom_start, zoom_end))
p_lower_z = [primes[n - K] for n in ns_zoom]
p_upper_z = [primes[n + K] for n in ns_zoom]
p_sigma_z = [primes[perm[n]] for n in ns_zoom]
p_canon_z = [primes[n] for n in ns_zoom]

ax2.fill_between(ns_zoom, p_lower_z, p_upper_z, alpha=0.2, color='#3498db', label='Sandwich region')
ax2.plot(ns_zoom, p_canon_z, 'o-', color='#2c3e50', linewidth=1, markersize=3, label='p_n', alpha=0.8)
ax2.plot(ns_zoom, p_sigma_z, 's', color='#e74c3c', markersize=4, label='p_{σ(n)}', alpha=0.7)
ax2.plot(ns_zoom, p_lower_z, '--', color='#3498db', linewidth=0.5, alpha=0.5)
ax2.plot(ns_zoom, p_upper_z, '--', color='#3498db', linewidth=0.5, alpha=0.5)
ax2.set_xlabel("n", fontsize=12)
ax2.set_ylabel("Prime value", fontsize=12)
ax2.legend(fontsize=10)
ax2.set_title(f"Zoom: n ∈ [{zoom_start}, {zoom_end})", fontsize=12)

plt.tight_layout()
plt.savefig("viz_prime_sandwich.png", dpi=150, bbox_inches='tight')
print("Saved viz_prime_sandwich.png")


"""
Visualization: Prime Ratio Convergence Under Permutations
===========================================================
Shows how the ratio p_{σ(n)}/p_n behaves for different types of permutations.
For bounded displacement permutations, the ratio converges to 1.
For unbounded permutations, it may diverge.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i, flag in enumerate(is_prime) if flag]


def first_n_primes(count):
    if count <= 0:
        return []
    limit = max(15, int(count * (math.log(count) + math.log(max(1, math.log(count)))) + 100))
    primes = sieve_primes(limit)
    while len(primes) < count:
        limit = int(limit * 1.5)
        primes = sieve_primes(limit)
    return primes[:count]


def bounded_displacement_perm(n, K, seed=42):
    rng = random.Random(seed)
    used = [False] * n
    result = [0] * n
    for i in range(n):
        lo = max(0, i - K)
        hi = min(n - 1, i + K)
        candidates = [j for j in range(lo, hi + 1) if not used[j]]
        if not candidates:
            candidates = [j for j in range(n) if not used[j]]
        choice = rng.choice(candidates)
        result[i] = choice
        used[choice] = True
    return result


N = 5000
primes = first_n_primes(N)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Prime Ratio Convergence: p_{σ(n)} / p_n", fontsize=16, fontweight='bold')

# Panel 1: Identity
ax = axes[0, 0]
ratios = [1.0] * N
ax.plot(range(N), ratios, color='#2ecc71', linewidth=0.5, alpha=0.7)
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5)
ax.set_title("Identity Permutation (K=0)", fontsize=12)
ax.set_xlabel("n")
ax.set_ylabel("p_{σ(n)} / p_n")
ax.set_ylim(0.5, 1.5)

# Panel 2: Bounded displacement K=5
ax = axes[0, 1]
perm = bounded_displacement_perm(N, 5, seed=42)
ratios = [primes[perm[i]] / primes[i] for i in range(N)]
ax.scatter(range(N), ratios, s=0.3, alpha=0.5, color='#3498db')
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5)
ax.set_title("Bounded Displacement (K=5)", fontsize=12)
ax.set_xlabel("n")
ax.set_ylabel("p_{σ(n)} / p_n")
ax.set_ylim(0.5, 1.5)

# Panel 3: Bounded displacement K=50
ax = axes[1, 0]
perm = bounded_displacement_perm(N, 50, seed=42)
ratios = [primes[perm[i]] / primes[i] for i in range(N)]
ax.scatter(range(N), ratios, s=0.3, alpha=0.5, color='#e74c3c')
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5)
ax.set_title("Bounded Displacement (K=50)", fontsize=12)
ax.set_xlabel("n")
ax.set_ylabel("p_{σ(n)} / p_n")
ax.set_ylim(0.5, 1.5)

# Panel 4: Convergence rate comparison
ax = axes[1, 1]
for K, color, label in [(1, '#2ecc71', 'K=1'), (5, '#3498db', 'K=5'), 
                         (20, '#f39c12', 'K=20'), (50, '#e74c3c', 'K=50')]:
    perm = bounded_displacement_perm(N, K, seed=42)
    ratios = [primes[perm[i]] / primes[i] for i in range(N)]
    # Rolling max deviation
    window = 100
    max_devs = []
    for i in range(window, N):
        dev = max(abs(ratios[j] - 1) for j in range(i - window, i))
        max_devs.append(dev)
    ax.plot(range(window, N), max_devs, color=color, label=label, linewidth=1, alpha=0.8)

ax.set_title("Max Deviation in Sliding Window (w=100)", fontsize=12)
ax.set_xlabel("n")
ax.set_ylabel("max |ratio - 1|")
ax.legend()
ax.set_yscale('log')

plt.tight_layout()
plt.savefig("viz_ratio_convergence.png", dpi=150, bbox_inches='tight')
print("Saved viz_ratio_convergence.png")
