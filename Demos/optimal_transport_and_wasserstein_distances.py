"""Finite Optimal Transport and Wasserstein Distances --- numerical demonstrations.

This self-contained script illustrates, with concrete numbers, the theorems of the
accompanying paper:

  * existence of an optimal transport plan over the (compact) transportation
    polytope                                            -> exists_optimal_plan
  * permutation plans are feasible and cost the average matched edge
                                                        -> permPlan_isTransportPlan,
                                                           transportCost_permPlan
  * the discrete Brenier theorem: for quadratic cost the monotone (sorted)
    matching is optimal                                 -> brenier_monotone_optimal,
                                                           perm_quadratic_optimal
  * three Wasserstein metric axioms: nonnegativity, self-distance zero, symmetry
                                                        -> wValue_nonneg,
                                                           wValue_self, wValue_symm

Everything is implemented from scratch with the standard library only
(no numpy / scipy), with type hints throughout.
"""

from __future__ import annotations

from itertools import permutations, product
from typing import Callable, List, Sequence, Tuple

Matrix = List[List[float]]
Vector = List[float]


# ---------------------------------------------------------------------------
# Core definitions: transport plans, cost, feasibility
# ---------------------------------------------------------------------------

def transport_cost(d: Matrix, pi: Matrix) -> float:
    """transportCost(d, pi) = sum_{i,j} pi[i][j] * d[i][j]."""
    return sum(pi[i][j] * d[i][j] for i in range(len(pi)) for j in range(len(pi[0])))


def is_transport_plan(pi: Matrix, a: Vector, b: Vector, tol: float = 1e-9) -> bool:
    """Check IsTransportPlan: nonnegativity, row sums = a, column sums = b."""
    n, m = len(a), len(b)
    if any(pi[i][j] < -tol for i in range(n) for j in range(m)):
        return False
    for i in range(n):
        if abs(sum(pi[i][j] for j in range(m)) - a[i]) > tol:
            return False
    for j in range(m):
        if abs(sum(pi[i][j] for i in range(n)) - b[j]) > tol:
            return False
    return True


def independent_coupling(a: Vector, b: Vector) -> Matrix:
    """The product plan pi[i][j] = a[i] * b[j]; always feasible (Remark 3.2)."""
    return [[a[i] * b[j] for j in range(len(b))] for i in range(len(a))]


def perm_plan(sigma: Sequence[int], n: int) -> Matrix:
    """permPlan(sigma): (1/n) on the diagonal j = sigma(i), else 0 (uniform marginals)."""
    pi = [[0.0] * n for _ in range(n)]
    for i in range(n):
        pi[i][sigma[i]] = 1.0 / n
    return pi


# ---------------------------------------------------------------------------
# Brute-force Kantorovich optimum over permutation plans (assignment problem)
# ---------------------------------------------------------------------------

def w_value_perm(d: Matrix) -> Tuple[float, Tuple[int, ...]]:
    """Minimum transport cost over permutation plans of uniform marginals.

    Returns (optimal cost, optimal permutation). This is the assignment-problem
    restriction of the Wasserstein value; by Birkhoff--von Neumann it equals the
    full-polytope optimum for uniform marginals.
    """
    n = len(d)
    best_cost = float("inf")
    best_sigma: Tuple[int, ...] = tuple(range(n))
    for sigma in permutations(range(n)):
        c = transport_cost(d, perm_plan(sigma, n))
        if c < best_cost:
            best_cost, best_sigma = c, sigma
    return best_cost, best_sigma


# ---------------------------------------------------------------------------
# Quadratic cost and the discrete Brenier theorem
# ---------------------------------------------------------------------------

def quadratic_cost(x: Vector, y: Vector) -> Matrix:
    """d[i][j] = (x[i] - y[j])^2."""
    return [[(x[i] - y[j]) ** 2 for j in range(len(y))] for i in range(len(x))]


def monovary(x: Vector, y: Vector) -> bool:
    """Monovary x y: x[i] < x[k] implies y[i] <= y[k] for all i, k."""
    n = len(x)
    return all(
        not (x[i] < x[k]) or (y[i] <= y[k])
        for i in range(n) for k in range(n)
    )


def cross_correlation(x: Vector, y: Vector, sigma: Sequence[int]) -> float:
    """sum_i x[i] * y[sigma(i)]; maximized by the monotone matching (rearrangement)."""
    return sum(x[i] * y[sigma[i]] for i in range(len(x)))


# ---------------------------------------------------------------------------
# Wasserstein metric axioms (verified numerically via the permutation optimum)
# ---------------------------------------------------------------------------

