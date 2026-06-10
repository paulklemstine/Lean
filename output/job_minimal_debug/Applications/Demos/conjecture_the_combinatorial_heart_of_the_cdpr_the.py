#!/usr/bin/env python3
"""
Tropical Brill-Noether Theory: Applications

Real-world applications and extended computations demonstrating
the CDPR theorem and its consequences.
"""

from typing import List, Tuple, Dict, Optional
from algorithms import (
    brill_noether_number, is_feasible, canonical_allocation,
    round_robin_path, verify_cdpr_path, path_states,
    canonical_tableau, count_allocations, count_tableaux,
    initial_state, in_weyl_chamber
)


# ===================== Application 1: Error-Correcting Codes =====================

def algebraic_geometry_code_parameters(g: int) -> List[Tuple[int, int, int, int]]:
    """
    Compute parameters of algebraic geometry (AG) codes from curves of genus g.

    An AG code from a curve of genus g with degree d and rank r has:
    - Code length: n (number of rational points, at least 2g+1 for our model)
    - Dimension: k = d - g + 1 (for d ≥ 2g - 1)
    - Minimum distance: d* ≥ n - d

    The CDPR theorem tells us which (d, r) pairs are feasible.

    Returns list of (d, r, k, min_dist_bound) for feasible linear series.
    """
    n = 2 * g + 1  # conservative point count
    results = []
    for d in range(0, 2 * g + 1):
        for r in range(0, d + 1):
            if is_feasible(g, r, d) and d >= 2 * g - 1:
                k = d - g + 1
                min_dist = n - d
                if k > 0 and min_dist > 0:
                    results.append((d, r, k, min_dist))
    return results


def demo_error_correcting_codes():
    """Demonstrate AG code parameter computation using Brill-Noether theory."""
    print("=" * 70)
    print("Application 1: Algebraic Geometry Error-Correcting Codes")
    print("=" * 70)
    print()
    print("Using the CDPR theorem to determine feasible linear series for AG codes.")
    print()

    for g in [2, 3, 4, 5]:
        params = algebraic_geometry_code_parameters(g)
        print(f"Genus g = {g} (code length n = {2*g+1}):")
        print(f"  {'d':>3} {'r':>3} {'k':>3} {'d*≥':>4} {'ρ':>4}")
        for d, r, k, md in params[:5]:
            rho = brill_noether_number(g, r, d)
            print(f"  {d:>3} {r:>3} {k:>3} {md:>4} {rho:>4}")
        print()


# ===================== Application 2: Tropical Moduli Spaces =====================

def tropical_moduli_dimension(g: int, r: int, d: int) -> int:
    """
    Compute the expected dimension of the tropical moduli space W^r_d.

    When ρ ≥ 0, the space of divisor classes of degree d and rank r
    on a general curve of genus g has dimension ρ.
    When ρ < 0, the space is expected to be empty.
    """
    return max(0, brill_noether_number(g, r, d))


def demo_moduli_dimensions():
    """Visualize the Brill-Noether moduli structure."""
    print("=" * 70)
    print("Application 2: Tropical Moduli Space Dimensions")
    print("=" * 70)
    print()
    print("Expected dimension of W^r_d (space of rank-r degree-d divisor classes)")
    print()

    for g in [4, 6, 8]:
        print(f"Genus g = {g}:")
        header = 'd\\r'
        print(f"  {header:>5}", end="")
        for r in range(5):
            print(f" {r:>4}", end="")
        print()
        for d in range(0, 2 * g + 1):
            print(f"  {d:>5}", end="")
            for r in range(5):
                rho = brill_noether_number(g, r, d)
                if rho >= 0:
                    print(f" {rho:>4}", end="")
                else:
                    print(f"   ·", end="")
            print()
        print()


# ===================== Application 3: Gonality Sequences =====================

def gonality(g: int) -> int:
    """
    Compute the gonality of a general curve of genus g.

    The gonality is the minimum degree d such that a rank-1 (r=1)
    divisor of degree d exists. By Brill-Noether: ρ(g,1,d) ≥ 0
    iff d ≥ (g+2)/2.
    """
    for d in range(0, 2 * g + 1):
        if is_feasible(g, 1, d):
            return d
    return 2 * g  # fallback


def max_rank_for_degree(g: int, d: int) -> int:
    """Compute the maximum rank r achievable for degree d on genus g."""
    for r in range(d + 1):
        if not is_feasible(g, r, d):
            return r - 1
    return d


