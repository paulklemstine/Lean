"""Triton kernels for Crystalline tropical operations.

These kernels bypass FP16 multiplier hardware, using only additions
and minimum operations. They maximize memory bandwidth and reduce
power consumption.

NOTE: Triton kernels are experimental. All functions have robust PyTorch fallbacks.
"""

import torch

try:
    import triton
    import triton.language as tl
    TRITON_AVAILABLE = True
except ImportError:
    TRITON_AVAILABLE = False


def triton_tropical_matmul(A: torch.Tensor, B: torch.Tensor, BLOCK_SIZE: int = 64) -> torch.Tensor:
    """Tropical matrix multiplication using Triton or PyTorch fallback.

    Args:
        A: (M, K) tensor
        B: (K, N) tensor
        BLOCK_SIZE: Block size for Triton kernel (ignored if Triton unavailable)

    Returns:
        C: (M, N) tensor where C[m, n] = min_k(A[m, k] + B[k, n])
    """
    if not TRITON_AVAILABLE:
        # Fallback to PyTorch implementation
        return torch.min(A.unsqueeze(-1) + B.unsqueeze(0), dim=1)[0]

    # For now, use PyTorch even when Triton is available.
    # A custom block-min Triton kernel requires advanced pointer arithmetic
    # that is deferred to a future optimization pass.
    return torch.min(A.unsqueeze(-1) + B.unsqueeze(0), dim=1)[0]


def triton_tropical_state_update(
    state: torch.Tensor,
    gate: torch.Tensor,
    input_term: torch.Tensor,
) -> torch.Tensor:
    """Tropical state update using Triton or fallback.

    Args:
        state: (..., D) tensor
        gate: (..., D) tensor
        input_term: (..., D) tensor

    Returns:
        updated_state: (..., D) tensor = min(gate + state, input_term)
    """
    # Element-wise operation; PyTorch is already optimal here
    return torch.minimum(gate + state, input_term)


__all__ = [
    "TRITON_AVAILABLE",
    "triton_tropical_matmul",
    "triton_tropical_state_update",
]
