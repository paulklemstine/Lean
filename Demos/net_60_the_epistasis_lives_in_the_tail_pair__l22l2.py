"""Epistasis Order as a Hypergraph Transversal Number, with an O(L^2) Certificate.

Fix a tolerance eps.  A route is *near-optimal* if its loss is within eps of the
unpruned optimum.  The central structural theorem is:

    cost(S) > eps   <=>   S meets the support of every near-optimal route,

i.e. an ablation is expensive exactly when it is a transversal (hitting set) of
the near-optimal route hypergraph.  Consequently the *epistasis order*

    epiOrder(eps) = min { |S| : cost(S) > eps }

is precisely the transversal number of that hypergraph.

Two algorithms are provided.

1. ``epistasis_order_exhaustive`` — increasing-size search, certifying order k in
   O(binom(L, k) * P) route scans.  Exact but exponential in k; the general
   transversal-number problem is NP-hard, so no polynomial method is expected.

2. ``order_two_certificate`` — the practical route.  If every single layer is
   affordable at tolerance eps >= 0 and some pair is not, then the order is
   exactly 2, with no search at all: cardinality 0 would make the empty ablation
   expensive (impossible, its cost is 0 <= eps) and cardinality 1 is excluded by
   hypothesis.  This needs only the L solo ablations plus the O(L^2) pair
   ablations already collected in a standard sweep, replacing a hopeless 2^L
   subset enumeration.

``greedy_transversal`` additionally returns a small hitting set via the classical
greedy heuristic (an O(log |E|)-approximation), useful to seed the exact search.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, Dict, FrozenSet, List, Optional, Sequence, Set, Tuple

Layers = FrozenSet[int]
Route = Tuple[FrozenSet[int], float]


def unpruned_optimum(routes: Sequence[Route]) -> float:
    """netLoss of the empty ablation: every route survives, so the global min."""
    return min(loss for _, loss in routes)


def near_optimal(routes: Sequence[Route], eps: float) -> List[Route]:
    """Routes whose loss is within eps of the unpruned optimum."""
    base = unpruned_optimum(routes)
    return [(s, l) for s, l in routes if l <= base + eps + 1e-12]


def is_transversal(routes: Sequence[Route], eps: float, S: Sequence[int]) -> bool:
    """Does S meet the support of every eps-near-optimal route?"""
    Sf = frozenset(S)
    return all(supp & Sf for supp, _ in near_optimal(routes, eps))


def epistasis_order_exhaustive(
    cost: Callable[[Sequence[int]], float],
    n_layers: int,
    eps: float,
    max_k: Optional[int] = None,
) -> Tuple[Optional[int], Optional[Tuple[int, ...]]]:
    """Least size of an expensive ablation, plus a witness of that size."""
    cap = n_layers if max_k is None else max_k
    for k in range(cap + 1):
        for S in combinations(range(n_layers), k):
            if cost(S) > eps + 1e-12:
                return k, S
    return None, None


def order_two_certificate(
    cost: Callable[[Sequence[int]], float], n_layers: int, eps: float
) -> Tuple[bool, Optional[Tuple[int, int]], Dict[str, float]]:
    """Certify epiOrder(eps) = 2 from solo and pair ablations alone.

    Returns (certified, witness pair, diagnostics).  Requires eps >= 0.
    Complexity: L + binom(L, 2) ablation evaluations, i.e. O(L^2) scans.
    """
    assert eps >= 0.0, "the criterion requires a non-negative tolerance"
    solos = {i: cost([i]) for i in range(n_layers)}
    worst_solo = max(solos.values(), default=0.0)
    if worst_solo > eps + 1e-12:  # some single layer is already expensive
        return False, None, {"worst_solo": worst_solo, "reason_order_is": 1.0}
    for a, b in combinations(range(n_layers), 2):
        if cost([a, b]) > eps + 1e-12:
            return True, (a, b), {
                "worst_solo": worst_solo,
                "pair_cost": cost([a, b]),
                "epistasis": cost([a, b]) - solos[a] - solos[b],
            }
    return False, None, {"worst_solo": worst_solo, "reason_order_is": float("inf")}


def greedy_transversal(routes: Sequence[Route], eps: float) -> List[int]:
    """Greedy hitting set of the near-optimal route family (log-approximation)."""
    edges: List[Set[int]] = [set(s) for s, _ in near_optimal(routes, eps) if s]
    chosen: List[int] = []
    while edges:
        counts: Dict[int, int] = {}
        for e in edges:
            for v in e:
                counts[v] = counts.get(v, 0) + 1
        if not counts:
            break
        v = max(counts, key=lambda x: (counts[x], -x))
        chosen.append(v)
        edges = [e for e in edges if v not in e]
    return sorted(chosen)


if __name__ == "__main__":
    FULL: Layers = frozenset(range(24))

    # The tail subsystem: layers 22 and 23 are almost free alone, everything else
    # is cheap, and only their joint ablation is expensive.
    TAIL_TARGETS = [
        (frozenset(), 0.0),
        (frozenset({22}), 3.0),
        (frozenset({23}), 3.0),
        (FULL - frozenset({22, 23}), 3.0),
        (FULL, 42.0),
    ]
    ROUTES: List[Route] = [(FULL - t, l) for t, l in TAIL_TARGETS]

    def cost(S: Sequence[int]) -> float:
        Sf = frozenset(S)
        base = unpruned_optimum(ROUTES)
        return min(l for s, l in ROUTES if not (s & Sf)) - base

    eps = 3.0
    print(f"tolerance eps = {eps}")
    print(f"  worst single-layer cost : {max(cost([i]) for i in range(24)):.0f}")
    print(f"  cost of the pair 22,23  : {cost([22, 23]):.0f}")

    k, wit = epistasis_order_exhaustive(cost, 24, eps, max_k=3)
    print(f"  exhaustive epistasis order : {k}   witness {wit}")

    ok, pair, diag = order_two_certificate(cost, 24, eps)
    print(f"  O(L^2) certificate         : {ok}   pair {pair}   {diag}")

    print(f"  greedy transversal         : {greedy_transversal(ROUTES, eps)}")
    print(f"  is {{22,23}} a transversal?   : {is_transversal(ROUTES, eps, [22, 23])}")
    print(f"  is {{22}} a transversal?      : {is_transversal(ROUTES, eps, [22])}")
    print("\n  note: this minimal subsystem models only the tail's redundancy, so other")
    print("        pairs are expensive too; the substantive content is that NO SINGLE")
    print("        layer is, which is what pins the epistasis order at exactly 2.")


"""Merge-Axiom Certification of Safe Per-Layer Pruning Budgets.

Since arbitrary monotone ablation-cost profiles are realizable, no additivity law
is forced by the model; any such law must come from extra structure on the route
family.  The exact structure is the *merge axiom*: a route family is mergeable if
any two routes p, q admit a common refinement r with

    supp(r) subset of supp(p) AND supp(q),
    loss(r) <= max(loss(p), loss(q)).

Whatever two backup routes can achieve separately, some route depending only on
the layers *both* of them need can achieve as well.

Under this local, pairwise-checkable hypothesis one gets a global bound over the
entire Boolean lattice of 2^L ablations:

    cost(S union T) <= max(cost(S), cost(T)),      hence
    cost(S)         <= max over i in S of cost({i}).

The second line is exactly the licence to do per-layer budget accounting.
Conversely a single super-additive pair certifies that mergeability fails, and
``merge_obstruction`` extracts the explicit witness: two optimal backups whose
common part is strictly worse than both.

This module also implements the *delta-relaxed* merge axiom (allowing slack
delta in the loss comparison) and computes the smallest slack under which a given
route family is mergeable, which is the practical certificate.

Complexity: the exact merge check is O(P^3) route comparisons for P routes,
O(P^2) if refinements are indexed by support; the slack computation is the same
scan taking a maximum instead of a boolean.
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, List, Optional, Sequence, Tuple

Layers = FrozenSet[int]
Route = Tuple[FrozenSet[int], float]


def net_loss(routes: Sequence[Route], S: Sequence[int]) -> float:
    Sf = frozenset(S)
    return min(l for supp, l in routes if not (supp & Sf))


def cost(routes: Sequence[Route], S: Sequence[int]) -> float:
    return net_loss(routes, S) - net_loss(routes, [])


def optimal_survivor(routes: Sequence[Route], S: Sequence[int]) -> int:
    Sf = frozenset(S)
    alive = [j for j, (supp, _) in enumerate(routes) if not (supp & Sf)]
    return min(alive, key=lambda j: routes[j][1])


def is_mergeable(routes: Sequence[Route], delta: float = 0.0) -> bool:
    """Does every pair of routes admit a common refinement within slack delta?"""
    for supp_p, loss_p in routes:
        for supp_q, loss_q in routes:
            bound = max(loss_p, loss_q) + delta + 1e-12
            inter = supp_p & supp_q
            if not any(s <= inter and l <= bound for s, l in routes):
                return False
    return True


def merge_slack(routes: Sequence[Route]) -> float:
    """Smallest delta making the family delta-mergeable.

    For each pair (p, q) the best available refinement inside the intersection of
    supports costs some amount; the slack needed is that amount minus
    max(loss p, loss q), and the family's slack is the worst case over all pairs.
    """
    worst = 0.0
    for supp_p, loss_p in routes:
        for supp_q, loss_q in routes:
            inter = supp_p & supp_q
            best = min((l for s, l in routes if s <= inter), default=float("inf"))
            worst = max(worst, best - max(loss_p, loss_q))
    return max(0.0, worst)


def merge_obstruction(
    routes: Sequence[Route], S: Sequence[int], T: Sequence[int]
) -> Optional[Tuple[int, int, List[Tuple[int, float]]]]:
    """Explicit obstruction produced by a super-additive pair (S, T).

    Returns (p, q, blocked) where p is the optimal backup avoiding S, q the
    optimal backup avoiding T, and ``blocked`` lists every route depending only
    on the layers both p and q need, all of which are strictly worse than both.
    Returns None when the pair is not super-additive.
    """
    joint = cost(routes, list(S) + list(T))
    if joint - cost(routes, S) - cost(routes, T) <= 0:
        return None
    p, q = optimal_survivor(routes, S), optimal_survivor(routes, T)
    inter = routes[p][0] & routes[q][0]
    bound = max(routes[p][1], routes[q][1])
    blocked = [(j, l) for j, (s, l) in enumerate(routes) if s <= inter and l > bound]
    return p, q, blocked


def per_layer_budget_holds(routes: Sequence[Route], n_layers: int) -> bool:
    """Check cost(S) <= max solo cost in S over every nonempty ablation."""
    for k in range(1, n_layers + 1):
        for S in combinations(range(n_layers), k):
            if cost(routes, S) > max(cost(routes, [i]) for i in S) + 1e-9:
                return False
    return True


