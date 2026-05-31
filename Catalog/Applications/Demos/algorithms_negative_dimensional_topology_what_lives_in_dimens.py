"""
Negative-Dimensional Topology: Core Algorithms

Type-hinted implementations of the key constructions from the formal theory.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class FormalDimObj:
    """A formal graded object with integer dimension and Euler characteristic."""
    dim: int
    euler: int

    def __repr__(self) -> str:
        return f"FormalDimObj(dim={self.dim}, χ={self.euler})"


@dataclass
class NegDimSpace:
    """A negative-dimensional space with canonical Euler characteristic."""
    dim: int
    components: int

    def __post_init__(self) -> None:
        assert self.dim <= 0, f"Dimension must be non-positive, got {self.dim}"
        assert self.components > 0, f"Components must be positive, got {self.components}"

    @property
    def euler_char(self) -> int:
        """χ(X) = (-1)^(-dim) · |π₀(X)|"""
        return ((-1) ** (-self.dim)) * self.components

    def to_formal(self) -> FormalDimObj:
        return FormalDimObj(dim=self.dim, euler=self.euler_char)


def suspend(X: FormalDimObj) -> FormalDimObj:
    """Formal suspension: dim → dim+1, χ → 2 - χ."""
    return FormalDimObj(dim=X.dim + 1, euler=2 - X.euler)


def desuspend(X: FormalDimObj) -> FormalDimObj:
    """Formal desuspension: dim → dim-1, χ → 2 - χ."""
    return FormalDimObj(dim=X.dim - 1, euler=2 - X.euler)


def suspend_iter(X: FormalDimObj, n: int) -> FormalDimObj:
    """Iterated suspension Σⁿ X."""
    result = X
    for _ in range(n):
        result = suspend(result)
    return result


def product(X: FormalDimObj, Y: FormalDimObj) -> FormalDimObj:
    """Product: dim adds, Euler multiplies (Künneth)."""
    return FormalDimObj(dim=X.dim + Y.dim, euler=X.euler * Y.euler)


def stabilization_steps(X: FormalDimObj) -> int:
    """Minimum suspensions to reach positive dimension."""
    if X.dim > 0:
        return 0
    return 1 - X.dim


@dataclass
class NegDimCW:
    """Negative-dimensional CW complex with cell counts."""
    codim: int
    cells: List[int]

    def __post_init__(self) -> None:
        assert len(self.cells) == self.codim + 1
        assert self.cells[0] > 0

    @property
    def euler_char(self) -> int:
        """χ = Σᵢ (-1)^(codim - i) · cells(i)"""
        return sum(
            ((-1) ** (self.codim - i)) * c
            for i, c in enumerate(self.cells)
        )

    @property
    def total_cells(self) -> int:
        return sum(self.cells)


class ProSpectrum:
    """A pro-spectrum: sequence of formal dim objects connected by suspension."""

    def __init__(self, base: FormalDimObj):
        self.base = base

    def space(self, n: int) -> FormalDimObj:
        """The n-th level of the pro-spectrum."""
        return suspend_iter(self.base, n)

    def euler_sequence(self, length: int) -> List[int]:
        """First `length` Euler characteristics."""
        return [self.space(n).euler for n in range(length)]

    def dim_sequence(self, length: int) -> List[int]:
        """First `length` dimensions."""
        return [self.space(n).dim for n in range(length)]


def verify_double_suspension_involution(X: FormalDimObj) -> bool:
    """Verify χ(Σ²X) = χ(X)."""
    return suspend(suspend(X)).euler == X.euler


def verify_consecutive_sum(base: FormalDimObj, n: int) -> bool:
    """Verify χ(Xₙ) + χ(Xₙ₊₁) = 2 in the pro-spectrum."""
    ps = ProSpectrum(base)
    return ps.space(n).euler + ps.space(n + 1).euler == 2


def euler_char_neg_dim(dim: int, components: int) -> int:
    """
    Compute χ for a negative-dimensional space.

    Algorithm:
        n ← |dim|
        if n is even: return components
        else: return -components
    """
    n = abs(dim)
    if n % 2 == 0:
        return components
    else:
        return -components


def classify_neg_dim_space(euler: int) -> Tuple[Optional[str], int]:
    """
    Given an Euler characteristic, determine the parity class and component count.

    Returns: (parity, components)
        parity: 'even' if codim is even, 'odd' if odd
        components: |π₀(X)| = |χ|
    """
    components = abs(euler)
    if euler > 0:
        return ('even', components)
    elif euler < 0:
        return ('odd', components)
    else:
        return (None, 0)  # Degenerate case


def uniform_cw_euler(codim: int) -> int:
    """
    Euler characteristic of a uniform CW complex (all cells = 1).

    For even codim: χ = 1
    For odd codim: χ = 0
    """
    cells = [1] * (codim + 1)
    return sum((-1) ** (codim - i) for i in range(codim + 1))
