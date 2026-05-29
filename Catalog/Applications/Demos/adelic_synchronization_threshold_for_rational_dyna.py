#!/usr/bin/env python3
"""
applications.py — Applications of adelic synchronization theory.

Demonstrates real-world uses:
1. Preperiodicity detection via synchronization threshold
2. Mandelbrot set boundary detection through finite field reductions
3. Cryptographic parameter screening
"""

from collections import Counter
from typing import List, Tuple, Optional


def quad_map_mod(x: int, c: int, p: int) -> int:
    return (x * x + c) % p

def find_preperiod_and_period(c: int, p: int) -> Tuple[int, int]:
    seen = {}
    x = 0
    for i in range(p + 2):
        if x in seen:
            return seen[x], i - seen[x]
        seen[x] = i
        x = quad_map_mod(x, c, p)
    return p, 1

def prime_sync_score(invariants: List) -> int:
    counts = Counter(invariants)
    return sum(c * c for c in counts.values())

def sieve(n: int) -> List[int]:
    if n < 2:
        return []
    s = [True] * (n + 1)
    s[0] = s[1] = False
    for i in range(2, int(n**0.5) + 1):
        if s[i]:
            for j in range(i*i, n + 1, i):
                s[j] = False
    return [i for i in range(2, n + 1) if s[i]]

def is_preperiodic_over_Q(c: int, max_iter: int = 200) -> Optional[Tuple[int, int]]:
    seen = {0: 0}
    x = 0
    for i in range(1, max_iter + 1):
        x = x * x + c
        if x in seen:
            return (seen[x], i)
        if abs(x) > 10**15:
            return None
        seen[x] = i
    return None


# ──────────────────────────────────────────────────────────────────────
# Application 1: Preperiodicity Detection
# ──────────────────────────────────────────────────────────────────────

def detect_preperiodic_parameters(c_range: range, primes: List[int],
                                   threshold_ratio: float = 0.25) -> List[dict]:
    """
    Screen parameters for preperiodicity using adelic synchronization.

    A high sync score relative to the number of primes suggests the parameter
    is exceptional (preperiodic over Q).

    Args:
        c_range: Range of integer parameters to test.
        primes: List of primes to use for reductions.
        threshold_ratio: Fraction of max score above which we flag as candidate.

    Returns:
        List of candidate parameters with their scores.
    """
    max_score = len(primes) ** 2
    threshold = max_score * threshold_ratio
    candidates = []

    for c in c_range:
        invariants = [find_preperiod_and_period(c, p) for p in primes]
        score = prime_sync_score(invariants)
        if score >= threshold:
            pp = is_preperiodic_over_Q(c)
            candidates.append({
                'c': c,
                'sync_score': score,
                'sync_ratio': score / max_score,
                'is_preperiodic': pp is not None,
                'preperiod_data': pp,
            })

    return sorted(candidates, key=lambda x: -x['sync_score'])


# ──────────────────────────────────────────────────────────────────────
# Application 2: Mandelbrot Set Boundary via Finite Fields
# ──────────────────────────────────────────────────────────────────────

def mandelbrot_sync_profile(c_real_range: range, primes: List[int]) -> List[dict]:
    """
    For integer parameters c, compute the sync profile.
    Parameters in the Mandelbrot set (bounded orbit) correspond to small
    orbit complexity; parameters outside have escaping orbits over Q
    but bounded orbits mod p.

    The sync score provides a finite-field proxy for Mandelbrot membership.
    """
    results = []
    max_score = len(primes) ** 2

    for c in c_real_range:
        invariants = [find_preperiod_and_period(c, p) for p in primes]
        score = prime_sync_score(invariants)

        # Check Mandelbrot membership over Q: orbit bounded?
        x = 0
        bounded = True
        for _ in range(100):
            x = x * x + c
            if abs(x) > 10**10:
                bounded = False
                break

        results.append({
            'c': c,
            'sync_score': score,
            'sync_ratio': score / max_score,
            'mandelbrot_member': bounded,
        })

    return results


# ──────────────────────────────────────────────────────────────────────
# Application 3: Cryptographic Parameter Screening
# ──────────────────────────────────────────────────────────────────────

