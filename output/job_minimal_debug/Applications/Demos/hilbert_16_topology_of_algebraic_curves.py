#!/usr/bin/env python3
"""
Applications of Hilbert 16 Infrastructure:
Real-world connections of algebraic curve topology, Harnack bounds,
and Hamiltonian dynamics.

Demonstrates applications to:
1. Topological classification of real algebraic curves
2. Phase portrait analysis of polynomial Hamiltonian systems
3. Certified bounds on periodic orbits
4. Oval arrangement enumeration and visualization
"""

from __future__ import annotations
import math
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


# ============================================================================
# Application 1: Topological Classification of Real Quartic Curves
# ============================================================================

def classify_quartic_arrangements() -> List[Dict]:
    """Enumerate all topologically distinct oval arrangements for quartics.

    A smooth real quartic (degree 4) has at most 4 ovals (Harnack bound).
    The nesting depth is at most ⌊4/2⌋ = 2.

    Returns a list of all possible topological types, classified by:
    - Number of ovals k (0 ≤ k ≤ 4)
    - Nesting structure (as a forest)

    Returns:
        List of dicts describing each arrangement type

    Mathematical context:
        The complete classification of quartic curves was achieved by
        Hilbert (1891) for non-singular curves. There are exactly 6
        topological types with maximal component count.
    """
    arrangements = []

    # k = 0: empty real locus
    arrangements.append({
        "num_ovals": 0,
        "nesting": "∅",
        "description": "Empty real locus",
        "notation": "⟨0⟩"
    })

    # k = 1: single oval
    arrangements.append({
        "num_ovals": 1,
        "nesting": "○",
        "description": "Single oval",
        "notation": "⟨1⟩"
    })

    # k = 2: two ovals, two cases
    arrangements.append({
        "num_ovals": 2,
        "nesting": "○ ○",
        "description": "Two unnested ovals",
        "notation": "⟨2⟩"
    })
    arrangements.append({
        "num_ovals": 2,
        "nesting": "○(○)",
        "description": "Two nested ovals (one inside the other)",
        "notation": "⟨1⟨1⟩⟩"
    })

    # k = 3: three ovals
    arrangements.append({
        "num_ovals": 3,
        "nesting": "○ ○ ○",
        "description": "Three unnested ovals",
        "notation": "⟨3⟩"
    })
    arrangements.append({
        "num_ovals": 3,
        "nesting": "○(○) ○",
        "description": "One nested pair plus one free oval",
        "notation": "⟨1⟨1⟩ ∪ 1⟩"
    })

    # k = 4: four ovals (Harnack maximum)
    arrangements.append({
        "num_ovals": 4,
        "nesting": "○ ○ ○ ○",
        "description": "Four unnested ovals (M-curve type 1)",
        "notation": "⟨4⟩"
    })
    arrangements.append({
        "num_ovals": 4,
        "nesting": "○(○) ○ ○",
        "description": "One nested pair plus two free ovals",
        "notation": "⟨1⟨1⟩ ∪ 2⟩"
    })
    arrangements.append({
        "num_ovals": 4,
        "nesting": "○(○) ○(○)",
        "description": "Two nested pairs",
        "notation": "⟨1⟨1⟩ ∪ 1⟨1⟩⟩"
    })
    arrangements.append({
        "num_ovals": 4,
        "nesting": "○(○(○)) ○",
        "description": "Triple nesting plus free oval",
        "notation": "⟨1⟨1⟨1⟩⟩ ∪ 1⟩"
    })
    # Note: depth 2 = ⌊4/2⌋ is achievable
    arrangements.append({
        "num_ovals": 4,
        "nesting": "○(○ ○ ○)",
        "description": "One outer oval containing three inner ovals",
        "notation": "⟨1⟨3⟩⟩"
    })

    return arrangements


# ============================================================================
# Application 2: Hamiltonian Phase Portrait Analysis
# ============================================================================

