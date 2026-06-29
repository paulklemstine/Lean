"""
Algorithms for EML Closure Computation

Implements the key algorithms from the research paper, including:
- Closure membership testing (semi-decision procedure)
- Iterative closure computation
- Fixed-point detection
- Galois connection computation
"""

import numpy as np
from typing import Callable, List, Optional, Tuple, Set
from dataclasses import dataclass
import time


@dataclass
class FunctionRepr:
    """Representation of a function on a discrete grid."""
    values: np.ndarray
    name: str = ""
    depth: int = 0  # generation depth
    
    def __eq__(self, other):
        if not isinstance(other, FunctionRepr):
            return False
        return np.allclose(self.values, other.values, atol=1e-10)
    
    def __hash__(self):
        return hash(tuple(np.round(self.values, 8)))


class EMLClosureEngine:
    """
    Engine for computing EML closures on discretized functions.
    
    Implements the closure operator EMLCl on Set(ℝ → ℝ) using
    discretization on a uniform grid.
    
    Operations: constants, pointwise addition, pointwise multiplication,
    function composition (via interpolation).
    """
    
    def __init__(self, grid: np.ndarray, max_depth: int = 3, 
                 max_functions: int = 1000, tolerance: float = 1e-10):
        """
        Args:
            grid: Evaluation grid for function discretization
            max_depth: Maximum generation depth
            max_functions: Maximum number of functions to track
            tolerance: Tolerance for function equality
        """
        self.grid = grid
        self.max_depth = max_depth
        self.max_functions = max_functions
        self.tolerance = tolerance
    
    def make_func(self, f: Callable, name: str = "") -> FunctionRepr:
        """Create a FunctionRepr from a callable."""
        return FunctionRepr(values=f(self.grid), name=name)
    
    def make_const(self, c: float) -> FunctionRepr:
        """Create a constant function."""
        return FunctionRepr(
            values=np.full_like(self.grid, c, dtype=float),
            name=f"const({c})"
        )
    
    def _is_in_set(self, f: FunctionRepr, s: List[FunctionRepr]) -> bool:
        """Check if f is approximately in set s."""
        return any(np.allclose(f.values, g.values, atol=self.tolerance) for g in s)
    
    def _add(self, f: FunctionRepr, g: FunctionRepr) -> FunctionRepr:
        """Pointwise addition."""
        return FunctionRepr(
            values=f.values + g.values,
            name=f"({f.name}+{g.name})",
            depth=max(f.depth, g.depth) + 1
        )
    
    def _mul(self, f: FunctionRepr, g: FunctionRepr) -> FunctionRepr:
        """Pointwise multiplication."""
        return FunctionRepr(
            values=f.values * g.values,
            name=f"({f.name}*{g.name})",
            depth=max(f.depth, g.depth) + 1
        )
    
    def _comp(self, f: FunctionRepr, g: FunctionRepr) -> Optional[FunctionRepr]:
        """Function composition f ∘ g via interpolation."""
        try:
            comp_vals = np.interp(g.values, self.grid, f.values)
            if np.all(np.isfinite(comp_vals)):
                return FunctionRepr(
                    values=comp_vals,
                    name=f"({f.name}∘{g.name})",
                    depth=max(f.depth, g.depth) + 1
                )
        except:
            pass
        return None
    
    def closure_step(self, functions: List[FunctionRepr]) -> List[FunctionRepr]:
        """
        Perform one closure step: generate all pairwise combinations.
        
        Time complexity: O(n²) where n = len(functions)
        Space complexity: O(n² + new_functions)
        """
        result = list(functions)
        new_funcs = []
        
        # Limit combinations for tractability
        n = min(len(functions), 50)
        
        for i in range(n):
            for j in range(n):
                if len(result) + len(new_funcs) >= self.max_functions:
                    break
                
                f, g = functions[i], functions[j]
                
                # Addition
                s = self._add(f, g)
                if not self._is_in_set(s, result + new_funcs):
                    new_funcs.append(s)
                
                # Multiplication
                p = self._mul(f, g)
                if not self._is_in_set(p, result + new_funcs):
                    new_funcs.append(p)
                
                # Composition
                c = self._comp(f, g)
                if c is not None and not self._is_in_set(c, result + new_funcs):
                    new_funcs.append(c)
        
        result.extend(new_funcs)
        return result
    
    def compute_closure(self, generators: List[FunctionRepr], 
                        depth: Optional[int] = None) -> List[FunctionRepr]:
        """
        Compute EMLCl(generators) up to given depth.
        
        This is Algorithm 1 from the research paper.
        
        Args:
            generators: Initial set of functions
            depth: Maximum depth (default: self.max_depth)
            
        Returns:
            List of functions in the (approximate) closure
        """
        if depth is None:
            depth = self.max_depth
        
        # Add standard constants
        result = list(generators)
        for c in [0, 1, -1, 0.5, 2]:
            cf = self.make_const(c)
            if not self._is_in_set(cf, result):
                result.append(cf)
        
        prev_size = 0
        for d in range(depth):
            if len(result) == prev_size:
                break  # Fixed point reached
            prev_size = len(result)
            result = self.closure_step(result)
            
        return result
    
    def is_closed(self, functions: List[FunctionRepr]) -> bool:
        """
        Check if a set is approximately closed (fixed point of EMLCl).
        
        Returns True if one closure step adds no new functions.
        """
        extended = self.closure_step(functions)
        return len(extended) == len(functions)
    
    def membership_test(self, target: FunctionRepr, 
                       generators: List[FunctionRepr],
                       max_depth: int = 3) -> Tuple[bool, int]:
        """
        Semi-decision procedure for closure membership.
        
        Tests whether target ∈ EMLCl(generators) at depth ≤ max_depth.
        
        Returns:
            (found, depth) where found is True if membership was confirmed,
            and depth is the generation depth at which it was found.
        """
        current = list(generators)
        for c in [0, 1, -1]:
            cf = self.make_const(c)
            if not self._is_in_set(cf, current):
                current.append(cf)
        
        for d in range(max_depth + 1):
            if self._is_in_set(target, current):
                return (True, d)
            current = self.closure_step(current)
        
        return (False, -1)


