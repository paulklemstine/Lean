#!/usr/bin/env python3
"""
Algorithms for Tropical Compression Dominance

Implements the core algorithms from the research paper:
1. Quotient complexity computation for arbitrary architecture descriptors
2. Architecture comparison via quotient complexity
3. Sample complexity bound evaluation
4. Compression gain analysis
5. Conjecture verification pipeline

All algorithms have O(L) time complexity where L is the number of layers.
"""

import math
from dataclasses import dataclass, field
from typing import List, Optional, Tuple


@dataclass
class LayerDescriptor:
    """Descriptor for a single layer in a neural network architecture.

    Attributes:
        name: Human-readable name for the layer
        param_dim: Raw parameter count for this layer
        group_order: Order of the symmetry group acting on this layer's parameters
        description: Optional description of the symmetry
    """
    name: str
    param_dim: int
    group_order: int = 1
    description: str = ""

    def __post_init__(self):
        if self.group_order <= 0:
            raise ValueError(f"Group order must be positive, got {self.group_order}")
        if self.param_dim < 0:
            raise ValueError(f"Parameter dimension must be non-negative, got {self.param_dim}")

    @property
    def quotient_complexity(self) -> int:
        """Quotient complexity of this layer: floor(d / |G|)."""
        return self.param_dim // self.group_order

    @property
    def compression_gain(self) -> int:
        """Parameters eliminated by symmetry in this layer."""
        return self.param_dim - self.quotient_complexity


@dataclass
class ArchitectureDescriptor:
    """Complete architecture descriptor as a sequence of layers.

    Attributes:
        name: Architecture name
        layers: List of layer descriptors
    """
    name: str
    layers: List[LayerDescriptor] = field(default_factory=list)

    def add_layer(self, layer: LayerDescriptor) -> 'ArchitectureDescriptor':
        """Add a layer and return self for chaining."""
        self.layers.append(layer)
        return self

    @property
    def total_param_dim(self) -> int:
        """Total raw parameter count across all layers."""
        return sum(l.param_dim for l in self.layers)

    @property
    def total_quotient_complexity(self) -> int:
        """Total quotient complexity (sum of per-layer quotient complexities)."""
        return sum(l.quotient_complexity for l in self.layers)

    @property
    def total_compression_gain(self) -> int:
        """Total parameters eliminated by symmetry."""
        return self.total_param_dim - self.total_quotient_complexity

    @property
    def compression_ratio(self) -> float:
        """Overall compression ratio d / Cq."""
        cq = self.total_quotient_complexity
        if cq == 0:
            return float('inf')
        return self.total_param_dim / cq


def compute_sample_complexity_bound(d: int, eps: float, delta: float) -> float:
    """
    Compute the algebraic sample complexity bound.

    SC(d, ε, δ) = d · log(1/ε) + log(1/δ)

    Args:
        d: Effective dimension (parameter count or quotient complexity)
        eps: Target accuracy (0 < eps < 1)
        delta: Target confidence parameter (0 < delta < 1)

    Returns:
        Sample complexity bound as a float

    Raises:
        ValueError: If eps or delta are out of range
    """
    if not (0 < eps < 1):
        raise ValueError(f"eps must be in (0,1), got {eps}")
    if not (0 < delta < 1):
        raise ValueError(f"delta must be in (0,1), got {delta}")
    return d * math.log(1.0 / eps) + math.log(1.0 / delta)


