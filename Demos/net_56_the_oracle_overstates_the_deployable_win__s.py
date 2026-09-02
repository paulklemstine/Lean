"""
Algorithm C --- Min-Plus (Tropical) Allocation of a Global Cache Budget Across Layers.

A transformer has L attention layers; each layer ell has a loss curve
f_ell(a) giving the loss incurred when that layer receives a cache slots.  The
best way to spend a global budget B is

    alloc(f_1, ..., f_L)(B) = min over (a_1 + ... + a_L = B) of sum_ell f_ell(a_ell),

which is the iterated min-plus convolution of the curves --- the same operation
that governs shortest paths and scheduling in tropical algebra.  Written
recursively,

    alloc([f])(B)         = f(B),
    alloc(f :: rest)(B)   = min_{0 <= a <= B} ( f(a) + alloc(rest)(B - a) ).

Dynamic programming evaluates this in O(L * B^2) time and O(B) space, and the
argmin bookkeeping recovers the optimal per-layer split.

The theory attached to this operator is the *penalty-passing* theorem: if every
layer's deployable loss exceeds its oracle loss pointwise by at least delta,
then the optimally allocated L-layer deployable loss exceeds the optimally
allocated L-layer oracle loss by at least L*delta.  No convexity or monotonicity
of the curves is assumed.  Consequence for practice: reallocating a global
budget across depth cannot recover a per-layer policy penalty; the correction
must be applied once per layer.
"""

from __future__ import annotations

from typing import List, Sequence, Tuple

Curve = Sequence[float]   # curve[a] = loss of this layer at budget a, 0 <= a <= B


def allocate(curves: Sequence[Curve], budget: int) -> Tuple[float, List[int]]:
    """
    Optimal global allocation by dynamic programming.

    Returns (optimal total loss, per-layer budgets summing to `budget`).
    Time O(L * B^2), space O(L * B).
    """
    L = len(curves)
    if L == 0:
        return 0.0, []
    # best[i][r] = optimal loss of layers i..L-1 given remaining budget r
    inf = float("inf")
    best: List[List[float]] = [[inf] * (budget + 1) for _ in range(L + 1)]
    take: List[List[int]] = [[0] * (budget + 1) for _ in range(L + 1)]
    for r in range(budget + 1):
        best[L][r] = 0.0 if r == 0 else inf
    # the last layer must absorb whatever remains
    for r in range(budget + 1):
        best[L - 1][r] = curves[L - 1][r]
        take[L - 1][r] = r
    for i in range(L - 2, -1, -1):
        for r in range(budget + 1):
            local_best, local_arg = inf, 0
            for a in range(r + 1):
                value = curves[i][a] + best[i + 1][r - a]
                if value < local_best:
                    local_best, local_arg = value, a
            best[i][r] = local_best
            take[i][r] = local_arg
    # reconstruct
    split: List[int] = []
    remaining = budget
    for i in range(L):
        a = take[i][remaining]
        split.append(a)
        remaining -= a
    return best[0][budget], split


def min_plus(f: Curve, g: Curve, budget: int) -> float:
    """Two-layer min-plus convolution (f (+) g)(B); commutative in f and g."""
    return min(f[a] + g[budget - a] for a in range(budget + 1))


def penalty_check(
    oracle_curves: Sequence[Curve], delta: float, budget: int
) -> Tuple[float, float, float]:
    """
    Verify the penalty-passing theorem numerically on given oracle curves.

    Returns (oracle allocation loss, policy allocation loss, L*delta) and
    asserts policy >= oracle + L*delta.
    """
    policy_curves = [[x + delta for x in curve] for curve in oracle_curves]
    o_loss, _ = allocate(oracle_curves, budget)
    p_loss, _ = allocate(policy_curves, budget)
    accumulated = len(oracle_curves) * delta
    assert p_loss >= o_loss + accumulated - 1e-12
    return o_loss, p_loss, accumulated


if __name__ == "__main__":
    budget = 12
    # deliberately non-convex per-layer curves
    curves: List[List[float]] = [
        [1.00, 0.81, 0.70, 0.70, 0.52, 0.51, 0.40, 0.39, 0.31, 0.30, 0.22, 0.21, 0.20],
        [1.00, 0.95, 0.60, 0.58, 0.57, 0.35, 0.34, 0.33, 0.19, 0.18, 0.12, 0.11, 0.09],
        [1.00, 0.70, 0.69, 0.55, 0.40, 0.39, 0.38, 0.26, 0.25, 0.17, 0.16, 0.10, 0.08],
        [1.00, 0.88, 0.75, 0.61, 0.60, 0.44, 0.30, 0.29, 0.28, 0.21, 0.14, 0.13, 0.07],
    ]
    total, split = allocate(curves, budget)
    print(f"optimal allocation of B={budget}: {split}  -> loss {total:.4f}")
    assert sum(split) == budget
    assert abs(min_plus(curves[0], curves[1], budget) - allocate(curves[:2], budget)[0]) < 1e-12
    for delta in (0.01, 0.05, 0.10):
        o, p, acc = penalty_check(curves, delta, budget)
        print(f"delta={delta:.2f}: oracle {o:.4f}  policy {p:.4f}  "
              f"difference {p - o:.4f}  >=  L*delta = {acc:.4f}")


"""
Algorithm A --- Retrospective Optimal Cache Selection and the Consistency Defect.

Two routines that together turn an oracle retention table into an honest
deployment forecast:

  * `optimal_cache_by_exchange`: the exchange lemma made executable.  The best
    cache of size B for a known attention row is obtained by taking the B keys
    of largest weight; sorting makes this O(n log n) (or O(n) with a selection
    algorithm), and no search over the C(n, B) admissible caches is needed.

  * `consistency_defect` and `corrected_retention_bound`: for the score
    actually used online, the *consistency defect* is

        eps = max_+ { w_t(k) - w_t(j) : s(k) <= s(j) },

    the largest amount by which the score inverts the true row.  The theory
    guarantees

        oracle(B) <= kept(top_B(s)) + B * eps,

    with equality attained on an explicit instance, so B*eps is exactly the
    correction that must be subtracted from a published oracle number.

The naive defect computation is O(n^2).  `consistency_defect` below runs in
O(n log n) by sorting keys in ascending score order and sweeping a running
maximum of the attention weight over the score-inferior prefix.
"""

from __future__ import annotations

from typing import List, Sequence, Set, Tuple


def optimal_cache_by_exchange(row: Sequence[float], budget: int) -> Tuple[Set[int], float]:
    """
    Return (optimal cache, retained mass) for a known attention row.

    Correctness is the exchange lemma: if H holds the B largest weights and S is
    any admissible cache, then every key in S \\ H is worth no more than every
    key in H \\ S, and |S \\ H| <= |H \\ S|, so swapping keys one at a time never
    decreases the retained mass.  Complexity O(n log n).
    """
    n = len(row)
    order = sorted(range(n), key=lambda j: (-row[j], j))
    chosen = set(order[: max(0, min(budget, n))])
    return chosen, sum(row[j] for j in chosen)


def top_by_score(score: Sequence[float], budget: int) -> Set[int]:
    """The `budget` best-scoring keys, ties broken by smaller index."""
    n = len(score)
    order = sorted(range(n), key=lambda j: (-score[j], j))
    return set(order[: max(0, min(budget, n))])


