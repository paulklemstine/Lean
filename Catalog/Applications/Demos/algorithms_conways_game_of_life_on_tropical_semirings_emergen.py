#!/usr/bin/env python3
"""
Tropical Game of Life — Algorithms

Complete implementations of the algorithms described in the research paper,
with docstrings, type hints, and example usage.
"""

import numpy as np
from typing import Tuple, List, Set, Dict, Optional
from dataclasses import dataclass


# ============================================================
# Algorithm 1: Tropical Threshold (Core Primitive)
# ============================================================

def tropical_threshold(s: int, lo: int, hi: int) -> int:
    """Tropical threshold function.
    
    Returns 1 if lo <= s <= hi, 0 otherwise.
    Implemented using min and truncating subtraction.
    
    Time complexity: O(1)
    Space complexity: O(1)
    
    Args:
        s: Input value to test
        lo: Lower bound of interval
        hi: Upper bound of interval
    
    Returns:
        1 if s is in [lo, hi], 0 otherwise
    
    Examples:
        >>> tropical_threshold(3, 2, 4)
        1
        >>> tropical_threshold(1, 2, 4)
        0
        >>> tropical_threshold(5, 2, 4)
        0
    """
    return min(1, max(0, s + 1 - lo)) * min(1, max(0, hi + 1 - s))


# ============================================================
# Algorithm 2: Tropical Life Step
# ============================================================

def tropical_life_step(config: np.ndarray) -> np.ndarray:
    """Apply one step of the tropical Life automaton on a torus.
    
    Each cell is updated based on its Moore neighborhood (8 neighbors)
    with periodic boundary conditions. The update rule uses tropical
    threshold functions for birth/survival decisions.
    
    Time complexity: O(m * n) where (m, n) is the grid shape
    Space complexity: O(m * n)
    
    Args:
        config: 2D numpy array representing the current configuration
    
    Returns:
        New configuration after one tropical Life step
    
    Example:
        >>> block = np.zeros((6, 6), dtype=int)
        >>> block[0:2, 0:2] = 1
        >>> np.array_equal(block, tropical_life_step(block))
        True
    """
    m, n = config.shape
    new_config = np.zeros_like(config)
    
    for i in range(m):
        for j in range(n):
            # Compute neighbor sum (Moore neighborhood on torus)
            s = 0
            for di in [-1, 0, 1]:
                for dj in [-1, 0, 1]:
                    if di == 0 and dj == 0:
                        continue
                    s += config[(i + di) % m, (j + dj) % n]
            
            # Tropical local rule
            alive = min(1, int(config[i, j]))
            survive = tropical_threshold(s, 2, 3)
            birth = tropical_threshold(s, 3, 3)
            new_config[i, j] = alive * survive + (1 - alive) * birth
    
    return new_config


def tropical_life_step_vectorized(config: np.ndarray) -> np.ndarray:
    """Vectorized version of tropical_life_step using numpy rolling.
    
    Significantly faster for large grids.
    
    Time complexity: O(m * n)
    Space complexity: O(m * n)
    """
    # Compute neighbor sum using rolled arrays
    s = np.zeros_like(config)
    for di in [-1, 0, 1]:
        for dj in [-1, 0, 1]:
            if di == 0 and dj == 0:
                continue
            s += np.roll(np.roll(config, -di, axis=0), -dj, axis=1)
    
    alive = np.minimum(1, config)
    survive = np.minimum(1, np.maximum(0, s + 1 - 2)) * np.minimum(1, np.maximum(0, 3 + 1 - s))
    birth_val = np.minimum(1, np.maximum(0, s + 1 - 3)) * np.minimum(1, np.maximum(0, 3 + 1 - s))
    
    return alive * survive + (1 - alive) * birth_val


# ============================================================
# Algorithm 3: Orbit Diversity Computation
# ============================================================

def orbit_diversity(config: np.ndarray, T: int) -> int:
    """Compute orbit diversity: number of distinct configurations in orbit.
    
    Returns |{step^t(c) : 0 <= t <= T}|.
    
    Time complexity: O(T * m * n) for evolution + O(T * m * n) for hashing
    Space complexity: O(T * m * n) for storing orbit
    
    Args:
        config: Initial configuration
        T: Time horizon
    
    Returns:
        Number of distinct configurations visited
    
    Example:
        >>> glider = np.zeros((10, 10), dtype=int)
        >>> for i, j in [(0,1),(1,2),(2,0),(2,1),(2,2)]:
        ...     glider[i, j] = 1
        >>> orbit_diversity(glider, 4)
        5
    """
    seen: Set[tuple] = set()
    current = config.copy()
    
    for t in range(T + 1):
        key = tuple(current.flatten())
        seen.add(key)
        if t < T:
            current = tropical_life_step_vectorized(current)
    
    return len(seen)


def orbit_diversity_with_history(config: np.ndarray, T: int) -> Tuple[int, List[np.ndarray]]:
    """Compute orbit diversity and return the full orbit history.
    
    Args:
        config: Initial configuration
        T: Time horizon
    
    Returns:
        Tuple of (diversity count, list of configurations)
    """
    history: List[np.ndarray] = []
    seen: Set[tuple] = set()
    current = config.copy()
    
    for t in range(T + 1):
        history.append(current.copy())
        seen.add(tuple(current.flatten()))
        if t < T:
            current = tropical_life_step_vectorized(current)
    
    return len(seen), history


