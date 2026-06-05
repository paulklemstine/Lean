#!/usr/bin/env python3
"""
Algorithms for Game of Life and Simulation Morphism Algebra

Type-hinted implementations of the key algorithms described in the research.
"""

from typing import Callable, TypeVar, Generic, Tuple, List, Set, Optional
from dataclasses import dataclass
import numpy as np

# =============================================================================
# Type Definitions
# =============================================================================

State = TypeVar('State')
Output = TypeVar('Output')

# =============================================================================
# Algorithm 1: Game of Life Step
# =============================================================================

def gol_step(grid: np.ndarray) -> np.ndarray:
    """Conway's Game of Life step function.
    
    Computes one generation of the Game of Life using numpy convolution
    for efficiency. Uses toroidal (wrap-around) boundary conditions.
    
    Time complexity: O(n²) for an n×n grid
    Space complexity: O(n²)
    
    Args:
        grid: 2D numpy array of 0s and 1s
        
    Returns:
        New grid after one GoL step
    """
    # Count neighbors using array shifts (toroidal boundary)
    rows, cols = grid.shape
    neighbor_count = np.zeros_like(grid)
    
    for di in [-1, 0, 1]:
        for dj in [-1, 0, 1]:
            if di == 0 and dj == 0:
                continue
            neighbor_count += np.roll(np.roll(grid, di, axis=0), dj, axis=1)
    
    # Apply rules vectorized
    birth = (grid == 0) & (neighbor_count == 3)
    survive = (grid == 1) & ((neighbor_count == 2) | (neighbor_count == 3))
    
    return (birth | survive).astype(int)


# =============================================================================
# Algorithm 2: SimSystem
# =============================================================================

@dataclass
class SimSystem(Generic[State]):
    """A computational dynamical system.
    
    Captures the essence of a deterministic computational process:
    a state space with a step function.
    """
    name: str
    step: Callable[[State], State]
    
    def iterate(self, n: int, state: State) -> State:
        """Apply step function n times.
        
        Time complexity: O(n × cost(step))
        """
        result = state
        for _ in range(n):
            result = self.step(result)
        return result


# =============================================================================
# Algorithm 3: SimMorphism with Composition
# =============================================================================

@dataclass
class SimMorphism:
    """A simulation morphism between SimSystems.
    
    Witnesses that the target system can simulate the source system
    with a bounded time overhead factor.
    
    Key invariant (coherence):
        target.iterate(time_factor, encode(s)) == encode(source.step(s))
    """
    source: SimSystem
    target: SimSystem
    encode: Callable
    time_factor: int  # Must be positive
    
    def __post_init__(self):
        assert self.time_factor > 0, "Time factor must be positive"
    
    @staticmethod
    def identity(system: SimSystem) -> 'SimMorphism':
        """Identity morphism: a system simulates itself with factor 1."""
        return SimMorphism(
            source=system,
            target=system,
            encode=lambda x: x,
            time_factor=1
        )
    
    def compose(self, other: 'SimMorphism') -> 'SimMorphism':
        """Compose simulation morphisms.
        
        If self: A → B with factor t₁, and other: B → C with factor t₂,
        returns A → C with factor t₁ × t₂.
        
        This is the key algebraic result: overhead is MULTIPLICATIVE.
        """
        assert self.target.name == other.source.name, \
            f"Cannot compose: {self.target.name} ≠ {other.source.name}"
        
        self_encode = self.encode
        other_encode = other.encode
        
        return SimMorphism(
            source=self.source,
            target=other.target,
            encode=lambda s: other_encode(self_encode(s)),
            time_factor=self.time_factor * other.time_factor
        )
    
    def verify_coherence(self, test_states: list, 
                         decode: Optional[Callable] = None) -> bool:
        """Verify the coherence condition on test states.
        
        Returns True if for all test states s:
          target.iterate(time_factor, encode(s)) ≈ encode(source.step(s))
        """
        for s in test_states:
            encoded = self.encode(s)
            simulated = self.target.iterate(self.time_factor, encoded)
            expected = self.encode(self.source.step(s))
            
            if decode:
                if decode(simulated) != decode(expected):
                    return False
            else:
                if simulated != expected:
                    return False
        return True


# =============================================================================
# Algorithm 4: SimComplexity
# =============================================================================

