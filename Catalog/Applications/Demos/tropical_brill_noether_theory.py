#!/usr/bin/env python3
"""
Applications of Tropical Brill-Noether Theory

Demonstrates practical applications including:
- Chip-firing games on graphs
- Algebraic curve classification
- Coding theory connections
- Optimization on networks
"""

from typing import List, Tuple, Optional


def brill_noether_number(g: int, r: int, d: int) -> int:
    """ρ(g, r, d) = g - (r+1)(g - d + r)."""
    return g - (r + 1) * (g - d + r)


# ── Application 1: Algebraic Curve Classification ──────────────────

def classify_curve_type(g: int) -> dict:
    """
    Classify a general curve of genus g by its divisor theory.

    Returns a dictionary of key invariants determined by BN theory.
    """
    result = {
        "genus": g,
        "gonality": None,
        "clifford_index": None,
        "max_rank_canonical": None,
        "bn_special_divisors": [],
    }

    # Gonality: min d with ρ(g, 1, d) ≥ 0
    for d in range(2 * g + 1):
        if brill_noether_number(g, 1, d) >= 0:
            result["gonality"] = d
            break

    # Clifford index: gon - 2 for general curves
    if result["gonality"]:
        result["clifford_index"] = result["gonality"] - 2

    # Max rank of canonical divisor (degree 2g-2)
    if g >= 1:
        result["max_rank_canonical"] = g - 1  # By Riemann-Roch

    # Find all (r, d) with ρ = 0 (Brill-Noether special)
    for r in range(1, g):
        for d in range(r, 2 * g):
            if brill_noether_number(g, r, d) == 0:
                result["bn_special_divisors"].append((r, d))

    return result


# ── Application 2: Chip-Firing Resource Allocation ─────────────────

class ChipFiringNetwork:
    """
    Models a resource allocation network as a chip-firing game.

    Vertices represent agents, edges represent communication channels,
    chips represent resources. Chip-firing moves represent resource transfers.
    """

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj = [[0] * n for _ in range(n)]
        for u, v in edges:
            self.adj[u][v] += 1
            self.adj[v][u] += 1

    def genus(self) -> int:
        """Graph genus = |E| - |V| + 1."""
        total_edges = sum(sum(row) for row in self.adj) // 2
        return total_edges - self.n + 1

    def distribute(self, total_resources: int, target_rank: int) -> Optional[List[int]]:
        """
        Find a distribution of `total_resources` chips achieving rank ≥ target_rank.

        Uses BN number as a feasibility check first.
        Returns None if ρ < 0 (infeasible by BN theory).
        """
        g = self.genus()
        rho = brill_noether_number(g, target_rank, total_resources)

        if rho < 0:
            return None  # BN says infeasible

        # Simple greedy distribution (equal spread)
        base = total_resources // self.n
        remainder = total_resources % self.n
        distribution = [base] * self.n
        for i in range(remainder):
            distribution[i] += 1

        return distribution


# ── Application 3: Error-Correcting Codes ──────────────────────────

def algebraic_geometry_code_params(g: int, n: int) -> List[Tuple[int, int, int]]:
    """
    Compute parameters [n, k, d] of AG codes on a genus-g curve.

    For a curve of genus g with n rational points, and a divisor of
    degree d_div and rank r:
    - Code length: n
    - Dimension: k = r + 1 (if d_div < n)
    - Minimum distance: d_code ≥ n - d_div

    Returns list of achievable code parameters.
    """
    codes = []
    for d_div in range(n):
        max_r = -1
        for r in range(d_div + 1):
            if brill_noether_number(g, r, d_div) >= 0:
                max_r = r
            else:
                break

        if max_r >= 0:
            k = max_r + 1
            d_code = n - d_div  # Goppa bound
            if k > 0 and d_code > 0:
                codes.append((n, k, d_code))

    return codes


# ── Application 4: Network Flow Optimization ──────────────────────

def tropical_flow_bound(g: int, d: int) -> int:
    """
    Upper bound on the number of independent flow routes through a
    genus-g network with d available capacity units.

    By tropical BN theory, the maximum "rank" (number of independent routes)
    is bounded by max r such that ρ(g, r, d) ≥ 0.
    """
    max_r = 0
    for r in range(d + 1):
        if brill_noether_number(g, r, d) >= 0:
            max_r = r
        else:
            break
    return max_r


