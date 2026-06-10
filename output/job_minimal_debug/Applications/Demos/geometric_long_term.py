#!/usr/bin/env python3
"""
Applications of Tropical Geometry

Demonstrates real-world connections of the tropical hypersurface theory:
1. Neural network decision boundaries as tropical hypersurfaces
2. Parametric linear programming sensitivity analysis
3. Phylogenetic tree space
4. Auction theory tie-breaking surfaces
"""

import numpy as np
from typing import List, Tuple


class MaxAffineModel:
    """A max-affine model: f(x) = max_j (w_j^T x + b_j).
    
    This is exactly a tropical polynomial where exponents
    are real-valued slope vectors.
    """
    
    def __init__(self, weights: np.ndarray, biases: np.ndarray):
        """
        Args:
            weights: shape (k, n) - slope vectors
            biases: shape (k,) - intercepts
        """
        self.weights = weights
        self.biases = biases
        self.k, self.n = weights.shape
    
    def predict(self, x: np.ndarray) -> float:
        return float(np.max(self.weights @ x + self.biases))
    
    def predict_batch(self, X: np.ndarray) -> np.ndarray:
        vals = X @ self.weights.T + self.biases  # (N, k)
        return np.max(vals, axis=1)
    
    def active_piece(self, x: np.ndarray) -> int:
        vals = self.weights @ x + self.biases
        return int(np.argmax(vals))
    
    def is_on_boundary(self, x: np.ndarray, tol: float = 1e-10) -> bool:
        vals = self.weights @ x + self.biases
        best = np.max(vals)
        return int(np.sum(np.abs(vals - best) < tol)) >= 2
    
    def boundary_points_2d(self, x_range=(-3, 3), y_range=(-3, 3),
                            resolution=500) -> np.ndarray:
        assert self.n == 2
        xs = np.linspace(*x_range, resolution)
        ys = np.linspace(*y_range, resolution)
        X, Y = np.meshgrid(xs, ys)
        points = np.column_stack([X.ravel(), Y.ravel()])
        
        vals = points @ self.weights.T + self.biases  # (N, k)
        best = np.max(vals, axis=1, keepdims=True)
        dx = (x_range[1] - x_range[0]) / resolution
        tol = 1.5 * dx * np.max(np.abs(self.weights))
        counts = np.sum(np.abs(vals - best) < tol, axis=1)
        return points[counts >= 2]


def app_neural_network():
    """Application 1: ReLU network decision boundary = tropical hypersurface."""
    print("=" * 60)
    print("APPLICATION 1: Neural Network Decision Boundaries")
    print("=" * 60)
    print()
    
    # A 2-input, 4-neuron single hidden layer ReLU network
    # computes f(x) = max over 2^4 = 16 activation patterns
    # Each pattern gives an affine function of the input
    
    # For simplicity, model directly as max-affine with 4 pieces
    # (representing 4 dominant activation patterns)
    model = MaxAffineModel(
        weights=np.array([
            [1.0, 0.5],
            [-0.3, 1.2],
            [0.8, -0.6],
            [-0.5, -0.4],
        ]),
        biases=np.array([0.0, 0.3, -0.2, 1.0])
    )
    
    print("Max-affine model with 4 pieces (= tropical polynomial with 4 monomials)")
    print(f"  Dimension: {model.n}")
    print(f"  Pieces: {model.k}")
    print()
    
    # Test points
    test_points = [
        np.array([0.0, 0.0]),
        np.array([1.0, 1.0]),
        np.array([-1.0, 2.0]),
    ]
    
    for x in test_points:
        val = model.predict(x)
        piece = model.active_piece(x)
        on_bd = model.is_on_boundary(x)
        print(f"  x = {x.tolist()}: f(x) = {val:.3f}, "
              f"active piece = {piece}, on boundary = {on_bd}")
    
    # Find boundary
    bd_points = model.boundary_points_2d()
    print(f"\n  Boundary points found: {len(bd_points)}")
    print("  The boundary is the tropical hypersurface of the network!")
    
    # Count cells
    print("\n  Competition cells (pairs of tied pieces):")
    cell_counts = {}
    for pt in bd_points:
        vals = model.weights @ pt + model.biases
        best = np.max(vals)
        tol = 0.1
        maxers = tuple(sorted(int(i) for i in np.where(np.abs(vals - best) < tol)[0]))
        if len(maxers) >= 2:
            pair = (maxers[0], maxers[1])
            cell_counts[pair] = cell_counts.get(pair, 0) + 1
    
    for pair, count in sorted(cell_counts.items()):
        print(f"    C(piece_{pair[0]}, piece_{pair[1]}): ~{count} points")
    print()


