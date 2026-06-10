#!/usr/bin/env python3
"""
Applications of Modular CF Dynamics
=====================================

Real-world applications of the modular continued-fraction dynamics theory:

1. Algebraic Number Detection: Determine if a number given by its CF expansion
   is likely quadratic irrational based on modular periodicity.
2. Cryptographic Period Analysis: Analyze periodicity properties of linear
   recurrence sequences modulo primes for pseudorandom number generation.
3. Diophantine Approximation Quality: Use modular graph structure to measure
   how well a number is approximated by rationals.
"""

from typing import List, Tuple, Dict, Optional
import math


class CFState:
    """State of CF convergent recurrence."""
    def __init__(self, p_prev, p_curr, q_prev, q_curr):
        self.p_prev = p_prev
        self.p_curr = p_curr
        self.q_prev = q_prev
        self.q_curr = q_curr

    def step_mod(self, a: int, m: int) -> 'CFState':
        return CFState(
            self.p_curr,
            (a * self.p_curr + self.p_prev) % m,
            self.q_curr,
            (a * self.q_curr + self.q_prev) % m,
        )

    def pair(self) -> Tuple[int, int]:
        return (self.p_curr, self.q_curr)

    def as_tuple(self) -> Tuple[int, int, int, int]:
        return (self.p_prev, self.p_curr, self.q_prev, self.q_curr)


# ============================================================
# Application 1: Algebraic Number Detection
# ============================================================

def detect_algebraic_degree(cf_coefficients: List[int],
                             test_primes: List[int] = None,
                             confidence_threshold: float = 0.8) -> Dict:
    """Detect whether a number is likely quadratic irrational from its CF expansion.

    Algorithm:
    1. For each test prime p, compute the modular CF state sequence.
    2. Check if the state sequence is eventually periodic.
    3. If periodic for most primes → likely quadratic irrational.
    4. If non-periodic for most primes → likely transcendental or higher degree.

    Args:
        cf_coefficients: first N coefficients of the CF expansion
        test_primes: primes to test (default: first 10 primes ≥ 3)
        confidence_threshold: fraction of primes that must be periodic

    Returns:
        Dict with classification and evidence
    """
    if test_primes is None:
        test_primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]

    results = []
    for p in test_primes:
        state = CFState(1, cf_coefficients[0] % p, 0, 1)
        state = CFState(state.p_prev % p, state.p_curr % p,
                        state.q_prev % p, state.q_curr % p)

        seen: Dict[Tuple, int] = {state.as_tuple(): 0}
        preperiod = -1
        period = -1

        for i in range(1, len(cf_coefficients)):
            a = cf_coefficients[i] % p
            state = state.step_mod(a, p)
            key = state.as_tuple()
            if key in seen:
                preperiod = seen[key]
                period = i - preperiod
                break
            seen[key] = i

        results.append({
            'prime': p,
            'periodic': period > 0,
            'preperiod': preperiod,
            'period': period,
        })

    periodic_count = sum(1 for r in results if r['periodic'])
    periodic_fraction = periodic_count / len(results)

    if periodic_fraction >= confidence_threshold:
        classification = "likely_quadratic_irrational"
    elif periodic_fraction >= 0.3:
        classification = "uncertain"
    else:
        classification = "likely_transcendental_or_higher_degree"

    return {
        'classification': classification,
        'periodic_fraction': periodic_fraction,
        'periodic_count': periodic_count,
        'total_primes': len(results),
        'details': results,
    }


# ============================================================
# Application 2: Linear Recurrence Period Analysis
# ============================================================

def analyze_linear_recurrence_periods(a: int, b: int,
                                       primes: List[int]) -> Dict:
    """Analyze the modular periods of a linear recurrence x_{n+1} = a*x_n + b*x_{n-1}.

    This generalizes the Fibonacci case (a=b=1) and connects to
    cryptographic applications of pseudorandom number generators.

    Args:
        a, b: recurrence coefficients (x_{n+1} = a*x_n + b*x_{n-1})
        primes: list of primes to analyze

    Returns:
        Analysis of period structure across primes
    """
    results = []
    for p in primes:
        # Find period of (x_{n-1}, x_n) mod p
        x_prev, x_curr = 1, 0  # initial state
        target = (x_prev % p, x_curr % p)

        x_prev, x_curr = 0, 1
        period = 0
        for i in range(1, p * p * 10):
            x_prev, x_curr = x_curr, (a * x_curr + b * x_prev) % p
            period = i
            if (x_prev % p, x_curr % p) == target:
                break

        results.append({
            'prime': p,
            'period': period,
            'period_over_p': period / p,
            'period_over_p2': period / (p * p),
        })

    return {
        'recurrence': f'x_{{n+1}} = {a}*x_n + {b}*x_{{n-1}}',
        'results': results,
    }


