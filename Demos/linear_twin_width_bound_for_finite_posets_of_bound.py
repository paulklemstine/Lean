"""Assemble PACKAGE.json from the deliverable files and inline code arrays."""
import json
import pathlib

HERE = pathlib.Path(__file__).parent


def read(name: str) -> str:
    return (HERE / name).read_text()


article = read("ARTICLE.md")
paper_md = read("RESEARCH_PAPER.md")
paper_tex = read("RESEARCH_PAPER.tex")
demo_py = read("demo.py")
viz_bands = read("visualize_bands.py")
viz_bound = read("visualize_bound.py")
interactive_html = read("interactive.html")

# ---- Algorithm code snippets (self-contained, type-hinted) ---------------- #
ALG_POSTYPE = '''from typing import Callable, List, Sequence

Leq = Callable[[int, int], bool]
ABOVE, INCOMP, BELOW, EQ = "Above", "Incomp", "Below", "Eq"


def pos_type(leq: Leq, x: int, c: int) -> str:
    """Position type of chain element c relative to observer x (Definition 2.7)."""
    if x == c:
        return EQ
    if c != x and leq(c, x):
        return ABOVE
    if x != c and leq(x, c):
        return BELOW
    return INCOMP


def pos_type_sequence(leq: Leq, x: int, sorted_chain: Sequence[int]) -> List[str]:
    """Position types of x along a chain already sorted bottom -> top."""
    return [pos_type(leq, x, c) for c in sorted_chain]
'''

ALG_NBHD = '''from typing import Callable, List, Sequence

Leq = Callable[[int, int], bool]


def pos_type(leq: Leq, x: int, c: int) -> str:
    if x == c:
        return "Eq"
    if leq(c, x):
        return "Above"
    if leq(x, c):
        return "Below"
    return "Incomp"


def transition_count(seq: Sequence[str]) -> int:
    """Changes between consecutive principal types; <= 2 by posType_mono + incomp_ord_convex."""
    principal: List[str] = [s for s in seq if s != "Eq"]
    return sum(1 for i in range(len(principal) - 1) if principal[i] != principal[i + 1])


def neighbourhood_type_count(leq: Leq, x: int,
                             cover: Sequence[Sequence[int]]) -> int:
    """
    Distinct red neighbourhood types of x under a chain cover:
    (sum of per-chain transitions) + 1 self/diagonal boundary.
    Theorem nbhdTypeCount_le: result <= 2*len(cover) + 1.
    """
    total = sum(transition_count([pos_type(leq, x, c) for c in ch]) for ch in cover)
    return total + 1
'''

ALG_CONVEX = '''from typing import Sequence


def incomp_is_interval(seq: Sequence[str]) -> bool:
    """
    Verify incomp_ord_convex: the Incomp entries of a position-type sequence
    form one contiguous block (a single order-interval of the chain).
    """
    idx = [i for i, s in enumerate(seq) if s == "Incomp"]
    if not idx:
        return True
    return idx == list(range(idx[0], idx[-1] + 1))
'''

ALG_DILWORTH = '''from typing import Callable, Dict, List, Sequence

Leq = Callable[[int, int], bool]


def width_via_dilworth(leq: Leq, elements: Sequence[int]) -> int:
    """
    Width (largest antichain) in polynomial time via Dilworth:
    width = |P| - (maximum matching of the bipartite graph with edges a < b).
    The pigeonhole bound antichain_card_le_chains is the easy converse:
    any antichain meets each chain at most once, so |A| <= (#chains).
    """
    elems: List[int] = list(elements)
    adj: Dict[int, List[int]] = {
        a: [b for b in elems if a != b and leq(a, b)] for a in elems
    }
    match_right: Dict[int, int] = {}

    def augment(a: int, seen: set) -> bool:
        for b in adj[a]:
            if b in seen:
                continue
            seen.add(b)
            if b not in match_right or augment(match_right[b], seen):
                match_right[b] = a
                return True
        return False

    matching = sum(1 for a in elems if augment(a, set()))
    return len(elems) - matching
'''

