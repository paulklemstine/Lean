#!/usr/bin/env python3
"""Numerical demonstrations of exact Singleton-defect capacity laws.

The script uses only the Python standard library.  It audits finite parameter
triples and prints three families illustrating exact balance, bounded positive
geometric defect, and positive defect density.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Iterable, Optional


@dataclass(frozen=True)
class CodeParameters:
    """A quantum-code parameter triple satisfying the Singleton inequality."""

    n: int
    k: int
    d: int

    def __post_init__(self) -> None:
        if self.n < 0 or self.k < 0 or self.d <= 0:
            raise ValueError("Require n >= 0, k >= 0, and d > 0")
        if self.k + 2 * (self.d - 1) > self.n:
            raise ValueError("The quantum Singleton inequality is violated")

    @property
    def exact_defect(self) -> int:
        return self.n + 2 - 2 * self.d

    @property
    def geometric_defect(self) -> int:
        return self.n - 2 * self.d

    @property
    def rate(self) -> Fraction:
        if self.n == 0:
            raise ZeroDivisionError("Rate requires positive block length")
        return Fraction(self.k, self.n)

    @property
    def normalized_exact_defect(self) -> Fraction:
        if self.n == 0:
            raise ZeroDivisionError("Normalization requires positive block length")
        return Fraction(self.exact_defect, self.n)


def audit(parameters: CodeParameters, entropy: Optional[Fraction] = None) -> dict[str, object]:
    """Return exact quantities and verify all finite-length conclusions."""
    d_exact = parameters.exact_defect
    d_geometric = parameters.geometric_defect
    assert d_exact == d_geometric + 2
    assert 0 <= parameters.k <= d_exact
    report: dict[str, object] = {
        "n": parameters.n,
        "k": parameters.k,
        "d": parameters.d,
        "exact_defect": d_exact,
        "geometric_defect": d_geometric,
    }
    if parameters.n > 0:
        assert parameters.rate <= parameters.normalized_exact_defect
        assert parameters.normalized_exact_defect == (
            Fraction(d_geometric, parameters.n) + Fraction(2, parameters.n)
        )
        report["rate"] = parameters.rate
        report["normalized_exact_defect"] = parameters.normalized_exact_defect
    if entropy is not None:
        if entropy > parameters.k:
            raise ValueError("Protected entropy must satisfy S <= k")
        assert entropy <= d_exact
        report["protected_entropy"] = entropy
    return report


def exact_balance(i: int) -> CodeParameters:
    """Singleton-saturating family with G = 0 and vanishing rate."""
    if i < 1:
        raise ValueError("Index must be positive")
    return CodeParameters(n=2 * i, k=2, d=i)


def bounded_positive_defect(i: int) -> CodeParameters:
    """Singleton-saturating family with G = 4 and vanishing rate."""
    if i < 1:
        raise ValueError("Index must be positive")
    return CodeParameters(n=2 * i + 4, k=6, d=i)


def positive_defect_density(i: int) -> CodeParameters:
    """Singleton-saturating family whose rate and defect density tend to 1/2."""
    if i < 1:
        raise ValueError("Index must be positive")
    return CodeParameters(n=4 * i, k=2 * i + 2, d=i)


def demonstrate_family(
    name: str,
    constructor: Callable[[int], CodeParameters],
    indices: Iterable[int],
) -> None:
    """Print exact defects, rates, and endpoint corrections for a family."""
    print(f"\n{name}")
    print(" i |    n    k    d |    G    D |       k/n       D/n       2/n")
    print("---+---------------+-----------+--------------------------------")
    for i in indices:
        p = constructor(i)
        audit(p, entropy=Fraction(p.k, 2))
        correction = Fraction(2, p.n)
        print(
            f"{i:2d} | {p.n:4d} {p.k:4d} {p.d:4d} |"
            f" {p.geometric_defect:4d} {p.exact_defect:4d} |"
            f" {float(p.rate):9.6f} {float(p.normalized_exact_defect):9.6f}"
            f" {float(correction):9.6f}"
        )


def verify_uniform_entropy_bound(
    family: Callable[[int], CodeParameters], indices: Iterable[int], bound: int
) -> None:
    """Check S_i = k_i/2 <= B + 2 and display its density envelope."""
    print(f"\nProtected-entropy test with geometric bound B = {bound}")
    for i in indices:
        p = family(i)
        if p.geometric_defect > bound:
            raise ValueError("The proposed geometric bound is false")
        entropy = Fraction(p.k, 2)
        assert entropy <= bound + 2
        density = entropy / p.n
        envelope = Fraction(bound + 2, p.n)
        assert density <= envelope
        print(
            f"i={i:4d}: S/n={float(density):.8f}, "
            f"upper envelope={(float(envelope)):.8f}"
        )


def main() -> None:
    sample_indices = (1, 2, 5, 10, 100, 1000)
    demonstrate_family("Exact balance: G = 0", exact_balance, sample_indices)
    demonstrate_family(
        "Bounded positive geometric defect: G = 4",
        bounded_positive_defect,
        sample_indices,
    )
    demonstrate_family(
        "Positive geometric-defect density",
        positive_defect_density,
        sample_indices,
    )
    verify_uniform_entropy_bound(exact_balance, (10, 100, 1000, 10000), bound=0)

    # Quantitative converse: epsilon <= rate implies epsilon <= D/n.
    example = positive_defect_density(100)
    epsilon = Fraction(2, 5)
    assert epsilon <= example.rate <= example.normalized_exact_defect
    print(
        "\nPositive-rate necessity: "
        f"epsilon={float(epsilon):.3f} <= rate={float(example.rate):.3f} "
        f"<= normalized defect={float(example.normalized_exact_defect):.3f}"
    )


if __name__ == "__main__":
    main()
