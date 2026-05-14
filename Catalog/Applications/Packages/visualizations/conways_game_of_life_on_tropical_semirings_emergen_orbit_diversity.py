import numpy as np
from typing import Tuple, List, Set, Dict, Optional
from dataclasses import dataclass

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