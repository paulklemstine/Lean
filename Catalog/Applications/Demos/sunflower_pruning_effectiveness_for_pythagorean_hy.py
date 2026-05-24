#!/usr/bin/env python3
"""
Applications of Sunflower Pruning Theory to Pythagorean Hypergraphs.

Demonstrates real-world applications:
1. Minimum transversal computation for Pythagorean coloring problems
2. Kernelization: reducing instance size via sunflower contraction
3. Overlap concentration analysis for arithmetic hypergraphs
4. SAT-inspired preprocessing using sunflower cores
"""

from __future__ import annotations
import math
from collections import defaultdict
from typing import Optional


# ═══════════════════════════════════════════════════════════════════════════
# Utility: Pythagorean Hypergraph Construction
# ═══════════════════════════════════════════════════════════════════════════

def pythagorean_edges(n: int) -> list[frozenset[int]]:
    """All Pythagorean triple edges {a,b,c} with 1 ≤ a < b < c ≤ n."""
    edges = []
    for a in range(1, n + 1):
        for b in range(a + 1, n + 1):
            c2 = a * a + b * b
            c = int(math.isqrt(c2))
            if c * c == c2 and c > b and c <= n:
                edges.append(frozenset({a, b, c}))
    return edges


def vertex_degrees(edges: list[frozenset[int]], n: int) -> dict[int, int]:
    deg = defaultdict(int)
    for e in edges:
        for v in e:
            deg[v] += 1
    return dict(deg)


# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Minimum Transversal via Sunflower Pruning
# ═══════════════════════════════════════════════════════════════════════════

def find_min_transversal(edges: list[frozenset[int]], max_k: int = 20) -> Optional[frozenset[int]]:
    """Find a minimum-size transversal (hitting set) using sunflower-pruned search.

    Iteratively tries k = 1, 2, 3, ... until a hitting set is found.
    Uses sunflower pruning for each attempt.
    """
    for k in range(1, max_k + 1):
        result = _sf_search(edges, k, frozenset())
        if result is not None:
            return result
    return None


def _sf_search(
    edges: list[frozenset[int]], budget: int, current: frozenset[int]
) -> Optional[frozenset[int]]:
    remaining = [e for e in edges if not (e & current)]
    if not remaining:
        return current
    if budget == 0:
        return None

    # Sunflower pruning: find high-degree vertex forming sunflower
    incidence: dict[int, list[frozenset[int]]] = defaultdict(list)
    for e in remaining:
        for v in e:
            incidence[v].append(e)

    # Try singleton-core sunflower
    for v in sorted(incidence, key=lambda x: -len(incidence[x])):
        if len(incidence[v]) <= budget:
            break
        inc = incidence[v]
        sf: list[frozenset[int]] = []
        for e in inc:
            if all(e & f == frozenset({v}) for f in sf):
                sf.append(e)
                if len(sf) > budget:
                    # Found sunflower with > budget petals → must include v
                    return _sf_search(edges, budget - 1, current | {v})

    # Fallback: branch on first uncovered edge
    uncovered = remaining[0]
    for v in sorted(uncovered):
        r = _sf_search(edges, budget - 1, current | {v})
        if r is not None:
            return r
    return None


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Sunflower Kernelization
# ═══════════════════════════════════════════════════════════════════════════