if __name__ == "__main__":
    FULL: Layers = frozenset(range(6))

    # (a) A NON-mergeable family: two layers free alone, costly together.
    tail = [
        (FULL, 0.0),                       # unpruned optimum (depends on all)
        (FULL - frozenset({4}), 3.0),      # backup avoiding layer 4, needs layer 5
        (FULL - frozenset({5}), 3.0),      # backup avoiding layer 5, needs layer 4
        (frozenset({4, 5}), 3.0),          # route needing only the tail
        (frozenset(), 42.0),               # fallback
    ]
    print("co-adapted tail family")
    print(f"   solo costs 4,5        : {cost(tail,[4]):.0f}, {cost(tail,[5]):.0f}")
    print(f"   joint cost {{4,5}}      : {cost(tail,[4,5]):.0f}")
    print(f"   mergeable             : {is_mergeable(tail)}")
    print(f"   merge slack needed    : {merge_slack(tail):.0f}")
    obs = merge_obstruction(tail, [4], [5])
    assert obs is not None
    p, q, blocked = obs
    print(f"   obstruction: optimal backups are routes {p} and {q} "
          f"(losses {tail[p][1]:.0f}, {tail[q][1]:.0f});")
    print(f"   every route inside their common support is worse: {blocked}")
    print(f"   per-layer budgeting valid : {per_layer_budget_holds(tail, 6)}")

    # (b) A mergeable family: the bottleneck profile c(S) = max_{i in S} phi(i).
    phi = [0.5, 1.5, 2.5, 3.5, 4.5, 5.5]
    bottleneck: List[Route] = []
    for k in range(7):
        for A in combinations(range(6), k):
            comp = FULL - frozenset(A)
            bottleneck.append((frozenset(A), max((phi[i] for i in comp), default=0.0)))
    print("\nbottleneck family  c(S) = max phi(i)")
    print(f"   mergeable                 : {is_mergeable(bottleneck)}")
    print(f"   merge slack needed        : {merge_slack(bottleneck):.1f}")
    print(f"   per-layer budgeting valid : {per_layer_budget_holds(bottleneck, 6)}")


"""Fast Möbius (Zeta) Transform for the Pure-Interaction Spectrum of a Cost Profile.

For a cost profile c on subsets of a block K of k layers, the pure-interaction
(Möbius) coefficients are

    m(A) = sum over B subset of A of (-1)^{|A \\ B|} c(B),

and the inversion theorem states that every joint ablation cost decomposes
uniquely into interactions of all orders:  c(S) = sum over A subset of S of m(A).

Order 1 recovers the solo costs, order 2 IS pairwise epistasis, and order 3 gives
the compounding law for triples:

    c(a,b,d) - (c(a)+c(b)+c(d)) = m(a,b) + m(a,d) + m(b,d) + m(a,b,d).

Naive evaluation of the whole spectrum costs O(3^k).  The transform below is the
standard subset-sum butterfly — one coordinate sweep per element, replacing the
value at every set containing x by its difference with the value at the set
without x — which runs in O(k * 2^k) time and O(2^k) space.  It is the fast
Walsh-Hadamard butterfly with subtraction in place of the +/- combination, and it
is exactly invertible by the zeta transform (replace '-=' with '+=').
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, Dict, FrozenSet, List, Sequence, Tuple

Layers = FrozenSet[int]


def mobius_transform(values: List[float], k: int) -> List[float]:
    """In-place-style subset Möbius transform of a 2^k table.  O(k * 2^k)."""
    out = list(values)
    for i in range(k):
        bit = 1 << i
        for mask in range(1 << k):
            if mask & bit:
                out[mask] -= out[mask ^ bit]
    return out


def zeta_transform(values: List[float], k: int) -> List[float]:
    """Inverse of ``mobius_transform``: recovers c(S) = sum_{A subset S} m(A)."""
    out = list(values)
    for i in range(k):
        bit = 1 << i
        for mask in range(1 << k):
            if mask & bit:
                out[mask] += out[mask ^ bit]
    return out


def interaction_spectrum(
    cost: Callable[[Layers], float], block: Sequence[int]
) -> Dict[Tuple[int, ...], float]:
    """All pure interactions inside ``block``, keyed by the sub-collection."""
    k = len(block)
    table = [
        cost(frozenset(block[i] for i in range(k) if mask >> i & 1))
        for mask in range(1 << k)
    ]
    coeffs = mobius_transform(table, k)
    return {
        tuple(block[i] for i in range(k) if mask >> i & 1): coeffs[mask]
        for mask in range(1 << k)
    }


def order_totals(spectrum: Dict[Tuple[int, ...], float]) -> Dict[int, float]:
    """Total interaction contributed by each order."""
    out: Dict[int, float] = {}
    for A, m in spectrum.items():
        out[len(A)] = out.get(len(A), 0.0) + m
    return out


def verify_inversion(
    cost: Callable[[Layers], float], block: Sequence[int], tol: float = 1e-9
) -> bool:
    """Check c(S) = sum_{A subset S} m(A) for every subset S of the block."""
    spec = interaction_spectrum(cost, block)
    for k in range(len(block) + 1):
        for S in combinations(block, k):
            predicted = sum(m for A, m in spec.items() if set(A) <= set(S))
            if abs(predicted - cost(frozenset(S))) > tol:
                return False
    return True


if __name__ == "__main__":
    # The measured 24-layer ablation profile, in hundredths of an accuracy point.
    PROFILE: Dict[Tuple[int, ...], float] = {
        (): 0.0,
        (21,): 13.0, (22,): 3.0, (23,): 3.0,
        (21, 22): 45.0, (21, 23): 45.0, (22, 23): 42.0,
        (21, 22, 23): 76.0,
    }

    def cost(S: Layers) -> float:
        return PROFILE[tuple(sorted(S))]

    block = (21, 22, 23)
    spec = interaction_spectrum(cost, block)
    print("Pure-interaction spectrum of the tail triple:")
    for A in sorted(spec, key=lambda t: (len(t), t)):
        if A:
            print(f"   order {len(A)}   m{A} = {spec[A]:+.0f}")

    tot = order_totals(spec)
    print("\nCompounding law:")
    print(f"   solo (order 1)        {tot[1]:+.0f}")
    print(f"   pairwise (order 2)    {tot[2]:+.0f}")
    print(f"   genuine triple (3)    {tot[3]:+.0f}")
    print(f"   total                 {sum(tot.values()):.0f}"
          f"   (measured 76)")
    print(f"\ninversion verified for every subset: {verify_inversion(cost, block)}")


"""Tropical Ablation-Cost Evaluation by Min-Plus Reduction over Surviving Routes.

Given a route system on L layers — a list of (support bitmask, loss) pairs, where
the support of a route is the set of layers whose fine structure it depends on —
this evaluates the ablation cost of an arbitrary layer set S:

    netLoss(S) = min { loss(i) : supp(i) AND S = 0 }      (a min-plus sum)
    cost(S)    = netLoss(S) - netLoss(0)

