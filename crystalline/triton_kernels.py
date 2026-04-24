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
    if not TRITON_AVAILABLE or not A.is_cuda:
        # Fallback to PyTorch implementation
        return torch.min(A.unsqueeze(-1) + B.unsqueeze(0), dim=1)[0]

    M, K = A.shape
    K2, N = B.shape
    assert K == K2, "Inner dimensions must match"

    # Ensure contiguous and float32 for Triton
    A = A.contiguous().float()
    B = B.contiguous().float()
    C = torch.empty(M, N, device=A.device, dtype=torch.float32)

    # Launch kernel
    grid = (triton.cdiv(M, BLOCK_SIZE), triton.cdiv(N, BLOCK_SIZE))
    _tropical_matmul_kernel[grid](
        A, B, C,
        M, N, K,
        A.stride(0), A.stride(1),
        B.stride(0), B.stride(1),
        C.stride(0), C.stride(1),
        BLOCK_SIZE=BLOCK_SIZE,
    )
    return C.to(A.dtype)


@triton.jit
def _tropical_matmul_kernel(
    A_ptr, B_ptr, C_ptr,
    M, N, K,
    stride_am, stride_ak,
    stride_bk, stride_bn,
    stride_cm, stride_cn,
    BLOCK_SIZE: tl.constexpr,
):
    """Tropical matmul kernel: C[m,n] = min_k(A[m,k] + B[k,n]).

    Each block computes a tile of C by iterating over K and accumulating
    the tropical product incrementally (no large intermediate tensor).
    """
    pid_m = tl.program_id(0)
    pid_n = tl.program_id(1)

    offs_m = pid_m * BLOCK_SIZE + tl.arange(0, BLOCK_SIZE)
    offs_n = pid_n * BLOCK_SIZE + tl.arange(0, BLOCK_SIZE)

    # Initialize accumulator with +inf
    acc = tl.full((BLOCK_SIZE, BLOCK_SIZE), float('inf'), dtype=tl.float32)

    # Iterate over K dimension, loading one column of A and one row of B at a time
    for k in range(0, K):
        # Load A column: A[m, k] for m in offs_m
        a_ptrs = A_ptr + offs_m * stride_am + k * stride_ak
        a_mask = offs_m < M
        a_col = tl.load(a_ptrs, mask=a_mask, other=float('inf'))

        # Load B row: B[k, n] for n in offs_n
        b_ptrs = B_ptr + k * stride_bk + offs_n * stride_bn
        b_mask = offs_n < N
        b_row = tl.load(b_ptrs, mask=b_mask, other=float('inf'))

        # Tropical multiply: broadcast a_col (BLOCK,) and b_row (BLOCK,)
        # to (BLOCK, BLOCK), then element-wise minimum with accumulator
        prod = tl.expand_dims(a_col, 1) + tl.expand_dims(b_row, 0)
        acc = tl.minimum(acc, prod)

    # Store output tile
    c_ptrs = C_ptr + offs_m[:, None] * stride_cm + offs_n[None, :] * stride_cn
    c_mask = (offs_m[:, None] < M) & (offs_n[None, :] < N)
    tl.store(c_ptrs, acc, mask=c_mask)


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