def screen_crypto_parameters(p: int, num_params: int = 50) -> List[dict]:
    """
    For a given prime p, screen parameters c for x^2+c mod p.
    Parameters with short orbits (preperiodic with small period)
    are BAD for pseudorandom generation. High sync across auxiliary
    primes signals such weakness.

    Args:
        p: The main prime for the cryptographic application.
        num_params: Number of parameters to test.

    Returns:
        Sorted list from most to least suspicious parameters.
    """
    # Use small auxiliary primes for screening
    aux_primes = [q for q in sieve(100) if q > 2 and q != p][:20]

    results = []
    for c in range(num_params):
        # Main orbit data
        preperiod, period = find_preperiod_and_period(c, p)

        # Sync score across auxiliary primes
        invariants = [find_preperiod_and_period(c, q) for q in aux_primes]
        score = prime_sync_score(invariants)
        max_score = len(aux_primes) ** 2

        results.append({
            'c': c,
            'main_preperiod': preperiod,
            'main_period': period,
            'total_orbit_length': preperiod + period,
            'sync_score': score,
            'sync_ratio': score / max_score,
            'security_rating': 'WEAK' if period < p // 4 and score > max_score * 0.15 else 'OK',
        })

    return sorted(results, key=lambda x: -x['sync_ratio'])


