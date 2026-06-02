#!/usr/bin/env python3
"""
Algorithms for Holographic Code Construction and Analysis

Type-hinted implementations of the key algorithms from the
"Gravity from Information" framework.
"""

from dataclasses import dataclass
from typing import Optional
import math


@dataclass
class QECCode:
    """Quantum error-correcting code with parameters [[n, k, d]]."""
    n: int  # physical qubits
    k: int  # logical qubits
    d: int  # code distance

    def __post_init__(self) -> None:
        assert self.n > 0, "n must be positive"
        assert 0 <= self.k <= self.n, "k must satisfy 0 <= k <= n"
        assert 0 < self.d <= self.n, "d must satisfy 0 < d <= n"

    def satisfies_singleton(self) -> bool:
        """Check quantum Singleton bound: n - k >= 2(d - 1)."""
        return self.n - self.k >= 2 * (self.d - 1)

    def saturates_singleton(self) -> bool:
        """Check Singleton saturation: k + 2(d-1) = n."""
        return self.k + 2 * (self.d - 1) == self.n

    def rate(self) -> float:
        """Code rate k/n."""
        return self.k / self.n

    def relative_distance(self) -> float:
        """Relative distance d/n."""
        return self.d / self.n

    def info_density(self) -> float:
        """Information density k/n."""
        return self.k / self.n

    def prot_density(self) -> float:
        """Protection density d/n."""
        return self.d / self.n

    def redundancy(self) -> float:
        """Redundancy n/k."""
        if self.k == 0:
            return float('inf')
        return self.n / self.k


@dataclass
class HolographicParams:
    """Spacetime geometry parameters for holographic code construction."""
    area: int       # boundary area in Planck units
    geodesic: int   # minimal geodesic length in Planck units

    def __post_init__(self) -> None:
        assert self.area > 0 and self.area % 4 == 0
        assert self.geodesic > 0 and self.geodesic % 2 == 0
        assert self.geodesic <= self.area

    def to_code(self) -> QECCode:
        """Construct holographic code from geometry."""
        return QECCode(
            n=self.area,
            k=self.area // 4,
            d=self.geodesic // 2
        )


def compose_codes(c1: QECCode, c2: QECCode) -> QECCode:
    """Compose two codes where c1 encodes into c2's logical space.
    
    Requires: c1.n == c2.k
    Returns: code with parameters (c2.n, c1.k, min(c1.d, c2.d))
    """
    assert c1.n == c2.k, f"c1.n={c1.n} must equal c2.k={c2.k}"
    return QECCode(n=c2.n, k=c1.k, d=min(c1.d, c2.d))


def holographic_entropy(a: int) -> int:
    """Holographic entanglement entropy S(a) = a // 4."""
    return a // 4


def find_singleton_saturating_codes(n_max: int) -> list[QECCode]:
    """Find all Singleton-saturating codes with n <= n_max.
    
    These are quantum MDS codes satisfying k + 2(d-1) = n.
    """
    codes: list[QECCode] = []
    for n in range(1, n_max + 1):
        for d in range(1, n + 1):
            k = n - 2 * (d - 1)
            if k >= 0 and k <= n:
                code = QECCode(n=n, k=k, d=d)
                if code.saturates_singleton():
                    codes.append(code)
    return codes


def singleton_tradeoff_curve(n: int) -> list[tuple[float, float]]:
    """Compute the information-protection tradeoff curve for given n.
    
    Returns list of (rho_I, rho_P) pairs for Singleton-saturating codes.
    """
    points: list[tuple[float, float]] = []
    for d in range(1, (n + 2) // 2 + 1):
        k = n - 2 * (d - 1)
        if k >= 0:
            points.append((k / n, d / n))
    return points


def geometric_singleton_bound(area: int) -> int:
    """Maximum geodesic length satisfying the Singleton bound.
    
    Returns: max geodesic such that the holographic code satisfies Singleton.
    geodesic <= 3*area/4 + 2
    """
    return 3 * area // 4 + 2


def verify_info_protection_tradeoff(code: QECCode) -> dict[str, float]:
    """Verify and report the information-protection tradeoff.
    
    Returns dict with rho_I, rho_P, lhs (rho_I + 2*rho_P),
    bound (1 + 2/n), and margin.
    """
    rho_I = code.info_density()
    rho_P = code.prot_density()
    lhs = rho_I + 2 * rho_P
    bound = 1 + 2 / code.n
    return {
        "rho_I": rho_I,
        "rho_P": rho_P,
        "lhs": lhs,
        "bound": bound,
        "margin": bound - lhs,
        "satisfied": lhs <= bound + 1e-12
    }


def code_hierarchy(layers: list[QECCode]) -> Optional[QECCode]:
    """Compose a hierarchy of codes (from innermost to outermost).
    
    Each layer must satisfy: layer[i].n == layer[i+1].k.
    Returns the composed code, or None if composition is invalid.
    """
    if not layers:
        return None
    result = layers[0]
    for i in range(1, len(layers)):
        if result.n != layers[i].k:
            return None
        result = compose_codes(result, layers[i])
    return result


if __name__ == "__main__":
    # Example: AdS_3 holographic code
    params = HolographicParams(area=100, geodesic=50)
    code = params.to_code()
    print(f"Holographic code: [[{code.n}, {code.k}, {code.d}]]")
    print(f"Singleton bound satisfied: {code.satisfies_singleton()}")
    print(f"Rate: {code.rate():.4f}")
    print(f"Tradeoff: {verify_info_protection_tradeoff(code)}")

    # Example: code hierarchy
    c1 = QECCode(n=4, k=2, d=2)   # Inner code
    c2 = QECCode(n=8, k=4, d=3)   # Middle code
    c3 = QECCode(n=20, k=8, d=5)  # Outer code
    composed = code_hierarchy([c1, c2, c3])
    if composed:
        print(f"\nComposed code: [[{composed.n}, {composed.k}, {composed.d}]]")
        print(f"Singleton: {composed.satisfies_singleton()}")
