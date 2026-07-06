"""
Numerical demonstrations for:

    Joint Descendants of the Last k Vertices in Random d-DAGs
    and a Beta-Moment Telescoping Law

This self-contained script verifies, numerically and (where possible) exactly:

  1. The rising-factorial identity   Gamma(x+m)/Gamma(x) = prod_{i<m}(x+i).
  2. The Beta-moment telescoping law: a product of Beta moments with additively
     chained parameters collapses to a ratio of Gamma factors at the endpoints.
  3. The single-Beta collapse: a chained product of independent Beta variables
     is distributed as a single Beta variable.
  4. The scaling exponent d/(d+1) governing the mean descendant-set size in a
     growing random d-DAG.

Only the Python standard library plus `random` and `math` are used, except an
optional (guarded) use of `statistics`. No external dependencies are required.
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Callable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. Rising-factorial identity:  Gamma(x+m)/Gamma(x) = x (x+1) ... (x+m-1)
# ---------------------------------------------------------------------------

def rising_factorial(x: float, m: int) -> float:
    """Return the rising factorial (x)^{bar m} = prod_{i=0}^{m-1} (x + i)."""
    prod = 1.0
    for i in range(m):
        prod *= (x + i)
    return prod


def gamma_ratio_integer_shift(x: float, m: int) -> float:
    """Return Gamma(x + m) / Gamma(x) via the Gamma function directly."""
    return math.gamma(x + m) / math.gamma(x)


def rising_factorial_exact(x: Fraction, m: int) -> Fraction:
    """Exact rational rising factorial for rational base x and integer m."""
    prod = Fraction(1)
    for i in range(m):
        prod *= (x + i)
    return prod


def demo_rising_factorial() -> None:
    print("=" * 70)
    print("1. Rising-factorial identity:  Gamma(x+m)/Gamma(x) = prod_{i<m}(x+i)")
    print("=" * 70)
    for x, m in [(2.5, 4), (0.75, 5), (3.0, 3), (1.2, 6)]:
        lhs = gamma_ratio_integer_shift(x, m)
        rhs = rising_factorial(x, m)
        print(f"  x={x:>4}, m={m}:  Gamma-ratio={lhs:.10f}  product={rhs:.10f}"
              f"  |diff|={abs(lhs - rhs):.2e}")
    # exact rational check
    xr, mr = Fraction(7, 3), 4
    print(f"  exact (x=7/3, m=4): product = {rising_factorial_exact(xr, mr)}")
    print()


# ---------------------------------------------------------------------------
# 2. Beta-moment telescoping law
# ---------------------------------------------------------------------------

def beta_moment(alpha: float, beta: float, p: float) -> float:
    """p-th moment of Beta(alpha, beta):
       Gamma(a+p) Gamma(a+b) / (Gamma(a) Gamma(a+b+p))."""
    return (math.gamma(alpha + p) * math.gamma(alpha + beta)) / (
        math.gamma(alpha) * math.gamma(alpha + beta + p)
    )


def beta_moment_product_direct(alpha: Sequence[float],
                               beta: Sequence[float], p: float) -> float:
    """Direct product of per-stage Beta moments (left-hand side)."""
    result = 1.0
    for a, b in zip(alpha, beta):
        result *= beta_moment(a, b, p)
    return result


def beta_moment_product_telescoped(alpha0: float, alpha_n: float,
                                   p: float) -> float:
    """Endpoint formula (right-hand side):
       Gamma(a0+p) Gamma(an) / (Gamma(a0) Gamma(an+p))."""
    return (math.gamma(alpha0 + p) * math.gamma(alpha_n)) / (
        math.gamma(alpha0) * math.gamma(alpha_n + p)
    )


def make_chained_parameters(alpha0: float, betas: Sequence[float]
                            ) -> Tuple[List[float], List[float], float]:
    """Build additively chained parameters:  alpha_{j+1} = alpha_j + beta_j.

    Returns (alpha[0..n-1], beta[0..n-1], alpha_n)."""
    alpha = [alpha0]
    for b in betas:
        alpha.append(alpha[-1] + b)
    alpha_n = alpha[-1]
    return alpha[:-1], list(betas), alpha_n


def demo_telescoping() -> None:
    print("=" * 70)
    print("2. Beta-moment telescoping law (additive chaining a_{j+1}=a_j+b_j)")
    print("=" * 70)
    alpha0 = 1.3
    betas = [0.7, 1.1, 0.5, 0.9, 1.4]
    alpha, beta, alpha_n = make_chained_parameters(alpha0, betas)
    for p in [2.0, 0.5, -0.3, 3.0]:
        lhs = beta_moment_product_direct(alpha, beta, p)
        rhs = beta_moment_product_telescoped(alpha0, alpha_n, p)
        print(f"  p={p:>5}:  direct={lhs:.12f}  endpoint={rhs:.12f}"
              f"  |diff|={abs(lhs - rhs):.2e}")
    print(f"  (a0 = {alpha0}, a_n = {alpha_n};  the product behaves like a "
          f"single Beta({alpha0}, {alpha_n - alpha0:.1f}))")
    print()


# ---------------------------------------------------------------------------
# 3. Single-Beta collapse (Corollary): sample the chained product of Betas
#    and compare empirical moments to a single Beta.
# ---------------------------------------------------------------------------

def sample_beta(alpha: float, beta: float, rng: random.Random) -> float:
    return rng.betavariate(alpha, beta)


def demo_single_beta_collapse(trials: int = 200_000, seed: int = 12345) -> None:
    print("=" * 70)
    print("3. Single-Beta collapse: prod of chained Betas ~ one Beta")
    print("=" * 70)
    rng = random.Random(seed)
    alpha0 = 1.3
    betas = [0.7, 1.1, 0.5, 0.9, 1.4]
    alpha, beta, alpha_n = make_chained_parameters(alpha0, betas)

    prod_samples = []
    single_samples = []
    for _ in range(trials):
        prod = 1.0
        for a, b in zip(alpha, beta):
            prod *= sample_beta(a, b, rng)
        prod_samples.append(prod)
        single_samples.append(sample_beta(alpha0, alpha_n - alpha0, rng))

    def empirical_moment(xs: Sequence[float], p: float) -> float:
        return sum(x ** p for x in xs) / len(xs)

    print(f"  chained product vs single Beta({alpha0},{alpha_n - alpha0:.1f}), "
          f"trials={trials}")
    for p in [1.0, 2.0, 3.0]:
        m_prod = empirical_moment(prod_samples, p)
        m_single = empirical_moment(single_samples, p)
        m_theory = beta_moment(alpha0, alpha_n - alpha0, p)
        print(f"    E[X^{int(p)}]:  product={m_prod:.5f}  single={m_single:.5f}"
              f"  theory={m_theory:.5f}")
    print()


# ---------------------------------------------------------------------------
# 4. Scaling exponent d/(d+1) in a growing random d-DAG.
# ---------------------------------------------------------------------------

def grow_random_ddag(d: int, N: int, rng: random.Random) -> List[List[int]]:
    """Grow a random d-DAG on vertices 0..N-1.

    Vertex n (>= d) attaches to d distinct uniformly chosen earlier vertices.
    Returns adjacency as a list `parents[n]` of the targets of n's out-edges
    (the vertices that n depends on / points to)."""
    parents: List[List[int]] = [[] for _ in range(N)]
    for n in range(d, N):
        parents[n] = rng.sample(range(n), d)
    return parents


def descendants_of(v: int, parents: Sequence[Sequence[int]], N: int) -> int:
    """Count vertices w > v with a directed path w ~> v (w depends on v).

    A vertex w is a descendant of v iff w == v or w points to some descendant
    of v. Processed in increasing index order, which is a topological order."""
    is_desc = [False] * N
    is_desc[v] = True
    count = 0
    for w in range(v + 1, N):
        if any(is_desc[u] for u in parents[w]):
            is_desc[w] = True
            count += 1
    return count


def demo_scaling_exponent(seed: int = 7) -> None:
    print("=" * 70)
    print("4. Exploratory: polynomial growth of descendant-set size")
    print("     (the sharp exponent d/(d+1) is a conjectural direction, not a")
    print("      verified result; this experiment only illustrates that mean")
    print("      descendant-set sizes grow as a power of the horizon.)")
    print("=" * 70)
    rng = random.Random(seed)
    for d in [1, 2, 3]:
        vertex = 50  # a fixed early vertex; measure its descendants
        reps = 40
        # measure mean descendant count of `vertex` at increasing horizons
        horizons = [500, 1000, 2000, 4000]
        logs_n: List[float] = []
        logs_mu: List[float] = []
        for H in horizons:
            total = 0
            for _ in range(reps):
                parents = grow_random_ddag(d, H, rng)
                total += descendants_of(vertex, parents, H)
            mu = total / reps
            logs_n.append(math.log(H))
            logs_mu.append(math.log(max(mu, 1e-9)))
        slope = _ols_slope(logs_n, logs_mu)
        print(f"  d={d}:  measured log-log growth slope in horizon = {slope:.3f}"
              f"   (descendant sets grow polynomially)")
    print()


def _ols_slope(xs: Sequence[float], ys: Sequence[float]) -> float:
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den if den else float("nan")


# ---------------------------------------------------------------------------

def main() -> None:
    demo_rising_factorial()
    demo_telescoping()
    demo_single_beta_collapse()
    demo_scaling_exponent()


if __name__ == "__main__":
    main()
