"""
Numerical demonstrations for
"Analogy as a Mathematical Operation: Metric Fidelity, Adjoint Structure,
and Tropical Optimization."

Each demo is self-contained (all helpers inlined) and prints results that
illustrate the paper's theorems:

  * distortion / fidelity of an analogy and the perfect copycat baseline,
  * the triangle inequality for analogies (composition bound),
  * the collapse counterexample (perfect one-sided analogy != equivalence),
  * Galois adjoint round trips as closure operators + uniqueness,
  * best-analogy selection as a single tropical (min-plus) sum.

Run:  python demo.py
"""

from __future__ import annotations

from math import inf
from typing import Callable, Dict, List, Sequence, Tuple, TypeVar

A = TypeVar("A")
B = TypeVar("B")
C = TypeVar("C")


# ---------------------------------------------------------------------------
# Core: analogies on finite metric samples
# ---------------------------------------------------------------------------
def distortion(
    sample: Sequence[A],
    forward: Callable[[A], B],
    backward: Callable[[B], A],
    dist: Callable[[A, A], float],
) -> float:
    """Round-trip distortion sup_a dist(a, backward(forward(a))) over a sample."""
    return max(dist(a, backward(forward(a))) for a in sample)


def is_fidelity(
    sample: Sequence[A],
    forward: Callable[[A], B],
    backward: Callable[[B], A],
    dist: Callable[[A, A], float],
    eps: float,
) -> bool:
    """Does the analogy have fidelity eps (distortion <= eps) on the sample?"""
    return distortion(sample, forward, backward, dist) <= eps + 1e-12


def demo_fidelity_and_copycat() -> None:
    print("=" * 68)
    print("DEMO 1: distortion, fidelity, and the perfect copycat")
    print("=" * 68)
    d = lambda x, y: abs(x - y)
    grid = [i / 4 for i in range(-8, 9)]  # -2.0 .. 2.0

    # Copycat: identity out and back -> distortion 0 (Theorem: copycat fidelity).
    print(f"copycat distortion            = {distortion(grid, lambda x: x, lambda y: y, d):.4f}")

    # A rounding analogy A=R -> B=Z -> A=R. Distortion = worst rounding error.
    fwd = lambda x: round(x)          # forward: real -> integer
    bwd = lambda n: float(n)          # backward: integer -> real
    print(f"rounding analogy distortion   = {distortion(grid, fwd, bwd, d):.4f}")
    print(f"  has fidelity 0.25?          = {is_fidelity(grid, fwd, bwd, d, 0.25)}")
    print(f"  has fidelity 0.10?          = {is_fidelity(grid, fwd, bwd, d, 0.10)}")

    # A scaling analogy that is a perfect left-inverse: distortion 0.
    fwd2 = lambda x: 3.0 * x
    bwd2 = lambda y: y / 3.0
    print(f"exact scaling distortion      = {distortion(grid, fwd2, bwd2, d):.4f}")
    print()


# ---------------------------------------------------------------------------
# Composition: triangle inequality for analogies
# ---------------------------------------------------------------------------
def demo_composition_bound() -> None:
    print("=" * 68)
    print("DEMO 2: triangle inequality for analogies  (eps_f + L * eps_g)")
    print("=" * 68)
    d = lambda x, y: abs(x - y)
    grid = [i / 5 for i in range(-15, 16)]  # -3 .. 3

    # f: A=R -> B=R  (round to nearest 0.5), backward = identity, L-Lipschitz L=1
    f_fwd = lambda x: round(2 * x) / 2
    f_bwd = lambda y: y
    L = 1.0  # f_bwd is the identity, 1-Lipschitz

    # g: B=R -> C=R  (round to nearest integer), backward = identity
    g_fwd = lambda y: round(y)
    g_bwd = lambda z: z

    eps_f = distortion(grid, f_fwd, f_bwd, d)
    # measure g on the image of f
    img = [f_fwd(x) for x in grid]
    eps_g = distortion(img, g_fwd, g_bwd, d)

    comp_fwd = lambda x: g_fwd(f_fwd(x))
    comp_bwd = lambda z: f_bwd(g_bwd(z))
    actual = distortion(grid, comp_fwd, comp_bwd, d)
    bound = eps_f + L * eps_g

    print(f"eps_f (round to 0.5)          = {eps_f:.4f}")
    print(f"eps_g (round to 1)            = {eps_g:.4f}")
    print(f"Lipschitz constant L (f_bwd)  = {L:.4f}")
    print(f"predicted bound eps_f+L*eps_g = {bound:.4f}")
    print(f"actual composite distortion   = {actual:.4f}")
    print(f"bound holds (actual <= bound) = {actual <= bound + 1e-12}")
    print()