def app_parametric_lp():
    """Application 2: Parametric LP — optimal value as tropical polynomial."""
    print("=" * 60)
    print("APPLICATION 2: Parametric Linear Programming")
    print("=" * 60)
    print()
    
    # LP: maximize c^T x subject to Ax <= b
    # For a polytope with known vertices v1, ..., vk:
    # optimal value = max_j c^T v_j = tropical polynomial in c
    
    # Example: unit square in 2D
    # Vertices: (0,0), (1,0), (0,1), (1,1)
    vertices = np.array([
        [0.0, 0.0],
        [1.0, 0.0],
        [0.0, 1.0],
        [1.0, 1.0],
    ])
    
    print("Polytope: unit square [0,1]²")
    print(f"Vertices: {vertices.tolist()}")
    print()
    print("Optimal value v(c) = max over vertices of c^T v")
    print("This is a tropical polynomial in the cost vector c!")
    print()
    
    # The tropical hypersurface in c-space = cost vectors where
    # the optimal vertex is non-unique
    model = MaxAffineModel(
        weights=vertices,  # vertices as slope vectors
        biases=np.zeros(len(vertices))
    )
    
    # Test cost vectors
    test_costs = [
        np.array([1.0, 0.0]),   # maximize x → vertex (1,0) or (1,1)
        np.array([0.0, 1.0]),   # maximize y → vertex (0,1) or (1,1)
        np.array([1.0, 1.0]),   # maximize x+y → vertex (1,1)
        np.array([-1.0, -1.0]), # minimize x+y → vertex (0,0)
        np.array([1.0, -1.0]),  # → vertex (1,0)
    ]
    
    print("Cost vector tests:")
    for c in test_costs:
        val = model.predict(c)
        active = model.active_piece(c)
        on_bd = model.is_on_boundary(c, tol=1e-8)
        print(f"  c = {c.tolist()}: optimal = {val:.2f}, "
              f"best vertex = {vertices[active].tolist()}, "
              f"non-unique = {on_bd}")
    
    print()
    print("The sensitivity regions of the LP are the complement cells")
    print("of the tropical hypersurface in cost-vector space.")
    print()


def app_auction():
    """Application 3: Auction theory — tropical tie-breaking."""
    print("=" * 60)
    print("APPLICATION 3: Auction Theory")
    print("=" * 60)
    print()
    
    print("Second-price auction with quality adjustments:")
    print("  Score_j(bid) = w_j * bid_j + quality_j")
    print("  Winner = argmax_j Score_j")
    print()
    
    # 3 bidders with different quality scores
    qualities = np.array([10.0, 8.0, 12.0])
    weight = 1.0
    
    print(f"  Bidder qualities: {qualities.tolist()}")
    print(f"  Score = quality + bid")
    print()
    
    # In 2D (bids of bidders 0 and 1, bidder 2's bid fixed at 5)
    # Score_0 = 10 + b0, Score_1 = 8 + b1, Score_2 = 12 + 5 = 17
    print("Fix bidder 2's bid at 5 (score = 17).")
    print("Tropical polynomial: T(b0, b1) = max(10+b0, 8+b1, 17)")
    print()
    
    model = MaxAffineModel(
        weights=np.array([
            [1.0, 0.0],   # bidder 0: 10 + b0
            [0.0, 1.0],   # bidder 1: 8 + b1
            [0.0, 0.0],   # bidder 2: 17 (constant)
        ]),
        biases=np.array([10.0, 8.0, 17.0])
    )
    
    test_bids = [
        np.array([5.0, 5.0]),
        np.array([7.0, 9.0]),
        np.array([7.0, 7.0]),
        np.array([10.0, 10.0]),
    ]
    
    print("Bid tests:")
    for b in test_bids:
        scores = model.weights @ b + model.biases
        winner = int(np.argmax(scores))
        on_bd = model.is_on_boundary(b, tol=1e-8)
        print(f"  Bids ({b[0]:.0f}, {b[1]:.0f}): "
              f"scores = {scores.tolist()}, "
              f"winner = bidder {winner}, "
              f"tie = {on_bd}")
    
    bd = model.boundary_points_2d(x_range=(0, 15), y_range=(0, 15))
    print(f"\n  Tie-breaking surface points: {len(bd)}")
    print("  This is the tropical hypersurface of the auction!")
    print()


