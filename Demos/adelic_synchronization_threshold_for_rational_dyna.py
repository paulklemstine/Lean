"""
Applications of Adelic Synchronization Theory

Real-world applications connecting arithmetic dynamics to:
1. Pseudorandom number generator quality testing
2. Cryptographic hash function analysis
3. Primality certificate generation
4. Modular arithmetic pattern detection
"""

from math import gcd, sqrt, log2
from collections import Counter
from typing import List, Tuple, Dict


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(sqrt(n)) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def orbit_signature(f, domain):
    """Compute orbit signature of f on domain."""
    visited = set()
    cycle_lengths = []
    tree_size = 0
    
    for start in domain:
        if start in visited:
            continue
        path = []
        seen = {}
        x = start
        step = 0
        while x not in seen and x not in visited:
            seen[x] = step
            path.append(x)
            x = f(x)
            step += 1
        
        if x in visited:
            for pt in path:
                visited.add(pt)
                tree_size += 1
        else:
            cycle_start = seen[x]
            period = step - cycle_start
            cycle_lengths.append(period)
            for i, pt in enumerate(path):
                visited.add(pt)
                if i < cycle_start:
                    tree_size += 1
    
    return sorted(cycle_lengths), tree_size


def sync_index(sig1, sig2):
    """Adelic synchronization index."""
    c1, _ = sig1
    c2, _ = sig2
    if not c1 or not c2:
        return 0.0
    counter1 = Counter(c1)
    counter2 = Counter(c2)
    common = sum((counter1 & counter2).values())
    return common / max(len(c1), len(c2))


# ============================================================
# Application 1: PRNG Quality Assessment
# ============================================================

def assess_prng_quality(generator, modulus: int, primes: List[int]) -> Dict:
    """
    Assess the quality of a pseudorandom number generator
    using cross-prime synchronization analysis.
    
    A good PRNG should have LOW cross-prime synchronization
    (behaving like a random map), while a poor PRNG with
    algebraic structure will show HIGH synchronization.
    
    Args:
        generator: Function int -> int (the PRNG step function)
        modulus: The modulus of the PRNG
        primes: List of primes for analysis
    
    Returns:
        Assessment dictionary with quality metrics
    """
    sigs = {}
    for p in primes:
        f = lambda x, p=p: generator(x) % p
        sigs[p] = orbit_signature(f, list(range(p)))
    
    # Compute mean sync
    total = 0
    count = 0
    for i, p1 in enumerate(primes):
        for j, p2 in enumerate(primes):
            if i < j:
                total += sync_index(sigs[p1], sigs[p2])
                count += 1
    
    mean = total / count if count else 0
    
    # Random maps have expected sync ~ 0
    quality = "GOOD" if mean < 0.15 else "SUSPECT" if mean < 0.3 else "POOR"
    
    return {
        "mean_synchronization": mean,
        "quality": quality,
        "interpretation": (
            f"Mean sync = {mean:.4f}. "
            f"{'Low sync suggests good pseudorandom behavior.' if quality == 'GOOD' else 'High sync suggests algebraic structure in the generator.'}"
        )
    }


# ============================================================
# Application 2: Modular Arithmetic Pattern Detection
# ============================================================

def detect_arithmetic_patterns(
    sequence: List[int],
    primes: List[int]
) -> Dict:
    """
    Detect hidden arithmetic patterns in a sequence using
    cross-prime orbit analysis.
    
    The idea: if a sequence has hidden algebraic structure,
    its behavior modulo different primes will be correlated
    (high synchronization). Random sequences show no correlation.
    
    Args:
        sequence: Integer sequence to analyze
        primes: Primes for cross-prime analysis
    
    Returns:
        Pattern detection results
    """
    results = {}
    for p in primes:
        reduced = [x % p for x in sequence]
        # Build transition function from sequence
        transitions = {}
        for i in range(len(reduced) - 1):
            transitions[reduced[i]] = reduced[i + 1]
        
        if transitions:
            f = lambda x, t=transitions: t.get(x, x)
            sig = orbit_signature(f, list(set(reduced)))
            results[p] = sig
    
    # Compute synchronization
    prime_list = sorted(results.keys())
    syncs = []
    for i in range(len(prime_list)):
        for j in range(i + 1, len(prime_list)):
            s = sync_index(results[prime_list[i]], results[prime_list[j]])
            syncs.append(s)
    
    mean = sum(syncs) / len(syncs) if syncs else 0
    has_pattern = mean > 0.2
    
    return {
        "mean_sync": mean,
        "pattern_detected": has_pattern,
        "per_prime_cycles": {p: results[p][0] for p in prime_list[:5]}
    }


