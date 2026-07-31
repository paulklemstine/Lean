#!/usr/bin/env python3
"""Exact numerical demonstrations of half-canonical square thresholds."""

from __future__ import annotations

from dataclasses import dataclass
from math import isqrt
from typing import Iterable


def rho(g: int, r: int, d: int) -> int:
    """Return the Brill--Noether number rho(g,r,d)."""
    return g - (r + 1) * (g - d + r)


def regular_graph_genus(n: int, k: int) -> int:
    """Return the genus forced by n vertices and regular degree k."""
    if n < 1 or k < 2:
        raise ValueError("require n >= 1 and k >= 2")
    product = n * (k - 2)
    if product % 2:
        raise ValueError("n(k-2) must be even")
    return product // 2 + 1


def admissible_ranks(g: int) -> list[int]:
    """List all r >= 0 with rho(g,r,g-1) >= 0, using exact squares."""
    if g < 1:
        return []
    return list(range(isqrt(g)))


@dataclass(frozen=True)
class CertificateCheck:
    genus: int
    scale: int
    degree: int
    rank: int
    degree_ok: bool
    square_root_rank_ok: bool
    covered_ranks: tuple[int, ...]

    @property
    def valid(self) -> bool:
        return self.degree_ok and self.square_root_rank_ok


def check_certificate(g: int, c: int, degree: int, rank: int) -> CertificateCheck:
    """Test a proposed certificate and report the ranks it proves when valid."""
    if min(g, c, degree, rank) < 0 or c == 0:
        raise ValueError("all inputs must be nonnegative and c must be positive")
    degree_ok = degree <= c * (g - 1)
    rank_ok = g <= (c * rank + 1) ** 2
    covered = tuple(admissible_ranks(g)) if degree_ok and rank_ok else ()
    return CertificateCheck(g, c, degree, rank, degree_ok, rank_ok, covered)


def regular_quadratic_test(n: int, k: int, r: int) -> bool:
    """Test admissibility directly from n, k, and r."""
    return 2 * (r + 1) ** 2 <= n * (k - 2) + 2


def demonstrate(cases: Iterable[tuple[int, int]]) -> None:
    """Print genus and admissible ranks for regular-graph parameter pairs."""
    for n, k in cases:
        g = regular_graph_genus(n, k)
        ranks = admissible_ranks(g)
        assert all(rho(g, r, g - 1) == g - (r + 1) ** 2 for r in ranks)
        assert all(regular_quadratic_test(n, k, r) for r in ranks)
        print(f"n={n:4d}, k={k}: genus={g:5d}, admissible ranks={ranks}")


def main() -> None:
    demonstrate([(10, 5), (50, 6), (100, 8)])
    result = check_certificate(g=101, c=4, degree=300, rank=3)
    print("\nCertificate example:")
    print(result)
    assert result.valid
    assert all(r <= result.scale * result.rank for r in result.covered_ranks)
    print("One divisor covers every admissible rank:", result.covered_ranks)


if __name__ == "__main__":
    main()