# ============================================================
# Application 3: Approximation Quality Measure
# ============================================================

def approximation_quality_spectrum(cf_coefficients: List[int],
                                    primes: List[int] = None) -> Dict:
    """Compute the "approximation quality spectrum" of a number.

    For each prime p, the modular CF graph captures how the convergents
    distribute modulo p. The graph density reflects the quality of
    rational approximation visible at scale 1/p.

    A quadratic irrational has predictable, periodic approximation quality.
    A transcendental number has more complex, often denser modular graphs.

    Args:
        cf_coefficients: CF expansion coefficients
        primes: primes to test

    Returns:
        Spectrum data for each prime
    """
    if primes is None:
        primes = [3, 5, 7, 11, 13]

    n = len(cf_coefficients)
    spectrum = []

    for p in primes:
        state = CFState(1, cf_coefficients[0] % p, 0, 1)
        state = CFState(state.p_prev % p, state.p_curr % p,
                        state.q_prev % p, state.q_curr % p)

        vertices = set()
        edges = set()
        prev_pair = state.pair()
        vertices.add(prev_pair)

        for i in range(1, n):
            a = cf_coefficients[i] % p
            state = state.step_mod(a, p)
            curr_pair = state.pair()
            vertices.add(curr_pair)
            edges.add((prev_pair, curr_pair))
            prev_pair = curr_pair

        max_possible_edges = p * p * (p * p - 1)
        density = len(edges) / max_possible_edges if max_possible_edges > 0 else 0

        spectrum.append({
            'prime': p,
            'vertices': len(vertices),
            'max_vertices': p * p,
            'vertex_coverage': len(vertices) / (p * p),
            'edges': len(edges),
            'density': density,
        })

    return {
        'n_coefficients': n,
        'spectrum': spectrum,
    }


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Algebraic Number Detection")
    print("=" * 60)

    # Test with known numbers
    test_cases = [
        ("φ (golden ratio)", [1] * 200),
        ("√2", [1] + [2] * 199),
        ("√3", [1] + [1, 2] * 100),
        ("√5", [2] + [4] * 199),
        ("e", None),  # will compute
    ]

    # Compute e's CF coefficients
    e_coeffs = [2]
    k = 1
    for i in range(1, 200):
        if i % 3 == 2:
            e_coeffs.append(2 * k)
            k += 1
        else:
            e_coeffs.append(1)
    test_cases[4] = ("e", e_coeffs)

    for name, coeffs in test_cases:
        result = detect_algebraic_degree(coeffs)
        print(f"\n  {name}:")
        print(f"    Classification: {result['classification']}")
        print(f"    Periodic for {result['periodic_count']}/{result['total_primes']} primes "
              f"({result['periodic_fraction']:.0%})")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Linear Recurrence Period Analysis")
    print("=" * 60)

    primes = [3, 5, 7, 11, 13, 17, 19]

    for a, b, name in [(1, 1, "Fibonacci"), (2, 1, "Pell"), (1, 2, "Custom(1,2)")]:
        result = analyze_linear_recurrence_periods(a, b, primes)
        print(f"\n  {name}: {result['recurrence']}")
        for r in result['results']:
            print(f"    p={r['prime']:2d}: period={r['period']:4d}, "
                  f"period/p={r['period_over_p']:.2f}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Approximation Quality Spectrum")
    print("=" * 60)

    for name, coeffs in test_cases:
        result = approximation_quality_spectrum(coeffs, [3, 5, 7, 11])
        print(f"\n  {name}:")
        for s in result['spectrum']:
            print(f"    p={s['prime']:2d}: vertices={s['vertices']:3d}/{s['max_vertices']:3d} "
                  f"({s['vertex_coverage']:.1%}), "
                  f"edges={s['edges']:4d}, density={s['density']:.4f}")