# ============================================================
# Application 3: Dynamical Primality Certificate
# ============================================================

def dynamical_primality_info(n: int) -> Dict:
    """
    Generate dynamical system information relevant to primality.
    
    For a number n, analyze the orbit structure of x -> x^2 + 1 mod n.
    Primes produce characteristic orbit structures different from
    composites, due to the structure of (Z/nZ)*.
    
    Args:
        n: Number to analyze
    
    Returns:
        Dynamical analysis results
    """
    f = lambda x: (x * x + 1) % n
    sig, tree = orbit_signature(f, list(range(n)))
    
    # For primes, the number of fixed points of x^2+1 relates to
    # the Legendre symbol (-1/p)
    fixed_points = sum(1 for x in range(n) if f(x) == x)
    
    # Orbit entropy
    distinct_cycles = len(set(sig))
    entropy = log2(distinct_cycles) if distinct_cycles > 0 else 0
    
    return {
        "n": n,
        "cycle_lengths": sig,
        "tree_size": tree,
        "num_cycles": len(sig),
        "fixed_points": fixed_points,
        "orbit_entropy": entropy,
        "entropy_bound": log2(n) if n > 0 else 0
    }


# ============================================================
# Main: Run all applications
# ============================================================

if __name__ == "__main__":
    primes = sieve_primes(30)
    primes = [p for p in primes if p > 2]
    
    print("=" * 60)
    print("APPLICATION 1: PRNG Quality Assessment")
    print("=" * 60)
    
    # Test with a simple linear congruential generator
    lcg = lambda x: (7 * x + 3) % 100
    result = assess_prng_quality(lcg, 100, primes)
    print(f"LCG x -> 7x + 3 (mod 100):")
    print(f"  {result['interpretation']}")
    print(f"  Quality: {result['quality']}")
    
    # Test with quadratic map (more complex)
    quad = lambda x: (x * x + 1) % 100
    result = assess_prng_quality(quad, 100, primes)
    print(f"\nQuadratic x -> x^2 + 1 (mod 100):")
    print(f"  {result['interpretation']}")
    print(f"  Quality: {result['quality']}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 2: Arithmetic Pattern Detection")
    print("=" * 60)
    
    # Structured sequence (powers of 2)
    powers = [2**k for k in range(50)]
    result = detect_arithmetic_patterns(powers, primes)
    print(f"Powers of 2:")
    print(f"  Mean sync: {result['mean_sync']:.4f}")
    print(f"  Pattern detected: {result['pattern_detected']}")
    
    # Random-looking sequence (Collatz iterates)
    collatz = [1]
    x = 27
    for _ in range(50):
        collatz.append(x)
        x = x // 2 if x % 2 == 0 else 3 * x + 1
    result = detect_arithmetic_patterns(collatz, primes)
    print(f"\nCollatz sequence from 27:")
    print(f"  Mean sync: {result['mean_sync']:.4f}")
    print(f"  Pattern detected: {result['pattern_detected']}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 3: Dynamical Primality Analysis")
    print("=" * 60)
    
    test_numbers = [7, 11, 13, 15, 17, 21, 23, 25, 29, 30]
    print(f"\n{'n':>4} {'Prime?':>7} {'Cycles':>8} {'Trees':>6} "
          f"{'Fixed':>6} {'Entropy':>8} {'Bound':>8}")
    print("-" * 55)
    for n in test_numbers:
        info = dynamical_primality_info(n)
        is_prime = all(n % i != 0 for i in range(2, int(sqrt(n)) + 1)) and n > 1
        print(f"{n:>4} {str(is_prime):>7} {info['num_cycles']:>8} "
              f"{info['tree_size']:>6} {info['fixed_points']:>6} "
              f"{info['orbit_entropy']:>8.3f} {info['entropy_bound']:>8.3f}")
    
    print("\n" + "=" * 60)
    print("All applications completed!")
    print("=" * 60)


