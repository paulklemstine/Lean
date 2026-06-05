#!/usr/bin/env python3
"""
Algorithms for Spectral Graph Theory and Neural Network Robustness

Type-hinted implementations of the core algorithms from the research.
"""

from dataclasses import dataclass
import math
from typing import Optional


@dataclass
class GraphSpectralData:
    """Spectral data of a computation graph.

    Attributes:
        num_verts: Number of vertices in the graph.
        alg_conn: Algebraic connectivity (Fiedler value, lambda_2).
        max_deg: Maximum vertex degree.
    """
    num_verts: int
    alg_conn: float
    max_deg: float

    def __post_init__(self) -> None:
        assert self.num_verts >= 1, "Must have at least 1 vertex"
        assert self.alg_conn >= 0, "Algebraic connectivity must be non-negative"
        assert self.max_deg > 0, "Max degree must be positive"
        assert self.alg_conn <= self.max_deg, "Algebraic connectivity cannot exceed max degree"


@dataclass
class NeuralLayer:
    """A neural network layer with known Lipschitz constant.

    Attributes:
        lip_const: The Lipschitz constant (operator norm) of the layer.
    """
    lip_const: float

    def __post_init__(self) -> None:
        assert self.lip_const > 0, "Lipschitz constant must be positive"


def contraction_factor(graph: GraphSpectralData) -> float:
    """Compute the spectral contraction factor c = 1 - lambda_2 / d_max.

    The contraction factor measures how much a single graph smoothing
    step reduces signal variation. It lies in [0, 1].

    Args:
        graph: Spectral data of the computation graph.

    Returns:
        The contraction factor c in [0, 1].
    """
    return 1.0 - graph.alg_conn / graph.max_deg


def network_lipschitz(layers: list[NeuralLayer]) -> float:
    """Compute the Lipschitz constant of a multi-layer network.

    By the chain rule for Lipschitz functions, the Lipschitz constant
    of a composition is bounded by the product of individual constants.

    Args:
        layers: List of neural network layers.

    Returns:
        The product of layer Lipschitz constants.
    """
    result = 1.0
    for layer in layers:
        result *= layer.lip_const
    return result


def iterated_smoothing_lipschitz(
    graph: GraphSpectralData, base_lip: float, k: int
) -> float:
    """Compute the effective Lipschitz constant after k smoothing iterations.

    After k applications of graph smoothing with contraction factor c,
    the Lipschitz constant becomes c^k * L.

    Args:
        graph: Spectral data of the computation graph.
        base_lip: The base Lipschitz constant L of the network.
        k: Number of smoothing iterations.

    Returns:
        The effective Lipschitz constant c^k * L.
    """
    c = contraction_factor(graph)
    return (c ** k) * base_lip


def certified_robustness_radius(margin: float, lipschitz: float) -> float:
    """Compute the certified robustness radius = margin / L.

    Given a classification margin m > 0 and Lipschitz constant L > 0,
    any perturbation with norm < m/L preserves the classification.

    Args:
        margin: The classification margin (score gap).
        lipschitz: The Lipschitz constant of the network.

    Returns:
        The certified robustness radius m/L, or inf if L = 0.
    """
    if lipschitz <= 0:
        return float('inf') if margin > 0 else 0.0
    return margin / lipschitz


def spectral_robustness_radius(
    graph: GraphSpectralData,
    margin: float,
    base_lip: float,
    smoothing_steps: int = 1,
) -> float:
    """Compute certified robustness radius with spectral smoothing.

    Combines graph spectral smoothing with Lipschitz certification:
    radius = margin / (c^k * L)

    Args:
        graph: Spectral data of the computation graph.
        margin: Classification margin.
        base_lip: Base Lipschitz constant.
        smoothing_steps: Number of graph smoothing iterations.

    Returns:
        The spectral-enhanced certified robustness radius.
    """
    eff_lip = iterated_smoothing_lipschitz(graph, base_lip, smoothing_steps)
    return certified_robustness_radius(margin, eff_lip)


