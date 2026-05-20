#!/usr/bin/env python3
"""
Tropical Brill-Noether Theory: Applications

Real-world applications of Brill-Noether theory to:
1. Error-correcting codes (algebraic geometry codes)
2. Network optimization via chip-firing
3. Moduli space dimension computation
"""

from typing import List, Tuple, Dict
from algorithms import brill_noether_number, brill_noether_threshold


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Algebraic Geometry Codes (Goppa Codes)
# ═══════════════════════════════════════════════════════════════════════

def goppa_code_parameters(g: int, n_points: int, d: int) -> Dict[str, int]:
    """Compute parameters of an algebraic geometry (Goppa) code.

    A Goppa code C(D, G) on a curve of genus g with n rational points,
    using a divisor G of degree d, has:
    - length: n
    - dimension: k ≥ d - g + 1 (by Riemann-Roch, when d ≥ 2g-1)
    - minimum distance: δ ≥ n - d

    The Brill-Noether number controls when such codes can be
    constructed on general curves.

    Args:
        g: genus of the curve
        n_points: number of rational points used
        d: degree of the divisor G

    Returns:
        Dictionary with code parameters
    """
    # Riemann-Roch gives k = d - g + 1 when d >= 2g - 1
    if d >= 2 * g - 1:
        k = d - g + 1
    else:
        # For smaller d, we need ρ ≥ 0 for existence on a general curve
        r = max(0, d - g)  # expected dimension
        rho = brill_noether_number(g, r, d)
        k = max(1, d - g + 1) if rho >= 0 else 0

    min_distance = max(0, n_points - d)
    rate = k / n_points if n_points > 0 else 0
    relative_distance = min_distance / n_points if n_points > 0 else 0

    return {
        "genus": g,
        "length": n_points,
        "degree": d,
        "dimension": k,
        "min_distance": min_distance,
        "rate": round(rate, 4),
        "relative_distance": round(relative_distance, 4),
        "rho": brill_noether_number(g, max(0, d - g), d)
    }


def optimal_code_degree(g: int, n_points: int,
                        target_rate: float = 0.5) -> int:
    """Find the optimal degree for a Goppa code achieving a target rate.

    Searches for the degree d that maximizes the minimum distance
    while achieving rate ≥ target_rate.

    Args:
        g: genus of the curve
        n_points: number of rational points
        target_rate: desired information rate

    Returns:
        Optimal degree d
    """
    best_d = g
    best_distance = 0

    for d in range(g, n_points):
        params = goppa_code_parameters(g, n_points, d)
        if params["rate"] >= target_rate and params["min_distance"] > best_distance:
            best_distance = params["min_distance"]
            best_d = d

    return best_d


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Network Chip-Firing / Load Balancing
# ═══════════════════════════════════════════════════════════════════════

def network_load_balance(loads: List[int],
                         adjacency: List[List[int]]) -> List[List[int]]:
    """Simulate chip-firing for network load balancing.

    Models a distributed system where nodes have varying loads (chips)
    and can transfer load to neighbors. This is equivalent to
    chip-firing on a graph, which is the foundation of tropical
    divisor theory.

    Args:
        loads: initial load at each node
        adjacency: adjacency list (node -> list of neighbors)

    Returns:
        History of load configurations
    """
    n = len(loads)
    current = loads.copy()
    history = [current.copy()]

    max_steps = 100
    for _ in range(max_steps):
        # Find a node that can fire (has enough load)
        fired = False
        for v in range(n):
            degree = len(adjacency[v])
            if current[v] >= degree:
                # Fire vertex v
                new_config = current.copy()
                new_config[v] -= degree
                for neighbor in adjacency[v]:
                    new_config[neighbor] += 1
                current = new_config
                history.append(current.copy())
                fired = True
                break

        if not fired:
            break  # No more fireable vertices

    return history