# ---- Demo code snippets (each exercises the MAIN theorem) ----------------- #
DEMO_PARALLEL = '''from typing import Callable, List, Sequence
from itertools import combinations

Leq = Callable[[int, int], bool]


def lt(leq: Leq, a: int, b: int) -> bool:
    return a != b and leq(a, b)


def pos_type(leq: Leq, x: int, c: int) -> str:
    if x == c:
        return "Eq"
    if lt(leq, c, x):
        return "Above"
    if lt(leq, x, c):
        return "Below"
    return "Incomp"


def transitions(seq: Sequence[str]) -> int:
    p = [s for s in seq if s != "Eq"]
    return sum(1 for i in range(len(p) - 1) if p[i] != p[i + 1])


def nbhd_count(leq: Leq, x: int, cover: Sequence[Sequence[int]]) -> int:
    return 1 + sum(transitions([pos_type(leq, x, c) for c in ch]) for ch in cover)


def parallel_chains(k: int, length: int):
    elements = list(range(k * length))

    def leq(a: int, b: int) -> bool:
        ca, pa = divmod(a, length)
        cb, pb = divmod(b, length)
        return ca == cb and pa <= pb

    cover = [[c * length + p for p in range(length)] for c in range(k)]
    return elements, leq, cover


def main() -> None:
    print("k | width | max nbhd types | 2k+1 | OK")
    for k in range(1, 8):
        elements, leq, cover = parallel_chains(k, length=9)
        worst = max(nbhd_count(leq, x, cover) for x in elements)
        bound = 2 * k + 1
        print(f"{k} | {k:5d} | {worst:14d} | {bound:4d} | {worst <= bound}")


if __name__ == "__main__":
    main()
'''

DEMO_DIVISIBILITY = '''from typing import Callable, List, Sequence

Leq = Callable[[int, int], bool]


def lt(leq: Leq, a: int, b: int) -> bool:
    return a != b and leq(a, b)


def sort_chain(leq: Leq, c: Sequence[int]) -> List[int]:
    out: List[int] = []
    for x in c:
        i = 0
        while i < len(out) and leq(out[i], x):
            i += 1
        out.insert(i, x)
    return out


def pos_type(leq: Leq, x: int, c: int) -> str:
    if x == c:
        return "Eq"
    if lt(leq, c, x):
        return "Above"
    if lt(leq, x, c):
        return "Below"
    return "Incomp"


def transitions(seq: Sequence[str]) -> int:
    p = [s for s in seq if s != "Eq"]
    return sum(1 for i in range(len(p) - 1) if p[i] != p[i + 1])


def greedy_cover(leq: Leq, elements: Sequence[int]) -> List[List[int]]:
    remaining = list(elements)
    cover: List[List[int]] = []
    while remaining:
        chain, rest, cur = [], [], None
        for x in sort_chain(leq, remaining):
            if cur is None or leq(cur, x):
                chain.append(x); cur = x
            else:
                rest.append(x)
        cover.append(chain); remaining = rest
    return cover


def main() -> None:
    """Divisibility poset on {1..n}: greedy chain cover vs. 2k+1 ceiling."""
    for n in (8, 12, 16, 20, 30):
        elements = list(range(1, n + 1))
        leq = lambda a, b: b % a == 0
        cover = greedy_cover(leq, elements)
        k = len(cover)
        worst = max(
            1 + sum(transitions([pos_type(leq, x, c) for c in ch]) for ch in cover)
            for x in elements
        )
        print(f"n={n:2d}  chains k={k:2d}  max nbhd types={worst:2d}  2k+1={2*k+1:2d}  "
              f"OK={worst <= 2*k + 1}")


if __name__ == "__main__":
    main()
'''

DEMO_PIGEONHOLE = '''from typing import Callable, Dict, List, Sequence
from itertools import combinations

Leq = Callable[[int, int], bool]


def incomparable(leq: Leq, a: int, b: int) -> bool:
    return not leq(a, b) and not leq(b, a)


def is_antichain(leq: Leq, a: Sequence[int]) -> bool:
    return all(incomparable(leq, x, y) for x, y in combinations(a, 2))


def width_via_dilworth(leq: Leq, elements: Sequence[int]) -> int:
    elems = list(elements)
    adj: Dict[int, List[int]] = {a: [b for b in elems if a != b and leq(a, b)] for a in elems}
    match_right: Dict[int, int] = {}

    def augment(a: int, seen: set) -> bool:
        for b in adj[a]:
            if b in seen:
                continue
            seen.add(b)
            if b not in match_right or augment(match_right[b], seen):
                match_right[b] = a
                return True
        return False

    return len(elems) - sum(1 for a in elems if augment(a, set()))


def main() -> None:
    """antichain_card_le_chains: a k-chain cover forces every antichain to have size <= k."""
    length = 5
    for k in range(1, 7):
        elements = list(range(k * length))
        leq = lambda a, b: (a // length == b // length) and (a % length <= b % length)
        cover = [[c * length + p for p in range(length)] for c in range(k)]
        antichain = [ch[length // 2] for ch in cover]
        width = width_via_dilworth(leq, elements)
        meets_once = all(len([a for a in antichain if a in set(ch)]) <= 1 for ch in cover)
        print(f"k={k}: |A|={len(antichain)} <= k, antichain={is_antichain(leq, antichain)}, "
              f"meets-each-chain-once={meets_once}, width={width} <= k={width <= k}")


if __name__ == "__main__":
    main()
'''