@dataclass
class PolynomialHamiltonian:
    """A polynomial Hamiltonian H(x,y) for phase portrait analysis.

    Represents H as a dictionary of coefficients: {(i,j): a_ij}
    where H(x,y) = Σ a_ij x^i y^j.
    """
    coeffs: Dict[Tuple[int, int], float]
    name: str = ""

    @property
    def degree(self) -> int:
        """Total degree of the polynomial."""
        if not self.coeffs:
            return 0
        return max(i + j for (i, j) in self.coeffs.keys() if self.coeffs[(i, j)] != 0)

    def eval(self, x: float, y: float) -> float:
        """Evaluate H(x,y)."""
        return sum(c * x**i * y**j for (i, j), c in self.coeffs.items())

    def grad(self, x: float, y: float) -> Tuple[float, float]:
        """Compute ∇H = (∂H/∂x, ∂H/∂y) at (x,y)."""
        dHdx = sum(c * i * x**(i-1) * y**j
                    for (i, j), c in self.coeffs.items() if i > 0)
        dHdy = sum(c * x**i * j * y**(j-1)
                    for (i, j), c in self.coeffs.items() if j > 0)
        return (dHdx, dHdy)

    def hamiltonian_vf(self, x: float, y: float) -> Tuple[float, float]:
        """Compute X_H = (∂H/∂y, -∂H/∂x) at (x,y)."""
        dHdx, dHdy = self.grad(x, y)
        return (dHdy, -dHdx)

    def is_regular(self, x: float, y: float, tol: float = 1e-10) -> bool:
        """Check if (x,y) is a regular point of H."""
        dHdx, dHdy = self.grad(x, y)
        return math.sqrt(dHdx**2 + dHdy**2) > tol

    def max_periodic_orbits(self) -> int:
        """Upper bound on compact periodic orbits at any regular energy."""
        d = self.degree
        return (d - 1) * (d - 2) // 2 + 1

    def analyze_level_set(self, c: float, grid_size: int = 200,
                          x_range: Tuple[float, float] = (-3, 3),
                          y_range: Tuple[float, float] = (-3, 3)
                          ) -> Dict:
        """Analyze the level set H(x,y) = c numerically.

        Uses a grid-based approach to count approximate connected components
        and detect nesting structure.

        Args:
            c: Level set value
            grid_size: Resolution of the analysis grid
            x_range: Range for x coordinate
            y_range: Range for y coordinate

        Returns:
            Dictionary with analysis results
        """
        dx = (x_range[1] - x_range[0]) / grid_size
        dy = (y_range[1] - y_range[0]) / grid_size

        # Count sign changes along grid lines (approximate zero crossings)
        crossings = 0
        regular_crossings = 0

        for i in range(grid_size):
            for j in range(grid_size):
                x = x_range[0] + i * dx
                y = y_range[0] + j * dy
                val = self.eval(x, y) - c

                # Check right neighbor
                if i < grid_size - 1:
                    x_next = x + dx
                    val_next = self.eval(x_next, y) - c
                    if val * val_next < 0:
                        crossings += 1
                        x_mid = (x + x_next) / 2
                        if self.is_regular(x_mid, y):
                            regular_crossings += 1

                # Check upper neighbor
                if j < grid_size - 1:
                    y_next = y + dy
                    val_next = self.eval(x, y_next) - c
                    if val * val_next < 0:
                        crossings += 1
                        y_mid = (y + y_next) / 2
                        if self.is_regular(x, y_mid):
                            regular_crossings += 1

        return {
            "level_value": c,
            "grid_crossings": crossings,
            "regular_crossings": regular_crossings,
            "max_components": self.max_periodic_orbits(),
            "degree": self.degree,
        }


# ============================================================================
# Application 3: Certified Bounds for Dynamical Systems
# ============================================================================

def analyze_perturbation_bounds(degree: int) -> Dict:
    """Compute certified bounds for a perturbed Hamiltonian system.

    For a polynomial Hamiltonian of degree d, under small perturbation:
    - Periodic orbits → limit cycles (some persist, some vanish)
    - Upper bound on limit cycles ≤ Harnack bound

    This is the "weak Hilbert 16" bound for near-Hamiltonian systems.

    Args:
        degree: Degree of the Hamiltonian

    Returns:
        Dictionary with bound information
    """
    g = (degree - 1) * (degree - 2) // 2
    h = g + 1

    return {
        "degree": degree,
        "genus": g,
        "harnack_bound": h,
        "max_periodic_orbits": h,
        "max_limit_cycles_near_hamiltonian": h,
        "nesting_depth_bound": degree // 2,
        "quadratic_bound": degree * degree,
    }


