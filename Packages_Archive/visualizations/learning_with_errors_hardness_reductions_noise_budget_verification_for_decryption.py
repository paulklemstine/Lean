from __future__ import annotations

def decryption_correct(q: float, B: float, n: int, delta: float) -> bool:
    """Check the noise-budget condition B + n*delta < q/4."""
    return B + n * delta < q / 4

def regev_decrypt(q: float, mu: int, e: float) -> int:
    v: float = (mu * (q / 2) + e) % q
    return 1 if q / 4 <= v < 3 * q / 4 else 0