PSEUDO_NBHD = """Input: poset relation leq, element x, chain cover {C_1,...,C_k}
Output: number of distinct red neighbourhood types of x (asserted <= 2k+1)

1. total <- 0
2. for each chain C_j in the cover:
3.     S <- sort C_j from bottom to top under leq
4.     types <- [ posType_x(c) for c in S ]          # Above / Incomp / Below / Eq
5.     drop Eq markers from types
6.     t_j <- number of indices i with types[i] != types[i+1]   # transitions
7.     assert t_j <= 2                                 # posType_mono + incomp_ord_convex
8.     total <- total + t_j
9. return total + 1                                    # +1 self/diagonal boundary"""

PSEUDO_POSTYPE = """Input: poset relation leq, element x, chain element c
Output: posType_x(c) in {Above, Incomp, Below, Eq}

1. if x == c: return Eq
2. if leq(c, x): return Above        # c < x
3. if leq(x, c): return Below        # x < c
4. return Incomp                     # x incomparable to c"""

PSEUDO_CONVEX = """Input: position-type sequence seq along a sorted chain
Output: True iff the Incomp entries form a single interval (incomp_ord_convex)

1. idx <- [ i : seq[i] == Incomp ]
2. if idx is empty: return True
3. return idx == [idx.first, idx.first+1, ..., idx.last]"""

PSEUDO_DILWORTH = """Input: poset relation leq, element list P
Output: width(P) = size of largest antichain

1. build bipartite graph G: left=P, right=P, edge (a,b) iff a < b
2. M <- maximum matching of G via augmenting paths
3. return |P| - |M|        # Dilworth: min chain cover = width
# Easy converse (antichain_card_le_chains): for any chain cover of size k,
# every antichain meets each chain at most once, hence has size <= k."""

future_directions = """# Future Directions — Twin-width of bounded-width posets

This cycle established the static linear neighbourhood-type bound
(nbhdTypeCount_le: <= 2k+1 red neighbourhood types per element under a k-chain
cover) and the pigeonhole link antichain_card_le_chains (a k-chain cover forces
width <= k). The threshold monotonicity posType_mono is the reusable engine. The
conjectures below extend these findings.

## C1. Dynamic twin-width bound via the chain-interval contraction
Conjecture. For a finite poset covered by k chains there is a contraction
sequence (merging two parts at a time, each intermediate partition consisting of
order-intervals of the chains) along which the red degree of every part stays
<= 2k+1; hence twin-width <= 2k+1.
The key insight is that posType_mono makes every part's red interactions with any
other chain a monotone boundary phenomenon, so merging intervals bottom-up never
lets more than two red boundaries per chain coexist at a part.
Why now? The static 2k+1 bound (nbhdTypeCount_le) is already formalized; only the
bookkeeping of a concrete merge order on List-encoded chains remains, which is a
finite-induction task well suited to the present infrastructure.

## C2. Full Dilworth as the hypothesis-discharger
Conjecture. Every finite poset of width <= k admits a labelling
chainIdx : a -> Fin k with comparable label classes (the deep direction of
Dilworth), so the hypotheses of nbhdTypeCount_le follow from "width <= k" alone.
The key insight is that antichain_card_le_chains is the trivial converse, so the
missing content is exactly Konig/augmenting-path matching on the incomparability
bipartite graph.
Why now? IsAntichain/IsChain are already wired in; a Hall/Konig lemma in Mathlib
could be lifted to close the gap and make the twin-width statement depend only on
the antichain-width hypothesis.

## C3. Lower bound: posets of width k with twin-width Omega(k)
Conjecture. There is a family of width-k posets whose strict-order digraph has
twin-width >= c*k for an absolute c > 0, so the linear dependence on k is
unavoidable.
The key insight is that k "interleaved" chains force every contraction to keep
Theta(k) simultaneously-mixed boundaries, the dynamic shadow of the tight
changeCount = 2 example in ComputationalEvidence.md.
Why now? The tightness witness for the per-chain <= 2 bound is already isolated;
promoting it to a global lower bound is the natural adversarial sequel.

## C4. From posets to comparability/incomparability graphs
Conjecture. The undirected incomparability graph of a width-k poset has bounded
twin-width (function of k only), matching the directed bound up to a constant.
The key insight is that incomp_ord_convex shows the incomparable region of each
chain relative to any vertex is a single interval, so the same monotone boundary
count controls the undirected red degree.
Why now? incomp_ord_convex is proved; reusing it for the undirected setting is a
direct corollary."""