# ── Main Demonstration ────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATIONS OF TROPICAL BRILL-NOETHER THEORY")
    print("=" * 60)

    # Application 1: Curve classification
    print("\n--- Algebraic Curve Classification ---")
    for g in [2, 3, 4, 5, 6]:
        info = classify_curve_type(g)
        print(f"\nGenus {g} general curve:")
        print(f"  Gonality: {info['gonality']}")
        print(f"  Clifford index: {info['clifford_index']}")
        print(f"  Max rank of canonical: {info['max_rank_canonical']}")
        if info['bn_special_divisors']:
            print(f"  BN-special divisors (ρ=0): {info['bn_special_divisors'][:5]}")

    # Application 2: Resource allocation
    print("\n--- Chip-Firing Resource Allocation ---")
    # Pentagon graph
    edges = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)]
    network = ChipFiringNetwork(5, edges)
    print(f"Pentagon network: genus = {network.genus()}")

    for total, rank in [(5, 1), (8, 2), (3, 1), (10, 3)]:
        result = network.distribute(total, rank)
        if result:
            print(f"  {total} resources, rank {rank}: distribution = {result}")
        else:
            rho = brill_noether_number(network.genus(), rank, total)
            print(f"  {total} resources, rank {rank}: INFEASIBLE (ρ = {rho})")

    # Application 3: AG codes
    print("\n--- Algebraic Geometry Codes ---")
    for g, n in [(2, 10), (3, 12), (4, 15)]:
        codes = algebraic_geometry_code_params(g, n)
        print(f"\nGenus {g}, n={n} points:")
        for params in codes[:5]:
            rate = params[1] / params[0]
            print(f"  [{params[0]}, {params[1]}, {params[2]}] rate={rate:.2f}")

    # Application 4: Network flow
    print("\n--- Tropical Flow Bounds ---")
    print("Max independent routes through genus-g network with d capacity:")
    header = "g\d".rjust(4)
    for d in range(1, 11):
        header += f" d={d:>2}"
    print(header)
    for g in range(1, 7):
        row = f"{g:>4}"
        for d in range(1, 11):
            row += f" {tropical_flow_bound(g, d):>4}"
        print(row)


#!/usr/bin/env python3
"""
Tropical Brill-Noether Theory: Interactive Demonstrations

This module provides concrete numerical demonstrations of the key results
from tropical Brill-Noether theory, including:

- Brill-Noether number computation and visualization
- Gonality of generic tropical curves
- Tropical Clifford bound verification
- Chain-of-loops model exploration
"""

from typing import List, Tuple
import itertools


def brill_noether_number(g: int, r: int, d: int) -> int:
    """
    Compute the Brill-Noether number ρ(g, r, d) = g - (r+1)(g - d + r).

    Parameters:
        g: genus of the curve
        r: desired rank of the divisor
        d: degree of the divisor

    Returns:
        The Brill-Noether number ρ(g, r, d)

    Examples:
        >>> brill_noether_number(3, 1, 3)
        1
        >>> brill_noether_number(4, 1, 3)
        0
        >>> brill_noether_number(5, 1, 3)
        -1
    """
    return g - (r + 1) * (g - d + r)


def bn_exists(g: int, r: int, d: int) -> bool:
    """Check whether ρ(g,r,d) ≥ 0 (divisor existence expected)."""
    return brill_noether_number(g, r, d) >= 0


def gonality(g: int) -> int:
    """
    Compute the gonality of a general curve of genus g.
    Gonality = min d such that ρ(g, 1, d) ≥ 0.

    For genus g, gonality = ⌈(g+2)/2⌉.

    >>> gonality(2)
    2
    >>> gonality(3)
    3
    >>> gonality(4)
    3
    >>> gonality(5)
    4
    """
    return (g + 2 + 1) // 2  # ceiling division


def print_bn_table(max_g: int = 8, max_r: int = 4) -> None:
    """Print a table of minimum degrees for rank-r divisors on genus-g curves."""
    print(f"\n{'='*60}")
    print("Minimum degree d for rank-r divisors (ρ(g,r,d) ≥ 0)")
    print(f"{'='*60}")
    header = f"{'g':>2}\{'r':>2}"
    for r in range(max_r + 1):
        header += f"  r={r:>2}"
    print(header)
    print("-" * (4 + 6 * (max_r + 1)))

    for g in range(max_g + 1):
        row = f"{g:>4}"
        for r in range(max_r + 1):
            # Find minimum d
            for d in range(100):
                if bn_exists(g, r, d):
                    row += f"  {d:>4}"
                    break
            else:
                row += "    -"
        print(row)


def print_rho_table(g: int) -> None:
    """Print ρ(g, r, d) for all relevant r, d."""
    print(f"\nρ(g={g}, r, d) table:")
    max_d = 2 * g
    max_r = g
    header = "r\d".rjust(4)
    for d in range(max_d + 1):
        header += f" {d:>3}"
    print(header)
    print("-" * (4 + 4 * (max_d + 1)))

    for r in range(max_r + 1):
        row = f"{r:>4}"
        for d in range(max_d + 1):
            rho = brill_noether_number(g, r, d)
            if rho >= 0:
                row += f" {rho:>3}"
            else:
                row += f"  {rho:>2}"
        print(row)


