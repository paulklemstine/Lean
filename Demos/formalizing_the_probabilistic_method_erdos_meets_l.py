"""
Numerical demonstrations for the constructive core of the probabilistic method.

This self-contained script illustrates three landmark results:

  1. Erdos's Ramsey lower bound  R(k,k) > 2^{k/2}, via the finite union-bound
     count  2 * C(n,k) < 2^{C(k,2)}.
  2. The Lovasz Local Lemma:
       - the first-moment / union-bound principle,
       - the independent-case product formula  P(no bad event) = prod (1 - p_i),
       - the Moser-Tardos resampling algorithm (constructive LLL).
  3. Turan's theorem: a K_{r+1}-free graph on n vertices has at most
     (1 - 1/r) n^2 / 2 edges, attained by the explicit Turan graph.

Everything is pure standard-library Python with type hints.
"""

from __future__ import annotations

import math
import random
from itertools import combinations
from typing import Callable, Dict, List, Tuple


# ---------------------------------------------------------------------------
# 1. Erdos's Ramsey lower bound by finite counting
# ---------------------------------------------------------------------------

def erdos_counting_holds(n: int, k: int) -> bool:
    """Return True iff the Erdos counting hypothesis 2*C(n,k) < 2^{C(k,2)} holds.

    When True, there exists a red/blue edge-coloring of K_n with no
    monochromatic K_k, i.e. R(k,k) > n.
    """
    return 2 * math.comb(n, k) < 2 ** math.comb(k, 2)


def expected_mono_cliques(n: int, k: int) -> float:
    """Expected number of monochromatic K_k under a uniform random coloring of K_n.

    Equal to 2 * C(n,k) * 2^{-C(k,2)}.  When < 1, a clique-free coloring exists.
    """
    return 2.0 * math.comb(n, k) * 2.0 ** (-math.comb(k, 2))


