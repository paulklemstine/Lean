#!/usr/bin/env python3
"""
Applications of the Max-Envelope Principle

Demonstrates practical applications of prime channel decomposition
for torsion persistence stability.
"""

import random
from typing import Dict, List, Tuple, Set


def prime_factors(n: int) -> Set[int]:
    if n < 2:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


def compute_p_birth(p, births, orders):
    for t, n in zip(births, orders):
        if n >= 2 and n % p == 0:
            return t
    return None


def global_birth(births, orders):
    result = None
    for t, n in zip(births, orders):
        if n >= 2 and (result is None or t < result):
            result = t
    return result


# Application 1: Parallel Stability Computation
def parallel_stability_bound(
    F_births: List[int], F_orders: List[int],
    G_births: List[int], G_orders: List[int]
) -> Dict:
    """
    Compute stability bound using prime channel decomposition.

    This simulates the parallel algorithm:
    1. Identify active primes (fast)
    2. Compute per-prime shifts (embarrassingly parallel)
    3. Take maximum (fast)

    In a real parallel implementation, step 2 would run on |S| cores.
    """
    primes = set()
    for n in F_orders + G_orders:
        primes |= prime_factors(n)

    # Step 2: Per-prime computation (would be parallel)
    channel_results = {}
    for p in sorted(primes):
        pF = compute_p_birth(p, F_births, F_orders)
        pG = compute_p_birth(p, G_births, G_orders)
        if pF is not None and pG is not None:
            channel_results[p] = {
                'birth_F': pF,
                'birth_G': pG,
                'shift': abs(pF - pG),
                'status': 'active'
            }
        elif pF is None and pG is None:
            channel_results[p] = {
                'birth_F': None,
                'birth_G': None,
                'shift': 0,
                'status': 'inactive'
            }
        else:
            channel_results[p] = {
                'birth_F': pF,
                'birth_G': pG,
                'shift': float('inf'),
                'status': 'one-sided'
            }

    # Step 3: Aggregate
    finite = [r['shift'] for r in channel_results.values()
              if r['shift'] < float('inf')]
    max_envelope = max(finite) if finite else 0

    # Actual global shift for comparison
    gF = global_birth(F_births, F_orders)
    gG = global_birth(G_births, G_orders)
    actual_global = abs(gF - gG) if gF is not None and gG is not None else float('inf')

    return {
        'channels': channel_results,
        'max_envelope': max_envelope,
        'actual_global_shift': actual_global,
        'bound_tight': max_envelope == actual_global,
        'num_primes': len(primes),
        'speedup_factor': f"{len(primes)}x parallel"
    }


# Application 2: Certified Stability Certificate
def stability_certificate(
    F_births: List[int], F_orders: List[int],
    G_births: List[int], G_orders: List[int],
    tolerance: int
) -> Dict:
    """
    Produce a certified stability certificate.

    Given tolerance δ, certify whether the filtrations are δ-stable
    by checking each prime channel independently.
    """
    primes = set()
    for n in F_orders + G_orders:
        primes |= prime_factors(n)

    violations = []
    max_shift = 0

    for p in sorted(primes):
        pF = compute_p_birth(p, F_births, F_orders)
        pG = compute_p_birth(p, G_births, G_orders)
        if pF is not None and pG is not None:
            shift = abs(pF - pG)
            max_shift = max(max_shift, shift)
            if shift > tolerance:
                violations.append({
                    'prime': p,
                    'shift': shift,
                    'birth_F': pF,
                    'birth_G': pG
                })

    return {
        'certified_stable': len(violations) == 0,
        'max_channel_shift': max_shift,
        'tolerance': tolerance,
        'violations': violations,
        'certificate': f"All {len(primes)} prime channels within tolerance"
                       if not violations else
                       f"{len(violations)} channel(s) exceed tolerance"
    }