# ============================================================================
# Application 4: Curve Topology Database
# ============================================================================

def build_topology_database(max_degree: int = 8) -> List[Dict]:
    """Build a database of topological constraints for real plane curves.

    For each degree d from 1 to max_degree, records:
    - Genus
    - Harnack bound
    - Parity constraints on oval count
    - Nesting depth bound
    - Known classification status

    Args:
        max_degree: Maximum degree to include

    Returns:
        List of records, one per degree
    """
    database = []

    classification_status = {
        1: "Complete: single line or empty",
        2: "Complete: conic sections (Apollonius, ~200 BCE)",
        3: "Complete: Newton's classification (1704)",
        4: "Complete: Hilbert (1891), Gudkov (1969), Rokhlin (1972)",
        5: "Complete: Kharlamov (1973), Gudkov-Krakhnov (1978)",
        6: "Complete: Gudkov conjecture proved by Rokhlin (1972), "
           "full classification by Nikulin (1979) and Kharlamov",
        7: "Partial: many constraints known, full classification open",
        8: "Partial: some constraints, largely open",
    }

    for d in range(1, max_degree + 1):
        g = (d - 1) * (d - 2) // 2
        h = g + 1

        # Parity constraint: for even d, the number of ovals has the
        # same parity as g + 1 (mod 2) for M-curves
        if d % 2 == 0:
            m_curve_parity = "even" if h % 2 == 0 else "odd"
        else:
            m_curve_parity = "any (odd degree)"

        record = {
            "degree": d,
            "genus": g,
            "harnack_bound": h,
            "max_nesting_depth": d // 2,
            "m_curve_oval_parity": m_curve_parity,
            "classification_status": classification_status.get(d, "Open"),
        }
        database.append(record)

    return database


# ============================================================================
# Main Demo
# ============================================================================

if __name__ == "__main__":
    # Application 1: Quartic classification
    print("=" * 70)
    print("APPLICATION 1: Topological Types of Real Quartic Curves")
    print("=" * 70)
    arrangements = classify_quartic_arrangements()
    for i, arr in enumerate(arrangements, 1):
        print(f"  Type {i:2d}: k={arr['num_ovals']}, "
              f"nesting={arr['nesting']:20s}  {arr['description']}")
    print(f"\n  Total topological types: {len(arrangements)}")
    print(f"  Harnack bound: {(4-1)*(4-2)//2 + 1} = 4 ovals maximum")

    # Application 2: Phase portrait analysis
    print("\n" + "=" * 70)
    print("APPLICATION 2: Hamiltonian Phase Portrait Analysis")
    print("=" * 70)

    # Example 1: Harmonic oscillator H = x² + y²
    h_oscillator = PolynomialHamiltonian(
        {(2, 0): 1.0, (0, 2): 1.0},
        name="Harmonic oscillator"
    )
    print(f"\n  {h_oscillator.name}: H = x² + y², degree = {h_oscillator.degree}")
    print(f"  Max periodic orbits (Harnack): {h_oscillator.max_periodic_orbits()}")
    for c in [0.5, 1.0, 2.0]:
        result = h_oscillator.analyze_level_set(c)
        print(f"    Level c={c}: {result['grid_crossings']} crossings detected")

    # Example 2: Double well H = x⁴/4 - x²/2 + y²/2
    h_double_well = PolynomialHamiltonian(
        {(4, 0): 0.25, (2, 0): -0.5, (0, 2): 0.5},
        name="Double well"
    )
    print(f"\n  {h_double_well.name}: H = x⁴/4 - x²/2 + y²/2, degree = {h_double_well.degree}")
    print(f"  Max periodic orbits (Harnack): {h_double_well.max_periodic_orbits()}")
    for c in [-0.2, 0.0, 0.1, 0.5]:
        result = h_double_well.analyze_level_set(c, grid_size=100)
        print(f"    Level c={c}: {result['grid_crossings']} crossings, "
              f"max components = {result['max_components']}")

    # Example 3: Cubic H = x³/3 - xy
    h_cubic = PolynomialHamiltonian(
        {(3, 0): 1/3, (1, 1): -1.0},
        name="Cubic Hamiltonian"
    )
    print(f"\n  {h_cubic.name}: H = x³/3 - xy, degree = {h_cubic.degree}")
    print(f"  Max periodic orbits (Harnack): {h_cubic.max_periodic_orbits()}")

    # Application 3: Perturbation bounds
    print("\n" + "=" * 70)
    print("APPLICATION 3: Certified Perturbation Bounds")
    print("=" * 70)
    print(f"\n  {'Degree':>8} {'Genus':>8} {'Harnack':>10} {'Max LCs':>10} {'Depth':>8}")
    print("  " + "-" * 48)
    for d in range(2, 9):
        bounds = analyze_perturbation_bounds(d)
        print(f"  {d:>8} {bounds['genus']:>8} {bounds['harnack_bound']:>10} "
              f"{bounds['max_limit_cycles_near_hamiltonian']:>10} "
              f"{bounds['nesting_depth_bound']:>8}")

    # Application 4: Topology database
    print("\n" + "=" * 70)
    print("APPLICATION 4: Real Plane Curve Topology Database")
    print("=" * 70)
    db = build_topology_database()
    for record in db:
        print(f"\n  Degree {record['degree']}:")
        print(f"    Genus: {record['genus']}")
        print(f"    Harnack bound: {record['harnack_bound']}")
        print(f"    Max nesting depth: {record['max_nesting_depth']}")
        print(f"    Status: {record['classification_status']}")