@dataclass
class SimComplexity:
    """Complexity class for simulation overhead.
    
    Captures how time and space overhead scale with input size.
    Both functions must be monotone.
    """
    time_overhead: Callable[[int], int]
    space_overhead: Callable[[int], int]
    
    @staticmethod
    def linear(time_const: int, space_const: int) -> 'SimComplexity':
        """Linear complexity: O(c·n) overhead."""
        return SimComplexity(
            time_overhead=lambda n: time_const * n,
            space_overhead=lambda n: space_const * n
        )
    
    @staticmethod
    def quadratic(time_const: int, space_const: int) -> 'SimComplexity':
        """Quadratic complexity: O(c·n²) overhead."""
        return SimComplexity(
            time_overhead=lambda n: time_const * n * n,
            space_overhead=lambda n: space_const * n * n
        )
    
    def compose(self, other: 'SimComplexity') -> 'SimComplexity':
        """Compose complexities. Functions compose (multiply overhead).
        
        If C₁(n) and C₂(n) are the overheads, composition gives C₁(C₂(n)).
        """
        self_time = self.time_overhead
        self_space = self.space_overhead
        other_time = other.time_overhead
        other_space = other.space_overhead
        
        return SimComplexity(
            time_overhead=lambda n: self_time(other_time(n)),
            space_overhead=lambda n: self_space(other_space(n))
        )


# =============================================================================
# Algorithm 5: Light Cone Analysis
# =============================================================================

def light_cone(t: int) -> Set[Tuple[int, int]]:
    """Compute the light cone at time t.
    
    Returns the set of all (x, y) with |x| ≤ t and |y| ≤ t.
    
    Size: (2t+1)²
    """
    return {(x, y) for x in range(-t, t+1) for y in range(-t, t+1)}


def verify_speed_of_light(grid: np.ndarray, center: Tuple[int, int], 
                           steps: int) -> List[int]:
    """Verify the speed of light bound experimentally.
    
    Returns the maximum Chebyshev distance of alive cells from center
    at each time step.
    """
    distances = []
    current = grid.copy()
    
    for _ in range(steps):
        current = gol_step(current)
        alive = np.argwhere(current == 1)
        if len(alive) > 0:
            max_dist = max(
                max(abs(p[0] - center[0]), abs(p[1] - center[1]))
                for p in alive
            )
        else:
            max_dist = 0
        distances.append(max_dist)
    
    return distances


# =============================================================================
# Algorithm 6: Still Life Detector
# =============================================================================

def is_still_life(grid: np.ndarray) -> bool:
    """Check if a configuration is a still life (fixed point of golStep)."""
    return np.array_equal(gol_step(grid), grid)


def find_still_life_violations(grid: np.ndarray) -> List[Tuple[int, int, str]]:
    """Find cells that violate still life constraints.
    
    Returns list of (row, col, violation_type) where violation_type is
    'alive_wrong_count' or 'dead_birth'.
    """
    violations = []
    rows, cols = grid.shape
    
    for i in range(rows):
        for j in range(cols):
            count = 0
            for di in [-1, 0, 1]:
                for dj in [-1, 0, 1]:
                    if di == 0 and dj == 0:
                        continue
                    ni, nj = (i + di) % rows, (j + dj) % cols
                    count += grid[ni, nj]
            
            if grid[i, j] == 1 and count not in (2, 3):
                violations.append((i, j, f'alive with {count} neighbors'))
            elif grid[i, j] == 0 and count == 3:
                violations.append((i, j, 'dead with 3 neighbors (birth)'))
    
    return violations


# =============================================================================
# Algorithm 7: TM Simulation Overhead Calculator
# =============================================================================

def tm_simulation_bound(num_states: int, num_symbols: int) -> dict:
    """Calculate the simulation overhead bound for a Turing machine.
    
    Returns bounds on the time factor needed to simulate a TM
    with the given number of states and symbols in a 2D CA.
    """
    assert num_states > 0 and num_symbols > 0
    
    upper_bound = (num_states + 1) * (num_symbols + 1)
    
    return {
        'num_states': num_states,
        'num_symbols': num_symbols,
        'time_factor_upper_bound': upper_bound,
        'description': f'A TM with {num_states} states and {num_symbols} symbols '
                       f'can be simulated with time factor ≤ {upper_bound}'
    }


if __name__ == "__main__":
    # Quick smoke test
    grid = np.zeros((10, 10), dtype=int)
    grid[4:7, 5] = 1  # Blinker
    
    print("Blinker (period 2):")
    for t in range(4):
        pop = np.sum(grid)
        still = is_still_life(grid)
        print(f"  t={t}: population={pop}, still_life={still}")
        grid = gol_step(grid)
    
    print("\nTM simulation bounds:")
    for s, k in [(2, 2), (5, 3), (10, 5)]:
        result = tm_simulation_bound(s, k)
        print(f"  {result['description']}")