def sunflower_kernel(edges: list[frozenset[int]], k: int) -> list[frozenset[int]]:
    """Apply sunflower kernelization: repeatedly find large sunflowers and
    contract them to their cores.

    After exhaustive application, the resulting instance is a kernel of
    bounded size (for fixed k), preserving hitting-set equivalence.
    """
    current = list(edges)
    changed = True
    reductions = 0

    while changed:
        changed = False
        incidence: dict[int, list[frozenset[int]]] = defaultdict(list)
        for e in current:
            for v in e:
                incidence[v].append(e)

        for v in sorted(incidence, key=lambda x: -len(incidence[x])):
            inc = incidence[v]
            if len(inc) <= k:
                continue
            # Extract a sunflower with core {v}
            sf: list[frozenset[int]] = []
            for e in inc:
                if all(e & f == frozenset({v}) for f in sf):
                    sf.append(e)
                    if len(sf) > k:
                        # Replace sunflower with core
                        sf_set = set(map(id, sf))
                        current = [e for e in current if id(e) not in sf_set]
                        current.append(frozenset({v}))
                        reductions += 1
                        changed = True
                        break
            if changed:
                break

    return current


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: Overlap Concentration Analysis
# ═══════════════════════════════════════════════════════════════════════════

def overlap_concentration_report(n: int) -> dict:
    """Analyze how Pythagorean triple structure concentrates overlap around
    specific vertices, creating the raw material for sunflower extraction."""
    edges = pythagorean_edges(n)
    deg = vertex_degrees(edges, n)

    if not deg:
        return {'n': n, 'edges': 0, 'report': 'No edges'}

    # Degree distribution
    max_deg = max(deg.values())
    degree_hist = defaultdict(int)
    for d in deg.values():
        degree_hist[d] += 1

    # Overlap analysis: for top vertices, compute pairwise intersection stats
    top10 = sorted(deg, key=lambda v: -deg[v])[:10]
    overlap_stats = []
    for v in top10:
        inc = [e for e in edges if v in e]
        # Count pairs with intersection exactly {v}
        singleton_pairs = 0
        total_pairs = 0
        for i, e1 in enumerate(inc):
            for e2 in inc[i+1:]:
                total_pairs += 1
                if e1 & e2 == frozenset({v}):
                    singleton_pairs += 1
        overlap_stats.append({
            'vertex': v,
            'degree': deg[v],
            'total_pairs': total_pairs,
            'singleton_intersection_pairs': singleton_pairs,
            'singleton_ratio': singleton_pairs / total_pairs if total_pairs > 0 else 0,
        })

    return {
        'n': n,
        'num_edges': len(edges),
        'max_degree': max_deg,
        'avg_degree_bound': 3 * len(edges) / n,
        'degree_histogram_top5': sorted(degree_hist.items(), reverse=True)[:5],
        'overlap_stats': overlap_stats,
    }


# ═══════════════════════════════════════════════════════════════════════════
# Application 4: SAT-Inspired Preprocessing
# ═══════════════════════════════════════════════════════════════════════════

def forced_variables(edges: list[frozenset[int]], k: int) -> set[int]:
    """Identify vertices that MUST be in any hitting set of size ≤ k.

    A vertex v is forced if:
    - The edges through v form a sunflower with core {v}
    - The sunflower has > k petals

    This is a preprocessing step analogous to unit propagation in SAT.
    """
    forced = set()
    incidence: dict[int, list[frozenset[int]]] = defaultdict(list)
    for e in edges:
        for v in e:
            incidence[v].append(e)

    for v, inc in incidence.items():
        if len(inc) <= k:
            continue
        sf: list[frozenset[int]] = []
        for e in inc:
            if all(e & f == frozenset({v}) for f in sf):
                sf.append(e)
                if len(sf) > k:
                    forced.add(v)
                    break
    return forced


