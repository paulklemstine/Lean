#!/usr/bin/env python3
"""
Tropical Renormalization Flow: Core Algorithms

Type-hinted implementations of the key algorithms from the tropical
renormalization framework.
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass, field
from typing import Optional


@dataclass
class TropicalDepthFlow:
    """A tropical depth flow on {0, ..., n-1}.
    
    Attributes:
        n: Size of the finite type
        step: The flow step function (as a list: step[i] = step(i))
        depth: The depth function (as a list: depth[i] = depth(i))
    """
    n: int
    step: list[int]
    depth: list[float]
    
    def __post_init__(self) -> None:
        assert len(self.step) == self.n
        assert len(self.depth) == self.n
        assert all(0 <= self.depth[i] for i in range(self.n)), "Depth must be non-negative"
        assert all(self.depth[self.step[i]] <= self.depth[i] for i in range(self.n)), \
            "Depth must be non-increasing under step"
    
    def iterate(self, x: int, n_steps: int) -> int:
        """Iterate step n_steps times starting from x."""
        for _ in range(n_steps):
            x = self.step[x]
        return x
    
    def is_fixed(self, x: int) -> bool:
        """Check if x is a fixed point."""
        return self.step[x] == x
    
    def is_strictly_contracting(self) -> bool:
        """Check if the flow is strictly contracting."""
        return all(
            self.depth[self.step[i]] < self.depth[i]
            for i in range(self.n)
            if not self.is_fixed(i)
        )
    
    def compute_fixed_point(self, x: int) -> int:
        """Compute the fixed point that x converges to.
        
        Under strict contraction, this is guaranteed to terminate
        within n steps.
        """
        return self.iterate(x, self.n)
    
    def compute_universality_classes(self) -> dict[int, list[int]]:
        """Compute universality classes by mapping each element to its fixed point.
        
        Returns a dict mapping fixed_point -> [elements in class].
        
        Time complexity: O(n^2)
        """
        classes: dict[int, list[int]] = {}
        for x in range(self.n):
            fp = self.compute_fixed_point(x)
            if fp not in classes:
                classes[fp] = []
            classes[fp].append(x)
        return classes
    
    def num_classes(self) -> int:
        """Count the number of universality classes."""
        return len(self.compute_universality_classes())
    
    def depth_spectrum(self) -> set[float]:
        """Compute the depth spectrum (set of depth values)."""
        return set(self.depth)
    
    def orbit(self, x: int) -> list[int]:
        """Compute the orbit of x until it reaches a fixed point or revisits."""
        visited = []
        seen = set()
        current = x
        while current not in seen:
            seen.add(current)
            visited.append(current)
            current = self.step[current]
        return visited


@dataclass
class CoarseGraining:
    """A coarse-graining map between tropical depth flows.
    
    Attributes:
        source: The source flow
        target: The target flow  
        map_fn: The coarse-graining map (as a list)
    """
    source: TropicalDepthFlow
    target: TropicalDepthFlow
    map_fn: list[int]
    
    def __post_init__(self) -> None:
        assert len(self.map_fn) == self.source.n
        # Check surjectivity
        assert set(self.map_fn) == set(range(self.target.n)), "Map must be surjective"
        # Check commutativity: map(step_F(x)) = step_G(map(x))
        for x in range(self.source.n):
            assert self.map_fn[self.source.step[x]] == self.target.step[self.map_fn[x]], \
                f"Map does not commute with step at x={x}"
        # Check depth reduction
        for x in range(self.source.n):
            assert self.target.depth[self.map_fn[x]] <= self.source.depth[x], \
                f"Map does not reduce depth at x={x}"
    
    def verify_merging_principle(self) -> bool:
        """Verify that the Merging Principle holds.
        
        Returns True if for all x, y in the same F-class,
        phi(x) and phi(y) are in the same G-class.
        """
        classes_f = self.source.compute_universality_classes()
        for fp, members in classes_f.items():
            g_fps = set()
            for x in members:
                g_fp = self.target.compute_fixed_point(self.map_fn[x])
                g_fps.add(g_fp)
            if len(g_fps) > 1:
                return False
        return True


def tropical_max_plus_step(
    W: np.ndarray, 
    v: np.ndarray
) -> np.ndarray:
    """Tropical max-plus averaging step.
    
    Computes: result[i] = (v[i] + max_j(v[j] + W[i,j])) / 2
    
    This is a non-expansion in the sup norm:
    ||T(v) - T(w)||_inf <= ||v - w||_inf
    
    Args:
        W: n×n weight matrix
        v: n-dimensional value vector
    
    Returns:
        The updated value vector
    
    Time complexity: O(n^2)
    """
    n = len(v)
    result = np.zeros(n)
    for i in range(n):
        max_neighbor = np.max(v + W[i])
        result[i] = (v[i] + max_neighbor) / 2
    return result


def tropical_flow_to_fixed_point(
    W: np.ndarray,
    v: np.ndarray,
    max_steps: int = 1000,
    tol: float = 1e-10
) -> tuple[np.ndarray, int]:
    """Run the tropical max-plus step until convergence.
    
    Args:
        W: Weight matrix
        v: Initial values
        max_steps: Maximum iterations
        tol: Convergence tolerance
    
    Returns:
        (final_values, num_steps)
    """
    for step in range(max_steps):
        v_new = tropical_max_plus_step(W, v)
        if np.max(np.abs(v_new - v)) < tol:
            return v_new, step + 1
        v = v_new
    return v, max_steps


def test_log_class_conjecture(n: int) -> tuple[int, int, bool]:
    """Test the logarithmic class conjecture for a given n.
    
    Enumerates all strictly contracting flows on {0,...,n-1} with
    depth[i] = i and finds the maximum number of universality classes.
    
    Returns:
        (max_classes, conjectured_bound, holds)
    """
    max_classes = 0
    depth = list(range(n))
    
    def search(idx: int, step_so_far: list[int]) -> None:
        nonlocal max_classes
        if idx == n:
            flow = TropicalDepthFlow(n, step_so_far[:], [float(d) for d in depth])
            nc = flow.num_classes()
            max_classes = max(max_classes, nc)
            return
        
        # Element idx can map to itself or any element with strictly lower depth
        targets = [idx]  # fixed point
        for j in range(idx):  # all j < idx have depth[j] < depth[idx]
            targets.append(j)
        
        for t in targets:
            step_so_far.append(t)
            search(idx + 1, step_so_far)
            step_so_far.pop()
    
    search(0, [])
    bound = int(np.floor(np.log2(n))) + 2
    return max_classes, bound, max_classes <= bound


if __name__ == "__main__":
    # Example usage
    print("=== Tropical Depth Flow Example ===")
    flow = TropicalDepthFlow(
        n=6,
        step=[0, 0, 0, 1, 2, 3],
        depth=[0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
    )
    
    print(f"Flow: step = {flow.step}")
    print(f"Depth: {flow.depth}")
    print(f"Strictly contracting: {flow.is_strictly_contracting()}")
    print(f"Universality classes: {flow.compute_universality_classes()}")
    print(f"Number of classes: {flow.num_classes()}")
    print(f"Depth spectrum: {flow.depth_spectrum()}")
    
    for x in range(6):
        print(f"  Orbit of {x}: {flow.orbit(x)}")
    
    print("\n=== Logarithmic Class Conjecture Test ===")
    for n in range(2, 9):
        mc, bound, holds = test_log_class_conjecture(n)
        print(f"  n={n}: max_classes={mc}, bound={bound}, holds={holds}")