lean_proofs = """-- Concept: Linear twin-width bound for finite posets of bounded width
-- Catalog/Geometry/TwinWidthPosets (order theory / structural graph parameters)
--
-- The formalized results (statements; see project Lean sources for full proofs):
--
-- posType_mono :
--   Along any chain C, for a fixed x the predicate (c < x) is downward closed and
--   (x < c) is upward closed in c; the position type of x along C is monotone in
--   the order Above < Incomp < Below.
--
-- incomp_ord_convex :
--   For a fixed x and chain C, { c in C | x is incomparable to c } is order-convex
--   (a single interval of C).
--
-- antichain_card_le_chains :
--   If a finite poset is covered by k chains, every antichain has cardinality <= k
--   (the easy / pigeonhole direction of Dilworth's theorem); hence width <= k.
--
-- nbhdTypeCount_le  (main static bound) :
--   Under a cover of a finite poset by k chains, every element exhibits at most
--   2*k + 1 distinct red neighbourhood types induced by the strict order relation.
--
-- These give the uniform, element-wise red-degree ceiling 2*k+1, the static
-- prerequisite for the conjectured twin-width <= 2*k+1 (Future Direction C1)."""

package = {
    "title": "Linear Twin-Width Bound for Finite Posets of Bounded Width",
    "domain": "Geometry",
    "description": (
        "We prove the static combinatorial core of a linear bound on the twin-width "
        "of a finite poset's strict-order digraph: under a cover by k chains every "
        "element exhibits at most 2k+1 red neighbourhood types, and a k-chain cover "
        "forces width at most k."
    ),
    "authors": ["Aristotle"],
    "date": "2026-06-21",
    "key_results": [
        "nbhdTypeCount_le: under a k-chain cover each element has at most 2k+1 red neighbourhood types induced by the strict order",
        "antichain_card_le_chains: a k-chain cover forces every antichain to have size at most k (pigeonhole direction of Dilworth)",
        "posType_mono: an element's position type along any chain is monotone (Above downward closed, Below upward closed)",
        "incomp_ord_convex: the set of chain elements incomparable to a fixed vertex is order-convex (a single interval)",
    ],
    "keywords": [
        "twin-width", "poset", "antichain", "chain cover", "width",
        "Dilworth", "order-convex", "red degree", "contraction sequence",
    ],
    "article": article,
    "research_paper": paper_md,
    "research_paper_tex": paper_tex,
    "demo": demo_py,
    "demos": [
        {
            "name": "Uniform 2k+1 Neighbourhood-Type Ceiling on Parallel-Chain Posets",
            "description": (
                "Builds the family of k mutually incomparable chains (width exactly k) "
                "for k = 1..7 and measures, for every element, the number of distinct "
                "red neighbourhood types induced by the strict order. Confirms the main "
                "theorem nbhdTypeCount_le: the measured maximum never exceeds 2k+1, "
                "independently of chain length."
            ),
            "code": DEMO_PARALLEL,
        },
        {
            "name": "Divisibility-Lattice Stress Test of the Neighbourhood-Type Bound",
            "description": (
                "Takes the divisibility poset on {1,...,n} for several n, builds a greedy "
                "chain cover of size k, and verifies that the maximum red neighbourhood-type "
                "count over all elements stays within the 2k+1 ceiling of nbhdTypeCount_le "
                "on a genuinely non-trivial, non-uniform poset."
            ),
            "code": DEMO_DIVISIBILITY,
        },
        {
            "name": "Pigeonhole Width Certificate via Chain Covers",
            "description": (
                "Demonstrates antichain_card_le_chains: for parallel-chain posets it "
                "exhibits a maximum antichain (one element per chain), checks that it meets "
                "each chain at most once, and confirms width = k via a Dilworth bipartite "
                "matching, so |A| <= k for every antichain."
            ),
            "code": DEMO_PIGEONHOLE,
        },
    ],
    "algorithms": [
        {
            "name": "Position-Type Classification of a Chain Element Relative to an Observer",
            "description": (
                "Computes posType_x(c) in {Above, Incomp, Below, Eq} for an observer x and a "
                "chain element c using the four mutually exclusive comparability cases of "
                "Definition 2.7. Foundational primitive for every other routine; O(1) "
                "comparisons per element, O(m) for a length-m chain."
            ),
            "pseudocode": PSEUDO_POSTYPE,
            "code": ALG_POSTYPE,
        },
        {
            "name": "Red Neighbourhood-Type Counting and the 2k+1 Verification",
            "description": (
                "Realizes the main theorem nbhdTypeCount_le. For each chain it counts the "
                "principal-type transitions (bounded by 2 thanks to posType_mono and "
                "incomp_ord_convex), sums over the k chains, and adds one for the self/diagonal "
                "boundary, yielding a value provably <= 2k+1. Complexity O(|P|) per element."
            ),
            "pseudocode": PSEUDO_NBHD,
            "code": ALG_NBHD,
        },
        {
            "name": "Order-Convexity Check of the Incomparable Region",
            "description": (
                "Verifies incomp_ord_convex by confirming that the Incomp entries of a "
                "position-type sequence form a single contiguous block, i.e. a single "
                "order-interval of the chain. Complexity O(m) for a length-m chain."
            ),
            "pseudocode": PSEUDO_CONVEX,
            "code": ALG_CONVEX,
        },
        {
            "name": "Poset Width via Dilworth Bipartite Matching",
            "description": (
                "Computes the width (largest antichain) in polynomial time as |P| minus a "
                "maximum bipartite matching of the strict relation, by Dilworth's theorem. "
                "The easy converse antichain_card_le_chains certifies width <= (number of "
                "chains). Complexity O(|P| * |E|) via augmenting paths."
            ),
            "pseudocode": PSEUDO_DILWORTH,
            "code": ALG_DILWORTH,
        },
    ],
    "visualizations": [
        {
            "name": "Above / Incomparable / Below Banding of a Chain",
            "description": (
                "Colours each element of a chain by its position type relative to an observer, "
                "making visible the monotone march (posType_mono) and the single grey "
                "incomparable block (incomp_ord_convex): blue Above, grey Incomp, red Below."
            ),
            "code": viz_bands,
        },
        {
            "name": "Linear 2k+1 Ceiling versus Measured Neighbourhood-Type Count",
            "description": (
                "Plots the 2k+1 ceiling against the measured maximum red neighbourhood-type "
                "count on parallel-chain posets for k = 1..10, illustrating that the bound "
                "of nbhdTypeCount_le holds with room to spare."
            ),
            "code": viz_bound,
        },
    ],
    "interactive_demos": [
        {
            "title": "Bounded-Width Poset Twin-Width Explorer",
            "description": (
                "An interactive widget to build k parallel chains, place an observer, and watch "
                "the Above/Incomparable/Below banding update live. It displays the per-chain "
                "transition count, the total red neighbourhood-type count, and the 2k+1 ceiling, "
                "letting users confirm nbhdTypeCount_le and the pigeonhole width bound by hand."
            ),
            "html": interactive_html,
        },
    ],
    "lean_proofs": lean_proofs,
    "future_directions": future_directions,
    "modules": {"demo": demo_py},
    "lean_files": ["Catalog/Geometry/TwinWidthPosets/TwinWidthPosets.lean"],
}