Representing supports as integer bitmasks turns the disjointness test into a
single bitwise AND, so a query is one linear scan: O(P) machine-word operations
for P routes, with no dependence on the depth L beyond word size.  Evaluating a
whole ablation table of A arms costs O(A*P); precomputing all solo costs costs
O(L*P).
"""

from __future__ import annotations

from typing import Dict, Iterable, List, Optional, Sequence, Tuple


def mask_of(layers: Iterable[int]) -> int:
    """Pack a set of layer indices into a bitmask."""
    m = 0
    for i in layers:
        m |= 1 << i
    return m


def layers_of(mask: int) -> List[int]:
    """Unpack a bitmask into a sorted list of layer indices."""
    out: List[int] = []
    i = 0
    while mask:
        if mask & 1:
            out.append(i)
        mask >>= 1
        i += 1
    return out


class TropicalNet:
    """A finite family of computation routes with min-plus evaluation.

    ``routes`` is a sequence of ``(support_mask, loss)`` pairs.  A fallback route
    of empty support is appended if absent, guaranteeing that the survivor set is
    never empty and every minimum is well defined.
    """

    def __init__(self, n_layers: int, routes: Sequence[Tuple[int, float]]) -> None:
        self.n_layers: int = n_layers
        self.routes: List[Tuple[int, float]] = list(routes)
        if not any(m == 0 for m, _ in self.routes):
            self.routes.append((0, max((l for _, l in self.routes), default=0.0) + 1.0))
        self._base: float = self._net_loss_mask(0)
        self._cache: Dict[int, float] = {}

    # ---- core min-plus reduction ---------------------------------------- #

    def _net_loss_mask(self, s: int) -> float:
        best = float("inf")
        for supp, loss in self.routes:
            if supp & s == 0 and loss < best:
                best = loss
        return best

    def net_loss(self, layers: Iterable[int]) -> float:
        """Tropical sum of the losses of the routes surviving the ablation."""
        return self._net_loss_mask(mask_of(layers))

    def cost(self, layers: Iterable[int]) -> float:
        """Increase of the tropical minimum caused by the ablation."""
        s = mask_of(layers)
        if s not in self._cache:
            self._cache[s] = self._net_loss_mask(s) - self._base
        return self._cache[s]

    def epistasis(self, a: Iterable[int], b: Iterable[int]) -> float:
        """Joint cost minus the two solo costs."""
        la, lb = list(a), list(b)
        return self.cost(la + lb) - self.cost(la) - self.cost(lb)

    def optimal_survivor(self, layers: Iterable[int]) -> Optional[int]:
        """Index of a route attaining the post-ablation minimum (the witness)."""
        s = mask_of(layers)
        best_j, best_l = None, float("inf")
        for j, (supp, loss) in enumerate(self.routes):
            if supp & s == 0 and loss < best_l:
                best_j, best_l = j, loss
        return best_j

    def solo_profile(self) -> Dict[int, float]:
        """All single-layer ablation costs, in O(L*P)."""
        return {i: self.cost([i]) for i in range(self.n_layers)}

    def ablation_table(
        self, arms: Sequence[Tuple[str, Sequence[int]]]
    ) -> List[Tuple[str, Sequence[int], float, float, float]]:
        """For each arm return (name, layers, joint cost, solo sum, excess).

        The excess is joint minus solo sum.  For a pair it is exactly the
        pairwise epistasis; for larger arms it also absorbs the higher-order
        interactions, which the Möbius spectrum separates out.
        """
        out = []
        for name, L in arms:
            joint = self.cost(L)
            solo = sum(self.cost([i]) for i in L)
            out.append((name, L, joint, solo, joint - solo))
        return out


def from_retention_targets(
    n_layers: int, targets: Sequence[Tuple[Sequence[int], float]]
) -> TropicalNet:
    """Build a net from retention patterns.

    The route with retention target T survives exactly the ablations S subset of
    T, so its support is the complement of T.
    """
    universe = (1 << n_layers) - 1
    return TropicalNet(n_layers, [(universe & ~mask_of(t), loss) for t, loss in targets])


if __name__ == "__main__":
    FULL = list(range(24))
    TOUCHED = [0, 1, 10, 11, 12, 15, 21, 22, 23]
    UNTOUCHED = [i for i in FULL if i not in TOUCHED]
    net = from_retention_targets(24, [
        ([], 0.0),
        ([0], 13.0), ([1], 12.0), ([10], 14.0), ([11], 14.0),
        ([12], 57.0), ([15], 22.0), ([21], 13.0), ([22], 3.0), ([23], 3.0),
        ([0, 1], 25.0), ([10, 11], 40.0), ([12, 15], 60.0), ([12, 22], 59.0),
        ([22, 23], 42.0), ([21, 22, 23], 76.0), ([21, 22], 45.0), ([21, 23], 45.0),
        (UNTOUCHED, 20.0), (FULL, 10000.0),
    ])
    arms = [("tail", [22, 23]), ("bulk", [12, 15]), ("front", [0, 1]),
            ("mid", [10, 11]), ("cross", [12, 22]), ("triple", [21, 22, 23])]
    print(f"{'arm':<8}{'layers':<14}{'joint':>7}{'solo':>7}{'excess':>8}   class")
    for name, L, joint, solo, e in net.ablation_table(arms):
        cls = "SUPER" if e > 0 else ("sub" if e < 0 else "additive")
        print(f"{name:<8}{str(L):<14}{joint:7.0f}{solo:7.0f}{e:+8.0f}   {cls}")


"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
import pathlib
from typing import Any, Dict, List

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES: List[str] = [
    "Catalog/Tropical/NetEpistasis/Core.lean",
    "Catalog/Tropical/NetEpistasis/Representation.lean",
    "Catalog/Tropical/NetEpistasis/Interaction.lean",
    "Catalog/Tropical/NetEpistasis/Transversal.lean",
    "Catalog/Tropical/NetEpistasis/Merge.lean",
    "Catalog/Tropical/NetEpistasis/TailPair.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===================== {f} =====================\n\n{read(ROOT / f)}"
    for f in LEAN_FILES
)

FUTURE_DIRECTIONS = read(A / "future_directions.md")

pkg: Dict[str, Any] = {
    "title": "The Tail Pair Is One Unit: Tropical Epistasis of Layer Ablations",
    "domain": "Tropical",
    "description": (
        "A min-plus (tropical) theory of neural-network ablation cost in which "
        "pruning a set of layers raises a minimum over surviving computation "
        "routes, explaining why the last two layers of a 24-layer transformer "
        "each cost 0.03 accuracy points alone but 0.42 points together. The "
        "realizable cost profiles are exactly the monotone normalized ones, so "
        "no additivity law exists; an ablation is expensive precisely when it is "
        "a hitting set of the near-optimal routes; and additivity holds exactly "
        "under a two-route merge axiom."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-24",
    "key_results": [
        "Representation theorem: a function on subsets of layers is the ablation-cost profile of some computation-route family if and only if it vanishes on the empty set and is monotone; monotonicity is therefore the only universal constraint, no additivity law holds, and the super-additivity ratio is unbounded.",
        "Hitting-set characterization: pruning a layer set costs more than a tolerance if and only if that set meets the support of every near-optimal route, so the least size of an expensive ablation is the transversal number of the near-optimal route hypergraph, and it equals two exactly when all single layers are cheap but some pair is not.",
        "Co-adaptation theorem: if two layers are individually affordable but jointly costly, then every near-optimal backup for one of them routes through the other, and nothing else backs either of them up.",
        "Merge axiom: if any two routes admit a common refinement supported on the layers both require and no worse than the worse of the two, then the cost of any joint ablation is bounded by the maximum of the individual costs, and by induction by the largest single-layer cost — so per-layer budgeting is provably safe; conversely one super-additive pair yields an explicit merge obstruction.",
        "Exact solution of the measured ablation table by a twenty-route family on twenty-four layers, in which the tail pair is seven-fold super-additive, three of six arms are super-additive and two sub-additive (refuting additivity), the tail triple compounds fourfold, and its Mobius decomposition reads 0.76 = 0.19 + 0.94 - 0.37 with a negative third-order term showing the co-adapted unit saturates at width two.",
    ],
    "keywords": [
        "tropical semiring",
        "min-plus algebra",
        "layer ablation",
        "epistasis",
        "Mobius inversion",
        "hypergraph transversal",
        "network pruning",
        "co-adaptation",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Tropical Ablation Laboratory: Reproducing and Dissecting the Measured Epistasis Table",
            "description": (
                "A complete, dependency-free walkthrough of the theory on the "
                "explicit twenty-route family that reproduces the measured "
                "ablation table exactly. It recomputes every solo and joint cost "
                "as a min-plus minimum over surviving routes; classifies all six "
                "arms as super-, sub- or exactly additive; verifies that the "
                "reported 'joint minus sum of solos' equals the second-order "
                "Mobius coefficient; computes the full interaction spectrum of "
                "the tail triple and checks the exact decomposition "
                "76 = 19 + 94 - 37; confirms the hitting-set equivalence between "
                "being expensive and being a transversal of the near-optimal "
                "routes; exhibits the two co-adapted backup routes of the tail "
                "pair; computes the epistasis order of the tail subsystem and of "
                "block profiles of every width; realizes prescribed pure "
                "epistasis of arbitrary strength to show the ratio is unbounded; "
                "and finally extracts the explicit merge obstruction from the "
                "tail pair, contrasting it with a genuinely mergeable family in "
                "which per-layer budgeting provably holds over all subsets."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "How Special Is Additivity? A Monte-Carlo Study over Realizable Cost Profiles",
            "description": (
                "A quantitative companion to the representation theorem. Since "
                "every monotone normalized profile is realizable, the demo samples "
                "random monotone profiles under two schemes — a bottom-up "
                "lattice construction and a mixture of capability blocks — "
                "realizes each as an explicit route family, and tabulates how "
                "often pairs come out super-additive, sub-additive or exactly "
                "additive, together with the median and maximum blow-up ratios. "
                "Exact additivity never occurs under the generic scheme; where it "
                "does occur, under size-one capability blocks, the damage is "
                "modular and the theory predicts zero epistasis. The demo closes "
                "by realizing pure epistasis of prescribed strength up to a "
                "million-fold, confirming the ratio is unbounded."
            ),
            "code": read(A / "demo_random_profiles.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Tropical Ablation-Cost Evaluation by Min-Plus Reduction over Surviving Routes",
            "description": (
                "The primitive on which everything else is built. A route family "
                "is stored as a list of (support bitmask, loss) pairs; the "
                "ablation cost of a layer set S is the minimum loss among routes "
                "whose support is disjoint from S, less the unpruned baseline — "
                "a sum in the min-plus semiring taken over a variable index set. "
                "Bitmask supports reduce the disjointness test to one bitwise "
                "AND, so a single query is a linear scan costing O(P) machine-word "
                "operations for P routes, independent of depth beyond word size; "
                "a full ablation table of A arms costs O(A*P) and the complete "
                "solo profile costs O(L*P). The module also returns the optimal "
                "surviving route, which is the witness used to certify each cost "
                "value, and builds families from retention patterns (the route "
                "with retention target T has support equal to the complement of T "
                "and so survives exactly the ablations contained in T)."
            ),
            "pseudocode": (
                "ALGORITHM TropicalAblationCost\n"
                "INPUT   routes = [(supp_1, loss_1), ..., (supp_P, loss_P)], supports as bitmasks\n"
                "        a fallback route with supp = 0 is appended if absent\n"
                "        S, a set of layers to prune\n"
                "OUTPUT  cost(S), and a witness route attaining it\n"
                "\n"
                "1  s <- bitmask(S)\n"
                "2  best <- +infinity ;  witness <- undefined\n"
                "3  for j = 1 .. P do\n"
                "4      if supp_j AND s = 0 then                  // route j survives\n"
                "5          if loss_j < best then\n"
                "6              best <- loss_j ;  witness <- j\n"
                "7  baseline <- min over all j of loss_j          // netLoss(empty set)\n"
                "8  return (best - baseline, witness)\n"
                "\n"
                "CORRECTNESS  every route survives the empty ablation, so line 7 is netLoss(0);\n"
                "             lines 3-6 compute the tropical sum over the survivor set, which is\n"
                "             nonempty because the fallback route has empty support.\n"
                "COMPLEXITY   O(P) word operations per query; O(A*P) for an A-arm table."
            ),
            "code": read(A / "algo_tropical_cost.py"),
        },
        {
            "name": "Fast Mobius Transform for the Pure-Interaction Spectrum of an Ablation-Cost Profile",
            "description": (
                "Computes the complete hierarchy of pure interactions of a cost "
                "profile restricted to a block of k layers. The Mobius "
                "coefficient m(A) is the alternating sum of the profile over all "
                "sub-collections of A, and the inversion theorem states that "
                "every joint cost is the sum of the pure interactions of its "
                "sub-collections. Order one recovers the solo costs, order two is "
                "exactly the pairwise epistasis reported by experiments, and "
                "order three yields the compounding law for triples. Naive "
                "evaluation of the whole spectrum costs O(3^k); the subset "
                "butterfly implemented here — one coordinate sweep per layer, "
                "replacing the value at each set containing x by its difference "
                "with the value at the set without x — runs in O(k * 2^k) time "
                "and O(2^k) space, and is exactly inverted by the zeta transform "
                "obtained by replacing subtraction with addition. Applied to the "
                "measured tail triple it returns the decomposition "
                "76 = 19 + 94 - 37, whose negative third-order term shows the "
                "co-adapted unit saturates at width two."
            ),
            "pseudocode": (
                "ALGORITHM FastMobiusSpectrum\n"
                "INPUT   block K = (x_1, ..., x_k); oracle cost(S) for S contained in K\n"
                "OUTPUT  m(A) for every A contained in K\n"
                "\n"
                "1  for mask = 0 .. 2^k - 1 do\n"
                "2      table[mask] <- cost({ x_i : bit i of mask is set })\n"
                "3  for i = 1 .. k do                              // one sweep per coordinate\n"
                "4      bit <- 2^(i-1)\n"
                "5      for mask = 0 .. 2^k - 1 do\n"
                "6          if mask AND bit != 0 then\n"
                "7              table[mask] <- table[mask] - table[mask XOR bit]\n"
                "8  return { subset(mask) -> table[mask] }\n"
                "\n"
                "INVERSE (zeta)  identical loop with '+' in place of '-'; recovers\n"
                "                cost(S) = sum over A contained in S of m(A).\n"
                "CORRECTNESS     after sweep i the table holds the Mobius transform in the first i\n"
                "                coordinates and the identity in the rest; induction on i.\n"
                "COMPLEXITY      O(k * 2^k) time, O(2^k) space, versus O(3^k) naively."
            ),
            "code": read(A / "algo_mobius_spectrum.py"),
        },
        {
            "name": "Epistasis Order as a Hypergraph Transversal Number, with an O(L-squared) Certificate",
            "description": (
                "Turns the question 'how many layers must be pruned together "
                "before anything breaks' into a covering problem. Since pruning a "
                "set costs more than a tolerance exactly when it meets the "
                "support of every near-optimal route, the least size of an "
                "expensive ablation is the transversal number of the near-optimal "
                "route hypergraph. Two methods are provided. The exhaustive "
                "increasing-size search certifies order k in O(binom(L,k) * P) "
                "route scans and is exact, but the general transversal-number "
                "problem is NP-hard so no polynomial method is expected. The "
                "practical route is the order-two certificate: if every single "
                "layer is affordable at a non-negative tolerance and some pair is "
                "not, the order is exactly two with no search at all — "
                "cardinality zero is impossible because the empty ablation is "
                "free, and cardinality one is excluded by hypothesis. That needs "
                "only the L solo and O(L^2) pair ablations a standard sweep "
                "already collects, replacing a hopeless enumeration of 2^L "
                "subsets. A greedy hitting-set heuristic with the classical "
                "logarithmic approximation guarantee is included to seed the "
                "exact search on larger instances."
            ),
            "pseudocode": (
                "ALGORITHM EpistasisOrder\n"
                "INPUT   routes, tolerance eps >= 0, depth L\n"
                "OUTPUT  epiOrder(eps) and a witness ablation\n"
                "\n"
                "-- exact, increasing-size search\n"
                "1  for k = 0, 1, 2, ... , L do\n"
                "2      for every S contained in {0..L-1} with |S| = k do\n"
                "3          if cost(S) > eps then return (k, S)\n"
                "4  return (undefined, undefined)                  // nothing is expensive\n"
                "\n"
                "-- O(L^2) certificate for order two (no search)\n"
                "5  for i = 0 .. L-1 do  if cost({i}) > eps then return 1   // order is one\n"
                "6  for every pair (a,b) do\n"
                "7      if cost({a,b}) > eps then return 2\n"
                "8  return 'order exceeds two'\n"
                "\n"
                "-- greedy transversal (seeding heuristic)\n"
                " 9  E <- { supp(r) : r near-optimal at eps, supp(r) nonempty }\n"
                "10  T <- empty\n"
                "11  while E is nonempty do\n"
                "12      v <- the layer contained in the most edges of E\n"
                "13      T <- T + {v} ;  remove from E every edge containing v\n"
                "14  return T\n"
                "\n"
                "CORRECTNESS  line 5 is sound because cost is monotone and cost(empty) = 0 <= eps,\n"
                "             so no ablation of cardinality below two can be expensive once every\n"
                "             singleton is affordable.\n"
                "COMPLEXITY   O(binom(L,k) * P) to certify order k exactly; O(L^2 * P) for the\n"
                "             order-two certificate; O(|E| * L) for the greedy heuristic."
            ),
            "code": read(A / "algo_epistasis_order.py"),
        },
        {
            "name": "Merge-Axiom Certification of Safe Per-Layer Pruning Budgets",
            "description": (
                "Decides whether per-layer budget accounting is valid for a given "
                "route family, and quantifies how badly it fails when it does. "
                "The merge axiom asks that any two routes admit a common "
                "refinement supported inside the intersection of their supports "
                "and no worse than the worse of the two: whatever two backups can "
                "do separately, some route depending only on the layers both of "
                "them need can do as well. Under this local, pairwise-checkable "
                "hypothesis the cost of any joint ablation is bounded by the "
                "maximum of the individual costs, and by induction by the largest "
                "single-layer cost — a global statement over all 2^L subsets "
                "obtained from a finite certificate. The module checks exact "
                "mergeability in O(P^2) refinement lookups, computes the smallest "
                "additive slack under which the family is approximately "
                "mergeable (the practical certificate), verifies the per-layer "
                "budget bound over the whole lattice, and extracts from any "
                "super-additive pair the explicit obstruction: two optimal "
                "backups every common refinement of which is strictly worse than "
                "both."
            ),
            "pseudocode": (
                "ALGORITHM MergeCertification\n"
                "INPUT   routes = [(supp_1, loss_1), ..., (supp_P, loss_P)]\n"
                "OUTPUT  mergeable?, minimal slack delta, and an obstruction if any\n"
                "\n"
                "-- exact / delta-relaxed merge check\n"
                "1  slack <- 0\n"
                "2  for each ordered pair (p, q) of routes do\n"
                "3      inter <- supp_p AND supp_q\n"
                "4      best  <- min { loss_r : supp_r is contained in inter }   (+inf if none)\n"
                "5      slack <- max(slack, best - max(loss_p, loss_q))\n"
                "6  mergeable <- (slack <= 0)\n"
                "\n"
                "-- obstruction from a super-additive pair (S, T)\n"
                "7  if cost(S union T) - cost(S) - cost(T) > 0 then\n"
                "8      p <- optimal survivor of the ablation S\n"
                "9      q <- optimal survivor of the ablation T\n"
                "10     inter <- supp_p AND supp_q ;  bound <- max(loss_p, loss_q)\n"
                "11     blocked <- { r : supp_r contained in inter and loss_r > bound }\n"
                "12     return (p, q, blocked)     // every common refinement is strictly worse\n"
                "\n"
                "CONSEQUENCE  if mergeable then for every S,  cost(S) <= max over i in S of\n"
                "             cost({i}), so per-layer budget accounting is valid.\n"
                "COMPLEXITY   O(P^2) pairs times the refinement lookup; O(P^3) unindexed,\n"
                "             O(P^2) with supports indexed by subset."
            ),
            "code": read(A / "algo_merge_certification.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Epistasis Landscape and the Interaction Spectrum of the Tail Triple",
            "description": (
                "A two-panel figure. The left panel pairs, for each of the six "
                "measured ablation arms, the joint cost against the sum of its "
                "members' solo costs, annotating each with its blow-up ratio and "
                "arrowing the super-additive excess; the arms are ordered so that "
                "the super-additive ones stand to the left of the additive and "
                "sub-additive ones, making visible that the tail pair "
                "simultaneously has the shortest solo bar and the largest ratio. "
                "The right panel shows the pure-interaction spectrum of the tail "
                "triple split by order: three solo terms, three pairwise "
                "epistases, and the single genuine third-order term, whose "
                "negative value of -37 hundredths is the evidence that the "
                "co-adapted unit saturates at width two rather than compounding "
                "indefinitely. An inset states the exact decomposition "
                "19 + 94 - 37 = 76."
            ),
            "code": read(A / "viz_epistasis_landscape.py"),
        },
        {
            "name": "Hitting Sets of the Near-Optimal Routes, and the Cost Lattice of the Tail Triple",
            "description": (
                "A two-panel figure making the combinatorial characterization "
                "concrete. The left panel draws the incidence matrix of the "
                "near-optimal route family of the tail subsystem at a tolerance "
                "of 0.03 accuracy points — rows are routes, columns are layers, a "
                "filled cell means the route depends on that layer — and then "
                "tests candidate ablations against it in a strip underneath, "
                "showing that no single layer meets every route while the tail "
                "pair does, so the transversal number and hence the epistasis "
                "order is exactly two. The right panel draws the cost surface "
                "over all subsets of the tail triple as a Hasse diagram of the "
                "Boolean lattice, each node shaded and labelled by its ablation "
                "cost, exhibiting the flat-flat-cliff profile that is the visual "
                "signature of a coordinated unit."
            ),
            "code": read(A / "viz_transversal_hypergraph.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Tropical Ablation Laboratory — Why Two Free Layers Cost a Fortune Together",
            "description": (
                "A single, deeply-instrumented widget that lets the reader "
                "discover the whole theory by hand on a live route family "
                "reproducing the measured ablation table exactly. Six linked "
                "panels. (1) A pruning console: click layers, or load any of the "
                "six measured arms, and read off the joint cost, the sum of solo "
                "costs, the epistasis, and a verdict classifying the ablation as "
                "super-, sub- or exactly additive, with comparative bars. (2) A "
                "route inspector showing every computation route, greying out "
                "those the ablation destroyed and highlighting the best survivor "
                "that sets the network's loss — clicking layer 22 alone reveals "
                "the surviving backup is precisely the route through layer 23, "
                "which is the entire phenomenon in one line. (3) A hitting-set "
                "panel with a tolerance slider that checks, live, the equivalence "
                "between being expensive and being a transversal of the "
                "near-optimal routes, and computes the epistasis order by "
                "search. (4) The measured ablation table, clickable to load any "
                "arm. (5) A live Mobius interaction spectrum for a selectable "
                "block of layers, displaying the signed contributions of each "
                "order and the exact decomposition of the joint cost. (6) A merge "
                "panel that exhibits the two optimal backup routes of the current "
                "pair and every candidate common refinement, certifying whether a "
                "merge exists or displaying the explicit obstruction. Six "
                "progressive-disclosure sections carry the formal statements and "
                "proofs — the representation theorem, the hitting-set "
                "characterization, the compounding law, the merge theorem and its "
                "dual obstruction — so a newcomer can stay on the narrative while "
                "an expert can read every argument."
            ),
            "html": read(A / "widget_tail_pair.html"),
        },
    ],
    "interactive_layout": read(A / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "demo_random_profiles": read(A / "demo_random_profiles.py"),
        "algo_tropical_cost": read(A / "algo_tropical_cost.py"),
        "algo_mobius_spectrum": read(A / "algo_mobius_spectrum.py"),
        "algo_epistasis_order": read(A / "algo_epistasis_order.py"),
        "algo_merge_certification": read(A / "algo_merge_certification.py"),
        "viz_epistasis_landscape": read(A / "viz_epistasis_landscape.py"),
        "viz_transversal_hypergraph": read(A / "viz_transversal_hypergraph.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(pkg, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out}  ({out.stat().st_size/1024:.1f} KiB)")


"""How special is additivity?  A Monte-Carlo study over realizable cost profiles.