#!/usr/bin/env python3
"""
Demonstration of Hilbert 16 Infrastructure: Genus Formula, Harnack Bound,
Oval Arrangements, and Hamiltonian Level Sets.

This script provides concrete numerical demonstrations of the theorems
formalized in the Lean 4 development.
"""

import math
from typing import List, Tuple, Optional


def plane_curve_genus(d: int) -> int:
    """Compute the genus of a smooth projective plane curve of degree d.

    The genus formula is g = (d-1)(d-2)/2, derived from the degree-genus
    formula for smooth projective curves.

    >>> plane_curve_genus(1)
    0
    >>> plane_curve_genus(3)
    1
    >>> plane_curve_genus(6)
    10
    """
    if d < 2:
        return 0
    return (d - 1) * (d - 2) // 2


def harnack_bound(d: int) -> int:
    """Compute the Harnack bound: maximum number of ovals for degree d.

    The Harnack bound is g + 1 = (d-1)(d-2)/2 + 1, first proved by
    Axel Harnack in 1876.

    >>> harnack_bound(1)
    1
    >>> harnack_bound(4)
    4
    >>> harnack_bound(6)
    11
    """
    return plane_curve_genus(d) + 1


def print_genus_table(max_degree: int = 12) -> None:
    """Print a table of genus and Harnack bound values."""
    print("=" * 60)
    print("GENUS FORMULA AND HARNACK BOUND FOR PLANE CURVES")
    print("=" * 60)
    print(f"{'Degree d':>10} {'Genus g':>10} {'Harnack g+1':>12} {'d²':>8}")
    print("-" * 42)
    for d in range(1, max_degree + 1):
        g = plane_curve_genus(d)
        h = harnack_bound(d)
        print(f"{d:>10} {g:>10} {h:>12} {d*d:>8}")
    print()
    print("Key observations:")
    print("  • Lines (d=1) and conics (d=2) have genus 0, at most 1 oval")
    print("  • Cubics (d=3) have genus 1, at most 2 ovals")
    print("  • Quartics (d=4) have genus 3, at most 4 ovals")
    print("  • The bound grows quadratically: g+1 ≤ d²")
    print()