out = HERE / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n")
print("wrote", out, "size", out.stat().st_size)


"""
Numerical demonstrations for:

    "A Linear Neighbourhood-Type Bound Toward Twin-Width of Bounded-Width Posets"

Every routine is self-contained (only the Python standard library is used) and
exercises one of the four results from the paper:

    posType_mono            -- threshold monotonicity along a chain
    incomp_ord_convex       -- the incomparable region is a single interval
    nbhdTypeCount_le        -- <= 2k+1 red neighbourhood types per element
    antichain_card_le_chains-- a k-chain cover forces every antichain to have size <= k

A finite poset is represented as a pair (elements, leq) where ``leq(a, b)`` is
True iff a <= b.  We only assume reflexivity, antisymmetry and transitivity.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, Dict, List, Sequence, Tuple

Elem = int
Leq = Callable[[Elem, Elem], bool]

# Position-type labels, ordered Above < Incomp < Below (Eq treated as a boundary).
ABOVE, INCOMP, BELOW, EQ = "Above", "Incomp", "Below", "Eq"


# --------------------------------------------------------------------------- #
#  Core poset utilities
# --------------------------------------------------------------------------- #
def lt(leq: Leq, a: Elem, b: Elem) -> bool:
    """Strict order a < b."""
    return a != b and leq(a, b)


def incomparable(leq: Leq, a: Elem, b: Elem) -> bool:
    """a is incomparable to b: neither a <= b nor b <= a."""
    return not leq(a, b) and not leq(b, a)


def is_chain(leq: Leq, c: Sequence[Elem]) -> bool:
    """True iff every pair in c is comparable."""
    return all(leq(a, b) or leq(b, a) for a, b in combinations(c, 2))


def is_antichain(leq: Leq, a: Sequence[Elem]) -> bool:
    """True iff every distinct pair in a is incomparable."""
    return all(incomparable(leq, x, y) for x, y in combinations(a, 2))


def sort_chain(leq: Leq, c: Sequence[Elem]) -> List[Elem]:
    """Return the chain sorted from bottom to top (insertion sort under <=)."""
    out: List[Elem] = []
    for x in c:
        i = 0
        while i < len(out) and leq(out[i], x):
            i += 1
        out.insert(i, x)
    return out


def pos_type(leq: Leq, x: Elem, c: Elem) -> str:
    """Position type of chain element c relative to the observer x."""
    if x == c:
        return EQ
    if lt(leq, c, x):
        return ABOVE
    if lt(leq, x, c):
        return BELOW
    return INCOMP


# --------------------------------------------------------------------------- #
#  Algorithm A + the monotonicity / convexity checks
# --------------------------------------------------------------------------- #
def pos_type_sequence(leq: Leq, x: Elem, chain: Sequence[Elem]) -> List[str]:
    """Position types of x along a chain, sorted bottom to top."""
    return [pos_type(leq, x, c) for c in sort_chain(leq, chain)]


def is_monotone_sequence(seq: Sequence[str]) -> bool:
    """
    Verify posType_mono: the sequence is Above* (Eq?) Incomp* (Eq?) Below*,
    i.e. once it leaves Above it never returns, and once it reaches Below it
    stays.  We check it is non-decreasing in the rank Above<Incomp<Below,
    treating Eq as a boundary marker compatible with its neighbours.
    """
    rank = {ABOVE: 0, EQ: 1, INCOMP: 1, BELOW: 2}
    ranks = [rank[s] for s in seq]
    return all(ranks[i] <= ranks[i + 1] for i in range(len(ranks) - 1))


def incomp_is_interval(seq: Sequence[str]) -> bool:
    """Verify incomp_ord_convex: the Incomp entries form one contiguous block."""
    idx = [i for i, s in enumerate(seq) if s == INCOMP]
    if not idx:
        return True
    return idx == list(range(idx[0], idx[-1] + 1))


def transition_count(seq: Sequence[str]) -> int:
    """Number of changes between consecutive principal types (Eq merged into a neighbour)."""
    principal = [s for s in seq if s != EQ]
    return sum(1 for i in range(len(principal) - 1) if principal[i] != principal[i + 1])


# --------------------------------------------------------------------------- #
#  Algorithm B: the 2k+1 neighbourhood-type bound (nbhdTypeCount_le)
# --------------------------------------------------------------------------- #
def neighbourhood_type_count(
    leq: Leq, x: Elem, cover: Sequence[Sequence[Elem]]
) -> int:
    """
    Distinct red neighbourhood types of x under a chain cover:
    (sum of per-chain transition points) + 1 for the self/diagonal boundary.
    Theorem nbhdTypeCount_le asserts this is <= 2*len(cover) + 1.
    """
    total = sum(transition_count(pos_type_sequence(leq, x, ch)) for ch in cover)
    return total + 1


# --------------------------------------------------------------------------- #
#  Algorithm D: pigeonhole width bound (antichain_card_le_chains)
# --------------------------------------------------------------------------- #
def max_antichain_size(leq: Leq, elements: Sequence[Elem]) -> int:
    """
    Largest antichain = width, computed in polynomial time via Dilworth's
    theorem: width = |P| - (maximum matching in the bipartite graph whose edges
    are the strict relations a < b).  The minimum chain cover has size
    |P| - matching, and by Dilworth equals the width.
    """
    elems = list(elements)
    # Bipartite graph: left copy -> right copy, edge a~b iff a < b.
    adj: Dict[Elem, List[Elem]] = {
        a: [b for b in elems if lt(leq, a, b)] for a in elems
    }
    match_right: Dict[Elem, Elem] = {}

    def augment(a: Elem, seen: set) -> bool:
        for b in adj[a]:
            if b in seen:
                continue
            seen.add(b)
            if b not in match_right or augment(match_right[b], seen):
                match_right[b] = a
                return True
        return False

    matching = sum(1 for a in elems if augment(a, set()))
    return len(elems) - matching


def antichain_meets_each_chain_once(
    leq: Leq, antichain: Sequence[Elem], cover: Sequence[Sequence[Elem]]
) -> bool:
    """The pigeonhole core: |A ∩ C_j| <= 1 for each chain C_j."""
    return all(
        len([a for a in antichain if a in set(ch)]) <= 1 for ch in cover
    )


# --------------------------------------------------------------------------- #
#  Example poset builders
# --------------------------------------------------------------------------- #
def parallel_chains(k: int, length: int) -> Tuple[List[Elem], Leq, List[List[Elem]]]:
    """
    k disjoint chains of given length, mutually incomparable.
    Element id = chain_index * length + position.  Width = k.
    """
    elements = list(range(k * length))

    def leq(a: Elem, b: Elem) -> bool:
        ca, pa = divmod(a, length)
        cb, pb = divmod(b, length)
        return ca == cb and pa <= pb

    cover = [[c * length + p for p in range(length)] for c in range(k)]
    return elements, leq, cover


def divisibility_poset(n: int) -> Tuple[List[Elem], Leq]:
    """Divisibility order on {1, ..., n}: a <= b iff a divides b."""
    elements = list(range(1, n + 1))

    def leq(a: Elem, b: Elem) -> bool:
        return b % a == 0

    return elements, leq


def greedy_chain_cover(leq: Leq, elements: Sequence[Elem]) -> List[List[Elem]]:
    """A simple greedy chain cover (not necessarily minimum)."""
    remaining = list(elements)
    cover: List[List[Elem]] = []
    while remaining:
        chain: List[Elem] = []
        rest: List[Elem] = []
        cur = None
        for x in sort_chain(leq, remaining):
            if cur is None or leq(cur, x):
                chain.append(x)
                cur = x
            else:
                rest.append(x)
        cover.append(chain)
        remaining = rest
    return cover


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_parallel_chains() -> None:
    print("=" * 72)
    print("DEMO 1  Parallel-chain posets: nbhdTypeCount_le and width = k")
    print("=" * 72)
    for k in range(1, 6):
        elements, leq, cover = parallel_chains(k, length=7)
        bound = 2 * k + 1
        worst = max(neighbourhood_type_count(leq, x, cover) for x in elements)
        width = max_antichain_size(leq, elements)
        ok = worst <= bound and width <= k
        print(
            f"k={k}: width={width} (<= {k}), "
            f"max nbhd types={worst} (<= 2k+1={bound})  "
            f"[{'OK' if ok else 'FAIL'}]"
        )
    print()


def demo_monotone_and_convex() -> None:
    print("=" * 72)
    print("DEMO 2  posType_mono and incomp_ord_convex on a mixed poset")
    print("=" * 72)
    # A 'fence-like' chain plus an outside observer to force Above/Incomp/Below.
    # Elements 0<1<2<3<4 form a chain; observer x sits above 0,1, beside 2, below 3,4.
    chain = [0, 1, 2, 3, 4]
    x = 99

    def leq(a: Elem, b: Elem) -> bool:
        if a == b:
            return True
        if a in chain and b in chain:
            return a <= b
        # observer x relates: 0<x, 1<x, x||2, x<3, x<4
        rel = {(0, x): True, (1, x): True, (x, 3): True, (x, 4): True}
        return rel.get((a, b), False)

    seq = pos_type_sequence(leq, x, chain)
    print(f"position-type sequence along chain: {seq}")
    print(f"posType_mono  (monotone non-decreasing): {is_monotone_sequence(seq)}")
    print(f"incomp_ord_convex (single Incomp block): {incomp_is_interval(seq)}")
    print(f"transition points (<= 2): {transition_count(seq)}")
    print()


def demo_divisibility() -> None:
    print("=" * 72)
    print("DEMO 3  Divisibility poset on {1,...,n}: greedy cover vs. bound")
    print("=" * 72)
    for n in (8, 12, 16, 20):
        elements, leq = divisibility_poset(n)
        cover = greedy_chain_cover(leq, elements)
        k = len(cover)
        bound = 2 * k + 1
        worst = max(neighbourhood_type_count(leq, x, cover) for x in elements)
        width = max_antichain_size(leq, elements)
        # Verify every per-chain sequence is monotone with a single incomp block.
        structural = all(
            is_monotone_sequence(pos_type_sequence(leq, x, ch))
            and incomp_is_interval(pos_type_sequence(leq, x, ch))
            for x in elements
            for ch in cover
        )
        print(
            f"n={n:2d}: chains used k={k}, width={width}, "
            f"max nbhd types={worst} (<= {bound}), "
            f"structure-OK={structural}  "
            f"[{'OK' if worst <= bound and structural else 'FAIL'}]"
        )
    print()


def demo_pigeonhole() -> None:
    print("=" * 72)
    print("DEMO 4  antichain_card_le_chains: |A| <= k via pigeonhole")
    print("=" * 72)
    elements, leq, cover = parallel_chains(k=4, length=5)
    k = len(cover)
    width = max_antichain_size(leq, elements)
    # Exhibit a maximum antichain (one element from each chain) and verify pigeonhole.
    antichain = [ch[2] for ch in cover]  # middle element of each chain
    print(f"chain cover size k = {k}")
    print(f"sample antichain = {antichain}, is_antichain = {is_antichain(leq, antichain)}")
    print(f"|A| = {len(antichain)} <= k = {k}: {len(antichain) <= k}")
    print(f"|A ∩ C_j| <= 1 for all j: {antichain_meets_each_chain_once(leq, antichain, cover)}")
    print(f"max antichain size (= width) = {width} <= k = {k}: {width <= k}")
    print()


def main() -> None:
    demo_parallel_chains()
    demo_monotone_and_convex()
    demo_divisibility()
    demo_pigeonhole()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()


"""
Visualization: the Above / Incomparable / Below banding of a chain seen from an
observer x, illustrating posType_mono and incomp_ord_convex (two thresholds, one
incomparable block).  Produces 'twinwidth_bands.png'.
"""
from __future__ import annotations

from typing import Callable, List

import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

Leq = Callable[[int, int], bool]
ABOVE, INCOMP, BELOW = "Above", "Incomp", "Below"
COLOR = {ABOVE: "#1f77b4", INCOMP: "#bdbdbd", BELOW: "#d62728"}


def pos_type(leq: Leq, x: int, c: int) -> str:
    if c != x and leq(c, x):
        return ABOVE
    if c != x and leq(x, c):
        return BELOW
    return INCOMP


def main() -> None:
    chain: List[int] = list(range(12))  # 0 < 1 < ... < 11
    x = 99

    def leq(a: int, b: int) -> bool:
        if a == b:
            return True
        if a in chain and b in chain:
            return a <= b
        # observer above 0..3, incomparable to 4..7, below 8..11
        if b == x:
            return a in (0, 1, 2, 3)
        if a == x:
            return b in (8, 9, 10, 11)
        return False

    seq = [pos_type(leq, x, c) for c in chain]
    fig, ax = plt.subplots(figsize=(10, 2.4))
    for i, t in enumerate(seq):
        ax.add_patch(Rectangle((i, 0), 1, 1, color=COLOR[t]))
        ax.text(i + 0.5, 0.5, str(i), ha="center", va="center", color="white")
    ax.set_xlim(0, len(chain))
    ax.set_ylim(0, 1)
    ax.set_yticks([])
    ax.set_xlabel("chain elements, bottom -> top")
    ax.set_title("Observer's view of a chain: Above (blue) | Incomp (grey) | Below (red)")
    handles = [Rectangle((0, 0), 1, 1, color=COLOR[t]) for t in (ABOVE, INCOMP, BELOW)]
    ax.legend(handles, [ABOVE, INCOMP, BELOW], loc="upper center",
              bbox_to_anchor=(0.5, -0.3), ncol=3)
    fig.tight_layout()
    fig.savefig("twinwidth_bands.png", dpi=150, bbox_inches="tight")
    print("wrote twinwidth_bands.png")


if __name__ == "__main__":
    main()


"""
Visualization: the linear ceiling 2k+1 versus the actual maximum neighbourhood-type
count measured on parallel-chain posets of width k.  Produces 'twinwidth_bound.png'.
"""
from __future__ import annotations

from typing import Callable, List, Sequence

import matplotlib.pyplot as plt

Leq = Callable[[int, int], bool]


def lt(leq: Leq, a: int, b: int) -> bool:
    return a != b and leq(a, b)


def pos_type(leq: Leq, x: int, c: int) -> str:
    if x == c:
        return "Eq"
    if lt(leq, c, x):
        return "Above"
    if lt(leq, x, c):
        return "Below"
    return "Incomp"


def transition_count(seq: Sequence[str]) -> int:
    p = [s for s in seq if s != "Eq"]
    return sum(1 for i in range(len(p) - 1) if p[i] != p[i + 1])


def nbhd_count(leq: Leq, x: int, cover: Sequence[Sequence[int]]) -> int:
    return 1 + sum(transition_count([pos_type(leq, x, c) for c in ch]) for ch in cover)


def parallel(k: int, length: int):
    elements = list(range(k * length))

    def leq(a: int, b: int) -> bool:
        ca, pa = divmod(a, length)
        cb, pb = divmod(b, length)
        return ca == cb and pa <= pb

    cover = [[c * length + p for p in range(length)] for c in range(k)]
    return elements, leq, cover


def main() -> None:
    ks: List[int] = list(range(1, 11))
    bound = [2 * k + 1 for k in ks]
    actual: List[int] = []
    for k in ks:
        elements, leq, cover = parallel(k, length=9)
        actual.append(max(nbhd_count(leq, x, cover) for x in elements))

    fig, ax = plt.subplots(figsize=(7, 4.5))
    ax.plot(ks, bound, "o-", label="2k+1 ceiling (nbhdTypeCount_le)")
    ax.plot(ks, actual, "s--", label="measured max neighbourhood-type count")
    ax.fill_between(ks, actual, bound, alpha=0.1)
    ax.set_xlabel("width k (number of chains)")
    ax.set_ylabel("red neighbourhood types per element")
    ax.set_title("Linear ceiling on red neighbourhood types of bounded-width posets")
    ax.legend()
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("twinwidth_bound.png", dpi=150)
    print("wrote twinwidth_bound.png")


if __name__ == "__main__":
    main()
