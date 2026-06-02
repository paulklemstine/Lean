#!/usr/bin/env python3
"""
Negative-Dimensional Topology: Core Algorithms

Type-hinted implementations of the key mathematical structures and algorithms
from the formal theory of negative-dimensional topology.
"""

from dataclasses import dataclass, field
from typing import List, Optional, Tuple, Iterator, Callable
from functools import reduce
import math


# ============================================================================
# Core Data Structures
# ============================================================================

@dataclass(frozen=True)
class FormalDimObj:
    """A formal dimension object with integer dimension and Euler characteristic.

    This is the fundamental building block of negative-dimensional topology.
    Every topological space (in any dimension) is represented by its dimension
    and Euler characteristic.
    """
    dim: int
    euler: int

    def suspend(self) -> 'FormalDimObj':
        """Apply the suspension functor: Σ(d, χ) = (d+1, 2-χ)."""
        return FormalDimObj(self.dim + 1, 2 - self.euler)

    def desuspend(self) -> 'FormalDimObj':
        """Apply desuspension: Σ⁻¹(d, χ) = (d-1, 2-χ)."""
        return FormalDimObj(self.dim - 1, 2 - self.euler)

    def suspend_iter(self, n: int) -> 'FormalDimObj':
        """Apply n-fold suspension. O(1) via parity formula."""
        if n < 0:
            return self.desuspend_iter(-n)
        new_dim = self.dim + n
        new_euler = self.euler if n % 2 == 0 else 2 - self.euler
        return FormalDimObj(new_dim, new_euler)

    def desuspend_iter(self, n: int) -> 'FormalDimObj':
        """Apply n-fold desuspension. O(1) via parity formula."""
        return self.suspend_iter(-n) if n < 0 else FormalDimObj(
            self.dim - n, self.euler if n % 2 == 0 else 2 - self.euler
        )

    def product(self, other: 'FormalDimObj') -> 'FormalDimObj':
        """Product via Künneth: (d₁,χ₁) × (d₂,χ₂) = (d₁+d₂, χ₁·χ₂)."""
        return FormalDimObj(self.dim + other.dim, self.euler * other.euler)

    def stabilization_steps(self) -> int:
        """Minimum n such that dim(Σⁿ self) > 0."""
        if self.dim > 0:
            return 0
        return max(0, -self.dim) + 1