def demonstrate_genus_recurrence(max_d: int = 10) -> None:
    """Demonstrate the genus recurrence: g(d+1) = g(d) + (d-1)."""
    print("=" * 60)
    print("GENUS RECURRENCE: g(d+1) = g(d) + (d-1)")
    print("=" * 60)
    for d in range(2, max_d):
        g_d = plane_curve_genus(d)
        g_d1 = plane_curve_genus(d + 1)
        diff = g_d1 - g_d
        check = "✓" if diff == d - 1 else "✗"
        print(f"  g({d+1}) = g({d}) + {d-1} = {g_d} + {d-1} = {g_d1}  {check}")
    print()


class NestingForest:
    """A nesting forest for ovals of a real plane curve.

    Each oval is represented by an integer ID. The parent function
    maps each oval to its immediately enclosing oval (or None for roots).
    """

    def __init__(self, parents: dict[int, Optional[int]]):
        """Create a nesting forest from a parent map.

        Args:
            parents: dict mapping oval ID -> parent ID (None for roots)
        """
        self.parents = parents
        self.ovals = set(parents.keys())

    @property
    def num_ovals(self) -> int:
        return len(self.ovals)

    @property
    def roots(self) -> set[int]:
        return {o for o in self.ovals if self.parents[o] is None}

    def depth(self, oval: int) -> int:
        """Compute the nesting depth of an oval."""
        d = 0
        current = oval
        while self.parents[current] is not None:
            current = self.parents[current]
            d += 1
        return d

    def max_depth(self) -> int:
        return max(self.depth(o) for o in self.ovals) if self.ovals else 0

    def is_outer(self, oval: int) -> bool:
        """An oval is outer if its depth is even."""
        return self.depth(oval) % 2 == 0

    def is_inner(self, oval: int) -> bool:
        """An oval is inner if its depth is odd."""
        return self.depth(oval) % 2 == 1

    def children(self, oval: int) -> set[int]:
        return {o for o in self.ovals if self.parents[o] == oval}

    def display(self, oval: Optional[int] = None, indent: int = 0) -> None:
        """Display the forest structure."""
        if oval is None:
            for root in sorted(self.roots):
                self.display(root, indent)
            return
        parity = "outer" if self.is_outer(oval) else "inner"
        print(f"{'  ' * indent}Oval {oval} (depth={self.depth(oval)}, {parity})")
        for child in sorted(self.children(oval)):
            self.display(child, indent + 1)


def demonstrate_oval_arrangements() -> None:
    """Demonstrate oval arrangement structures for various curve types."""
    print("=" * 60)
    print("OVAL ARRANGEMENTS AND NESTING FORESTS")
    print("=" * 60)

    # Example 1: Quartic with 4 ovals (Harnack maximum)
    # Two nested pairs: (1 inside 2) and (3 inside 4)
    print("\n--- Quartic (degree 4, max 4 ovals) ---")
    print("Configuration: Two nested pairs")
    forest1 = NestingForest({1: 2, 2: None, 3: 4, 4: None})
    forest1.display()
    print(f"  Nesting depth: {forest1.max_depth()}, Bound: {4 // 2} = ⌊d/2⌋")
    print(f"  Outer ovals: {[o for o in sorted(forest1.ovals) if forest1.is_outer(o)]}")
    print(f"  Inner ovals: {[o for o in sorted(forest1.ovals) if forest1.is_inner(o)]}")

    # Example 2: Quartic with 4 unnested ovals
    print("\n--- Quartic (degree 4, 4 unnested ovals) ---")
    forest2 = NestingForest({1: None, 2: None, 3: None, 4: None})
    forest2.display()
    print(f"  Nesting depth: {forest2.max_depth()}")
    print(f"  All ovals are outer (depth 0)")

    # Example 3: Sextic with deep nesting
    print("\n--- Sextic (degree 6, max 11 ovals) ---")
    print("Configuration: Chain of depth 3 plus additional ovals")
    forest3 = NestingForest({
        1: 2, 2: 3, 3: None,  # Chain of depth 3
        4: 3, 5: None, 6: None, 7: 5,  # Additional structure
    })
    forest3.display()
    print(f"  Num ovals: {forest3.num_ovals}, Harnack bound: {harnack_bound(6)}")
    print(f"  Nesting depth: {forest3.max_depth()}, Bound: {6 // 2} = ⌊6/2⌋")
    print()