"""
Demo: Adelic Synchronization for Arithmetic Dynamics

Demonstrates the key concepts from the formal Lean proofs:
1. Orbit structure of polynomial maps over finite fields
2. Cross-prime synchronization measurement
3. Phase transition detection in parameter families
"""

from collections import Counter
from math import gcd, log2


def iterate_map(f, x, n, mod):
    """Compute f^[n](x) mod p."""
    val = x % mod
    for _ in range(n):
        val = f(val, mod)
    return val


def quadratic_map(x, c, p):
    """The quadratic map x -> x^2 + c mod p."""
    return (x * x + c) % p


def compute_orbit(f, x, p):
    """Compute the full orbit of x under f mod p.
    Returns (preperiod, period, orbit_list)."""
    seen = {}
    orbit = []
    val = x % p
    step = 0
    while val not in seen:
        seen[val] = step
        orbit.append(val)
        val = f(val, p)
        step += 1
    preperiod = seen[val]
    period = step - preperiod
    return preperiod, period, orbit


def functional_graph(f, p):
    """Compute the complete functional graph of f on Z/pZ.
    Returns dict mapping each element to its (preperiod, period)."""
    result = {}
    for x in range(p):
        pre, per, _ = compute_orbit(lambda v, m: f(v, m), x, p)
        result[x] = (pre, per)
    return result


def orbit_signature(f, p):
    """Compute the orbit signature: multiset of cycle lengths."""
    graph = functional_graph(f, p)
    # Find all cycle lengths
    visited = set()
    cycle_lengths = []
    tree_size = 0
    for x in range(p):
        pre, per = graph[x]
        if pre == 0 and x not in visited:
            # x is on a cycle
            cycle_lengths.append(per)
            # Mark all points on this cycle
            val = x
            for _ in range(per):
                visited.add(val)
                val = f(val, p)
        elif pre > 0:
            tree_size += 1
    return sorted(cycle_lengths), tree_size


def adelic_sync_index(sig1, sig2):
    """Compute the synchronization index between two orbit signatures."""
    cycles1, _ = sig1
    cycles2, _ = sig2
    if not cycles1 or not cycles2:
        return 0.0
    c1 = Counter(cycles1)
    c2 = Counter(cycles2)
    common = sum((c1 & c2).values())
    return common / max(len(cycles1), len(cycles2))


def is_prime(n):
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


def get_primes(up_to):
    """Get all primes up to a given bound."""
    return [p for p in range(2, up_to + 1) if is_prime(p)]


# ============================================================
# Demo 1: Eventually Periodic Orbits (Theorem: eventually_periodic_of_finite)
# ============================================================
print("=" * 60)
print("DEMO 1: Eventually Periodic Orbits")
print("Every element of Z/pZ under x -> x^2 + c is eventually periodic")
print("=" * 60)

p = 17
c = 3
print(f"\nMap: x -> x^2 + {c} (mod {p})")
print(f"Computing orbits for all elements of Z/{p}Z:\n")

for x in range(p):
    pre, per, orbit = compute_orbit(lambda v, m: quadratic_map(v, c, m), x, p)
    orbit_str = " -> ".join(str(o) for o in orbit[:pre + per + 1])
    if len(orbit) > pre + per:
        orbit_str += " -> ..."
    print(f"  x={x:2d}: preperiod={pre}, period={per}, orbit: {orbit_str}")

# ============================================================
# Demo 2: Orbit Signatures and Cross-Prime Synchronization
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Orbit Signatures Across Primes")
print("Computing cycle structure of x -> x^2 + c for different primes")
print("=" * 60)

primes = get_primes(50)
c_values = [0, -1, 3, 7]

