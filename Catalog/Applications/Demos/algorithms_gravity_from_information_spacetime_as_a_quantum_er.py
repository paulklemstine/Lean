"""
Algorithms for Holographic Code Tower Analysis

Type-hinted implementations of the key algorithms from the research.
"""

from dataclasses import dataclass
from typing import Optional


@dataclass
class QECCParams:
    """Parameters of a quantum error-correcting code [[n, k, d]]."""
    n: int  # physical qubits
    k: int  # logical qubits
    d: int  # code distance

    def __post_init__(self) -> None:
        assert self.k <= self.n, f"k={self.k} > n={self.n}"
        assert self.d >= 1, f"d={self.d} < 1"
        assert self.k + 2 * self.d <= self.n + 2, \
            f"Singleton bound violated: {self.k} + 2*{self.d} > {self.n} + 2"

    @property
    def is_mds(self) -> bool:
        return self.k + 2 * self.d == self.n + 2

    @property
    def defect(self) -> int:
        return self.n + 2 - (self.k + 2 * self.d)

    @property
    def singleton_entropy(self) -> float:
        return (self.n - self.k) / 2

    @property
    def redundancy(self) -> int:
        return self.n - self.k

    @property
    def recon_threshold(self) -> int:
        return self.n - self.d + 1

    @property
    def rate(self) -> float:
        return self.k / self.n if self.n > 0 else 0.0


@dataclass
class HolographicCodeTower:
    """A holographic code tower: layered family of QECC codes."""
    codes: list[QECCParams]

    def __post_init__(self) -> None:
        assert len(self.codes) >= 1, "Tower must have at least 1 layer"
        k0 = self.codes[0].k
        for i, c in enumerate(self.codes):
            assert c.k == k0, f"Layer {i} has k={c.k} != k0={k0}"
        for i in range(len(self.codes) - 1):
            assert self.codes[i].d < self.codes[i + 1].d, \
                f"Distance not strictly increasing: d[{i}]={self.codes[i].d} >= d[{i+1}]={self.codes[i+1].d}"

    @property
    def height(self) -> int:
        return len(self.codes)

    @property
    def logical_dim(self) -> int:
        return self.codes[0].k

    @property
    def is_fully_mds(self) -> bool:
        return all(c.is_mds for c in self.codes)

    def block_at(self, l: int) -> int:
        return self.codes[l].n

    def dist_at(self, l: int) -> int:
        return self.codes[l].d

    def curvature(self, l: int) -> int:
        """Discrete curvature at interior layer l."""
        assert 0 < l < self.height - 1, f"Layer {l} is not interior"
        return self.block_at(l + 1) - 2 * self.block_at(l) + self.block_at(l - 1)

    def distance_curvature(self, l: int) -> int:
        """Discrete curvature of the distance sequence at layer l."""
        assert 0 < l < self.height - 1
        return self.dist_at(l + 1) - 2 * self.dist_at(l) + self.dist_at(l - 1)

    def verify_curvature_identity(self) -> bool:
        """Verify κ_n = 2κ_d at all interior layers (only valid for MDS towers)."""
        if not self.is_fully_mds:
            return False
        for l in range(1, self.height - 1):
            if self.curvature(l) != 2 * self.distance_curvature(l):
                return False
        return True


def construct_mds_tower(k: int, distances: list[int]) -> HolographicCodeTower:
    """Construct an MDS holographic code tower from logical dim and distance sequence.

    Args:
        k: Number of logical qubits (constant across layers)
        distances: Strictly increasing sequence of code distances

    Returns:
        A fully MDS HolographicCodeTower
    """
    codes = [QECCParams(n=k + 2 * d - 2, k=k, d=d) for d in distances]
    return HolographicCodeTower(codes)


def construct_toric_tower(l_range: range) -> HolographicCodeTower:
    """Construct a tower from toric code family [[2L², 2, L]].

    Note: This is NOT an MDS tower (toric codes have positive defect for L ≥ 3).
    """
    codes = [QECCParams(n=2 * L ** 2, k=2, d=L) for L in l_range]
    return HolographicCodeTower(codes)


def complementary_recovery_analysis(code: QECCParams) -> dict[str, int]:
    """Analyze complementary recovery for a code.

    Returns dict with recovery threshold, and for MDS codes,
    the critical region size for complementary recovery.
    """
    result = {
        "n": code.n,
        "k": code.k,
        "d": code.d,
        "recon_threshold": code.recon_threshold,
        "erasure_capacity": code.d - 1,
        "is_mds": code.is_mds,
    }
    if code.is_mds:
        result["mds_critical_size"] = (code.n + code.k) // 2 + 1
    return result


def bekenstein_singleton_check(code: QECCParams) -> dict[str, float]:
    """Verify the Bekenstein-Singleton correspondence for a code."""
    area = 2 * (code.n - code.k)
    s_bh = area / 4
    s_singleton = code.singleton_entropy
    return {
        "area": area,
        "S_BH": s_bh,
        "S_singleton": s_singleton,
        "match": abs(s_bh - s_singleton) < 1e-10,
        "S_equals_d_minus_1": abs(s_singleton - (code.d - 1)) < 1e-10 if code.is_mds else None,
    }


def page_entropy(code: QECCParams, s: int) -> float:
    """Page curve entropy for a boundary subregion of size s.

    Returns min(s, n-s, singleton_entropy).
    """
    return min(float(s), min(float(code.n - s), code.singleton_entropy))


if __name__ == "__main__":
    # Example usage
    tower = construct_mds_tower(k=1, distances=[3, 4, 5, 6, 7])
    print(f"MDS Tower (k=1, d=3..7): fully MDS = {tower.is_fully_mds}")
    print(f"Curvature identity holds: {tower.verify_curvature_identity()}")

    for l in range(1, tower.height - 1):
        print(f"  Layer {l}: κ_n={tower.curvature(l)}, "
              f"2κ_d={2*tower.distance_curvature(l)}")

    # Toric code tower
    toric = construct_toric_tower(range(2, 8))
    print(f"\nToric Tower: fully MDS = {toric.is_fully_mds}")
    for l in range(1, toric.height - 1):
        print(f"  Layer {l} (L={l+2}): κ_n={toric.curvature(l)}, defect={toric.codes[l].defect}")
