#!/usr/bin/env python3
"""Numerical demonstrations of Singleton geometric-defect bounds.

This script audits finite [[n,k,d]] parameter triples, illustrates exact balance,
checks bounded-defect families, and visualizes the resulting logical-rate ceiling.
It uses only the Python standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import floor
from typing import Iterable, Sequence


@dataclass(frozen=True)
class CodeAudit:
    """Arithmetic audit of one proposed quantum-code parameter triple."""

    n: int
    k: int
    d: int
    defect: int
    singleton_valid: bool
    singleton_saturated: bool
    capacity_ceiling: int
    slack: int


def audit_code(n: int, k: int, d: int) -> CodeAudit:
    """Audit Singleton validity and the geometric defect of [[n,k,d]].

    Raises:
        ValueError: If parameters are outside their natural domains or n < 2d,
            in which case the nonnegative-defect dictionary does not apply.
    """
    if n < 0 or k < 0 or d < 1:
        raise ValueError("Require n >= 0, k >= 0, and d >= 1.")
    if k > n:
        raise ValueError("A logical-qubit count must satisfy k <= n.")
    if n < 2 * d:
        raise ValueError("The dictionary n = 2d + defect requires n >= 2d.")
    defect = n - 2 * d
    slack = n + 2 - (2 * d + k)
    return CodeAudit(
        n=n,
        k=k,
        d=d,
        defect=defect,
        singleton_valid=slack >= 0,
        singleton_saturated=slack == 0,
        capacity_ceiling=defect + 2,
        slack=slack,
    )


def maximum_logical_capacity(n: int, d: int) -> int:
    """Return the Singleton ceiling n - 2d + 2 under n >= 2d."""
    if d < 1 or n < 2 * d:
        raise ValueError("Require d >= 1 and n >= 2d.")
    return n - 2 * d + 2


def rate_threshold(defect_bound: int, epsilon: float) -> int:
    """Return N such that n >= N implies (D+2)/n < epsilon."""
    if defect_bound < 0:
        raise ValueError("The defect bound must be nonnegative.")
    if epsilon <= 0.0:
        raise ValueError("epsilon must be positive.")
    return floor((defect_bound + 2) / epsilon) + 1


def audit_family(
    triples: Iterable[tuple[int, int, int]], defect_bound: int
) -> list[CodeAudit]:
    """Audit a family and enforce the common defect/capacity bound."""
    reports = [audit_code(n, k, d) for n, k, d in triples]
    for report in reports:
        if not report.singleton_valid:
            raise ValueError(f"Singleton violation: {report}")
        if report.defect > defect_bound:
            raise ValueError(f"Defect exceeds D={defect_bound}: {report}")
        assert report.k <= defect_bound + 2
    return reports


def ascii_rate_plot(rows: Sequence[CodeAudit], width: int = 50) -> str:
    """Create a dependency-free bar chart of observed logical rates."""
    if width < 1:
        raise ValueError("width must be positive.")
    lines = ["physical size n | logical rate k/n"]
    for row in rows:
        rate = row.k / row.n if row.n else 0.0
        bar = "█" * min(width, round(rate * width))
        lines.append(f"{row.n:15d} | {bar:<{width}} {rate:.6f}")
    return "\n".join(lines)


def demonstrate_balanced_geometry() -> None:
    """Show that exact balance permits k <= 2 and saturates only at k = 2."""
    print("\n1. Exact balance n = 2d")
    print(" n    d    k  valid  saturated  defect  ceiling")
    for n, d in [(20, 10), (100, 50), (1000, 500)]:
        for k in range(4):
            report = audit_code(n, k, d)
            print(
                f"{n:4d} {d:4d} {k:4d}  "
                f"{str(report.singleton_valid):5s}  "
                f"{str(report.singleton_saturated):9s}  "
                f"{report.defect:6d}  {report.capacity_ceiling:7d}"
            )


def demonstrate_defect_capacity() -> None:
    """Show that capacity grows with defect rather than total size."""
    print("\n2. Defect-capacity law k <= defect + 2")
    print(" n    d  defect  maximum k")
    for n, d in [(100, 50), (110, 50), (120, 50), (1000, 450)]:
        defect = n - 2 * d
        ceiling = maximum_logical_capacity(n, d)
        print(f"{n:4d} {d:4d} {defect:7d} {ceiling:10d}")
        assert ceiling == defect + 2


def demonstrate_bounded_defect_rates() -> None:
    """Build a saturating fixed-defect family and display its vanishing rate."""
    print("\n3. Fixed defect D = 10: bounded capacity and vanishing rate")
    defect_bound = 10
    triples = [(2 * d + defect_bound, defect_bound + 2, d) for d in (10, 50, 100, 500)]
    reports = audit_family(triples, defect_bound)
    print(ascii_rate_plot(reports))
    epsilon = 0.01
    threshold = rate_threshold(defect_bound, epsilon)
    print(
        f"For epsilon={epsilon}, every Singleton-valid member with "
        f"n >= {threshold} has k/n < epsilon."
    )


def demonstrate_direction_collision() -> None:
    """Compare genuine and reversed redundancy inequalities at balance."""
    print("\n4. Genuine versus reversed redundancy at n = 2d")
    n, d = 100, 50
    print(" k  genuine  reversed  both")
    for k in range(5):
        genuine = 2 * (d - 1) <= n - k
        reversed_relation = n - k <= 2 * (d - 1)
        print(f"{k:2d}  {str(genuine):7s}  {str(reversed_relation):8s}  {genuine and reversed_relation}")
        if genuine and reversed_relation:
            assert k == 2


def main() -> None:
    """Run all numerical demonstrations."""
    print("Singleton Geometry Demonstration")
    print("================================")
    demonstrate_balanced_geometry()
    demonstrate_defect_capacity()
    demonstrate_bounded_defect_rates()
    demonstrate_direction_collision()


if __name__ == "__main__":
    main()
