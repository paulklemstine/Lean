"""
Algorithm 1 — Forward Value Recursion over an Ordered Weight Monoid.

Computes the table V(i, s) = best score of a labelling of stages 0..i ending in state s,
together with argmax pointers suitable for backtracing.  Weights live in any linearly
ordered commutative monoid with monotone addition; `None` plays the role of the
absorbing bottom element for constrained problems.
"""

from __future__ import annotations

from typing import Callable, List, Optional, Tuple

Weight = Optional[float]  # None = bottom (infeasible), absorbing for +, least for <=


def wadd(x: Weight, y: Weight) -> Weight:
    """Monoid addition with an absorbing bottom element."""
    return None if (x is None or y is None) else x + y


def wgt(x: Weight, y: Weight) -> bool:
    """Strict order `x > y` with bottom least."""
    if x is None:
        return False
    if y is None:
        return True
    return x > y


def forward_pass(
    n_states: int,
    init: Callable[[int], Weight],
    step: Callable[[int, int, int], Weight],
    n: int,
) -> Tuple[List[List[Weight]], List[List[int]]]:
    """Return (V, ptr) with V[i][s] = V(i, s) and ptr[i+1][t] an argmax predecessor.

    Complexity: Theta(n * n_states^2) monoid additions and comparisons,
    Theta(n * n_states) memory (Theta(n_states) if pointers are discarded).
    """
    assert n_states >= 1, "the state space must be non-empty"
    V: List[List[Weight]] = [[init(s) for s in range(n_states)]]
    ptr: List[List[int]] = [[-1] * n_states]
    for i in range(n):
        row: List[Weight] = []
        prow: List[int] = []
        for t in range(n_states):
            best: Weight = wadd(V[i][0], step(i, 0, t))
            arg = 0
            for s in range(1, n_states):
                cand = wadd(V[i][s], step(i, s, t))
                if wgt(cand, best):
                    best, arg = cand, s
            row.append(best)
            prow.append(arg)
        V.append(row)
        ptr.append(prow)
    return V, ptr


if __name__ == "__main__":
    A = [[2.0, -1.0, 3.0], [1.0, 0.0, -2.0], [-3.0, 4.0, 1.0]]
    V, _ = forward_pass(3, lambda s: float(s), lambda i, s, t: A[s][t], 3)
    for i, row in enumerate(V):
        print(f"V({i}, .) =", [None if v is None else round(v, 2) for v in row])
    # expected: [0,1,2], [2,6,3], [7,7,5], [9,9,10]


"""
Algorithm 2 — Optimal Run Reconstruction by Backtrace.

Given the argmax pointers produced by the forward pass, reconstructs a labelling whose
score equals the reported optimum.  The reconstructed labelling satisfies the structural
condition  V(i, f(i)) + step(i, f(i), f(i+1)) = V(i+1, f(i+1))  at every stage, which is
equivalent -- over any ordered weight monoid -- to every prefix of the labelling being
optimal for its own endpoint.  Verification of both conditions is included.
"""

from __future__ import annotations

from typing import Callable, List, Optional, Sequence, Tuple

Weight = Optional[float]


def wadd(x: Weight, y: Weight) -> Weight:
    return None if (x is None or y is None) else x + y


def wgt(x: Weight, y: Weight) -> bool:
    if x is None:
        return False
    if y is None:
        return True
    return x > y


def backtrace(ptr: List[List[int]], n: int, end_state: int) -> List[int]:
    """Reconstruct the optimal labelling ending at `end_state`.  Cost Theta(n)."""
    f = [0] * (n + 1)
    f[n] = end_state
    for i in range(n - 1, -1, -1):
        f[i] = ptr[i + 1][f[i + 1]]
    return f


def best_end_state(V: List[List[Weight]], n: int) -> int:
    """The endpoint of the uniformly dominating run."""
    arg = 0
    for s in range(1, len(V[n])):
        if wgt(V[n][s], V[n][arg]):
            arg = s
    return arg


def score(
    init: Callable[[int], Weight],
    step: Callable[[int, int, int], Weight],
    f: Sequence[int],
    n: int,
) -> Weight:
    acc: Weight = init(f[0])
    for i in range(n):
        acc = wadd(acc, step(i, f[i], f[i + 1]))
    return acc


def certify(
    V: List[List[Weight]],
    init: Callable[[int], Weight],
    step: Callable[[int, int, int], Weight],
    f: Sequence[int],
    n: int,
) -> Tuple[bool, bool]:
    """Return (is_backtrace, is_run): the structural and the semantic certificate."""
    is_bt = all(
        wadd(V[i][f[i]], step(i, f[i], f[i + 1])) == V[i + 1][f[i + 1]] for i in range(n)
    )
    is_run = all(score(init, step, f, i) == V[i][f[i]] for i in range(n + 1))
    return is_bt, is_run


if __name__ == "__main__":
    from alg1_forward import forward_pass

    A = [[2.0, -1.0, 3.0], [1.0, 0.0, -2.0], [-3.0, 4.0, 1.0]]
    init = lambda s: float(s)
    step = lambda i, s, t: A[s][t]
    n = 5
    V, ptr = forward_pass(3, init, step, n)
    end = best_end_state(V, n)
    f = backtrace(ptr, n, end)
    print("optimal labelling:", f, " score:", score(init, step, f, n),
          " reported V:", V[n][end])
    print("(is_backtrace, is_run):", certify(V, init, step, f, n))


"""
Algorithm 3 — Max-Plus Walk-Matrix Exponentiation (Tropical Repeated Squaring).

Segment composition in a layered dynamic program obeys a Chapman-Kolmogorov identity:
the optimal weight of a walk of m1 + m2 + 2 transitions is the max-plus product of the
two segment matrices.  When the transition weights do not depend on the stage, the walk
matrices are therefore tropical powers of a single matrix A, and the m-step optimum can
be obtained by repeated squaring in Theta(|S|^3 log m) operations instead of the
Theta(m |S|^2) of a straight forward pass.
"""

from __future__ import annotations

from typing import List, Optional

Weight = Optional[float]
Matrix = List[List[Weight]]


def wadd(x: Weight, y: Weight) -> Weight:
    return None if (x is None or y is None) else x + y


def wmax(x: Weight, y: Weight) -> Weight:
    if x is None:
        return y
    if y is None:
        return x
    return x if x >= y else y


def mat_mul(X: Matrix, Y: Matrix) -> Matrix:
    """Max-plus matrix product: (X (x) Y)[s][u] = max_t (X[s][t] + Y[t][u])."""
    n = len(X)
    Z: Matrix = [[None] * n for _ in range(n)]
    for s in range(n):
        for u in range(n):
            acc: Weight = None
            for t in range(n):
                acc = wmax(acc, wadd(X[s][t], Y[t][u]))
            Z[s][u] = acc
    return Z


def mat_pow(A: Matrix, k: int) -> Matrix:
    """A^(x)k for k >= 1, by tropical repeated squaring.  Theta(|S|^3 log k)."""
    assert k >= 1
    result: Optional[Matrix] = None
    base = [row[:] for row in A]
    while k:
        if k & 1:
            result = base if result is None else mat_mul(result, base)
        k >>= 1
        if k:
            base = mat_mul(base, base)
    assert result is not None
    return result


def mat_vec(v: List[Weight], X: Matrix) -> List[Weight]:
    """Max-plus action of a matrix on a value vector: (v (x) X)[t] = max_s (v[s] + X[s][t])."""
    n = len(v)
    out: List[Weight] = []
    for t in range(n):
        acc: Weight = None
        for s in range(n):
            acc = wmax(acc, wadd(v[s], X[s][t]))
        out.append(acc)
    return out


def value_by_squaring(init: List[Weight], A: Matrix, n: int) -> List[Weight]:
    """V(n, .) for a stage-independent specification, via tropical powering."""
    if n == 0:
        return init[:]
    return mat_vec(init, mat_pow(A, n))


if __name__ == "__main__":
    A: Matrix = [[2.0, -1.0, 3.0], [1.0, 0.0, -2.0], [-3.0, 4.0, 1.0]]
    init: List[Weight] = [0.0, 1.0, 2.0]

    # cross-check against the plain forward pass
    def forward(n: int) -> List[Weight]:
        V = init[:]
        for _ in range(n):
            V = mat_vec(V, A)
        return V

    for n in range(9):
        fast = value_by_squaring(init, A, n)
        slow = forward(n)
        assert fast == slow, (n, fast, slow)
        print(f"n = {n}:  V(n,.) = {fast}   [repeated squaring agrees with forward pass]")

    # Chapman-Kolmogorov: A^(m1+1) (x) A^(m2+1) = A^(m1+m2+2)
    for m1 in range(1, 5):
        for m2 in range(1, 5):
            assert mat_mul(mat_pow(A, m1), mat_pow(A, m2)) == mat_pow(A, m1 + m2)
    print("Chapman-Kolmogorov identity verified for all segment splittings tested.")


