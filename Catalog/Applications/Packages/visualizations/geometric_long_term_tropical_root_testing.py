#!/usr/bin/env python3
"""
Algorithms for Tropical Geometry

Implements the core algorithms from the research paper:
1. Tropical polynomial evaluation
2. Tropical root testing
3. Competition cell enumeration
4. Tropical hypersurface sampling (for visualization)
5. Maximizer computation
"""

import numpy as np
from typing import List, Tuple, Set, Optional
from dataclasses import dataclass


@dataclass
class TropicalMonomial:
    """A tropical monomial: coefficient c and exponent vector alpha.
    
    Evaluates to the affine form L(x) = c + sum_i(alpha_i * x_i).
    """
    coeff: float
    exp: np.ndarray
    
    def __init__(self, coeff: float, exp):
        self.coeff = coeff
        self.exp = np.asarray(exp, dtype=float)
    
    @property
    def dim(self) -> int:
        return len(self.exp)
    
    def eval(self, x: np.ndarray) -> float:
        """Evaluate the affine form at point x.
        
        Time complexity: O(n) where n = dimension.
        """
        return self.coeff + float(np.dot(self.exp, x))
    
    def eval_batch(self, X: np.ndarray) -> np.ndarray:
        """Evaluate at multiple points simultaneously.
        
        Args:
            X: array of shape (N, n) where N = number of points
        
        Returns:
            array of shape (N,) with evaluation values
            
        Time complexity: O(N * n)
        """
        return self.coeff + X @ self.exp


class TropicalPolynomial:
    """A tropical polynomial = finite max of affine forms.
    
    T(x) = max_{m in monomials} L_m(x)
    
    where L_m(x) = c_m + sum_i(alpha_m_i * x_i).
    """
    
    def __init__(self, monomials: List[TropicalMonomial]):
        """Initialize with a nonempty list of monomials.
        
        Args:
            monomials: list of TropicalMonomial, must be nonempty
        """
        if not monomials:
            raise ValueError("Tropical polynomial must have at least one monomial")
        self.monomials = list(monomials)
        self._n = monomials[0].dim
        self._k = len(monomials)
        # Precompute coefficient and exponent matrices for batch ops
        self._coeffs = np.array([m.coeff for m in monomials])
        self._exps = np.stack([m.exp for m in monomials])  # shape (k, n)
    
    @property
    def dim(self) -> int:
        """Ambient dimension n."""
        return self._n
    
    @property
    def num_monomials(self) -> int:
        """Number of monomials k."""
        return self._k
    
    def eval(self, x: np.ndarray) -> float:
        """Evaluate T(x) = max_m L_m(x).
        
        Time complexity: O(k * n)
        Space complexity: O(k)
        """
        vals = self._coeffs + self._exps @ x
        return float(np.max(vals))
    
    def eval_all(self, x: np.ndarray) -> np.ndarray:
        """Return all monomial values at x.
        
        Returns array of shape (k,) with L_m(x) for each m.
        """
        return self._coeffs + self._exps @ x
    
    def eval_batch(self, X: np.ndarray) -> np.ndarray:
        """Evaluate at multiple points.
        
        Args:
            X: array of shape (N, n)
        Returns:
            array of shape (N,) with T(x) for each x
        """
        # vals shape: (N, k)
        vals = X @ self._exps.T + self._coeffs[np.newaxis, :]
        return np.max(vals, axis=1)
    
    def maximizers(self, x: np.ndarray, tol: float = 1e-12) -> List[int]:
        """Return indices of monomials achieving the maximum at x.
        
        Time complexity: O(k * n)
        """
        vals = self.eval_all(x)
        best = np.max(vals)
        return [int(i) for i in np.where(np.abs(vals - best) < tol)[0]]
    
    def maximizer_count(self, x: np.ndarray, tol: float = 1e-12) -> int:
        """Count how many monomials achieve the maximum at x."""
        vals = self.eval_all(x)
        best = np.max(vals)
        return int(np.sum(np.abs(vals - best) < tol))
    
    def is_tropical_root(self, x: np.ndarray, tol: float = 1e-12) -> bool:
        """Test if x is a tropical root (max achieved by >= 2 monomials).
        
        Time complexity: O(k * n)
        Space complexity: O(k)
        """
        return self.maximizer_count(x, tol) >= 2
    
    def is_tropical_root_batch(self, X: np.ndarray, tol: float = 1e-12) -> np.ndarray:
        """Test tropical root condition for multiple points.
        
        Args:
            X: array of shape (N, n)
        Returns:
            boolean array of shape (N,)
        """
        vals = X @ self._exps.T + self._coeffs[np.newaxis, :]  # (N, k)
        best = np.max(vals, axis=1, keepdims=True)  # (N, 1)
        counts = np.sum(np.abs(vals - best) < tol, axis=1)  # (N,)
        return counts >= 2
    
    def competition_cell_membership(self, x: np.ndarray, i: int, j: int,
                                     tol: float = 1e-12) -> bool:
        """Test if x belongs to competition cell C(m_i, m_j).
        
        C(m_i, m_j) = {x : L_i(x) = L_j(x) and forall m, L_m(x) <= L_i(x)}
        
        Time complexity: O(k * n)
        """
        if i == j:
            return False
        vals = self.eval_all(x)
        # Check tie between i and j
        if abs(vals[i] - vals[j]) > tol:
            return False
        # Check domination
        return bool(np.all(vals <= vals[i] + tol))
    
    def active_competition_cell(self, x: np.ndarray,
                                 tol: float = 1e-12) -> Optional[Tuple[int, int]]:
        """Find which competition cell x belongs to (if any).
        
        Returns (i, j) with i < j, or None if x is not a root.
        """
        maxers = self.maximizers(x, tol)
        if len(maxers) < 2:
            return None
        return (maxers[0], maxers[1])
    
    def enumerate_nonempty_cells(self, sample_count: int = 10000,
                                  x_range: Tuple[float, float] = (-5, 5),
                                  tol: float = 0.1) -> Set[Tuple[int, int]]:
        """Heuristically find nonempty competition cells by random sampling.
        
        For exact enumeration, use LP feasibility (see research paper Algorithm 3).
        
        Args:
            sample_count: number of random test points
            x_range: range for uniform sampling
            tol: tolerance for root detection
        
        Returns:
            set of (i, j) pairs with i < j for observed nonempty cells
        """
        cells = set()
        X = np.random.uniform(x_range[0], x_range[1], (sample_count, self._n))
        
        for idx in range(sample_count):
            x = X[idx]
            vals = self.eval_all(x)
            best = np.max(vals)
            maxers = [int(i) for i in np.where(np.abs(vals - best) < tol)[0]]
            if len(maxers) >= 2:
                for a in range(len(maxers)):
                    for b in range(a+1, len(maxers)):
                        cells.add((maxers[a], maxers[b]))
        
        return cells