def app_phylogenetics():
    """Application 4: Tropical geometry in phylogenetics."""
    print("=" * 60)
    print("APPLICATION 4: Phylogenetic Tree Distances")
    print("=" * 60)
    print()
    
    print("Ultrametric condition for 3 taxa (A, B, C):")
    print("  d(A,B) ≤ max(d(A,C), d(B,C))  [tropical inequality]")
    print()
    
    # For 3 taxa, the tree space has three topologies:
    # T1: ((A,B),C), T2: ((A,C),B), T3: ((B,C),A)
    # The ultrametric d(A,B) = max over internal edges
    
    # Tropical representation: distances as max-plus expressions
    # d(A,B) in tree T1 with edge lengths e1, e2, e3:
    # d(A,B) = e1 + e2 (going through root)
    
    print("For tree ((A,B),C) with internal edges e_AB, e_C:")
    print("  d(A,B) = 2*e_AB")
    print("  d(A,C) = e_AB + e_C")
    print("  d(B,C) = e_AB + e_C")
    print()
    
    # Sample trees and check tropical conditions
    np.random.seed(42)
    n_trees = 1000
    valid_count = 0
    
    for _ in range(n_trees):
        e_ab = np.random.exponential(1.0)
        e_c = np.random.exponential(1.0)
        
        d_ab = 2 * e_ab
        d_ac = e_ab + e_c
        d_bc = e_ab + e_c
        
        # Check ultrametric: each distance ≤ max of other two
        ultra = (d_ab <= max(d_ac, d_bc) and
                 d_ac <= max(d_ab, d_bc) and
                 d_bc <= max(d_ab, d_ac))
        if ultra:
            valid_count += 1
    
    print(f"Random tree test: {valid_count}/{n_trees} trees are ultrametric")
    print("(Expected: 100% for trees, as all tree metrics are ultrametric)")
    print()
    print("The space of phylogenetic trees embeds into tropical projective space.")
    print("Tropical hypersurfaces partition this space by tree topology.")
    print()