def demo_gonality_and_rank():
    """Compute gonality sequences and rank tables."""
    print("=" * 70)
    print("Application 3: Gonality and Maximum Rank")
    print("=" * 70)
    print()

    # Gonality sequence
    print("Gonality of general curves:")
    print(f"  {'g':>3} {'gon':>4}")
    for g in range(0, 13):
        gon = gonality(g)
        print(f"  {g:>3} {gon:>4}")

    # Maximum rank table
    print("\nMaximum rank for degree d on genus g:")
    header = 'd\\g'
    print(f"  {header:>5}", end="")
    for g in range(8):
        print(f" {g:>3}", end="")
    print()
    for d in range(0, 12):
        print(f"  {d:>5}", end="")
        for g in range(8):
            mr = max_rank_for_degree(g, d)
            print(f" {mr:>3}", end="")
        print()


# ===================== Application 4: Path Visualization =====================

def visualize_path(g: int, r: int, d: int):
    """Visualize a CDPR path through the Weyl chamber."""
    print(f"\nCDPR Path Visualization: (g,r,d) = ({g},{r},{d})")
    rho = brill_noether_number(g, r, d)
    print(f"ρ = {rho}")

    if rho < 0:
        print("No valid path exists.")
        return

    sigma = round_robin_path(g, r)
    states = path_states(d, r, sigma)
    valid, reason = verify_cdpr_path(g, r, d, sigma)
    print(f"Round-robin path: {sigma}")
    print(f"Valid: {valid}")
    print()

    # ASCII visualization
    max_val = max(max(s) for s in states)
    for level in range(max_val, -1, -1):
        line = f"  {level:>2} │"
        for i, state in enumerate(states):
            chars = ""
            for j in range(r + 1):
                if state[j] == level:
                    chars += "●"
                elif state[j] > level:
                    chars += "│"
                else:
                    chars += " "
            line += chars + " "
        print(line)
    print(f"     └" + "───" * (g + 1))
    print(f"      " + "".join(f"{i:<3}" for i in range(g + 1)))
    print(f"      step →")
    print(f"      (● = coordinate value at that level)")


def demo_path_visualization():
    """Show path visualizations for several parameter choices."""
    print("=" * 70)
    print("Application 4: Weyl Chamber Path Visualization")
    print("=" * 70)

    visualize_path(4, 1, 3)
    visualize_path(6, 1, 4)
    visualize_path(6, 2, 5)


# ===================== Application 5: Brill-Noether Landscape =====================

def demo_brill_noether_landscape():
    """Generate a heatmap-style view of the Brill-Noether landscape."""
    print("\n" + "=" * 70)
    print("Application 5: Brill-Noether Landscape")
    print("=" * 70)
    print()
    print("For fixed g, show ρ values across (r, d) parameter space.")
    print("• = feasible (ρ ≥ 0), · = infeasible (ρ < 0)")
    print()

    g = 6
    print(f"g = {g}:")
    header = 'r\\d'
    print(f"  {header:>4}", end="")
    for d in range(2 * g + 1):
        print(f"{d:>3}", end="")
    print()

    for r in range(g + 1):
        print(f"  {r:>4}", end="")
        for d in range(2 * g + 1):
            rho = brill_noether_number(g, r, d)
            if rho >= 0:
                if rho == 0:
                    print(f" ○ ", end="")
                else:
                    print(f" • ", end="")
            else:
                print(f" · ", end="")
        print()


# ===================== Application 6: Counting Tropical Divisor Classes =====================

def demo_counting():
    """Count CDPR allocations and tableaux for various parameters."""
    print("\n" + "=" * 70)
    print("Application 6: Counting Combinatorial Objects")
    print("=" * 70)
    print()
    print("Number of CDPR allocations and displacement tableaux:")
    print(f"  {'g':>3} {'r':>3} {'d':>3} {'ρ':>4} {'#alloc':>8} {'#tableau':>10}")

    for g in range(1, 9):
        for r in range(min(g, 3) + 1):
            for d in range(max(0, r), min(2 * g + 1, g + r + 1)):
                rho = brill_noether_number(g, r, d)
                if 0 <= rho <= 3:
                    na = count_allocations(g, r, d)
                    cols = max(0, g + r - d)
                    nt = count_tableaux(g, r + 1, cols) if cols <= 5 else "—"
                    print(f"  {g:>3} {r:>3} {d:>3} {rho:>4} {na:>8} {str(nt):>10}")


# ===================== Main =====================

if __name__ == "__main__":
    demo_error_correcting_codes()
    demo_moduli_dimensions()
    demo_gonality_and_rank()
    demo_path_visualization()
    demo_brill_noether_landscape()
    demo_counting()


#!/usr/bin/env python3
"""
Tropical Brill-Noether Theory: Demonstrations

Concrete numerical examples illustrating the CDPR existence theorem
and the equivalence between allocations, displacement tableaux, and
Weyl chamber lattice paths.
"""

from typing import List, Tuple, Optional
import itertools


