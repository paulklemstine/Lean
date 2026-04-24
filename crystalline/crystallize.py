"""Crystallization: pushing weights to discrete integer states.

Inspired by CrystallizationTheory.lean and NeuralCrystallizerFrontier.lean:
- crystal_error_bound: rounding error <= 1/2
- total_crystal_error: bounded by n/2 for n weights
- crystal_penalty_zero_at_int: sin^2(pi*w) vanishes at integers
"""

import math

import torch
import torch.nn as nn


def crystallization_penalty(weights: torch.Tensor) -> torch.Tensor:
    """Penalty that vanishes exactly at integer values.

    Uses sin^2(pi * w) so that loss is 0 at w ∈ Z and grows smoothly elsewhere.
    Reference: crystal_penalty_zero_at_int theorem.
    """
    return torch.sum(torch.sin(math.pi * weights) ** 2)


def sheffer_nand(a: torch.Tensor, b: torch.Tensor) -> torch.Tensor:
    """Sheffer stroke (NAND) — functionally complete boolean operation.

    NAND(a, b) = NOT(a AND b) = 1 - a*b
    For crystallized values in {0, 1}, this yields {1, 1, 1, 0}.
    """
    return 1.0 - a * b


def tropical_to_sheffer(weights: torch.Tensor, threshold: float = 0.5) -> torch.Tensor:
    """Map tropical (real-valued) weights to Sheffer boolean values {0, 1}.

    Values with |w| < threshold map to 0, others map to 1.
    """
    return (torch.abs(weights) >= threshold).float()


def crystallize_tensor(tensor: torch.Tensor) -> torch.Tensor:
    """Round tensor values to nearest integer in {-1, 0, 1}.

    This is the crystallization operation: snap weights to discrete states.
    """
    with torch.no_grad():
        rounded = torch.round(tensor)
        # Clamp to {-1, 0, 1}
        rounded = torch.clamp(rounded, -1.0, 1.0)
        tensor.copy_(rounded)
    return tensor


def crystallize_module(module: nn.Module) -> None:
    """Apply crystallization to all parameters of a module in-place."""
    for p in module.parameters():
        crystallize_tensor(p)
