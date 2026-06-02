"""
Algorithms for Categorical Surprise Theory

Type-hinted implementations of the core algorithms from the research paper.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional, Callable


# ============================================================
# Data Structures
# ============================================================

@dataclass
class SurpriseSpace:
    """A metric space with a distinguished expected element."""
    expected: float
    
    def surprise(self, x: float) -> float:
        """Compute the surprise value of x."""
        return abs(x - self.expected)
    
    def find_optimal(self, candidates: List[float]) -> Tuple[float, float]:
        """Find the maximally surprising element (Fundamental Theorem of Comedy)."""
        if not candidates:
            raise ValueError("Cannot find optimal in empty set")
        best = max(candidates, key=self.surprise)
        return best, self.surprise(best)


@dataclass
class Joke:
    """A joke: expected resolution paired with actual punchline."""
    expected_resolution: float
    actual_punchline: float
    
    @property
    def humor_value(self) -> float:
        return abs(self.expected_resolution - self.actual_punchline)


@dataclass  
class IRJoke:
    """Incongruity-Resolution joke model."""
    incongruity: float
    resolution: float
    
    def __post_init__(self) -> None:
        assert self.incongruity >= 0, "Incongruity must be non-negative"
        assert 0 <= self.resolution <= 1, "Resolution must be in [0, 1]"
    
    @property
    def net_humor(self) -> float:
        return self.incongruity * (1 - self.resolution)
    
    @property
    def joke_type(self) -> str:
        if self.resolution < 0.1:
            return "absurdist"
        elif self.resolution < 0.3:
            return "dark"
        elif self.resolution < 0.6:
            return "observational"
        elif self.resolution < 0.8:
            return "wordplay"
        else:
            return "pun"


@dataclass
class SubversionMap:
    """A surprise-amplifying map between spaces."""
    source: SurpriseSpace
    target: SurpriseSpace
    transform: Callable[[float], float]
    amplification: float
    
    def apply(self, x: float) -> float:
        return self.transform(x)
    
    def verify_amplification(self, x: float) -> bool:
        """Check the amplification property at a point."""
        target_surprise = self.target.surprise(self.apply(x))
        source_surprise = self.source.surprise(x)
        return target_surprise >= self.amplification * source_surprise - 1e-10


@dataclass
class SurpriseFunctor:
    """A pair of monotone maps with measurable gap."""
    expected_map: Callable[[float], float]
    twist_map: Callable[[float], float]
    
    def gap(self, x: float) -> float:
        return abs(self.expected_map(x) - self.twist_map(x))


# ============================================================
# Core Algorithms
# ============================================================

def compute_info_surprise(p: float) -> float:
    """
    Compute information-theoretic surprise: -log₂(p).
    
    Algorithm: Direct computation using log₂.
    Complexity: O(1)
    """
    if p <= 0:
        return float('inf')
    return -math.log2(p)


def compute_uniform_entropy(n: int) -> float:
    """
    Compute entropy of uniform distribution on n elements: log₂(n).
    
    Algorithm: H = -Σ (1/n) log₂(1/n) = log₂(n)
    Complexity: O(1)
    """
    if n <= 0:
        raise ValueError("n must be positive")
    return math.log2(n)


def find_optimal_joke(
    candidates: List[float],
    expected: float
) -> Tuple[float, float]:
    """
    Find the maximally surprising punchline.
    
    Algorithm: Linear scan (argmax of surprise function).
    Complexity: O(n) where n = len(candidates)
    Correctness: Guaranteed by Fundamental Theorem of Comedy 
                 (maximum exists in finite/compact spaces).
    
    Returns: (optimal_punchline, humor_value)
    """
    if not candidates:
        raise ValueError("No candidates")
    space = SurpriseSpace(expected)
    return space.find_optimal(candidates)


def analyze_comedy_routine(humor_values: List[float]) -> dict:
    """
    Analyze a comedy routine (sequence of humor values).
    
    Algorithm: Single-pass statistics.
    Complexity: O(n)
    
    Returns: Dictionary with total, average, peak, and monotonicity check.
    """
    if not humor_values:
        return {"total": 0.0, "average": 0.0, "peak": 0.0}
    
    total = sum(humor_values)
    average = total / len(humor_values)
    peak = max(humor_values)
    
    return {
        "total": total,
        "average": average,
        "peak": peak,
        "count": len(humor_values),
        "average_le_peak": average <= peak + 1e-10,
    }


def compute_gap_profile(
    functor: SurpriseFunctor,
    points: List[float]
) -> List[Tuple[float, float]]:
    """
    Compute the surprise gap profile along a sequence of points.
    
    Algorithm: Evaluate gap at each point.
    Complexity: O(n)
    
    Returns: List of (point, gap) pairs.
    """
    return [(x, functor.gap(x)) for x in points]


def verify_gap_triangle(
    functor: SurpriseFunctor,
    x: float,
    y: float
) -> bool:
    """
    Verify the gap triangle inequality: gap(y) ≤ gap(x) + d_F(x,y) + d_T(x,y).
    
    Algorithm: Direct computation and comparison.
    Complexity: O(1)
    """
    gap_y = functor.gap(y)
    gap_x = functor.gap(x)
    d_F = abs(functor.expected_map(x) - functor.expected_map(y))
    d_T = abs(functor.twist_map(x) - functor.twist_map(y))
    return gap_y <= gap_x + d_F + d_T + 1e-10


def optimal_ir_decomposition(
    humor_target: float,
    max_incongruity: float = 10.0,
    resolution_step: float = 0.01
) -> IRJoke:
    """
    Find the IR decomposition that achieves a target humor value
    with minimum incongruity (most efficient joke).
    
    Algorithm: For each resolution level, compute required incongruity.
               Choose the decomposition with minimum incongruity.
    Complexity: O(1/resolution_step)
    
    The optimal is always r=0, I=humor_target (absurdist).
    But if we want r > 0 (some resolution), I must be larger.
    """
    best: Optional[IRJoke] = None
    best_incongruity = float('inf')
    
    r = 0.0
    while r <= 0.99:
        # I * (1-r) = humor_target => I = humor_target / (1-r)
        required_inc = humor_target / (1 - r)
        if required_inc <= max_incongruity and required_inc < best_incongruity:
            best_incongruity = required_inc
            best = IRJoke(required_inc, r)
        r += resolution_step
    
    if best is None:
        raise ValueError(f"Cannot achieve humor {humor_target} within bounds")
    return best


if __name__ == "__main__":
    # Quick demonstration
    space = SurpriseSpace(expected=5.0)
    optimal, humor = space.find_optimal([1.0, 3.0, 5.0, 7.0, 10.0])
    print(f"Optimal punchline: {optimal}, humor: {humor}")
    
    joke = IRJoke(incongruity=8.0, resolution=0.3)
    print(f"IR Joke: type={joke.joke_type}, net_humor={joke.net_humor}")
    
    print(f"Uniform entropy (n=8): {compute_uniform_entropy(8):.4f} bits")
    
    routine = analyze_comedy_routine([3.0, 5.0, 7.0, 2.0, 9.0])
    print(f"Routine analysis: {routine}")
