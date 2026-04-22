"""
Triton kernels for tropical (min-plus) operations.

These kernels bypass FP16 multiplier hardware, using only additions
and minimum operations. They maximize memory bandwidth and reduce
power consumption.

Reference: TropicalNNCompilation.lean
"""

import torch

# Try to import triton; if unavailable, fall back to PyTorch
try:
    import triton
    import triton.language as tl
    TRITON_AVAILABLE = True
except ImportError:
    TRITON_AVAILABLE = False


if TRITON_AVAILABLE:
    @triton.jit
    def _tropical_matmul_kernel(
        A_ptr, B_ptr, C_ptr,
        M, N, K,
        stride_am, stride_ak,
        stride_bk, stride_bn,
        stride_cm, stride_cn,
        BLOCK_SIZE: tl.constexpr,
    ):
        """Triton kernel for tropical matrix multiplication.

        Computes C[m, n] = min_k(A[m, k] + B[k, n])
        """
        pid_m = tl.program_id(0)
        pid_n = tl.program_id(1)

        # Compute starting offsets for this block
        offs_m = pid_m * BLOCK_SIZE + tl.arange(0, BLOCK_SIZE)
        offs_n = pid_n * BLOCK_SIZE + tl.arange(0, BLOCK_SIZE)
        offs_k = tl.arange(0, BLOCK_SIZE)

        # Initialize accumulator with +inf
        acc = tl.full((BLOCK_SIZE, BLOCK_SIZE), float('inf'), dtype=tl.float32)

        # Pointers to A and B blocks
        a_ptrs = A_ptr + (offs_m[:, None] * stride_am + offs_k[None, :] * stride_ak)
        b_ptrs = B_ptr + (offs_k[:, None] * stride_bk + offs_n[None, :] * stride_bn)

        # Loop over K dimension in blocks
        for k in range(0, K, BLOCK_SIZE):
            # Load blocks of A and B
            a = tl.load(a_ptrs, mask=offs_k[None, :] < K - k, other=float('inf'))
            b = tl.load(b_ptrs, mask=offs_k[:, None] < K - k, other=float('inf'))

            # Tropical multiplication: addition
            # Then tropical addition: minimum
            ab = a[:, :, None] + b[None, :, :]  # (BLOCK, BLOCK, BLOCK)
            acc = tl.minimum(acc, tl.min(ab, axis=1))

            # Advance pointers
            a_ptrs += BLOCK_SIZE * stride_ak
            b_ptrs += BLOCK_SIZE * stride_bk

        # Store result
        c_ptrs = C_ptr + (offs_m[:, None] * stride_cm + offs_n[None, :] * stride_cn)
        tl.store(c_ptrs, acc, mask=(offs_m[:, None] < M) & (offs_n[None, :] < N))

    @triton.jit
    def _tropical_l1_distance_kernel(
        Q_ptr, K_ptr, Out_ptr,
        B, H, M, N, D,
        stride_qb, stride_qh, stride_qm, stride_qd,
        stride_kb, stride_kh, stride_kn, stride_kd,
        stride_ob, stride_oh, stride_om, stride_on,
        BLOCK_M: tl.constexpr,
        BLOCK_N: tl.constexpr,
        BLOCK_D: tl.constexpr,
    ):
        """Triton kernel for tropical L1 distance attention scores.

        Computes Out[b, h, m, n] = -sum_d(|Q[b, h, m, d] - K[b, h, n, d]|)
        """
        pid_bh = tl.program_id(0)
        pid_m = tl.program_id(1)
        pid_n = tl.program_id(2)

        pid_b = pid_bh // H
        pid_h = pid_bh % H

        offs_m = pid_m * BLOCK_M + tl.arange(0, BLOCK_M)
        offs_n = pid_n * BLOCK_N + tl.arange(0, BLOCK_N)
        offs_d = tl.arange(0, BLOCK_D)

        # Initialize accumulator
        acc = tl.zeros((BLOCK_M, BLOCK_N), dtype=tl.float32)

        # Pointers
        q_ptrs = Q_ptr + (
            pid_b * stride_qb + pid_h * stride_qh +
            offs_m[:, None] * stride_qm + offs_d[None, :] * stride_qd
        )
        k_ptrs = K_ptr + (
            pid_b * stride_kb + pid_h * stride_kh +
            offs_n[:, None] * stride_kn + offs_d[None, :] * stride_kd
        )

        # Loop over D dimension
        for d in range(0, D, BLOCK_D):
            q = tl.load(q_ptrs, mask=offs_d[None, :] < D - d, other=0.0)
            k = tl.load(k_ptrs, mask=offs_d[None, :] < D - d, other=0.0)

            # L1 distance: |q - k|
            diff = q[:, None, :] - k[None, :, :]  # (BLOCK_M, BLOCK_N, BLOCK_D)
            acc += tl.sum(tl.abs(diff), axis=2)

            q_ptrs += BLOCK_D * stride_qd
            k_ptrs += BLOCK_D * stride_kd

        # Negate for tropical dot product
        acc = -acc

        # Store
        o_ptrs = Out_ptr + (
            pid_b * stride_ob + pid_h * stride_oh +
            offs_m[:, None] * stride_om + offs_n[None, :] * stride_on
        )
        tl.store(o_ptrs, acc, mask=(offs_m[:, None] < M) & (offs_n[None, :] < N))