def brill_noether_number(g: int, r: int, d: int) -> int:
    """Compute the Brill-Noether number ρ(g,r,d) = g - (r+1)(g-d+r)."""
    return g - (r + 1) * (g - d + r)


def canonical_allocation(g: int, r: int, d: int) -> Optional[List[int]]:
    """
    Construct the canonical CDPR allocation if ρ ≥ 0.

    Returns a weakly decreasing list [s_0, s_1, ..., s_r] summing to g,
    with s_r ≥ g - d + r.
    """
    rho = brill_noether_number(g, r, d)
    if rho < 0:
        return None

    c = max(0, g + r - d)
    s = [0] * (r + 1)
    s[0] = g - r * c
    for j in range(1, r + 1):
        s[j] = c
    return s


def verify_allocation(g: int, r: int, d: int, s: List[int]) -> bool:
    """Verify that s is a valid CDPR allocation."""
    # Sum check
    if sum(s) != g:
        return False
    # Antitone check
    for j in range(len(s) - 1):
        if s[j] < s[j + 1]:
            return False
    # Floor bound
    if s[-1] < g - d + r:
        return False
    return True


def round_robin_path(g: int, r: int) -> List[int]:
    """Construct the round-robin CDPR path: σ(k) = k mod (r+1)."""
    return [k % (r + 1) for k in range(g)]


def step_count(sigma: List[int], r: int, i: int, j: int) -> int:
    """Count how many of the first i steps are assigned to coordinate j."""
    return sum(1 for k in range(min(i, len(sigma))) if sigma[k] == j)


def verify_cdpr_path(g: int, r: int, d: int, sigma: List[int]) -> bool:
    """Verify that sigma is a valid CDPR path."""
    if len(sigma) != g:
        return False

    for i in range(g + 1):
        # Ordering condition
        for j in range(r):
            if step_count(sigma, r, i, j + 1) > step_count(sigma, r, i, j):
                return False
        # Positivity condition
        if d - r - i + step_count(sigma, r, i, r) < 0:
            return False
    return True


def canonical_tableau(g: int, rows: int, cols: int) -> Optional[List[List[int]]]:
    """
    Construct the canonical displacement tableau T(i,j) = i*cols + j.
    Returns None if rows*cols > g.
    """
    if rows * cols > g:
        return None
    return [[i * cols + j for j in range(cols)] for i in range(rows)]


def verify_tableau(g: int, T: List[List[int]]) -> bool:
    """Verify that T is a valid displacement tableau."""
    all_entries = set()
    for row in T:
        # Row-strict
        for j in range(len(row) - 1):
            if row[j] >= row[j + 1]:
                return False
        # All entries in range
        for entry in row:
            if entry < 0 or entry >= g:
                return False
            all_entries.add(entry)
    # Injective
    total_cells = sum(len(row) for row in T)
    return len(all_entries) == total_cells


def weyl_chamber_state(d: int, r: int, sigma: List[int], i: int) -> List[int]:
    """Compute the Weyl chamber state vector at step i."""
    state = [d - j for j in range(r + 1)]
    for k in range(i):
        chosen = sigma[k]
        for j in range(r + 1):
            if j != chosen:
                state[j] -= 1
    return state


# ==================== DEMONSTRATIONS ====================

def demo_brill_noether_table():
    """Print a table of Brill-Noether numbers for small parameters."""
    print("=" * 60)
    print("Demo 1: Brill-Noether Number Table")
    print("=" * 60)
    print(f"{'g':>3} {'r':>3} {'d':>3} {'ρ(g,r,d)':>10} {'Exists?':>8}")
    print("-" * 35)

    cases = [
        (0, 0, 0), (1, 0, 1), (2, 1, 2), (3, 1, 2),
        (3, 1, 3), (4, 1, 3), (5, 1, 4), (6, 1, 4),
        (6, 2, 5), (9, 2, 6), (10, 3, 8), (12, 3, 9),
    ]
    for g, r, d in cases:
        rho = brill_noether_number(g, r, d)
        exists_str = "✓" if rho >= 0 else "✗"
        print(f"{g:>3} {r:>3} {d:>3} {rho:>10} {exists_str:>8}")


def demo_allocation():
    """Demonstrate CDPR allocation construction and verification."""
    print("\n" + "=" * 60)
    print("Demo 2: CDPR Allocation Construction")
    print("=" * 60)

    cases = [(4, 1, 3), (6, 2, 5), (9, 2, 6), (5, 1, 4)]
    for g, r, d in cases:
        rho = brill_noether_number(g, r, d)
        alloc = canonical_allocation(g, r, d)
        print(f"\n(g,r,d) = ({g},{r},{d}), ρ = {rho}")
        if alloc is None:
            print("  No allocation exists (ρ < 0)")
        else:
            valid = verify_allocation(g, r, d, alloc)
            print(f"  Canonical allocation: {alloc}")
            print(f"  Sum = {sum(alloc)}, Valid = {valid}")