# ============================================================
# Algorithm 4: Still Life Detection
# ============================================================

def is_still_life(config: np.ndarray) -> bool:
    """Check if a configuration is a still life (fixed point).
    
    Time complexity: O(m * n)
    Space complexity: O(m * n)
    
    Args:
        config: Configuration to check
    
    Returns:
        True if config is a fixed point of the tropical Life step
    
    Example:
        >>> block = np.zeros((6, 6), dtype=int)
        >>> block[0:2, 0:2] = 1
        >>> is_still_life(block)
        True
    """
    return np.array_equal(config, tropical_life_step_vectorized(config))


# ============================================================
# Algorithm 5: Glider Detection
# ============================================================

def detect_glider(config: np.ndarray, max_period: int = 20) -> Optional[Tuple[int, int, int]]:
    """Detect if a configuration is a glider.
    
    Searches for period k and displacement (dx, dy) such that
    step^k(config) = shift(dx, dy, config).
    
    Time complexity: O(max_period * m * n * m * n) worst case
    Space complexity: O(m * n)
    
    Args:
        config: Configuration to analyze
        max_period: Maximum period to search
    
    Returns:
        Tuple (period, dx, dy) if glider detected, None otherwise
    """
    m, n = config.shape
    
    # Check it's not a still life
    if is_still_life(config):
        return None
    
    current = config.copy()
    for k in range(1, max_period + 1):
        current = tropical_life_step_vectorized(current)
        
        # Try all shifts
        for dx in range(m):
            for dy in range(n):
                shifted = np.roll(np.roll(config, dx, axis=0), dy, axis=1)
                if np.array_equal(current, shifted):
                    return (k, dx, dy)
    
    return None


# ============================================================
# Algorithm 6: Pattern Search (Exhaustive on Small Grids)
# ============================================================

@dataclass
class PatternAnalysis:
    """Analysis results for a configuration."""
    config: np.ndarray
    is_still_life: bool
    glider_info: Optional[Tuple[int, int, int]]
    orbit_diversity_10: int
    alive_count: int


def exhaustive_binary_search(m: int, n: int, max_alive: int = 6) -> List[PatternAnalysis]:
    """Search all binary configurations on m×n torus for interesting patterns.
    
    Enumerates configurations with up to max_alive cells and classifies them.
    
    Args:
        m, n: Grid dimensions
        max_alive: Maximum number of alive cells to consider
    
    Returns:
        List of interesting pattern analyses
    """
    from itertools import combinations
    
    results: List[PatternAnalysis] = []
    cells = [(i, j) for i in range(m) for j in range(n)]
    
    for num_alive in range(1, max_alive + 1):
        for alive_cells in combinations(cells, num_alive):
            config = np.zeros((m, n), dtype=int)
            for i, j in alive_cells:
                config[i, j] = 1
            
            still = is_still_life(config)
            glider = detect_glider(config, max_period=8) if not still else None
            div = orbit_diversity(config, 10)
            
            if still and num_alive > 1:
                results.append(PatternAnalysis(
                    config=config.copy(), is_still_life=True,
                    glider_info=None, orbit_diversity_10=1,
                    alive_count=num_alive
                ))
            elif glider is not None:
                results.append(PatternAnalysis(
                    config=config.copy(), is_still_life=False,
                    glider_info=glider, orbit_diversity_10=div,
                    alive_count=num_alive
                ))
    
    return results


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Life Algorithms — Example Usage")
    print("=" * 50)
    
    # Block still life
    print("\n1. Block still life (6×6 torus):")
    block = np.zeros((6, 6), dtype=int)
    block[0:2, 0:2] = 1
    print(f"   Is still life: {is_still_life(block)}")
    print(f"   Orbit diversity (T=10): {orbit_diversity(block, 10)}")
    
    # Glider
    print("\n2. Glider (10×10 torus):")
    glider = np.zeros((10, 10), dtype=int)
    for i, j in [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)]:
        glider[i, j] = 1
    result = detect_glider(glider)
    print(f"   Glider detected: {result}")
    print(f"   Orbit diversity (T=4): {orbit_diversity(glider, 4)}")
    print(f"   Orbit diversity (T=20): {orbit_diversity(glider, 20)}")
    
    # Vectorized performance comparison
    print("\n3. Performance comparison (50×50 torus, random config):")
    import time
    large_config = np.random.randint(0, 2, (50, 50))
    
    start = time.time()
    for _ in range(10):
        tropical_life_step(large_config)
    t_basic = time.time() - start
    
    start = time.time()
    for _ in range(10):
        tropical_life_step_vectorized(large_config)
    t_vec = time.time() - start
    
    print(f"   Basic:      {t_basic:.4f}s for 10 steps")
    print(f"   Vectorized: {t_vec:.4f}s for 10 steps")
    print(f"   Speedup:    {t_basic/t_vec:.1f}x")
    
    # Small grid search
    print("\n4. Exhaustive search on 4×4 torus (up to 4 alive cells):")
    patterns = exhaustive_binary_search(4, 4, max_alive=4)
    still_lifes = [p for p in patterns if p.is_still_life]
    gliders = [p for p in patterns if p.glider_info is not None]
    print(f"   Still lifes found: {len(still_lifes)}")
    print(f"   Gliders found: {len(gliders)}")
    for g in gliders[:3]:
        print(f"     Period={g.glider_info[0]}, shift=({g.glider_info[1]},{g.glider_info[2]}), "
              f"alive={g.alive_count}")