for c in c_values:
    print(f"\nc = {c}:")
    for p in primes[:10]:
        sig, tree = orbit_signature(lambda v, m: quadratic_map(v, c, m), p)
        print(f"  p={p:3d}: cycles={sig}, tree_size={tree}")

# ============================================================
# Demo 3: Synchronization Matrix and Phase Transition
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Cross-Prime Synchronization Matrix")
print("Measuring synchronization between orbit structures at different primes")
print("=" * 60)

primes = get_primes(30)
c_test = [0, -1, -2, 3, 7, 11]  # First 3 exceptional, last 3 generic

for c in c_test:
    sigs = {}
    for p in primes:
        if p == 2:  # skip p=2 for quadratic maps
            continue
        sig = orbit_signature(lambda v, m: quadratic_map(v, c, m), p)
        sigs[p] = sig

    # Compute mean synchronization
    prime_list = sorted(sigs.keys())
    total_sync = 0
    count = 0
    for i in range(len(prime_list)):
        for j in range(i + 1, len(prime_list)):
            sync = adelic_sync_index(sigs[prime_list[i]], sigs[prime_list[j]])
            total_sync += sync
            count += 1
    mean_sync = total_sync / count if count > 0 else 0

    label = "EXCEPTIONAL" if c in [0, -1, -2] else "GENERIC"
    print(f"  c={c:3d} [{label:11s}]: mean_sync = {mean_sync:.4f}")

# ============================================================
# Demo 4: Periodic Orbit Counting (Theorem: periodic_orbits_size_divides)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Periodic Orbit Size Divisibility")
print("The number of points with minimal period n divides n")
print("=" * 60)

p = 31
print(f"\nMap: x -> x^2 + 1 (mod {p})")

for n in range(1, 16):
    # Count points with f^n(x) = x
    periodic_n = []
    for x in range(p):
        val = x
        for _ in range(n):
            val = quadratic_map(val, 1, p)
        if val == x:
            periodic_n.append(x)

    # Count points with MINIMAL period exactly n
    minimal_n = []
    for x in periodic_n:
        min_per = n
        for m in range(1, n):
            val = x
            for _ in range(m):
                val = quadratic_map(val, 1, p)
            if val == x:
                min_per = m
                break
        if min_per == n:
            minimal_n.append(x)

    if minimal_n:
        divides = len(minimal_n) % n == 0
        print(f"  n={n:2d}: |periodic|={len(periodic_n):3d}, "
              f"|minimal period n|={len(minimal_n):3d}, "
              f"n divides count: {divides} ({len(minimal_n)}/{n}={len(minimal_n) // n})")

# ============================================================
# Demo 5: Image Stabilization (Theorem: image_stabilization)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Image Stabilization")
print("Iterates of f eventually stabilize on finite types")
print("=" * 60)

p = 11
c = 2
print(f"\nMap: x -> x^2 + {c} (mod {p})")

for k in range(1, 15):
    image = set()
    for x in range(p):
        val = x
        for _ in range(k):
            val = quadratic_map(val, c, p)
        image.add(val)
    print(f"  f^[{k:2d}](Z/{p}Z) = {sorted(image)} (size={len(image)})")

print("\nThe image stabilizes once the transient part is consumed.")

# ============================================================
# Demo 6: Orbit Entropy (Theorem: orbit_entropy_le_log_card)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Orbit Entropy Bound")
print("Orbit entropy ≤ log_2(p) for maps on Z/pZ")
print("=" * 60)

for p in get_primes(50)[:12]:
    sig, tree = orbit_signature(lambda v, m: quadratic_map(v, 0, m), p)
    distinct_lengths = len(set(sig))
    entropy = log2(distinct_lengths) if distinct_lengths > 0 else 0
    bound = log2(p)
    print(f"  p={p:3d}: distinct cycle lengths={distinct_lengths}, "
          f"entropy={entropy:.3f}, log_2(p)={bound:.3f}, "
          f"bound holds: {entropy <= bound}")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


