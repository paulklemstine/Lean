#!/usr/bin/env python3
"""
Algorithms for spectral periodic table theory.

Type-hinted implementations of the core mathematical constructions:
shell degeneracy, Madelung ordering, period computation, and
nuclear magic number generation.
"""
from dataclasses import dataclass
from typing import List, Tuple, Iterator, Optional


@dataclass(frozen=True)
class Subshell:
    """A quantum subshell (n, l) with n ≥ 1 and 0 ≤ l < n."""
    n: int  # principal quantum number
    l: int  # angular momentum quantum number

    def __post_init__(self) -> None:
        assert self.n >= 1, f"n must be ≥ 1, got {self.n}"
        assert 0 <= self.l < self.n, f"l must be in [0, n), got l={self.l}, n={self.n}"

    @property
    def madelung(self) -> int:
        """Madelung number n + l."""
        return self.n + self.l

    @property
    def capacity(self) -> int:
        """Number of electrons: 2(2l+1)."""
        return 2 * (2 * self.l + 1)

    @property
    def spectroscopic(self) -> str:
        """Standard spectroscopic notation (e.g., '3d')."""
        labels = 'spdfghiklmno'
        letter = labels[self.l] if self.l < len(labels) else f'[{self.l}]'
        return f"{self.n}{letter}"


def shell_degeneracy(n: int) -> int:
    """Total quantum states in shell n (with spin): 2n².

    Proof: Σ_{l=0}^{n-1} 2(2l+1) = 2·Σ(2l+1) = 2n².
    """
    return 2 * n * n


def orbital_degeneracy_by_sum(n: int) -> int:
    """Compute orbital degeneracy as explicit sum Σ_{l=0}^{n-1}(2l+1).

    Returns n² by the sum-of-odd-numbers identity.
    """
    return sum(2 * l + 1 for l in range(n))


def madelung_ordering(max_madelung: int = 12) -> List[Subshell]:
    """Generate all valid subshells in Madelung filling order.

    Subshells are ordered by (n+l, n) lexicographically.

    Args:
        max_madelung: Maximum Madelung number to include.

    Returns:
        List of Subshell objects in filling order.
    """
    subshells: List[Subshell] = []
    for m in range(1, max_madelung + 1):
        for n in range(1, m + 1):
            l = m - n
            if l < n:
                subshells.append(Subshell(n=n, l=l))
    return subshells


def compute_period_lengths(subshells: List[Subshell]) -> List[int]:
    """Compute period lengths from Madelung-ordered subshells.

    Groups subshells by Madelung number; each group's total
    capacity is one period length.

    Returns:
        List of period lengths.
    """
    if not subshells:
        return []
    periods: List[int] = []
    current_m = subshells[0].madelung
    current_total = 0
    for s in subshells:
        if s.madelung != current_m:
            periods.append(current_total)
            current_m = s.madelung
            current_total = 0
        current_total += s.capacity
    if current_total > 0:
        periods.append(current_total)
    return periods


def noble_gas_numbers(periods: List[int]) -> List[int]:
    """Compute noble gas atomic numbers as partial sums of periods."""
    result: List[int] = []
    cumulative = 0
    for p in periods:
        cumulative += p
        result.append(cumulative)
    return result


def ideal_period_length(k: int) -> int:
    """The k-th period length: 2·⌈(k+2)/2⌉².

    Satisfies: periods come in pairs, each pair = 2(j+1)².
    """
    return 2 * ((k + 2) // 2) ** 2


def ho_shell_degeneracy(N: int) -> int:
    """3D harmonic oscillator shell degeneracy (with spin): (N+1)(N+2)."""
    return (N + 1) * (N + 2)


def cumulative_ho(N: int) -> int:
    """Cumulative HO filling through shell N.

    Closed form: (N+1)(N+2)(N+3)/3.
    """
    return sum(ho_shell_degeneracy(k) for k in range(N + 1))


def ho_magic_numbers(max_shell: int = 6) -> List[int]:
    """Harmonic oscillator magic numbers (without spin-orbit correction)."""
    return [cumulative_ho(N) for N in range(max_shell + 1)]


@dataclass
class SpectralPeriodicTable:
    """Abstract spectral periodic table defined by eigenvalue multiplicities.

    The multiplicities determine the period structure: consecutive
    eigenvalues with the same multiplicity form a period.
    """
    multiplicities: List[int]

    @property
    def cumulative(self) -> List[int]:
        """Cumulative filling sequence."""
        result: List[int] = []
        total = 0
        for m in self.multiplicities:
            total += m
            result.append(total)
        return result

    @property
    def is_strictly_increasing(self) -> bool:
        """Check that cumulative filling is strictly increasing."""
        cum = self.cumulative
        return all(cum[i] < cum[i+1] for i in range(len(cum) - 1))

    def noble_gases(self) -> List[int]:
        """Elements at shell boundaries."""
        return self.cumulative


def build_quantum_periodic_table(max_shell: int = 7) -> SpectralPeriodicTable:
    """Build the quantum periodic table with 2n² degeneracies."""
    mults = [shell_degeneracy(n) for n in range(1, max_shell + 1)]
    return SpectralPeriodicTable(multiplicities=mults)


def build_ho_periodic_table(max_shell: int = 6) -> SpectralPeriodicTable:
    """Build the harmonic oscillator periodic table."""
    mults = [ho_shell_degeneracy(N) for N in range(max_shell + 1)]
    return SpectralPeriodicTable(multiplicities=mults)


def sum_of_squares(n: int) -> int:
    """Σ_{k=0}^{n} k² = n(n+1)(2n+1)/6."""
    return n * (n + 1) * (2 * n + 1) // 6


def verify_sum_of_squares(max_n: int = 20) -> bool:
    """Verify the sum of squares formula computationally."""
    for n in range(max_n + 1):
        if sum(k**2 for k in range(n + 1)) != sum_of_squares(n):
            return False
    return True


def verify_ho_formula(max_N: int = 20) -> bool:
    """Verify 3·cumulativeHO(N) = (N+1)(N+2)(N+3)."""
    for N in range(max_N + 1):
        if 3 * cumulative_ho(N) != (N+1) * (N+2) * (N+3):
            return False
    return True


if __name__ == "__main__":
    # Verify all identities
    assert verify_sum_of_squares(), "Sum of squares formula failed"
    assert verify_ho_formula(), "HO cumulative formula failed"

    # Build and display the periodic table
    subshells = madelung_ordering()
    periods = compute_period_lengths(subshells)
    nobles = noble_gas_numbers(periods)

    print("Madelung filling order:")
    cumulative = 0
    for s in subshells[:20]:
        cumulative += s.capacity
        print(f"  {s.spectroscopic:>4}  (n+l={s.madelung})  capacity={s.capacity:>3}  cumulative={cumulative}")

    print(f"\nPeriod lengths: {periods[:7]}")
    print(f"Noble gas Z:    {nobles[:7]}")
    print(f"Real noble gas: [2, 10, 18, 36, 54, 86, 118]")

    print(f"\nHO magic numbers: {ho_magic_numbers()}")
    print(f"Real magic:       [2, 8, 20, 28, 50, 82, 126]")

    # Quantum periodic table
    qpt = build_quantum_periodic_table()
    print(f"\nQuantum PT cumulative: {qpt.cumulative}")
    print(f"Strictly increasing: {qpt.is_strictly_increasing}")