def analyze_network_stability(loads: List[int],
                              adjacency: List[List[int]]) -> Dict:
    """Analyze stability of a chip configuration on a network.

    In the divisor theory analogy:
    - loads = divisor (chip configuration)
    - degree = sum of loads
    - rank = robustness to adversarial chip removal

    A configuration is "stable" if no vertex can fire.
    The rank measures how many chips can be removed while
    maintaining the ability to reach a stable effective configuration.

    Args:
        loads: chip configuration
        adjacency: network adjacency list

    Returns:
        Analysis dictionary
    """
    n = len(loads)
    total_load = sum(loads)
    genus = sum(len(adj) for adj in adjacency) // 2 - n + 1

    # Check stability
    stable = all(loads[v] < len(adjacency[v]) for v in range(n))

    # Check effectiveness (all loads ≥ 0)
    effective = all(l >= 0 for l in loads)

    return {
        "total_load": total_load,
        "genus": genus,
        "stable": stable,
        "effective": effective,
        "max_load": max(loads),
        "min_load": min(loads),
        "brill_noether_rho": brill_noether_number(genus, 1, total_load)
    }


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Moduli Space Dimension Computation
# ═══════════════════════════════════════════════════════════════════════

def brill_noether_locus_dimension(g: int, r: int, d: int) -> int:
    """Expected dimension of the Brill-Noether locus W^r_d.

    On a general curve of genus g, the Brill-Noether locus W^r_d
    (the space of linear series g^r_d) has dimension exactly ρ(g,r,d)
    when ρ ≥ 0, and is empty when ρ < 0.

    This is the content of the Brill-Noether theorem (Griffiths-Harris 1980),
    proved tropically by Cools-Draisma-Payne-Robeva 2012.

    Args:
        g: genus
        r: rank
        d: degree

    Returns:
        Expected dimension (ρ if ≥ 0, -1 if empty)
    """
    rho = brill_noether_number(g, r, d)
    return rho if rho >= 0 else -1


def moduli_special_divisors(g: int) -> List[Dict]:
    """Catalog all special divisor types on a general curve of genus g.

    A divisor is "special" if r ≥ 1 (it has nontrivial global sections
    beyond the obvious ones). Lists all (r, d) with ρ(g,r,d) = 0,
    the boundary cases.

    Args:
        g: genus of the curve

    Returns:
        List of boundary special divisor types
    """
    specials = []
    for r in range(1, g):
        for d in range(r, 2 * g):
            rho = brill_noether_number(g, r, d)
            if rho == 0:
                specials.append({
                    "rank": r,
                    "degree": d,
                    "rho": rho,
                    "description": f"g^{r}_{d}: {r+1}-dimensional linear series"
                })
    return specials


# ═══════════════════════════════════════════════════════════════════════
# Main: Run all applications
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Tropical Brill-Noether Theory: Applications")
    print("=" * 60)

    # Application 1: Goppa codes
    print("\n1. Algebraic Geometry Codes (Goppa Codes)")
    print("-" * 50)
    print("  Parameters for codes on genus-3 curves with 16 rational points:")
    print(f"  {'d':>3} {'k':>3} {'δ':>3} {'rate':>6} {'rel.δ':>6} {'ρ':>4}")
    for d in range(3, 14):
        params = goppa_code_parameters(3, 16, d)
        print(f"  {d:>3} {params['dimension']:>3} {params['min_distance']:>3}"
              f" {params['rate']:>6.3f} {params['relative_distance']:>6.3f}"
              f" {params['rho']:>4}")

    opt_d = optimal_code_degree(3, 16, target_rate=0.3)
    print(f"\n  Optimal degree for rate ≥ 0.3: d = {opt_d}")
    print(f"  Parameters: {goppa_code_parameters(3, 16, opt_d)}")

    # Application 2: Network load balancing
    print("\n\n2. Network Load Balancing via Chip-Firing")
    print("-" * 50)
    # Ring network with 5 nodes
    adj = [[4, 1], [0, 2], [1, 3], [2, 4], [3, 0]]
    loads = [5, 0, 0, 3, 0]
    print(f"  Ring network (5 nodes), initial loads: {loads}")
    history = network_load_balance(loads, adj)
    for i, config in enumerate(history[:8]):
        print(f"    Step {i}: {config} (total={sum(config)})")
    if len(history) > 8:
        print(f"    ... ({len(history)} total steps)")
        print(f"    Final: {history[-1]}")

    analysis = analyze_network_stability(loads, adj)
    print(f"\n  Network analysis:")
    for key, val in analysis.items():
        print(f"    {key}: {val}")

    # Application 3: Moduli dimensions
    print("\n\n3. Moduli Space Dimensions")
    print("-" * 50)
    for g in [3, 4, 5, 6]:
        print(f"\n  Genus {g}:")
        specials = moduli_special_divisors(g)
        if specials:
            for s in specials:
                print(f"    {s['description']} (ρ = {s['rho']})")
        else:
            print(f"    No boundary special divisors")

        print(f"\n  Dimension table (ρ values, -1 = empty):")
        hdr = 'd\\r'
        print(f"    {hdr:>5}", end="")
        for r in range(1, min(g, 5)):
            print(f"  r={r}", end="")
        print()
        for d in range(2 * g + 1):
            print(f"    d={d:>2}:", end="")
            for r in range(1, min(g, 5)):
                dim = brill_noether_locus_dimension(g, r, d)
                print(f"  {dim:>3}", end="")
            print()

    print("\n\nAll applications completed.")