def consistency_defect(row: Sequence[float], score: Sequence[float]) -> float:
    """
    eps = max_+ { row[k] - row[j] : score[k] <= score[j] }, in O(n log n).

    Sort the keys by ascending score.  Sweeping left to right, maintain the
    running maximum M of `row` over all keys seen so far (these are exactly the
    keys of score <= the current key's score, ties included by processing whole
    ties before recording).  Each key j contributes M - row[j].
    """
    n = len(row)
    order = sorted(range(n), key=lambda j: score[j])
    best = 0.0
    running_max = float("-inf")
    i = 0
    while i < n:
        # process the whole tie group at this score level first
        group_end = i
        while group_end < n and score[order[group_end]] == score[order[i]]:
            group_end += 1
        for t in range(i, group_end):
            running_max = max(running_max, row[order[t]])
        for t in range(i, group_end):
            best = max(best, running_max - row[order[t]])
        i = group_end
    return max(best, 0.0)


def corrected_retention_bound(
    row: Sequence[float], score: Sequence[float], budget: int
) -> dict:
    """
    Everything a deployment table needs for one row and one budget.

    Returns the oracle value, the retention actually achieved by the
    score-ranked cache, the consistency defect, the guaranteed lower bound
    oracle - B*eps, and the slack between guarantee and reality.
    """
    _, orc = optimal_cache_by_exchange(row, budget)
    cache = top_by_score(score, budget)
    achieved = sum(row[j] for j in cache)
    eps = consistency_defect(row, score)
    return {
        "oracle": orc,
        "achieved": achieved,
        "defect": eps,
        "correction": budget * eps,
        "guaranteed_floor": orc - budget * eps,
        "slack": achieved - (orc - budget * eps),
    }


if __name__ == "__main__":
    row: List[float] = [0.31, 0.02, 0.24, 0.11, 0.05, 0.19, 0.03, 0.05]
    score: List[float] = [0.05, 0.30, 0.10, 0.20, 0.02, 0.18, 0.09, 0.06]
    for budget in (1, 2, 3, 4):
        report = corrected_retention_bound(row, score, budget)
        print(f"B={budget}: " + "  ".join(f"{k}={v:.4f}" for k, v in report.items()))
    # brute-force cross-check of the O(n log n) defect against the O(n^2) form
    naive = max(
        [0.0]
        + [
            row[k] - row[j]
            for j in range(len(row))
            for k in range(len(row))
            if score[k] <= score[j]
        ]
    )
    assert abs(naive - consistency_defect(row, score)) < 1e-12
    print("defect cross-check OK")


"""
Algorithm B --- Causally Honest Streaming Cache Eviction with a Recency Reserve.

A single pass over the rows of an attention matrix, maintaining a cache of at
most B keys.  The invariant that makes the simulation *honest* is that the cache
serving row t is a function of rows strictly before t only: the accumulated
score is updated only AFTER the row has been served.  Violating that ordering is
the classic causal leak, and it produces retained fractions above 1, which is
physically impossible for a probability row --- a useful sanity gate.

The budget is split into a heavy-hitter half of size a and a recency reserve of
size b, with a + b = B.  The theory says both halves are load-bearing: with
b = 0 there is an instance on which the policy retains nothing, and likewise for
a = 0, while any split with a, b >= 1 survives both instances.

Complexity: with T rows and n keys, maintaining accumulated scores costs O(nT),
and selecting the top a scores per row costs O(n log n) per row, i.e. O(nT log n)
overall; a heap or quickselect reduces the per-row term to O(n + a log a).
"""

from __future__ import annotations

from typing import Dict, List, Sequence, Set

Matrix = Sequence[Sequence[float]]


def stream_eviction(
    w: Matrix,
    budget: int,
    recency_reserve: int,
    n: int | None = None,
) -> Dict[str, object]:
    """
    Simulate causally honest eviction over all rows of `w`.

    Parameters
    ----------
    w                : attention matrix; w[t][j] is the mass row t places on key j.
    budget           : total cache size B.
    recency_reserve  : b, the number of slots reserved for the most recent keys.
                       The heavy-hitter half receives a = B - b slots.
    n                : number of keys (defaults to the row width of w).

    Returns a dict with per-row retentions, the mean retention, the per-row
    oracle values and the mean oracle-to-policy gap.
    """
    if n is None:
        n = len(w[0])
    a = max(budget - recency_reserve, 0)
    b = min(recency_reserve, budget)

    acc: List[float] = [0.0] * n
    retentions: List[float] = []
    oracles: List[float] = []

    for t, row in enumerate(w):
        # --- build the cache from the PAST only ---------------------------
        visible = min(t, n)                       # keys a causal row may hold
        order = sorted(range(visible), key=lambda j: (-acc[j], j))
        cache: Set[int] = set(order[:a])
        cache |= set(range(max(visible - b, 0), visible))
        cache.add(t if t < n else n - 1)          # current key is always cached

        # --- serve row t ---------------------------------------------------
        retentions.append(sum(row[j] for j in cache if j < n))
        best = sorted(row[: min(t + 1, n)], reverse=True)
        oracles.append(sum(x for x in best[:budget]))

        # --- only NOW may the statistic see row t --------------------------
        for j in range(n):
            acc[j] += row[j]

    mean_ret = sum(retentions) / len(retentions)
    mean_orc = sum(oracles) / len(oracles)
    return {
        "retentions": retentions,
        "mean_retention": mean_ret,
        "oracles": oracles,
        "mean_oracle": mean_orc,
        "mean_gap": mean_orc - mean_ret,
        "sanity_band_ok": all(0.0 <= r <= 1.0 + 1e-9 for r in retentions),
        "budget": budget,
        "heavy_hitter_slots": a,
        "recency_slots": b,
    }


def synthetic_attention(n: int, decay: float = 0.85, sink: float = 0.25) -> Matrix:
    """
    A crude but realistic stand-in for trained causal attention: an
    attention-sink mass on key 0, a geometric recency profile, and row-wise
    normalisation so that every row is a probability distribution.
    """
    rows: List[List[float]] = []
    for t in range(n):
        raw = [0.0] * n
        for j in range(t + 1):
            raw[j] = decay ** (t - j)
        raw[0] += sink * (t + 1) ** 0.5
        z = sum(raw)
        rows.append([x / z for x in raw])
    return rows