# ---------------------------------------------------------------------------
# Collapse counterexample: perfect one-sided analogy is NOT an equivalence
# ---------------------------------------------------------------------------
def demo_collapse() -> None:
    print("=" * 68)
    print("DEMO 3: perfect one-sided analogy != equivalence")
    print("=" * 68)
    # A = {*} (single point encoded as 0), B = R.
    A_sample = [0]  # the single point
    d_A = lambda x, y: abs(x - y)
    F = lambda star: 0.0           # A -> B : send the point to 0.0
    G = lambda x: 0                # B -> A : collapse all of R to the point
    print(f"forward-then-back distortion on A = {distortion(A_sample, F, G, d_A):.4f}"
          f"  (perfect: G o F = id_A)")
    # But F o G on B collapses everything:
    b = 1.0
    print(f"F(G({b})) = {F(G(b))}   !=  {b}   (F o G is NOT id_B)")
    print("=> fidelity is directional; a perfect left inverse need not be an equivalence.")
    print()


# ---------------------------------------------------------------------------
# Adjoint (Galois) model on a finite lattice: divisors of 12 under divisibility
# ---------------------------------------------------------------------------
def demo_adjoint_closure() -> None:
    print("=" * 68)
    print("DEMO 4: adjoint analogy -> closure operator + uniqueness")
    print("=" * 68)
    # L = subsets of {2,3} (concept lattice, order = subset).
    # M = divisors of 6 (order = divisibility).
    # Forward l(S) = product of primes in S ; backward u(n) = primes dividing n.
    primes = [2, 3]
    subsets: List[frozenset] = [frozenset(), frozenset({2}), frozenset({3}), frozenset({2, 3})]

    def l(S: frozenset) -> int:
        p = 1
        for q in S:
            p *= q
        return p

    def u(n: int) -> frozenset:
        return frozenset(q for q in primes if n % q == 0)

    # Verify the Galois equivalence l(S) | n  <=>  S subset u(n)
    divisors_6 = [1, 2, 3, 6]
    ok = all(
        ((n % l(S) == 0) == S.issubset(u(n)))
        for S in subsets
        for n in divisors_6
    )
    print(f"Galois equivalence l(S)|n <=> S<=u(n) holds : {ok}")

    # Round trip u o l is a closure operator: idempotent + extensive
    idem = all(u(l(S)) == u(l(u(l(S)))) for S in subsets)
    ext = all(S.issubset(u(l(S))) for S in subsets)
    print(f"u o l idempotent (closure)                 : {idem}")
    print(f"u o l extensive (S <= u(l(S)))             : {ext}")

    # Uniqueness of the adjoint: brute-force search for ANY valid backward map
    # to l; it must equal u.
    import itertools
    def valid_backward(cand: Dict[int, frozenset]) -> bool:
        return all(
            ((n % l(S) == 0) == S.issubset(cand[n]))
            for S in subsets
            for n in divisors_6
        )
    valid = [
        dict(zip(divisors_6, combo))
        for combo in itertools.product(subsets, repeat=len(divisors_6))
        if valid_backward(dict(zip(divisors_6, combo)))
    ]
    unique = len(valid) == 1 and valid[0] == {n: u(n) for n in divisors_6}
    print(f"backward adjoint is unique (== u)          : {unique}")
    print()


# ---------------------------------------------------------------------------
# Tropical optimization: best analogy = single min-plus sum
# ---------------------------------------------------------------------------
def tropical_sum(values: Sequence[float]) -> float:
    """Tropical (min-plus) sum: additive identity +inf, x (+) y = min(x, y)."""
    total = inf
    for v in values:
        total = min(total, v)
    return total


def best_analogy(costs: Dict[str, float]) -> Tuple[str, float]:
    """Return the minimizing candidate and its cost via tropical aggregation."""
    best_name, best_cost = None, inf
    for name, c in costs.items():
        if c < best_cost:
            best_name, best_cost = name, c
    return best_name, best_cost  # type: ignore[return-value]


def demo_tropical_optimization() -> None:
    print("=" * 68)
    print("DEMO 5: making the best analogy = one tropical (min-plus) sum")
    print("=" * 68)
    # Candidate analogies with distortion costs; 'infeasible' has cost +inf.
    costs = {
        "solar-system":  0.90,
        "water-in-pipes": 0.35,
        "billiard-balls": 0.60,
        "infeasible":     inf,
    }
    score = tropical_sum(list(costs.values()))
    name, cost = best_analogy(costs)
    print("candidate distortions:")
    for k, v in costs.items():
        print(f"   {k:16s} : {v}")
    print(f"tropical score (min-plus sum) = {score:.4f}")
    print(f"best analogy                  = {name!r} with cost {cost:.4f}")
    print(f"score equals best cost        = {abs(score - cost) < 1e-12}")
    print(f"score lower-bounds all        = {all(score <= v + 1e-12 for v in costs.values())}")
    print()


def main() -> None:
    demo_fidelity_and_copycat()
    demo_composition_bound()
    demo_collapse()
    demo_adjoint_closure()
    demo_tropical_optimization()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
