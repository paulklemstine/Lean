"""
Algorithms for K-Fold Directional Log-Concavity Depth

Implements:
1. LorentzianDepthComputer - Compute k-fold DLC depth of a valuated matroid
2. RatioTransformChain - Iteratively apply ratio transforms
3. TropicalBridge - Convert log-concavity to tropical convexity
4. MConvexVerifier - Verify M-convex exchange property

Complexity:
- Depth computation: O(k * n * |S|) where |S| is support size
- Ratio transform: O(|S|) per application
- M-convex verification: O(|S|^2 * n^2)
"""

import numpy as np
from math import factorial, log
from itertools import combinations, product as cartesian_product
from typing import Callable, List, Tuple, Optional, Set, Dict


class RatioTransform:
    """
    The discrete ratio transform R_i f(m) = f(m + e_i) / f(m).
    
    This is the discrete analog of the logarithmic derivative.
    Applying it k times extracts k-th order curvature information.
    
    Time: O(1) per evaluation (delegates to f)
    Space: O(1) additional
    """
    
    def __init__(self, f: Callable, direction: int, dim: int):
        """
        Args:
            f: base function Z^n -> R
            direction: coordinate index i
            dim: dimension n
        """
        self.f = f
        self.direction = direction
        self.dim = dim
    
    def __call__(self, m: tuple) -> float:
        """Evaluate R_i f at point m."""
        shifted = list(m)
        shifted[self.direction] += 1
        denom = self.f(tuple(m))
        if abs(denom) < 1e-15:
            return 0.0
        return self.f(tuple(shifted)) / denom
    
    @staticmethod
    def chain(f: Callable, directions: List[int], dim: int) -> Callable:
        """
        Apply ratio transforms in sequence: R_{i_k} ... R_{i_1} f.
        
        Time: O(k) per evaluation
        """
        result = f
        for d in directions:
            result = RatioTransform(result, d, dim)
        return result


class LorentzianDepthComputer:
    """
    Compute the Lorentzian depth (k-fold DLC depth) of a function.
    
    Algorithm:
    1. Start with depth k = 0 (check positivity)
    2. For each k, check all-direction log-concavity
    3. Apply ratio transform and recurse
    4. Stop when log-concavity fails
    
    Time: O(k_max * n * |points|) where n = dimension
    Space: O(|points|) for caching
    """
    
    def __init__(self, f: Callable, dim: int, 
                 points: Optional[List[tuple]] = None,
                 max_depth: int = 10,
                 tol: float = 1e-10):
        """
        Args:
            f: function Z^n -> R (the valuation)
            dim: dimension n
            points: test points (auto-generated if None)
            max_depth: maximum depth to check
            tol: numerical tolerance
        """
        self.f = f
        self.dim = dim
        self.max_depth = max_depth
        self.tol = tol
        
        if points is None:
            self.points = list(cartesian_product(range(6), repeat=dim))
        else:
            self.points = points
    
    def _check_positive(self, f: Callable) -> bool:
        """Check if f is positive on all test points."""
        for m in self.points:
            if f(m) <= self.tol:
                return False
        return True
    
    def _check_dir_log_concave(self, f: Callable, direction: int) -> Tuple[bool, float]:
        """
        Check directional log-concavity in direction i.
        
        Returns:
            (is_lc, min_ratio): whether LC holds and the minimum f(m+e)^2/(f(m)*f(m+2e))
        """
        min_ratio = float('inf')
        is_lc = True
        
        for m in self.points:
            e = [0] * self.dim
            e[direction] = 1
            m1 = tuple(m[j] + e[j] for j in range(self.dim))
            m2 = tuple(m[j] + 2*e[j] for j in range(self.dim))
            
            fm = f(m)
            fm1 = f(m1)
            fm2 = f(m2)
            
            if fm > self.tol and fm2 > self.tol:
                ratio = fm1**2 / (fm * fm2)
                min_ratio = min(min_ratio, ratio)
                if ratio < 1.0 - self.tol:
                    is_lc = False
        
        return is_lc, min_ratio
    
    def compute_depth(self) -> Tuple[int, Dict]:
        """
        Compute the k-fold DLC depth.
        
        Returns:
            (depth, info): depth value and diagnostic info
        
        Time: O(max_depth * dim * |points|)
        """
        info = {
            'positivity_checks': [],
            'lc_checks': [],
            'min_ratios': []
        }
        
        current_f = self.f
        
        for k in range(self.max_depth):
            # Check positivity
            is_pos = self._check_positive(current_f)
            info['positivity_checks'].append(is_pos)
            if not is_pos:
                return k, info
            
            # Check all-direction log-concavity
            all_lc = True
            min_ratio_k = float('inf')
            for i in range(self.dim):
                is_lc, min_r = self._check_dir_log_concave(current_f, i)
                min_ratio_k = min(min_ratio_k, min_r)
                if not is_lc:
                    all_lc = False
                    break
            
            info['lc_checks'].append(all_lc)
            info['min_ratios'].append(min_ratio_k)
            
            if not all_lc:
                return k, info
            
            # Apply ratio transform in direction 0
            current_f = RatioTransform(current_f, 0, self.dim)
        
        return self.max_depth, info