def transpose(pi: Matrix) -> Matrix:
    """Transpose a plan; maps a coupling of (a,b) to a coupling of (b,a)."""
    n, m = len(pi), len(pi[0])
    return [[pi[i][j] for i in range(n)] for j in range(m)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_existence() -> None:
    print("=" * 70)
    print("1. EXISTENCE OF AN OPTIMAL PLAN (exists_optimal_plan)")
    print("=" * 70)
    a: Vector = [0.5, 0.3, 0.2]
    b: Vector = [0.2, 0.5, 0.3]
    d: Matrix = [[0.0, 1.0, 2.0], [1.0, 0.0, 1.0], [2.0, 1.0, 0.0]]
    pi0 = independent_coupling(a, b)
    print(f"Independent coupling feasible? {is_transport_plan(pi0, a, b)}")
    print(f"Independent coupling cost      = {transport_cost(d, pi0):.4f}")
    # Sample the polytope on a fine grid to witness that an optimum is attained.
    best = min(
        transport_cost(d, pi0),
        # search a few feasible plans by perturbing toward the diagonal
        *[transport_cost(d, p) for p in _feasible_samples(a, b)],
    )
    print(f"Best sampled feasible cost     = {best:.4f}")
    print("A continuous cost on the compact polytope attains its minimum.\n")


def _feasible_samples(a: Vector, b: Vector) -> List[Matrix]:
    """Generate a handful of feasible plans by mixing the product plan with the
    'greedy diagonal' plan, witnessing that lower costs are achievable."""
    n, m = len(a), len(b)
    prod = independent_coupling(a, b)
    samples: List[Matrix] = []
    for t in (0.25, 0.5, 0.75, 1.0):
        # northwest-corner feasible plan
        nw = [[0.0] * m for _ in range(n)]
        ra, rb = a[:], b[:]
        for i in range(n):
            for j in range(m):
                amt = min(ra[i], rb[j])
                nw[i][j] = amt
                ra[i] -= amt
                rb[j] -= amt
        mix = [[(1 - t) * prod[i][j] + t * nw[i][j] for j in range(m)] for i in range(n)]
        samples.append(mix)
    return samples


def demo_permutation_plans() -> None:
    print("=" * 70)
    print("2. PERMUTATION PLANS (permPlan_isTransportPlan, transportCost_permPlan)")
    print("=" * 70)
    n = 4
    d: Matrix = [[abs(i - j) for j in range(n)] for i in range(n)]
    sigma = (2, 0, 3, 1)
    pi = perm_plan(sigma, n)
    a = [1.0 / n] * n
    print(f"Permutation sigma = {sigma}")
    print(f"permPlan feasible (uniform marginals)? {is_transport_plan(pi, a, a)}")
    direct = transport_cost(d, pi)
    formula = sum(d[i][sigma[i]] for i in range(n)) / n
    print(f"transportCost(permPlan sigma)  = {direct:.4f}")
    print(f"(1/n) * sum_i d[i, sigma(i)]    = {formula:.4f}")
    print(f"Match: {abs(direct - formula) < 1e-12}\n")


def demo_brenier() -> None:
    print("=" * 70)
    print("3. DISCRETE BRENIER THEOREM (brenier_monotone_optimal,")
    print("   perm_quadratic_optimal)")
    print("=" * 70)
    x = sorted([0.1, 0.9, 0.4, 0.6])
    y = sorted([0.2, 0.5, 0.8, 1.3])  # sorting both => monovary
    print(f"x (sorted) = {x}")
    print(f"y (sorted) = {y}")
    print(f"monovary(x, y)? {monovary(x, y)}")
    d = quadratic_cost(x, y)
    n = len(x)
    identity = tuple(range(n))
    id_cost = transport_cost(d, perm_plan(identity, n))
    opt_cost, opt_sigma = w_value_perm(d)
    print(f"Quadratic cost of identity matching = {id_cost:.4f}")
    print(f"Brute-force optimal matching         = {opt_sigma} with cost {opt_cost:.4f}")
    print(f"Identity is optimal? {opt_sigma == identity}")
    # Show the rearrangement-inequality mechanism: identity maximizes cross term.
    cross_id = cross_correlation(x, y, identity)
    cross_max = max(cross_correlation(x, y, s) for s in permutations(range(n)))
    print(f"Cross term sum_i x_i y_i             = {cross_id:.4f}")
    print(f"Max cross term over permutations     = {cross_max:.4f}")
    print(f"Identity maximizes cross term? {abs(cross_id - cross_max) < 1e-12}\n")


def demo_metric_axioms() -> None:
    print("=" * 70)
    print("4. WASSERSTEIN METRIC AXIOMS (wValue_nonneg, wValue_self, wValue_symm)")
    print("=" * 70)
    # A genuine distance kernel on {0,1,2}: d[i][j] = |i - j|.
    n = 3
    d: Matrix = [[float(abs(i - j)) for j in range(n)] for i in range(n)]

    # wValue_nonneg
    cost_ab, _ = w_value_perm(d)
    print(f"wValue_nonneg : optimal cost = {cost_ab:.4f} >= 0  -> {cost_ab >= 0}")

    # wValue_self: cost of moving uniform onto itself is 0 (identity matching).
    self_cost = transport_cost(d, perm_plan(tuple(range(n)), n))
    print(f"wValue_self   : cost of identity coupling = {self_cost:.4f} (== 0)")

    # wValue_symm: transpose any plan; cost is preserved when d is symmetric.
    sigma = (1, 2, 0)
    pi = perm_plan(sigma, n)
    c_forward = transport_cost(d, pi)
    c_back = transport_cost(d, transpose(pi))  # d symmetric => same cost
    print(f"wValue_symm   : cost(pi) = {c_forward:.4f}, cost(pi^T) = {c_back:.4f}"
          f"  -> equal: {abs(c_forward - c_back) < 1e-12}\n")


def main() -> None:
    print("\nFINITE OPTIMAL TRANSPORT & WASSERSTEIN DISTANCES --- NUMERICAL DEMO\n")
    demo_existence()
    demo_permutation_plans()
    demo_brenier()
    demo_metric_axioms()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