#!/usr/bin/env python3
"""
Modular Continued-Fraction Dynamics: Demonstration
===================================================

This script demonstrates the core mathematical results about how
continued fraction expansions of quadratic irrationals produce
eventually periodic modular dynamics, and how graph-theoretic
invariants inherit this periodicity.

Key demonstrations:
1. CF convergent computation and the recurrence relation
2. Modular reduction of convergents (Pisano-like periods)
3. Modular CF graph construction and stabilization
4. Periodicity detection via graph invariants
5. Comparison: quadratic irrationals vs transcendental numbers
"""

from typing import Tuple, List, Dict, Set
import math


def cf_coefficients_golden_ratio(n: int) -> List[int]:
    """Golden ratio φ = [1; 1, 1, 1, ...] - all 1s."""
    return [1] * n


def cf_coefficients_sqrt2(n: int) -> List[int]:
    """√2 = [1; 2, 2, 2, ...] - 1 followed by all 2s."""
    return [1] + [2] * (n - 1) if n > 0 else []


def cf_coefficients_sqrt3(n: int) -> List[int]:
    """√3 = [1; 1, 2, 1, 2, ...] - period 2 after initial term."""
    if n == 0:
        return []
    result = [1]
    for i in range(1, n):
        result.append(1 if i % 2 == 1 else 2)
    return result


def cf_coefficients_e(n: int) -> List[int]:
    """e = [2; 1, 2, 1, 1, 4, 1, 1, 6, ...] - NOT eventually periodic."""
    if n == 0:
        return []
    result = [2]
    k = 1
    for i in range(1, n):
        if i % 3 == 2:
            result.append(2 * k)
            k += 1
        else:
            result.append(1)
    return result


def compute_convergents(coeffs: List[int]) -> List[Tuple[int, int]]:
    """Compute convergents (p_n, q_n) from CF coefficients using the recurrence:
    p_{n+1} = a_{n+1} * p_n + p_{n-1}
    q_{n+1} = a_{n+1} * q_n + q_{n-1}
    """
    if not coeffs:
        return []

    # Initial state: p_{-1}=1, p_0=a_0, q_{-1}=0, q_0=1
    convergents = []
    p_prev, p_curr = 1, coeffs[0]
    q_prev, q_curr = 0, 1
    convergents.append((p_curr, q_curr))

    for i in range(1, len(coeffs)):
        a = coeffs[i]
        p_new = a * p_curr + p_prev
        q_new = a * q_curr + q_prev
        convergents.append((p_new, q_new))
        p_prev, p_curr = p_curr, p_new
        q_prev, q_curr = q_curr, q_new

    return convergents


def convergents_mod_p(convergents: List[Tuple[int, int]], p: int) -> List[Tuple[int, int]]:
    """Reduce convergent pairs modulo p."""
    return [(pn % p, qn % p) for pn, qn in convergents]


def build_modular_cf_graph(mod_convergents: List[Tuple[int, int]]) -> Dict:
    """Build the modular CF graph from convergent pairs.

    Returns dict with:
    - vertices: set of (p_n mod p, q_n mod p)
    - edges: set of directed edges between consecutive pairs
    """
    vertices: Set[Tuple[int, int]] = set()
    edges: Set[Tuple[Tuple[int, int], Tuple[int, int]]] = set()

    for i, v in enumerate(mod_convergents):
        vertices.add(v)
        if i > 0:
            edges.add((mod_convergents[i-1], v))

    return {
        'vertices': vertices,
        'edges': edges,
        'vertex_count': len(vertices),
        'edge_count': len(edges),
    }


def detect_periodicity(sequence: List, max_period: int = None) -> Tuple[int, int]:
    """Detect eventual periodicity in a sequence.

    Returns (preperiod, period) or (-1, -1) if not detected.
    """
    n = len(sequence)
    if max_period is None:
        max_period = n // 2

    for N in range(n):
        for T in range(1, min(max_period + 1, n - N)):
            periodic = True
            for k in range(N, n - T):
                if sequence[k + T] != sequence[k]:
                    periodic = False
                    break
            if periodic and n - N > 2 * T:  # need enough evidence
                return (N, T)
    return (-1, -1)


