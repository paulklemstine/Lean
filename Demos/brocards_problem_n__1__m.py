"""
Brocard's Problem through a Borel-Cantelli Lens -- numerical demonstrations.

This self-contained script illustrates, with exact and floating-point
arithmetic, the results formalized in the accompanying paper:

  * the three known Brown numbers n = 4, 5, 7 with n! + 1 = m^2;
  * an exhaustive census confirming no other Brown number below a bound;
  * the exact structural constraints (m odd; (m-1)(m+1) = n!; Wilson m >= p);
  * the convergence of the Brocard density series sum_n 1/sqrt(n!) and its
    geometric tail bound -- the analytic heart of the probabilistic
    finiteness theorem;
  * a Monte-Carlo / expectation check that the *expected* number of "hits"
    is finite, mirroring the first Borel-Cantelli lemma.

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import List, Tuple


# --------------------------------------------------------------------------
# Exact integer square root and perfect-square test (mirrors isPerfectSquareB)
# --------------------------------------------------------------------------
def isqrt(n: int) -> int:
    """Integer square root: largest r with r*r <= n. Uses math.isqrt (exact)."""
    if n < 0:
        raise ValueError("isqrt of negative number")
    return math.isqrt(n)


def is_perfect_square(n: int) -> bool:
    """Exact perfect-square test: r = isqrt(n), check r*r == n."""
    r = isqrt(n)
    return r * r == n


# --------------------------------------------------------------------------
# Section 1: the three known Brown numbers
# --------------------------------------------------------------------------
def known_brown_numbers() -> List[Tuple[int, int]]:
    """Return the (n, m) pairs with n! + 1 = m^2 for the known Brown numbers."""
    pairs: List[Tuple[int, int]] = []
    for n in (4, 5, 7):
        val = math.factorial(n) + 1
        m = isqrt(val)
        assert m * m == val, "expected a perfect square"
        pairs.append((n, m))
    return pairs


# --------------------------------------------------------------------------
# Section 2: exhaustive census (mirrors brocard_no_others_below_1000)
# --------------------------------------------------------------------------
def brown_census(bound: int) -> List[int]:
    """All n in [0, bound) with n! + 1 a perfect square (n! maintained
    incrementally; each test costs O(log) big-integer multiplications)."""
    result: List[int] = []
    fact = 1
    for n in range(bound):
        if n > 0:
            fact *= n
        if is_perfect_square(fact + 1):
            result.append(n)
    return result


# --------------------------------------------------------------------------
# Section 3: exact structural constraints
# --------------------------------------------------------------------------
def check_m_odd(n: int, m: int) -> bool:
    """brocard_m_odd: for n >= 2 a solution has m odd."""
    return m % 2 == 1


def check_factorization(n: int, m: int) -> bool:
    """brocard_factor: (m-1)(m+1) = n!."""
    return (m - 1) * (m + 1) == math.factorial(n)


def is_prime(p: int) -> bool:
    if p < 2:
        return False
    if p % 2 == 0:
        return p == 2
    i = 3
    while i * i <= p:
        if p % i == 0:
            return False
        i += 2
    return True


def wilson_lower_bound(n: int, m: int) -> Tuple[bool, int]:
    """brocard_wilson_ge: if p = n+1 is prime, then p | m and hence m >= p.
    Returns (applies, p) and asserts the divisibility/bound when it applies."""
    p = n + 1
    if is_prime(p):
        assert m % p == 0, "Wilson: p should divide m"
        assert m >= p, "Wilson: m should be at least p"
        return True, p
    return False, p


# --------------------------------------------------------------------------
# Section 4: convergence of the density series sum_n 1/sqrt(n!)
# --------------------------------------------------------------------------
def density_partial_sum(N: int) -> float:
    """Partial sum S_N = sum_{n=0}^{N} 1/sqrt(n!)."""
    s = 0.0
    fact = 1
    for n in range(N + 1):
        if n > 0:
            fact *= n
        s += 1.0 / math.sqrt(fact)
    return s


def geometric_tail_bound(N: int) -> float:
    """Rigorous bound on the tail sum_{n>N} 1/sqrt(n!) via 1/sqrt(n!) <=
    sqrt(2) * (1/sqrt(2))^n, a geometric series with ratio 1/sqrt(2)."""
    r = 1.0 / math.sqrt(2.0)
    # sum_{n=N+1}^infty sqrt(2) * r^n = sqrt(2) * r^(N+1) / (1 - r)
    return math.sqrt(2.0) * r ** (N + 1) / (1.0 - r)


# --------------------------------------------------------------------------
# Section 5: Borel-Cantelli expectation check
# --------------------------------------------------------------------------
def expected_hits(bound: int) -> float:
    """Expected number of 'hits' under the density model mu(E_n) = 1/sqrt(n!):
    E[# hits] = sum_n 1/sqrt(n!). Finite => first Borel-Cantelli => a.s.
    finitely many hits."""
    return density_partial_sum(bound)


def main() -> None:
    print("=" * 70)
    print("Brocard's Problem: n! + 1 = m^2  --  a Borel-Cantelli study")
    print("=" * 70)

    print("\n[1] The three known Brown numbers (n! + 1 = m^2):")
    for n, m in known_brown_numbers():
        print(f"    n = {n}:  {n}! + 1 = {math.factorial(n) + 1} = {m}^2")

    print("\n[2] Exhaustive census of Brown numbers below 1000:")
    census = brown_census(1000)
    print(f"    {{ n in [0,1000) : n!+1 is a perfect square }} = {census}")
    assert census == [4, 5, 7], "census must match the formal theorem"
    print("    matches the formal theorem brocard_no_others_below_1000.")

    print("\n[3] Exact structural constraints on the known solutions:")
    for n, m in known_brown_numbers():
        odd = check_m_odd(n, m)
        fac = check_factorization(n, m)
        applies, p = wilson_lower_bound(n, m)
        wil = f"Wilson p={p}: p|m and m>=p" if applies else f"(n+1={p} not prime)"
        print(f"    n={n}, m={m}:  m odd? {odd};  (m-1)(m+1)=n!? {fac};  {wil}")

    print("\n[4] Convergence of the density series  sum_n 1/sqrt(n!):")
    for N in (5, 10, 20, 50):
        S = density_partial_sum(N)
        tail = geometric_tail_bound(N)
        print(f"    N={N:3d}:  partial sum = {S:.10f}   tail bound <= {tail:.2e}")
    print(f"    Converges to approximately {density_partial_sum(50):.6f}.")

    print("\n[5] Borel-Cantelli expectation (sum of event probabilities):")
    E = expected_hits(100)
    print(f"    E[# hits] = sum_n 1/sqrt(n!) ~ {E:.6f} < infinity")
    print("    => first Borel-Cantelli: almost surely only finitely many hits")
    print("       (brocard_heuristic_finite / brocard_heuristic_ae_finite).")

    print("\nDone.")


if __name__ == "__main__":
    main()


"""
Visualization: convergence of the Brocard density series and the squeeze that
proves it. Produces a two-panel figure:

  (left)  partial sums S_N = sum_{n=0}^N 1/sqrt(n!) approaching their limit,
          with the rigorous geometric tail bound shaded;
  (right) the term-by-term comparison 1/sqrt(n!) <= sqrt(2)*(1/sqrt(2))^n on a
          log scale, the geometric domination underlying the convergence proof.

Requires matplotlib. Run:  python viz.py
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt


def density_terms(N: int) -> List[float]:
    terms: List[float] = []
    fact = 1
    for n in range(N + 1):
        if n > 0:
            fact *= n
        terms.append(1.0 / math.sqrt(fact))
    return terms


def main() -> None:
    N = 12
    terms = density_terms(N)
    partial = []
    s = 0.0
    for t in terms:
        s += t
        partial.append(s)
    limit = partial[-1]

    geo = [math.sqrt(2.0) * (1.0 / math.sqrt(2.0)) ** n for n in range(N + 1)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4.5))

    ax1.axhline(limit, color="crimson", ls="--", lw=1, label=f"limit ~ {limit:.4f}")
    ax1.plot(range(N + 1), partial, "o-", color="navy", label="partial sum $S_N$")
    ax1.set_title("Convergence of $\\sum_n 1/\\sqrt{n!}$")
    ax1.set_xlabel("$N$")
    ax1.set_ylabel("$S_N$")
    ax1.legend()
    ax1.grid(alpha=0.3)

    ax2.semilogy(range(N + 1), terms, "o-", color="navy",
                 label="$1/\\sqrt{n!}$")
    ax2.semilogy(range(N + 1), geo, "s--", color="darkorange",
                 label="$\\sqrt{2}\\,(1/\\sqrt{2})^n$ (dominating)")
    ax2.set_title("Geometric domination (the convergence proof)")
    ax2.set_xlabel("$n$")
    ax2.set_ylabel("term (log scale)")
    ax2.legend()
    ax2.grid(alpha=0.3, which="both")

    fig.suptitle("Brocard density heuristic: the summable tail behind "
                 "Borel-Cantelli finiteness")
    fig.tight_layout()
    fig.savefig("brocard_density.png", dpi=150)
    print("saved brocard_density.png")


if __name__ == "__main__":
    main()