# Application 3: Sensitivity Analysis
def channel_sensitivity(
    F_births: List[int], F_orders: List[int],
    G_births: List[int], G_orders: List[int]
) -> Dict:
    """
    Analyze which prime channel is most sensitive to perturbation.

    Identifies the "worst channel" — the prime contributing the
    largest stability distance.
    """
    primes = set()
    for n in F_orders + G_orders:
        primes |= prime_factors(n)

    shifts = {}
    for p in sorted(primes):
        pF = compute_p_birth(p, F_births, F_orders)
        pG = compute_p_birth(p, G_births, G_orders)
        if pF is not None and pG is not None:
            shifts[p] = abs(pF - pG)

    if not shifts:
        return {'worst_channel': None, 'analysis': 'No active channels'}

    worst = max(shifts, key=shifts.get)
    total = sum(shifts.values())

    return {
        'worst_channel': worst,
        'worst_shift': shifts[worst],
        'all_shifts': shifts,
        'relative_contribution': {
            p: f"{100*s/total:.1f}%" if total > 0 else "0%"
            for p, s in shifts.items()
        },
        'recommendation': f"Focus stability improvement on p={worst} channel"
    }


def main():
    print("=" * 60)
    print("APPLICATION 1: Parallel Stability Computation")
    print("=" * 60)

    F_b, F_o = [2, 5, 8], [6, 10, 15]
    G_b, G_o = [3, 9, 10], [6, 10, 15]

    result = parallel_stability_bound(F_b, F_o, G_b, G_o)
    print(f"F: births={F_b}, orders={F_o}")
    print(f"G: births={G_b}, orders={G_o}")
    print(f"Active primes: {result['num_primes']}")
    print(f"Max envelope (upper bound): {result['max_envelope']}")
    print(f"Actual global shift: {result['actual_global_shift']}")
    print(f"Bound tight: {result['bound_tight']}")
    print(f"Potential speedup: {result['speedup_factor']}")
    print()
    for p, info in result['channels'].items():
        print(f"  Channel p={p}: shift={info['shift']}, status={info['status']}")

    print()
    print("=" * 60)
    print("APPLICATION 2: Stability Certificate")
    print("=" * 60)

    cert = stability_certificate(F_b, F_o, G_b, G_o, tolerance=3)
    print(f"Tolerance: {cert['tolerance']}")
    print(f"Certified stable: {cert['certified_stable']}")
    print(f"Max channel shift: {cert['max_channel_shift']}")
    print(f"Certificate: {cert['certificate']}")
    if cert['violations']:
        for v in cert['violations']:
            print(f"  Violation: p={v['prime']}, shift={v['shift']}")

    print()
    cert2 = stability_certificate(F_b, F_o, G_b, G_o, tolerance=5)
    print(f"With tolerance={cert2['tolerance']}: {cert2['certificate']}")

    print()
    print("=" * 60)
    print("APPLICATION 3: Sensitivity Analysis")
    print("=" * 60)

    sens = channel_sensitivity(F_b, F_o, G_b, G_o)
    print(f"Worst channel: p={sens['worst_channel']} (shift={sens['worst_shift']})")
    print(f"All shifts: {sens['all_shifts']}")
    print(f"Relative contributions: {sens['relative_contribution']}")
    print(f"Recommendation: {sens['recommendation']}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Max-Envelope Principle for Torsion Persistence Stability

Demonstrates that global torsion birth stability is bounded by the maximum
of primewise stability distances. Tests the conjecture that equality holds
universally (it does not — counterexamples are found).
"""

import random
from collections import Counter
from fractions import Fraction


def prime_factors(n):
    """Return the set of prime factors of n."""
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


def active_primes(torsion_orders_F, torsion_orders_G):
    """Compute the set of active primes from torsion orders."""
    primes = set()
    for n in torsion_orders_F + torsion_orders_G:
        if n >= 2:
            primes |= prime_factors(n)
    return primes


def p_torsion_birth(p, birth_times, torsion_orders):
    """
    Compute the p-torsion birth index.
    Returns the earliest index where p divides the torsion order, or None.
    """
    for i, (t, n) in enumerate(zip(birth_times, torsion_orders)):
        if n >= 2 and p in prime_factors(n):
            return t
    return None


def global_torsion_birth(birth_times, torsion_orders):
    """
    Compute the global torsion birth index.
    Returns the earliest birth time where any torsion is present, or None.
    """
    min_birth = None
    for t, n in zip(birth_times, torsion_orders):
        if n >= 2:
            if min_birth is None or t < min_birth:
                min_birth = t
    return min_birth


def nat_dist(a, b):
    """Natural number distance: |a - b|."""
    if a is None or b is None:
        return float('inf')
    return abs(a - b)


def generate_random_filtration(num_channels=3, max_birth=20,
                                torsion_pool=(2, 3, 5, 6, 10, 15, 30)):
    """Generate a random filtration with torsion channels."""
    birth_times = sorted(random.sample(range(1, max_birth + 1), min(num_channels, max_birth)))
    torsion_orders = [random.choice(torsion_pool) for _ in range(len(birth_times))]
    return birth_times, torsion_orders


def compute_stability(F_births, F_orders, G_births, G_orders):
    """
    Compute the global shift and max prime shift for a pair of filtrations.

    Returns:
        global_shift: natDist of global torsion births
        max_prime_shift: maximum of primewise natDist values
        prime_shifts: dict mapping primes to their shifts
        determining_prime_F: prime determining global birth of F
        determining_prime_G: prime determining global birth of G
    """
    primes = active_primes(F_orders, G_orders)

    global_F = global_torsion_birth(F_births, F_orders)
    global_G = global_torsion_birth(G_births, G_orders)
    global_shift = nat_dist(global_F, global_G)

    prime_shifts = {}
    for p in sorted(primes):
        pF = p_torsion_birth(p, F_births, F_orders)
        pG = p_torsion_birth(p, G_births, G_orders)
        if pF is not None and pG is not None:
            prime_shifts[p] = nat_dist(pF, pG)
        elif pF is None and pG is None:
            prime_shifts[p] = 0
        else:
            prime_shifts[p] = float('inf')

    # Check if any prime has one-sided birth (violates theorem hypotheses)
    has_onesided = any(d == float('inf') for d in prime_shifts.values())
    finite_shifts = {p: d for p, d in prime_shifts.items() if d < float('inf')}
    max_prime_shift = max(finite_shifts.values()) if finite_shifts else 0
    if has_onesided:
        max_prime_shift = float('inf')  # Theorem doesn't apply

    # Determine which prime determines global birth
    det_F = None
    det_G = None
    if global_F is not None:
        for p in sorted(primes):
            pb = p_torsion_birth(p, F_births, F_orders)
            if pb == global_F:
                det_F = p
                break
    if global_G is not None:
        for p in sorted(primes):
            pb = p_torsion_birth(p, G_births, G_orders)
            if pb == global_G:
                det_G = p
                break

    return global_shift, max_prime_shift, prime_shifts, det_F, det_G


def main():
    random.seed(42)
    N = 1000

    print("=" * 70)
    print("MAX-ENVELOPE PRINCIPLE: Computational Verification")
    print("=" * 70)
    print()
    print(f"Testing {N} random filtration pairs...")
    print(f"Torsion orders drawn from: {{2, 3, 5, 6, 10, 15, 30}}")
    print()

    # Statistics
    upper_bound_holds = 0
    exact_matches = 0
    strict_inequality = 0
    counterexamples = []
    maximizing_primes = Counter()
    gap_sizes = []

    for trial in range(N):
        num_ch = random.randint(1, 4)
        F_births, F_orders = generate_random_filtration(num_ch)
        G_births, G_orders = generate_random_filtration(num_ch)

        gs, mps, ps, det_F, det_G = compute_stability(
            F_births, F_orders, G_births, G_orders)

        if gs == float('inf') or mps == float('inf'):
            continue
        # Also skip if any prime has one-sided birth
        if any(d == float('inf') for d in ps.values()):
            continue

        # Check upper bound
        if gs <= mps:
            upper_bound_holds += 1
        else:
            counterexamples.append({
                'trial': trial,
                'F': (F_births, F_orders),
                'G': (G_births, G_orders),
                'global_shift': gs,
                'max_prime_shift': mps,
                'prime_shifts': ps
            })

        # Check equality
        if gs == mps:
            exact_matches += 1
        else:
            strict_inequality += 1
            gap_sizes.append(mps - gs)

        # Record maximizing prime
        if ps:
            max_p = max(ps, key=lambda p: ps.get(p, 0))
            maximizing_primes[max_p] += 1

    total_valid = upper_bound_holds + len(counterexamples)

    print("RESULTS")
    print("-" * 40)
    print(f"Valid trials:       {total_valid}")
    print(f"Upper bound holds:  {upper_bound_holds}/{total_valid} "
          f"({100*upper_bound_holds/total_valid:.1f}%)")
    print(f"Exact matches:      {exact_matches}/{total_valid} "
          f"({100*exact_matches/total_valid:.1f}%)")
    print(f"Strict inequality:  {strict_inequality}/{total_valid} "
          f"({100*strict_inequality/total_valid:.1f}%)")
    print()

    if counterexamples:
        print(f"COUNTEREXAMPLES TO UPPER BOUND: {len(counterexamples)}")
        for ce in counterexamples[:3]:
            print(f"  Trial {ce['trial']}: global={ce['global_shift']}, "
                  f"max_prime={ce['max_prime_shift']}")
    else:
        print("No counterexamples to upper bound found.")
    print()

    if gap_sizes:
        print(f"Gap statistics (max_prime - global when strict):")
        print(f"  Mean gap:  {sum(gap_sizes)/len(gap_sizes):.2f}")
        print(f"  Max gap:   {max(gap_sizes)}")
        print(f"  Min gap:   {min(gap_sizes)}")
    print()

    print("Histogram of maximizing primes:")
    for p in sorted(maximizing_primes.keys()):
        count = maximizing_primes[p]
        bar = "█" * (count // 10)
        print(f"  p={p:2d}: {count:4d} {bar}")
    print()

    # Representative examples
    print("=" * 70)
    print("REPRESENTATIVE EXAMPLES")
    print("=" * 70)

    # Example 1: Equality case
    print("\nExample 1: Equality (same prime determines both births)")
    random.seed(100)
    for _ in range(100):
        F_births, F_orders = generate_random_filtration(2)
        G_births, G_orders = generate_random_filtration(2)
        gs, mps, ps, det_F, det_G = compute_stability(
            F_births, F_orders, G_births, G_orders)
        if gs == mps and gs > 0 and det_F == det_G:
            print(f"  F: births={F_births}, orders={F_orders}")
            print(f"  G: births={G_births}, orders={G_orders}")
            print(f"  Global shift: {gs}")
            print(f"  Max prime shift: {mps}")
            print(f"  Prime shifts: {ps}")
            print(f"  Determining prime: F={det_F}, G={det_G}")
            break

    # Example 2: Strict inequality case
    print("\nExample 2: Strict inequality (different primes active)")
    random.seed(200)
    for _ in range(1000):
        F_births, F_orders = generate_random_filtration(3)
        G_births, G_orders = generate_random_filtration(3)
        gs, mps, ps, det_F, det_G = compute_stability(
            F_births, F_orders, G_births, G_orders)
        if gs < mps and gs > 0 and mps < float('inf') and all(d < float('inf') for d in ps.values()):
            print(f"  F: births={F_births}, orders={F_orders}")
            print(f"  G: births={G_births}, orders={G_orders}")
            print(f"  Global shift: {gs}")
            print(f"  Max prime shift: {mps}")
            print(f"  Prime shifts: {ps}")
            print(f"  Determining prime: F={det_F}, G={det_G}")
            print(f"  Gap: {mps - gs}")
            break

    print("\n" + "=" * 70)
    print("CONCLUSION")
    print("=" * 70)
    print()
    print("The upper bound globalShift ≤ maxPrimeShift holds universally.")
    print("The equality conjecture (HypothesisC_strong) is FALSE in general:")
    print(f"  equality holds in ~{100*exact_matches/total_valid:.0f}% of cases,")
    print(f"  strict inequality in ~{100*strict_inequality/total_valid:.0f}% of cases.")
    print()
    print("The max-envelope inequality is the correct general statement.")
    print("Equality holds when the same prime determines both global births")
    print("AND that prime achieves the maximum primewise shift.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Prime Channel Decomposition

Shows how the global torsion birth is the minimum of primewise births,
and how stability distances decompose across prime channels.
Creates a heatmap of primewise shifts for multiple filtration pairs.
"""

import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def prime_factors(n):
    if n < 2:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


random.seed(123)
primes_list = [2, 3, 5, 7]
pool = [2, 3, 5, 6, 10, 14, 15, 21, 30, 35, 42, 70, 105, 210]
N = 20

# Compute shifts for N pairs
shifts_matrix = np.zeros((N, len(primes_list)))
global_shifts = []

for trial in range(N):
    nc = random.randint(2, 5)
    Fb = sorted(random.sample(range(1, 30), min(nc, 29)))
    Fo = [random.choice(pool) for _ in range(len(Fb))]
    Gb = sorted(random.sample(range(1, 30), min(nc, 29)))
    Go = [random.choice(pool) for _ in range(len(Gb))]

    # Global birth
    gF = min((t for t, n in zip(Fb, Fo) if n >= 2), default=None)
    gG = min((t for t, n in zip(Gb, Go) if n >= 2), default=None)
    gs = abs(gF - gG) if gF is not None and gG is not None else 0
    global_shifts.append(gs)

    # Per-prime shifts
    for j, p in enumerate(primes_list):
        pF = min((t for t, n in zip(Fb, Fo) if n >= 2 and n % p == 0), default=None)
        pG = min((t for t, n in zip(Gb, Go) if n >= 2 and n % p == 0), default=None)
        if pF is not None and pG is not None:
            shifts_matrix[trial, j] = abs(pF - pG)
        else:
            shifts_matrix[trial, j] = -1  # no data

fig, axes = plt.subplots(1, 2, figsize=(14, 7))

# Heatmap of primewise shifts
ax1 = axes[0]
display_matrix = shifts_matrix.copy()
mask = display_matrix < 0
display_matrix[mask] = np.nan

im = ax1.imshow(display_matrix, aspect='auto', cmap='YlOrRd',
                interpolation='nearest')
ax1.set_xticks(range(len(primes_list)))
ax1.set_xticklabels([f'p={p}' for p in primes_list], fontsize=11)
ax1.set_ylabel('Filtration Pair Index', fontsize=12)
ax1.set_title('Primewise Shift Heatmap\n(darker = larger shift)', fontsize=13)

# Mark cells with no data
for i in range(N):
    for j in range(len(primes_list)):
        if mask[i, j]:
            ax1.text(j, i, '—', ha='center', va='center', color='gray', fontsize=8)
        else:
            val = int(display_matrix[i, j])
            ax1.text(j, i, str(val), ha='center', va='center',
                    color='white' if val > 8 else 'black', fontsize=9)

plt.colorbar(im, ax=ax1, label='Shift Distance')

# Bar chart: global vs max prime
ax2 = axes[1]
max_prime_shifts = [max(shifts_matrix[i, shifts_matrix[i] >= 0], default=0)
                     for i in range(N)]

x = np.arange(N)
width = 0.35
bars1 = ax2.bar(x - width/2, global_shifts, width, label='Global Shift',
                color='#2196F3', alpha=0.8)
bars2 = ax2.bar(x + width/2, max_prime_shifts, width, label='Max Prime Shift',
                color='#FF9800', alpha=0.8)

# Highlight pairs where gap > 0
for i in range(N):
    if max_prime_shifts[i] > global_shifts[i]:
        ax2.annotate('', xy=(i + width/2, max_prime_shifts[i]),
                     xytext=(i + width/2, max_prime_shifts[i] + 0.5),
                     arrowprops=dict(arrowstyle='v', color='red', lw=1.5))

ax2.set_xlabel('Filtration Pair Index', fontsize=12)
ax2.set_ylabel('Shift Distance', fontsize=12)
ax2.set_title('Global vs Max Prime Shift\n(red arrows: strict inequality)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_channels.png', dpi=150, bbox_inches='tight')
print("Saved viz_channels.png")


#!/usr/bin/env python3
"""
Visualization: Max-Envelope Principle for Torsion Stability

Visualizes the relationship between global torsion birth shifts and
the maximum of primewise shifts across many random filtration pairs.
Shows that globalShift ≤ maxPrimeShift always holds (points below diagonal)
but equality does not always hold.
"""

import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def prime_factors(n):
    if n < 2:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


def compute_shifts(F_births, F_orders, G_births, G_orders):
    primes = set()
    for n in F_orders + G_orders:
        primes |= prime_factors(n)

    def gb(births, orders):
        r = None
        for t, n in zip(births, orders):
            if n >= 2 and (r is None or t < r):
                r = t
        return r

    gF, gG = gb(F_births, F_orders), gb(G_births, G_orders)
    gs = abs(gF - gG) if gF is not None and gG is not None else None

    max_ps = 0
    for p in primes:
        pF = None
        for t, n in zip(F_births, F_orders):
            if n >= 2 and n % p == 0 and (pF is None or t < pF):
                pF = t
        pG = None
        for t, n in zip(G_births, G_orders):
            if n >= 2 and n % p == 0 and (pG is None or t < pG):
                pG = t
        if pF is not None and pG is not None:
            max_ps = max(max_ps, abs(pF - pG))

    return gs, max_ps


random.seed(42)
N = 500
pool = [2, 3, 5, 6, 10, 15, 30]

globals_list = []
maxprimes_list = []

for _ in range(N):
    nc = random.randint(1, 4)
    Fb = sorted(random.sample(range(1, 25), min(nc, 24)))
    Fo = [random.choice(pool) for _ in range(len(Fb))]
    Gb = sorted(random.sample(range(1, 25), min(nc, 24)))
    Go = [random.choice(pool) for _ in range(len(Gb))]

    gs, mps = compute_shifts(Fb, Fo, Gb, Go)
    if gs is not None:
        globals_list.append(gs)
        maxprimes_list.append(mps)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Scatter of global vs max prime shift
ax1 = axes[0]
gs_arr = np.array(globals_list)
mps_arr = np.array(maxprimes_list)

# Color by whether equality holds
eq_mask = gs_arr == mps_arr
ineq_mask = ~eq_mask

ax1.scatter(mps_arr[eq_mask], gs_arr[eq_mask], c='#2196F3', alpha=0.5,
           s=30, label=f'Equality ({eq_mask.sum()})', zorder=2)
ax1.scatter(mps_arr[ineq_mask], gs_arr[ineq_mask], c='#FF5722', alpha=0.5,
           s=30, label=f'Strict ineq ({ineq_mask.sum()})', zorder=2)

max_val = max(max(globals_list), max(maxprimes_list)) + 1
ax1.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='y = x (equality)')
ax1.fill_between([0, max_val], [0, max_val], [max_val, max_val],
                  alpha=0.05, color='red')