"""
Visualization 3: Functional Graph Structure

Visualizes the functional graph of x -> x^2 + c (mod p) for different
primes and parameters, showing the tree-and-cycle decomposition that
underlies the orbit signature. Each node is a residue class, and edges
show the action of the map. Cycle elements are highlighted.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import sqrt, pi, cos, sin


def compute_orbits(f, n):
    """Compute orbit data for f on {0, ..., n-1}."""
    preperiods = {}
    periods = {}
    for x in range(n):
        seen = {}
        val = x
        step = 0
        while val not in seen:
            seen[val] = step
            val = f(val)
            step += 1
        cycle_start = seen[val]
        period = step - cycle_start
        preperiods[x] = max(0, cycle_start - seen.get(x, 0))
        periods[x] = period
    
    # Identify cycle elements
    cycles = set()
    for x in range(n):
        if preperiods[x] == 0:
            # Check if truly on cycle
            val = f(x)
            path = [x]
            while val != x:
                path.append(val)
                val = f(val)
            for pt in path:
                cycles.add(pt)
    
    return preperiods, periods, cycles


def draw_functional_graph(ax, f, n, title):
    """Draw the functional graph of f on {0, ..., n-1}."""
    preperiods, periods, cycles = compute_orbits(f, n)
    
    # Layout: place cycle elements in a circle, tree elements outside
    cycle_list = sorted(cycles)
    tree_list = [x for x in range(n) if x not in cycles]
    
    positions = {}
    
    # Place cycle elements in a circle
    if cycle_list:
        for i, x in enumerate(cycle_list):
            angle = 2 * pi * i / len(cycle_list) - pi / 2
            positions[x] = (0.5 + 0.25 * cos(angle), 0.5 + 0.25 * sin(angle))
    
    # Place tree elements outside, near their eventual cycle entry
    for x in tree_list:
        # Find which cycle element this tree node leads to
        val = x
        depth = 0
        while val not in cycles:
            val = f(val)
            depth += 1
        # Place near the cycle entry with some offset
        if val in positions:
            cx, cy = positions[val]
            angle = 2 * pi * (hash((x, depth)) % 360) / 360
            r = 0.15 + 0.08 * depth
            positions[x] = (cx + r * cos(angle), cy + r * sin(angle))
        else:
            positions[x] = (np.random.uniform(0.1, 0.9), np.random.uniform(0.1, 0.9))
    
    # Draw edges
    for x in range(n):
        y = f(x)
        if x != y:
            x1, y1 = positions[x]
            x2, y2 = positions[y]
            dx, dy = x2 - x1, y2 - y1
            length = sqrt(dx*dx + dy*dy)
            if length > 0:
                # Shorten arrow slightly
                shrink = 0.02
                ax.annotate('', xy=(x2 - shrink*dx/length, y2 - shrink*dy/length),
                          xytext=(x1 + shrink*dx/length, y1 + shrink*dy/length),
                          arrowprops=dict(arrowstyle='->', color='#7f8c8d',
                                        lw=0.8, connectionstyle='arc3,rad=0.1'))
    
    # Draw nodes
    for x in range(n):
        px, py = positions[x]
        if x in cycles:
            circle = plt.Circle((px, py), 0.025, color='#e74c3c',
                              ec='#c0392b', linewidth=1.5, zorder=5)
            ax.add_patch(circle)
            ax.text(px, py, str(x), ha='center', va='center',
                   fontsize=7, fontweight='bold', color='white', zorder=6)
        else:
            circle = plt.Circle((px, py), 0.02, color='#3498db',
                              ec='#2980b9', linewidth=1, zorder=5)
            ax.add_patch(circle)
            ax.text(px, py, str(x), ha='center', va='center',
                   fontsize=6, color='white', zorder=6)
    
    # Stats
    cycle_count = 0
    counted = set()
    for x in cycles:
        if x not in counted:
            cycle_count += 1
            val = f(x)
            counted.add(x)
            while val != x:
                counted.add(val)
                val = f(val)
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=10, fontweight='bold')
    ax.text(0.02, 0.02, f'{len(cycles)} periodic, {len(tree_list)} tree, {cycle_count} cycles',
            fontsize=7, transform=ax.transAxes,
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax.axis('off')


# Create figure
fig, axes = plt.subplots(3, 3, figsize=(15, 15))
fig.suptitle('Functional Graphs of x → x² + c (mod p)\nRed = Periodic Points, Blue = Tree Points',
             fontsize=16, fontweight='bold')

configs = [
    (11, 0), (11, -1), (11, 3),
    (13, 0), (13, -1), (13, 3),
    (17, 0), (17, -1), (17, 3),
]

for idx, (p, c) in enumerate(configs):
    ax = axes[idx // 3][idx % 3]
    f = lambda x, p=p, c=c: (x * x + c) % p
    draw_functional_graph(ax, f, p, f'p = {p}, c = {c}')

plt.tight_layout()
plt.savefig('functional_graphs.png', dpi=150, bbox_inches='tight')
print("Saved functional_graphs.png")


"""
Visualization 2: Phase Transition in Synchronization Landscape