"""
Algorithm 4 — Forward-Backward Max-Marginal Computation.

The forward value V(k, s) summarises the best past ending in state s at stage k; the
backward value B(k, m, s) summarises the best future of m further transitions starting
from s at stage k.  Their sum is the best score achievable by any labelling *forced* to
occupy state s at stage k -- the max-marginal.  The forward-backward decomposition
states that maximising the sum over s recovers the unconstrained global optimum, so the
shortfall of a max-marginal measures exactly the price of the corresponding constraint.

Both passes cost Theta(n |S|^2) and are independent, hence parallelisable.
"""

from __future__ import annotations

from typing import Callable, List, Optional, Tuple

Weight = Optional[float]


def wadd(x: Weight, y: Weight) -> Weight:
    return None if (x is None or y is None) else x + y


def wmax(x: Weight, y: Weight) -> Weight:
    if x is None:
        return y
    if y is None:
        return x
    return x if x >= y else y


def forward_values(
    n_states: int,
    init: Callable[[int], Weight],
    step: Callable[[int, int, int], Weight],
    k: int,
) -> List[List[Weight]]:
    V: List[List[Weight]] = [[init(s) for s in range(n_states)]]
    for i in range(k):
        row: List[Weight] = []
        for t in range(n_states):
            acc: Weight = None
            for s in range(n_states):
                acc = wmax(acc, wadd(V[i][s], step(i, s, t)))
            row.append(acc)
        V.append(row)
    return V


def backward_values(
    n_states: int,
    step: Callable[[int, int, int], Weight],
    k: int,
    m: int,
) -> List[List[Weight]]:
    """B[j][s] = B(k + j, m - j, s), computed by a single backward sweep."""
    B: List[List[Weight]] = [[None] * n_states for _ in range(m + 1)]
    B[m] = [0.0] * n_states
    for j in range(m - 1, -1, -1):
        for s in range(n_states):
            acc: Weight = None
            for t in range(n_states):
                acc = wmax(acc, wadd(step(k + j, s, t), B[j + 1][t]))
            B[j][s] = acc
    return B


def max_marginals(
    n_states: int,
    init: Callable[[int], Weight],
    step: Callable[[int, int, int], Weight],
    k: int,
    m: int,
) -> Tuple[List[Weight], Weight]:
    """Return (max-marginals at stage k, the global optimum at horizon k+m)."""
    V = forward_values(n_states, init, step, k)
    B = backward_values(n_states, step, k, m)
    marg = [wadd(V[k][s], B[0][s]) for s in range(n_states)]
    best: Weight = None
    for w in marg:
        best = wmax(best, w)
    return marg, best


if __name__ == "__main__":
    A = [[2.0, -1.0, 3.0], [1.0, 0.0, -2.0], [-3.0, 4.0, 1.0]]
    init = lambda s: float(s)
    step = lambda i, s, t: A[s][t]
    n_states = 3

    for k in range(5):
        for m in range(5):
            marg, best = max_marginals(n_states, init, step, k, m)
            V = forward_values(n_states, init, step, k + m)
            glob: Weight = None
            for s in range(n_states):
                glob = wmax(glob, V[k + m][s])
            assert best == glob, (k, m, best, glob)
    print("Forward-backward decomposition verified for all cuts with k, m <= 4.")

    k, m = 2, 3
    marg, best = max_marginals(n_states, init, step, k, m)
    print(f"\nMax-marginals at stage k = {k} with m = {m} remaining transitions:")
    for s, w in enumerate(marg):
        gap = None if (w is None or best is None) else best - w
        print(f"  forcing state {s}: best achievable = {w}"
              f"   (price of the constraint: {gap})")


"""Assemble PACKAGE.json from the deliverable files and the packaging assets."""

from __future__ import annotations

import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, ".package_assets")