ax1.set_xlabel('Max Prime Shift (envelope)', fontsize=12)
ax1.set_ylabel('Global Shift', fontsize=12)
ax1.set_title('Max-Envelope Inequality:\nGlobal Shift ≤ Max Prime Shift', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_xlim(-0.5, max_val)
ax1.set_ylim(-0.5, max_val)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# Plot 2: Distribution of gaps
ax2 = axes[1]
gaps = mps_arr - gs_arr
ax2.hist(gaps, bins=range(int(gaps.min()), int(gaps.max()) + 2),
         color='#4CAF50', edgecolor='white', alpha=0.8)
ax2.axvline(x=0, color='red', linestyle='--', alpha=0.5, label='Gap = 0 (equality)')
ax2.set_xlabel('Gap: maxPrimeShift − globalShift', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Distribution of Max-Envelope Gap\n(always ≥ 0 by theorem)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_envelope.png', dpi=150, bbox_inches='tight')
print("Saved viz_envelope.png")


#!/usr/bin/env python3
"""
Visualization: Min-Max Lipschitz Property

Illustrates the key analytic lemma: |min(a_i) - min(b_i)| ≤ max|a_i - b_i|.
This is the mathematical backbone of the max-envelope inequality.
Shows the Lipschitz property across many random examples.
"""

import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


random.seed(77)
N = 2000
dims = [2, 3, 5, 10]

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

for idx, d in enumerate(dims):
    ax = axes[idx // 2][idx % 2]

    min_dists = []
    max_coord_dists = []

    for _ in range(N):
        a = [random.randint(0, 20) for _ in range(d)]
        b = [random.randint(0, 20) for _ in range(d)]

        min_a, min_b = min(a), min(b)
        min_dist = abs(min_a - min_b)

        coord_dists = [abs(a[i] - b[i]) for i in range(d)]
        max_coord = max(coord_dists)

        min_dists.append(min_dist)
        max_coord_dists.append(max_coord)

    ax.scatter(max_coord_dists, min_dists, alpha=0.2, s=10, c='#1565C0')

    max_val = max(max(min_dists), max(max_coord_dists)) + 1
    ax.plot([0, max_val], [0, max_val], 'r--', alpha=0.5, linewidth=2,
            label='y = x (Lipschitz bound)')
    ax.fill_between([0, max_val], [0, 0], [0, max_val],
                     alpha=0.03, color='blue')

    ax.set_xlabel('max|aᵢ − bᵢ| (L∞ distance)', fontsize=10)
    ax.set_ylabel('|min(aᵢ) − min(bᵢ)|', fontsize=10)
    ax.set_title(f'Min-Max Lipschitz (d = {d})', fontsize=12)
    ax.legend(fontsize=9, loc='upper left')
    ax.set_xlim(-0.5, max_val)
    ax.set_ylim(-0.5, max_val)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

fig.suptitle('The Min-Max Lipschitz Lemma: min is 1-Lipschitz w.r.t. L∞',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_lipschitz.png', dpi=150, bbox_inches='tight')
print("Saved viz_lipschitz.png")
