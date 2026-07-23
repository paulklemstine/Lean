from __future__ import annotations
import math

def cf_quadratic_surd(P0: int, N: int, Q0: int, n_terms: int = 200) -> list[int]:
    """Exact partial quotients of x = (P0 + sqrt N)/Q0 (N not a perfect square)."""
    if (N - P0 * P0) % Q0 != 0:                      # normalize so Q0 | (N - P0^2)
        P0, N, Q0 = P0 * abs(Q0), N * Q0 * Q0, Q0 * abs(Q0)
    a: list[int] = []
    P, Q = P0, Q0
    s = math.isqrt(N)                                # floor(sqrt N), exact
    for _ in range(n_terms):
        ai = (P + s) // Q if Q > 0 else -((-P - s - 1) // (-Q))
        a.append(ai)
        P = ai * Q - P
        Q = (N - P * P) // Q
    return a

def _tail(a: list[int]) -> float:
    v = float(a[-1])
    for ai in reversed(a[:-1]):
        v = ai + 1.0 / v
    return v

def lagrange_constant(a: list[int]) -> float:
    """k(x) = 1 / limsup_i ([a_i; a_{i+1}, ...] + [0; a_{i-1}, ..., a_1])."""
    best = 0.0
    for i in range(len(a) // 4, 3 * len(a) // 4):
        best = max(best, _tail(a[i:]) + _tail([0] + a[1:i][::-1]))
    return 1.0 / best
