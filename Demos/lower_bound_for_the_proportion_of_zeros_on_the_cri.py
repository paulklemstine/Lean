"""
Numerical demonstrations for:

    A Conditional Lower Bound for the Proportion of Critical-Line Zeros
    of PGL(3) Twisted L-functions

The mathematical content, restated in the finite combinatorial model used
throughout:

    * `total`   -- an index set of all analysed zeros (size N)
    * `onLine`  -- the subset lying on the critical line Re(s) = 1/2
    * `w`       -- a real "detection weight" (mollifier) with the SUPPORT
                   CONDITION: w_i = 0 whenever i is NOT an on-line zero.

    First / second mollified moments:
        M1 = sum_i w_i,      M2 = sum_i w_i^2.

    Cauchy-Schwarz detection inequality (Theorem 3.1):
        M1^2 <= |onLine| * M2.

    Mollified second-moment inequality (the analytic hypothesis):
        (1/9) * M2 * N <= M1^2.

    Conclusion (Theorems 4.1 / 4.2):
        |onLine| >= N/9   and   proportion = |onLine|/N >= 1/9.

Everything below is self-contained standard-library Python.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Sequence


# ---------------------------------------------------------------------------
# Core quantities
# ---------------------------------------------------------------------------
def first_moment(weights: Sequence[float]) -> float:
    """M1 = sum_i w_i."""
    return float(sum(weights))


def second_moment(weights: Sequence[float]) -> float:
    """M2 = sum_i w_i^2."""
    return float(sum(w * w for w in weights))


def proportion(total_size: int, on_line_size: int) -> float:
    """proportion = |onLine| / |total|."""
    if total_size <= 0:
        raise ValueError("total must be non-empty")
    return on_line_size / total_size


def support_condition_holds(
    weights: Sequence[float], on_line: Iterable[int]
) -> bool:
    """Verify w_i = 0 for every index i NOT in `on_line`."""
    on = set(on_line)
    return all(w == 0.0 for i, w in enumerate(weights) if i not in on)


def cauchy_schwarz_detection_ok(
    weights: Sequence[float], on_line_size: int
) -> bool:
    """Check M1^2 <= |onLine| * M2 (Theorem 3.1)."""
    m1 = first_moment(weights)
    m2 = second_moment(weights)
    return m1 * m1 <= on_line_size * m2 + 1e-12


def moment_inequality_ok(weights: Sequence[float], total_size: int) -> bool:
    """Check (1/9) * M2 * N <= M1^2 (the analytic hypothesis)."""
    m1 = first_moment(weights)
    m2 = second_moment(weights)
    return (1.0 / 9.0) * m2 * total_size <= m1 * m1 + 1e-12


# ---------------------------------------------------------------------------
# Certified lower bound
# ---------------------------------------------------------------------------
@dataclass
class Certificate:
    total_size: int
    on_line_size: int
    m1: float
    m2: float
    support_ok: bool
    moment_ineq_ok: bool
    certified_lower_bound: float   # the proven >= 1/9 bound
    observed_proportion: float


def certify(weights: Sequence[float], on_line: Sequence[int]) -> Certificate:
    """
    Given a weight vector and the list of on-line indices, verify the
    hypotheses and return a certificate that the proportion is >= 1/9.
    """
    n = len(weights)
    k = len(set(on_line))
    m1 = first_moment(weights)
    m2 = second_moment(weights)
    support_ok = support_condition_holds(weights, on_line)
    mom_ok = moment_inequality_ok(weights, n)
    # If the hypotheses hold, the theorem guarantees proportion >= 1/9.
    lb = 1.0 / 9.0 if (support_ok and mom_ok and m2 > 0 and n > 0) else 0.0
    return Certificate(
        total_size=n,
        on_line_size=k,
        m1=m1,
        m2=m2,
        support_ok=support_ok,
        moment_ineq_ok=mom_ok,
        certified_lower_bound=lb,
        observed_proportion=proportion(n, k),
    )


# ---------------------------------------------------------------------------
# Cauchy-Schwarz deficit (Section 8.2): the surplus factor 1 + c
# ---------------------------------------------------------------------------
def cauchy_schwarz_deficit(nonzero_weights: Sequence[float]) -> float:
    """
    Return c = variance / mean^2 of the on-line weights.  The proportion
    beats 1/9 by the factor (1 + c); c = 0 iff the weights are all equal
    (Cauchy-Schwarz tight).
    """
    k = len(nonzero_weights)
    if k == 0:
        return 0.0
    mu = sum(nonzero_weights) / k
    if mu == 0.0:
        return 0.0
    var = sum((w - mu) ** 2 for w in nonzero_weights) / k
    return var / (mu * mu)


# ---------------------------------------------------------------------------
# Aggregate over a family of twists (Theorem 6.2)
# ---------------------------------------------------------------------------
def aggregate_proportion(
    per_twist: Sequence[tuple[int, int]]
) -> float:
    """
    `per_twist` is a list of (N_b, onLine_b) pairs.  If each satisfies
    onLine_b >= N_b/9, the pooled proportion is also >= 1/9.
    Returns the pooled proportion (sum onLine) / (sum N).
    """
    tot = sum(n for n, _ in per_twist)
    onl = sum(k for _, k in per_twist)
    if tot == 0:
        raise ValueError("empty family")
    return onl / tot


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_witness() -> None:
    print("=" * 68)
    print("DEMO 1  -- Non-vacuity witness (Theorem 5.1)")
    print("=" * 68)
    # total = {0, 1}, onLine = {0}, w = [1, 0]
    weights = [1.0, 0.0]
    on_line = [0]
    cert = certify(weights, on_line)
    print(f"  total size N            = {cert.total_size}")
    print(f"  onLine size             = {cert.on_line_size}  (proper subset)")
    print(f"  M1                      = {cert.m1}")
    print(f"  M2                      = {cert.m2}")
    print(f"  support condition holds = {cert.support_ok}")
    print(f"  (1/9)*M2*N <= M1^2      = {cert.moment_ineq_ok}"
          f"   [ {1/9*cert.m2*cert.total_size:.4f} <= {cert.m1**2:.4f} ]")
    print(f"  observed proportion     = {cert.observed_proportion:.4f}")
    print(f"  certified lower bound   = {cert.certified_lower_bound:.4f}")
    print()


def demo_uniform() -> None:
    print("=" * 68)
    print("DEMO 2  -- Uniform detector: Cauchy-Schwarz is tight")
    print("=" * 68)
    for n in (9, 18, 90):
        # every zero on-line, uniform weight 1
        weights = [1.0] * n
        on_line = list(range(n))
        cert = certify(weights, on_line)
        c = cauchy_schwarz_deficit([1.0] * n)
        print(f"  N={n:3d}: M1={cert.m1:6.1f}  M2={cert.m2:6.1f}  "
              f"(1/9)M2 N={1/9*cert.m2*n:8.1f} <= M1^2={cert.m1**2:8.1f}  "
              f"prop={cert.observed_proportion:.3f}  deficit c={c:.3f}")
    print("  Uniform weights => deficit c = 0 => bound 1/9 is exactly tight.")
    print()


def demo_deficit() -> None:
    print("=" * 68)
    print("DEMO 3  -- Uneven detector: harvesting the Cauchy-Schwarz slack")
    print("=" * 68)
    configs = {
        "flat":        [1.0, 1.0, 1.0, 1.0],
        "mild spread": [1.0, 1.2, 0.8, 1.5],
        "heavy spread":[0.2, 3.0, 0.1, 2.7],
    }
    for name, w in configs.items():
        c = cauchy_schwarz_deficit(w)
        improved = (1.0 / 9.0) * (1.0 + c)
        print(f"  {name:12s}: c = {c:6.3f}  ->  improved bound "
              f"(1/9)(1+c) = {improved:.4f}")
    print("  Larger weight dispersion => larger surplus over 1/9.")
    print()


def demo_aggregate() -> None:
    print("=" * 68)
    print("DEMO 4  -- Aggregate over a family of twists (Theorem 6.2)")
    print("=" * 68)
    # each twist: (N_b, onLine_b) with onLine_b >= N_b / 9
    family = [(90, 12), (81, 9), (72, 40), (99, 11)]
    for n, k in family:
        ok = k >= n / 9
        print(f"  twist: N={n:3d}  onLine={k:3d}  "
              f"(>= N/9 = {n/9:5.1f})  {'OK' if ok else 'FAIL'}")
    pooled = aggregate_proportion(family)
    print(f"  pooled proportion = {pooled:.4f}  (>= 1/9 = {1/9:.4f}: "
          f"{pooled >= 1/9})")
    print()


def demo_asymptotic() -> None:
    print("=" * 68)
    print("DEMO 5  -- Eventual proportion bound over growing conductor Q")
    print("=" * 68)
    print("  Model: for each Q, weights on the on-line zeros satisfy the")
    print("  moment inequality; we report the certified proportion.")
    for q in (11, 101, 1009, 10007):
        n = q                    # crude model: ~Q zeros analysed
        k = max(1, n // 9 + (q % 7))   # at least N/9 on the line
        weights = [1.0] * k + [0.0] * (n - k)
        on_line = list(range(k))
        cert = certify(weights, on_line)
        print(f"  Q={q:6d}: N={n:6d}  onLine={k:6d}  "
              f"prop={cert.observed_proportion:.4f}  "
              f">=1/9: {cert.observed_proportion >= 1/9 - 1e-9}")
    print()


def main() -> None:
    demo_witness()
    demo_uniform()
    demo_deficit()
    demo_aggregate()
    demo_asymptotic()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