The representation theorem says a function c on subsets of layers is the
ablation-cost profile of some route family **exactly** when c(empty) = 0 and c is
monotone.  Monotonicity is therefore the only universal constraint — there is no
additivity law to appeal to.

This demo makes that quantitative.  It samples random monotone normalized
profiles on a small layer set, realizes each one as an explicit route family, and
measures how often pairs come out super-additive, sub-additive, or exactly
additive.  Two sampling schemes are used, because "random monotone function" has
no canonical meaning:

  * ``sample_monotone_lattice``  — draw an increment for every covering pair of
    the Boolean lattice and accumulate: c(S) = sum over the chain, symmetrized by
    taking, for each S, the max over its immediate predecessors plus a fresh
    non-negative increment.  This is the maximum-entropy way to build a monotone
    function bottom-up.

  * ``sample_threshold_mixture`` — draw a random collection of "capability
    blocks" K with weights r_K and set c(S) = sum of r_K over blocks K contained
    in S.  Every such profile is monotone, and this is exactly the structure the
    theory predicts for a network with several co-adapted units.

The headline numbers are instructive.  Under the bottom-up scheme exact
additivity occurs in **zero** of thousands of pairs — it is a measure-zero
coincidence, not a default.  Under the block-mixture scheme it is common, but
only because size-one blocks make the damage *modular*, and modular damage has
provably zero epistasis; every super-additive pair traces to a block of size two
or more.  Either way, super-additivity is ordinary and its ratio is unbounded.
So the measured tail pair needs no special explanation for *being*
super-additive; what is remarkable is the *size* of its blow-up — a factor of
seven at the smallest solo sum anywhere in the network.

