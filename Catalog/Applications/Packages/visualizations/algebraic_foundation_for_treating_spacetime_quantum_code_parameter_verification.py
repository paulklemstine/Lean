"""
Algorithms for Holographic Quantum Error-Correcting Codes.

Implements the core algebraic structures and computations from the
Bekenstein-Singleton correspondence framework.
"""

from typing import List, Tuple, Optional
from dataclasses import dataclass
import math


@dataclass
class QCode:
    """A quantum error-correcting code [[n, k, d]]."""
    n: int  # physical qubits
    k: int  # logical qubits
    d: int  # distance

    def __post_init__(self) -> None:
        assert self.n > 0, "n must be positive"
        assert 0 <= self.k <= self.n, "k must satisfy 0 <= k <= n"
        assert self.d > 0, "d must be positive"
        assert 2 * self.d <= self.n - self.k + 2, \
            f"Quantum Singleton violated: 2*{self.d} > {self.n}-{self.k}+2"

    @property
    def redundancy(self) -> int:
        """Number of extra physical qubits beyond logical content."""
        return self.n - self.k

    @property
    def rate(self) -> float:
        """Fraction of physical qubits carrying logical information."""
        return self.k / self.n

    @property
    def is_mds(self) -> bool:
        """Whether the code saturates the quantum Singleton bound."""
        return self.redundancy == 2 * (self.d - 1)

    @property
    def entropy_defect(self) -> int:
        """Gap from Singleton saturation (non-negative)."""
        return self.redundancy - 2 * (self.d - 1)

    @property
    def singleton_entropy(self) -> float:
        """The Singleton entropy: (n-k)/2."""
        return self.redundancy / 2.0

    @property
    def bekenstein_hawking_entropy(self) -> float:
        """Bekenstein-Hawking entropy with area = 2*(n-k)."""
        return 2 * self.redundancy / 4.0


def verify_singleton_bound(code: QCode) -> bool:
    """Verify the quantum Singleton bound: n - k >= 2(d-1)."""
    return code.redundancy >= 2 * (code.d - 1)


def verify_bekenstein_singleton(code: QCode) -> bool:
    """Verify the Bekenstein-Singleton correspondence for MDS codes."""
    if not code.is_mds:
        return False
    return abs(code.bekenstein_hawking_entropy - code.singleton_entropy) < 1e-12


def entropy_density(code: QCode) -> float:
    """Singleton entropy per physical qubit, bounded by 1/2."""
    return code.singleton_entropy / code.n


def enumerate_mds_codes(max_n: int) -> List[QCode]:
    """Enumerate all MDS quantum codes up to block length max_n."""
    codes: List[QCode] = []
    for n in range(1, max_n + 1):
        for d in range(1, n // 2 + 2):
            k = n - 2 * (d - 1)
            if k < 0:
                continue
            try:
                code = QCode(n=n, k=k, d=d)
                if code.is_mds:
                    codes.append(code)
            except AssertionError:
                continue
    return codes


@dataclass
class PageCurve:
    """A Page curve: k(t) for a dynamical code family."""
    n: int          # fixed total size
    page_time: int  # time of maximum entropy

    def k(self, t: int) -> int:
        """Logical qubits at time t (Page curve shape)."""
        if t <= self.page_time:
            return min(t, self.n // 2)
        else:
            return max(self.n // 2 - (t - self.page_time), 0)

    def radiation_entropy(self, t: int) -> int:
        """Radiation entropy at time t."""
        return self.k(t)

    def code_at(self, t: int) -> QCode:
        """The quantum code at time t."""
        k_t = self.k(t)
        d_t = (self.n - k_t) // 2 + 1
        return QCode(n=self.n, k=k_t, d=d_t)

    def trace(self, t_max: int) -> List[Tuple[int, int]]:
        """Return the Page curve as (t, k(t)) pairs."""
        return [(t, self.k(t)) for t in range(t_max + 1)]


def holographic_entropy_check(
    S: dict,
    regions: List[str]
) -> dict:
    """
    Check SSA and MMI for an entropy assignment.

    S: dictionary mapping frozenset of region labels to entropy values
    regions: list of region labels

    Returns dict with 'ssa_satisfied' and 'mmi_satisfied' booleans.
    """
    from itertools import combinations

    def get_S(labels: frozenset) -> float:
        return S.get(labels, 0.0)

    ssa_violations = []
    mmi_violations = []

    # Check SSA for all triples of disjoint singleton regions
    for triple in combinations(regions, 3):
        A, B, C = frozenset([triple[0]]), frozenset([triple[1]]), frozenset([triple[2]])
        AB = A | B
        BC = B | C
        ABC = A | B | C

        # SSA: S(AB) + S(BC) >= S(ABC) + S(B)
        lhs = get_S(AB) + get_S(BC)
        rhs = get_S(ABC) + get_S(B)
        if lhs < rhs - 1e-10:
            ssa_violations.append((triple, lhs - rhs))

        # MMI: S(AB) + S(AC) + S(BC) <= S(A) + S(B) + S(C) + S(ABC)
        AC = A | C
        lhs_mmi = get_S(AB) + get_S(AC) + get_S(BC)
        rhs_mmi = get_S(A) + get_S(B) + get_S(C) + get_S(ABC)
        if lhs_mmi > rhs_mmi + 1e-10:
            mmi_violations.append((triple, lhs_mmi - rhs_mmi))

    return {
        'ssa_satisfied': len(ssa_violations) == 0,
        'mmi_satisfied': len(mmi_violations) == 0,
        'ssa_violations': ssa_violations,
        'mmi_violations': mmi_violations,
    }


def singleton_entropy_density_scan(max_n: int = 50) -> List[Tuple[int, int, float]]:
    """
    Scan entropy density (n-k)/(2n) for all valid MDS codes.
    Returns (n, k, density) triples, all with density <= 0.5.
    """
    results = []
    for n in range(2, max_n + 1):
        for d in range(1, n // 2 + 2):
            k = n - 2 * (d - 1)
            if 0 <= k <= n:
                density = (n - k) / (2 * n)
                results.append((n, k, density))
    return results


if __name__ == "__main__":
    # Quick self-test
    c = QCode(n=5, k=1, d=3)
    print(f"Code [[{c.n},{c.k},{c.d}]]:")
    print(f"  Redundancy: {c.redundancy}")
    print(f"  Rate: {c.rate:.3f}")
    print(f"  MDS: {c.is_mds}")
    print(f"  Singleton entropy: {c.singleton_entropy}")
    print(f"  BH entropy: {c.bekenstein_hawking_entropy}")
    print(f"  BH = Singleton: {verify_bekenstein_singleton(c)}")
    print(f"  Entropy density: {entropy_density(c):.3f} <= 0.5: {entropy_density(c) <= 0.5}")