@dataclass(frozen=True)
class FormalBettiSeq:
    """A formal Betti sequence for a negative-dimensional space.

    Represents the formal cell structure with alternating-sum Euler characteristic.
    """
    codim: int
    betti: Tuple[int, ...]

    def __post_init__(self) -> None:
        assert len(self.betti) == self.codim + 1, "Betti length must be codim + 1"
        assert self.betti[0] > 0, "β₀ must be positive"

    @property
    def euler_char(self) -> int:
        """Euler characteristic: Σᵢ (-1)ⁱ βᵢ."""
        return sum((-1)**i * b for i, b in enumerate(self.betti))

    @property
    def total_betti(self) -> int:
        """Total Betti number: Σᵢ βᵢ."""
        return sum(self.betti)

    def is_palindromic(self) -> bool:
        """Check if Betti sequence satisfies Poincaré duality symmetry."""
        n = self.codim
        return all(self.betti[i] == self.betti[n - i] for i in range(n + 1))

    def middle_betti(self) -> Optional[int]:
        """Return the middle Betti number if codim is even."""
        if self.codim % 2 != 0:
            return None
        return self.betti[self.codim // 2]


# ============================================================================
# Sphere Spectrum
# ============================================================================

def neg_dim_sphere(d: int) -> FormalDimObj:
    """The formal sphere S^d for any integer dimension d.

    χ(S^d) = 1 + (-1)^d, which gives:
    - χ(S^0) = 2 (two points)
    - χ(S^1) = 0 (circle)
    - χ(S^2) = 2 (sphere)
    - χ(S^{-1}) = 0 (empty set)
    - χ(S^{-2}) = 2
    """
    return FormalDimObj(d, 1 + (-1)**d)


# ============================================================================
# Pro-Spectrum Algorithm
# ============================================================================

def pro_spectrum(base: FormalDimObj, levels: int) -> List[FormalDimObj]:
    """Generate the first `levels` entries of the pro-spectrum from base.

    Each level is connected by suspension: space[n+1] = Σ(space[n]).
    Uses O(1) per level via the parity formula.
    """
    return [base.suspend_iter(n) for n in range(levels)]


def cesaro_average(base: FormalDimObj, n_terms: int) -> float:
    """Compute the Cesàro average of Euler characteristics.

    For even n_terms = 2(k+1), the average is exactly 1.
    For odd n_terms = 2k+1, the average is (2k + χ) / (2k+1).
    """
    if n_terms <= 0:
        return 0.0
    if n_terms % 2 == 0:
        return 1.0  # Exact by theorem
    k = (n_terms - 1) // 2
    return (2 * k + base.euler) / n_terms


# ============================================================================
# Dimension Pairing
# ============================================================================

def dim_pairing(x: FormalDimObj, y: FormalDimObj, target: int) -> int:
    """Compute the dimension pairing ⟨X, Y⟩_t.

    Returns 0 iff dim(X)+dim(Y) = t, or χ(X) = 0, or χ(Y) = 0.
    """
    return (x.dim + y.dim - target) * (x.euler * y.euler)


def find_complementary_dim(x: FormalDimObj) -> int:
    """Find the target dimension t for which any Y with dim(Y) = t - dim(X)
    gives ⟨X, Y⟩_t = 0 (complementarity)."""
    return x.dim  # Any target works when we set dim(Y) = target - dim(X)


# ============================================================================
# Poincaré Duality Check
# ============================================================================

def check_poincare_duality(betti: FormalBettiSeq) -> Tuple[bool, str]:
    """Verify the Poincaré duality conjecture for a Betti sequence.

    Returns (passes, explanation).
    """
    if betti.codim % 2 != 0:
        return True, "Codimension is odd; duality not applicable"

    if not betti.is_palindromic():
        return True, "Not palindromic; duality not applicable"

    k = betti.codim // 2
    chi = betti.euler_char
    beta_k = betti.betti[k]

    if chi % 2 == beta_k % 2:
        return True, f"χ={chi} ≡ β_{k}={beta_k} (mod 2) ✓"
    else:
        return False, f"COUNTEREXAMPLE: χ={chi} ≢ β_{k}={beta_k} (mod 2)"


# ============================================================================
# Suspension-Product Analysis
# ============================================================================

def suspension_product_defect(x: FormalDimObj, y: FormalDimObj) -> int:
    """Compute the defect χ(Σ(X×Y)) - χ((ΣX)×Y) = 2(1 - χ(Y)).

    Non-zero iff χ(Y) ≠ 1, proving non-commutativity.
    """
    return 2 * (1 - y.euler)


# ============================================================================
# Uniform Cell Analysis
# ============================================================================

def uniform_betti_euler(codim: int) -> int:
    """Euler characteristic of uniform Betti sequence (all βᵢ = 1).

    For even codim = 2k: χ = 1
    For odd codim = 2k+1: χ = 0
    """
    return sum((-1)**i for i in range(codim + 1))


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    # Demonstrate key algorithms
    print("=== Pro-Spectrum from empty space ===")
    empty = FormalDimObj(-1, 0)
    spectrum = pro_spectrum(empty, 10)
    for i, s in enumerate(spectrum):
        print(f"  Level {i}: dim={s.dim:3d}, χ={s.euler}")

    print("\n=== Cesàro Averages ===")
    X = FormalDimObj(-3, 7)
    for n in range(1, 21):
        avg = cesaro_average(X, n)
        print(f"  {n:2d} terms: avg = {avg:.6f}")

    print("\n=== Poincaré Duality Tests ===")
    test_seqs = [
        FormalBettiSeq(4, (1, 3, 5, 3, 1)),
        FormalBettiSeq(2, (2, 4, 2)),
        FormalBettiSeq(6, (1, 1, 1, 1, 1, 1, 1)),
    ]
    for seq in test_seqs:
        passes, msg = check_poincare_duality(seq)
        print(f"  β={seq.betti}: {msg}")

    print("\n=== Uniform Cell Euler Characteristics ===")
    for codim in range(0, 21):
        chi = uniform_betti_euler(codim)
        print(f"  codim={codim:2d}: χ={chi:2d} {'(even codim → χ=1)' if codim % 2 == 0 else ''}")