def demo_round_robin_path():
    """Demonstrate the round-robin CDPR path."""
    print("\n" + "=" * 60)
    print("Demo 3: Round-Robin CDPR Path")
    print("=" * 60)

    g, r, d = 6, 1, 4
    rho = brill_noether_number(g, r, d)
    sigma = round_robin_path(g, r)
    valid = verify_cdpr_path(g, r, d, sigma)

    print(f"Parameters: (g,r,d) = ({g},{r},{d}), ρ = {rho}")
    print(f"Round-robin path: σ = {sigma}")
    print(f"Valid CDPR path: {valid}")
    print()
    print("Step-by-step Weyl chamber states:")
    print(f"{'Step':>6} {'State':>20} {'Counts':>20} {'In Chamber':>12}")
    for i in range(g + 1):
        state = weyl_chamber_state(d, r, sigma, i)
        counts = [step_count(sigma, r, i, j) for j in range(r + 1)]
        in_chamber = all(state[j] >= state[j + 1] for j in range(r)) and state[r] >= 0
        print(f"{i:>6} {str(state):>20} {str(counts):>20} {'✓' if in_chamber else '✗':>12}")


def demo_displacement_tableau():
    """Demonstrate displacement tableau construction."""
    print("\n" + "=" * 60)
    print("Demo 4: Displacement Tableau")
    print("=" * 60)

    cases = [(4, 1, 3), (6, 1, 4), (9, 2, 6)]
    for g, r, d in cases:
        rho = brill_noether_number(g, r, d)
        rows = r + 1
        cols = max(0, g + r - d)
        T = canonical_tableau(g, rows, cols)
        print(f"\n(g,r,d) = ({g},{r},{d}), ρ = {rho}")
        print(f"Tableau shape: {rows} × {cols}")
        if T is None:
            print("  No tableau exists")
        else:
            valid = verify_tableau(g, T)
            for i, row in enumerate(T):
                print(f"  Row {i}: {row}")
            print(f"  Valid: {valid}")


def demo_exhaustive_search():
    """Exhaustively verify the CDPR theorem for small parameters."""
    print("\n" + "=" * 60)
    print("Demo 5: Exhaustive Verification (small cases)")
    print("=" * 60)

    max_g = 8
    verified = 0
    failures = 0

    for g in range(max_g + 1):
        for r in range(g + 1):
            for d in range(2 * g + 1):
                rho = brill_noether_number(g, r, d)
                alloc = canonical_allocation(g, r, d)

                if rho >= 0:
                    if alloc is None:
                        print(f"  FAILURE: ρ ≥ 0 but no allocation for ({g},{r},{d})")
                        failures += 1
                    elif not verify_allocation(g, r, d, alloc):
                        print(f"  FAILURE: allocation invalid for ({g},{r},{d})")
                        failures += 1
                    else:
                        verified += 1
                else:
                    if alloc is not None:
                        print(f"  FAILURE: ρ < 0 but allocation found for ({g},{r},{d})")
                        failures += 1
                    else:
                        verified += 1

    print(f"\nVerified {verified} cases, {failures} failures (g ≤ {max_g})")
    if failures == 0:
        print("All cases pass! ✓")


def demo_classical_cases():
    """Show classical Brill-Noether theory examples."""
    print("\n" + "=" * 60)
    print("Demo 6: Classical Brill-Noether Examples")
    print("=" * 60)

    print("\n--- Every curve has a degree-g map to P^1 (r=1, d=g) ---")
    for g in range(1, 8):
        rho = brill_noether_number(g, 1, g)
        print(f"  g={g}: ρ(g,1,g) = {rho} {'(exists)' if rho >= 0 else '(no)'}")

    print("\n--- Canonical divisor: r = g-1, d = 2g-2 ---")
    for g in range(1, 8):
        d = 2 * g - 2
        r = g - 1
        rho = brill_noether_number(g, r, d)
        print(f"  g={g}: ρ(g,{r},{d}) = {rho}")

    print("\n--- Hyperelliptic: r=1, d=2 ---")
    for g in range(1, 8):
        rho = brill_noether_number(g, 1, 2)
        print(f"  g={g}: ρ(g,1,2) = {rho} {'(exists)' if rho >= 0 else '(no)'}")


if __name__ == "__main__":
    demo_brill_noether_table()
    demo_allocation()
    demo_round_robin_path()
    demo_displacement_tableau()
    demo_exhaustive_search()
    demo_classical_cases()