#!/usr/bin/env python3
"""
Tropical Brill-Noether Theory: Demonstrations

Concrete numerical examples illustrating the Brill-Noether number,
divisor existence on chains of loops, and the classical-tropical bridge.
"""

from typing import List, Tuple
import itertools


def brill_noether_number(g: int, r: int, d: int) -> int:
    """Compute the Brill-Noether number ρ(g,r,d) = g - (r+1)(g - d + r).

    >>> brill_noether_number(3, 1, 3)
    0
    >>> brill_noether_number(4, 1, 3)
    -1
    >>> brill_noether_number(2, 1, 3)
    1
    """
    return g - (r + 1) * (g - d + r)


def brill_noether_expansion(g: int, r: int, d: int) -> int:
    """Equivalent expansion: ρ = (r+1)d - rg - r(r+1).

    >>> brill_noether_expansion(3, 1, 3)
    0
    >>> brill_noether_expansion(5, 2, 7)
    2
    """
    return (r + 1) * d - r * g - r * (r + 1)


# ── Demo 1: Monotonicity in degree ─────────────────────────────────────

def demo_monotonicity_degree():
    """Demonstrate that ρ is nondecreasing in d (Theorem: brillNoetherNumber_mono_degree)."""
    print("=" * 60)
    print("Demo 1: Monotonicity of ρ in degree d")
    print("=" * 60)
    print()

    for g, r in [(3, 1), (5, 2), (7, 3)]:
        print(f"  g={g}, r={r}:")
        values = []
        for d in range(0, 15):
            rho = brill_noether_number(g, r, d)
            values.append(rho)
        print(f"    d:  {list(range(15))}")
        print(f"    ρ:  {values}")
        # Verify monotonicity
        assert all(values[i] <= values[i+1] for i in range(len(values)-1)), \
            "Monotonicity violated!"
        print(f"    ✓ Monotonicity verified")
        print()


# ── Demo 2: Large degree threshold ─────────────────────────────────────

def demo_large_degree_threshold():
    """Demonstrate that ρ ≥ 0 when d ≥ g + r (Theorem: brillNoetherNumber_nonneg_of_degree_large)."""
    print("=" * 60)
    print("Demo 2: Large degree threshold (d ≥ g + r ⟹ ρ ≥ 0)")
    print("=" * 60)
    print()

    for g in range(1, 8):
        for r in range(0, 5):
            d_threshold = g + r
            rho_at_threshold = brill_noether_number(g, r, d_threshold)
            assert rho_at_threshold >= 0, \
                f"Threshold violated at g={g}, r={r}, d={d_threshold}"

    print("  ✓ Verified for all g ∈ [1,7], r ∈ [0,4]: ρ(g,r,g+r) ≥ 0")
    print()

    # Show some examples
    for g, r in [(3, 1), (5, 2), (10, 3)]:
        d = g + r
        rho = brill_noether_number(g, r, d)
        print(f"  g={g}, r={r}, d=g+r={d}: ρ = {rho}")
    print()


# ── Demo 3: Rank zero base case ────────────────────────────────────────