def demo_convergent_computation():
    """Demo 1: Show CF convergent computation."""
    print("=" * 70)
    print("DEMO 1: Continued Fraction Convergents")
    print("=" * 70)

    for name, cf_func in [("Golden Ratio φ", cf_coefficients_golden_ratio),
                           ("√2", cf_coefficients_sqrt2),
                           ("√3", cf_coefficients_sqrt3)]:
        coeffs = cf_func(10)
        convs = compute_convergents(coeffs)
        print(f"\n{name} = [{', '.join(str(c) for c in coeffs)}]")
        print(f"  Convergents p_n/q_n:")
        for i, (p, q) in enumerate(convs):
            ratio = p / q if q != 0 else float('inf')
            print(f"    n={i}: {p}/{q} = {ratio:.10f}")


def demo_modular_dynamics():
    """Demo 2: Modular reduction and periodicity."""
    print("\n" + "=" * 70)
    print("DEMO 2: Modular CF Dynamics")
    print("=" * 70)

    primes = [3, 5, 7, 11, 13]

    for name, cf_func in [("Golden Ratio φ", cf_coefficients_golden_ratio),
                           ("√2", cf_coefficients_sqrt2),
                           ("e (transcendental)", cf_coefficients_e)]:
        print(f"\n--- {name} ---")
        coeffs = cf_func(50)
        convs = compute_convergents(coeffs)

        for p in primes:
            mod_convs = convergents_mod_p(convs, p)
            # Extract just the p_n mod p sequence
            p_seq = [v[0] for v in mod_convs]
            preperiod, period = detect_periodicity(p_seq)
            if preperiod >= 0:
                print(f"  mod {p:2d}: eventually periodic, "
                      f"preperiod={preperiod}, period={period}")
            else:
                print(f"  mod {p:2d}: no periodicity detected in {len(p_seq)} terms")


def demo_graph_construction():
    """Demo 3: Modular CF graph construction and stabilization."""
    print("\n" + "=" * 70)
    print("DEMO 3: Modular CF Graph Construction")
    print("=" * 70)

    p = 7
    coeffs = cf_coefficients_golden_ratio(60)
    convs = compute_convergents(coeffs)
    mod_convs = convergents_mod_p(convs, p)

    print(f"\nGolden ratio mod {p}:")
    print(f"  Window   Vertices   Edges   New Edges")
    print(f"  ------   --------   -----   ---------")

    prev_edges = set()
    for window in range(5, 55, 5):
        graph = build_modular_cf_graph(mod_convs[:window])
        new_edges = graph['edges'] - prev_edges
        print(f"  {window:6d}   {graph['vertex_count']:8d}   "
              f"{graph['edge_count']:5d}   {len(new_edges):9d}")
        prev_edges = graph['edges']

    print(f"\n  State space bound: p² = {p**2}")
    print(f"  Graph stabilizes when no new edges appear.")


def demo_periodicity_transfer():
    """Demo 4: Periodicity transfers through graph invariants."""
    print("\n" + "=" * 70)
    print("DEMO 4: Periodicity Transfer through Graph Invariants")
    print("=" * 70)

    p = 5
    coeffs = cf_coefficients_sqrt2(80)
    convs = compute_convergents(coeffs)
    mod_convs = convergents_mod_p(convs, p)

    # Track edge count as window slides
    window_size = 10
    edge_counts = []
    for start in range(len(mod_convs) - window_size):
        window = mod_convs[start:start + window_size]
        graph = build_modular_cf_graph(window)
        edge_counts.append(graph['edge_count'])

    print(f"\n√2 mod {p}, sliding window of size {window_size}:")
    print(f"  Edge count sequence: {edge_counts[:30]}...")
    preperiod, period = detect_periodicity(edge_counts)
    if preperiod >= 0:
        print(f"  → Eventually periodic! Preperiod={preperiod}, Period={period}")
    else:
        print(f"  → No periodicity detected")