if __name__ == "__main__":
    n = 96
    w = synthetic_attention(n)
    print(f"{'B':>5} {'b (recency)':>12} {'mean ret.':>11} {'mean oracle':>12} {'gap':>8}")
    for budget in (8, 16, 32):
        for b in (0, budget // 2, budget):
            out = stream_eviction(w, budget, b, n)
            assert out["sanity_band_ok"], "retention outside [0,1]: causal leak!"
            print(
                f"{budget:>5} {b:>12} {out['mean_retention']:>11.4f} "
                f"{out['mean_oracle']:>12.4f} {out['mean_gap']:>8.4f}"
            )


"""Assemble PACKAGE.json from the individual deliverables in the project."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Novelty/OracleOnlineEvictionGap.lean",
    "Catalog/Novelty/OracleOnlineEvictionSharp.lean",
    "Catalog/Novelty/OracleOnlineEvictionLayers.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {f} =====\n\n{read(ROOT / f)}" for f in LEAN_FILES
)

INTERACTIVE_LAYOUT = read(A / "interactive_layout.md")

package = {
    "title": "The Oracle Overstates the Deployable Win: An Information Barrier for Streaming Attention-Cache Eviction",
    "domain": "Novelty",
    "description": (
        "Retrospective top-k selection retains over 99% of a trained model's attention mass at a "
        "cache of 32-64 keys out of 1024, but we prove that no causally honest eviction policy can "
        "inherit those numbers: at every budget short of the full context there is a legitimate "
        "instance where the oracle retains all the mass and the policy retains none, and the exact "
        "price of the assumption that would close the gap is the budget times the score's "
        "consistency defect."
    ),
    "authors": ["Aristotle"],
    "date": "2026-09-02",
    "key_results": [
        "Oracle-to-policy separation: for every context length n, every cache budget 1 <= B < n, and every causally honest eviction policy, there is an attention matrix whose rows are genuine probability distributions on which the omniscient selector retains all of the served row's mass and the policy retains none, so the oracle-to-policy gap equals 1, the maximum arithmetically possible.",
        "Average-case and randomised form: over an explicit family of n instances the mean retention of any causal policy is at most the budget fraction B/n while the oracle equals 1 throughout, and the same bound holds in expectation for every finite mixture of causal policies, so randomisation provides no escape.",
        "Exchange lemma and the exact price of imperfect scores: a cache of the top B keys under any score is oracle-optimal when the score never misranks the served row, and loses at most B times the consistency defect when it misranks by at most that amount; an explicit instance attains the loss exactly, so the correction is sharp and scales with the cache size rather than the context length.",
        "Stationarity isolated: if the served attention row is an order-preserving affine image of the accumulated attention score, the heavy-hitter cache is exactly the optimal cache, and within an epsilon/2 neighbourhood of such an image it loses at most B epsilon; this is the hypothesis heavy-hitter eviction silently assumes.",
        "Hybrid policies are structurally forced, and neither granularity nor depth rescues deployment: pure accumulation and pure recency each retain nothing on an instance where the other retains everything, a budget split retains both exactly when both halves are nonzero, a block-granularity oracle still separates from every causal policy, and per-layer policy penalties accumulate to L times delta under optimal min-plus budget allocation across L layers.",
    ],
    "keywords": [
        "attention cache eviction",
        "heavy hitters",
        "oracle gap",
        "online algorithms",
        "exchange argument",
        "min-plus convolution",
        "information barrier",
        "KV cache",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "End-to-End Verification of the Oracle-Policy Separation and its Corrections",
            "description": (
                "A dependency-free numerical tour of every result in the paper. It brute-forces the "
                "oracle over all admissible caches and checks it against the greedy top-B rule "
                "predicted by the exchange lemma; exhibits a score that is order-consistent with the "
                "served row and verifies it attains the oracle exactly; computes the consistency "
                "defect of an inconsistent score and confirms the B*eps guarantee; reproduces the "
                "extremal instance where that guarantee holds with equality; enumerates the "
                "uniform-prefix / one-hot adversarial family and confirms that heavy hitters, "
                "recency and the hybrid each retain zero on some instance while averaging at most "
                "B/n; runs a Yao-style averaging over a probabilistic mixture of the three policies "
                "and finds an instance where the expected retention is still at most B/n; contrasts "
                "the stale and pinned diagnostics to show that neither pure heuristic dominates "
                "while a genuine split survives both; checks that a block-granularity oracle still "
                "beats every causal policy by a full unit; verifies numerically that a per-layer "
                "penalty accumulates to L*delta under optimal min-plus allocation over non-convex "
                "loss curves; and finally replays the recorded retention table, confirming the "
                "11.31-point gap at matched budget, the recency gain at every budget, and the "
                "refutation of the 0.95 deployability target."
            ),
            "code": read(ROOT / "demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Retrospective Optimal Cache Selection and the Consistency Defect",
            "description": (
                "Two coupled routines. The first solves the oracle's problem exactly: because the "
                "retention objective is linear in the chosen keys, the exchange lemma shows that "
                "keeping the B keys of largest attention weight dominates every admissible cache, "
                "so the optimum is found by a single sort in O(n log n) rather than by searching "
                "the C(n, B) admissible caches. The second computes the consistency defect "
                "eps = max_+ { w_t(k) - w_t(j) : s(k) <= s(j) } of the score actually used online. "
                "The naive form is O(n^2); the implementation sorts by ascending score and sweeps a "
                "running maximum over each tie group, giving O(n log n). The defect is the single "
                "scalar that converts a published oracle number into an honest deployment forecast, "
                "since the theory guarantees oracle <= retained + B*eps and exhibits an instance "
                "where that holds with equality."
            ),
            "pseudocode": (
                "ALGORITHM OptimalCacheByExchange(row, B)\n"
                "  1. order <- indices 0..n-1 sorted by decreasing row[j], ties by increasing j\n"
                "  2. H <- first min(B, n) entries of order\n"
                "  3. return (H, sum of row[j] for j in H)\n"
                "  -- optimality: for any admissible S, |S \\ H| <= |H \\ S| and every key of\n"
                "  --   S \\ H is worth no more than every key of H \\ S, so swapping keys one at a\n"
                "  --   time never decreases retention.  Cost O(n log n).\n"
                "\n"
                "ALGORITHM ConsistencyDefect(row, score)\n"
                "  1. order <- indices sorted by increasing score\n"
                "  2. best <- 0 ; runmax <- -infinity ; i <- 0\n"
                "  3. while i < n do\n"
                "  4.     g <- the maximal tie group order[i..], all of equal score\n"
                "  5.     for each key k in g: runmax <- max(runmax, row[k])\n"
                "  6.     for each key j in g: best <- max(best, runmax - row[j])\n"
                "  7.     i <- i + |g|\n"
                "  8. return max(best, 0)\n"
                "  -- correctness: after step 5 the value runmax equals the maximum of row over all\n"
                "  --   keys of score <= score(j), which is exactly the set the defect quantifies\n"
                "  --   over.  Cost O(n log n).\n"
                "\n"
                "ALGORITHM CorrectedRetentionBound(row, score, B)\n"
                "  1. (H_star, oracle) <- OptimalCacheByExchange(row, B)\n"
                "  2. H <- top B keys by score, ties by index\n"
                "  3. achieved <- sum of row[j] for j in H\n"
                "  4. eps <- ConsistencyDefect(row, score)\n"
                "  5. return oracle, achieved, eps, B*eps, oracle - B*eps, achieved - (oracle - B*eps)"
            ),
            "code": read(A / "alg_oracle_and_defect.py"),
        },
        {
            "name": "Causally Honest Streaming Cache Eviction with a Recency Reserve",
            "description": (
                "A single streaming pass that simulates deployment faithfully. The invariant that "
                "makes it honest is the update ordering: the cache serving row t is built from the "
                "accumulated score over rows strictly before t, and the score absorbs row t only "
                "after that row has been served. Violating the ordering is the classic causal leak "
                "and produces retained fractions above 1, which is impossible for a probability row "
                "and therefore functions as a sanity gate; the implementation asserts the retention "
                "band explicitly. The budget is split into a heavy-hitter half of size a and a "
                "recency reserve of size b, and the current key is always cached. Complexity is "
                "O(nT) for score maintenance plus O(n log n) per row for selection, i.e. "
                "O(nT log n) overall, reducible to O(T(n + a log a)) with a heap. Running it on a "
                "synthetic attention profile with an attention sink and geometric recency decay "
                "reproduces the qualitative ordering of the measured table: the oracle above the "
                "hybrid above pure accumulation, at every budget."
            ),
            "pseudocode": (
                "ALGORITHM StreamEviction(w, B, b)\n"
                "  1. a <- B - b ; acc[j] <- 0 for all keys j\n"
                "  2. for t = 0, 1, ..., T do\n"
                "  3.     visible <- min(t, n)                    -- keys a causal row may hold\n"
                "  4.     order <- visible keys sorted by decreasing acc, ties by increasing index\n"
                "  5.     cache <- first a entries of order\n"
                "  6.     cache <- cache union { visible-b, ..., visible-1 }   -- recency reserve\n"
                "  7.     cache <- cache union { current key }                 -- always resident\n"
                "  8.     retention[t] <- sum of w[t][j] over j in cache\n"
                "  9.     oracle[t]    <- sum of the B largest entries of w[t] over visible keys\n"
                " 10.     ASSERT 0 <= retention[t] <= 1          -- causal-leak sanity gate\n"
                " 11.     for all j: acc[j] <- acc[j] + w[t][j]  -- ONLY NOW may the score see row t\n"
                " 12. return mean(retention), mean(oracle), mean(oracle) - mean(retention)"
            ),
            "code": read(A / "alg_streaming_eviction.py"),
        },
        {
            "name": "Min-Plus (Tropical) Allocation of a Global Cache Budget Across Layers",
            "description": (
                "Optimal distribution of a global cache budget over the attention layers of a model "
                "is the iterated min-plus convolution of the per-layer loss curves, the same "
                "tropical operation that governs shortest paths and scheduling: the two-layer value "
                "is min over a of f(a) + g(B - a), and the L-layer value is the minimum of the sum "
                "of per-layer losses over all allocations summing to B. Dynamic programming "
                "evaluates it in O(L*B^2) time and O(L*B) space, with argmin bookkeeping recovering "
                "the optimal split. The theorem attached to the operator is penalty passing: if "
                "every layer's deployable loss exceeds its oracle loss pointwise by at least delta, "
                "the optimally allocated L-layer deployable loss exceeds the optimally allocated "
                "L-layer oracle loss by at least L*delta. No convexity or monotonicity of the "
                "curves is assumed, so the statement covers the irregular profiles real models "
                "exhibit; the practical consequence is that reallocating budget across depth cannot "
                "recover a per-layer policy penalty, and a deployment table for an L-layer model "
                "must be corrected L times."
            ),
            "pseudocode": (
                "ALGORITHM Allocate(curves f_1..f_L, budget B)\n"
                "  1. best[L-1][r] <- f_L(r) for r = 0..B ; take[L-1][r] <- r\n"
                "  2. for i = L-2 down to 0 do\n"
                "  3.     for r = 0..B do\n"
                "  4.         best[i][r] <- min over a in 0..r of ( f_{i+1}(a) + best[i+1][r-a] )\n"
                "  5.         take[i][r] <- an argmin a of step 4\n"
                "  6. remaining <- B ; split <- empty list\n"
                "  7. for i = 0..L-1 do\n"
                "  8.     a <- take[i][remaining] ; append a to split ; remaining <- remaining - a\n"
                "  9. return (best[0][B], split)\n"
                " -- cost O(L*B^2) time, O(L*B) space\n"
                "\n"
                "THEOREM (penalty passing)\n"
                "  if f'_i(a) >= f_i(a) + delta for every layer i and budget a, then\n"
                "  Allocate(f'_1..f'_L, B) >= Allocate(f_1..f_L, B) + L*delta\n"
                " -- proof: let a attain the primed minimum; bound the unprimed value by the same\n"
                " --   split, then apply the hypothesis at layer 1 and induction on the remaining\n"
                " --   L-1 layers at budget B-a."
            ),
            "code": read(A / "alg_minplus_allocation.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Oracle Gap: Measured Table Beside the Proved Worst Case",
            "description": (
                "A two-panel figure. The left panel plots the recorded retention table — oracle, "
                "pure accumulated heavy hitters, and the heavy-hitter/recency hybrid — against cache "
                "budget on a log-2 axis, annotating the 11.31-point separation at the matched budget "
                "of 64 keys and drawing the pre-registered 0.95 deployability target that every "
                "deployable arm failed to reach. The right panel plots the proved worst case on the "
                "uniform-prefix / one-hot family: the oracle sits at 1 for every budget, any causal "
                "policy averages at most B/n, and its worst instance sits at 0, with the separation "
                "region shaded. Together the panels make the paper's thesis visible in one image: "
                "the measured gap is the mild shadow of a separation that is, in the worst case, "
                "total."
            ),
            "code": read(A / "viz_oracle_vs_policy.py"),
        },
        {
            "name": "Diagnostic Families: Why the Hybrid Split Is Forced",
            "description": (
                "Three attention matrices rendered as heatmaps — the adversarial uniform-prefix / "
                "one-hot family, the stale family whose prefix hammers the oldest key while the "
                "served row needs the newest, and the pinned family where every row including the "
                "served one attends the oldest key — with the cache chosen by pure accumulation, "
                "pure recency, and a genuine split marked as coloured bands beneath each matrix and "
                "annotated with the mass each retains. The figure shows at a glance that each pure "
                "heuristic retains nothing on the family where the other retains everything, and "
                "that only a split with both halves nonzero survives both diagnostics, which is the "
                "structural explanation of the hybrid's uniform empirical advantage."
            ),
            "code": read(A / "viz_diagnostic_families.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Eviction Sandbox: Hindsight Versus Deployable Caches",
            "description": (
                "A live laboratory for the central separation. Pick an instance family — the "
                "adversarial uniform-prefix / one-hot construction, the stale diagnostic, the pinned "
                "diagnostic, or a trained-like profile with an attention sink and recency decay — "
                "then set the context length, the target key, and the split of the budget between "
                "heavy-hitter slots and recency slots. The widget draws the attention matrix as a "
                "heatmap, outlines the mass the served row actually needs, and shows the oracle "
                "cache and both halves of the policy cache as bands beneath it, with live retention "
                "bars and a running verdict. A single button runs the impossibility argument in "
                "front of the reader: it finds a target key the current policy's cache omits, and "
                "the scoreboard jumps to an oracle value of 1 against a policy value of 0. Setting "
                "the recency reserve to zero on the stale family, or the heavy-hitter half to zero "
                "on the pinned family, reproduces the two total failures that make the hybrid split "
                "necessary. Expandable panels give the counting argument behind the full-unit gap "
                "and the B/n average bound."
            ),
            "html": read(A / "widget_eviction_sandbox.html"),
        },
        {
            "title": "The Consistency Defect Ledger: Pricing an Imperfect Score",
            "description": (
                "The positive half of the theory, made tangible. A true attention row and an online "
                "score are drawn as paired bar charts, with the oracle cache filled in navy and the "
                "score-ranked cache outlined in red, so that every inversion between the two "
                "rankings is visible. A slider corrupts the score continuously from perfectly "
                "order-consistent to badly mismatched, and an accounting table updates live with the "
                "oracle retention, the retention the score-ranked cache actually achieves, the "
                "consistency defect, the correction B times that defect, and the slack in the "
                "guarantee. Selecting the extremal instance — where the top-scoring keys carry no "
                "mass and every other key carries exactly the defect — drives the slack to zero, "
                "showing the reader that the correction is not a loose bound but the exact "
                "conversion rate from score quality to retained mass. Expandable panels give the "
                "exchange argument behind the bound and the construction that attains it."
            ),
            "html": read(A / "widget_consistency_defect.html"),
        },
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": read(A / "future_directions.md"),
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "oracle_and_defect": read(A / "alg_oracle_and_defect.py"),
        "streaming_eviction": read(A / "alg_streaming_eviction.py"),
        "minplus_allocation": read(A / "alg_minplus_allocation.py"),
        "viz_oracle_vs_policy": read(A / "viz_oracle_vs_policy.py"),
        "viz_diagnostic_families": read(A / "viz_diagnostic_families.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""
Visualization 2 --- Why Hybrids Are Forced: the Stale and Pinned Diagnostics.

Three attention matrices are drawn as heatmaps, with the cache selected by each
policy marked underneath the served (final) row:

  * the ADVERSARIAL family: a uniform prefix followed by a one-hot served row.
    All n instances share their prefix, so a causally honest policy must commit
    to the same cache on all of them; since the cache holds fewer than n keys,
    some instance is missed entirely.

  * the STALE family: the prefix hammers key 0, but the served row attends the
    current key n-1.  Accumulated score is maximally misleading; pure heavy
    hitters retain 0, pure recency retains 1.

  * the PINNED family: every row, including the served one, attends key 0.
    Pure recency retains 0, pure heavy hitters retain 1.

A budget split with a heavy-hitter half AND a recency half retains everything on
both diagnostics, which is exactly why the hybrid arm beats both pure arms at
every budget in the measured table.

Run:  python3 viz_diagnostic_families.py   (writes diagnostic_families.png)
"""

from __future__ import annotations

from typing import Callable, Dict, List, Sequence, Set

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

Matrix = List[List[float]]


def adv(n: int, T: int, j0: int) -> Matrix:
    uni = [1.0 / n] * n
    hot = [1.0 if j == j0 else 0.0 for j in range(n)]
    return [list(uni) for _ in range(T)] + [hot]


def stale(n: int, T: int) -> Matrix:
    old = [1.0 if j == 0 else 0.0 for j in range(n)]
    new = [1.0 if j == n - 1 else 0.0 for j in range(n)]
    return [list(old) for _ in range(T)] + [new]


def pinned(n: int, T: int) -> Matrix:
    row = [1.0 if j == 0 else 0.0 for j in range(n)]
    return [list(row) for _ in range(T + 1)]


def accumulated(w: Matrix, t: int, n: int) -> List[float]:
    return [sum(w[r][j] for r in range(t)) for j in range(n)]


def split_cache(w: Matrix, t: int, n: int, a: int, b: int) -> Set[int]:
    score = accumulated(w, t, n)
    order = sorted(range(n), key=lambda j: (-score[j], j))
    return set(order[:a]) | set(range(max(n - b, 0), n))


def main() -> None:
    n, T, budget = 12, 5, 4
    families: Dict[str, Matrix] = {
        f"adversarial  (one-hot at $j_0=6$)": adv(n, T, 6),
        "stale  (prefix on key 0, row needs key $n-1$)": stale(n, T),
        "pinned  (everything on key 0)": pinned(n, T),
    }
    policies: Dict[str, Callable[[Matrix], Set[int]]] = {
        "pure accumulation": lambda w: split_cache(w, T, n, budget, 0),
        "pure recency": lambda w: split_cache(w, T, n, 0, budget),
        "split (2 + 2)": lambda w: split_cache(w, T, n, budget // 2, budget - budget // 2),
    }
    colors = {"pure accumulation": "#c0392b",
              "pure recency": "#2874a6",
              "split (2 + 2)": "#1e8449"}

    fig, axes = plt.subplots(1, 3, figsize=(15.5, 5.4))
    for ax, (title, w) in zip(axes, families.items()):
        ax.imshow(np.array(w), cmap="magma", aspect="auto",
                  vmin=0.0, vmax=1.0, interpolation="nearest")
        ax.set_title(title, fontsize=11, fontweight="bold")
        ax.set_xlabel("key $j$")
        ax.set_ylabel("query row $t$")
        ax.set_xticks(range(n))
        ax.set_yticks(range(T + 1))
        ax.axhline(T - 0.5, color="white", lw=1.4, ls="--")
        for k, (pname, P) in enumerate(policies.items()):
            cache = P(w)
            retained = sum(w[T][j] for j in cache)
            y = T + 0.75 + 0.42 * k
            for j in cache:
                ax.plot(j, y, marker="s", ms=7, color=colors[pname],
                        clip_on=False)
            ax.text(n - 0.3, y, f"  {pname}: retains {retained:.0f}",
                    va="center", fontsize=9, color=colors[pname], clip_on=False)
        ax.set_ylim(T + 2.1, -0.5)

    fig.suptitle(
        "Each pure heuristic fails totally where the other succeeds totally; "
        "only a genuine split survives both",
        fontsize=13, fontweight="bold",
    )
    fig.tight_layout(rect=(0, 0, 1, 0.93))
    fig.savefig("diagnostic_families.png", dpi=170)
    print("wrote diagnostic_families.png")


if __name__ == "__main__":
    main()


"""
Visualization 1 --- The Oracle Gap: Measured Table and Worst-Case Separation.

Produces a two-panel figure.

Left panel: the recorded retention table.  Oracle, pure accumulated heavy
hitters, and the heavy-hitter/recency hybrid, plotted against cache budget, with
the 11.31-point gap at the matched budget B = 64 annotated, and the refuted 0.95
deployability target drawn as a horizontal line.

Right panel: the worst case.  On the uniform-prefix / one-hot family with n keys
and budget B, the omniscient selector retains 1 on every instance while any
causally honest policy averages at most B/n.  The shaded region between the two
curves is the proved separation, which is total (a full unit) on the worst
instance at every budget short of the full context.

Run:  python3 viz_oracle_vs_policy.py     (writes oracle_vs_policy.png)
"""

from __future__ import annotations

from typing import Dict, List, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


MEASURED: Dict[str, List[Tuple[int, float]]] = {
    "oracle (per-row top-k)": [(32, 0.9913), (64, 0.9953)],
    "heavy hitters (accumulated)": [(32, 0.8633), (64, 0.8822), (128, 0.9189)],
    "hybrid (heavy hitters + recency)": [(32, 0.9205), (64, 0.9384), (128, 0.9605)],
}
STYLE = {
    "oracle (per-row top-k)": dict(color="#1b3a6b", marker="o", lw=2.4),
    "heavy hitters (accumulated)": dict(color="#c0392b", marker="s", lw=2.0),
    "hybrid (heavy hitters + recency)": dict(color="#1e8449", marker="^", lw=2.0),
}


def main() -> None:
    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(13.5, 5.2))

    # ---------------- left: the measured table -------------------------
    for name, pts in MEASURED.items():
        xs = [b for b, _ in pts]
        ys = [v for _, v in pts]
        ax0.plot(xs, ys, label=name, **STYLE[name])
    ax0.axhline(0.95, color="#7f8c8d", ls="--", lw=1.2)
    ax0.text(33, 0.953, "pre-registered 0.95 target (refuted)",
             color="#7f8c8d", fontsize=9)
    ax0.annotate(
        "", xy=(64, 0.9953), xytext=(64, 0.8822),
        arrowprops=dict(arrowstyle="<->", color="#8e44ad", lw=2.0),
    )
    ax0.text(66, 0.935, "11.31 points\nat matched B = 64",
             color="#8e44ad", fontsize=10, fontweight="bold")
    ax0.set_xscale("log", base=2)
    ax0.set_xticks([32, 64, 128])
    ax0.set_xticklabels(["32", "64", "128"])
    ax0.set_xlabel("cache budget $B$ (keys, context 1024)")
    ax0.set_ylabel("retained attention mass")
    ax0.set_title("Measured: hindsight vs. deployable", fontweight="bold")
    ax0.set_ylim(0.84, 1.005)
    ax0.grid(alpha=0.3)
    ax0.legend(loc="lower right", fontsize=9)

    # ---------------- right: the worst case ----------------------------
    n = 64
    budgets = list(range(1, n))
    oracle = [1.0 for _ in budgets]
    policy_avg = [b / n for b in budgets]
    ax1.plot(budgets, oracle, color="#1b3a6b", lw=2.4,
             label="oracle (every instance)")
    ax1.plot(budgets, policy_avg, color="#c0392b", lw=2.4,
             label=r"any causal policy, average $\leq B/n$")
    ax1.plot(budgets, [0.0] * len(budgets), color="#c0392b", lw=1.6, ls=":",
             label="any causal policy, worst instance $= 0$")
    ax1.fill_between(budgets, policy_avg, oracle, color="#c0392b", alpha=0.12)
    ax1.text(n * 0.30, 0.62, "proved separation\n(total on the worst instance)",
             fontsize=10, color="#7b241c")
    ax1.set_xlabel(f"cache budget $B$ (worst-case family, $n = {n}$)")
    ax1.set_ylabel("retained attention mass")
    ax1.set_title("Proved: the barrier is informational", fontweight="bold")
    ax1.set_ylim(-0.04, 1.06)
    ax1.grid(alpha=0.3)
    ax1.legend(loc="center right", fontsize=9)

    fig.suptitle(
        "Trained attention is prunable in retrospect, not predictable in advance",
        fontsize=13, fontweight="bold",
    )
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig("oracle_vs_policy.png", dpi=170)
    print("wrote oracle_vs_policy.png")


if __name__ == "__main__":
    main()


"""
Numerical demonstrations for
"The Oracle Overstates the Deployable Win: An Information Barrier for
 Streaming Attention-Cache Eviction".

Everything is self-contained: pure Python standard library, type hints, and no
external dependencies.  Run with

    python3 demo.py

The script demonstrates, numerically:

  1. Retention, admissible caches, and the omniscient oracle.
  2. The exchange lemma: top-B by the TRUE row is optimal (checked by brute
     force against every admissible cache).
  3. Order consistency: a score consistent with the served row makes the
     score-ranked cache optimal; epsilon-consistency costs at most B*eps.
  4. Sharpness: an instance where the loss is EXACTLY B*eps.
  5. The impossibility: on the uniform-prefix / one-hot family, any causally
     honest policy retains 0 on some instance where the oracle retains 1, and
     its average retention over the family is at most B/n.
  6. Randomisation does not help: a mixture of policies still averages <= B/n.
  7. Stale vs pinned diagnostics: neither pure accumulation nor pure recency
     dominates; a genuine budget split survives both.
  8. Block granularity does not rescue deployment.
  9. Min-plus (tropical) allocation across layers: a per-layer penalty delta
     accumulates to L*delta under optimal global budget allocation.
 10. The recorded run: P1 confirmed, P2 confirmed, P3 refuted.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, Dict, FrozenSet, Iterable, List, Sequence, Tuple

Row = Sequence[float]          # one attention distribution over n keys
Matrix = Sequence[Row]         # rows 0..T (row T is the served row)
Cache = FrozenSet[int]
Policy = Callable[[Matrix, int], Cache]   # (matrix, row index) -> cache


# --------------------------------------------------------------------------
# 1. Core objects: retention, admissible caches, the oracle
# --------------------------------------------------------------------------

def kept(w: Matrix, t: int, cache: Iterable[int]) -> float:
    """Attention mass that row t places on the cached key set."""
    return sum(w[t][j] for j in cache)


def admissible_caches(n: int, budget: int) -> List[Cache]:
    """All subsets of {0,...,n-1} of size at most `budget`."""
    out: List[Cache] = []
    for size in range(min(budget, n) + 1):
        for combo in combinations(range(n), size):
            out.append(frozenset(combo))
    return out


def oracle(w: Matrix, t: int, n: int, budget: int) -> float:
    """Best retention achievable at this budget, chosen AFTER reading row t."""
    return max(kept(w, t, S) for S in admissible_caches(n, budget))


def oracle_fast(w: Matrix, t: int, n: int, budget: int) -> float:
    """Same value via the exchange lemma: keep the `budget` largest weights."""
    weights = sorted((w[t][j] for j in range(n)), reverse=True)
    return sum(max(x, 0.0) for x in weights[:budget])


# --------------------------------------------------------------------------
# 2. Score-ranked caches (ties broken by index, exactly as in the theory)
# --------------------------------------------------------------------------

def top_by_score(n: int, budget: int, score: Sequence[float]) -> Cache:
    """The `budget` best-scoring keys; ties broken by smaller index."""
    order = sorted(range(n), key=lambda j: (-score[j], j))
    return frozenset(order[:budget])


def consistency_defect(w: Matrix, t: int, n: int, score: Sequence[float]) -> float:
    """
    The consistency defect eps = max_+ { w_t(k) - w_t(j) : score(k) <= score(j) }.

    This is the single scalar that converts an oracle table into an honest
    deployment forecast: the score-ranked cache loses at most B*eps.
    """
    worst = 0.0
    for j in range(n):
        for k in range(n):
            if score[k] <= score[j]:
                worst = max(worst, w[t][k] - w[t][j])
    return worst


# --------------------------------------------------------------------------
# 3. The three deployable policies
# --------------------------------------------------------------------------

def accumulated(w: Matrix, t: int, n: int) -> List[float]:
    """H2O statistic: attention accumulated over rows strictly before t."""
    return [sum(w[r][j] for r in range(t)) for j in range(n)]


def heavy_hitter_policy(n: int, budget: int) -> Policy:
    def P(w: Matrix, t: int) -> Cache:
        return top_by_score(n, budget, accumulated(w, t, n))
    return P


def recency_set(n: int, m: int) -> Cache:
    return frozenset(range(max(n - m, 0), n))


def recency_policy(n: int, budget: int) -> Policy:
    def P(w: Matrix, t: int) -> Cache:
        return recency_set(n, budget)
    return P


def split_policy(n: int, a: int, b: int) -> Policy:
    """`a` keys by accumulated score, `b` keys reserved for recency."""
    def P(w: Matrix, t: int) -> Cache:
        return top_by_score(n, a, accumulated(w, t, n)) | recency_set(n, b)
    return P


def hybrid_policy(n: int, budget: int) -> Policy:
    return split_policy(n, budget // 2, budget - budget // 2)


# --------------------------------------------------------------------------
# 4. Instance families
# --------------------------------------------------------------------------

def adv(n: int, T: int, j0: int) -> Matrix:
    """T uniform rows, then a one-hot served row at key j0.  Every row sums to 1."""
    uniform = [1.0 / n] * n
    onehot = [1.0 if j == j0 else 0.0 for j in range(n)]
    return [list(uniform) for _ in range(T)] + [onehot]


def stale(n: int, T: int) -> Matrix:
    """Prefix hammers key 0; the served row attends the CURRENT key n-1."""
    old = [1.0 if j == 0 else 0.0 for j in range(n)]
    new = [1.0 if j == n - 1 else 0.0 for j in range(n)]
    return [list(old) for _ in range(T)] + [new]


def pinned(n: int, T: int) -> Matrix:
    """Every row, including the served one, attends the same old key 0."""
    row = [1.0 if j == 0 else 0.0 for j in range(n)]
    return [list(row) for _ in range(T + 1)]


def sharp_instance(n: int, budget: int, eps: float) -> Matrix:
    """Top-B keys by the score j -> -j carry 0; every other key carries eps."""
    row = [0.0 if j < budget else eps for j in range(n)]
    return [list(row)]


def block_keys(n: int, block_size: int, b: int) -> Cache:
    return frozenset(j for j in range(n) if j // block_size == b)


# --------------------------------------------------------------------------
# 5. Min-plus (tropical) allocation across layers
# --------------------------------------------------------------------------

def min_plus(f: Sequence[float], g: Sequence[float], budget: int) -> float:
    """Optimally allocated two-layer loss: min over a of f(a) + g(B-a)."""
    return min(f[a] + g[budget - a] for a in range(budget + 1))


def alloc_loss(curves: Sequence[Sequence[float]], budget: int) -> float:
    """Iterated min-plus convolution: optimal allocation over a list of layers."""
    if not curves:
        return 0.0
    if len(curves) == 1:
        return curves[0][budget]
    return min(
        curves[0][a] + alloc_loss(curves[1:], budget - a)
        for a in range(budget + 1)
    )


# --------------------------------------------------------------------------
# 6. The recorded run
# --------------------------------------------------------------------------

MEASURED: Dict[Tuple[str, int], float] = {
    ("oracle", 32): 0.9913, ("oracle", 64): 0.9953,
    ("hh", 32): 0.8633, ("hh", 64): 0.8822, ("hh", 128): 0.9189,
    ("hyb", 32): 0.9205, ("hyb", 64): 0.9384, ("hyb", 128): 0.9605,
}


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_oracle_and_exchange() -> None:
    banner("1. The oracle, and the exchange lemma (brute force vs greedy)")
    n, budget = 8, 3
    row = [0.31, 0.02, 0.24, 0.11, 0.05, 0.19, 0.03, 0.05]
    w: Matrix = [row]
    brute = oracle(w, 0, n, budget)
    greedy = oracle_fast(w, 0, n, budget)
    best = top_by_score(n, budget, row)
    print(f"row            = {row}")
    print(f"budget B       = {budget}")
    print(f"oracle (brute) = {brute:.6f}   over {len(admissible_caches(n, budget))} caches")
    print(f"oracle (greedy)= {greedy:.6f}   via top-B by the TRUE row")
    print(f"optimal cache  = {sorted(best)}  -> kept = {kept(w, 0, best):.6f}")
    assert abs(brute - greedy) < 1e-12
    print("OK: retrospective pruning is exactly the greedy top-B.")


def demo_consistency_price() -> None:
    banner("2. Order consistency, and the B*eps price of its failure")
    n, budget = 8, 3
    row = [0.31, 0.02, 0.24, 0.11, 0.05, 0.19, 0.03, 0.05]
    w: Matrix = [row]

    # A consistent score: any strictly order-preserving transform of the row.
    consistent_score = [x ** 3 for x in row]
    H = top_by_score(n, budget, consistent_score)
    print(f"consistent score  -> cache {sorted(H)}, kept = {kept(w, 0, H):.6f}")
    print(f"oracle                                        {oracle_fast(w, 0, n, budget):.6f}")
    assert abs(kept(w, 0, H) - oracle_fast(w, 0, n, budget)) < 1e-12
    print("OK: a consistent score attains the oracle exactly.")

    # An inconsistent score: rank by index instead.
    bad_score = [-float(j) for j in range(n)]
    Hbad = top_by_score(n, budget, bad_score)
    eps = consistency_defect(w, 0, n, bad_score)
    lhs = oracle_fast(w, 0, n, budget)
    rhs = kept(w, 0, Hbad) + budget * eps
    print(f"\ninconsistent score -> cache {sorted(Hbad)}, kept = {kept(w, 0, Hbad):.6f}")
    print(f"consistency defect eps = {eps:.6f}")
    print(f"oracle {lhs:.6f}  <=  kept + B*eps = {rhs:.6f}   [{'holds' if lhs <= rhs + 1e-12 else 'FAILS'}]")
    assert lhs <= rhs + 1e-12


def demo_sharpness() -> None:
    banner("3. Sharpness: the loss is EXACTLY B*eps on the extremal instance")
    eps = 0.07
    print(f"{'n':>4} {'B':>4} {'oracle':>10} {'kept(top-B)':>12} {'B*eps':>10}")
    for budget in (1, 2, 3, 4):
        n = 2 * budget + 1
        w = sharp_instance(n, budget, eps)
        H = top_by_score(n, budget, [-float(j) for j in range(n)])
        orc = oracle_fast(w, 0, n, budget)
        k = kept(w, 0, H)
        print(f"{n:>4} {budget:>4} {orc:>10.6f} {k:>12.6f} {budget * eps:>10.6f}")
        assert abs(orc - (k + budget * eps)) < 1e-12
    print("OK: the B*eps bound is attained, so no sharper correction exists.")


def demo_impossibility() -> None:
    banner("4. The impossibility: every causal policy retains 0 somewhere")
    n, budget, T = 12, 4, 6
    policies: List[Tuple[str, Policy]] = [
        ("heavy hitters", heavy_hitter_policy(n, budget)),
        ("recency", recency_policy(n, budget)),
        ("hybrid", hybrid_policy(n, budget)),
    ]
    print(f"n = {n}, B = {budget}, T = {T}   (uniform prefix, one-hot served row)")
    print(f"{'policy':>16} {'#instances kept=0':>20} {'mean retention':>16} {'B/n':>8}")
    for name, P in policies:
        zeros = 0
        total = 0.0
        for j0 in range(n):
            w = adv(n, T, j0)
            r = kept(w, T, P(w, T))
            total += r
            zeros += (r == 0.0)
        mean = total / n
        print(f"{name:>16} {zeros:>20} {mean:>16.4f} {budget / n:>8.4f}")
        assert zeros >= 1, "impossibility theorem violated"
        assert mean <= budget / n + 1e-12, "average bound violated"
    orc = oracle_fast(adv(n, T, 0), T, n, budget)
    print(f"\noracle retention on EVERY instance of the family: {orc:.4f}")
    print("OK: gap = 1 on some instance; mean retention <= B/n for every policy.")


def demo_randomisation() -> None:
    banner("5. Randomisation does not help (Yao-style averaging)")
    n, budget, T = 12, 4, 6
    mixture: List[Tuple[float, str, Policy]] = [
        (0.4, "heavy hitters", heavy_hitter_policy(n, budget)),
        (0.35, "recency", recency_policy(n, budget)),
        (0.25, "hybrid", hybrid_policy(n, budget)),
    ]
    assert abs(sum(q for q, _, _ in mixture) - 1.0) < 1e-12
    worst_j0, worst_val = -1, float("inf")
    for j0 in range(n):
        w = adv(n, T, j0)
        val = sum(q * kept(w, T, P(w, T)) for q, _, P in mixture)
        if val < worst_val:
            worst_j0, worst_val = j0, val
    print(f"mixture weights: {[(name, q) for q, name, _ in mixture]}")
    print(f"worst instance j0 = {worst_j0}: expected retention = {worst_val:.4f}")
    print(f"budget fraction  B/n = {budget / n:.4f}   oracle = 1.0000")
    assert worst_val <= budget / n + 1e-12
    print("OK: the barrier is informational, not an artefact of determinism.")


def demo_diagnostics() -> None:
    banner("6. Stale vs pinned: neither pure heuristic dominates; splits survive")
    n, budget, T = 10, 4, 5
    w_stale, w_pin = stale(n, T), pinned(n, T)
    rows = [
        ("pure accumulation", split_policy(n, budget, 0)),
        ("pure recency", split_policy(n, 0, budget)),
        ("genuine split (2,2)", split_policy(n, budget // 2, budget - budget // 2)),
    ]
    print(f"n = {n}, B = {budget}, T = {T}")
    print(f"{'policy':>22} {'stale':>10} {'pinned':>10}")
    for name, P in rows:
        rs = kept(w_stale, T, P(w_stale, T))
        rp = kept(w_pin, T, P(w_pin, T))
        print(f"{name:>22} {rs:>10.4f} {rp:>10.4f}")
    a_only = split_policy(n, budget, 0)
    b_only = split_policy(n, 0, budget)
    both = split_policy(n, budget // 2, budget - budget // 2)
    assert kept(w_stale, T, a_only(w_stale, T)) == 0.0
    assert kept(w_pin, T, b_only(w_pin, T)) == 0.0
    assert kept(w_stale, T, both(w_stale, T)) == 1.0
    assert kept(w_pin, T, both(w_pin, T)) == 1.0
    print("OK: each pure arm fails TOTALLY where the other succeeds totally;")
    print("    only a split with both halves nonzero passes both diagnostics.")


def demo_granularity() -> None:
    banner("7. Block granularity does not rescue deployment")
    n, budget, T, block = 12, 4, 6, 4
    P = hybrid_policy(n, budget)
    misses = []
    for j0 in range(n):
        w = adv(n, T, j0)
        pol = kept(w, T, P(w, T))
        blk = kept(w, T, block_keys(n, block, j0 // block))
        if pol == 0.0:
            misses.append((j0, blk - pol))
    print(f"n = {n}, B = {budget}, block width = {block}")
    print(f"instances where a block-granularity oracle beats the policy by a full unit:")
    print(f"  {[j0 for j0, gap in misses]}")
    assert misses and all(abs(gap - 1.0) < 1e-12 for _, gap in misses)
    print("OK: coarsening changes the oracle's MENU, not the policy's INFORMATION.")


def demo_layers() -> None:
    banner("8. Min-plus allocation across layers: the penalty accumulates")
    budget = 8
    delta = 0.03
    # Deliberately non-convex oracle loss curves.
    oracle_curves = [
        [1.00, 0.72, 0.61, 0.44, 0.40, 0.39, 0.21, 0.20, 0.19],
        [1.00, 0.90, 0.55, 0.52, 0.51, 0.30, 0.29, 0.15, 0.10],
        [1.00, 0.65, 0.64, 0.50, 0.33, 0.32, 0.31, 0.22, 0.12],
    ]
    policy_curves = [[x + delta for x in curve] for curve in oracle_curves]
    print(f"total budget = {budget}, per-layer penalty delta = {delta}")
    print(f"{'L':>3} {'oracle alloc':>14} {'policy alloc':>14} {'difference':>12} {'L*delta':>10}")
    for L in range(1, len(oracle_curves) + 1):
        a = alloc_loss(oracle_curves[:L], budget)
        b = alloc_loss(policy_curves[:L], budget)
        print(f"{L:>3} {a:>14.4f} {b:>14.4f} {b - a:>12.4f} {L * delta:>10.4f}")
        assert b >= a + L * delta - 1e-12
    two = min_plus(oracle_curves[0], oracle_curves[1], budget)
    assert abs(two - alloc_loss(oracle_curves[:2], budget)) < 1e-12
    print("OK: optimal reallocation cannot recover a per-layer policy penalty;")
    print("    it accumulates linearly in depth.")


def demo_recorded_run() -> None:
    banner("9. The recorded run: P1 confirmed, P2 confirmed, P3 refuted")
    print(f"{'budget':>8} {'oracle':>10} {'heavy hit.':>12} {'hybrid':>10} {'gap (O-HH)':>12}")
    for b in (32, 64, 128):
        o = MEASURED.get(("oracle", b))
        h = MEASURED[("hh", b)]
        y = MEASURED[("hyb", b)]
        o_s = f"{o:.4f}" if o is not None else "     -"
        gap = f"{o - h:.4f}" if o is not None else "     -"
        print(f"{b:>8} {o_s:>10} {h:>12.4f} {y:>10.4f} {gap:>12}")

    gap64 = MEASURED[("oracle", 64)] - MEASURED[("hh", 64)]
    print(f"\nP1  oracle-to-policy gap at matched B=64 : {gap64:.4f}  (> 0.02 floor)  CONFIRMED")
    for b in (32, 64, 128):
        d = MEASURED[("hyb", b)] - MEASURED[("hh", b)]
        assert d > 0
        print(f"P2  recency gain at B={b:<4}                 : {d:+.4f}                   CONFIRMED")
    print(f"P3  best deployable at B=64              : {MEASURED[('hyb', 64)]:.4f}  (< 0.95)        REFUTED")
    print(f"    even a 12.5%-of-context cache        : {MEASURED[('hyb', 128)]:.4f}  (< 0.97)")
    assert gap64 > 0.02
    assert MEASURED[("hyb", 64)] < 0.95
    for arm in ("hh", "hyb"):
        assert MEASURED[(arm, 32)] < MEASURED[(arm, 64)] < MEASURED[(arm, 128)]
    assert MEASURED[("oracle", 32)] < MEASURED[("oracle", 64)]
    for value in MEASURED.values():
        assert 0.0 <= value <= 1.0
    print("\nSanity gates: all values in [0,1]; every arm strictly increasing in budget.")


def main() -> None:
    print("The Oracle Overstates the Deployable Win --- numerical demonstrations")
    demo_oracle_and_exchange()
    demo_consistency_price()
    demo_sharpness()
    demo_impossibility()
    demo_randomisation()
    demo_diagnostics()
    demo_granularity()
    demo_layers()
    demo_recorded_run()
    print()
    print("=" * 74)
    print("All demonstrations completed and all assertions passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