Self-contained; standard library only.  Run with:  python3 demo_random_profiles.py
"""

from __future__ import annotations

import random
from itertools import combinations
from typing import Callable, Dict, FrozenSet, List, Sequence, Tuple

Layers = FrozenSet[int]


# --------------------------------------------------------------------------- #
# Realization: every monotone normalized profile is a route family             #
# --------------------------------------------------------------------------- #


def realize(n: int, profile: Dict[Layers, float]) -> List[Tuple[Layers, float]]:
    """Canonical route family of a monotone profile.

    Routes are indexed by subsets A of layers; the route indexed by A has support
    A and loss profile(complement of A).  Then the family's ablation cost profile
    is exactly ``profile``.
    """
    universe = frozenset(range(n))
    return [
        (frozenset(A), profile[universe - frozenset(A)])
        for k in range(n + 1)
        for A in combinations(range(n), k)
    ]


def cost_of(routes: Sequence[Tuple[Layers, float]], S: Layers) -> float:
    """Ablation cost as a min-plus minimum over the surviving routes."""
    base = min(l for _, l in routes)
    return min(l for supp, l in routes if not (supp & S)) - base


def is_monotone(n: int, profile: Dict[Layers, float]) -> bool:
    for k in range(n):
        for A in combinations(range(n), k):
            Af = frozenset(A)
            for x in range(n):
                if x not in Af and profile[Af] > profile[Af | {x}] + 1e-12:
                    return False
    return True


# --------------------------------------------------------------------------- #
# Two samplers for monotone normalized profiles                                #
# --------------------------------------------------------------------------- #


def sample_monotone_lattice(n: int, rng: random.Random, scale: float = 1.0
                            ) -> Dict[Layers, float]:
    """Bottom-up construction: each set exceeds all its immediate predecessors."""
    profile: Dict[Layers, float] = {frozenset(): 0.0}
    for k in range(1, n + 1):
        for A in combinations(range(n), k):
            Af = frozenset(A)
            floor = max(profile[Af - {x}] for x in Af)
            profile[Af] = floor + rng.expovariate(1.0 / scale)
    return profile


def sample_threshold_mixture(n: int, rng: random.Random, n_blocks: int = 4,
                             scale: float = 1.0) -> Dict[Layers, float]:
    """Mixture of capability blocks: c(S) = sum of r_K over blocks K inside S."""
    blocks: List[Tuple[Layers, float]] = []
    for _ in range(n_blocks):
        size = rng.randint(1, min(3, n))
        K = frozenset(rng.sample(range(n), size))
        blocks.append((K, rng.expovariate(1.0 / scale)))
    profile: Dict[Layers, float] = {}
    for k in range(n + 1):
        for A in combinations(range(n), k):
            Af = frozenset(A)
            profile[Af] = sum(r for K, r in blocks if K <= Af)
    return profile


# --------------------------------------------------------------------------- #
# The study                                                                    #
# --------------------------------------------------------------------------- #


def classify_pairs(n: int, profile: Dict[Layers, float]
                   ) -> Tuple[int, int, int, float]:
    """Count super/sub/exactly-additive pairs and record the largest ratio."""
    routes = realize(n, profile)

    def c(*layers: int) -> float:
        return cost_of(routes, frozenset(layers))

    sup = sub = add = 0
    best_ratio = 0.0
    for a, b in combinations(range(n), 2):
        joint, solo = c(a, b), c(a) + c(b)
        e = joint - solo
        if e > 1e-9:
            sup += 1
            if solo > 1e-9:
                best_ratio = max(best_ratio, joint / solo)
            else:
                best_ratio = float("inf")
        elif e < -1e-9:
            sub += 1
        else:
            add += 1
    return sup, sub, add, best_ratio


def run(sampler: Callable[[int, random.Random], Dict[Layers, float]],
        name: str, n: int, trials: int, seed: int) -> None:
    rng = random.Random(seed)
    tot_sup = tot_sub = tot_add = 0
    ratios: List[float] = []
    checked_monotone = True
    for t in range(trials):
        prof = sampler(n, rng)
        if t < 5:
            checked_monotone &= is_monotone(n, prof)
        s, b, a, r = classify_pairs(n, prof)
        tot_sup += s
        tot_sub += b
        tot_add += a
        if r > 0:
            ratios.append(r)
    total = tot_sup + tot_sub + tot_add
    finite = [r for r in ratios if r != float("inf")]
    finite.sort()
    print(f"\n  {name}  (n = {n} layers, {trials} profiles, "
          f"{total} pairs)")
    print(f"      realizability spot-check (monotone?)  : {checked_monotone}")
    print(f"      super-additive pairs                  : "
          f"{tot_sup:5d}  ({100*tot_sup/total:5.1f} %)")
    print(f"      sub-additive pairs                    : "
          f"{tot_sub:5d}  ({100*tot_sub/total:5.1f} %)")
    print(f"      exactly additive pairs                : "
          f"{tot_add:5d}  ({100*tot_add/total:5.1f} %)")
    if finite:
        print(f"      median / max super-additive ratio     : "
              f"{finite[len(finite)//2]:.2f}x  /  {finite[-1]:.2f}x")
    if len(finite) < len(ratios):
        print(f"      profiles with an INFINITE ratio       : "
              f"{len(ratios)-len(finite)}  (both solo costs exactly zero)")


def unbounded_ratio_demo() -> None:
    """Explicitly realize a prescribed super-additivity strength."""
    print("\n  Prescribed pure epistasis: two layers free alone, worth r together.")
    n = 4
    for r in (1.0, 50.0, 1_000.0, 1e6):
        profile = {
            frozenset(A): (r if {0, 1} <= set(A) else 0.0)
            for k in range(n + 1)
            for A in combinations(range(n), k)
        }
        routes = realize(n, profile)
        c0 = cost_of(routes, frozenset({0}))
        c1 = cost_of(routes, frozenset({1}))
        c01 = cost_of(routes, frozenset({0, 1}))
        print(f"      r = {r:>10.0f}:  cost{{0}} = {c0:.0f},  cost{{1}} = {c1:.0f},  "
              f"cost{{0,1}} = {c01:.0f},  epistasis = {c01-c0-c1:.0f}")
    print("      The super-additivity ratio is unbounded — no law caps it.")


def main() -> None:
    print("=" * 74)
    print("How special is additivity?  Monte-Carlo over realizable cost profiles")
    print("=" * 74)
    run(lambda n, rng: sample_monotone_lattice(n, rng), "bottom-up monotone",
        n=4, trials=400, seed=20260824)
    run(lambda n, rng: sample_threshold_mixture(n, rng), "capability-block mixture",
        n=4, trials=400, seed=99)
    unbounded_ratio_demo()
    print("\n  Conclusion: additivity is not a null hypothesis one can fall back on.")
    print("  Under a generic monotone profile it never holds exactly.  Where it does")
    print("  hold — the block mixture with size-one blocks — the damage is MODULAR,")
    print("  each layer carrying its own fixed penalty, and the theory predicts zero")
    print("  epistasis there.  Epistasis is exactly the failure of modularity, and")
    print("  every super-additive pair above traces to a block of size two or more.")


if __name__ == "__main__":
    main()


"""Visualization: the epistasis landscape of a 24-layer ablation study.

Produces a two-panel figure.

Left panel  — for each measured arm, a paired bar chart of the joint ablation
              cost against the sum of its members' solo costs, with the
              super-additive excess shaded.  The tail pair is highlighted: it
              has the shortest solo bar and the tallest joint bar relative to
              it (a factor of seven).

Right panel — the pure-interaction (Möbius) spectrum of the tail triple
              {21, 22, 23}, split by order.  Order 1 is the solo costs, order 2
              the pairwise epistases, order 3 the single genuine third-order
              term.  The negative order-3 bar is the numerical evidence that the
              co-adapted tail unit saturates at width two.

Costs are in hundredths of an accuracy point.  Requires matplotlib and numpy.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np

Layers = FrozenSet[int]

FULL: Layers = frozenset(range(24))
TOUCHED: Layers = frozenset({0, 1, 10, 11, 12, 15, 21, 22, 23})

# (retention target, loss).  A path survives pruning S iff S is inside its target.
TARGETS: List[Tuple[Layers, float]] = [
    (frozenset(), 0.0),
    (frozenset({0}), 13.0), (frozenset({1}), 12.0),
    (frozenset({10}), 14.0), (frozenset({11}), 14.0),
    (frozenset({12}), 57.0), (frozenset({15}), 22.0),
    (frozenset({21}), 13.0), (frozenset({22}), 3.0), (frozenset({23}), 3.0),
    (frozenset({0, 1}), 25.0), (frozenset({10, 11}), 40.0),
    (frozenset({12, 15}), 60.0), (frozenset({12, 22}), 59.0),
    (frozenset({22, 23}), 42.0), (frozenset({21, 22, 23}), 76.0),
    (frozenset({21, 22}), 45.0), (frozenset({21, 23}), 45.0),
    (FULL - TOUCHED, 20.0), (FULL, 10000.0),
]

PATHS: List[Tuple[Layers, float]] = [(FULL - t, l) for t, l in TARGETS]


def net_loss(S: Iterable[int]) -> float:
    """Tropical (min-plus) sum of the losses of the paths surviving prune S."""
    Sf = frozenset(S)
    return min(loss for supp, loss in PATHS if not (supp & Sf))


def cost(S: Iterable[int]) -> float:
    """Increase of the tropical minimum caused by pruning S."""
    return net_loss(S) - net_loss(frozenset())


def mobius(A: Sequence[int]) -> float:
    """Pure interaction coefficient m(A) = sum_{B<=A} (-1)^{|A\\B|} cost(B)."""
    total = 0.0
    for k in range(len(A) + 1):
        for B in combinations(A, k):
            total += (-1.0) ** (len(A) - len(B)) * cost(B)
    return total


ARMS: List[Tuple[str, Tuple[int, ...]]] = [
    ("tail\n22,23", (22, 23)),
    ("triple\n21,22,23", (21, 22, 23)),
    ("mid\n10,11", (10, 11)),
    ("front\n0,1", (0, 1)),
    ("cross\n12,22", (12, 22)),
    ("bulk\n12,15", (12, 15)),
]


