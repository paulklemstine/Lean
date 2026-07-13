"""
Numerical demonstrations of the sharp diagonal correlation inequality on the
discrete cube {0,1}^n with the uniform probability measure.

All functions are self-contained. We verify:

  1. Harris/FKG:            Cov(f, g) >= 0 for increasing observables.
  2. Reverse correlation:   Cov(f, g) <= 0 for f increasing, g decreasing.
  3. Variance bound:        Var(f) <= 1/4 for [0,1]-valued observables.
  4. Cauchy-Schwarz:        Cov(f, g)^2 <= Var(f) * Var(g).
  5. Sharp diagonal bound:  Cov(f, g) <= 1/4 for [0,1]-valued observables.
  6. Dictatorship spectrum: E[dict_i] = 1/2, Var[dict_i] = 1/4,
                            Cov(dict_i, dict_i) = 1/4, Cov(dict_i, dict_j) = 0.
  7. Disjoint-support rigidity: Cov(f, g) = 0 when f, g read complementary blocks.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, List, Tuple

Point = Tuple[int, ...]           # a point of {0,1}^n
Observable = Callable[[Point], float]


def cube(n: int) -> List[Point]:
    """All 2^n points of the discrete cube {0,1}^n."""
    return list(product((0, 1), repeat=n))


def expectation(f: Observable, n: int) -> float:
    """Uniform mean E[f] = 2^{-n} * sum_x f(x)."""
    pts = cube(n)
    return sum(f(x) for x in pts) / len(pts)


def covariance(f: Observable, g: Observable, n: int) -> float:
    """Cov(f, g) = E[f g] - E[f] E[g]."""
    ef = expectation(f, n)
    eg = expectation(g, n)
    efg = expectation(lambda x: f(x) * g(x), n)
    return efg - ef * eg


def variance(f: Observable, n: int) -> float:
    """Var(f) = Cov(f, f)."""
    return covariance(f, f, n)


def dict_obs(i: int) -> Observable:
    """The i-th dictatorship: dict_i(x) = 1 if x_i = 1 else 0."""
    return lambda x: float(x[i])


def is_increasing(f: Observable, n: int) -> bool:
    """Brute-force check that f is monotone for the coordinatewise order."""
    pts = cube(n)
    for x in pts:
        for y in pts:
            if all(xi <= yi for xi, yi in zip(x, y)) and f(x) > f(y) + 1e-12:
                return False
    return True


def demo_harris(n: int = 4) -> None:
    """Harris/FKG and the reverse inequality on concrete monotone observables."""
    print(f"[1-2] Harris and reverse correlation on n = {n}")
    # An increasing majority-like weight and a threshold dictatorship-sum.
    f: Observable = lambda x: sum(x) / n                    # increasing, [0,1]
    g: Observable = lambda x: float(x[0] or x[1])          # increasing, {0,1}
    h: Observable = lambda x: 1.0 - sum(x) / n             # decreasing, [0,1]
    assert is_increasing(f, n) and is_increasing(g, n)
    cfg = covariance(f, g, n)
    cfh = covariance(f, h, n)
    print(f"    Cov(sum/n, x0 OR x1)   = {cfg:+.6f}  (>= 0 expected)")
    print(f"    Cov(sum/n, 1 - sum/n)  = {cfh:+.6f}  (<= 0 expected)")
    assert cfg >= -1e-12 and cfh <= 1e-12


def demo_bounds(n: int = 4) -> None:
    """Variance bound, Cauchy-Schwarz, and the sharp diagonal bound."""
    print(f"[3-5] Variance / Cauchy-Schwarz / diagonal bound on n = {n}")
    observables: List[Tuple[str, Observable]] = [
        ("sum/n", lambda x: sum(x) / n),
        ("dict_0", dict_obs(0)),
        ("x0 AND x1", lambda x: float(x[0] and x[1])),
        ("parity-free ramp", lambda x: (sum(x) >= n / 2) * 1.0),
    ]
    for name, f in observables:
        v = variance(f, n)
        print(f"    Var({name:16s}) = {v:.6f}  (<= 0.25 expected)")
        assert v <= 0.25 + 1e-12 and v >= -1e-12
    for (na, fa), (nb, fb) in zip(observables, observables[1:]):
        c = covariance(fa, fb, n)
        rhs = variance(fa, n) * variance(fb, n)
        print(f"    Cov({na},{nb})^2 = {c*c:.6f} <= {rhs:.6f} = Var*Var")
        assert c * c <= rhs + 1e-12
        assert c <= 0.25 + 1e-12


def demo_dictatorship_spectrum(n: int = 5) -> None:
    """Exact means, variances, and cross-covariances of dictatorships."""
    print(f"[6] Dictatorship spectrum on n = {n}")
    for i in range(n):
        e = expectation(dict_obs(i), n)
        v = variance(dict_obs(i), n)
        print(f"    E[dict_{i}] = {e:.6f}  Var[dict_{i}] = {v:.6f}")
        assert abs(e - 0.5) < 1e-12 and abs(v - 0.25) < 1e-12
    same = covariance(dict_obs(0), dict_obs(0), n)
    diff = covariance(dict_obs(0), dict_obs(1), n)
    print(f"    Cov(dict_0, dict_0) = {same:.6f}  (1/4 expected, extremal)")
    print(f"    Cov(dict_0, dict_1) = {diff:.6f}  (0 expected)")
    assert abs(same - 0.25) < 1e-12 and abs(diff) < 1e-12


def demo_disjoint_support(n: int = 6) -> None:
    """Rigidity: complementary-block observables are exactly uncorrelated."""
    print(f"[7] Disjoint-support rigidity on n = {n}")
    half = n // 2
    # f reads only coordinates {0,...,half-1}; g reads only the complement.
    f: Observable = lambda x: float(any(x[i] for i in range(half)))
    g: Observable = lambda x: sum(x[i] for i in range(half, n)) / (n - half)
    c = covariance(f, g, n)
    print(f"    Cov(f on first half, g on second half) = {c:+.6e}  (0 expected)")
    assert abs(c) < 1e-12


def main() -> None:
    demo_harris()
    demo_bounds()
    demo_dictatorship_spectrum()
    demo_disjoint_support()
    print("\nAll numerical checks passed.")


if __name__ == "__main__":
    main()