def analyze_architecture(
    arch: ArchitectureDescriptor,
    eps: float = 0.01,
    delta: float = 0.05,
) -> dict:
    """
    Complete analysis of an architecture's compression properties.

    Algorithm 5.1 from the paper.

    Args:
        arch: Architecture descriptor
        eps: Target accuracy
        delta: Target confidence

    Returns:
        Dictionary with all computed quantities
    """
    d = arch.total_param_dim
    cq = arch.total_quotient_complexity
    gain = arch.total_compression_gain

    sc_raw = compute_sample_complexity_bound(d, eps, delta)
    sc_compressed = compute_sample_complexity_bound(cq, eps, delta)
    sc_improvement = sc_raw - sc_compressed

    return {
        'name': arch.name,
        'total_param_dim': d,
        'total_quotient_complexity': cq,
        'compression_gain': gain,
        'compression_ratio': arch.compression_ratio,
        'sc_raw': sc_raw,
        'sc_compressed': sc_compressed,
        'sc_improvement': sc_improvement,
        'improvement_factor': sc_raw / sc_compressed if sc_compressed > 0 else float('inf'),
        'layers': [
            {
                'name': l.name,
                'param_dim': l.param_dim,
                'group_order': l.group_order,
                'quotient_complexity': l.quotient_complexity,
                'compression_gain': l.compression_gain,
            }
            for l in arch.layers
        ],
    }


def compare_architectures(
    arch1: ArchitectureDescriptor,
    arch2: ArchitectureDescriptor,
    eps: float = 0.01,
    delta: float = 0.05,
) -> dict:
    """
    Compare two architectures using quotient complexity.

    Algorithm 5.2 from the paper.

    Args:
        arch1, arch2: Architecture descriptors to compare
        eps, delta: Sample complexity parameters

    Returns:
        Comparison results including predicted ranking
    """
    a1 = analyze_architecture(arch1, eps, delta)
    a2 = analyze_architecture(arch2, eps, delta)

    cq1 = a1['total_quotient_complexity']
    cq2 = a2['total_quotient_complexity']

    if cq1 < cq2:
        prediction = f"{arch1.name} generalizes better"
        confidence = cq2 / cq1 if cq1 > 0 else float('inf')
    elif cq2 < cq1:
        prediction = f"{arch2.name} generalizes better"
        confidence = cq1 / cq2 if cq2 > 0 else float('inf')
    else:
        prediction = "Inconclusive (equal quotient complexity)"
        confidence = 1.0

    return {
        'arch1': a1,
        'arch2': a2,
        'prediction': prediction,
        'confidence_ratio': confidence,
    }


def verify_compression_dominance_conjecture(
    architectures: List[ArchitectureDescriptor],
    eps: float = 0.01,
    delta: float = 0.05,
) -> List[dict]:
    """
    Verify the Tropical Compression Dominance conjecture for a list of architectures.

    For each architecture, checks whether:
      SC(d) / SC(d/|G|) ≥ |G| / log(d)

    Args:
        architectures: List of architecture descriptors
        eps, delta: Sample complexity parameters

    Returns:
        List of verification results, one per architecture
    """
    results = []
    for arch in architectures:
        d = arch.total_param_dim
        cq = arch.total_quotient_complexity
        g_eff = d // cq if cq > 0 else d  # Effective group order

        sc_raw = compute_sample_complexity_bound(d, eps, delta)
        sc_comp = compute_sample_complexity_bound(cq, eps, delta) if cq > 0 else 0

        if sc_comp > 0:
            ratio = sc_raw / sc_comp
        else:
            ratio = float('inf')

        threshold = g_eff / math.log(d) if d > 1 else float('inf')
        passed = ratio >= threshold

        results.append({
            'name': arch.name,
            'param_dim': d,
            'quotient_complexity': cq,
            'effective_group_order': g_eff,
            'sc_ratio': ratio,
            'threshold': threshold,
            'conjecture_holds': passed,
        })

    return results


# === Factory functions for common architectures ===