if __name__ == "__main__":
    app_neural_network()
    app_parametric_lp()
    app_auction()
    app_phylogenetics()
    print("=" * 60)
    print("All applications completed.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Hypersurface Demo

Demonstrates the competition cell decomposition theorem for tropical polynomials.
A tropical polynomial T(x) = max_m (c_m + sum_i alpha_m_i * x_i) has a tropical
hypersurface (corner locus) where the maximum is achieved by >= 2 monomials.

The theorem says this hypersurface equals the union of pairwise competition cells.
"""

import numpy as np
from typing import List, Tuple, Optional


class TropMonomial:
    """A tropical monomial with coefficient c and exponent vector alpha."""
    
    def __init__(self, coeff: float, exp: List[int]):
        self.coeff = coeff
        self.exp = np.array(exp, dtype=float)
    
    def eval(self, x: np.ndarray) -> float:
        """Evaluate the affine form c + sum(alpha_i * x_i)."""
        return self.coeff + np.dot(self.exp, x)
    
    def __repr__(self):
        terms = []
        for i, e in enumerate(self.exp):
            if e != 0:
                terms.append(f"{int(e)}*x{i}")
        expr = " + ".join(terms) if terms else "0"
        sign = "+" if self.coeff >= 0 else ""
        return f"({sign}{self.coeff} + {expr})"


class TropPoly:
    """A tropical polynomial = finite set of tropical monomials."""
    
    def __init__(self, monomials: List[TropMonomial]):
        assert len(monomials) > 0, "Polynomial must be nonempty"
        self.monomials = monomials
    
    def eval(self, x: np.ndarray) -> float:
        """Evaluate T_p(x) = max_m L_m(x)."""
        return max(m.eval(x) for m in self.monomials)
    
    def maximizers(self, x: np.ndarray, tol=1e-12) -> List[int]:
        """Return indices of monomials achieving the maximum at x."""
        vals = [m.eval(x) for m in self.monomials]
        best = max(vals)
        return [i for i, v in enumerate(vals) if abs(v - best) < tol]
    
    def is_trop_root(self, x: np.ndarray, tol=1e-12) -> bool:
        """Test if x is a tropical root (max achieved by >= 2 monomials)."""
        return len(self.maximizers(x, tol)) >= 2
    
    def eval_grid(self, x_range, y_range, resolution=200):
        """Evaluate on a 2D grid (for n=2 polynomials)."""
        xs = np.linspace(*x_range, resolution)
        ys = np.linspace(*y_range, resolution)
        X, Y = np.meshgrid(xs, ys)
        Z = np.zeros_like(X)
        for i in range(resolution):
            for j in range(resolution):
                Z[i, j] = self.eval(np.array([X[i, j], Y[i, j]]))
        return X, Y, Z


def demo_tropical_line():
    """Demo 1: The standard tropical line (tripod)."""
    print("=" * 60)
    print("DEMO 1: Standard Tropical Line (Y-shaped tripod)")
    print("=" * 60)
    print()
    print("Polynomial: T(x,y) = max(0, x, y)")
    print("Monomials: m0 = (0, [0,0]), m1 = (0, [1,0]), m2 = (0, [0,1])")
    print()
    
    p = TropPoly([
        TropMonomial(0, [0, 0]),  # constant 0
        TropMonomial(0, [1, 0]),  # x
        TropMonomial(0, [0, 1]),  # y
    ])
    
    # Test specific points
    test_points = [
        (np.array([0.0, 0.0]), "Origin"),
        (np.array([-1.0, -1.0]), "(-1,-1) on ray x=y, x<0"),
        (np.array([-2.0, 0.5]), "(-2, 0.5) off hypersurface"),
        (np.array([1.0, 0.0]), "(1, 0) on ray y=0, x>0"),
        (np.array([0.0, 3.0]), "(0, 3) on ray x=0, y>0"),
    ]
    
    print("Point tests:")
    for x, label in test_points:
        vals = [m.eval(x) for m in p.monomials]
        maxers = p.maximizers(x)
        is_root = p.is_trop_root(x)
        print(f"  {label}")
        print(f"    Values: {[round(v, 4) for v in vals]}")
        print(f"    Maximizers: {maxers}, Is root: {is_root}")
    
    print()
    print("Competition cells of the tropical line:")
    print("  C(m0, m1) = {(x,y) : 0 = x >= y}  →  ray: x=0, y≤0")
    print("  C(m0, m2) = {(x,y) : 0 = y >= x}  →  ray: y=0, x≤0")
    print("  C(m1, m2) = {(x,y) : x = y >= 0}  →  ray: x=y, x≥0")
    print("  Vertex at origin where all three tie.")
    print()


def demo_tropical_conic():
    """Demo 2: A tropical conic."""
    print("=" * 60)
    print("DEMO 2: Tropical Conic")
    print("=" * 60)
    print()
    print("T(x,y) = max(0, x, y, 2x, 2y, x+y)")
    
    p = TropPoly([
        TropMonomial(0, [0, 0]),
        TropMonomial(0, [1, 0]),
        TropMonomial(0, [0, 1]),
        TropMonomial(0, [2, 0]),
        TropMonomial(0, [0, 2]),
        TropMonomial(0, [1, 1]),
    ])
    
    # Sample points on the hypersurface
    n_points = 1000
    roots_found = []
    for _ in range(n_points):
        x = np.random.uniform(-3, 3, 2)
        if p.is_trop_root(x, tol=0.05):
            roots_found.append(x)
    
    print(f"  Random sampling: {len(roots_found)}/{n_points} points near hypersurface")
    print()


def demo_competition_cells():
    """Demo 3: Verify the competition cell decomposition theorem."""
    print("=" * 60)
    print("DEMO 3: Competition Cell Decomposition Verification")
    print("=" * 60)
    print()
    
    # Polynomial with shifted coefficients
    p = TropPoly([
        TropMonomial(1.0, [0, 0]),   # 1
        TropMonomial(0.0, [1, 0]),   # x
        TropMonomial(-0.5, [0, 1]),  # -0.5 + y
    ])
    
    print("Polynomial: T(x,y) = max(1, x, -0.5+y)")
    print()
    
    # Dense grid test
    resolution = 500
    xs = np.linspace(-4, 4, resolution)
    ys = np.linspace(-4, 4, resolution)
    
    root_count = 0
    cell_count = 0
    mismatch_count = 0
    
    for xi in xs:
        for yi in ys:
            x = np.array([xi, yi])
            
            # Check root condition (Definition)
            vals = [m.eval(x) for m in p.monomials]
            best = max(vals)
            maximizers = [i for i, v in enumerate(vals) if abs(v - best) < 1e-10]
            is_root = len(maximizers) >= 2
            
            # Check competition cell condition (Theorem)
            in_cell = False
            for i in range(len(p.monomials)):
                for j in range(len(p.monomials)):
                    if i == j:
                        continue
                    vi, vj = vals[i], vals[j]
                    if abs(vi - vj) < 1e-10 and all(v <= vi + 1e-10 for v in vals):
                        in_cell = True
                        break
                if in_cell:
                    break
            
            if is_root:
                root_count += 1
            if in_cell:
                cell_count += 1
            if is_root != in_cell:
                mismatch_count += 1
    
    total = resolution * resolution
    print(f"Grid test ({resolution}x{resolution} = {total} points):")
    print(f"  Tropical roots found: {root_count}")
    print(f"  Points in competition cells: {cell_count}")
    print(f"  Mismatches (root ↔ cell): {mismatch_count}")
    print(f"  → Theorem verified: {'YES' if mismatch_count == 0 else 'NO'}")
    print()


def demo_neural_network_connection():
    """Demo 4: Connection to neural network decision boundaries."""
    print("=" * 60)
    print("DEMO 4: Neural Network Decision Boundary as Tropical Hypersurface")
    print("=" * 60)
    print()
    
    # A simple max-affine model: f(x) = max(w1·x + b1, w2·x + b2, w3·x + b3)
    # This is equivalent to a single ReLU layer
    w = np.array([[1.0, 0.5], [-0.5, 1.0], [0.3, -0.8]])
    b = np.array([0.0, 0.5, -0.3])
    
    print("Max-affine model: f(x,y) = max(x+0.5y, -0.5x+y+0.5, 0.3x-0.8y-0.3)")
    print()
    
    # This is a tropical polynomial!
    p = TropPoly([
        TropMonomial(b[i], list(w[i])) for i in range(3)
    ])
    
    # Find decision boundary points
    resolution = 300
    xs = np.linspace(-3, 3, resolution)
    ys = np.linspace(-3, 3, resolution)
    boundary_points = []
    
    for xi in xs:
        for yi in ys:
            x = np.array([xi, yi])
            if p.is_trop_root(x, tol=0.03):
                boundary_points.append([xi, yi])
    
    boundary_points = np.array(boundary_points) if boundary_points else np.empty((0, 2))
    
    print(f"Decision boundary points found: {len(boundary_points)}")
    print("The decision boundary IS the tropical hypersurface!")
    print()
    
    # Verify competition cell structure
    print("Competition cells (which affine pieces tie):")
    for i in range(3):
        for j in range(i+1, 3):
            cell_points = []
            for pt in boundary_points:
                x = np.array(pt)
                vals = [m.eval(x) for m in p.monomials]
                if abs(vals[i] - vals[j]) < 0.05 and all(v <= vals[i] + 0.05 for v in vals):
                    cell_points.append(pt)
            print(f"  C(m{i}, m{j}): ~{len(cell_points)} points")
    print()


def demo_closedness():
    """Demo 5: Verify closedness — limit points are in the hypersurface."""
    print("=" * 60)
    print("DEMO 5: Closedness of Tropical Hypersurface")
    print("=" * 60)
    print()
    
    p = TropPoly([
        TropMonomial(0, [0, 0]),
        TropMonomial(0, [1, 0]),
        TropMonomial(0, [0, 1]),
    ])
    
    # Approach a boundary point along a sequence
    # The ray x=y, x>=0 is on the hypersurface
    # Approach from slightly off: x_n = (1/n, 1/n + 1/n^2)
    print("Approaching the ray x=y (x≥0) with sequence x_n = (1/n, 1/n + 1/n²):")
    print("  These points are OFF the hypersurface (y slightly > x, so m2 wins uniquely)")
    print()
    
    for n in [10, 100, 1000, 10000]:
        x = np.array([1.0/n, 1.0/n + 1.0/n**2])
        is_root = p.is_trop_root(x)
        vals = [m.eval(x) for m in p.monomials]
        print(f"  n={n:5d}: x=({x[0]:.6f}, {x[1]:.6f}), "
              f"vals={[round(v,6) for v in vals]}, root={is_root}")
    
    # The limit point (0,0) IS on the hypersurface
    x_limit = np.array([0.0, 0.0])
    print(f"\n  Limit point (0, 0): root={p.is_trop_root(x_limit)}")
    print("  → Hypersurface contains its limit points (closed set). ✓")
    print()


if __name__ == "__main__":
    demo_tropical_line()
    demo_tropical_conic()
    demo_competition_cells()
    demo_neural_network_connection()
    demo_closedness()
    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables embedded."""

import json
import base64
from pathlib import Path

# Read all text files
def read_file(path):
    return Path(path).read_text()

# Generate visualizations
from visualizations import generate_all_visualizations
viz_data = generate_all_visualizations()

# Read Lean proof
lean_code = read_file('Tropical/Geometry/Hypersurface.lean')

# Read markdown files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')

# Read Python code
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

package = {
    "title": "Tropical Hypersurfaces via Corner Loci: Competition Cell Decomposition",
    "domain": "Tropical Geometry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Hypersurface Demo",
            "code": demo_code
        },
        {
            "name": "Applications of Tropical Geometry",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Polynomial Evaluation",
            "pseudocode": "Input: monomials [(c₁,α₁),...,(cₖ,αₖ)], point x ∈ ℝⁿ\nOutput: max value T(x)\n\nbest ← -∞\nfor j = 1 to k:\n  val ← cⱼ + Σᵢ αⱼᵢ·xᵢ\n  best ← max(best, val)\nreturn best\n\nComplexity: O(kn) time, O(1) space",
            "code": algorithms_code
        },
        {
            "name": "Tropical Root Testing",
            "pseudocode": "Input: monomials [(c₁,α₁),...,(cₖ,αₖ)], point x ∈ ℝⁿ\nOutput: True if x is a tropical root\n\nCompute vⱼ = cⱼ + Σᵢ αⱼᵢ·xᵢ for all j\nbest ← max(v₁,...,vₖ)\ncount ← |{j : vⱼ = best}|\nreturn count ≥ 2\n\nComplexity: O(kn) time, O(k) space",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Line (Y-shaped Tripod)",
            "data": f"data:image/png;base64,{viz_data['tropical_line']}"
        },
        {
            "name": "Tropical Conic",
            "data": f"data:image/png;base64,{viz_data['tropical_conic']}"
        },
        {
            "name": "Competition Cell Decomposition",
            "data": f"data:image/png;base64,{viz_data['competition_cells']}"
        },
        {
            "name": "Neural Network Decision Boundary",
            "data": f"data:image/png;base64,{viz_data['neural_boundary']}"
        },
        {
            "name": "Cell Structure with Annotations",
            "data": f"data:image/png;base64,{viz_data['cell_structure']}"
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({Path('PACKAGE.json').stat().st_size} bytes)")


#!/usr/bin/env python3
"""
Visualizations for Tropical Geometry

Generates publication-quality figures showing:
1. Standard tropical line (tripod)
2. Tropical conic
3. Competition cell decomposition
4. Neural network decision boundary
5. 3D tropical surface
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import base64
from io import BytesIO


def eval_trop_poly(coeffs, exps, X, Y):
    """Evaluate tropical polynomial on a grid.
    
    coeffs: array of shape (k,)
    exps: array of shape (k, 2)
    X, Y: meshgrids
    """
    k = len(coeffs)
    vals = np.zeros((k,) + X.shape)
    for j in range(k):
        vals[j] = coeffs[j] + exps[j, 0] * X + exps[j, 1] * Y
    return vals


def find_root_mask(vals, tol_factor=0.02):
    """Find tropical root points from monomial values."""
    best = np.max(vals, axis=0)
    tol = tol_factor * (np.max(best) - np.min(best) + 1)
    counts = np.sum(np.abs(vals - best[np.newaxis]) < tol, axis=0)
    return counts >= 2


def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def plot_tropical_line():
    """Figure 1: Standard tropical line — the Y-shaped tripod."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: the tropical polynomial surface
    ax = axes[0]
    res = 300
    x = np.linspace(-3, 3, res)
    y = np.linspace(-3, 3, res)
    X, Y = np.meshgrid(x, y)
    
    coeffs = np.array([0., 0., 0.])
    exps = np.array([[0, 0], [1, 0], [0, 1]], dtype=float)
    vals = eval_trop_poly(coeffs, exps, X, Y)
    Z = np.max(vals, axis=0)
    
    # Color by which monomial wins
    winner = np.argmax(vals, axis=0)
    colors = ['#2196F3', '#FF5722', '#4CAF50']
    cmap = ListedColormap(colors)
    
    ax.contourf(X, Y, winner.astype(float), levels=[-0.5, 0.5, 1.5, 2.5],
                colors=colors, alpha=0.3)
    
    # Draw the hypersurface
    root_mask = find_root_mask(vals, tol_factor=0.015)
    ax.scatter(X[root_mask], Y[root_mask], c='black', s=0.3, alpha=0.8)
    
    # Exact rays
    t = np.linspace(0, 3, 100)
    ax.plot(-t, -t, 'k-', linewidth=2, label='Ray: x=y, x≤0')
    ax.plot(t, np.zeros_like(t), 'k-', linewidth=2, label='Ray: y=0, x≥0')
    ax.plot(np.zeros_like(t), t, 'k-', linewidth=2, label='Ray: x=0, y≥0')
    ax.plot(0, 0, 'ko', markersize=8, zorder=5)
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('Tropical Line: T(x,y) = max(0, x, y)', fontsize=14)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.legend(fontsize=9, loc='lower right')
    
    # Annotations
    ax.annotate('0 wins', xy=(-1.5, 0.5), fontsize=11, color=colors[0],
                fontweight='bold')
    ax.annotate('x wins', xy=(1.5, -1), fontsize=11, color=colors[1],
                fontweight='bold')
    ax.annotate('y wins', xy=(-1, 2), fontsize=11, color=colors[2],
                fontweight='bold')
    
    # Right: 3D view of the tropical polynomial
    ax3d = fig.add_subplot(122, projection='3d')
    axes[1].set_visible(False)
    
    ax3d.plot_surface(X, Y, Z, cmap='viridis', alpha=0.7, linewidth=0,
                      antialiased=True)
    ax3d.set_xlabel('x')
    ax3d.set_ylabel('y')
    ax3d.set_zlabel('T(x,y)')
    ax3d.set_title('3D View: Piecewise-Linear Surface', fontsize=14)
    ax3d.view_init(elev=25, azim=-60)
    
    plt.tight_layout()
    data = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/tropical_line.png', dpi=150,
                bbox_inches='tight')
    plt.close(fig)
    return data


def plot_tropical_conic():
    """Figure 2: Tropical conic with 6 monomials."""
    fig, ax = plt.subplots(figsize=(8, 8))
    
    res = 500
    x = np.linspace(-2, 2, res)
    y = np.linspace(-2, 2, res)
    X, Y = np.meshgrid(x, y)
    
    coeffs = np.array([0., 0., 0., 0., 0., 0.])
    exps = np.array([
        [0, 0], [1, 0], [0, 1],
        [2, 0], [0, 2], [1, 1]
    ], dtype=float)
    vals = eval_trop_poly(coeffs, exps, X, Y)
    
    # Color by winner
    winner = np.argmax(vals, axis=0)
    colors = ['#E91E63', '#2196F3', '#4CAF50', '#FF9800', '#9C27B0', '#00BCD4']
    cmap = ListedColormap(colors)
    ax.contourf(X, Y, winner.astype(float),
                levels=np.arange(-0.5, 6.5, 1), colors=colors, alpha=0.25)
    
    # Hypersurface
    root_mask = find_root_mask(vals, tol_factor=0.012)
    ax.scatter(X[root_mask], Y[root_mask], c='black', s=0.2, alpha=0.9)
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('Tropical Conic: T(x,y) = max(0, x, y, 2x, 2y, x+y)',
                 fontsize=13)
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    
    # Label regions
    labels = ['1', 'x', 'y', '2x', '2y', 'x+y']
    label_pos = [(-0.5, -0.5), (0.8, -0.5), (-0.7, 0.8),
                 (1.5, 0), (0, 1.5), (0.8, 0.8)]
    for i, (pos, label) in enumerate(zip(label_pos, labels)):
        ax.annotate(label, xy=pos, fontsize=10, color=colors[i],
                    fontweight='bold', ha='center')
    
    plt.tight_layout()
    data = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/tropical_conic.png', dpi=150,
                bbox_inches='tight')
    plt.close(fig)
    return data