def erdos_lower_bound(k: int) -> int:
    """Largest n we can certify with n = 2^{floor(k/2)} giving R(k,k) > n."""
    return 2 ** (k // 2)


def demo_ramsey() -> None:
    print("=" * 70)
    print("1. ERDOS RAMSEY LOWER BOUND  R(k,k) > 2^{k/2}")
    print("=" * 70)
    print(f"{'k':>3} {'n=2^floor(k/2)':>16} {'E[#mono cliques]':>20} {'R(k,k)>n?':>12}")
    for k in range(3, 12):
        n = erdos_lower_bound(k)
        exp = expected_mono_cliques(n, k)
        ok = erdos_counting_holds(n, k)
        print(f"{k:>3} {n:>16} {exp:>20.6f} {str(ok):>12}")

    print("\nConcrete small cases certified by counting:")
    for n, k in [(5, 4), (8, 6)]:
        lhs, rhs = 2 * math.comb(n, k), 2 ** math.comb(k, 2)
        print(f"  R({k},{k}) > {n}:  2*C({n},{k}) = {lhs} < 2^C({k},2) = {rhs}"
              f"  -> {lhs < rhs}")


# ---------------------------------------------------------------------------
# 2a. First-moment / union-bound principle
# ---------------------------------------------------------------------------

def union_bound_positive(probs: List[float]) -> Tuple[bool, float]:
    """First-moment principle.

    If sum(probs) < 1 then P(no bad event) >= 1 - sum(probs) > 0.
    Returns (guarantee_holds, lower_bound_on_prob_all_good).
    """
    s = sum(probs)
    return (s < 1.0, max(0.0, 1.0 - s))


# ---------------------------------------------------------------------------
# 2b. Independent Lovasz Local Lemma: exact product formula
# ---------------------------------------------------------------------------

def independent_all_good(probs: List[float]) -> float:
    """For mutually independent bad events, P(no bad event) = prod (1 - p_i)."""
    out = 1.0
    for p in probs:
        out *= (1.0 - p)
    return out


def demo_lll_principles() -> None:
    print("\n" + "=" * 70)
    print("2. LOVASZ LOCAL LEMMA PRINCIPLES")
    print("=" * 70)

    probs = [0.1, 0.2, 0.15, 0.05]
    ok, lb = union_bound_positive(probs)
    print(f"Union bound: p = {probs}, sum = {sum(probs):.3f}")
    print(f"  guarantee P(all good) > 0 ? {ok};  lower bound = {lb:.3f}")

    many = [0.3] * 5  # sum = 1.5 > 1, union bound FAILS...
    ok2, _ = union_bound_positive(many)
    exact = independent_all_good(many)
    print(f"\nIndependent case: p = {many}, sum = {sum(many):.3f}")
    print(f"  union bound guarantee? {ok2}  (fails: sum >= 1)")
    print(f"  but if independent, exact P(all good) = prod(1-p_i) = {exact:.5f} > 0")


# ---------------------------------------------------------------------------
# 2c. Moser-Tardos constructive LLL on a k-SAT instance
# ---------------------------------------------------------------------------

Clause = List[Tuple[int, bool]]  # list of (variable_index, required_polarity)


def clause_satisfied(clause: Clause, assign: Dict[int, bool]) -> bool:
    """A clause is satisfied if at least one literal matches the assignment."""
    return any(assign[v] == polarity for v, polarity in clause)


def moser_tardos(
    num_vars: int,
    clauses: List[Clause],
    rng: random.Random,
    max_steps: int = 100_000,
) -> Tuple[Dict[int, bool], int]:
    """Moser-Tardos resampling algorithm for the constructive LLL.

    Sample all variables; while some clause is violated, pick one and resample
    exactly the variables it depends on.  Under e*p*(d+1) <= 1 this terminates
    in expected O(#clauses) resamplings.  Returns (assignment, #resamplings).
    """
    assign: Dict[int, bool] = {v: rng.random() < 0.5 for v in range(num_vars)}
    steps = 0
    while steps < max_steps:
        violated = [c for c in clauses if not clause_satisfied(c, assign)]
        if not violated:
            return assign, steps
        c = rng.choice(violated)
        for v, _ in c:                      # resample the clause's variables
            assign[v] = rng.random() < 0.5
        steps += 1
    return assign, steps


def demo_moser_tardos() -> None:
    print("\n" + "=" * 70)
    print("2c. MOSER-TARDOS CONSTRUCTIVE LLL (random k-SAT)")
    print("=" * 70)
    rng = random.Random(2026)
    num_vars, k, num_clauses = 40, 5, 60   # sparse => LLL condition holds
    clauses: List[Clause] = []
    for _ in range(num_clauses):
        vs = rng.sample(range(num_vars), k)
        clauses.append([(v, rng.random() < 0.5) for v in vs])

    total_steps = 0
    trials = 20
    for _ in range(trials):
        assign, steps = moser_tardos(num_vars, clauses, rng)
        assert all(clause_satisfied(c, assign) for c in clauses)
        total_steps += steps
    print(f"vars={num_vars}, clause width k={k}, clauses={num_clauses}")
    print(f"  all {trials} runs found a satisfying assignment")
    print(f"  average resamplings until success: {total_steps / trials:.1f}")


# ---------------------------------------------------------------------------
# 3. Turan's theorem and the explicit Turan graph
# ---------------------------------------------------------------------------

def turan_graph_edges(n: int, r: int) -> int:
    """Number of edges of the Turan graph T(n, r): complete r-partite, balanced."""
    sizes = [n // r + (1 if i < n % r else 0) for i in range(r)]
    total = n * (n - 1) // 2
    within = sum(s * (s - 1) // 2 for s in sizes)   # non-edges (inside parts)
    return total - within


def turan_bound(n: int, r: int) -> float:
    """Turan's upper bound (1 - 1/r) * n^2 / 2 on edges of a K_{r+1}-free graph."""
    return (1.0 - 1.0 / r) * n * n / 2.0


def max_clique_size(n: int, adj: List[List[bool]]) -> int:
    """Brute-force maximum clique size (small n only), to verify K_{r+1}-freeness."""
    best = 0
    verts = list(range(n))
    for size in range(n, 0, -1):
        if size <= best:
            break
        for combo in combinations(verts, size):
            if all(adj[a][b] for a, b in combinations(combo, 2)):
                return size
    return best


def demo_turan() -> None:
    print("\n" + "=" * 70)
    print("3. TURAN'S THEOREM  |E| <= (1 - 1/r) n^2 / 2")
    print("=" * 70)
    print(f"{'n':>4} {'r':>3} {'T(n,r) edges':>14} {'bound':>12} {'<= bound?':>10}")
    for n, r in [(6, 2), (9, 3), (10, 3), (12, 4), (15, 5)]:
        e = turan_graph_edges(n, r)
        b = turan_bound(n, r)
        print(f"{n:>4} {r:>3} {e:>14} {b:>12.2f} {str(e <= b + 1e-9):>10}")

    # verify the Turan graph is actually K_{r+1}-free for a small case
    n, r = 9, 3
    parts = [i % r for i in range(n)]
    adj = [[parts[i] != parts[j] and i != j for j in range(n)] for i in range(n)]
    omega = max_clique_size(n, adj)
    print(f"\nT({n},{r}) largest clique = {omega} (must be <= r = {r}, "
          f"so K_{{{r+1}}}-free: {omega <= r})")


# ---------------------------------------------------------------------------

def main() -> None:
    demo_ramsey()
    demo_lll_principles()
    demo_moser_tardos()
    demo_turan()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