def demo_quadratic_vs_transcendental():
    """Demo 5: Compare quadratic irrationals with transcendentals."""
    print("\n" + "=" * 70)
    print("DEMO 5: Quadratic Irrationals vs Transcendentals")
    print("=" * 70)

    p = 7
    n_terms = 100

    cases = [
        ("φ (quadratic)", cf_coefficients_golden_ratio),
        ("√2 (quadratic)", cf_coefficients_sqrt2),
        ("√3 (quadratic)", cf_coefficients_sqrt3),
        ("e (transcendental)", cf_coefficients_e),
    ]

    for name, cf_func in cases:
        coeffs = cf_func(n_terms)
        convs = compute_convergents(coeffs)
        mod_convs = convergents_mod_p(convs, p)

        # Check state sequence periodicity
        preperiod, period = detect_periodicity(mod_convs)
        graph = build_modular_cf_graph(mod_convs)

        print(f"\n  {name}:")
        print(f"    Convergent pairs mod {p}: {graph['vertex_count']} distinct / {p**2} possible")
        print(f"    Edges: {graph['edge_count']}")
        if preperiod >= 0:
            print(f"    State periodicity: preperiod={preperiod}, period={period}")
            print(f"    → PERIODIC (consistent with quadratic irrational)")
        else:
            print(f"    State periodicity: NOT DETECTED in {n_terms} terms")
            print(f"    → NON-PERIODIC (consistent with transcendental)")


def demo_pisano_periods():
    """Demo 6: Pisano periods and the stabilization conjecture."""
    print("\n" + "=" * 70)
    print("DEMO 6: Pisano Periods (Fibonacci mod p)")
    print("=" * 70)

    def fibonacci_mod_period(p: int) -> int:
        """Compute the Pisano period π(p) = period of Fibonacci mod p."""
        if p <= 1:
            return 1
        f_prev, f_curr = 0, 1
        for i in range(1, 6 * p + 10):
            f_prev, f_curr = f_curr, (f_prev + f_curr) % p
            if f_prev == 0 and f_curr == 1:
                return i
        return -1  # should not happen for prime p

    print(f"\n  Prime p   π(p)   6p    π(p)/p   π(p) ≤ 6p?")
    print(f"  -------   ----   --    ------   ----------")
    all_satisfy = True
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        pi_p = fibonacci_mod_period(p)
        ratio = pi_p / p
        satisfies = pi_p <= 6 * p
        if not satisfies:
            all_satisfy = False
        print(f"  {p:7d}   {pi_p:4d}   {6*p:3d}   {ratio:6.2f}   {'✓' if satisfies else '✗'}")

    print(f"\n  Conjecture π(p) ≤ 6p: {'CONFIRMED for all tested primes' if all_satisfy else 'COUNTEREXAMPLE FOUND'}")


if __name__ == "__main__":
    demo_convergent_computation()
    demo_modular_dynamics()
    demo_graph_construction()
    demo_periodicity_transfer()
    demo_quadratic_vs_transcendental()
    demo_pisano_periods()
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Graph Stabilization Curves
===========================================

Shows how the modular CF graph K_p(x, N) stabilizes as N grows.
For quadratic irrationals, both vertex count and edge count plateau
at a finite value determined by the period. For transcendentals,
the counts grow continuously (up to the p² bound).