def demonstrate_hamiltonian_orthogonality() -> None:
    """Demonstrate that Hamiltonian vector fields are orthogonal to gradients."""
    print("=" * 60)
    print("HAMILTONIAN VECTOR FIELD ORTHOGONALITY")
    print("=" * 60)
    print()
    print("For H(x,y), the Hamiltonian VF is X_H = (∂H/∂y, -∂H/∂x)")
    print("The gradient is ∇H = (∂H/∂x, ∂H/∂y)")
    print("Orthogonality: ∇H · X_H = (∂H/∂x)(∂H/∂y) + (∂H/∂y)(-∂H/∂x) = 0")
    print()

    # Example: H(x,y) = x² + y² (harmonic oscillator)
    print("--- Example 1: H(x,y) = x² + y² ---")
    for point in [(1.0, 0.0), (0.0, 1.0), (1.0, 1.0), (3.0, -2.0)]:
        x, y = point
        grad = (2 * x, 2 * y)       # ∇H = (2x, 2y)
        vf = (2 * y, -2 * x)        # X_H = (2y, -2x)
        dot = grad[0] * vf[0] + grad[1] * vf[1]
        print(f"  Point ({x}, {y}): ∇H = {grad}, X_H = {vf}, ∇H·X_H = {dot}")

    # Example: H(x,y) = x³ - 3xy² (monkey saddle)
    print("\n--- Example 2: H(x,y) = x³ - 3xy² ---")
    for point in [(1.0, 1.0), (2.0, 0.5), (-1.0, 2.0)]:
        x, y = point
        dHdx = 3 * x**2 - 3 * y**2
        dHdy = -6 * x * y
        grad = (dHdx, dHdy)
        vf = (dHdy, -dHdx)
        dot = grad[0] * vf[0] + grad[1] * vf[1]
        print(f"  Point ({x}, {y}): ∇H·X_H = {dot:.10f}")
    print()

    # Example: Quartic H(x,y) = x⁴ + y⁴ - x² - y²
    print("--- Example 3: H(x,y) = x⁴ + y⁴ - x² - y² ---")
    print("  Level sets of this quartic form nested ovals (lemniscate family)")
    for point in [(0.5, 0.3), (1.0, 0.0), (0.7, 0.7)]:
        x, y = point
        dHdx = 4 * x**3 - 2 * x
        dHdy = 4 * y**3 - 2 * y
        grad = (dHdx, dHdy)
        vf = (dHdy, -dHdx)
        dot = grad[0] * vf[0] + grad[1] * vf[1]
        H_val = x**4 + y**4 - x**2 - y**2
        is_reg = "regular" if abs(dHdx) + abs(dHdy) > 1e-10 else "SINGULAR"
        print(f"  Point ({x}, {y}): H = {H_val:.4f}, |∇H| = {math.sqrt(dHdx**2+dHdy**2):.4f}, "
              f"∇H·X_H = {dot:.1e}, {is_reg}")
    print()


def demonstrate_component_bound() -> None:
    """Show how degree bounds periodic orbit counts."""
    print("=" * 60)
    print("COMPONENT COMPLEXITY: DEGREE → GENUS → ORBITS")
    print("=" * 60)
    print()
    print("For polynomial Hamiltonian H of degree d:")
    print("  • Level sets H(x,y)=c are algebraic curves of degree d")
    print("  • Genus g = (d-1)(d-2)/2")
    print("  • Max compact connected components = g + 1 (Harnack)")
    print("  • Each compact component → periodic orbit of Hamiltonian flow")
    print()
    print(f"{'Degree d':>10} {'Max periodic orbits':>22} {'≤ d²':>8}")
    print("-" * 42)
    for d in range(1, 9):
        h = harnack_bound(d)
        print(f"{d:>10} {h:>22} {d*d:>8}")
    print()
    print("This is the formal bridge:")
    print("  Hilbert 16 Part I (ovals) → Part II (limit cycles)")
    print("  via Hamiltonian systems and Harnack bound")
    print()


if __name__ == "__main__":
    print_genus_table()
    demonstrate_genus_recurrence()
    demonstrate_oval_arrangements()
    demonstrate_hamiltonian_orthogonality()
    demonstrate_component_bound()

    print("=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)