def compute_tropical_hypersurface_2d(
    poly: TropicalPolynomial,
    x_range: Tuple[float, float] = (-3, 3),
    y_range: Tuple[float, float] = (-3, 3),
    resolution: int = 500,
    tol: float = None
) -> np.ndarray:
    """Compute the tropical hypersurface of a 2D polynomial by grid sampling.
    
    Returns array of shape (N, 2) of approximate hypersurface points.
    
    The tolerance is set adaptively based on grid spacing to capture
    the hypersurface as a thin band.
    """
    assert poly.dim == 2, "This function is for 2D polynomials"
    
    if tol is None:
        dx = (x_range[1] - x_range[0]) / resolution
        tol = 1.5 * max(dx, (y_range[1] - y_range[0]) / resolution) * max(
            np.max(np.abs(poly._exps)), 1.0)
    
    xs = np.linspace(*x_range, resolution)
    ys = np.linspace(*y_range, resolution)
    X, Y = np.meshgrid(xs, ys)
    points = np.column_stack([X.ravel(), Y.ravel()])
    
    is_root = poly.is_tropical_root_batch(points, tol=tol)
    return points[is_root]


def tropical_vertex_enumeration_2d(
    poly: TropicalPolynomial,
    x_range: Tuple[float, float] = (-10, 10)
) -> List[np.ndarray]:
    """Find vertices of a 2D tropical hypersurface exactly.
    
    Vertices are points where >= 3 monomials achieve the maximum.
    Found by intersecting pairs of affine equality constraints
    and checking domination.
    
    Time complexity: O(k^3 * n) where k = num monomials, n = dimension.
    """
    assert poly.dim == 2, "This function is for 2D polynomials"
    
    vertices = []
    k = poly.num_monomials
    
    for i in range(k):
        for j in range(i+1, k):
            # Solve L_i(x) = L_j(x):
            # c_i + a_i^T x = c_j + a_j^T x
            # (a_i - a_j)^T x = c_j - c_i
            da = poly._exps[i] - poly._exps[j]
            dc = poly._coeffs[j] - poly._coeffs[i]
            
            if np.allclose(da, 0):
                continue  # Parallel: either identical or never meet
            
            # This gives a line, not a point. For a vertex we need 3 monomials.
            for m in range(k):
                if m == i or m == j:
                    continue
                # Solve system: L_i(x) = L_j(x) and L_i(x) = L_m(x)
                A = np.array([
                    poly._exps[i] - poly._exps[j],
                    poly._exps[i] - poly._exps[m]
                ])
                b = np.array([
                    poly._coeffs[j] - poly._coeffs[i],
                    poly._coeffs[m] - poly._coeffs[i]
                ])
                
                if abs(np.linalg.det(A)) < 1e-14:
                    continue
                
                x = np.linalg.solve(A, b)
                
                # Check if in range
                if not (x_range[0] <= x[0] <= x_range[1] and
                        x_range[0] <= x[1] <= x_range[1]):
                    continue
                
                # Check domination
                vals = poly.eval_all(x)
                best = vals[i]  # = vals[j] = vals[m] by construction
                if np.all(vals <= best + 1e-10):
                    # This is a vertex
                    already = any(np.allclose(x, v, atol=1e-8) for v in vertices)
                    if not already:
                        vertices.append(x)
    
    return vertices


