from typing import List, Tuple

def rg_orbit(t: float, lam: float, N: int) -> List[Tuple[float, float]]:
    """RG orbit on S^1: (RG_lam)^n(sigma(t)) = sigma(lam^n * t)."""
    orbit: List[Tuple[float, float]] = []
    for n in range(N + 1):
        s: float = (lam ** n) * t
        d: float = 1.0 + s * s
        orbit.append((2.0 * s / d, (1.0 - s * s) / d))
    return orbit

if __name__ == "__main__":
    for p in rg_orbit(0.3, 1.7, 6):
        print(f"({p[0]:+.6f}, {p[1]:+.6f})  norm={p[0]**2 + p[1]**2:.10f}")
