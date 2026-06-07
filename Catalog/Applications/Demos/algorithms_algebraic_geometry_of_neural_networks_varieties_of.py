#!/usr/bin/env python3
"""
Algorithms for Tropical Neural Variety Analysis

Type-hinted implementations of the core algorithms for analyzing
ReLU neural network decision boundaries as tropical varieties.
"""

from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass
import math


@dataclass
class NeuralArchitecture:
    """Specifies a ReLU network architecture by layer widths."""
    input_dim: int
    hidden_widths: List[int]
    output_dim: int

    @property
    def depth(self) -> int:
        """Number of hidden layers."""
        return len(self.hidden_widths)

    @property
    def total_width(self) -> int:
        """Sum of all hidden layer widths."""
        return sum(self.hidden_widths)

    @property
    def width_product(self) -> int:
        """Product of hidden layer widths (tropical degree)."""
        result = 1
        for w in self.hidden_widths:
            result *= w
        return result


@dataclass
class TropicalNeuralComplex:
    """
    The Tropical Neural Complex: a combinatorial structure encoding
    the algebraic-geometric properties of a ReLU network's decision boundary.

    Novel mathematical structure introduced in this research.
    """
    arch: NeuralArchitecture

    @property
    def folding_number(self) -> int:
        """Maximum number of linear regions = 2^(total width)."""
        return 2 ** self.arch.total_width

    @property
    def tropical_degree(self) -> int:
        """Tropical polynomial degree = product of layer widths."""
        return self.arch.width_product

    @property
    def boundary_facet_bound(self) -> int:
        """Maximum codimension-1 facets of the decision boundary."""
        return self.folding_number - 1

    @property
    def singularity_bound(self) -> int:
        """Maximum singular points on the decision boundary."""
        result = 1
        for w in self.arch.hidden_widths:
            result *= math.comb(w, 2)
        return result

    @property
    def spectral_gap(self) -> float:
        """Tropical spectral gap measuring depth advantage."""
        if not self.arch.hidden_widths:
            return 0.0
        L = self.arch.depth
        avg_w = self.arch.total_width / L
        if avg_w <= 1:
            return 0.0
        return L * math.log2(avg_w) - math.log2(L * avg_w)


def compose_complexes(c1: TropicalNeuralComplex,
                       c2: TropicalNeuralComplex) -> TropicalNeuralComplex:
    """
    Compose two tropical neural complexes (stack networks).

    Theorem (proved in Lean): composition multiplies both
    folding numbers and tropical degrees.
    """
    combined_arch = NeuralArchitecture(
        input_dim=c1.arch.input_dim,
        hidden_widths=c1.arch.hidden_widths + c2.arch.hidden_widths,
        output_dim=c2.arch.output_dim
    )
    return TropicalNeuralComplex(arch=combined_arch)


def optimal_depth_for_budget(total_width: int, min_layer_width: int = 2) -> Tuple[int, List[int]]:
    """
    Find the depth that maximizes tropical degree for a given total width budget.

    By AM-GM, equal layer widths maximize the product.
    The optimal depth L satisfies w = W/L, maximizing (W/L)^L.
    The maximum of x^(W/x) occurs at x = W/e, so optimal depth ≈ W/e.

    Returns (optimal_depth, optimal_widths).
    """
    best_degree = 0
    best_config: Tuple[int, List[int]] = (1, [total_width])

    for L in range(1, total_width + 1):
        w = total_width // L
        if w < min_layer_width:
            break
        remainder = total_width - w * L
        widths = [w] * L
        # Distribute remainder
        for i in range(remainder):
            widths[i] += 1

        degree = 1
        for wi in widths:
            degree *= wi

        if degree > best_degree:
            best_degree = degree
            best_config = (L, widths)

    return best_config


def depth_width_tradeoff_table(total_width: int) -> List[Dict[str, float]]:
    """
    Generate a table showing the depth-width tradeoff for a fixed total width.

    Returns list of dicts with keys: depth, width_per_layer, tropical_degree,
    folding_number, spectral_gap, efficiency_ratio.
    """
    results = []
    for L in range(1, total_width + 1):
        w = total_width // L
        if w < 1:
            break
        arch = NeuralArchitecture(input_dim=2, hidden_widths=[w] * L, output_dim=1)
        tnc = TropicalNeuralComplex(arch=arch)

        results.append({
            'depth': L,
            'width_per_layer': w,
            'tropical_degree': tnc.tropical_degree,
            'folding_number': tnc.folding_number,
            'spectral_gap': tnc.spectral_gap,
            'efficiency_ratio': tnc.tropical_degree / max(1, L * w),
        })
    return results