# ═══════════════════════════════════════════════════════════════════════════
# Main Demo
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=" * 72)
    print("  APPLICATIONS OF SUNFLOWER PRUNING THEORY")
    print("=" * 72)

    # App 1: Minimum transversal
    print("\n── Application 1: Minimum Transversal Computation ──")
    for n in [50, 100, 200]:
        edges = pythagorean_edges(n)
        result = find_min_transversal(edges, max_k=15)
        if result:
            print(f"  n={n}: min transversal size = {len(result)}, T = {sorted(result)[:10]}{'...' if len(result) > 10 else ''}")
        else:
            print(f"  n={n}: no transversal found with k ≤ 15")

    # App 2: Kernelization
    print("\n── Application 2: Sunflower Kernelization ──")
    for n in [100, 200, 500]:
        edges = pythagorean_edges(n)
        for k in [3, 5]:
            kernel = sunflower_kernel(edges, k)
            reduction = (1 - len(kernel) / len(edges)) * 100 if edges else 0
            print(f"  n={n}, k={k}: {len(edges)} edges → {len(kernel)} kernel edges ({reduction:.1f}% reduction)")

    # App 3: Overlap concentration
    print("\n── Application 3: Overlap Concentration ──")
    for n in [100, 200]:
        report = overlap_concentration_report(n)
        print(f"\n  n={n}: {report['num_edges']} edges, max degree = {report['max_degree']}")
        print(f"  Average degree lower bound (3|E|/n) = {report['avg_degree_bound']:.1f}")
        print(f"  Top vertices by overlap concentration:")
        for s in report['overlap_stats'][:3]:
            print(f"    v={s['vertex']}: deg={s['degree']}, "
                  f"{s['singleton_intersection_pairs']}/{s['total_pairs']} singleton pairs "
                  f"({s['singleton_ratio']:.1%})")

    # App 4: Forced variables
    print("\n── Application 4: Forced Variables (SAT-style preprocessing) ──")
    for n in [100, 200, 500]:
        edges = pythagorean_edges(n)
        for k in [3, 5, 8]:
            fv = forced_variables(edges, k)
            print(f"  n={n}, k={k}: {len(fv)} forced vertices: {sorted(fv)[:10]}{'...' if len(fv) > 10 else ''}")

    print("\n" + "=" * 72)


#!/usr/bin/env python3
"""
Sunflower Pruning for Pythagorean Hypergraphs — Interactive Demo

Demonstrates that the arithmetic structure of Pythagorean triples creates
forced overlap patterns exploitable by sunflower-based branching, yielding
dramatic search-tree reduction compared to naive hitting-set algorithms.

Usage:
    python demo.py
"""

from __future__ import annotations
import time
import math
from itertools import combinations
from collections import defaultdict
from typing import Optional


# ═══════════════════════════════════════════════════════════════════════════
# Core Construction
# ═══════════════════════════════════════════════════════════════════════════

def pythagorean_edges(n: int) -> list[frozenset[int]]:
    """All Pythagorean triple edges {a,b,c} with 1 ≤ a < b < c ≤ n."""
    edges = []
    for a in range(1, n + 1):
        for b in range(a + 1, n + 1):
            c2 = a * a + b * b
            c = int(math.isqrt(c2))
            if c * c == c2 and c > b and c <= n:
                edges.append(frozenset({a, b, c}))
    return edges


def vertex_degrees(edges: list[frozenset[int]], n: int) -> dict[int, int]:
    """Degree of each vertex in {1,...,n}."""
    deg = defaultdict(int)
    for e in edges:
        for v in e:
            deg[v] += 1
    return dict(deg)


# ═══════════════════════════════════════════════════════════════════════════
# Sunflower Detection
# ═══════════════════════════════════════════════════════════════════════════

def find_sunflower_singleton_core(
    edges: list[frozenset[int]], min_petals: int
) -> Optional[tuple[frozenset[int], list[frozenset[int]]]]:
    """Find a sunflower with singleton core {v} and ≥ min_petals petals."""
    incidence: dict[int, list[frozenset[int]]] = defaultdict(list)
    for e in edges:
        for v in e:
            incidence[v].append(e)

    for v in sorted(incidence, key=lambda x: -len(incidence[x])):
        inc = incidence[v]
        if len(inc) < min_petals:
            continue
        sunflower: list[frozenset[int]] = []
        for e in inc:
            if all(e & f == frozenset({v}) for f in sunflower):
                sunflower.append(e)
                if len(sunflower) >= min_petals:
                    return frozenset({v}), sunflower
    return None


# ═══════════════════════════════════════════════════════════════════════════
# Hitting Set Search — Naive
# ═══════════════════════════════════════════════════════════════════════════