def optimal_smoothing_steps(
    graph: GraphSpectralData,
    target_improvement: float,
) -> int:
    """Compute the minimum smoothing steps for a target robustness improvement.

    Given a target improvement factor (e.g., 10x), compute the minimum
    number of smoothing iterations k such that 1/c^k >= target.

    Args:
        graph: Spectral data of the computation graph.
        target_improvement: Desired improvement factor (e.g., 10.0 for 10x).

    Returns:
        Minimum k such that c^k <= 1/target_improvement, or -1 if impossible.
    """
    c = contraction_factor(graph)
    if c <= 0:
        return 1  # Complete graph: one step achieves infinite improvement
    if c >= 1:
        return -1  # Disconnected graph: smoothing doesn't help

    # Need c^k <= 1/target, so k >= log(1/target) / log(c)
    k = math.ceil(math.log(1.0 / target_improvement) / math.log(c))
    return max(k, 1)


def robustness_improvement_factor(
    graph: GraphSpectralData, k: int
) -> float:
    """Compute the robustness improvement factor from k smoothing steps.

    The improvement factor is 1/c^k, representing how much the
    certified radius increases compared to no smoothing.

    Args:
        graph: Spectral data of the computation graph.
        k: Number of smoothing iterations.

    Returns:
        The improvement factor 1/c^k.
    """
    c = contraction_factor(graph)
    if c <= 0:
        return float('inf') if k > 0 else 1.0
    return 1.0 / (c ** k)


def find_robustness_equivalent(
    target_ratio: float,
    candidate_max_degs: list[float],
) -> list[tuple[float, float]]:
    """Find graphs with the same robustness as a target ratio.

    By the duality theorem, graphs with the same lambda_2/d_max ratio
    are robustness-equivalent. This function finds (lambda_2, d_max)
    pairs with the given ratio.

    Args:
        target_ratio: The target lambda_2/d_max ratio.
        candidate_max_degs: List of candidate max degrees.

    Returns:
        List of (lambda_2, d_max) pairs with the target ratio.
    """
    return [(target_ratio * d, d) for d in candidate_max_degs]


def depth_width_tradeoff(
    graph: GraphSpectralData,
    margin: float,
    layer_lip: float,
    depth: int,
    smoothing_steps: int,
) -> dict[str, float]:
    """Analyze the depth-width-robustness tradeoff.

    For a network with `depth` layers each having Lipschitz constant
    `layer_lip`, and `smoothing_steps` graph smoothing iterations,
    compute the certified radius and related quantities.

    Args:
        graph: Spectral data of the computation graph.
        margin: Classification margin.
        layer_lip: Per-layer Lipschitz constant.
        depth: Number of network layers.
        smoothing_steps: Number of smoothing iterations.

    Returns:
        Dictionary with analysis results.
    """
    c = contraction_factor(graph)
    base_lip = layer_lip ** depth
    eff_lip = (c ** smoothing_steps) * base_lip
    radius = certified_robustness_radius(margin, eff_lip)

    return {
        "contraction_factor": c,
        "base_lipschitz": base_lip,
        "effective_lipschitz": eff_lip,
        "certified_radius": radius,
        "improvement_factor": robustness_improvement_factor(graph, smoothing_steps),
        "depth": depth,
        "smoothing_steps": smoothing_steps,
    }


if __name__ == "__main__":
    # Quick self-test
    g = GraphSpectralData(num_verts=10, alg_conn=2.0, max_deg=4.0)
    assert abs(contraction_factor(g) - 0.5) < 1e-10
    assert abs(iterated_smoothing_lipschitz(g, 100.0, 2) - 25.0) < 1e-10
    assert abs(certified_robustness_radius(1.0, 25.0) - 0.04) < 1e-10
    print("All self-tests passed.")