def triton_tropical_matmul(A: torch.Tensor, B: torch.Tensor, BLOCK_SIZE: int = 64) -> torch.Tensor:
    """Tropical matrix multiplication using Triton.

    Args:
        A: (M, K) tensor
        B: (K, N) tensor
        BLOCK_SIZE: Block size for Triton kernel

    Returns:
        C: (M, N) tensor where C[m, n] = min_k(A[m, k] + B[k, n])
    """
    if not TRITON_AVAILABLE:
        # Fallback to PyTorch implementation
        return torch.min(A.unsqueeze(1) + B.unsqueeze(0), dim=2)[0]

    M, K = A.shape
    K2, N = B.shape
    assert K == K2, "Inner dimensions must match"

    C = torch.empty(M, N, device=A.device, dtype=A.dtype)

    # Launch kernel
    grid = (
        (M + BLOCK_SIZE - 1) // BLOCK_SIZE,
        (N + BLOCK_SIZE - 1) // BLOCK_SIZE,
    )

    _tropical_matmul_kernel[grid](
        A, B, C,
        M, N, K,
        A.stride(0), A.stride(1),
        B.stride(0), B.stride(1),
        C.stride(0), C.stride(1),
        BLOCK_SIZE=BLOCK_SIZE,
    )

    return C


def triton_tropical_l1_distance(
    Q: torch.Tensor,
    K: torch.Tensor,
    BLOCK_M: int = 32,
    BLOCK_N: int = 32,
    BLOCK_D: int = 64,
) -> torch.Tensor:
    """Tropical L1 distance attention scores using Triton.

    Args:
        Q: (B, H, M, D) tensor
        K: (B, H, N, D) tensor

    Returns:
        Out: (B, H, M, N) tensor where Out[b, h, m, n] = -sum_d(|Q - K|)
    """
    if not TRITON_AVAILABLE:
        # Fallback to PyTorch implementation
        return -torch.sum(torch.abs(Q.unsqueeze(-2) - K.unsqueeze(-3)), dim=-1)

    B, H, M, D = Q.shape
    B2, H2, N, D2 = K.shape
    assert B == B2 and H == H2 and D == D2, "Dimensions must match"

    Out = torch.empty(B, H, M, N, device=Q.device, dtype=torch.float32)

    grid = (
        B * H,
        (M + BLOCK_M - 1) // BLOCK_M,
        (N + BLOCK_N - 1) // BLOCK_N,
    )

    _tropical_l1_distance_kernel[grid](
        Q, K, Out,
        B, H, M, N, D,
        Q.stride(0), Q.stride(1), Q.stride(2), Q.stride(3),
        K.stride(0), K.stride(1), K.stride(2), K.stride(3),
        Out.stride(0), Out.stride(1), Out.stride(2), Out.stride(3),
        BLOCK_M=BLOCK_M,
        BLOCK_N=BLOCK_N,
        BLOCK_D=BLOCK_D,
    )

    return Out


__all__ = [
    "TRITON_AVAILABLE",
    "triton_tropical_matmul",
    "triton_tropical_l1_distance",
    "_tropical_matmul_kernel",
    "_tropical_l1_distance_kernel",
]