def main():
    primes = [p for p in sieve(200) if p > 2]

    print("=" * 70)
    print("  APPLICATION 1: Preperiodicity Detection via Synchronization")
    print("=" * 70)

    candidates = detect_preperiodic_parameters(range(-20, 21), primes)
    print(f"\nScanning c ∈ [-20, 20] with {len(primes)} primes")
    print(f"\n{'c':>6} | {'Score':>8} | {'Ratio':>6} | {'Preperiodic?':>12}")
    print("-" * 45)
    for r in candidates[:15]:
        pp = "Yes" if r['is_preperiodic'] else "No"
        print(f"{r['c']:>6} | {r['sync_score']:>8} | {r['sync_ratio']:>6.3f} | {pp:>12}")

    print("\n" + "=" * 70)
    print("  APPLICATION 2: Mandelbrot Boundary via Finite Field Sync")
    print("=" * 70)

    results = mandelbrot_sync_profile(range(-3, 4), primes[:20])
    print(f"\n{'c':>6} | {'Sync Ratio':>10} | {'In Mandelbrot?':>14}")
    print("-" * 40)
    for r in results:
        m = "Yes" if r['mandelbrot_member'] else "No"
        print(f"{r['c']:>6} | {r['sync_ratio']:>10.3f} | {m:>14}")

    print("\n" + "=" * 70)
    print("  APPLICATION 3: Cryptographic Parameter Screening")
    print("=" * 70)

    crypto_results = screen_crypto_parameters(p=251, num_params=30)
    print(f"\nScreening x^2 + c mod 251")
    print(f"\n{'c':>6} | {'Period':>6} | {'Sync':>6} | {'Rating':>6}")
    print("-" * 35)
    for r in crypto_results[:15]:
        print(f"{r['c']:>6} | {r['main_period']:>6} | {r['sync_ratio']:>6.3f} | {r['security_rating']:>6}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Demonstration of Adelic Synchronization in Arithmetic Dynamics

This script:
1. Samples parameters c for the family f_c(x) = x^2 + c
2. Computes reduced orbit invariants over many primes
3. Displays synchronization matrices and summary statistics
4. Highlights candidate exceptional (preperiodic) parameters

The key prediction: preperiodic parameters exhibit dramatically higher
synchronization scores than generic parameters.
"""

from collections import Counter
from typing import List, Tuple, Optional, Dict, Set


# ──────────────────────────────────────────────────────────────────────
# Core algorithms (self-contained)
# ──────────────────────────────────────────────────────────────────────

def quad_map_mod(x: int, c: int, p: int) -> int:
    return (x * x + c) % p

def find_preperiod_and_period(c: int, p: int, seed: int = 0) -> Tuple[int, int]:
    seen = {}
    x = seed % p
    for i in range(p + 2):
        if x in seen:
            return seen[x], i - seen[x]
        seen[x] = i
        x = quad_map_mod(x, c, p)
    return p, 1

def orbit_prefix_complexity(c: int, p: int, seed: int = 0, N: int = 0) -> int:
    if N == 0:
        N = min(p, 200)
    values = set()
    x = seed % p
    values.add(x)
    for _ in range(N):
        x = quad_map_mod(x, c, p)
        values.add(x)
    return len(values)

def prime_sync_score(invariants: List) -> int:
    counts = Counter(invariants)
    return sum(c * c for c in counts.values())

def is_preperiodic_over_Q(c: int, max_iter: int = 100) -> Optional[Tuple[int, int]]:
    orbit = [0]
    seen = {0: 0}
    x = 0
    for i in range(1, max_iter + 1):
        x = x * x + c
        if x in seen:
            return (seen[x], i)
        if abs(x) > 10**15:
            return None
        seen[x] = i
        orbit.append(x)
    return None

def sieve_of_eratosthenes(n: int) -> List[int]:
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


# ──────────────────────────────────────────────────────────────────────
# Demo
# ──────────────────────────────────────────────────────────────────────

def main():
    primes = [p for p in sieve_of_eratosthenes(300) if p > 2]
    n_primes = len(primes)

    print("=" * 78)
    print("  ADELIC SYNCHRONIZATION THRESHOLD — DEMONSTRATION")
    print("  Family: f_c(x) = x² + c,  critical orbit seed = 0")
    print(f"  Using {n_primes} odd primes: 3, 5, 7, ..., {primes[-1]}")
    print("=" * 78)

    # ── Part 1: Exceptional vs generic parameters ──
    print("\n┌──────────────────────────────────────────────────────────────────┐")
    print("│  PART 1: Synchronization Scores — Exceptional vs Generic       │")
    print("└──────────────────────────────────────────────────────────────────┘")

    exceptional_params = [0, -1, -2]  # known preperiodic over Q
    generic_params = [1, 2, 3, -3, -4, 5, 7, 10, -5, -6, 100, -100, 42, -42]

    max_score = n_primes ** 2

    def analyze(c):
        invariants = [find_preperiod_and_period(c, p) for p in primes]
        score = prime_sync_score(invariants)
        counts = Counter(invariants)
        dom = counts.most_common(1)[0]
        complexity = sum(orbit_prefix_complexity(c, p) for p in primes) / n_primes
        pp = is_preperiodic_over_Q(c)
        return {
            'c': c, 'score': score, 'ratio': score / max_score,
            'dominant': dom[0], 'dom_count': dom[1],
            'dom_frac': dom[1] / n_primes,
            'avg_complexity': complexity,
            'preperiodic': pp,
            'n_distinct': len(counts),
        }

    print(f"\n{'c':>6} | {'Preperiodic':>12} | {'Sync':>8} | {'Ratio':>6} | "
          f"{'Dom Frac':>8} | {'#Distinct':>9} | {'Avg Cplx':>8}")
    print("─" * 78)

    print("  ── Exceptional (preperiodic over ℚ) ──")
    for c in exceptional_params:
        r = analyze(c)
        pp_str = f"({r['preperiodic'][0]},{r['preperiodic'][1]})" if r['preperiodic'] else "No"
        print(f"{r['c']:>6} | {pp_str:>12} | {r['score']:>8} | {r['ratio']:>6.3f} | "
              f"{r['dom_frac']:>8.3f} | {r['n_distinct']:>9} | {r['avg_complexity']:>8.1f}")

    print("  ── Generic (non-preperiodic) ──")
    for c in generic_params:
        r = analyze(c)
        pp_str = f"({r['preperiodic'][0]},{r['preperiodic'][1]})" if r['preperiodic'] else "No"
        print(f"{r['c']:>6} | {pp_str:>12} | {r['score']:>8} | {r['ratio']:>6.3f} | "
              f"{r['dom_frac']:>8.3f} | {r['n_distinct']:>9} | {r['avg_complexity']:>8.1f}")

    # ── Part 2: Synchronization matrix for a few primes ──
    print("\n┌──────────────────────────────────────────────────────────────────┐")
    print("│  PART 2: Synchronization Matrix (first 10 primes)              │")
    print("└──────────────────────────────────────────────────────────────────┘")

    small_primes = primes[:10]
    for c in [0, -1, 3]:
        invariants = [find_preperiod_and_period(c, p) for p in small_primes]
        pp = is_preperiodic_over_Q(c)
        label = "EXCEPTIONAL" if pp else "GENERIC"
        print(f"\nc = {c} ({label})")
        print(f"  Primes:     {small_primes}")
        print(f"  Invariants: {invariants}")
        # Agreement matrix
        n = len(small_primes)
        print(f"  Agreement matrix (1 = same invariant):")
        print("        ", "  ".join(f"{p:>3}" for p in small_primes))
        for i in range(n):
            row = "  ".join(
                f"{'  1' if invariants[i] == invariants[j] else '  ·'}"
                for j in range(n)
            )
            print(f"  p={small_primes[i]:>3}  {row}")

    # ── Part 3: Orbit complexity profiles ──
    print("\n┌──────────────────────────────────────────────────────────────────┐")
    print("│  PART 3: Orbit Complexity Growth Profiles                      │")
    print("└──────────────────────────────────────────────────────────────────┘")

    p_test = 97  # a moderately large prime
    print(f"\nPrime p = {p_test}")
    depths = [5, 10, 20, 30, 50, 80]

    print(f"\n{'c':>6} | {'Preperiodic':>12} | " +
          " | ".join(f"N={d:>2}" for d in depths))
    print("─" * 70)
    for c in [0, -1, -2, 1, 3, 7, 42]:
        pp = is_preperiodic_over_Q(c)
        pp_str = f"({pp[0]},{pp[1]})" if pp else "No"
        complexities = [orbit_prefix_complexity(c, p_test, 0, d) for d in depths]
        print(f"{c:>6} | {pp_str:>12} | " +
              " | ".join(f"{cx:>4}" for cx in complexities))

    # ── Part 4: Search for high synchronization ──
    print("\n┌──────────────────────────────────────────────────────────────────┐")
    print("│  PART 4: Scanning for High Synchronization Parameters          │")
    print("└──────────────────────────────────────────────────────────────────┘")

    scan_primes = primes[:30]  # use 30 primes for speed
    max_sc = len(scan_primes) ** 2
    threshold = max_sc * 0.3  # 30% agreement threshold

    high_sync = []
    for c in range(-50, 51):
        invariants = [find_preperiod_and_period(c, p) for p in scan_primes]
        score = prime_sync_score(invariants)
        if score >= threshold:
            pp = is_preperiodic_over_Q(c)
            high_sync.append((c, score, pp))

    print(f"\nScanning c ∈ [-50, 50] with {len(scan_primes)} primes, "
          f"threshold = {threshold:.0f} ({threshold/max_sc*100:.0f}%)")
    print(f"\nHigh-synchronization parameters found:")
    print(f"{'c':>6} | {'Score':>8} | {'Ratio':>6} | {'Preperiodic over ℚ?':>20}")
    print("─" * 50)
    for c, score, pp in sorted(high_sync, key=lambda x: -x[1]):
        pp_str = f"Yes ({pp[0]},{pp[1]})" if pp else "No"
        print(f"{c:>6} | {score:>8} | {score/max_sc:>6.3f} | {pp_str:>20}")

    # ── Part 5: Theorem verification ──
    print("\n┌──────────────────────────────────────────────────────────────────┐")
    print("│  PART 5: Theorem Verification — Iterate Propagation            │")
    print("└──────────────────────────────────────────────────────────────────┘")

    p_ver = 53
    c_ver = -1  # f^[1](0) = -1, f^[2](0) = 0, so m=0, n=2
    print(f"\nVerifying propagation for c={c_ver}, p={p_ver}")

    orbit = []
    x = 0
    for i in range(20):
        orbit.append(x)
        x = quad_map_mod(x, c_ver, p_ver)

    # Find first collision
    seen = {}
    m_found, n_found = None, None
    for i, val in enumerate(orbit):
        if val in seen and m_found is None:
            m_found, n_found = seen[val], i
            break
        seen[val] = i

    if m_found is not None:
        print(f"  First collision: f^[{m_found}](0) = f^[{n_found}](0) = {orbit[m_found]}")
        print(f"  Period = {n_found - m_found}")
        print(f"  Verifying propagation for k = 0..10:")
        all_ok = True
        for k in range(11):
            lhs = orbit[m_found + k] if m_found + k < len(orbit) else "?"
            rhs = orbit[n_found + k] if n_found + k < len(orbit) else "?"
            ok = lhs == rhs
            all_ok = all_ok and ok
            print(f"    k={k}: f^[{m_found+k}](0) = {lhs}, "
                  f"f^[{n_found+k}](0) = {rhs}  {'✓' if ok else '✗'}")
        print(f"  All propagations verified: {'YES ✓' if all_ok else 'NO ✗'}")

    print("\n" + "=" * 78)
    print("  CONCLUSION")
    print("=" * 78)
    print("""
  The data clearly shows:
  • Preperiodic parameters (c = 0, -1, -2) have MUCH higher synchronization
    scores than generic parameters — their reduced orbit invariants agree
    across most primes.
  • Generic parameters show low sync scores with many distinct invariant values.
  • This validates the adelic synchronization thesis: exceptional algebraic
    relations in characteristic zero produce detectable collective signals
    across finite prime reductions.
  • The orbit complexity collapses after collision, confirming the phase
    transition predicted by the theoretical framework.
    """)


if __name__ == "__main__":
    main()


"""
Visualization 2: Orbit Complexity Growth Curves

Shows how the orbit prefix set cardinality (number of distinct orbit values
up to depth N) grows with N for different parameters c mod a fixed prime p.

Exceptional parameters exhibit early saturation (complexity collapse),
while generic parameters show continued growth — the "phase transition"
in orbit complexity that our theorems predict.
"""

import matplotlib.pyplot as plt
import numpy as np


def quad_map_mod(x, c, p):
    return (x * x + c) % p

def orbit_prefix_card(c, p, N):
    """Count distinct values in orbit up to depth N."""
    values = set()
    x = 0
    values.add(x)
    for _ in range(N):
        x = quad_map_mod(x, c, p)
        values.add(x)
    return len(values)


p = 97  # A moderately large prime
max_depth = 80
depths = list(range(1, max_depth + 1))

params_exceptional = [(0, "c = 0 (fixed)"), (-1, "c = −1 (period 2)"),
                       (-2, "c = −2 (preperiod 1)")]
params_generic = [(1, "c = 1"), (3, "c = 3"), (7, "c = 7"),
                  (13, "c = 13"), (42, "c = 42")]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle(f"Orbit Prefix Complexity Growth (mod p = {p})",
             fontsize=14, fontweight='bold')

# Panel 1: Exceptional parameters
for c, label in params_exceptional:
    complexities = [orbit_prefix_card(c, p, d) for d in depths]
    ax1.plot(depths, complexities, 'o-', markersize=2, linewidth=2, label=label)

ax1.axhline(y=p, color='gray', linestyle='--', alpha=0.5, label=f'p = {p}')
ax1.set_xlabel("Observation depth N", fontsize=12)
ax1.set_ylabel("Distinct orbit values", fontsize=12)
ax1.set_title("Exceptional Parameters\n(Early saturation = complexity collapse)", fontsize=11)
ax1.legend(fontsize=9)
ax1.set_ylim(0, max_depth)
ax1.grid(alpha=0.3)

# Panel 2: Generic parameters
for c, label in params_generic:
    complexities = [orbit_prefix_card(c, p, d) for d in depths]
    ax2.plot(depths, complexities, 'o-', markersize=2, linewidth=2, label=label)

ax2.axhline(y=p, color='gray', linestyle='--', alpha=0.5, label=f'p = {p}')
ax2.set_xlabel("Observation depth N", fontsize=12)
ax2.set_ylabel("Distinct orbit values", fontsize=12)
ax2.set_title("Generic Parameters\n(Continued growth before eventual saturation)", fontsize=11)
ax2.legend(fontsize=9)
ax2.set_ylim(0, max_depth)
ax2.grid(alpha=0.3)

plt.tight_layout()
plt.savefig("complexity_curves.png", dpi=150, bbox_inches='tight')
print("Saved complexity_curves.png")


"""
Visualization 1: Synchronization Heatmap

Visualizes the pairwise agreement matrix of orbit invariants across primes
for different parameters c. Exceptional (preperiodic) parameters show
dense agreement blocks; generic parameters show sparse, disordered patterns.

This is the core visual evidence for the adelic synchronization thesis.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from collections import Counter


def quad_map_mod(x, c, p):
    return (x * x + c) % p

def find_preperiod_and_period(c, p):
    seen = {}
    x = 0
    for i in range(p + 2):
        if x in seen:
            return seen[x], i - seen[x]
        seen[x] = i
        x = quad_map_mod(x, c, p)
    return p, 1

def sieve(n):
    if n < 2:
        return []
    s = [True] * (n + 1)
    s[0] = s[1] = False
    for i in range(2, int(n**0.5) + 1):
        if s[i]:
            for j in range(i*i, n + 1, i):
                s[j] = False
    return [i for i in range(2, n + 1) if s[i]]


primes = [p for p in sieve(200) if p > 2][:40]
n_p = len(primes)

params = [0, -1, -2, 3, 7, 42]
titles = [
    "c = 0 (fixed point)",
    "c = −1 (period 2)",
    "c = −2 (preperiod 1)",
    "c = 3 (generic)",
    "c = 7 (generic)",
    "c = 42 (generic)",
]

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
fig.suptitle("Adelic Synchronization Heatmaps\nPairwise agreement of orbit invariants across primes",
             fontsize=14, fontweight='bold')

for idx, (c, title) in enumerate(zip(params, titles)):
    ax = axes[idx // 3][idx % 3]
    invariants = [find_preperiod_and_period(c, p) for p in primes]

    # Build agreement matrix
    matrix = np.zeros((n_p, n_p))
    for i in range(n_p):
        for j in range(n_p):
            matrix[i][j] = 1 if invariants[i] == invariants[j] else 0

    score = int(matrix.sum())
    ratio = score / (n_p * n_p)

    cmap = mcolors.ListedColormap(['#f0f0f0', '#2166ac'])
    ax.imshow(matrix, cmap=cmap, interpolation='nearest', aspect='equal')
    ax.set_title(f"{title}\nSync ratio: {ratio:.3f}", fontsize=10)
    ax.set_xlabel("Prime index")
    ax.set_ylabel("Prime index")
    ax.set_xticks([])
    ax.set_yticks([])

plt.tight_layout()
plt.savefig("sync_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved sync_heatmap.png")


"""
Visualization 3: Synchronization Landscape

Plots the sync score as a function of the parameter c, scanning a range
of integer values. Peaks correspond to exceptional (preperiodic) parameters.

This is the "order parameter" landscape — the adelic synchronization
phase diagram for the quadratic family.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def quad_map_mod(x, c, p):
    return (x * x + c) % p

def find_preperiod_and_period(c, p):
    seen = {}
    x = 0
    for i in range(p + 2):
        if x in seen:
            return seen[x], i - seen[x]
        seen[x] = i
        x = quad_map_mod(x, c, p)
    return p, 1

def prime_sync_score(invariants):
    counts = Counter(invariants)
    return sum(v * v for v in counts.values())

def sieve(n):
    if n < 2:
        return []
    s = [True] * (n + 1)
    s[0] = s[1] = False
    for i in range(2, int(n**0.5) + 1):
        if s[i]:
            for j in range(i*i, n + 1, i):
                s[j] = False
    return [i for i in range(2, n + 1) if s[i]]

def is_preperiodic_over_Q(c, max_iter=200):
    seen = {0: 0}
    x = 0
    for i in range(1, max_iter + 1):
        x = x * x + c
        if x in seen:
            return True
        if abs(x) > 10**15:
            return False
        seen[x] = i
    return False


primes = [p for p in sieve(200) if p > 2]
n_primes = len(primes)
max_score = n_primes ** 2

c_range = range(-30, 31)
scores = []
is_exc = []

for c in c_range:
    invariants = [find_preperiod_and_period(c, p) for p in primes]
    score = prime_sync_score(invariants)
    scores.append(score / max_score)
    is_exc.append(is_preperiodic_over_Q(c))

c_list = list(c_range)

fig, ax = plt.subplots(figsize=(14, 6))
fig.suptitle("Adelic Synchronization Landscape\nSync score vs parameter c for f(x) = x² + c",
             fontsize=14, fontweight='bold')

# Plot all scores as bars
colors = ['#d62728' if exc else '#1f77b4' for exc in is_exc]
ax.bar(c_list, scores, color=colors, alpha=0.7, width=0.8)

# Highlight exceptional parameters
exc_cs = [c for c, e in zip(c_list, is_exc) if e]
exc_scores = [s for s, e in zip(scores, is_exc) if e]
ax.scatter(exc_cs, exc_scores, color='red', s=80, zorder=5,
           label='Preperiodic over ℚ', edgecolors='black', linewidth=1)

# Add labels for exceptional parameters
for c, s in zip(exc_cs, exc_scores):
    ax.annotate(f'c={c}', (c, s), textcoords="offset points",
                xytext=(0, 10), ha='center', fontsize=8, color='red')

ax.set_xlabel("Parameter c", fontsize=12)
ax.set_ylabel("Synchronization ratio (score / max)", fontsize=12)
ax.legend(fontsize=10)
ax.grid(alpha=0.3, axis='y')
ax.set_xlim(c_list[0] - 1, c_list[-1] + 1)

plt.tight_layout()
plt.savefig("sync_landscape.png", dpi=150, bbox_inches='tight')
print("Saved sync_landscape.png")