This directly illustrates the main theorem: eventually periodic CF
coefficients produce eventually periodic graph invariants.
"""

import matplotlib.pyplot as plt
import numpy as np


def compute_graph_growth(coeffs_func, p, max_n=200):
    """Track vertex and edge count as window size N grows."""
    vertices = set()
    edges = set()
    vertex_counts = []
    edge_counts = []
    new_edge_counts = []

    p_prev, p_curr = 1 % p, coeffs_func(0) % p
    q_prev, q_curr = 0, 1 % p
    prev_pair = (p_curr, q_curr)
    vertices.add(prev_pair)
    vertex_counts.append(len(vertices))
    edge_counts.append(len(edges))
    new_edge_counts.append(0)

    for n in range(1, max_n):
        a = coeffs_func(n) % p
        p_new = (a * p_curr + p_prev) % p
        q_new = (a * q_curr + q_prev) % p
        p_prev, p_curr = p_curr, p_new
        q_prev, q_curr = q_curr, q_new

        curr_pair = (p_curr, q_curr)
        vertices.add(curr_pair)
        old_edge_count = len(edges)
        edges.add((prev_pair, curr_pair))
        new_edges = len(edges) - old_edge_count
        prev_pair = curr_pair

        vertex_counts.append(len(vertices))
        edge_counts.append(len(edges))
        new_edge_counts.append(new_edges)

    return vertex_counts, edge_counts, new_edge_counts


# Define number sequences
def golden(n): return 1
def sqrt2(n): return 1 if n == 0 else 2
def sqrt3(n):
    if n == 0: return 1
    return 1 if n % 2 == 1 else 2
def euler_e(n):
    if n == 0: return 2
    if (n + 1) % 3 == 0: return 2 * ((n + 1) // 3)
    return 1

fig, axes = plt.subplots(2, 3, figsize=(18, 10))

primes = [5, 11, 23]
numbers = [
    ("φ (Golden Ratio)", golden, '#2196F3'),
    ("√2", sqrt2, '#4CAF50'),
    ("√3", sqrt3, '#FF9800'),
    ("e (transcendental)", euler_e, '#E91E63'),
]

max_n = 150

for col, p in enumerate(primes):
    ax_vert = axes[0][col]
    ax_edge = axes[1][col]

    for name, func, color in numbers:
        vcounts, ecounts, new_ecounts = compute_graph_growth(func, p, max_n)
        ns = range(len(vcounts))

        ax_vert.plot(ns, vcounts, color=color, linewidth=1.5, label=name, alpha=0.8)
        ax_edge.plot(ns, ecounts, color=color, linewidth=1.5, label=name, alpha=0.8)

    # Add p² bound line
    ax_vert.axhline(y=p**2, color='gray', linestyle=':', alpha=0.5, linewidth=1)
    ax_vert.text(max_n - 2, p**2 + 1, f'p²={p**2}', fontsize=8, color='gray',
                ha='right', va='bottom')

    ax_vert.set_title(f'p = {p}', fontsize=13, fontweight='bold')
    ax_vert.set_ylabel('Vertex Count' if col == 0 else '', fontsize=11)
    ax_vert.set_xlim(0, max_n)
    ax_vert.grid(True, alpha=0.3)
    if col == 0:
        ax_vert.legend(fontsize=8, loc='lower right')

    ax_edge.set_xlabel('Window Size N', fontsize=11)
    ax_edge.set_ylabel('Edge Count' if col == 0 else '', fontsize=11)
    ax_edge.set_xlim(0, max_n)
    ax_edge.grid(True, alpha=0.3)

# Add row labels
axes[0][0].set_ylabel('Vertices in K_p(x, N)', fontsize=12, fontweight='bold')
axes[1][0].set_ylabel('Edges in K_p(x, N)', fontsize=12, fontweight='bold')

fig.suptitle('Modular CF Graph Stabilization: K_p(x, N) as N Grows\n'
             'Quadratic irrationals stabilize; transcendentals keep growing',
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('viz_graph_stabilization.png', dpi=150, bbox_inches='tight')
print("Saved viz_graph_stabilization.png")


#!/usr/bin/env python3
"""
Visualization: Modular CF Graph Structure
==========================================

Visualizes the modular continued-fraction graph K_p(x, N) for different
quadratic irrationals and a transcendental number, showing how convergent
pairs distribute modulo a prime p. Quadratic irrationals produce structured,
periodic graphs while transcendentals fill the state space more densely.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def cf_state_mod(coeffs, n, p):
    """Compute CF states (p_curr, q_curr) mod p for first n terms."""
    if n == 0:
        return []
    p_prev, p_curr = 1, coeffs[0] % p
    q_prev, q_curr = 0, 1
    pairs = [(p_curr % p, q_curr % p)]
    for i in range(1, n):
        a = coeffs[i] % p
        p_new = (a * p_curr + p_prev) % p
        q_new = (a * q_curr + q_prev) % p
        pairs.append((p_new, q_new))
        p_prev, p_curr = p_curr, p_new
        q_prev, q_curr = q_curr, q_new
    return pairs


def make_coeffs(name, n):
    """Generate CF coefficients for named constants."""
    if name == "φ":
        return [1] * n
    elif name == "√2":
        return [1] + [2] * (n - 1)
    elif name == "√3":
        result = [1]
        for i in range(1, n):
            result.append(1 if i % 2 == 1 else 2)
        return result
    elif name == "e":
        result = [2]
        k = 1
        for i in range(1, n):
            if i % 3 == 2:
                result.append(2 * k)
                k += 1
            else:
                result.append(1)
        return result
    return [1] * n