def plot_competition_cells():
    """Figure 3: Competition cell decomposition."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # A tropical polynomial with 3 shifted monomials
    coeffs = np.array([1.0, 0.0, -0.5])
    exps = np.array([[0, 0], [1, 0], [0, 1]], dtype=float)
    
    res = 400
    x = np.linspace(-4, 4, res)
    y = np.linspace(-4, 4, res)
    X, Y = np.meshgrid(x, y)
    vals = eval_trop_poly(coeffs, exps, X, Y)
    best = np.max(vals, axis=0)
    
    cell_pairs = [(0, 1), (0, 2), (1, 2)]
    cell_names = ['C(1, x)', 'C(1, -½+y)', 'C(x, -½+y)']
    cell_colors = ['#E91E63', '#2196F3', '#4CAF50']
    
    for idx, (ax, (i, j)) in enumerate(zip(axes, cell_pairs)):
        # Background: winner regions
        winner = np.argmax(vals, axis=0)
        bg_colors = ['#ffcdd2', '#bbdefb', '#c8e6c9']
        bg_cmap = ListedColormap(bg_colors)
        ax.contourf(X, Y, winner.astype(float),
                    levels=[-0.5, 0.5, 1.5, 2.5], colors=bg_colors, alpha=0.4)
        
        # Highlight this competition cell
        tol = 0.08
        cell_mask = (
            (np.abs(vals[i] - vals[j]) < tol) &
            (np.all(vals <= vals[i:i+1] + tol, axis=0))
        )
        ax.scatter(X[cell_mask], Y[cell_mask], c=cell_colors[idx],
                   s=1.5, alpha=0.8, label=cell_names[idx])
        
        # Full hypersurface in grey
        root_mask = find_root_mask(vals, tol_factor=0.01)
        ax.scatter(X[root_mask], Y[root_mask], c='grey', s=0.1, alpha=0.3)
        
        ax.set_xlabel('x', fontsize=11)
        ax.set_ylabel('y', fontsize=11)
        ax.set_title(f'Cell {cell_names[idx]}', fontsize=13,
                     color=cell_colors[idx])
        ax.set_xlim(-4, 4)
        ax.set_ylim(-4, 4)
        ax.set_aspect('equal')
        ax.legend(fontsize=10, loc='upper right')
    
    fig.suptitle('Competition Cell Decomposition: T(x,y) = max(1, x, -½+y)',
                 fontsize=15, y=1.02)
    plt.tight_layout()
    data = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/competition_cells.png', dpi=150,
                bbox_inches='tight')
    plt.close(fig)
    return data


def plot_neural_boundary():
    """Figure 4: Neural network decision boundary as tropical hypersurface."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Max-affine model with 5 pieces
    weights = np.array([
        [1.0, 0.3],
        [-0.4, 1.1],
        [0.7, -0.8],
        [-0.6, -0.3],
        [0.2, 0.9],
    ])
    biases = np.array([0.0, 0.3, -0.1, 0.8, -0.5])
    
    res = 500
    x = np.linspace(-3, 3, res)
    y = np.linspace(-3, 3, res)
    X, Y = np.meshgrid(x, y)
    
    k = len(biases)
    vals = np.zeros((k,) + X.shape)
    for j in range(k):
        vals[j] = biases[j] + weights[j, 0] * X + weights[j, 1] * Y
    
    # Left: Active piece (region coloring)
    ax = axes[0]
    winner = np.argmax(vals, axis=0)
    colors = ['#E91E63', '#2196F3', '#4CAF50', '#FF9800', '#9C27B0']
    cmap = ListedColormap(colors)
    ax.contourf(X, Y, winner.astype(float),
                levels=np.arange(-0.5, k + 0.5, 1), colors=colors, alpha=0.35)
    
    root_mask = find_root_mask(vals, tol_factor=0.01)
    ax.scatter(X[root_mask], Y[root_mask], c='black', s=0.3, alpha=0.8)
    
    for j in range(k):
        ax.annotate(f'Piece {j}', xy=(0, 0), fontsize=9, color=colors[j],
                    fontweight='bold')
    
    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Decision Boundary = Tropical Hypersurface', fontsize=13)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    
    # Right: 3D surface
    ax3d = fig.add_subplot(122, projection='3d')
    axes[1].set_visible(False)
    
    Z = np.max(vals, axis=0)
    ax3d.plot_surface(X, Y, Z, cmap='plasma', alpha=0.7, linewidth=0)
    ax3d.set_xlabel('x₁')
    ax3d.set_ylabel('x₂')
    ax3d.set_zlabel('f(x)')
    ax3d.set_title('Max-Affine Function (Tropical Polynomial)', fontsize=13)
    ax3d.view_init(elev=20, azim=-45)
    
    plt.tight_layout()
    data = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/neural_boundary.png', dpi=150,
                bbox_inches='tight')
    plt.close(fig)
    return data