def analyze_architecture(arch: NeuralArchitecture) -> Dict[str, float]:
    """
    Complete analysis of a neural architecture's tropical properties.

    Returns a dictionary with all computed invariants.
    """
    tnc = TropicalNeuralComplex(arch=arch)
    return {
        'depth': arch.depth,
        'total_width': arch.total_width,
        'folding_number': tnc.folding_number,
        'tropical_degree': tnc.tropical_degree,
        'boundary_facet_bound': tnc.boundary_facet_bound,
        'singularity_bound': tnc.singularity_bound,
        'spectral_gap': tnc.spectral_gap,
        'log2_tropical_degree': math.log2(tnc.tropical_degree) if tnc.tropical_degree > 0 else 0,
        'log2_folding_number': math.log2(tnc.folding_number) if tnc.folding_number > 0 else 0,
    }


def compare_architectures(archs: List[NeuralArchitecture]) -> List[Dict[str, float]]:
    """Compare multiple architectures on all tropical invariants."""
    return [analyze_architecture(arch) for arch in archs]


# ---- Activation Pattern Algorithms ----

ActivationPattern = Tuple[bool, ...]
FullPattern = Tuple[ActivationPattern, ...]


def enumerate_activation_patterns(width: int) -> List[ActivationPattern]:
    """Enumerate all 2^w activation patterns for a layer of width w."""
    if width == 0:
        return [()]
    patterns = []
    for i in range(2 ** width):
        pattern = tuple(bool((i >> j) & 1) for j in range(width))
        patterns.append(pattern)
    return patterns


def pattern_distance(p1: ActivationPattern, p2: ActivationPattern) -> int:
    """Hamming distance between two activation patterns."""
    return sum(a != b for a, b in zip(p1, p2))


def adjacent_patterns(p: ActivationPattern) -> List[ActivationPattern]:
    """Get all patterns that differ in exactly one neuron (Hamming distance 1)."""
    result = []
    for i in range(len(p)):
        flipped = list(p)
        flipped[i] = not flipped[i]
        result.append(tuple(flipped))
    return result


def boundary_graph_edges(widths: List[int]) -> int:
    """
    Count the number of boundary-crossing edges in the activation pattern graph.

    Each edge connects two patterns differing in one neuron, representing
    a potential decision boundary facet.

    Theorem (proved): This equals total_width * 2^(total_width - 1).
    """
    W = sum(widths)
    if W == 0:
        return 0
    return W * (2 ** (W - 1))


if __name__ == "__main__":
    # Example: Compare common architectures
    archs = [
        NeuralArchitecture(2, [8], 1),
        NeuralArchitecture(2, [4, 4], 1),
        NeuralArchitecture(2, [2, 2, 2, 2], 1),
        NeuralArchitecture(2, [16], 1),
        NeuralArchitecture(2, [4, 4, 4, 4], 1),
    ]

    print("Architecture Comparison:")
    print(f"{'Config':<20} {'Depth':>6} {'TotW':>6} {'TropDeg':>10} {'FoldNum':>12} {'Gap':>8}")
    print("-" * 65)

    for arch in archs:
        info = analyze_architecture(arch)
        config = f"{arch.input_dim}→{'→'.join(str(w) for w in arch.hidden_widths)}→{arch.output_dim}"
        print(f"{config:<20} {info['depth']:>6.0f} {info['total_width']:>6.0f} "
              f"{info['tropical_degree']:>10.0f} {info['folding_number']:>12.0f} "
              f"{info['spectral_gap']:>8.2f}")

    print("\nOptimal depth for budget W=16:")
    opt_depth, opt_widths = optimal_depth_for_budget(16)
    print(f"  Depth = {opt_depth}, Widths = {opt_widths}, "
          f"Tropical Degree = {math.prod(opt_widths)}")