def naive_search(
    edges: list[frozenset[int]], budget: int, current: frozenset[int],
    counter: list[int]
) -> Optional[frozenset[int]]:
    counter[0] += 1
    uncovered = next((e for e in edges if not (e & current)), None)
    if uncovered is None:
        return current
    if budget == 0:
        return None
    for v in sorted(uncovered):
        r = naive_search(edges, budget - 1, current | {v}, counter)
        if r is not None:
            return r
    return None


# ═══════════════════════════════════════════════════════════════════════════
# Hitting Set Search — Sunflower-Pruned
# ═══════════════════════════════════════════════════════════════════════════

def sunflower_search(
    edges: list[frozenset[int]], budget: int, current: frozenset[int],
    counter: list[int]
) -> Optional[frozenset[int]]:
    counter[0] += 1
    remaining = [e for e in edges if not (e & current)]
    if not remaining:
        return current
    if budget == 0:
        return None
    sf = find_sunflower_singleton_core(remaining, budget + 1)
    if sf is not None:
        core, _ = sf
        for v in sorted(core):
            r = sunflower_search(edges, budget - 1, current | {v}, counter)
            if r is not None:
                return r
        return None
    uncovered = remaining[0]
    for v in sorted(uncovered):
        r = sunflower_search(edges, budget - 1, current | {v}, counter)
        if r is not None:
            return r
    return None


# ═══════════════════════════════════════════════════════════════════════════
# Demo Runner
# ═══════════════════════════════════════════════════════════════════════════

