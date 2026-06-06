#!/usr/bin/env python3
"""
Algorithms for Tropical Activation Complex computation and analysis.

Type-hinted implementations of all algorithms from the research paper.
"""

from math import comb, prod, log2, floor, ceil
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


@dataclass
class ReLUArchitecture:
    """A ReLU neural network architecture."""
    input_dim: int
    hidden_widths: List[int]

    @property
    def depth(self) -> int:
        return len(self.hidden_widths)

    @property
    def total_width(self) -> int:
        return sum(self.hidden_widths)

    @property
    def max_width(self) -> int:
        return max(self.hidden_widths) if self.hidden_widths else 0


@dataclass
class TropicalActivationComplex:
    """The Tropical Activation Complex (TAC) — a novel mathematical structure
    capturing the algebraic geometry of ReLU decision boundaries."""
    arch: ReLUArchitecture
    tropical_degree: int
    fold_number: int
    singularity_budget: int
    region_bound: int

    def verify_fundamental_theorem(self) -> Dict[str, bool]:
        """Verify all parts of the fundamental TAC inequality."""
        return {
            "degree_le_region": self.tropical_degree <= self.region_bound,
            "region_le_exp_fold": self.region_bound <= 2 ** self.fold_number,
            "singularity_le_fold_sq": self.singularity_budget <= self.fold_number ** 2,
        }

    def __repr__(self) -> str:
        return (f"TAC(arch=({self.arch.input_dim}; {self.arch.hidden_widths}), "
                f"deg={self.tropical_degree}, fold={self.fold_number}, "
                f"sing={self.singularity_budget}, regions={self.region_bound})")


def zaslavsky_bound(num_hyperplanes: int, dimension: int) -> int:
    """Compute the Zaslavsky bound: max regions from n hyperplanes in R^d.

    Z(n, d) = sum_{k=0}^{d} C(n, k)

    This is the maximum number of connected components that n hyperplanes
    in general position create in R^d.

    Args:
        num_hyperplanes: Number of hyperplanes (n)
        dimension: Ambient dimension (d)

    Returns:
        The Zaslavsky bound Z(n, d)
    """
    return sum(comb(num_hyperplanes, k) for k in range(dimension + 1))


def compute_tac(arch: ReLUArchitecture) -> TropicalActivationComplex:
    """Construct a Tropical Activation Complex from a ReLU architecture.

    Computes all four structural invariants:
    - Tropical degree: prod(w_i)
    - Fold number: sum(w_i)
    - Singularity budget: sum(C(w_i, 2))
    - Region bound: prod(Z(w_i, n))

    Args:
        arch: The ReLU network architecture

    Returns:
        The corresponding TAC
    """
    ws = arch.hidden_widths
    n = arch.input_dim

    return TropicalActivationComplex(
        arch=arch,
        tropical_degree=prod(ws) if ws else 1,
        fold_number=sum(ws),
        singularity_budget=sum(comb(w, 2) for w in ws),
        region_bound=prod(zaslavsky_bound(w, n) for w in ws) if ws else 1,
    )


def optimal_balanced_architecture(
    total_width: int, depth: int, input_dim: int
) -> Tuple[ReLUArchitecture, TropicalActivationComplex]:
    """Find the balanced architecture for given total width and depth.

    By the AM-GM theorem, the tropical degree is maximized when all
    layer widths are as equal as possible.

    Args:
        total_width: Total width W = sum(w_i)
        depth: Number of hidden layers L
        input_dim: Input dimension n

    Returns:
        Tuple of (optimal architecture, its TAC)
    """
    base = total_width // depth
    remainder = total_width % depth
    widths = [base + (1 if i < remainder else 0) for i in range(depth)]

    arch = ReLUArchitecture(input_dim=input_dim, hidden_widths=widths)
    return arch, compute_tac(arch)