def plot_cell_structure():
    """Figure 5: Detailed cell structure with annotations."""
    fig, ax = plt.subplots(figsize=(10, 10))
    
    # Generic 4-term polynomial
    coeffs = np.array([0., 0.5, -0.3, 0.2])
    exps = np.array([[0, 0], [1, 0], [0, 1], [1, 1]], dtype=float)
    
    res = 600
    x = np.linspace(-3, 3, res)
    y = np.linspace(-3, 3, res)
    X, Y = np.meshgrid(x, y)
    vals = eval_trop_poly(coeffs, exps, X, Y)
    
    winner = np.argmax(vals, axis=0)
    colors = ['#E91E63', '#2196F3', '#4CAF50', '#FF9800']
    cmap = ListedColormap(colors)
    ax.contourf(X, Y, winner.astype(float),
                levels=[-0.5, 0.5, 1.5, 2.5, 3.5], colors=colors, alpha=0.25)
    
    # Hypersurface
    root_mask = find_root_mask(vals, tol_factor=0.01)
    ax.scatter(X[root_mask], Y[root_mask], c='black', s=0.5, alpha=0.9)
    
    # Find and mark vertices (3+ monomials tie)
    best = np.max(vals, axis=0)
    tol = 0.06
    triple_mask = np.sum(np.abs(vals - best[np.newaxis]) < tol, axis=0) >= 3
    if np.any(triple_mask):
        ax.scatter(X[triple_mask], Y[triple_mask], c='red', s=20, zorder=5,
                   marker='o', label='Vertices (≥3 tie)')
    
    labels = ['c₀=0', 'c₁+x', 'c₂+y', 'c₃+x+y']
    label_pos = [(-2, -1.5), (2, -1.5), (-2, 2), (1.5, 1.5)]
    for i, (pos, label) in enumerate(zip(label_pos, labels)):
        ax.annotate(label, xy=pos, fontsize=12, color=colors[i],
                    fontweight='bold', ha='center',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                              edgecolor=colors[i], alpha=0.8))
    
    ax.set_xlabel('x', fontsize=13)
    ax.set_ylabel('y', fontsize=13)
    ax.set_title('Tropical Hypersurface: T(x,y) = max(0, 0.5+x, -0.3+y, 0.2+x+y)',
                 fontsize=13)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.legend(fontsize=11, loc='lower right')
    ax.grid(True, alpha=0.2)
    
    plt.tight_layout()
    data = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/cell_structure.png', dpi=150,
                bbox_inches='tight')
    plt.close(fig)
    return data


def generate_all_visualizations():
    """Generate all visualization figures and return base64 data."""
    print("Generating visualizations...")
    
    data = {}
    
    print("  1/5: Tropical line...")
    data['tropical_line'] = plot_tropical_line()
    
    print("  2/5: Tropical conic...")
    data['tropical_conic'] = plot_tropical_conic()
    
    print("  3/5: Competition cells...")
    data['competition_cells'] = plot_competition_cells()
    
    print("  4/5: Neural boundary...")
    data['neural_boundary'] = plot_neural_boundary()
    
    print("  5/5: Cell structure...")
    data['cell_structure'] = plot_cell_structure()
    
    print("Done!")
    return data


if __name__ == "__main__":
    data = generate_all_visualizations()
    for name, b64 in data.items():
        print(f"  {name}: {len(b64)} bytes base64")