def main() -> None:
    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(14.5, 6.0))
    fig.suptitle(
        "Epistasis of layer ablations: joint cost is not the sum of solo costs",
        fontsize=14, fontweight="bold",
    )

    # ---------------- left panel: joint vs solo sum ---------------------- #
    names = [n for n, _ in ARMS]
    joint = np.array([cost(L) for _, L in ARMS])
    solo = np.array([sum(cost({i}) for i in L) for _, L in ARMS])
    x = np.arange(len(ARMS))
    w = 0.36

    ax0.bar(x - w / 2, solo, w, label="sum of solo costs", color="#9ecae1",
            edgecolor="#3182bd")
    ax0.bar(x + w / 2, joint, w, label="joint ablation cost", color="#fc9272",
            edgecolor="#de2d26")

    for i, (j, s) in enumerate(zip(joint, solo)):
        ratio = j / s if s else float("inf")
        colour = "#a50f15" if j > s else "#08519c"
        ax0.annotate(f"{ratio:.2f}x", (i + w / 2, j), textcoords="offset points",
                     xytext=(0, 5), ha="center", fontsize=10, fontweight="bold",
                     color=colour)
        if j > s:  # shade the super-additive excess
            ax0.annotate("", xy=(i + w / 2, j), xytext=(i + w / 2, s),
                         arrowprops=dict(arrowstyle="<->", color="#a50f15", lw=1.2))

    ax0.set_xticks(x)
    ax0.set_xticklabels(names, fontsize=10)
    ax0.set_ylabel("cost (hundredths of an accuracy point)")
    ax0.set_title("Six ablation arms, ordered by super-additivity")
    ax0.legend(loc="upper center", fontsize=9, framealpha=0.95)
    ax0.grid(axis="y", alpha=0.3)
    ax0.axvline(1.5, color="grey", ls=":", lw=1)
    top = max(joint.max(), solo.max())
    ax0.set_ylim(0, top * 1.24)
    ax0.text(0.02, 0.955, "super-additive", transform=ax0.transAxes, ha="left",
             fontsize=10, color="#a50f15", fontweight="bold")
    ax0.text(0.98, 0.955, "additive / sub-additive", transform=ax0.transAxes,
             ha="right", fontsize=10, color="#08519c", fontweight="bold")

    # ---------------- right panel: interaction spectrum ------------------ #
    block = (21, 22, 23)
    spectrum: Dict[Tuple[int, ...], float] = {}
    for k in range(1, 4):
        for A in combinations(block, k):
            spectrum[A] = mobius(A)

    labels = [f"m({','.join(map(str, A))})" for A in spectrum]
    values = [spectrum[A] for A in spectrum]
    orders = [len(A) for A in spectrum]
    palette = {1: "#74c476", 2: "#fd8d3c", 3: "#6a51a3"}
    colours = [palette[o] for o in orders]

    y = np.arange(len(labels))
    ax1.barh(y, values, color=colours, edgecolor="black", linewidth=0.6)
    ax1.set_yticks(y)
    ax1.set_yticklabels(labels, fontsize=10)
    ax1.invert_yaxis()
    ax1.axvline(0, color="black", lw=1)
    ax1.set_xlabel("pure interaction (hundredths of a point)")
    ax1.set_title("Interaction spectrum of the tail triple {21,22,23}")
    ax1.grid(axis="x", alpha=0.3)
    for yi, v in zip(y, values):
        ax1.annotate(f"{v:+.0f}", (v, yi), textcoords="offset points",
                     xytext=(8 if v >= 0 else -26, -4), fontsize=10,
                     fontweight="bold")

    total = sum(values)
    ax1.set_xlim(-46, 46)
    ax1.text(
        0.98, 0.06,
        f"solo 19  +  pairwise 94  +  third order (-37)  =  {total:.0f}"
        f"\n= measured triple cost 76",
        transform=ax1.transAxes, ha="right", va="bottom", fontsize=10,
        bbox=dict(boxstyle="round,pad=0.5", fc="#f7f7f7", ec="grey"),
    )

    handles = [plt.Rectangle((0, 0), 1, 1, color=palette[o]) for o in (1, 2, 3)]
    ax1.legend(handles, ["order 1 (solo)", "order 2 (epistasis)",
                         "order 3 (genuine triple)"], loc="upper left", fontsize=9)

    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("epistasis_landscape.png", dpi=160)
    print("wrote epistasis_landscape.png")


if __name__ == "__main__":
    main()


"""Visualization: an ablation is expensive exactly when it is a hitting set.

Two panels illustrating the combinatorial heart of the theory.

Left panel  — the incidence matrix of the near-optimal route family at tolerance
              eps = 0.03 accuracy points.  Rows are the computation routes that
              are still within eps of the unpruned optimum; columns are layers;
              a filled cell means the route depends on that layer.  Pruning a
              layer set S is expensive precisely when S meets every row.  The
              check strip underneath tests candidate ablations: no single layer
              hits all three rows, but the pair {22, 23} does — so the
              transversal number, i.e. the epistasis order, is exactly two.

Right panel — the cost surface over all subsets of the tail triple
              {21, 22, 23}, drawn as a Hasse diagram of the Boolean lattice with
              each node labelled by its ablation cost and each edge by the
              marginal increase.  The pattern "flat, flat, then a cliff" is the
              visual signature of a co-adapted unit.

Requires matplotlib.  Costs are in hundredths of an accuracy point.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Tuple

import matplotlib.pyplot as plt
from matplotlib.patches import Circle, Rectangle

Layers = FrozenSet[int]

FULL: Layers = frozenset(range(24))
TOUCHED: Layers = frozenset({0, 1, 10, 11, 12, 15, 21, 22, 23})

TARGETS: List[Tuple[Layers, float]] = [
    (frozenset(), 0.0),
    (frozenset({0}), 13.0), (frozenset({1}), 12.0),
    (frozenset({10}), 14.0), (frozenset({11}), 14.0),
    (frozenset({12}), 57.0), (frozenset({15}), 22.0),
    (frozenset({21}), 13.0), (frozenset({22}), 3.0), (frozenset({23}), 3.0),
    (frozenset({0, 1}), 25.0), (frozenset({10, 11}), 40.0),
    (frozenset({12, 15}), 60.0), (frozenset({12, 22}), 59.0),
    (frozenset({22, 23}), 42.0), (frozenset({21, 22, 23}), 76.0),
    (frozenset({21, 22}), 45.0), (frozenset({21, 23}), 45.0),
    (FULL - TOUCHED, 20.0), (FULL, 10000.0),
]
PATHS: List[Tuple[Layers, float]] = [(FULL - t, l) for t, l in TARGETS]

# The tail subsystem: a minimal model of the last two layers alone.  Layers 22
# and 23 are individually almost free, every other layer is cheap, and only the
# joint pruning of the pair is expensive.
TAIL_TARGETS: List[Tuple[Layers, float]] = [
    (frozenset(), 0.0),
    (frozenset({22}), 3.0),
    (frozenset({23}), 3.0),
    (FULL - frozenset({22, 23}), 3.0),
    (FULL, 42.0),
]
TAIL_PATHS: List[Tuple[Layers, float]] = [(FULL - t, l) for t, l in TAIL_TARGETS]


def net_loss(S: Iterable[int], paths: List[Tuple[Layers, float]] = PATHS) -> float:
    """Tropical (min-plus) sum of the losses of the routes surviving prune S."""
    Sf = frozenset(S)
    return min(loss for supp, loss in paths if not (supp & Sf))


def cost(S: Iterable[int], paths: List[Tuple[Layers, float]] = PATHS) -> float:
    """Increase of the tropical minimum caused by pruning S."""
    return net_loss(S, paths) - net_loss(frozenset(), paths)


def near_optimal(eps: float, paths: List[Tuple[Layers, float]] = PATHS) -> List[int]:
    """Routes whose loss is within eps of the unpruned optimum."""
    base = net_loss(frozenset(), paths)
    return [j for j, (_, l) in enumerate(paths) if l <= base + eps + 1e-12]


def draw_incidence(ax: plt.Axes, eps: float) -> None:
    """Incidence matrix of the near-optimal routes of the tail subsystem."""
    paths = TAIL_PATHS
    cols = [20, 21, 22, 23]
    rows = [j for j in near_optimal(eps, paths) if paths[j][0]]
    nc, nr = len(cols), len(rows)

    ax.set_xlim(-4.0, nc + 6.6)
    ax.set_ylim(-5.6, nr + 1.7)
    ax.axis("off")
    ax.set_aspect("equal")

    for c, lay in enumerate(cols):  # column headers
        tail = lay in (22, 23)
        ax.text(c + 0.5, nr + 0.30, str(lay), ha="center", va="bottom", fontsize=11,
                fontweight="bold" if tail else "normal",
                color="#d94801" if tail else "#08519c")
    ax.text(-0.25, nr + 0.30, "layer:", ha="right", va="bottom", fontsize=10,
            style="italic")

    for r, j in enumerate(rows):  # incidence cells
        y = nr - 1 - r
        supp = paths[j][0]
        for c, lay in enumerate(cols):
            inside = lay in supp
            ax.add_patch(Rectangle((c + 0.06, y + 0.06), 0.88, 0.88,
                                   fc="#6baed6" if inside else "#f7f7f7",
                                   ec="#525252", lw=0.8))
            if not inside:
                ax.text(c + 0.5, y + 0.5, "\u00b7", ha="center", va="center",
                        fontsize=13, color="#969696")
        ax.text(-0.25, y + 0.5, f"route {j}  (loss {paths[j][1]:.0f})",
                ha="right", va="center", fontsize=10)

    ax.text(nc / 2, nr + 1.30,
            "filled = the route depends on that layer",
            ha="center", fontsize=9.5, style="italic", color="#525252")

    tests: List[Tuple[str, Tuple[int, ...]]] = [
        ("{21}", (21,)), ("{22}", (22,)), ("{23}", (23,)), ("{22,23}", (22, 23)),
    ]
    for t, (label, S) in enumerate(tests):
        y = -1.30 - 0.66 * t
        hits = all(paths[j][0] & frozenset(S) for j in rows)
        for c, lay in enumerate(cols):
            ax.add_patch(Rectangle((c + 0.06, y + 0.04), 0.88, 0.48,
                                   fc="#fd8d3c" if lay in S else "#ffffff",
                                   ec="#8c2d04" if lay in S else "#d9d9d9", lw=0.9))
        ax.text(-0.25, y + 0.28, f"prune {label}", ha="right", va="center",
                fontsize=10)
        verdict = ("hits every route  \u2192  EXPENSIVE" if hits
                   else "misses a route  \u2192  cheap")
        ax.text(nc + 0.30, y + 0.28,
                f"cost {cost(S, paths):5.0f}    {verdict}", ha="left", va="center",
                fontsize=10, fontweight="bold" if hits else "normal",
                color="#a50f15" if hits else "#238b45")

    ax.text(nc / 2 + 1.6, -5.45,
            "No single layer meets every route, but {22,23} does:\n"
            "the transversal number \u2014 the epistasis order \u2014 is exactly 2.",
            ha="center", va="bottom", fontsize=10,
            bbox=dict(boxstyle="round,pad=0.45", fc="#fff5eb", ec="#e6550d"))

    ax.set_title(f"Tail subsystem: near-optimal routes at tolerance {eps:.0f} "
                 "(= 0.03 pts)", fontsize=12)


def draw_lattice(ax: plt.Axes) -> None:
    block = (21, 22, 23)
    nodes: Dict[Tuple[int, ...], Tuple[float, float]] = {}
    for k in range(4):
        subs = list(combinations(block, k))
        for idx, A in enumerate(subs):
            nodes[A] = ((idx - (len(subs) - 1) / 2.0) * 2.1, 1.55 * k)

    ax.set_xlim(-3.7, 3.7)
    ax.set_ylim(-2.05, 6.1)
    ax.axis("off")
    ax.set_aspect("equal")

    for A, (xa, ya) in nodes.items():
        for B, (xb, yb) in nodes.items():
            if len(B) == len(A) + 1 and set(A) < set(B):
                ax.plot([xa, xb], [ya, yb], color="#cccccc", lw=1.2, zorder=1)
                if len(B) == 3:  # label only the three edges into the top node
                    mx, my = 0.70 * xa + 0.30 * xb, 0.70 * ya + 0.30 * yb
                    if abs(xa - xb) < 1e-9:  # vertical edge: nudge clear
                        mx, my = mx + 1.0, my + 0.10
                    ax.text(mx, my, f"+{cost(B) - cost(A):.0f}", fontsize=9,
                            color="#636363", ha="center", va="center", zorder=2,
                            bbox=dict(boxstyle="round,pad=0.12", fc="white",
                                      ec="none", alpha=0.9))

    for A, (x, y) in nodes.items():
        c = cost(A)
        shade = min(1.0, c / 80.0)
        ax.add_patch(Circle((x, y), 0.46,
                            fc=(1.0, 1.0 - 0.72 * shade, 1.0 - 0.85 * shade),
                            ec="black", lw=1.4, zorder=3))
        label = "{ }" if not A else "{" + ",".join(map(str, A)) + "}"
        if not A:  # empty set: label to the right of the node
            ax.text(x + 0.62, y, label, ha="left", va="center", fontsize=9.5,
                    zorder=4)
        else:
            below = len(A) == 1
            ax.text(x, y - 0.62 if below else y + 0.62, label, ha="center",
                    va="top" if below else "bottom", fontsize=9.5, zorder=4)
        ax.text(x, y, f"{c:.0f}", ha="center", va="center", fontsize=11,
                fontweight="bold", zorder=4)

    ax.set_title("Ablation cost over the Boolean lattice of the tail triple",
                 fontsize=12)
    ax.text(0, 5.75, "each edge adds one layer to the ablation",
            ha="center", va="center", fontsize=9.5, style="italic",
            color="#525252")
    ax.text(0, -1.95,
            "Solos 13, 3, 3  —  pairs 45, 45, 42  —  triple 76.\n"
            "Flat, flat, cliff: the signature of a coordinated unit.",
            ha="center", va="bottom", fontsize=10,
            bbox=dict(boxstyle="round,pad=0.45", fc="#f7fbff", ec="#3182bd"))


def main() -> None:
    fig, (ax0, ax1) = plt.subplots(
        1, 2, figsize=(16.5, 6.6), gridspec_kw={"width_ratios": [1.45, 1.0]}
    )
    fig.suptitle(
        "Expensive ablations are exactly the hitting sets of the near-optimal routes",
        fontsize=14, fontweight="bold",
    )
    draw_incidence(ax0, 3.0)
    draw_lattice(ax1)
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig("transversal_hypergraph.png", dpi=160)
    print("wrote transversal_hypergraph.png")


if __name__ == "__main__":
    main()


"""
Tropical epistasis of layer ablations — numerical demonstration.
================================================================