def search_optimal_depth(
    total_width: int, input_dim: int, max_depth: Optional[int] = None
) -> Tuple[int, ReLUArchitecture, TropicalActivationComplex]:
    """Search for the depth that maximizes the region bound.

    Args:
        total_width: Total width W
        input_dim: Input dimension n
        max_depth: Maximum depth to search (defaults to total_width)

    Returns:
        Tuple of (optimal depth, architecture, TAC)
    """
    if max_depth is None:
        max_depth = total_width

    best_depth = 1
    best_arch, best_tac = optimal_balanced_architecture(total_width, 1, input_dim)
    best_regions = best_tac.region_bound

    for d in range(2, max_depth + 1):
        arch, tac = optimal_balanced_architecture(total_width, d, input_dim)
        if tac.region_bound > best_regions:
            best_regions = tac.region_bound
            best_depth = d
            best_arch = arch
            best_tac = tac

    return best_depth, best_arch, best_tac


def relu(x: float) -> float:
    """ReLU activation function: max(0, x)."""
    return max(0.0, x)


def relu_abs_formula(x: float) -> float:
    """ReLU via absolute value: (x + |x|) / 2."""
    return (x + abs(x)) / 2.0


def max_abs_formula(a: float, b: float) -> float:
    """Max via absolute value: (a + b + |a - b|) / 2."""
    return (a + b + abs(a - b)) / 2.0


def count_activation_patterns_1d(
    weights: List[float], biases: List[float], x_range: Tuple[float, float], num_samples: int = 10000
) -> int:
    """Count distinct activation patterns of a single ReLU layer on 1D input.

    Each neuron computes relu(w*x + b). The activation pattern records
    which neurons are active (w*x + b > 0) at each point.

    Args:
        weights: Layer weights
        biases: Layer biases
        x_range: Range of x values to sample
        num_samples: Number of sample points

    Returns:
        Number of distinct activation patterns observed
    """
    patterns = set()
    x_min, x_max = x_range

    for i in range(num_samples):
        x = x_min + (x_max - x_min) * i / (num_samples - 1)
        pattern = tuple(1 if w * x + b > 0 else 0 for w, b in zip(weights, biases))
        patterns.add(pattern)

    return len(patterns)


def amgm_bound(widths: List[int]) -> int:
    """Compute the AM-GM upper bound on tropical degree.

    prod(w_i) <= (sum(w_i) / L + 1)^L

    Args:
        widths: Layer widths

    Returns:
        The AM-GM upper bound
    """
    if not widths:
        return 1
    S = sum(widths)
    L = len(widths)
    return (S // L + 1) ** L


def depth_advantage_ratio(
    total_width: int, depth: int, input_dim: int
) -> float:
    """Compute the ratio of deep/shallow region bounds.

    Measures how much advantage depth gives over a single-layer network
    with the same total width.

    Args:
        total_width: Total width W
        depth: Number of layers L
        input_dim: Input dimension n

    Returns:
        Ratio deep_regions / shallow_regions
    """
    _, shallow_tac = optimal_balanced_architecture(total_width, 1, input_dim)
    _, deep_tac = optimal_balanced_architecture(total_width, depth, input_dim)

    if shallow_tac.region_bound == 0:
        return float('inf')
    return deep_tac.region_bound / shallow_tac.region_bound


if __name__ == "__main__":
    # Example usage
    arch = ReLUArchitecture(input_dim=2, hidden_widths=[4, 4, 4])
    tac = compute_tac(arch)
    print(f"Architecture: {arch}")
    print(f"TAC: {tac}")
    print(f"Fundamental theorem: {tac.verify_fundamental_theorem()}")
    print()

    # Optimal depth search
    opt_depth, opt_arch, opt_tac = search_optimal_depth(12, 3)
    print(f"Optimal depth for W=12, n=3: {opt_depth}")
    print(f"Architecture: {opt_arch}")
    print(f"Regions: {opt_tac.region_bound}")
