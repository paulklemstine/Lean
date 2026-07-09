from typing import List

def cheb_U(k: int, x: float) -> float:
    """Evaluate the Chebyshev polynomial of the second kind U_k(x) via the
    numerically stable three-term recurrence
        U_0 = 1,  U_1 = 2x,  U_{k+1} = 2x U_k - U_{k-1}.
    Runs in O(k) arithmetic operations and O(1) memory.
    """
    if k < 0:
        raise ValueError("k must be nonnegative")
    u_prev, u_curr = 1.0, 2.0 * x
    if k == 0:
        return u_prev
    if k == 1:
        return u_curr
    for _ in range(2, k + 1):
        u_prev, u_curr = u_curr, 2.0 * x * u_curr - u_prev
    return u_curr

def verify_deligne_envelope(kmax: int, samples: int = 2000) -> bool:
    """Verify |U_k(x)| <= k+1 for 0 <= k <= kmax on a grid of [-1, 1]."""
    grid: List[float] = [-1.0 + 2.0 * i / samples for i in range(samples + 1)]
    for k in range(kmax + 1):
        if max(abs(cheb_U(k, x)) for x in grid) > (k + 1) + 1e-9:
            return False
    return True