def demo_closure_engine():
    """Demonstrate the EML closure engine."""
    grid = np.linspace(-2, 2, 201)
    engine = EMLClosureEngine(grid, max_depth=2, max_functions=500)
    
    # Create generators
    sin_f = engine.make_func(np.sin, "sin")
    cos_f = engine.make_func(np.cos, "cos")
    id_f = engine.make_func(lambda x: x, "id")
    
    print("EML Closure Engine Demo")
    print("=" * 50)
    
    # Compute closure of {sin}
    t0 = time.time()
    cl_sin = engine.compute_closure([sin_f], depth=2)
    t1 = time.time()
    print(f"\n|EMLCl({{sin}})| ≈ {len(cl_sin)} (computed in {t1-t0:.3f}s)")
    
    # Compute closure of {sin, cos}
    t0 = time.time()
    cl_sincos = engine.compute_closure([sin_f, cos_f], depth=2)
    t1 = time.time()
    print(f"|EMLCl({{sin, cos}})| ≈ {len(cl_sincos)} (computed in {t1-t0:.3f}s)")
    
    # Monotonicity check
    print(f"\nMonotonicity: |EMLCl({{sin}})| ≤ |EMLCl({{sin, cos}})|? "
          f"{len(cl_sin) <= len(cl_sincos)}")
    
    # Membership test
    sin2 = engine.make_func(lambda x: np.sin(x)**2, "sin²")
    found, depth = engine.membership_test(sin2, [sin_f], max_depth=2)
    print(f"\nsin² ∈ EMLCl({{sin}})? {found} (found at depth {depth})")
    
    sincos = engine.make_func(lambda x: np.sin(np.cos(x)), "sin∘cos")
    found, depth = engine.membership_test(sincos, [sin_f, cos_f], max_depth=2)
    print(f"sin∘cos ∈ EMLCl({{sin, cos}})? {found} (found at depth {depth})")
    
    # Closure of empty set
    cl_empty = engine.compute_closure([], depth=1)
    all_const = all(np.std(f.values) < 1e-8 for f in cl_empty)
    print(f"\n|EMLCl(∅)| = {len(cl_empty)}")
    print(f"All constant functions? {all_const}")
    
    # Fixed-point test
    print(f"\nIs EMLCl(∅) closed (fixed point)? {engine.is_closed(cl_empty)}")


if __name__ == "__main__":
    demo_closure_engine()
