from __future__ import annotations
import mpmath as mp

def scattering_residue(num_terms: int = 8, precision: int = 40) -> float:
    """Estimate Res_{s=1} of the arithmetic factor zeta(2s-1).

    Uses the sequence s_k = 1 + 10**(-k) and returns the last iterate of
    (s-1)*zeta(2s-1), which converges to 1/2.
    """
    mp.mp.dps = precision
    value = mp.mpf(0)
    for k in range(1, num_terms + 1):
        s = mp.mpf(1) + mp.mpf(10) ** (-k)
        value = (s - 1) * mp.zeta(2 * s - 1)
    return float(value)

if __name__ == "__main__":
    print("estimated residue:", scattering_residue())