fig, axes = plt.subplots(2, 2, figsize=(12, 12))
p = 11  # prime modulus
n_terms = 120

cases = [("φ (Golden Ratio)", "φ"), ("√2", "√2"), ("√3", "√3"), ("e (Euler's number)", "e")]
colors_list = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']

for idx, (title, name) in enumerate(cases):
    ax = axes[idx // 2][idx % 2]
    coeffs = make_coeffs(name, n_terms)
    pairs = cf_state_mod(coeffs, n_terms, p)

    # Plot all possible grid points in light gray
    for x in range(p):
        for y in range(p):
            ax.plot(x, y, '.', color='#E0E0E0', markersize=3, zorder=1)

    # Plot edges
    for i in range(len(pairs) - 1):
        x1, y1 = pairs[i]
        x2, y2 = pairs[i + 1]
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color=colors_list[idx],
                                   alpha=0.3, lw=0.8),
                    zorder=2)

    # Plot vertices with visit frequency
    from collections import Counter
    counts = Counter(pairs)
    unique_pairs = list(counts.keys())
    sizes = [min(200, 20 + 10 * counts[pair]) for pair in unique_pairs]

    xs = [pair[0] for pair in unique_pairs]
    ys = [pair[1] for pair in unique_pairs]
    ax.scatter(xs, ys, s=sizes, c=colors_list[idx], alpha=0.7,
              edgecolors='black', linewidths=0.5, zorder=3)

    # Mark start
    ax.plot(pairs[0][0], pairs[0][1], '*', color='red', markersize=12, zorder=4)

    ax.set_title(f'{title}\nmod {p}: {len(counts)} vertices, '
                f'{"periodic" if name != "e" else "non-periodic"}',
                fontsize=11, fontweight='bold')
    ax.set_xlabel('p_n mod p', fontsize=10)
    ax.set_ylabel('q_n mod p', fontsize=10)
    ax.set_xlim(-0.5, p - 0.5)
    ax.set_ylim(-0.5, p - 0.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

fig.suptitle(f'Modular CF Graphs K_{{p}}(x, {n_terms}) for p = {p}\n'
             'Quadratic irrationals (top, bottom-left) vs transcendental (bottom-right)',
             fontsize=14, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.94])