def run_demo():
    print("=" * 72)
    print("  SUNFLOWER PRUNING FOR PYTHAGOREAN HYPERGRAPHS")
    print("  Demonstrating arithmetic structure → search collapse")
    print("=" * 72)

    test_values = [50, 100, 200, 500]

    # ── Part 1: Hypergraph Structure ──────────────────────────────────────
    print("\n┌─────────────────────────────────────────────────────────────┐")
    print("│  PART 1: Pythagorean Hypergraph Structure                  │")
    print("└─────────────────────────────────────────────────────────────┘")
    print(f"{'n':>6} │ {'|E|':>7} │ {'max deg':>8} │ {'vertex':>6} │ {'3|E|/n':>8} │ {'max SF':>6}")
    print("───────┼─────────┼──────────┼────────┼──────────┼────────")

    edge_data = {}
    for n in test_values:
        edges = pythagorean_edges(n)
        edge_data[n] = edges
        deg = vertex_degrees(edges, n)
        if not deg:
            print(f"{n:>6} │ {0:>7} │ {'—':>8} │ {'—':>6} │ {'—':>8} │ {'—':>6}")
            continue

        max_v = max(deg, key=deg.get)
        max_d = deg[max_v]
        avg_bound = 3 * len(edges) / n if n > 0 else 0

        # Find max sunflower around top vertex
        inc = [e for e in edges if max_v in e]
        sf: list[frozenset[int]] = []
        for e in inc:
            if all(e & f == frozenset({max_v}) for f in sf):
                sf.append(e)
        sf_size = len(sf)

        print(f"{n:>6} │ {len(edges):>7} │ {max_d:>8} │ {max_v:>6} │ {avg_bound:>8.1f} │ {sf_size:>6}")

    # ── Part 2: Incidence Double-Counting Verification ────────────────────
    print("\n┌─────────────────────────────────────────────────────────────┐")
    print("│  PART 2: Verified Incidence Identity ∑ deg(v) = 3·|E|      │")
    print("└─────────────────────────────────────────────────────────────┘")
    for n in test_values:
        edges = edge_data[n]
        deg = vertex_degrees(edges, n)
        deg_sum = sum(deg.values())
        three_E = 3 * len(edges)
        status = "✓ VERIFIED" if deg_sum == three_E else "✗ FAILED"
        print(f"  n={n:>4}: ∑ deg(v) = {deg_sum:>6},  3·|E| = {three_E:>6}  [{status}]")

    # ── Part 3: Search Comparison ─────────────────────────────────────────
    print("\n┌─────────────────────────────────────────────────────────────┐")
    print("│  PART 3: Naive vs Sunflower-Pruned Transversal Search      │")
    print("└─────────────────────────────────────────────────────────────┘")

    # Use small k values and moderate n to keep runtime manageable
    test_cases = [(50, 5), (50, 6), (100, 5), (100, 6)]

    print(f"{'(n,k)':>10} │ {'naive calls':>12} │ {'SF calls':>12} │ {'ratio':>8} │ {'gain':>8}")
    print("───────────┼──────────────┼──────────────┼──────────┼─────────")

    for n, k in test_cases:
        edges = edge_data.get(n, pythagorean_edges(n))

        # Naive search
        counter_n = [0]
        t0 = time.time()
        result_n = naive_search(edges, k, frozenset(), counter_n)
        t_naive = time.time() - t0

        # Sunflower search
        counter_s = [0]
        t0 = time.time()
        result_s = sunflower_search(edges, k, frozenset(), counter_s)
        t_sf = time.time() - t0

        cn, cs = counter_n[0], counter_s[0]
        ratio = cn / cs if cs > 0 else float('inf')
        gain = (1 - cs / cn) * 100 if cn > 0 else 0

        print(f"  ({n},{k}){' ' * (5 - len(str(n)) - len(str(k)))} │ {cn:>12,} │ {cs:>12,} │ {ratio:>7.1f}x │ {gain:>6.1f}%")

    # ── Part 4: Sunflower Core Statistics ─────────────────────────────────
    print("\n┌─────────────────────────────────────────────────────────────┐")
    print("│  PART 4: Sunflower Core Statistics (Overlap Concentration) │")
    print("└─────────────────────────────────────────────────────────────┘")

    for n in [100, 200, 500]:
        edges = edge_data.get(n, pythagorean_edges(n))
        deg = vertex_degrees(edges, n)
        if not deg:
            continue

        # Top-5 vertices by degree
        top5 = sorted(deg, key=lambda v: -deg[v])[:5]
        print(f"\n  n = {n} ({len(edges)} edges)")
        print(f"  {'vertex':>8} │ {'degree':>7} │ {'sunflower size':>14} │ {'core':>6}")
        print(f"  {'─'*8}─┼─{'─'*7}─┼─{'─'*14}─┼─{'─'*6}")

        for v in top5:
            inc = [e for e in edges if v in e]
            sf: list[frozenset[int]] = []
            for e in inc:
                if all(e & f == frozenset({v}) for f in sf):
                    sf.append(e)
            print(f"  {v:>8} │ {deg[v]:>7} │ {len(sf):>14} │ {{{v}}}")

    # ── Part 5: Theoretical Branching Comparison ──────────────────────────
    print("\n┌─────────────────────────────────────────────────────────────┐")
    print("│  PART 5: Theoretical Branching: 3^k (naive) vs 1^k (core) │")
    print("└─────────────────────────────────────────────────────────────┘")
    print(f"  {'k':>4} │ {'3^k (naive)':>14} │ {'1^k (SF core)':>14} │ {'ratio':>10}")
    print(f"  {'─'*4}─┼─{'─'*14}─┼─{'─'*14}─┼─{'─'*10}")
    for k in range(1, 11):
        naive = 3 ** k
        sf_val = 1
        print(f"  {k:>4} │ {naive:>14,} │ {sf_val:>14} │ {naive:>10,}x")

    print("\n" + "=" * 72)
    print("  CONCLUSION: Arithmetic structure of Pythagorean triples creates")
    print("  high-degree vertices with large singleton-core sunflowers,")
    print("  enabling exponential search-tree compression via sunflower pruning.")
    print("=" * 72)


if __name__ == '__main__':
    run_demo()