A *prunable net* is a finite family of computation paths.  Path ``i`` depends on
a set of layers ``supp(i)`` (its support) and carries a loss ``loss(i)``.
Pruning a set ``S`` of layers destroys every path whose support meets ``S``; the
network falls back on the best surviving path, so

    netLoss(S) = min { loss(i) : supp(i) ∩ S = ∅ }        (a min-plus sum)
    cost(S)    = netLoss(S) - netLoss(∅)

and the pairwise *epistasis* of two layer sets is

    epi(S, T)  = cost(S ∪ T) - cost(S) - cost(T).

This script demonstrates, with no external dependencies:

  1. an explicit 20-path net on 24 layers reproducing a measured ablation table
     exactly (costs in hundredths of an accuracy point);
  2. the verdicts: the tail pair {22,23} is 7x super-additive; three of six arms
     are super-additive, two sub-additive, one exactly additive; the tail triple
     compounds at 4x and is the costliest arm;
  3. the Möbius (pure-interaction) decomposition, including the exact identity
     76 = 19 + 94 - 37 for the tail triple;
  4. the hitting-set characterization: cost(S) > eps  <=>  S is a transversal of
     the eps-near-optimal path family; and the epistasis order as a transversal
     number;
  5. the representation theorem: any monotone normalized cost profile is
     realizable, so super-additivity is unbounded;
  6. the merge axiom: mergeable systems satisfy cost(S ∪ T) <= max(cost S, cost T)
     and per-layer budgeting is safe, while the measured net is not mergeable.

Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, Dict, FrozenSet, Iterable, List, Optional, Sequence, Tuple

Layers = FrozenSet[int]

# --------------------------------------------------------------------------- #
# 1.  The tropical model                                                       #
# --------------------------------------------------------------------------- #


class PrunableNet:
    """A finite family of computation paths on ``n_layers`` layers.

    ``paths`` is a list of ``(support, loss)`` pairs.  A fallback path with
    empty support is appended automatically if none is present, so that the
    survivor set is never empty and every minimum below is well defined.
    """

    def __init__(self, n_layers: int, paths: Sequence[Tuple[Iterable[int], float]]) -> None:
        self.n_layers: int = n_layers
        self.paths: List[Tuple[Layers, float]] = [
            (frozenset(supp), float(loss)) for supp, loss in paths
        ]
        if not any(len(s) == 0 for s, _ in self.paths):
            worst = max((l for _, l in self.paths), default=0.0)
            self.paths.append((frozenset(), worst + 1.0))

    # -- tropical evaluation ------------------------------------------------ #

    def survivors(self, S: Iterable[int]) -> List[int]:
        """Indices of the paths that survive pruning the layer set ``S``."""
        Sf = frozenset(S)
        return [j for j, (supp, _) in enumerate(self.paths) if not (supp & Sf)]

    def net_loss(self, S: Iterable[int]) -> float:
        """The min-plus sum of the losses of the surviving paths."""
        return min(self.paths[j][1] for j in self.survivors(S))

    def cost(self, S: Iterable[int]) -> float:
        """The increase of the tropical minimum caused by pruning ``S``."""
        return self.net_loss(S) - self.net_loss(frozenset())

    def epi(self, S: Iterable[int], T: Iterable[int]) -> float:
        """Epistasis: joint cost minus the two solo costs."""
        Sf, Tf = frozenset(S), frozenset(T)
        return self.cost(Sf | Tf) - self.cost(Sf) - self.cost(Tf)

    # -- near-optimal paths, transversals, epistasis order ------------------ #

    def near_optimal(self, eps: float) -> List[int]:
        """Paths whose loss is within ``eps`` of the unpruned optimum."""
        base = self.net_loss(frozenset())
        return [j for j, (_, l) in enumerate(self.paths) if l <= base + eps + 1e-12]

    def is_transversal(self, eps: float, S: Iterable[int]) -> bool:
        """Does ``S`` meet the support of every eps-near-optimal path?"""
        Sf = frozenset(S)
        return all(self.paths[j][0] & Sf for j in self.near_optimal(eps))

    def epi_order(self, eps: float, max_k: Optional[int] = None) -> Optional[int]:
        """Least size of an expensive layer set = transversal number."""
        cap = self.n_layers if max_k is None else max_k
        for k in range(0, cap + 1):
            for S in combinations(range(self.n_layers), k):
                if self.cost(S) > eps + 1e-12:
                    return k
        return None

    def is_mergeable(self) -> bool:
        """Does every pair of paths admit a common refinement?"""
        for supp_p, loss_p in self.paths:
            for supp_q, loss_q in self.paths:
                inter = supp_p & supp_q
                bound = max(loss_p, loss_q)
                if not any(
                    supp_r <= inter and loss_r <= bound + 1e-12
                    for supp_r, loss_r in self.paths
                ):
                    return False
        return True


# --------------------------------------------------------------------------- #
# 2.  Möbius (pure interaction) calculus                                       #
# --------------------------------------------------------------------------- #


def mobius(cost: Callable[[Layers], float], A: Iterable[int]) -> float:
    """Pure interaction coefficient  m(A) = sum_{B<=A} (-1)^{|A\\B|} c(B)."""
    Af = tuple(sorted(A))
    total = 0.0
    for k in range(len(Af) + 1):
        for B in combinations(Af, k):
            total += (-1.0) ** (len(Af) - len(B)) * cost(frozenset(B))
    return total


def interaction_spectrum(
    cost: Callable[[Layers], float], block: Sequence[int]
) -> Dict[Tuple[int, ...], float]:
    """All pure interactions inside a block, by fast Möbius (zeta) transform.

    O(k * 2^k) for a block of k layers, versus O(3^k) for naive summation.
    """
    k = len(block)
    table: Dict[int, float] = {}
    for mask in range(1 << k):
        subset = frozenset(block[i] for i in range(k) if mask >> i & 1)
        table[mask] = cost(subset)
    for i in range(k):  # one coordinate sweep per layer
        for mask in range(1 << k):
            if mask >> i & 1:
                table[mask] -= table[mask ^ (1 << i)]
    return {
        tuple(block[i] for i in range(k) if mask >> i & 1): table[mask]
        for mask in range(1 << k)
    }


# --------------------------------------------------------------------------- #
# 3.  The canonical realization of a monotone cost profile                     #
# --------------------------------------------------------------------------- #


def net_from_profile(n_layers: int, profile: Callable[[Layers], float]) -> PrunableNet:
    """Realize any monotone normalized profile as a prunable net.

    Paths are indexed by subsets A of layers; path A has support A and loss
    ``profile(complement of A)``.  Then cost(S) = profile(S) for every S.
    """
    universe = list(range(n_layers))
    paths: List[Tuple[Iterable[int], float]] = []
    for k in range(n_layers + 1):
        for A in combinations(universe, k):
            comp = frozenset(universe) - frozenset(A)
            paths.append((A, profile(comp)))
    return PrunableNet(n_layers, paths)


# --------------------------------------------------------------------------- #
# 4.  The measured 24-layer system                                             #
# --------------------------------------------------------------------------- #

FULL = frozenset(range(24))
TOUCHED = frozenset({0, 1, 10, 11, 12, 15, 21, 22, 23})

# Each entry is (retention target T, loss).  The path survives exactly the
# prunings S <= T, so its support is the complement of T.
TARGETS: List[Tuple[FrozenSet[int], float]] = [
    (frozenset(), 0.0),
    (frozenset({0}), 13.0),
    (frozenset({1}), 12.0),
    (frozenset({10}), 14.0),
    (frozenset({11}), 14.0),
    (frozenset({12}), 57.0),
    (frozenset({15}), 22.0),
    (frozenset({21}), 13.0),
    (frozenset({22}), 3.0),
    (frozenset({23}), 3.0),
    (frozenset({0, 1}), 25.0),
    (frozenset({10, 11}), 40.0),
    (frozenset({12, 15}), 60.0),
    (frozenset({12, 22}), 59.0),
    (frozenset({22, 23}), 42.0),
    (frozenset({21, 22, 23}), 76.0),
    (frozenset({21, 22}), 45.0),
    (frozenset({21, 23}), 45.0),
    (FULL - TOUCHED, 20.0),
    (FULL, 10000.0),
]


def measured_net() -> PrunableNet:
    """The explicit 20-path net whose cost profile is the measured table."""
    return PrunableNet(24, [(FULL - target, loss) for target, loss in TARGETS])


ARMS: List[Tuple[str, Tuple[int, ...]]] = [
    ("tail_22_23", (22, 23)),
    ("bulk_12_15", (12, 15)),
    ("front_0_1", (0, 1)),
    ("mid_10_11", (10, 11)),
    ("cross_22_12", (22, 12)),
    ("triple_21_22_23", (21, 22, 23)),
]


def classify(joint: float, solo_sum: float) -> str:
    if joint > solo_sum + 1e-9:
        return "SUPER-ADDITIVE"
    if joint < solo_sum - 1e-9:
        return "sub-additive"
    return "exactly additive"


# --------------------------------------------------------------------------- #
# 5.  Demonstrations                                                           #
# --------------------------------------------------------------------------- #