class TropicalBridge:
    """
    Convert between log-concavity and tropical convexity.
    
    The tropicalization map: f -> -log(f) converts:
    - Multiplicative structure → Additive structure
    - Log-concavity → Tropical convexity (discrete convexity in min-plus)
    - Products → Sums (in tropical semiring)
    
    Time: O(1) per point evaluation
    """
    
    @staticmethod
    def tropicalize(f: Callable, m: tuple) -> float:
        """Compute -log(f(m))."""
        val = f(m)
        if val <= 0:
            return float('inf')
        return -log(val)
    
    @staticmethod
    def check_tropical_convexity(f: Callable, direction: int, 
                                  point: tuple, dim: int) -> Tuple[float, float, bool]:
        """
        Check: 2 * trop(f(m+e)) <= trop(f(m)) + trop(f(m+2e))
        
        Returns:
            (lhs, rhs, satisfied)
        """
        e = [0] * dim
        e[direction] = 1
        m1 = tuple(point[j] + e[j] for j in range(dim))
        m2 = tuple(point[j] + 2*e[j] for j in range(dim))
        
        t0 = TropicalBridge.tropicalize(f, point)
        t1 = TropicalBridge.tropicalize(f, m1)
        t2 = TropicalBridge.tropicalize(f, m2)
        
        lhs = 2 * t1
        rhs = t0 + t2
        
        return lhs, rhs, lhs <= rhs + 1e-10
    
    @staticmethod
    def tropical_hessian(f: Callable, point: tuple, dim: int) -> np.ndarray:
        """
        Compute the tropical Hessian matrix H_{ij} at a point.
        
        H_{ij} = trop(f(m+e_i+e_j)) + trop(f(m)) - trop(f(m+e_i)) - trop(f(m+e_j))
        
        Negative semidefiniteness corresponds to tropical supermodularity.
        
        Time: O(n^2)
        """
        H = np.zeros((dim, dim))
        t0 = TropicalBridge.tropicalize(f, point)
        
        for i in range(dim):
            ei = [0] * dim
            ei[i] = 1
            mi = tuple(point[j] + ei[j] for j in range(dim))
            ti = TropicalBridge.tropicalize(f, mi)
            
            for j in range(dim):
                ej = [0] * dim
                ej[j] = 1
                mj = tuple(point[k] + ej[k] for k in range(dim))
                mij = tuple(point[k] + ei[k] + ej[k] for k in range(dim))
                
                tj = TropicalBridge.tropicalize(f, mj)
                tij = TropicalBridge.tropicalize(f, mij)
                
                H[i, j] = tij + t0 - ti - tj
        
        return H


class MConvexVerifier:
    """
    Verify the M-convex exchange property for a support set.
    
    M-convexity: for any m, m' in S with m_i > m'_i,
    there exists j with m_j < m'_j such that m - e_i + e_j ∈ S.
    
    Time: O(|S|^2 * n^2) for full verification
    """
    
    @staticmethod
    def verify(support: List[tuple], dim: int) -> Tuple[bool, Optional[Tuple]]:
        """
        Verify M-convex exchange property.
        
        Returns:
            (is_mconvex, counterexample): True if M-convex, or a counterexample pair
        """
        support_set = set(support)
        
        for m in support:
            for mp in support:
                for i in range(dim):
                    if m[i] > mp[i]:
                        # Need to find j with m[j] < mp[j] and m - e_i + e_j in S
                        found = False
                        for j in range(dim):
                            if m[j] < mp[j]:
                                exchanged = list(m)
                                exchanged[i] -= 1
                                exchanged[j] += 1
                                if tuple(exchanged) in support_set:
                                    found = True
                                    break
                        
                        if not found:
                            return False, (m, mp, i)
        
        return True, None


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Example: multinomial coefficient function
    def multinomial(m, degree=4):
        if any(x < 0 for x in m) or sum(m) != degree:
            return 0.0
        return factorial(degree) / np.prod([factorial(int(x)) for x in m])
    
    n = 3
    f = lambda m: multinomial(m, degree=4)
    
    # Compute depth
    points = [m for m in cartesian_product(range(5), repeat=n) if sum(m) == 4]
    computer = LorentzianDepthComputer(f, n, points=points, max_depth=8)
    depth, info = computer.compute_depth()
    print(f"Multinomial (n=3, d=4) depth: >= {depth}")
    print(f"Min ratios per level: {info['min_ratios'][:depth]}")
    
    # Tropical Hessian
    H = TropicalBridge.tropical_hessian(f, (2, 1, 1), n)
    print(f"\nTropical Hessian at (2,1,1):")
    print(H)
    eigenvalues = np.linalg.eigvalsh(H)
    print(f"Eigenvalues: {eigenvalues}")
    print(f"Negative semidefinite: {all(e <= 1e-10 for e in eigenvalues)}")
    
    # M-convex verification
    support = [m for m in points if f(m) > 0]
    is_mc, cx = MConvexVerifier.verify(support, n)
    print(f"\nM-convex support: {is_mc}")