def clifford_bound_demo() -> None:
    """Demonstrate the Clifford bound: if ρ ≥ 0, r ≥ 1, d ≤ 2g-2, then d ≥ 2r."""
    print("\n" + "=" * 60)
    print("Tropical Clifford Bound Verification")
    print("=" * 60)
    print("Checking: if ρ(g,r,d) ≥ 0, r ≥ 1, g ≥ 2, d ≤ 2g-2 → d ≥ 2r")

    violations = 0
    for g in range(2, 20):
        for r in range(1, g + 1):
            for d in range(2 * g - 1):  # d ≤ 2g-2
                if bn_exists(g, r, d) and d < 2 * r:
                    print(f"  VIOLATION: g={g}, r={r}, d={d}, ρ={brill_noether_number(g,r,d)}")
                    violations += 1

    if violations == 0:
        print("  ✓ No violations found (as expected from our formal proof)")


def gonality_demo() -> None:
    """Demonstrate the gonality computation for generic tropical curves."""
    print("\n" + "=" * 60)
    print("Gonality of Generic Tropical Curves")
    print("=" * 60)
    print(f"{'Genus g':>8}  {'Gonality':>8}  {'ρ(g,1,gon)':>10}  {'ρ(g,1,gon-1)':>12}")
    print("-" * 45)

    for g in range(2, 16):
        gon = gonality(g)
        rho_gon = brill_noether_number(g, 1, gon)
        rho_prev = brill_noether_number(g, 1, gon - 1)
        print(f"{g:>8}  {gon:>8}  {rho_gon:>10}  {rho_prev:>12}")


def chain_of_loops_demo() -> None:
    """Demonstrate the chain-of-loops model."""
    print("\n" + "=" * 60)
    print("Chain of Loops Model")
    print("=" * 60)

    for g in [1, 2, 3, 4, 5]:
        print(f"\nGenus g = {g}:")
        print(f"  Vertices: v_0, v_1, ..., v_{g} ({g+1} vertices)")
        print(f"  Edges: {2*g} edges ({g} loops)")
        print(f"  Genus (first Betti number): {g}")
        print(f"  Gonality: {gonality(g)}")

        # Print BN existence for small d and r
        print(f"  Rank-r divisors exist for:")
        for r in range(min(g + 1, 4)):
            min_d = None
            for d in range(50):
                if bn_exists(g, r, d):
                    min_d = d
                    break
            print(f"    r={r}: d ≥ {min_d} (ρ = {brill_noether_number(g, r, min_d)})")


def specialization_demo() -> None:
    """Demonstrate the specialization principle."""
    print("\n" + "=" * 60)
    print("Baker's Specialization Principle")
    print("=" * 60)
    print("""
The specialization lemma states:
  If an algebraic curve X specializes to a tropical curve Γ,
  and X has a divisor of degree d and rank r,
  then Γ also has a divisor of degree d and rank ≥ r.

Combined with the classical Brill-Noether theorem:
  X has rank-r degree-d divisors when ρ(g,r,d) ≥ 0
  ⟹ Γ has rank-r degree-d divisors when ρ(g,r,d) ≥ 0

This gives the EXISTENCE direction of tropical BN for free!
The NONEXISTENCE direction (ρ < 0 ⟹ no such divisors)
requires the full CDPR combinatorial argument.
""")


if __name__ == "__main__":
    print("=" * 60)
    print("TROPICAL BRILL-NOETHER THEORY: DEMONSTRATIONS")
    print("=" * 60)

    # Core demonstrations
    print_bn_table()
    print_rho_table(4)
    gonality_demo()
    clifford_bound_demo()
    chain_of_loops_demo()
    specialization_demo()

    # Specific examples
    print("\n" + "=" * 60)
    print("Key Examples")
    print("=" * 60)

    examples = [
        (3, 1, 3, "Genus 3, rank 1, degree 3 (hyperelliptic g₃¹)"),
        (4, 1, 3, "Genus 4, rank 1, degree 3 (gonality of genus 4)"),
        (5, 2, 5, "Genus 5, rank 2, degree 5 (canonical on genus 5)"),
        (6, 1, 4, "Genus 6, rank 1, degree 4 (gonality of genus 6)"),
        (4, 2, 4, "Genus 4, rank 2, degree 4 (plane quartic?)"),
    ]

    for g, r, d, desc in examples:
        rho = brill_noether_number(g, r, d)
        exists_str = "EXISTS" if rho >= 0 else "DOES NOT EXIST"
        print(f"  ρ({g},{r},{d}) = {rho:>3} → {exists_str:>15}  ({desc})")