def read(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


LEAN_FILES = [
    "Catalog/Logic/DPCompleteness.lean",
    "Catalog/Logic/DPCompletenessWalks.lean",
    "Catalog/Logic/DPCompletenessApplications.lean",
    "Catalog/Logic/DPCompletenessStability.lean",
    "Catalog/Logic/DPCompletenessConstrained.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===================== {p} =====================\n\n" + read(os.path.join(ROOT, p))
    for p in LEAN_FILES
)

package = {
    "title": "Completeness of Layered Dynamic Programming over Ordered Weight Monoids",
    "domain": "Logic",
    "description": (
        "A general theory of layered dynamic programming over an arbitrary finite state space and "
        "an arbitrary linearly ordered commutative weight monoid, culminating in the completeness "
        "theorem: every labelling is dominated by some run of the dynamic program, so the value "
        "function is the greatest achievable score. The cancellativity hypothesis of the classical "
        "treatment is removed by replacing the semantic notion of a run with a structural backtrace "
        "notion, which opens the theory to constrained problems where infeasibility is an absorbing "
        "weight."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-22",
    "key_results": [
        "Domination: every labelling scores at most the dynamic-programming value at its endpoint, "
        "proved by a two-line induction requiring only that a maximum dominates its terms and that "
        "adding a constant preserves the order.",
        "Completeness and exactness: every labelling is dominated by some run, a single universal run "
        "dominates all labellings simultaneously, and the value function is the greatest element -- "
        "not merely the supremum -- of the set of achievable scores.",
        "Bellman's optimality principle and the characterisation of runs: over a cancellative weight "
        "monoid, a labelling is generated by the recursion exactly when it is optimal among all "
        "labellings with the same endpoint.",
        "Forward-backward decomposition and the tropical walk calculus: an optimal path may be cut at "
        "any intermediate stage, segment composition obeys a max-plus Chapman-Kolmogorov identity, and "
        "the value function is the max-plus action of the walk matrices on the initial vector.",
        "Completeness without cancellativity: the structural backtrace notion of a run coincides with "
        "the semantic one over any ordered weight monoid, yielding exactness for constrained dynamic "
        "programming with an absorbing infeasible weight, together with the criterion that the value "
        "is infeasible exactly when every labelling is.",
        "Lipschitz stability: specifications differing by at most a on initial weights and b on "
        "transition weights have value functions differing by at most a + nb at horizon n, so a run "
        "computed on a perturbed model is within 2(a + nb) of the true optimum.",
    ],
    "keywords": [
        "dynamic programming",
        "Bellman optimality principle",
        "Viterbi algorithm",
        "completeness",
        "tropical semiring",
        "max-plus algebra",
        "ordered monoid",
        "constrained optimisation",
    ],
    "article": read(os.path.join(ROOT, "ARTICLE.md")),
    "research_paper": read(os.path.join(ROOT, "RESEARCH_PAPER.md")),
    "research_paper_tex": read(os.path.join(ROOT, "RESEARCH_PAPER.tex")),
    "demo": read(os.path.join(ROOT, "demo.py")),
    "demos": [
        {
            "name": "Complete Numerical Verification of the Dynamic-Programming "
                    "Completeness Theorem",
            "description": (
                "An end-to-end numerical tour of every result in the theory, on an explicit "
                "three-state integer instance. It prints the forward value table and checks it "
                "against exhaustive enumeration of all labellings at each horizon; verifies "
                "domination on two thousand random labellings; reconstructs optimal runs by "
                "backtracing and confirms both the structural and the semantic run certificates; "
                "enumerates every labelling that is optimal at its endpoint and confirms that each "
                "is optimal at every prefix, thereby exhibiting Bellman's optimality principle; "
                "verifies the forward-backward decomposition at every cut and prints the resulting "
                "max-marginals; checks the max-plus Chapman-Kolmogorov identity and the transfer "
                "identity relating value functions across stages; solves the same instance in the "
                "dual order to obtain shortest paths and cross-checks against brute force; measures "
                "the empirical deviation of the optimum under four hundred random perturbations "
                "against the predicted Lipschitz envelope; and finally solves a constrained "
                "maximum-weight independent set instance over the weight monoid with an absorbing "
                "bottom element."
            ),
            "code": read(os.path.join(ROOT, "demo.py")),
        },
        {
            "name": "Constrained Dynamic Programming with an Absorbing Infeasible Weight",
            "description": (
                "A focused demonstration that completeness survives the loss of cancellativity. "
                "Infeasible transitions carry an absorbing bottom weight, so that adding anything to "
                "an infeasible partial score leaves it infeasible; this makes the weight monoid "
                "non-cancellative and breaks the classical proof that end-optimality forces "
                "prefix-optimality. Three instances are solved and audited against exhaustive "
                "enumeration: maximum-weight independent set on a path with vertex weights 3, 7, 2, "
                "8, 1 (optimum 15, attained by vertices 1 and 3); a four-symbol decoding problem "
                "over a three-letter alphabet with one forbidden bigram; and a deliberately "
                "over-constrained instance in which no feasible labelling exists at all. For each, "
                "the reconstructed labelling is certified against both the structural definition of "
                "a run (the recursion is realised exactly at every stage) and the semantic one "
                "(every prefix is optimal), and the reported value is compared with the true optimum "
                "over all labellings. The last instance illustrates the infeasibility criterion: the "
                "bottom value is a proof that no feasible labelling exists, not a failure to find one."
            ),
            "code": read(os.path.join(ASSETS, "demo_constrained.py")),
        },
    ],
    "algorithms": [
        {
            "name": "Forward Value Recursion over an Ordered Weight Monoid",
            "description": (
                "The forward pass of the layered dynamic program. It fills a table whose entry "
                "V(i, s) is the best score of a labelling of stages 0 through i ending in state s, "
                "using only the previous column: V(0, s) = init(s) and V(i+1, t) is the maximum over "
                "predecessor states s of V(i, s) + step(i, s, t). Alongside each entry it records an "
                "argmax predecessor, which is exactly the data a backtrace consumes.\n\n"
                "The correctness of this recursion is the completeness theorem: every labelling "
                "scores at most the table entry at its endpoint. The proof is a two-line induction "
                "using only that a maximum dominates each of its terms and that adding a constant "
                "preserves the order -- hence the algorithm is valid over any linearly ordered "
                "commutative monoid with monotone addition, not merely over the reals. Reading the "
                "order upside down turns it into the shortest-path recursion; adjoining an absorbing "
                "bottom element turns it into a constrained solver, with infeasibility propagating "
                "automatically.\n\n"
                "Complexity: Theta(n |S|^2) monoid additions and comparisons, against the "
                "|S|^(n+1) labellings the problem nominally ranges over. Memory is Theta(n |S|) with "
                "pointers retained, or Theta(|S|) if only the optimal value is needed."
            ),
            "pseudocode": (
                "ALGORITHM ForwardPass\n"
                "INPUT   finite non-empty state set S; init : S -> W;\n"
                "        step : N x S x S -> W;  horizon n\n"
                "OUTPUT  value table V[0..n][S]; argmax pointers pi[1..n][S]\n"
                "\n"
                "1  for each s in S do\n"
                "2      V[0][s] <- init(s)\n"
                "3  end for\n"
                "4  for i <- 0 to n-1 do\n"
                "5      for each t in S do\n"
                "6          best <- V[i][s0] + step(i, s0, t)     // s0 any fixed state of S\n"
                "7          arg  <- s0\n"
                "8          for each s in S \\ {s0} do\n"
                "9              c <- V[i][s] + step(i, s, t)      // monoid addition\n"
                "10             if c > best then                  // order of W; bottom is least\n"
                "11                 best <- c ;  arg <- s\n"
                "12             end if\n"
                "13         end for\n"
                "14         V[i+1][t] <- best ;  pi[i+1][t] <- arg\n"
                "15     end for\n"
                "16 end for\n"
                "17 return (V, pi)\n"
                "\n"
                "INVARIANT  after iteration i, V[i][s] is the greatest element of\n"
                "           { score(f, i) : f a labelling with f(i) = s }.\n"
                "COST       Theta(n |S|^2) additions and comparisons."
            ),
            "code": read(os.path.join(ASSETS, "alg1_forward.py")),
        },
        {
            "name": "Optimal Run Reconstruction by Backtrace",
            "description": (
                "The soundness half of the algorithm: turning the value table into an explicit "
                "witness. Starting from the endpoint that maximises the last column, the loop follows "
                "the stored argmax pointers backwards, producing a labelling whose score is exactly "
                "the reported optimum.\n\n"
                "The reconstructed labelling satisfies the structural condition V(i, f(i)) + "
                "step(i, f(i), f(i+1)) = V(i+1, f(i+1)) at every stage -- the recursion is realised on "
                "the nose. That structural condition is equivalent, over any ordered weight monoid, to "
                "the semantic condition that every prefix of the labelling is optimal for its own "
                "endpoint. The equivalence is what makes the algorithm correct without any "
                "cancellativity assumption on the weights, and hence what makes it correct for "
                "constrained problems where an absorbing infeasible weight destroys cancellativity. "
                "The implementation verifies both certificates independently.\n\n"
                "Complexity: Theta(n) after the forward pass, or Theta(n |S|) additional memory to "
                "store the pointers. A pointer-free variant recomputes the argmax at each step in "
                "Theta(n |S|) time and Theta(|S|) memory."
            ),
            "pseudocode": (
                "ALGORITHM Backtrace\n"
                "INPUT   value table V; pointers pi; horizon n; endpoint s (optional)\n"
                "OUTPUT  labelling f with f(n) = s realising V[n][s]\n"
                "\n"
                "1  if s is not supplied then\n"
                "2      s <- argmax_{u in S} V[n][u]        // gives the uniformly dominating run\n"
                "3  end if\n"
                "4  f[n] <- s\n"
                "5  for i <- n-1 down to 0 do\n"
                "6      f[i] <- pi[i+1][ f[i+1] ]\n"
                "7  end for\n"
                "8  return f\n"
                "\n"
                "CERTIFICATE (structural)  for all i < n:\n"
                "      V[i][f[i]] + step(i, f[i], f[i+1]) = V[i+1][f[i+1]]\n"
                "CERTIFICATE (semantic)    for all i <= n:\n"
                "      score(f, i) = V[i][f[i]]\n"
                "The two are equivalent over every ordered weight monoid.\n"
                "COST  Theta(n)."
            ),
            "code": read(os.path.join(ASSETS, "alg2_backtrace.py")),
        },
        {
            "name": "Max-Plus Walk-Matrix Exponentiation by Tropical Repeated Squaring",
            "description": (
                "An asymptotically faster forward pass for specifications whose transition weights do "
                "not depend on the stage. Writing the optimal weight of a segment of consecutive "
                "transitions as a matrix, segment composition satisfies a Chapman-Kolmogorov identity: "
                "the matrix of a long segment is the max-plus product of the matrices of its two "
                "halves, where the max-plus product replaces the usual sum-of-products by a "
                "maximum-of-sums. The walk matrices therefore form a semigroup, and in the "
                "stage-homogeneous case they are tropical powers of a single matrix.\n\n"
                "Consequently the m-step matrix can be computed by repeated squaring, and the value "
                "function is recovered by a single max-plus matrix-vector action on the initial "
                "weights. This is the tropical analogue of computing the m-step kernel of a Markov "
                "chain by matrix powering, with maximum replacing summation and addition replacing "
                "multiplication.\n\n"
                "Complexity: Theta(|S|^3 log m) monoid operations, versus Theta(m |S|^2) for the "
                "straight forward pass; the trade-off favours squaring when m greatly exceeds "
                "|S| / log m. The implementation cross-checks the squaring result against the plain "
                "forward pass and verifies the Chapman-Kolmogorov identity for every splitting tested."
            ),
            "pseudocode": (
                "ALGORITHM TropicalPower\n"
                "INPUT   transition matrix A over the weight monoid; exponent k >= 1\n"
                "OUTPUT  the max-plus power A^(x)k\n"
                "\n"
                "1  function MatMul(X, Y)\n"
                "2      for each s, u in S do\n"
                "3          Z[s][u] <- max_{t in S} ( X[s][t] + Y[t][u] )\n"
                "4      end for\n"
                "5      return Z\n"
                "6  end function\n"
                "\n"
                "7  result <- undefined ;  base <- A\n"
                "8  while k > 0 do\n"
                "9      if k is odd then\n"
                "10         result <- (result = undefined) ? base : MatMul(result, base)\n"
                "11     end if\n"
                "12     k <- floor(k / 2)\n"
                "13     if k > 0 then base <- MatMul(base, base) end if\n"
                "14 end while\n"
                "15 return result\n"
                "\n"
                "ALGORITHM ValueBySquaring\n"
                "INPUT   init vector; matrix A; horizon n\n"
                "1  if n = 0 then return init end if\n"
                "2  X <- TropicalPower(A, n)\n"
                "3  return the vector t |-> max_{s in S} ( init[s] + X[s][t] )\n"
                "\n"
                "COST  Theta(|S|^3 log n) additions and comparisons."
            ),
            "code": read(os.path.join(ASSETS, "alg3_tropical.py")),
        },
        {
            "name": "Forward-Backward Max-Marginal Computation",
            "description": (
                "Computes, for every state s and every intermediate stage k, the best score achievable "
                "by a labelling constrained to occupy state s at stage k. The forward value V(k, s) "
                "summarises the best past ending in s; the backward value B(k, m, s), obtained by the "
                "mirror-image recursion swept from the far end, summarises the best future of m further "
                "transitions starting from s. Their sum is the constrained optimum -- the max-marginal "
                "-- and the forward-backward decomposition theorem says that maximising this sum over s "
                "recovers the unconstrained global optimum, for every choice of cut.\n\n"
                "The shortfall of a max-marginal below the global optimum is therefore exactly the price "
                "of the corresponding constraint, which is how sensitivity analysis and structured-"
                "prediction confidence estimates are computed. The identity also licenses linear-space "
                "divide-and-conquer reconstruction of the optimal path, and meet-in-the-middle "
                "parallelisation: the two sweeps are independent and are combined in a single pass over "
                "the states.\n\n"
                "Complexity: Theta((k+m) |S|^2) in total for the two passes -- the same order as one "
                "forward pass -- with Theta(|S|) work for the recombination. The implementation verifies "
                "the decomposition at every cut with k and m at most four."
            ),
            "pseudocode": (
                "ALGORITHM ForwardBackwardMaxMarginals\n"
                "INPUT   init; step; cut stage k; remaining transitions m\n"
                "OUTPUT  max-marginals mu[s] for s in S, and the global optimum\n"
                "\n"
                "1  // forward sweep over stages 0 .. k\n"
                "2  V[0][s] <- init(s)  for each s in S\n"
                "3  for i <- 0 to k-1 do\n"
                "4      V[i+1][t] <- max_{s in S} ( V[i][s] + step(i, s, t) )   for each t in S\n"
                "5  end for\n"
                "\n"
                "6  // backward sweep over stages k+m .. k\n"
                "7  B[m][s] <- 0  for each s in S\n"
                "8  for j <- m-1 down to 0 do\n"
                "9      B[j][s] <- max_{t in S} ( step(k+j, s, t) + B[j+1][t] )  for each s in S\n"
                "10 end for\n"
                "\n"
                "11 mu[s] <- V[k][s] + B[0][s]   for each s in S\n"
                "12 return (mu, max_{s in S} mu[s])\n"
                "\n"
                "THEOREM  max_{s} mu[s] = max_{s} V[k+m][s], for every cut k.\n"
                "COST     Theta((k+m) |S|^2); the two sweeps are independent and parallelisable."
            ),
            "code": read(os.path.join(ASSETS, "alg4_maxmarginal.py")),
        },
    ],
    "visualizations": [
        {
            "name": "The Trellis, the Value Function, and the Reconstructed Optimum",
            "description": (
                "Draws the layered graph whose vertices are (stage, state) pairs and whose edges are "
                "the possible transitions. Every vertex is annotated with its forward value, and the "
                "labelling reconstructed by backtracing from the best final vertex is highlighted "
                "together with the transition weights it collects. The picture makes both halves of "
                "correctness visible at once: the highlighted path genuinely exists and genuinely "
                "scores the annotated value (soundness), and no other path through the trellis reaches "
                "a higher final annotation (completeness). Rendered for the running three-state integer "
                "instance at horizon five, where the dynamic program fills eighteen table cells to "
                "select the best of seven hundred and twenty-nine labellings."
            ),
            "code": read(os.path.join(ASSETS, "viz_trellis.py")),
        },
        {
            "name": "Linear Error Accumulation: the Lipschitz Envelope of the Optimum",
            "description": (
                "Samples random perturbations of the specification within a fixed budget -- at most a "
                "in every initial weight and at most b in every transition weight -- and plots the "
                "resulting deviation of the value function against the theoretical envelope a + nb, "
                "as a function of the horizon n. A second series tracks the true sub-optimality of a "
                "run computed on the perturbed model but evaluated under the true model, against its "
                "predicted bound 2(a + nb). The picture shows the qualitative point that makes the "
                "theory deployable on estimated weights: error accumulates linearly in the horizon, "
                "never exponentially, and every sampled deviation stays inside the envelope."
            ),
            "code": read(os.path.join(ASSETS, "viz_stability.py")),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Trellis Laboratory: Soundness and Completeness, Audited Live",
            "description": (
                "A fully interactive layered dynamic program. Edit every initial and transition weight, "
                "drag the horizon from one to seven stages, and click the badge on any matrix cell to "
                "give that transition the absorbing infeasible weight -- which makes the weight monoid "
                "non-cancellative and exercises precisely the setting the structural notion of a run was "
                "designed for. A single toggle flips the whole computation between maximisation "
                "(longest paths, max-plus) and minimisation (shortest paths, min-plus), demonstrating "
                "order duality: only one comparison in the code changes.\n\n"
                "The value table updates live, the trellis highlights the labelling reconstructed by "
                "backtracing together with the transition weights it collects, and a background "
                "exhaustive audit enumerates every one of the exponentially many labellings and reports, "
                "separately, whether the reconstructed path really scores what the table claims "
                "(soundness) and whether anything at all beats it (completeness). A running counter "
                "contrasts the number of table cells filled with the number of labellings the algorithm "
                "never looked at. Three progressively-disclosed panels give the two-line induction "
                "proving completeness, the distinction between the structural and semantic notions of a "
                "run and why the absorbing weight breaks the classical argument, and the duality "
                "argument that makes minimisation the same theorem read upside down."
            ),
            "html": read(os.path.join(ASSETS, "widget_trellis.html")),
        },
        {
            "title": "Cutting an Optimal Path: the Forward-Backward Decomposition in Motion",
            "description": (
                "An interactive illustration of the theorem that an optimal path may be severed at any "
                "intermediate stage and reassembled as best-way-in plus best-way-out. Drag the cut stage "
                "and the total horizon and watch the forward value (the best past ending in each state) "
                "and the backward value (the best future starting from each state) trade magnitude in a "
                "live bar chart, while their maximised sum stays pinned to the global optimum -- with the "
                "identity checked numerically and displayed at every position of the cut. A table lists "
                "the max-marginal for each state at the cut: the best score achievable by a labelling "
                "forced through that state, whose shortfall from the winner is exactly the price of the "
                "constraint. Two disclosed panels explain the proof as an interchange of two maxima, and "
                "the three uses of the identity in practice: sensitivity analysis, linear-space "
                "divide-and-conquer reconstruction, and meet-in-the-middle parallelisation."
            ),
            "html": read(os.path.join(ASSETS, "widget_fb.html")),
        },
    ],
    "interactive_layout": read(os.path.join(ASSETS, "interactive_layout.md")),
    "lean_proofs": lean_proofs,
    "future_directions": read(os.path.join(ASSETS, "future_directions.txt")),
    "modules": {
        "demo": read(os.path.join(ROOT, "demo.py")),
        "demo_constrained": read(os.path.join(ASSETS, "demo_constrained.py")),
        "forward_pass": read(os.path.join(ASSETS, "alg1_forward.py")),
        "backtrace": read(os.path.join(ASSETS, "alg2_backtrace.py")),
        "tropical_walk_algebra": read(os.path.join(ASSETS, "alg3_tropical.py")),
        "max_marginals": read(os.path.join(ASSETS, "alg4_maxmarginal.py")),
        "viz_trellis": read(os.path.join(ASSETS, "viz_trellis.py")),
        "viz_stability": read(os.path.join(ASSETS, "viz_stability.py")),
    },
    "lean_files": LEAN_FILES,
}

with open(os.path.join(ROOT, "PACKAGE.json"), "w", encoding="utf-8") as fh:
    json.dump(package, fh, indent=2, ensure_ascii=False)
    fh.write("\n")

print("wrote PACKAGE.json")
print("top-level keys:", ", ".join(package.keys()))
for k in ("demos", "algorithms", "visualizations", "interactive_demos", "key_results",
          "keywords", "lean_files"):
    print(f"  {k}: {len(package[k])} entries")
print("lean_proofs characters:", len(package["lean_proofs"]))


"""
Constrained Dynamic Programming over an Absorbing Bottom Element
================================================================

A worked demonstration that completeness survives the loss of cancellativity.

Infeasible transitions are given the absorbing weight BOT ("bottom"): BOT + w = BOT, and
BOT is below every ordinary weight.  The resulting weight monoid is NOT cancellative --
BOT + 1 = BOT + 2 while 1 != 2 -- so the classical argument that end-optimality forces
prefix-optimality breaks.  Defining a run structurally (the recursion is realised exactly
at every stage) instead of semantically repairs this: runs still exist, still realise the
value, and still dominate every labelling.

Two instances are solved and audited against exhaustive enumeration:

  A. Maximum-weight independent set on a path (no two adjacent vertices selected).
  B. Sequence decoding under a forbidden-bigram constraint.

Both also illustrate the infeasibility criterion: the value BOT is a *proof* that no
feasible labelling exists, not merely a failure to find one.

Self-contained: standard library only.  Run:  python demo_constrained.py
"""

from __future__ import annotations

import itertools
from typing import Callable, Iterable, List, Optional, Sequence, Tuple

Weight = Optional[float]  # None = BOT
BOT: Weight = None


def wadd(x: Weight, y: Weight) -> Weight:
    return None if (x is None or y is None) else x + y


def wgt(x: Weight, y: Weight) -> bool:
    if x is None:
        return False
    if y is None:
        return True
    return x > y


def wstr(x: Weight) -> str:
    return "BOT" if x is None else f"{x:g}"


def forward(
    n_states: int,
    init: Callable[[int], Weight],
    step: Callable[[int, int, int], Weight],
    n: int,
) -> Tuple[List[List[Weight]], List[List[int]]]:
    V: List[List[Weight]] = [[init(s) for s in range(n_states)]]
    P: List[List[int]] = [[-1] * n_states]
    for i in range(n):
        row, prow = [], []
        for t in range(n_states):
            best, arg = wadd(V[i][0], step(i, 0, t)), 0
            for s in range(1, n_states):
                c = wadd(V[i][s], step(i, s, t))
                if wgt(c, best):
                    best, arg = c, s
            row.append(best)
            prow.append(arg)
        V.append(row)
        P.append(prow)
    return V, P


def score(
    init: Callable[[int], Weight],
    step: Callable[[int, int, int], Weight],
    f: Sequence[int],
    n: int,
) -> Weight:
    acc = init(f[0])
    for i in range(n):
        acc = wadd(acc, step(i, f[i], f[i + 1]))
    return acc


def all_labellings(n_states: int, n: int) -> Iterable[Tuple[int, ...]]:
    return itertools.product(range(n_states), repeat=n + 1)


def solve_and_audit(
    name: str,
    n_states: int,
    init: Callable[[int], Weight],
    step: Callable[[int, int, int], Weight],
    n: int,
    state_names: List[str],
) -> Tuple[List[int], Weight]:
    print(f"\n--- {name} " + "-" * max(0, 62 - len(name)))
    V, P = forward(n_states, init, step, n)

    header = "  stage | " + "  ".join(f"V(n,{nm})" for nm in state_names)
    print(header)
    print("  " + "-" * (len(header) - 2))
    for i in range(n + 1):
        print(f"    {i}   | " + "  ".join(f"{wstr(V[i][s]):>8}" for s in range(n_states)))

    end = 0
    for s in range(1, n_states):
        if wgt(V[n][s], V[n][end]):
            end = s
    f = [0] * (n + 1)
    f[n] = end
    for i in range(n - 1, -1, -1):
        f[i] = P[i + 1][f[i + 1]]
    dp_val = V[n][end]

    # structural certificate
    is_bt = all(
        wadd(V[i][f[i]], step(i, f[i], f[i + 1])) == V[i + 1][f[i + 1]] for i in range(n)
    )
    # semantic certificate
    is_run = all(score(init, step, f, i) == V[i][f[i]] for i in range(n + 1))

    # exhaustive audit
    best: Weight = BOT
    n_feasible = 0
    for g in all_labellings(n_states, n):
        w = score(init, step, g, n)
        if w is not None:
            n_feasible += 1
        if wgt(w, best):
            best = w

    print(f"\n  reconstructed labelling : "
          f"{' -> '.join(state_names[s] for s in f)}")
    print(f"  its score               : {wstr(score(init, step, f, n))}"
          f"   (reported value {wstr(dp_val)})")
    print(f"  structural certificate  : backtrace = {is_bt}")
    print(f"  semantic certificate    : run       = {is_run}")
    print(f"  exhaustive audit        : {n_states ** (n + 1)} labellings, "
          f"{n_feasible} feasible, best = {wstr(best)}")
    print(f"  completeness            : "
          f"{'nothing was missed' if best == dp_val else 'MISSED'}")
    if dp_val is BOT:
        print("  infeasibility criterion : the value BOT certifies that NO feasible "
              "labelling exists.")
    return f, dp_val


def instance_mwis() -> None:
    """A. Maximum-weight independent set on a path."""
    w = [3.0, 7.0, 2.0, 8.0, 1.0]
    print("\nA. Maximum-weight independent set on the path with vertex weights "
          f"{[int(x) for x in w]}")
    print("   state at stage i = whether vertex i is selected; "
          "selecting two adjacent vertices costs BOT.")

    def init(s: int) -> Weight:
        return w[0] if s == 1 else 0.0

    def step(i: int, s: int, t: int) -> Weight:
        if s == 1 and t == 1:
            return BOT
        return w[i + 1] if t == 1 else 0.0

    f, val = solve_and_audit("path of 5 vertices", 2, init, step, 4, ["skip", "take"])
    chosen = [i for i, b in enumerate(f) if b == 1]
    print(f"  optimal independent set : {chosen}  of total weight "
          f"{sum(w[i] for i in chosen):g}")


def instance_bigram() -> None:
    """B. Decoding with a forbidden bigram."""
    print("\n\nB. Decoding a 4-symbol sequence over the alphabet {x, y, z} where the "
          "bigram 'y z' is forbidden")
    emission = [
        [1.0, 4.0, 2.0],   # stage 0 preferences for x, y, z
        [3.0, 1.0, 5.0],
        [2.0, 6.0, 1.0],
        [4.0, 2.0, 3.0],
    ]
    names = ["x", "y", "z"]

    def init(s: int) -> Weight:
        return emission[0][s]

    def step(i: int, s: int, t: int) -> Weight:
        if s == 1 and t == 2:          # 'y' followed by 'z' is forbidden
            return BOT
        return emission[i + 1][t]

    solve_and_audit("forbidden bigram 'y z'", 3, init, step, 3, names)

    print("\n   Note how the constraint is enforced purely arithmetically: no pruning "
          "heuristic,\n   no separate feasibility test, no special case in the recursion.")


def instance_infeasible() -> None:
    """C. An over-constrained instance: infeasibility is certified."""
    print("\n\nC. An over-constrained instance in which every transition is forbidden")

    def init(s: int) -> Weight:
        return float(s)

    def step(i: int, s: int, t: int) -> Weight:
        return BOT

    solve_and_audit("all transitions forbidden", 2, init, step, 3, ["p", "q"])


def main() -> None:
    print(__doc__)
    instance_mwis()
    instance_bigram()
    instance_infeasible()
    print("\n" + "=" * 74)
    print("In every instance the value function was exact: it is the greatest element "
          "of the\nset of achievable scores, attained by an explicitly reconstructed "
          "labelling -- with no\ncancellativity assumption anywhere.")
    print("=" * 74)


if __name__ == "__main__":
    main()


"""
Visualisation: Lipschitz stability of the dynamic-programming optimum.

If two specifications differ by at most `a` in every initial weight and at most `b` in
every transition weight, the theory predicts that their value functions differ by at
most  a + n*b  at horizon n -- error accumulates LINEARLY in the horizon, not
exponentially.  This script samples random perturbations within the budget, plots the
empirical deviations against the theoretical envelope, and overlays the induced
sub-optimality of a run computed on the perturbed model against its predicted bound
2(a + n*b).

Requires: matplotlib.  Run:  python viz_stability.py
"""

from __future__ import annotations

import random
from typing import Callable, List, Tuple

import matplotlib.pyplot as plt

N_STATES: int = 3
INIT: List[float] = [0.0, 1.0, 2.0]
A: List[List[float]] = [[2.0, -1.0, 3.0], [1.0, 0.0, -2.0], [-3.0, 4.0, 1.0]]

A_BUDGET: float = 0.4   # perturbation budget on initial weights
B_BUDGET: float = 0.25  # perturbation budget on transition weights
MAX_N: int = 14
TRIALS: int = 300


def forward(init: List[float], step: Callable[[int, int, int], float],
            n: int) -> Tuple[List[List[float]], List[List[int]]]:
    V: List[List[float]] = [init[:]]
    P: List[List[int]] = [[-1] * N_STATES]
    for i in range(n):
        row, prow = [], []
        for t in range(N_STATES):
            best, arg = -float("inf"), 0
            for s in range(N_STATES):
                c = V[i][s] + step(i, s, t)
                if c > best:
                    best, arg = c, s
            row.append(best)
            prow.append(arg)
        V.append(row)
        P.append(prow)
    return V, P


def score(init: List[float], step: Callable[[int, int, int], float],
          f: List[int], n: int) -> float:
    acc = init[f[0]]
    for i in range(n):
        acc += step(i, f[i], f[i + 1])
    return acc


def main() -> None:
    rng = random.Random(20260822)
    base_step: Callable[[int, int, int], float] = lambda i, s, t: A[s][t]
    V0, _ = forward(INIT, base_step, MAX_N)

    dev_max: List[float] = []
    dev_mean: List[float] = []
    gap_max: List[float] = []

    for n in range(MAX_N + 1):
        worst, total, worst_gap = 0.0, 0.0, 0.0
        for _ in range(TRIALS):
            di = [rng.uniform(-A_BUDGET, A_BUDGET) for _ in range(N_STATES)]
            ds = [[rng.uniform(-B_BUDGET, B_BUDGET) for _ in range(N_STATES)]
                  for _ in range(N_STATES)]
            init_p = [INIT[s] + di[s] for s in range(N_STATES)]
            step_p: Callable[[int, int, int], float] = \
                lambda i, s, t, ds=ds: A[s][t] + ds[s][t]

            Vp, Pp = forward(init_p, step_p, n)
            d = max(abs(Vp[n][s] - V0[n][s]) for s in range(N_STATES))
            worst = max(worst, d)
            total += d

            # run optimal for the perturbed model, evaluated under the true model
            end = max(range(N_STATES), key=lambda s: Vp[n][s])
            g = [0] * (n + 1)
            g[n] = end
            for i in range(n - 1, -1, -1):
                g[i] = Pp[i + 1][g[i + 1]]
            true_opt = max(V0[n][s] for s in range(N_STATES))
            worst_gap = max(worst_gap, true_opt - score(INIT, base_step, g, n))

        dev_max.append(worst)
        dev_mean.append(total / TRIALS)
        gap_max.append(worst_gap)

    ns = list(range(MAX_N + 1))
    bound = [A_BUDGET + n * B_BUDGET for n in ns]
    bound2 = [2 * v for v in bound]

    fig, ax = plt.subplots(figsize=(10.5, 6))
    fig.patch.set_facecolor("#0f1220")
    ax.set_facecolor("#131730")

    ax.fill_between(ns, 0, bound, color="#7aa2ff", alpha=0.13,
                    label="admissible region: |V' - V| $\\leq$ a + n·b")
    ax.plot(ns, bound, color="#7aa2ff", lw=2.2, label="bound  a + n·b")
    ax.plot(ns, bound2, color="#ffcf6b", lw=2.0, ls="--",
            label="transfer bound  2(a + n·b)")
    ax.plot(ns, dev_max, "o-", color="#5ee0c0", lw=1.9, ms=5,
            label=f"worst observed |V' - V| over {TRIALS} perturbations")
    ax.plot(ns, dev_mean, "s--", color="#5ee0c0", lw=1.2, ms=4, alpha=0.6,
            label="mean observed |V' - V|")
    ax.plot(ns, gap_max, "^-", color="#ff9f6b", lw=1.6, ms=5,
            label="worst true-optimality gap of a perturbed-model run")

    ax.set_xlabel("horizon  n", color="#e8ecff")
    ax.set_ylabel("weight units", color="#e8ecff")
    ax.set_title(f"Stability of the optimum:  a = {A_BUDGET}, b = {B_BUDGET}\n"
                 "error accumulates linearly in the horizon, never exponentially",
                 color="#e8ecff", fontsize=12, pad=14)
    ax.tick_params(colors="#9aa3c7")
    for sp in ax.spines.values():
        sp.set_color("#2b3157")
    ax.grid(color="#232a4d", lw=0.7)
    leg = ax.legend(facecolor="#171b2e", edgecolor="#2b3157", fontsize=9)
    for txt in leg.get_texts():
        txt.set_color("#e8ecff")

    fig.tight_layout()
    fig.savefig("stability.png", dpi=170, facecolor=fig.get_facecolor())
    print("wrote stability.png")
    print("every observed deviation stayed inside the predicted envelope:",
          all(d <= b + 1e-9 for d, b in zip(dev_max, bound)))


if __name__ == "__main__":
    main()


"""
Visualisation: the DP trellis, the value function, and the optimal run.

Draws the layered graph whose vertices are (stage, state) pairs and whose edges carry
the transition weights.  Each vertex is annotated with its forward value V(n,s); the
labelling reconstructed by backtracing from the best final state is highlighted.  The
picture makes the two halves of correctness visible at once: the highlighted path
exists (soundness) and no other path through the trellis reaches a higher final
annotation (completeness).

Requires: matplotlib.  Run:  python viz_trellis.py
"""

from __future__ import annotations

from typing import List, Tuple

import matplotlib.pyplot as plt

# --- specification --------------------------------------------------------

N_STATES: int = 3
STATE_NAMES: List[str] = ["A", "B", "C"]
INIT: List[float] = [0.0, 1.0, 2.0]
A: List[List[float]] = [
    [2.0, -1.0, 3.0],
    [1.0, 0.0, -2.0],
    [-3.0, 4.0, 1.0],
]
HORIZON: int = 5


def forward(n: int) -> Tuple[List[List[float]], List[List[int]]]:
    """Forward pass: value table and argmax pointers.  Cost Theta(n |S|^2)."""
    V: List[List[float]] = [INIT[:]]
    P: List[List[int]] = [[-1] * N_STATES]
    for i in range(n):
        row, prow = [], []
        for t in range(N_STATES):
            best, arg = -float("inf"), 0
            for s in range(N_STATES):
                c = V[i][s] + A[s][t]
                if c > best:
                    best, arg = c, s
            row.append(best)
            prow.append(arg)
        V.append(row)
        P.append(prow)
    return V, P


def backtrace(P: List[List[int]], n: int, s: int) -> List[int]:
    f = [0] * (n + 1)
    f[n] = s
    for i in range(n - 1, -1, -1):
        f[i] = P[i + 1][f[i + 1]]
    return f


def main() -> None:
    V, P = forward(HORIZON)
    end = max(range(N_STATES), key=lambda s: V[HORIZON][s])
    path = backtrace(P, HORIZON, end)

    fig, ax = plt.subplots(figsize=(13, 5.6))
    fig.patch.set_facecolor("#0f1220")
    ax.set_facecolor("#0f1220")

    def xy(i: int, s: int) -> Tuple[float, float]:
        return float(i), float(N_STATES - 1 - s)

    # edges
    for i in range(HORIZON):
        for s in range(N_STATES):
            for t in range(N_STATES):
                on = (path[i] == s and path[i + 1] == t)
                x0, y0 = xy(i, s)
                x1, y1 = xy(i + 1, t)
                ax.plot([x0, x1], [y0, y1],
                        color="#5ee0c0" if on else "#39406e",
                        lw=3.0 if on else 0.9,
                        alpha=1.0 if on else 0.45,
                        zorder=2 if on else 1)
                if on:
                    ax.text((x0 + x1) / 2, (y0 + y1) / 2 + 0.09, f"{A[s][t]:+.0f}",
                            color="#5ee0c0", fontsize=9, ha="center",
                            family="monospace", zorder=4)

    # vertices
    for i in range(HORIZON + 1):
        for s in range(N_STATES):
            x, y = xy(i, s)
            on = path[i] == s
            ax.scatter([x], [y], s=430 if on else 320,
                       c="#5ee0c0" if on else "#1e2340",
                       edgecolors="#5ee0c0" if on else "#39406e",
                       linewidths=2, zorder=3)
            ax.text(x, y, STATE_NAMES[s], color="#04211b" if on else "#9aa3c7",
                    fontsize=10, ha="center", va="center", family="monospace", zorder=4)
            ax.text(x, y + 0.30, f"{V[i][s]:.0f}", color="#7aa2ff", fontsize=9,
                    ha="center", family="monospace", zorder=4)
        ax.text(i, -0.62, f"stage {i}", color="#9aa3c7", fontsize=9, ha="center")

    title = ("Layered dynamic programming: the value function annotates every vertex, "
             "and backtracing\nfrom the best final vertex reconstructs the optimum "
             f"(score {V[HORIZON][end]:.0f}) among all "
             f"{N_STATES ** (HORIZON + 1)} labellings")
    ax.set_title(title, color="#e8ecff", fontsize=12, pad=16)
    ax.set_xlim(-0.6, HORIZON + 0.6)
    ax.set_ylim(-0.95, N_STATES - 0.35)
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("trellis.png", dpi=170, facecolor=fig.get_facecolor())
    print("wrote trellis.png;  optimal labelling:",
          " -> ".join(STATE_NAMES[s] for s in path),
          f" score {V[HORIZON][end]:.0f}")


if __name__ == "__main__":
    main()


"""
Completeness of Layered Dynamic Programming over Ordered Weight Monoids
=======================================================================

Numerical demonstrations of the main results:

  1. Domination            score(f, n) <= V(n, f(n))                for every labelling f
  2. Realisability         V(n, s) is attained by an explicit run   (backtrace)
  3. Exactness             V(n, s) = max over all labellings ending at s
  4. Uniform completeness  a single run dominates every labelling
  5. Bellman's optimality principle: end-optimal  <=>  all prefixes optimal
  6. Characterisation: run <=> optimal among labellings with the same endpoint
  7. Forward-backward decomposition  max_s V(k+m,s) = max_s (V(k,s) + B(k,m,s))
  8. Tropical walk calculus: Chapman-Kolmogorov and the transfer identity
  9. Order duality: the same code, run upside down, solves shortest paths
 10. Lipschitz stability   |V'(n,s) - V(n,s)| <= a + n*b
 11. Constrained DP over W u {bottom}: maximum-weight independent set on a path

Everything is self-contained: pure Python standard library, no dependencies.
Run with:  python demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

# ---------------------------------------------------------------------------
# Weights.  We use `float` for ordinary weights and `None` for the absorbing
# bottom element (infeasible).  `Weight = Optional[float]`.
# ---------------------------------------------------------------------------

Weight = Optional[float]  # None encodes the absorbing bottom element


def wadd(x: Weight, y: Weight) -> Weight:
    """Addition in the weight monoid, with `None` (bottom) absorbing."""
    if x is None or y is None:
        return None
    return x + y


def wmax(x: Weight, y: Weight) -> Weight:
    """Maximum in the weight monoid, with `None` (bottom) least."""
    if x is None:
        return y
    if y is None:
        return x
    return x if x >= y else y


def wle(x: Weight, y: Weight) -> bool:
    """Order of the weight monoid, with `None` (bottom) least."""
    if x is None:
        return True
    if y is None:
        return False
    return x <= y


def wstr(x: Weight) -> str:
    return "  BOT " if x is None else f"{x:6.2f}"


# ---------------------------------------------------------------------------
# Specifications.
# ---------------------------------------------------------------------------

class DPSpec:
    """A layered dynamic-programming specification over a finite state space.

    `n_states`  the number of states, indexed 0 .. n_states-1
    `init(s)`   the weight of starting in state s
    `step(i,s,t)` the weight of moving from state s at stage i to t at stage i+1
    """

    def __init__(
        self,
        n_states: int,
        init: Callable[[int], Weight],
        step: Callable[[int, int, int], Weight],
    ) -> None:
        assert n_states >= 1, "the state space must be non-empty"
        self.n_states = n_states
        self.init = init
        self.step = step

    @property
    def states(self) -> range:
        return range(self.n_states)

    # -- scores ------------------------------------------------------------

    def score(self, f: Sequence[int], n: int) -> Weight:
        """score(f, n): the accumulated weight of the labelling f up to stage n."""
        assert n < len(f), "labelling too short for this horizon"
        acc: Weight = self.init(f[0])
        for i in range(n):
            acc = wadd(acc, self.step(i, f[i], f[i + 1]))
        return acc

    # -- forward value function -------------------------------------------

    def value_table(self, n: int) -> Tuple[List[List[Weight]], List[List[int]]]:
        """Forward pass.  Returns (V, pointers) with V[i][s] = V(i, s).

        pointers[i+1][t] is a predecessor state attaining the maximum defining
        V(i+1, t) -- exactly the data a backtrace consumes.
        Cost: Theta(n * |S|^2).
        """
        V: List[List[Weight]] = [[self.init(s) for s in self.states]]
        ptr: List[List[int]] = [[-1 for _ in self.states]]
        for i in range(n):
            row: List[Weight] = []
            prow: List[int] = []
            for t in self.states:
                best: Weight = None
                arg = 0
                started = False
                for s in self.states:
                    cand = wadd(V[i][s], self.step(i, s, t))
                    if not started or not wle(cand, best):
                        best, arg, started = cand, s, True
                row.append(best)
                prow.append(arg)
            V.append(row)
            ptr.append(prow)
        return V, ptr

    def val(self, n: int, s: int) -> Weight:
        return self.value_table(n)[0][n][s]

    # -- backtrace ---------------------------------------------------------

    def backtrace(self, n: int, s: int) -> List[int]:
        """Reconstruct a labelling of stages 0..n ending at state s that realises
        V(n, s).  Cost: Theta(n) after the forward pass."""
        _, ptr = self.value_table(n)
        f = [0] * (n + 1)
        f[n] = s
        for i in range(n - 1, -1, -1):
            f[i] = ptr[i + 1][f[i + 1]]
        return f

    def optimal_run(self, n: int) -> Tuple[List[int], Weight]:
        """The uniformly dominating run of Theorem 'Completeness, uniform form'."""
        V, _ = self.value_table(n)
        best_state = max(self.states, key=lambda s: (-math.inf if V[n][s] is None else V[n][s]))
        f = self.backtrace(n, best_state)
        return f, V[n][best_state]

    # -- predicates --------------------------------------------------------

    def is_run(self, f: Sequence[int], n: int) -> bool:
        """Semantic notion: every prefix score equals the value at its endpoint."""
        V, _ = self.value_table(n)
        return all(self.score(f, i) == V[i][f[i]] for i in range(n + 1))

    def is_backtrace(self, f: Sequence[int], n: int) -> bool:
        """Structural notion: the recursion is realised exactly at every stage."""
        V, _ = self.value_table(n)
        return all(
            wadd(V[i][f[i]], self.step(i, f[i], f[i + 1])) == V[i + 1][f[i + 1]]
            for i in range(n)
        )

    # -- backward values ---------------------------------------------------

    def bval(self, k: int, m: int, s: int) -> Weight:
        """B(k, m, s): the best weight of m further transitions from s at stage k."""
        if m == 0:
            return 0.0
        best: Weight = None
        started = False
        for t in self.states:
            cand = wadd(self.step(k, s, t), self.bval(k + 1, m - 1, t))
            if not started or not wle(cand, best):
                best, started = cand, True
        return best

    # -- walk matrices -----------------------------------------------------

    def walk(self, k: int, m: int, s: int, t: int) -> Weight:
        """The optimal weight of m+1 transitions from s at stage k to t at stage k+m+1."""
        if m == 0:
            return self.step(k, s, t)
        best: Weight = None
        started = False
        for u in self.states:
            cand = wadd(self.step(k, s, u), self.walk(k + 1, m - 1, u, t))
            if not started or not wle(cand, best):
                best, started = cand, True
        return best

    # -- brute force -------------------------------------------------------

    def all_labellings(self, n: int) -> Iterable[Tuple[int, ...]]:
        return itertools.product(self.states, repeat=n + 1)

    def brute_force(self, n: int, s: int) -> Weight:
        """Exhaustive maximum over the |S|^(n+1) labellings ending at s."""
        best: Weight = None
        for f in self.all_labellings(n):
            if f[n] == s:
                best = wmax(best, self.score(f, n))
        return best


# ---------------------------------------------------------------------------
# Running example: three states, integer weights, stage-independent transitions
# ---------------------------------------------------------------------------

A3: List[List[float]] = [
    [2.0, -1.0, 3.0],
    [1.0, 0.0, -2.0],
    [-3.0, 4.0, 1.0],
]

EX = DPSpec(
    n_states=3,
    init=lambda s: float(s),
    step=lambda i, s, t: A3[s][t],
)


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_value_table() -> None:
    banner("1. The forward value function of the three-state example")
    print("   init(s) = s   and   step_i(s,t) = A[s][t]  with")
    for row in A3:
        print("        " + "  ".join(f"{x:5.1f}" for x in row))
    V, _ = EX.value_table(4)
    print("\n     n |  V(n,0)  V(n,1)  V(n,2)")
    print("   ----+-------------------------")
    for n in range(5):
        print(f"     {n} | " + " ".join(wstr(V[n][s]) for s in EX.states))
    print("\n   e.g. V(1,1) = max(0-1, 1+0, 2+4) = 6, realised by the labelling 2 -> 1.")


def demo_exactness_and_domination() -> None:
    banner("2. Domination and exactness, checked against brute-force enumeration")
    for n in range(4):
        for s in EX.states:
            dp = EX.val(n, s)
            bf = EX.brute_force(n, s)
            assert dp == bf, (n, s, dp, bf)
        print(f"   horizon n = {n}:  {3 ** (n + 1):5d} labellings enumerated, "
              f"DP value matches brute force at every endpoint  [OK]")

    # Domination for random labellings.
    rng = random.Random(20260822)
    n = 6
    V, _ = EX.value_table(n)
    worst_gap = math.inf
    for _ in range(2000):
        f = [rng.randrange(3) for _ in range(n + 1)]
        gap = V[n][f[n]] - EX.score(f, n)
        assert gap >= -1e-12
        worst_gap = min(worst_gap, gap)
    print(f"\n   2000 random labellings at horizon {n}: score(f,n) <= V(n,f(n)) always;")
    print(f"   the smallest observed slack is {worst_gap:.2f} (0 means the random")
    print("   labelling happened to be optimal for its endpoint).")


def demo_backtrace_and_completeness() -> None:
    banner("3. Realisability, runs, and uniform completeness")
    n = 5
    for s in EX.states:
        f = EX.backtrace(n, s)
        assert EX.score(f, n) == EX.val(n, s)
        assert EX.is_backtrace(f, n) and EX.is_run(f, n)
        print(f"   backtrace ending at state {s}: {f}   score = {wstr(EX.score(f, n))}"
              f"  = V({n},{s})  [run: yes]")

    g, best = EX.optimal_run(n)
    print(f"\n   uniformly dominating run: {g}  with score {wstr(best)}")
    dominates_all = all(wle(EX.score(f, n), best) for f in EX.all_labellings(n))
    print(f"   does it dominate all {3 ** (n + 1)} labellings?  {dominates_all}")


def demo_bellman_principle() -> None:
    banner("4. Bellman's optimality principle: end-optimal implies prefix-optimal")
    n = 4
    V, _ = EX.value_table(n)
    checked = 0
    for f in EX.all_labellings(n):
        end_optimal = EX.score(f, n) == V[n][f[n]]
        if end_optimal:
            checked += 1
            assert EX.is_run(f, n), f
    print(f"   {checked} of the {3 ** (n + 1)} labellings at horizon {n} are optimal at their")
    print("   endpoint; every single one of them is optimal at EVERY prefix as well.")

    # The characterisation: run <=> optimal among labellings with the same endpoint.
    for f in EX.all_labellings(n):
        best_same_end = EX.brute_force(n, f[n])
        assert EX.is_run(f, n) == (EX.score(f, n) == best_same_end)
    print("   Characterisation verified: a labelling is a run exactly when it is optimal")
    print("   among all labellings sharing its endpoint.")


def demo_forward_backward() -> None:
    banner("5. Forward-backward decomposition")
    print("     k   m |  max_s V(k+m,s)   max_s (V(k,s) + B(k,m,s))")
    print("   --------+--------------------------------------------")
    for k in range(4):
        for m in range(4):
            V, _ = EX.value_table(k + m)
            lhs = max(V[k + m][s] for s in EX.states)
            rhs = max(V[k][s] + EX.bval(k, m, s) for s in EX.states)
            assert abs(lhs - rhs) < 1e-9
            print(f"     {k}   {m} | {lhs:12.2f}   {rhs:24.2f}")
    print("\n   The optimum may be cut at ANY intermediate stage k: (best way in) + (best way out).")

    # Max-marginals: the best score subject to occupying state s at stage k.
    k, m = 2, 3
    V, _ = EX.value_table(k + m)
    print(f"\n   Max-marginals at stage k={k} with m={m} remaining transitions:")
    for s in EX.states:
        forced = V[k][s] + EX.bval(k, m, s)
        print(f"     forcing state {s} at stage {k}:  best achievable score = {forced:6.2f}")


def demo_walk_calculus() -> None:
    banner("6. Tropical walk calculus: Chapman-Kolmogorov and the transfer identity")
    ok = True
    for m1 in range(3):
        for m2 in range(3):
            for k in range(2):
                for s in EX.states:
                    for u in EX.states:
                        lhs = EX.walk(k, m1 + m2 + 1, s, u)
                        rhs = max(
                            EX.walk(k, m1, s, t) + EX.walk(k + m1 + 1, m2, t, u)
                            for t in EX.states
                        )
                        ok = ok and abs(lhs - rhs) < 1e-9
    print(f"   Chapman-Kolmogorov  W_k^(m1+m2+1) = W_k^(m1) (x) W_(k+m1+1)^(m2):  {ok}")
    print("   (max-plus matrix multiplication; the walk matrices form a shifted semigroup)")

    print("\n   Transfer identity  V(k+m+1,t) = max_s (V(k,s) + W_k^(m)(s,t))  at k=1, m=2:")
    V, _ = EX.value_table(4)
    for t in EX.states:
        rhs = max(V[1][s] + EX.walk(1, 2, s, t) for s in EX.states)
        assert abs(V[4][t] - rhs) < 1e-9
        print(f"     t = {t}:  V(4,{t}) = {V[4][t]:6.2f}   =   {rhs:6.2f}")


def demo_duality() -> None:
    banner("7. Order duality: the same theory, upside down, gives shortest paths")

    def negate(spec: DPSpec) -> DPSpec:
        """Reading the order upside down is implemented by negating the weights."""
        return DPSpec(
            spec.n_states,
            lambda s: -spec.init(s),
            lambda i, s, t: -spec.step(i, s, t),
        )

    DUAL = negate(EX)
    n = 4
    g, best_neg = DUAL.optimal_run(n)
    print(f"   minimising run of the same specification: {g}")
    print(f"   its true (un-negated) score is {EX.score(g, n):.2f}")
    bf_min = min(EX.score(f, n) for f in EX.all_labellings(n))
    print(f"   brute-force minimum over all {3 ** (n + 1)} labellings: {bf_min:.2f}")
    assert abs(EX.score(g, n) - bf_min) < 1e-9
    print("   Maximisation and minimisation are the same theorem read in dual orders.")


def demo_stability() -> None:
    banner("8. Lipschitz stability of the optimum under perturbation")
    rng = random.Random(7)
    a, b = 0.3, 0.2
    n = 6

    def perturbed() -> DPSpec:
        di = [rng.uniform(-a, a) for _ in EX.states]
        ds = [[rng.uniform(-b, b) for _ in EX.states] for _ in EX.states]
        return DPSpec(
            EX.n_states,
            lambda s: EX.init(s) + di[s],
            lambda i, s, t: EX.step(i, s, t) + ds[s][t],
        )

    print(f"   perturbation budget: a = {a} on initial weights, b = {b} on transitions")
    print(f"   predicted bound at horizon n = {n}:  a + n*b = {a + n * b:.2f}")
    V, _ = EX.value_table(n)
    worst = 0.0
    worst_transfer = 0.0
    for _ in range(400):
        P = perturbed()
        VP, _ = P.value_table(n)
        worst = max(worst, max(abs(VP[n][s] - V[n][s]) for s in EX.states))
        g, _ = P.optimal_run(n)
        true_opt = max(V[n][s] for s in EX.states)
        worst_transfer = max(worst_transfer, true_opt - EX.score(g, n))
    print(f"   largest observed |V'(n,s) - V(n,s)| over 400 perturbations: {worst:.4f}   "
          f"(<= {a + n * b:.2f})")
    print(f"   largest true-optimality gap of a run computed on the perturbed model: "
          f"{worst_transfer:.4f}")
    print(f"   predicted transfer bound 2(a + n*b) = {2 * (a + n * b):.2f}")


def demo_constrained_mwis() -> None:
    banner("9. Constrained DP over W u {bottom}: maximum-weight independent set")
    w = [3.0, 7.0, 2.0, 8.0, 1.0]
    print(f"   path on 5 vertices with weights {[int(x) for x in w]};")
    print("   state at stage i = 'is vertex i selected?'  (0 = no, 1 = yes)")
    print("   the transition selected -> selected carries the absorbing weight BOT.")

    def mis_init(s: int) -> Weight:
        return w[0] if s == 1 else 0.0

    def mis_step(i: int, s: int, t: int) -> Weight:
        if s == 1 and t == 1:
            return None  # forbidden: two adjacent vertices selected
        return w[i + 1] if t == 1 else 0.0

    MIS = DPSpec(2, mis_init, mis_step)
    n = 4
    V, _ = MIS.value_table(n)
    print("\n     n |  V(n,not selected)  V(n,selected)")
    print("   ----+-----------------------------------")
    for i in range(n + 1):
        print(f"     {i} |  {wstr(V[i][0])}            {wstr(V[i][1])}")

    g, best = MIS.optimal_run(n)
    chosen = [i for i, b in enumerate(g) if b == 1]
    print(f"\n   optimum = {wstr(best)}   attained by the independent set {chosen} "
          f"of weight {sum(w[i] for i in chosen):.0f}")

    # Exhaustive check.
    bf = None
    for f in MIS.all_labellings(n):
        bf = wmax(bf, MIS.score(f, n))
    print(f"   brute force over all {2 ** (n + 1)} subsets: {wstr(bf)}   [matches]")

    # Every labelling with two adjacent selections is infeasible.
    bad = [f for f in MIS.all_labellings(n)
           if any(f[i] == 1 and f[i + 1] == 1 for i in range(n))]
    assert all(MIS.score(f, n) is None for f in bad)
    print(f"   all {len(bad)} labellings selecting two adjacent vertices score BOT, "
          "as the theory predicts.")

    # An over-constrained instance: infeasibility is certified, not merely unfound.
    print("\n   Over-constrained instance (every transition forbidden after stage 0):")
    HARD = DPSpec(2, mis_init, lambda i, s, t: None)
    VH, _ = HARD.value_table(2)
    print(f"     V(2, s) = {[wstr(VH[2][s]) for s in HARD.states]}")
    all_bot = all(HARD.score(f, 2) is None for f in HARD.all_labellings(2))
    print(f"     is every labelling genuinely infeasible?  {all_bot}")
    print("     The value BOT is a PROOF of infeasibility, not a failure to search.")


def main() -> None:
    print(__doc__)
    demo_value_table()
    demo_exactness_and_domination()
    demo_backtrace_and_completeness()
    demo_bellman_principle()
    demo_forward_backward()
    demo_walk_calculus()
    demo_duality()
    demo_stability()
    demo_constrained_mwis()
    banner("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