Shows the mean cross-prime synchronization index as a function of the
parameter c in the quadratic family x -> x^2 + c. The plot reveals a
bimodal distribution: exceptional parameters (with special algebraic
relations among critical orbits) cluster at high synchronization,
while generic parameters remain at low synchronization.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import Counter
from math import sqrt


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(sqrt(n)) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def orbit_signature(f, domain):
    visited = set()
    cycle_lengths = []
    tree_size = 0
    for start in domain:
        if start in visited:
            continue
        path = []
        seen = {}
        x = start
        step = 0
        while x not in seen and x not in visited:
            seen[x] = step
            path.append(x)
            x = f(x)
            step += 1
        if x in visited:
            for pt in path:
                visited.add(pt)
                tree_size += 1
        else:
            cycle_start = seen[x]
            period = step - cycle_start
            cycle_lengths.append(period)
            for i, pt in enumerate(path):
                visited.add(pt)
                if i < cycle_start:
                    tree_size += 1
    return sorted(cycle_lengths), tree_size


def sync_index(sig1, sig2):
    c1, _ = sig1
    c2, _ = sig2
    if not c1 or not c2:
        return 0.0
    counter1 = Counter(c1)
    counter2 = Counter(c2)
    common = sum((counter1 & counter2).values())
    return common / max(len(c1), len(c2))


def mean_sync(c, primes):
    sigs = {}
    for p in primes:
        f = lambda x, p=p, c=c: (x * x + c) % p
        sigs[p] = orbit_signature(f, list(range(p)))
    
    total = 0
    count = 0
    for i in range(len(primes)):
        for j in range(i + 1, len(primes)):
            total += sync_index(sigs[primes[i]], sigs[primes[j]])
            count += 1
    return total / count if count else 0


# Setup
primes = [p for p in sieve_primes(40) if p > 2]
c_range = list(range(-15, 16))

# Compute synchronization for each parameter
syncs = []
for c in c_range:
    ms = mean_sync(c, primes)
    syncs.append(ms)

# Known exceptional parameters
exceptional = {0: 'Fixed: 0↦0',
               -1: 'Period 2: 0↦-1↦0',
               -2: '0↦-2↦2↦2'}

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10), height_ratios=[2, 1])
fig.suptitle('Adelic Synchronization Phase Transition\nQuadratic Family x → x² + c',
             fontsize=16, fontweight='bold')

# Top plot: bar chart
colors = ['#e74c3c' if c in exceptional else '#3498db' for c in c_range]
bars = ax1.bar(c_range, syncs, color=colors, alpha=0.8, edgecolor='white', linewidth=0.5)

# Add threshold line
threshold = 0.5 * (max(syncs) + np.median(syncs))
ax1.axhline(y=threshold, color='#2c3e50', linestyle='--', linewidth=1.5,
            label=f'Threshold τ ≈ {threshold:.3f}')

# Annotate exceptional parameters
for c, label in exceptional.items():
    if c in c_range:
        idx = c_range.index(c)
        ax1.annotate(label, (c, syncs[idx]),
                    textcoords="offset points", xytext=(0, 15),
                    ha='center', fontsize=8, fontweight='bold',
                    arrowprops=dict(arrowstyle='->', color='#e74c3c'),
                    color='#e74c3c')