def make_cnn_architecture(
    n: int, k: int, num_channels: int = 1, num_layers: int = 1,
) -> ArchitectureDescriptor:
    """
    Create a CNN architecture descriptor.

    Args:
        n: Spatial resolution (n×n image)
        k: Kernel size (k×k kernel)
        num_channels: Number of input/output channels per layer
        num_layers: Number of convolutional layers

    Returns:
        ArchitectureDescriptor for the CNN
    """
    arch = ArchitectureDescriptor(
        name=f"CNN({n}×{n}, {k}×{k}, ch={num_channels}, L={num_layers})"
    )
    for i in range(num_layers):
        arch.add_layer(LayerDescriptor(
            name=f"Conv layer {i+1}",
            param_dim=n**2 * k**2 * num_channels**2,
            group_order=n**2,
            description=f"Translation symmetry on {n}×{n} grid",
        ))
    return arch


def make_equivariant_mlp(n: int, num_layers: int = 1) -> ArchitectureDescriptor:
    """
    Create a permutation-equivariant MLP architecture descriptor.

    Args:
        n: Number of input elements
        num_layers: Number of equivariant layers

    Returns:
        ArchitectureDescriptor for the equivariant MLP
    """
    arch = ArchitectureDescriptor(name=f"EquivMLP(n={n}, L={num_layers})")
    for i in range(num_layers):
        arch.add_layer(LayerDescriptor(
            name=f"Equivariant layer {i+1}",
            param_dim=n**2,
            group_order=math.factorial(n),
            description=f"S_{n} permutation symmetry",
        ))
    return arch


def make_attention_architecture(
    num_heads: int, d_k: int, d_model: int = 512,
) -> ArchitectureDescriptor:
    """
    Create a multi-head attention architecture descriptor.

    Args:
        num_heads: Number of attention heads
        d_k: Key/query dimension per head
        d_model: Model dimension

    Returns:
        ArchitectureDescriptor for the attention layer
    """
    arch = ArchitectureDescriptor(
        name=f"Attention(h={num_heads}, d_k={d_k}, d_model={d_model})"
    )
    # Q, K, V projections: each is d_model × d_k per head
    qkv_params = 3 * num_heads * d_model * d_k
    arch.add_layer(LayerDescriptor(
        name="QKV projections",
        param_dim=qkv_params,
        group_order=math.factorial(num_heads),
        description=f"S_{num_heads} head permutation symmetry",
    ))
    # Output projection: h * d_k × d_model
    arch.add_layer(LayerDescriptor(
        name="Output projection",
        param_dim=num_heads * d_k * d_model,
        group_order=math.factorial(num_heads),
        description=f"S_{num_heads} head permutation symmetry",
    ))
    return arch


if __name__ == "__main__":
    print("=== Algorithm Demo ===\n")

    # Demo: Analyze a multi-layer CNN
    cnn = make_cnn_architecture(n=32, k=3, num_channels=64, num_layers=3)
    result = analyze_architecture(cnn)
    print(f"Architecture: {result['name']}")
    print(f"  Total parameters:        {result['total_param_dim']:>12,}")
    print(f"  Quotient complexity:      {result['total_quotient_complexity']:>12,}")
    print(f"  Compression ratio:        {result['compression_ratio']:>12.1f}")
    print(f"  SC improvement:           {result['sc_improvement']:>12.1f}")
    print()

    # Demo: Compare CNN vs fully-connected
    fc = ArchitectureDescriptor(name="Fully Connected")
    fc.add_layer(LayerDescriptor("FC layer", param_dim=cnn.total_param_dim, group_order=1))

    comparison = compare_architectures(cnn, fc)
    print(f"Comparison: {comparison['prediction']}")
    print(f"  Confidence ratio: {comparison['confidence_ratio']:.1f}x")
    print()

    # Demo: Verify conjecture
    archs = [
        make_cnn_architecture(n, 3) for n in [8, 16, 32, 64, 128]
    ]
    results = verify_compression_dominance_conjecture(archs)
    print("Conjecture verification:")
    for r in results:
        status = "✓" if r['conjecture_holds'] else "✗"
        print(f"  {status} {r['name']}: ratio={r['sc_ratio']:.2f}, "
              f"threshold={r['threshold']:.2f}")