def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_ablation_table() -> None:
    banner("1.  The measured ablation table, recomputed as tropical minima")
    net = measured_net()
    print("\n  Solo cost profile (hundredths of an accuracy point):")
    for i in sorted(TOUCHED):
        print(f"      layer {i:>2}:  cost = {net.cost({i}):6.2f}   ({net.cost({i})/100:.4f} pts)")

    header = f"\n  {'arm':<18}{'layers':<14}{'cost':>8}{'sum solo':>10}{'ratio':>8}   class"
    print(header)
    print("  " + "-" * (len(header) - 4))
    for name, layers in ARMS:
        joint = net.cost(layers)
        solo = sum(net.cost({i}) for i in layers)
        ratio = joint / solo if solo else float("inf")
        print(
            f"  {name:<18}{str(layers):<14}{joint:8.2f}{solo:10.2f}{ratio:8.2f}   "
            f"{classify(joint, solo)}"
        )
    print("\n  P1 CONFIRMED: the tail pair has the smallest solo sum (6) and the")
    print("               largest ratio (7x) of any arm.")
    print("  P2 REFUTED  : three arms super-additive, two sub-additive, one additive.")
    print("  P3 CONFIRMED: the triple compounds at 4x and is the costliest arm.")


def demo_epistasis() -> None:
    banner("2.  Epistasis = second-order pure interaction")
    net = measured_net()
    pairs = [(22, 23), (0, 1), (10, 11), (12, 15), (12, 22), (21, 22), (21, 23)]
    print(f"\n  {'pair':<12}{'epi':>8}{'Mobius m(a,b)':>16}   agree?")
    print("  " + "-" * 46)
    for a, b in pairs:
        e = net.epi({a}, {b})
        m = mobius(net.cost, (a, b))
        print(f"  {str((a,b)):<12}{e:8.2f}{m:16.2f}   {abs(e - m) < 1e-9}")
    print("\n  The number an experiment reports as 'joint minus sum of solos' is")
    print("  exactly the degree-2 coefficient of the Mobius decomposition.")


def demo_triple_decomposition() -> None:
    banner("3.  The compounding law for the tail triple:  76 = 19 + 94 - 37")
    net = measured_net()
    a, b, d = 21, 22, 23
    solo = net.cost({a}) + net.cost({b}) + net.cost({d})
    pairwise = net.epi({a}, {b}) + net.epi({a}, {d}) + net.epi({b}, {d})
    third = mobius(net.cost, (a, b, d))
    joint = net.cost((a, b, d))
    print(f"\n  solo sum              = {solo:7.2f}")
    print(f"  sum of 3 epistases    = {pairwise:7.2f}")
    print(f"  third-order term m    = {third:7.2f}")
    print(f"  ------------------------------")
    print(f"  predicted joint cost  = {solo + pairwise + third:7.2f}")
    print(f"  measured  joint cost  = {joint:7.2f}")
    assert abs(solo + pairwise + third - joint) < 1e-9

    print("\n  Full interaction spectrum of the block {21,22,23}:")
    spec = interaction_spectrum(net.cost, (21, 22, 23))
    for A in sorted(spec, key=lambda t: (len(t), t)):
        if A:
            print(f"      order {len(A)}  m({A}) = {spec[A]:7.2f}")
    print("\n  The third-order term is NEGATIVE (-37): the pairwise interactions")
    print("  over-count, so the tail unit SATURATES at width two rather than")
    print("  compounding indefinitely.")


def demo_hitting_set() -> None:
    banner("4.  Expensive  <=>  transversal of the near-optimal path family")
    net = measured_net()
    eps = 3.0
    near = net.near_optimal(eps)
    print(f"\n  Tolerance eps = {eps}.  Near-optimal paths and their supports")
    print("  (shown intersected with the nine measured layers):")
    for j in near:
        supp = sorted(net.paths[j][0] & TOUCHED)
        print(f"      path {j:>2}  loss {net.paths[j][1]:7.2f}   support ∩ measured = {supp}")

    print(f"\n  {'S':<14}{'cost(S)':>9}{'> eps?':>9}{'transversal?':>15}   agree?")
    print("  " + "-" * 60)
    for S in [(22,), (23,), (22, 23), (0, 1), (12,), (12, 15), (21, 22, 23)]:
        c = net.cost(S)
        exp = c > eps + 1e-12
        tr = net.is_transversal(eps, S)
        print(f"  {str(S):<14}{c:9.2f}{str(exp):>9}{str(tr):>15}   {exp == tr}")

    print("\n  Co-adaptation of the tail pair: every near-optimal backup for one")
    print("  member routes through the other.")
    base = net.net_loss(frozenset())
    for x, y in [(22, 23), (23, 22)]:
        wit = [
            j
            for j in near
            if x not in net.paths[j][0] and y in net.paths[j][0]
        ]
        j = wit[0]
        print(
            f"      path {j:>2} (loss {net.paths[j][1]:.2f} <= {base:.2f}+{eps:.0f}) "
            f"avoids layer {x} but routes through layer {y}"
        )


def demo_epistasis_order() -> None:
    banner("5.  The epistasis order is a hypergraph transversal number")
    # The tail subsystem: five retention patterns.
    tail_targets = [
        (frozenset(), 0.0),
        (frozenset({22}), 3.0),
        (frozenset({23}), 3.0),
        (FULL - frozenset({22, 23}), 3.0),
        (FULL, 42.0),
    ]
    tail = PrunableNet(24, [(FULL - t, l) for t, l in tail_targets])
    worst_solo = max(tail.cost({i}) for i in range(24))
    print(f"\n  Tail subsystem: worst single-layer cost   = {worst_solo:.2f}")
    print(f"                  cost of the pair {{22,23}} = {tail.cost((22, 23)):.2f}")
    print(f"                  epistasis order at eps=3  = {tail.epi_order(3.0, max_k=3)}")
    print("\n  No single layer hits every near-optimal path, but {22,23} does:")
    print("  the transversal number is 2, so budgets must be assigned to the")
    print("  PAIR, never to its members.")

    print("\n  Blocks of any width are realizable.  Block profiles on 6 layers:")
    for k in (1, 2, 3, 4):
        block = frozenset(range(k))

        def profile(S: Layers, block: Layers = block) -> float:
            return 10.0 if block <= S else 0.0

        net_k = net_from_profile(6, profile)
        print(
            f"      block of size {k}:  epistasis order at eps=0  = "
            f"{net_k.epi_order(0.0, max_k=k)}"
        )


def demo_representation() -> None:
    banner("6.  Representation: monotone is the ONLY constraint")
    print("\n  (a) Pure epistasis at arbitrary strength: two layers free alone,")
    print("      worth r together.")
    for r in (1.0, 100.0, 10_000.0):

        def pair_profile(S: Layers, r: float = r) -> float:
            return r if {0, 1} <= S else 0.0

        net = net_from_profile(4, pair_profile)
        print(
            f"      r = {r:>9.1f}:  cost{{0}} = {net.cost({0}):.1f}, "
            f"cost{{1}} = {net.cost({1}):.1f}, cost{{0,1}} = {net.cost({0,1}):.1f}, "
            f"epi = {net.epi({0}, {1}):.1f}"
        )
    print("\n      The super-additivity ratio is UNBOUNDED (here it is infinite).")

    print("\n  (b) Sub-additivity: the threshold profile 'any pruning costs 1'.")

    def threshold(S: Layers) -> float:
        return 1.0 if S else 0.0

    net = net_from_profile(4, threshold)
    print(
        f"      cost{{0}} = {net.cost({0}):.1f}, cost{{1}} = {net.cost({1}):.1f}, "
        f"cost{{0,1}} = {net.cost({0,1}):.1f}, epi = {net.epi({0}, {1}):.1f}"
    )

    print("\n  (c) The zero-epistasis null model: modular damage.")
    phi = [0.5, 1.5, 2.5, 3.5]

    def modular(S: Layers) -> float:
        return sum(phi[i] for i in S)

    net = net_from_profile(4, modular)
    worst = max(
        abs(net.epi(S, T))
        for S in (frozenset({0}), frozenset({0, 1}))
        for T in (frozenset({2}), frozenset({3}), frozenset({2, 3}))
    )
    print(f"      largest |epi| over disjoint sets = {worst:.1e}  (i.e. zero)")
    print("      Epistasis is EXACTLY the failure of the landscape to be modular.")


def demo_merge_axiom() -> None:
    banner("7.  The merge axiom: exactly when per-layer budgeting is safe")
    net = measured_net()
    print(f"\n  Measured net mergeable?  {net.is_mergeable()}")
    print("  A single super-additive pair refutes mergeability.  The explicit")
    print("  obstruction from the tail pair:")

    def optimal_survivor(S: Iterable[int]) -> int:
        js = net.survivors(S)
        return min(js, key=lambda j: net.paths[j][1])

    p = optimal_survivor({22})
    q = optimal_survivor({23})
    inter = net.paths[p][0] & net.paths[q][0]
    bound = max(net.paths[p][1], net.paths[q][1])
    refinements = [
        (j, net.paths[j][1]) for j, (s, _) in enumerate(net.paths) if s <= inter
    ]
    print(f"      p = path {p} (loss {net.paths[p][1]:.2f}) is optimal avoiding layer 22")
    print(f"      q = path {q} (loss {net.paths[q][1]:.2f}) is optimal avoiding layer 23")
    print(f"      every route inside supp(p) ∩ supp(q) has loss:")
    for j, l in refinements:
        print(f"          path {j:>2}: loss {l:9.2f}   > max(loss p, loss q) = {bound:.2f}?"
              f"  {l > bound + 1e-12}")
    print("\n      The capability lives precisely in the DISAGREEMENT between two")
    print("      backup routes; no merge recovers it.")

    print("\n  Contrast: a mergeable net.  Take the BOTTLENECK profile on 4 layers,")
    print("  c(S) = max_{i in S} phi(i), whose canonical realization merges any two")
    print("  routes p, q by the route supported on supp(p) ∩ supp(q).")
    phi = [0.5, 1.5, 2.5, 3.5]

    def bottleneck(S: Layers) -> float:
        return max((phi[i] for i in S), default=0.0)

    mrg = net_from_profile(4, bottleneck)
    subsets = [
        frozenset(S)
        for k in range(1, 5)
        for S in combinations(range(4), k)
    ]
    worst_super = max(
        mrg.epi(S, T)
        for S in (frozenset({0}), frozenset({1}))
        for T in (frozenset({2}), frozenset({3}))
    )
    max_bound_ok = all(
        mrg.cost(S | T) <= max(mrg.cost(S), mrg.cost(T)) + 1e-9
        for S in subsets
        for T in subsets
    )
    budget_ok = all(
        mrg.cost(S) <= max(mrg.cost({i}) for i in S) + 1e-9 for S in subsets
    )
    print(f"\n      mergeable?                                        {mrg.is_mergeable()}")
    print(f"      largest epistasis over disjoint pairs           = {worst_super:.1e}")
    print(f"      cost(S ∪ T) <= max(cost S, cost T) for all pairs? {max_bound_ok}")
    print(f"      cost(S) <= max solo cost in S, for ALL 15 subsets? {budget_ok}")
    print("\n      (Under the merge axiom these GLOBAL bounds over the whole Boolean")
    print("       lattice follow from a LOCAL two-path exchange property.  Note the")
    print("       bound is by the MAXIMUM, strictly stronger than sub-additivity:")
    print("       a merely additive/modular profile is NOT mergeable.)")


def main() -> None:
    print(__doc__.split("Run with:")[0].rstrip())
    demo_ablation_table()
    demo_epistasis()
    demo_triple_decomposition()
    demo_hitting_set()
    demo_epistasis_order()
    demo_representation()
    demo_merge_axiom()
    banner("All demonstrations completed.")


if __name__ == "__main__":
    main()