def demo_rank_zero():
    """Demonstrate that ρ(g, 0, d) = d (Theorem: brillNoetherNumber_rank_zero)."""
    print("=" * 60)
    print("Demo 3: Base case ρ(g, 0, d) = d")
    print("=" * 60)
    print()

    for g in range(0, 6):
        for d in range(0, 10):
            assert brill_noether_number(g, 0, d) == d, \
                f"Base case violated at g={g}, d={d}"

    print("  ✓ Verified for all g ∈ [0,5], d ∈ [0,9]: ρ(g, 0, d) = d")
    print()


# ── Demo 4: Certified nonexistence ─────────────────────────────────────

def demo_nonexistence():
    """Demonstrate certified nonexistence when ρ < 0
    (Theorem: no_general_divisor_when_rho_negative)."""
    print("=" * 60)
    print("Demo 4: Certified nonexistence (ρ < 0)")
    print("=" * 60)
    print()

    impossible_cases = []
    for g in range(1, 8):
        for r in range(1, g + 1):
            for d in range(0, 2 * g):
                rho = brill_noether_number(g, r, d)
                if rho < 0:
                    impossible_cases.append((g, r, d, rho))

    print(f"  Found {len(impossible_cases)} certified impossible (g, r, d) triples")
    print(f"  for g ∈ [1,7], r ∈ [1,g], d ∈ [0,2g-1]")
    print()
    print("  Examples of impossible linear series on BN-general curves:")
    for g, r, d, rho in impossible_cases[:8]:
        print(f"    g={g}, r={r}, d={d}: ρ = {rho} < 0 → no g^{r}_{d} exists")
    print()


# ── Demo 5: Classical-tropical bridge ──────────────────────────────────

def demo_bridge():
    """Demonstrate the classical-tropical bridge theorem:
    classical g^r_d existence → ρ ≥ 0 via tropicalization."""
    print("=" * 60)
    print("Demo 5: Classical-Tropical Bridge")
    print("=" * 60)
    print()
    print("  The bridge theorem says: if a classical algebraic curve")
    print("  of genus g carries a g^r_d, and its tropicalization is")
    print("  Brill-Noether general, then ρ(g,r,d) ≥ 0.")
    print()

    # Classical Brill-Noether theorem: a general curve of genus g
    # carries a g^r_d iff ρ ≥ 0
    print("  Classical existence predictions vs tropical ρ:")
    print()
    print(f"  {'g':>3} {'r':>3} {'d':>3} {'ρ':>5}  {'Classical':>10}  {'Tropical':>10}")
    print(f"  {'─'*3} {'─'*3} {'─'*3} {'─'*5}  {'─'*10}  {'─'*10}")

    for g, r, d in [(3,1,3), (4,1,3), (2,1,2), (5,2,7), (6,2,5), (4,1,4)]:
        rho = brill_noether_number(g, r, d)
        classical = "exists" if rho >= 0 else "no"
        tropical = "ρ≥0 ✓" if rho >= 0 else "ρ<0 ✗"
        print(f"  {g:>3} {r:>3} {d:>3} {rho:>5}  {classical:>10}  {tropical:>10}")
    print()
    print("  The bridge theorem ensures these columns always agree")
    print("  for BN-general tropicalizations.")
    print()


# ── Demo 6: Brill-Noether table for genus 4 ───────────────────────────

def demo_genus4_table():
    """Print a complete Brill-Noether table for genus 4."""
    print("=" * 60)
    print("Demo 6: Complete Brill-Noether table for genus 4")
    print("=" * 60)
    print()
    g = 4
    print(f"  Genus g = {g}")
    print(f"  ρ(g,r,d) = g - (r+1)(g - d + r)")
    print()
    print(f"       d=0  d=1  d=2  d=3  d=4  d=5  d=6  d=7  d=8")
    for r in range(5):
        row = []
        for d in range(9):
            rho = brill_noether_number(g, r, d)
            row.append(f"{rho:>4}")
        print(f"  r={r}: {'  '.join(row)}")
    print()
    print("  Positive entries → linear series exist on general curves")
    print("  Negative entries → certified nonexistence")
    print("  Zero entries → boundary case (linear series exist, dimension 0)")
    print()


if __name__ == "__main__":
    demo_monotonicity_degree()
    demo_large_degree_threshold()
    demo_rank_zero()
    demo_nonexistence()
    demo_bridge()
    demo_genus4_table()

    print("All demonstrations completed successfully.")