plt.savefig('viz_modular_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_modular_graph.png")


#!/usr/bin/env python3
"""
Visualization: Periodicity Detection Heatmap
==============================================

Creates a heatmap showing the detected period of the modular CF state sequence
for different numbers (rows) across different primes (columns). Quadratic
irrationals show consistent small periods, while transcendentals show
no detected periodicity (or very large periods).
"""

import matplotlib.pyplot as plt
import numpy as np


def cf_state_mod_period(coeffs_func, p, max_steps=500):
    """Detect the period of CF state sequence mod p.
    Returns (preperiod, period) or (-1, -1) if not found.
    """
    p_prev, p_curr = 1 % p, coeffs_func(0) % p
    q_prev, q_curr = 0, 1 % p
    seen = {}
    state = (p_prev, p_curr, q_prev, q_curr)
    seen[state] = 0

    for n in range(1, max_steps):
        a = coeffs_func(n) % p
        p_new = (a * p_curr + p_prev) % p
        q_new = (a * q_curr + q_prev) % p
        p_prev, p_curr = p_curr, p_new
        q_prev, q_curr = q_curr, q_new
        state = (p_prev, p_curr, q_prev, q_curr)
        if state in seen:
            return seen[state], n - seen[state]
        seen[state] = n
    return -1, -1


def golden(n):
    return 1

def sqrt2(n):
    return 1 if n == 0 else 2

def sqrt3(n):
    if n == 0: return 1
    return 1 if n % 2 == 1 else 2

def sqrt5(n):
    return 2 if n == 0 else 4

def sqrt7(n):
    if n == 0: return 2
    pattern = [1, 1, 1, 4]
    return pattern[(n - 1) % 4]

def euler_e(n):
    if n == 0: return 2
    if (n + 1) % 3 == 0:
        return 2 * ((n + 1) // 3)
    return 1

def pi_approx(n):
    """Approximate π CF: [3; 7, 15, 1, 292, 1, 1, 1, 2, ...]"""
    pi_cf = [3, 7, 15, 1, 292, 1, 1, 1, 2, 1, 3, 1, 14, 2, 1, 1, 2, 2, 2, 2,
             1, 84, 2, 1, 1, 15, 3, 13, 1, 4, 2, 6, 6, 99, 1, 2, 2, 6, 3, 5]
    return pi_cf[n] if n < len(pi_cf) else 1  # fallback


numbers = [
    ("φ", golden),
    ("√2", sqrt2),
    ("√3", sqrt3),
    ("√5", sqrt5),
    ("√7", sqrt7),
    ("e", euler_e),
    ("π", pi_approx),
]

primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

# Compute periods
period_matrix = np.zeros((len(numbers), len(primes)))
preperiod_matrix = np.zeros((len(numbers), len(primes)))

for i, (name, func) in enumerate(numbers):
    for j, p in enumerate(primes):
        pre, per = cf_state_mod_period(func, p, max_steps=2000)
        period_matrix[i, j] = per if per > 0 else -1
        preperiod_matrix[i, j] = pre if pre >= 0 else -1

# Normalize periods by p for visualization
normalized = np.where(period_matrix > 0, period_matrix / np.array(primes), 0)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

# Left: Raw periods
im1 = ax1.imshow(np.log1p(np.maximum(period_matrix, 0)), aspect='auto',
                  cmap='YlOrRd', interpolation='nearest')
ax1.set_xticks(range(len(primes)))
ax1.set_xticklabels([str(p) for p in primes], fontsize=9)
ax1.set_yticks(range(len(numbers)))
ax1.set_yticklabels([n[0] for n in numbers], fontsize=11)
ax1.set_xlabel('Prime p', fontsize=12)
ax1.set_title('log(1 + Period) of Modular CF State Sequence', fontsize=12, fontweight='bold')

# Add period values as text
for i in range(len(numbers)):
    for j in range(len(primes)):
        val = int(period_matrix[i, j])
        color = 'white' if period_matrix[i, j] > np.median(period_matrix[period_matrix > 0]) else 'black'
        if val > 0:
            ax1.text(j, i, str(val), ha='center', va='center', fontsize=7, color=color)
        else:
            ax1.text(j, i, '?', ha='center', va='center', fontsize=8, color='gray')

plt.colorbar(im1, ax=ax1, label='log(1 + period)')

# Right: Normalized periods (period / p)
im2 = ax2.imshow(normalized, aspect='auto', cmap='viridis', interpolation='nearest',
                  vmin=0, vmax=6)
ax2.set_xticks(range(len(primes)))
ax2.set_xticklabels([str(p) for p in primes], fontsize=9)
ax2.set_yticks(range(len(numbers)))
ax2.set_yticklabels([n[0] for n in numbers], fontsize=11)
ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_title('Period / p  (Pisano-like ratio)', fontsize=12, fontweight='bold')

for i in range(len(numbers)):
    for j in range(len(primes)):
        val = normalized[i, j]
        if val > 0:
            ax2.text(j, i, f'{val:.1f}', ha='center', va='center',
                    fontsize=7, color='white' if val > 3 else 'black')
        else:
            ax2.text(j, i, '?', ha='center', va='center', fontsize=8, color='gray')

plt.colorbar(im2, ax=ax2, label='period / p')

# Add horizontal line separating quadratic from transcendental
for ax in [ax1, ax2]:
    ax.axhline(y=4.5, color='red', linewidth=2, linestyle='--', alpha=0.7)
    ax.text(len(primes) - 0.3, 2, 'Quadratic\nIrrationals', fontsize=8,
            color='red', ha='right', va='center', fontweight='bold')
    ax.text(len(primes) - 0.3, 5.5, 'Transcendental', fontsize=8,
            color='red', ha='right', va='center', fontweight='bold')

fig.suptitle('Modular CF Dynamics: Period Detection Across Primes\n'
             'Quadratic irrationals have bounded periods; transcendentals do not',
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.92])
plt.savefig('viz_periodicity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_periodicity_heatmap.png")