# Example usage
if __name__ == "__main__":
    print("=== Tropical Geometry Algorithms ===\n")
    
    # Standard tropical line
    line = TropicalPolynomial([
        TropicalMonomial(0, [0, 0]),
        TropicalMonomial(0, [1, 0]),
        TropicalMonomial(0, [0, 1]),
    ])
    
    print("Standard tropical line: max(0, x, y)")
    print(f"  Eval at (1,2): {line.eval(np.array([1., 2.]))}")
    print(f"  Maximizers at (1,2): {line.maximizers(np.array([1., 2.]))}")
    print(f"  Is root at (0,0): {line.is_tropical_root(np.array([0., 0.]))}")
    print(f"  Is root at (1,2): {line.is_tropical_root(np.array([1., 2.]))}")
    
    # Find vertices
    vertices = tropical_vertex_enumeration_2d(line)
    print(f"  Vertices: {[v.tolist() for v in vertices]}")
    
    # Enumerate cells
    cells = line.enumerate_nonempty_cells()
    print(f"  Nonempty competition cells: {cells}")
    
    print()
    
    # Tropical conic
    conic = TropicalPolynomial([
        TropicalMonomial(0, [0, 0]),
        TropicalMonomial(0, [1, 0]),
        TropicalMonomial(0, [0, 1]),
        TropicalMonomial(0, [2, 0]),
        TropicalMonomial(0, [0, 2]),
        TropicalMonomial(0, [1, 1]),
    ])
    
    print("Tropical conic: max(0, x, y, 2x, 2y, x+y)")
    vertices = tropical_vertex_enumeration_2d(conic)
    print(f"  Vertices: {[np.round(v, 4).tolist() for v in vertices]}")
    cells = conic.enumerate_nonempty_cells()
    print(f"  Nonempty competition cells: {cells}")
    
    # Batch evaluation performance
    print("\n--- Performance Test ---")
    import time
    
    for k, n in [(5, 2), (10, 5), (50, 10), (100, 20)]:
        monos = [TropicalMonomial(np.random.randn(),
                                   np.random.randint(0, 3, n))
                 for _ in range(k)]
        poly = TropicalPolynomial(monos)
        X = np.random.randn(10000, n)
        
        t0 = time.time()
        poly.is_tropical_root_batch(X)
        dt = time.time() - t0
        
        print(f"  k={k:3d}, n={n:2d}: 10000 root tests in {dt*1000:.1f} ms "
              f"({dt/10000*1e6:.1f} μs/point)")