ax1.set_xlabel('Parameter c', fontsize=12)
ax1.set_ylabel('Mean Cross-Prime\nSynchronization', fontsize=12)
ax1.legend(fontsize=10, loc='upper right')
ax1.set_ylim(0, max(syncs) * 1.3)

# Add legend patches
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='#e74c3c', alpha=0.8, label='Exceptional'),
                   Patch(facecolor='#3498db', alpha=0.8, label='Generic')]
ax1.legend(handles=legend_elements, loc='upper left', fontsize=10)

# Bottom plot: histogram of sync values
ax2.hist(syncs, bins=20, color='#95a5a6', edgecolor='white', alpha=0.8)
ax2.axvline(x=threshold, color='#e74c3c', linestyle='--', linewidth=1.5,
            label=f'Threshold τ')
ax2.set_xlabel('Mean Synchronization Value', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Distribution of Synchronization Values', fontsize=12)
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved phase_transition.png")


"""
Visualization 1: Cross-Prime Synchronization Heatmap

Visualizes the pairwise synchronization index between orbit structures
of the quadratic map x -> x^2 + c modulo different primes. Each cell (i,j)
shows the synchronization index between primes p_i and p_j for a given
parameter c. Exceptional parameters (c=0, -1) show distinct patterns
compared to generic parameters (c=3, 7).
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import Counter
from math import sqrt


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(sqrt(n)) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def orbit_signature(f, domain):
    visited = set()
    cycle_lengths = []
    tree_size = 0
    for start in domain:
        if start in visited:
            continue
        path = []
        seen = {}
        x = start
        step = 0
        while x not in seen and x not in visited:
            seen[x] = step
            path.append(x)
            x = f(x)
            step += 1
        if x in visited:
            for pt in path:
                visited.add(pt)
                tree_size += 1
        else:
            cycle_start = seen[x]
            period = step - cycle_start
            cycle_lengths.append(period)
            for i, pt in enumerate(path):
                visited.add(pt)
                if i < cycle_start:
                    tree_size += 1
    return sorted(cycle_lengths), tree_size


def sync_index(sig1, sig2):
    c1, _ = sig1
    c2, _ = sig2
    if not c1 or not c2:
        return 0.0
    counter1 = Counter(c1)
    counter2 = Counter(c2)
    common = sum((counter1 & counter2).values())
    return common / max(len(c1), len(c2))


# Setup
primes = [p for p in sieve_primes(60) if p > 2][:12]
c_values = [0, -1, 3, 7]
titles = ['c = 0 (Exceptional)', 'c = -1 (Exceptional)',
          'c = 3 (Generic)', 'c = 7 (Generic)']

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Cross-Prime Synchronization Matrices\nfor Quadratic Maps x → x² + c',
             fontsize=16, fontweight='bold')

for idx, (c, title) in enumerate(zip(c_values, titles)):
    ax = axes[idx // 2][idx % 2]
    
    sigs = {}
    for p in primes:
        f = lambda x, p=p, c=c: (x * x + c) % p
        sigs[p] = orbit_signature(f, list(range(p)))
    
    n = len(primes)
    matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i == j:
                matrix[i][j] = 1.0
            else:
                matrix[i][j] = sync_index(sigs[primes[i]], sigs[primes[j]])
    
    im = ax.imshow(matrix, cmap='YlOrRd', vmin=0, vmax=1, aspect='equal')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(primes, fontsize=8, rotation=45)
    ax.set_yticklabels(primes, fontsize=8)
    ax.set_xlabel('Prime p', fontsize=10)
    ax.set_ylabel('Prime q', fontsize=10)
    ax.set_title(title, fontsize=12, fontweight='bold')
    
    mean = np.mean(matrix[np.triu_indices(n, k=1)])
    ax.text(0.02, 0.98, f'Mean sync: {mean:.3f}',
            transform=ax.transAxes, fontsize=10,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

fig.colorbar(im, ax=axes, shrink=0.6, label='Synchronization Index')
plt.tight_layout()
plt.savefig('sync_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved sync_heatmap.png")
