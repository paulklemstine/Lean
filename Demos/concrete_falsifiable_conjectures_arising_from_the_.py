"""Backtracking detection of weak and strong copies of the Boolean lattice B_d."""

from __future__ import annotations

from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence


def popcount(x: int) -> int:
    """Cardinality of the set encoded by the bitmask ``x``."""
    return bin(x).count("1")


def subset(x: int, y: int) -> bool:
    """Containment of bitmask-encoded sets."""
    return x & ~y == 0


def strict_subset(x: int, y: int) -> bool:
    """Strict containment of bitmask-encoded sets."""
    return x != y and subset(x, y)


def boolean_lattice(d: int) -> List[int]:
    """The elements of B_d, listed along a linear extension (by cardinality)."""
    return sorted(range(1 << d), key=popcount)


def _search(
    lattice: Sequence[int],
    family: Sequence[int],
    strong: bool,
    idx: int,
    assign: Dict[int, int],
    used: FrozenSet[int],
) -> Optional[Dict[int, int]]:
    """Depth-first assignment of family members to lattice elements."""
    if idx == len(lattice):
        return dict(assign)
    p = lattice[idx]
    for A in family:
        if A in used:
            continue
        ok = True
        for q, B in assign.items():
            if strict_subset(q, p) and not strict_subset(B, A):
                ok = False
            elif strict_subset(p, q) and not strict_subset(A, B):
                ok = False
            elif strong and not strict_subset(q, p) and not strict_subset(p, q):
                if subset(A, B) or subset(B, A):
                    ok = False
            if not ok:
                break
        if ok:
            assign[p] = A
            out = _search(lattice, family, strong, idx + 1, assign, used | {A})
            if out is not None:
                return out
            del assign[p]
    return None


def find_copy(family: Iterable[int], d: int, strong: bool = False) -> Optional[Dict[int, int]]:
    """An embedding of B_d into ``family``, or None if the family is B_d-free."""
    fam = sorted(set(family), key=popcount)
    if len(fam) < (1 << d):
        return None
    return _search(boolean_lattice(d), fam, strong, 0, {}, frozenset())


def height(family: Iterable[int]) -> int:
    """Length of a longest chain inside ``family`` (dynamic programming by size)."""
    fam = sorted(set(family), key=popcount)
    best: Dict[int, int] = {}
    top = 0
    for A in fam:
        best[A] = 1 + max((best[B] for B in best if strict_subset(B, A)), default=0)
        top = max(top, best[A])
    return top


def is_weak_free(family: Iterable[int], d: int) -> bool:
    """Weak B_d-freeness, using the cheap height criterion as a shortcut."""
    if height(family) <= d:  # height <= d already forces B_d-freeness
        return True
    return find_copy(family, d, strong=False) is None


if __name__ == "__main__":
    cube = list(range(8))  # all subsets of a 3-element set
    print("copy of B_3 inside the 3-cube :", find_copy(cube, 3) is not None)
    print("height of the 3-cube          :", height(cube))
    middle = [x for x in range(8) if popcount(x) in (1, 2)]
    print("two middle layers, height     :", height(middle))
    print("two middle layers, B_2-free   :", is_weak_free(middle, 2))
    print("two middle layers, B_1-free   :", is_weak_free(middle, 1))


"""Greedy Antichain Augmentation: turn a B_d-free family into a larger B_{d+1}-free one."""

from __future__ import annotations

from typing import Dict, Iterable, List, Set, Tuple


def popcount(x: int) -> int:
    """Cardinality of the set encoded by the bitmask ``x``."""
    return bin(x).count("1")


def largest_complement_layer(n: int, family: Iterable[int]) -> List[int]:
    """The largest cardinality class of the complement of ``family`` inside 2^[n].

    Every cardinality class is an antichain, and by pigeonhole the largest one has
    at least (2^n - |family|)/(n+1) members.
    """
    fam: Set[int] = set(family)
    buckets: Dict[int, List[int]] = {i: [] for i in range(n + 1)}
    for A in range(1 << n):
        if A not in fam:
            buckets[popcount(A)].append(A)
    return max(buckets.values(), key=len)


def augment(n: int, family: Iterable[int]) -> Tuple[List[int], int]:
    """Adjoin the largest complement layer; returns the new family and the gain.

    If the input is weak (resp. strong) B_d-free, the output is weak (resp. strong)
    B_{d+1}-free, of size at least |family| + (2^n - |family|)/(n+1).
    Runs in O(2^n) time and space; no copy detection is performed.
    """
    fam = sorted(set(family))
    layer = largest_complement_layer(n, fam)
    return sorted(set(fam) | set(layer)), len(layer)


def central_layers(n: int, d: int) -> List[int]:
    """The union of the d central layers of 2^[n]: the standard B_d-free benchmark."""
    start = max(0, (n - d + 1) // 2)
    return [A for A in range(1 << n) if start <= popcount(A) < start + d]


if __name__ == "__main__":
    n = 8
    fam = central_layers(n, 3)  # a weak B_3-free family
    new, gain = augment(n, fam)
    guaranteed = -((-(2 ** n - len(fam))) // (n + 1))  # ceiling of (2^n - |F|)/(n+1)
    print(f"n = {n}")
    print(f"  three central layers      : {len(fam)} sets  (weak B_3-free)")
    print(f"  guaranteed pigeonhole gain: {guaranteed}")
    print(f"  actual gain               : {gain}")
    print(f"  augmented family          : {len(new)} sets  (weak B_4-free)")
    print(f"  four central layers       : {len(central_layers(n, 4))} sets")


"""Canonical Up-Set Lifting: an order embedding of B_d into B_{d+1} avoiding an antichain."""

from __future__ import annotations

from typing import Dict, FrozenSet, List, Set


def subset(x: int, y: int) -> bool:
    """Is the set with bitmask ``x`` contained in the set with bitmask ``y``?"""
    return x & ~y == 0


def up_closure(d: int, antichain: FrozenSet[int]) -> Set[int]:
    """The up-set U = { Y in B_d : some Z contained in Y lies in the antichain }.

    Computed with a subset-sum (zeta) transform in O(2^d * d) instead of the
    naive O(4^d) double loop over pairs.
    """
    hit: List[bool] = [(Y in antichain) for Y in range(1 << d)]
    for bit in range(d):
        for Y in range(1 << d):
            if Y & (1 << bit):
                hit[Y] = hit[Y] or hit[Y ^ (1 << bit)]
    return {Y for Y in range(1 << d) if hit[Y]}


def lift_up(d: int, up_set: Set[int]) -> Dict[int, int]:
    """The embedding attached to an up-set: adjoin the extra atom exactly on U."""
    last = 1 << d
    return {X: (X | last) if X in up_set else X for X in range(1 << d)}


def canonical_lift(d: int, antichain: FrozenSet[int]) -> Dict[int, int]:
    """An order embedding B_d -> B_{d+1} whose image misses the given antichain."""
    return lift_up(d, up_closure(d, antichain))


def verify(d: int, antichain: FrozenSet[int], emb: Dict[int, int]) -> bool:
    """Check injectivity, order preservation *and* reflection, and avoidance."""
    if len(set(emb.values())) != len(emb):
        return False
    for X in emb:
        for Y in emb:
            if subset(X, Y) != subset(emb[X], emb[Y]):
                return False
    return all(v not in antichain for v in emb.values())


if __name__ == "__main__":
    from itertools import combinations

    # B_2 -> B_3, dodging the antichain { {0}, {1,2} } (bitmasks 0b001 and 0b110).
    A = frozenset({0b001, 0b110})
    emb = canonical_lift(2, A)
    print("antichain :", sorted(A))
    print("embedding :", {bin(k): bin(v) for k, v in sorted(emb.items())})
    print("valid     :", verify(2, A, emb))

    # Exhaustive check for every antichain of B_3 and of B_4.
    for d in (2, 3):
        elems = list(range(1 << (d + 1)))
        total = ok = 0
        for r in range(len(elems) + 1):
            for cand in combinations(elems, r):
                if any(
                    x != y and (subset(x, y) or subset(y, x))
                    for x in cand
                    for y in cand
                ):
                    continue
                A = frozenset(cand)
                total += 1
                ok += verify(d, A, canonical_lift(d, A))
        print(f"d = {d}: {ok}/{total} antichains of B_{d+1} successfully avoided")


"""Assemble PACKAGE.json from the deliverables and the auxiliary asset sources."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "_assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


article = read(ROOT / "ARTICLE.md")
paper = read(ROOT / "RESEARCH_PAPER.md")
tex = read(ROOT / "RESEARCH_PAPER.tex")
demo = read(ROOT / "demo.py")
lean = read(ROOT / "Catalog" / "Combinatorics" / "B3FreeAntichainMonotone.lean")

alg_lift = read(A / "alg_lifting.py")
alg_copy = read(A / "alg_copy_detection.py")
alg_greedy = read(A / "alg_greedy_augment.py")
demo_escape = read(A / "demo_escape_routes.py")
viz_lift = read(A / "viz_lifting.py")
viz_bounds = read(A / "viz_bounds.py")
widget_lift = read(A / "widget_lifting.html")
widget_bounds = read(A / "widget_bounds.html")

future_directions = read(A / "future_directions.md")
layout = read(A / "interactive_layout.md")

package = {
    "title": "Adding an Antichain: Strict Monotonicity of the Boolean-Lattice Extremal Numbers",
    "domain": "Combinatorics",
    "description": (
        "A single lifting lemma \u2014 for every antichain of the Boolean lattice on d+1 atoms "
        "there is an order embedding of the d-atom lattice avoiding it \u2014 shows that adjoining "
        "any antichain to a Boolean-lattice-free family raises the forbidden dimension by exactly "
        "one, yielding a height criterion for freeness and strict monotonicity of the extremal "
        "numbers La(n, B_d) in d precisely when d \u2264 n, with an explicit pigeonhole gain."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-06",
    "key_results": [
        "Lifting Lemma: for every antichain A of the Boolean lattice on d+1 atoms there is an order embedding of the Boolean lattice on d atoms whose image misses A; the embeddings are indexed by up-sets, and the up-set generated by A always works.",
        "Antichain Union Theorem: the union of a family containing no copy of the d-atom Boolean lattice with an arbitrary antichain contains no copy of the (d+1)-atom Boolean lattice, for weak and for strong copies alike.",
        "Height Sandwich: a family of height at most d contains no copy of the d-atom Boolean lattice, while any such free family has height at most 2^d - 1, and both thresholds are attained; in particular any family realising at most d distinct set sizes is free, with no completeness or symmetry hypothesis.",
        "Strict Monotonicity Theorem: La(n, B_d) < La(n, B_{d+1}) holds exactly when d \u2264 n, and identically for the strong extremal number; iterating gives La(n, B_d) + k \u2264 La(n, B_{d+k}) whenever d + k \u2264 n + 1.",
        "Pigeonhole Gain Theorem: 2^n + n\u00b7La(n, B_d) \u2264 (n+1)\u00b7La(n, B_{d+1}) for all n and d, so the gain is at least (2^n - La(n, B_d))/(n+1); unconditionally La(n, B_{d+1}) \u2265 2^n/(n+1).",
    ],
    "keywords": [
        "forbidden subposet problems",
        "Boolean lattice",
        "antichain",
        "Sperner theory",
        "extremal set theory",
        "order embedding",
        "chain decomposition",
        "up-set",
    ],
    "article": article,
    "research_paper": paper,
    "research_paper_tex": tex,
    "demo": demo,
    "demos": [
        {
            "name": "Exhaustive Verification of the Antichain Mechanism on Small Ground Sets",
            "description": (
                "A self-contained brute-force laboratory for the whole theory. Sets are bitmasks; "
                "copies of the Boolean lattice are located by backtracking that respects order "
                "preservation (weak copies) and, optionally, order reflection (strong copies). "
                "The script (i) verifies the Lifting Lemma against every antichain of the Boolean "
                "lattices on 2, 3 and 4 atoms and prints a worked example; (ii) tests the Antichain "
                "Union Theorem on every pair consisting of a free family and an antichain over a "
                "three-element ground set, in both the weak and the strong sense; (iii) computes "
                "the exact extremal numbers La(n, B_d) and La*(n, B_d) for n \u2264 3 and d \u2264 4 by "
                "enumerating all 2^(2^n) families, confirming that strict growth in d occurs exactly "
                "when d \u2264 n and that the pigeonhole inequality 2^n + n\u00b7La(n,B_d) \u2264 (n+1)\u00b7La(n,B_{d+1}) "
                "holds with the predicted slack; (iv) checks the two height criteria and their "
                "sharpness; and (v) tabulates the central-layer benchmark against the chain upper "
                "bound for n up to 10."
            ),
            "code": demo,
        },
        {
            "name": "Counting the Escape Routes: How Many Up-Set Lifts Dodge a Given Antichain",
            "description": (
                "The Lifting Lemma guarantees at least one order embedding of the d-atom Boolean "
                "lattice into the (d+1)-atom one avoiding a prescribed antichain. This demo asks how "
                "much room there really is. It enumerates every up-set of the d-atom lattice (their "
                "number is the Dedekind number of order d: 3, 6, 20 for d = 1, 2, 3), forms the "
                "corresponding lift for each, and counts for every antichain of the larger lattice "
                "how many lifts avoid it. The minimum over antichains turns out to be exactly one in "
                "each case, so the lemma is tight: there are obstacle sets for which precisely one "
                "monotone weaving survives \u2014 and the canonical up-set generated by the antichain is "
                "always among the survivors."
            ),
            "code": demo_escape,
        },
    ],
    "algorithms": [
        {
            "name": "Canonical Up-Set Lifting: Embedding a Cube While Dodging an Antichain",
            "description": (
                "Given a dimension d and an antichain A inside the Boolean lattice on d+1 atoms, the "
                "algorithm returns an order embedding of the Boolean lattice on d atoms whose image "
                "is disjoint from A. Mathematical basis: any map sending each element X of the small "
                "lattice to one of its two avatars in the big lattice (with or without the extra atom) "
                "preserves and reflects containment exactly when the set U of elements sent upward is "
                "an up-set. Choosing U to be the up-set generated by the bottom-face members of A "
                "guarantees avoidance: if X is outside U, its image is its bottom avatar, which "
                "cannot lie in A without putting X into U; if X is inside U, some witness strictly "
                "below the image already lies in A, and an antichain cannot contain two comparable "
                "elements. Complexity: the up-set is computed by a subset-sum (zeta) transform in "
                "O(2^d\u00b7d) time and O(2^d) space, improving on the naive O(4^d) pairwise scan; "
                "verifying the embedding property costs O(4^d). This routine is the engine behind the "
                "Antichain Union Theorem and hence behind every growth statement in the pipeline."
            ),
            "pseudocode": (
                "INPUT : dimension d; antichain A of the Boolean lattice on atoms {0,...,d}\n"
                "OUTPUT: order embedding lambda of the lattice on atoms {0,...,d-1} with image disjoint from A\n"
                "\n"
                "1.  for Y = 0 .. 2^d - 1:            hit[Y] <- (Y is a member of A)\n"
                "2.  for bit = 0 .. d-1:                        # subset-sum (zeta) transform\n"
                "3.      for Y = 0 .. 2^d - 1:\n"
                "4.          if bit is in Y: hit[Y] <- hit[Y] OR hit[Y without bit]\n"
                "5.  U <- { Y : hit[Y] }                        # the up-set generated by A\n"
                "6.  for X = 0 .. 2^d - 1:\n"
                "7.      if X in U: lambda(X) <- X together with atom d\n"
                "8.      else     : lambda(X) <- X\n"
                "9.  return lambda\n"
                "\n"
                "INVARIANT: U is upward closed, hence  X subset Y  <=>  lambda(X) subset lambda(Y).\n"
                "POSTCONDITION: image(lambda) intersect A = empty."
            ),
            "code": alg_lift,
        },
        {
            "name": "Backtracking Detection of Weak and Strong Boolean-Lattice Copies",
            "description": (
                "Decides whether a family of sets contains a copy of the Boolean lattice on d atoms, "
                "and exhibits one if so. Elements of the pattern lattice are processed along a linear "
                "extension (by cardinality), and each is assigned an unused member of the family; the "
                "assignment is checked against all previously assigned pairs. For a weak copy the "
                "requirement is that strict containment in the pattern forces strict containment of "
                "images; for a strong copy, incomparable pattern elements must additionally receive "
                "incomparable sets. The search backtracks on the first violation. Worst-case cost is "
                "O(|F|^(2^d)\u00b72^d), but processing along the cardinality order prunes so aggressively "
                "that ground sets of size up to four with d up to four are instantaneous. The height "
                "criterion provides a free shortcut: if the family has no chain of d+1 sets, it is "
                "certified free without any search, and computing the height costs only O(|F|^2)."
            ),
            "pseudocode": (
                "INPUT : family F of subsets; dimension d; flag STRONG\n"
                "OUTPUT: an embedding iota of the d-atom Boolean lattice into F, or NONE\n"
                "\n"
                "1.  if height(F) <= d: return NONE            # cheap sufficient freeness test\n"
                "2.  if |F| < 2^d: return NONE                 # a copy needs 2^d distinct sets\n"
                "3.  L <- elements of the pattern lattice sorted by cardinality\n"
                "4.  return SEARCH(0, empty assignment, empty used-set)\n"
                "\n"
                "SEARCH(i, assign, used):\n"
                "5.  if i = |L|: return assign\n"
                "6.  p <- L[i]\n"
                "7.  for each A in F not in used:\n"
                "8.      ok <- TRUE\n"
                "9.      for each (q, B) in assign:\n"
                "10.         if q strictly-subset p and not (B strictly-subset A): ok <- FALSE\n"
                "11.         if p strictly-subset q and not (A strictly-subset B): ok <- FALSE\n"
                "12.         if STRONG and p, q incomparable and A, B comparable: ok <- FALSE\n"
                "13.     if ok:\n"
                "14.         result <- SEARCH(i+1, assign + {p -> A}, used + {A})\n"
                "15.         if result is not NONE: return result\n"
                "16. return NONE"
            ),
            "code": alg_copy,
        },
        {
            "name": "Greedy Antichain Augmentation and the Pigeonhole Gain",
            "description": (
                "Upgrades a family containing no copy of the d-atom Boolean lattice into a strictly "
                "larger family containing no copy of the (d+1)-atom one, without performing any copy "
                "detection. The complement of the input inside the power set of an n-element ground "
                "set is partitioned into the n+1 cardinality classes; each class is an antichain, and "
                "by pigeonhole the largest has at least (2^n - |F|)/(n+1) members. Adjoining it is "
                "legitimate by the Antichain Union Theorem, and the resulting size bound is exactly "
                "the Pigeonhole Gain Theorem 2^n + n\u00b7La(n, B_d) \u2264 (n+1)\u00b7La(n, B_{d+1}). Complexity: "
                "O(2^n) time and space, dominated by scanning the power set; contrast this with the "
                "doubly exponential cost of certifying freeness by search. Applied to the d central "
                "layers of an eight-element ground set, the procedure returns precisely the d+1 "
                "central layers \u2014 the greedy move reproduces the classical benchmark."
            ),
            "pseudocode": (
                "INPUT : ground set size n; family F of subsets of [n], free of the d-atom lattice\n"
                "OUTPUT: family F' containing F, free of the (d+1)-atom lattice,\n"
                "        with |F'| >= |F| + (2^n - |F|)/(n+1)\n"
                "\n"
                "1.  for i = 0 .. n: bucket[i] <- empty list\n"
                "2.  for each subset A of [n]:\n"
                "3.      if A not in F: append A to bucket[|A|]\n"
                "4.  L <- the bucket of maximum size            # an antichain, disjoint from F\n"
                "5.  return F union L\n"
                "\n"
                "CORRECTNESS: each bucket is an antichain (equal cardinalities are incomparable);\n"
                "the Antichain Union Theorem raises the forbidden dimension by exactly one;\n"
                "pigeonhole gives (n+1)|L| >= 2^n - |F|."
            ),
            "code": alg_greedy,
        },
    ],
    "visualizations": [
        {
            "name": "Weaving Between Two Faces: the Lifting Lemma on the Three-Cube",
            "description": (
                "Draws the Hasse diagram of the Boolean lattice on three atoms, marks a chosen "
                "antichain of obstacles in red, and highlights in green the image of the copy of the "
                "two-atom lattice produced by the canonical up-set lift, together with its four "
                "covering edges. The picture makes the mechanism visible: the copy stays on the "
                "bottom face until an obstacle is encountered below, then rises to the top face and "
                "never comes back down \u2014 exactly the monotonicity that makes the map an order "
                "embedding."
            ),
            "code": viz_lift,
        },
        {
            "name": "The Sandwich: Layer Constructions, the Chain Bound, and the Free Floor",
            "description": (
                "Two panels, everything measured in units of the central binomial coefficient. The "
                "left panel plots the d central layers for d = 1,...,4 against the ground set size, "
                "showing convergence to the horizontal lines at height d from below, and overlays the "
                "construction-free floor 2^n/((n+1)C(n,floor(n/2))) which decays like 1/sqrt(n) \u2014 the "
                "visual explanation of why the pigeonhole gain, although unconditional, cannot deliver "
                "a full central binomial coefficient. The right panel shades the unknown territory for "
                "the three-atom lattice between the layer value, slightly below 3, and the chain upper "
                "bound 7."
            ),
            "code": viz_bounds,
        },
    ],
    "interactive_demos": [
        {
            "title": "The Lifting Lemma Explorer: Dodge Any Antichain, Live",
            "description": (
                "An interactive Hasse diagram of the Boolean lattice on d+1 atoms (d = 1, 2, 3). Click "
                "nodes to place obstacles; the widget automatically keeps them an antichain by removing "
                "any obstacle comparable to your latest choice. It then computes the canonical up-set, "
                "draws the resulting embedded copy of the d-atom lattice in green with its covering "
                "edges, tabulates the map element by element with an indication of which elements are "
                "sent upward, and reports how many of the Dedekind-many up-set lifts avoid your "
                "antichain \u2014 always at least one, and for some antichains exactly one. Presets supply "
                "a random antichain and the full middle layer, the hardest natural obstacle set."
            ),
            "html": widget_lift,
        },
        {
            "title": "Growth Sandbox: Layers, Chains, and the Pigeonhole Gain",
            "description": (
                "Sliders for the ground set size n and the forbidden dimension d drive a live table and "
                "a chart. The table lists the central binomial coefficient, the d central layers, the "
                "chain upper bound, the construction-free floor 2^n/(n+1) and the whole power set, each "
                "also as a multiple of the central layer. A verdict panel applies the exact strictness "
                "criterion: when d is at most n the extremal number strictly grows, and the widget "
                "prints the pigeonhole-guaranteed gain against the gain actually realised by passing to "
                "d+1 central layers; when d exceeds n it explains why growth stops, both sides equalling "
                "2^n. The chart plots all bounds in units of the central layer with your current n "
                "marked, making the 1/sqrt(n) decay of the free floor immediately visible."
            ),
            "html": widget_bounds,
        },
    ],
    "interactive_layout": layout,
    "lean_proofs": lean,
    "future_directions": future_directions,
    "modules": {
        "demo": demo,
        "alg_lifting": alg_lift,
        "alg_copy_detection": alg_copy,
        "alg_greedy_augment": alg_greedy,
        "demo_escape_routes": demo_escape,
        "viz_lifting": viz_lift,
        "viz_bounds": viz_bounds,
    },
    "lean_files": ["Catalog/Combinatorics/B3FreeAntichainMonotone.lean"],
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""Counting escape routes: how many up-set lifts of B_d into B_{d+1} dodge an antichain.

The Lifting Lemma guarantees at least one. This script enumerates *all* up-sets of
B_d -- there are Dedekind-many -- and counts, for every antichain of B_{d+1}, how many
of the resulting order embeddings avoid it. It reports the minimum over antichains,
which is the true "margin" in the Lifting Lemma, and checks that the canonical
up-set (generated by the antichain itself) is always among the successful ones.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple


def subset(x: int, y: int) -> bool:
    """Containment of bitmask-encoded sets."""
    return x & ~y == 0


def all_up_sets(d: int) -> List[FrozenSet[int]]:
    """Every up-set of B_d (their number is the Dedekind number of order d)."""
    elems = list(range(1 << d))
    out: List[FrozenSet[int]] = []
    for mask in range(1 << len(elems)):
        U = {elems[i] for i in range(len(elems)) if (mask >> i) & 1}
        if all(not (subset(X, Y) and X in U and Y not in U) for X in elems for Y in elems):
            out.append(frozenset(U))
    return out


def all_antichains(d: int) -> List[FrozenSet[int]]:
    """Every antichain of B_d."""
    elems = list(range(1 << d))
    out: List[FrozenSet[int]] = []
    for r in range(len(elems) + 1):
        for cand in combinations(elems, r):
            if all(
                not (x != y and (subset(x, y) or subset(y, x)))
                for x in cand
                for y in cand
            ):
                out.append(frozenset(cand))
    return out


def lift_image(d: int, U: FrozenSet[int]) -> Set[int]:
    """Image of the embedding attached to the up-set U."""
    last = 1 << d
    return {(X | last) if X in U else X for X in range(1 << d)}


def canonical_up_set(d: int, A: FrozenSet[int]) -> FrozenSet[int]:
    """The up-set generated inside B_d by the bottom-face members of A."""
    return frozenset(
        Y for Y in range(1 << d) if any(Z in A and subset(Z, Y) for Z in range(1 << d))
    )


def survey(d: int) -> Tuple[int, int, int, bool]:
    """(number of up-sets, number of antichains, min escape routes, canonical always works)."""
    ups = all_up_sets(d)
    images: Dict[FrozenSet[int], Set[int]] = {U: lift_image(d, U) for U in ups}
    antis = all_antichains(d + 1)
    worst = len(ups)
    canonical_ok = True
    for A in antis:
        good = [U for U in ups if not (images[U] & A)]
        worst = min(worst, len(good))
        if canonical_up_set(d, A) not in good:
            canonical_ok = False
    return len(ups), len(antis), worst, canonical_ok


if __name__ == "__main__":
    print(" d   up-sets of B_d   antichains of B_{d+1}   min # of avoiding lifts   canonical always works")
    for d in (1, 2, 3):
        ups, antis, worst, ok = survey(d)
        print(f" {d}       {ups:6d}                  {antis:6d}                    {worst:6d}          {ok}")
    print()
    print("The minimum is always at least 1 -- the content of the Lifting Lemma --")
    print("and the canonical up-set generated by the antichain always realises it.")


"""Where the truth lives: layer lower bound, chain upper bound, and the pigeonhole gain."""

from __future__ import annotations

from math import comb
from typing import List

import matplotlib.pyplot as plt


def central_binomial(n: int) -> int:
    """The size of the largest layer of 2^[n]."""
    return comb(n, n // 2)


def layer_value(n: int, d: int) -> int:
    """Sum of the d largest binomial coefficients: the classical B_d-free construction."""
    start = max(0, (n - d + 1) // 2)
    return sum(comb(n, start + i) for i in range(d) if 0 <= start + i <= n)


def chain_bound(n: int, d: int) -> int:
    """The chain-decomposition upper bound (2^d - 1) * C(n, floor(n/2))."""
    return (2 ** d - 1) * central_binomial(n)


def pigeonhole_floor(n: int) -> float:
    """The unconditional lower bound 2^n/(n+1), in units of C(n, floor(n/2))."""
    return 2 ** n / ((n + 1) * central_binomial(n))


def plot(dmax: int = 4, nmax: int = 40) -> None:
    """Plot everything in units of the central binomial coefficient."""
    ns: List[int] = list(range(2, nmax + 1))
    fig, axes = plt.subplots(1, 2, figsize=(12, 4.6))

    ax = axes[0]
    for d in range(1, dmax + 1):
        ax.plot(
            ns,
            [layer_value(n, d) / central_binomial(n) for n in ns],
            label=f"$d = {d}$ layer construction",
        )
        ax.axhline(d, color="0.85", lw=0.8, ls=":")
    ax.plot(ns, [pigeonhole_floor(n) for n in ns], "k--",
            label=r"$2^n/((n+1)\,C(n,\lfloor n/2\rfloor))$")
    ax.set_xlabel("$n$")
    ax.set_ylabel(r"size / $C(n,\lfloor n/2\rfloor)$")
    ax.set_title("Lower bounds, in units of the central layer")
    ax.legend(fontsize=8)

    ax = axes[1]
    d = 3
    ax.fill_between(
        ns,
        [layer_value(n, d) / central_binomial(n) for n in ns],
        [chain_bound(n, d) / central_binomial(n) for n in ns],
        color="#cfe4ff",
        label="unknown territory for $d = 3$",
    )
    ax.plot(ns, [layer_value(n, d) / central_binomial(n) for n in ns], color="#1b7f4f",
            label="three central layers")
    ax.plot(ns, [chain_bound(n, d) / central_binomial(n) for n in ns], color="#8c1c14",
            label=r"chain bound $2^d-1 = 7$")
    ax.axhline(3, color="0.4", lw=0.9, ls=":")
    ax.set_ylim(0, 8)
    ax.set_xlabel("$n$")
    ax.set_ylabel(r"size / $C(n,\lfloor n/2\rfloor)$")
    ax.set_title(r"The gap for $B_3$: between $3+\varepsilon$ and $7$")
    ax.legend(fontsize=8)

    plt.tight_layout()
    plt.savefig("boolean_free_bounds.png", dpi=160)
    print("wrote boolean_free_bounds.png")


if __name__ == "__main__":
    plot()


"""Hasse-diagram visualization of the Lifting Lemma: B_2 dodging an antichain in B_3."""

from __future__ import annotations

from typing import Dict, FrozenSet, List, Set, Tuple

import matplotlib.pyplot as plt


def popcount(x: int) -> int:
    """Cardinality of the set encoded by the bitmask ``x``."""
    return bin(x).count("1")


def label(x: int, d: int) -> str:
    """Render a bitmask as a set of atom labels."""
    items = [chr(ord("a") + i) for i in range(d) if (x >> i) & 1]
    return "{" + "".join(items) + "}" if items else "\u2205"


def positions(d: int) -> Dict[int, Tuple[float, float]]:
    """Layered coordinates for the Hasse diagram of B_d."""
    levels: Dict[int, List[int]] = {}
    for x in range(1 << d):
        levels.setdefault(popcount(x), []).append(x)
    pos: Dict[int, Tuple[float, float]] = {}
    for k, nodes in levels.items():
        for i, x in enumerate(sorted(nodes)):
            pos[x] = (i - (len(nodes) - 1) / 2.0, float(k))
    return pos


def up_closure(d: int, antichain: FrozenSet[int]) -> Set[int]:
    """The up-set generated (inside B_d) by the bottom-face members of the antichain."""
    return {
        Y
        for Y in range(1 << d)
        if any(Z in antichain and (Z & ~Y) == 0 for Z in range(1 << d))
    }


def canonical_lift(d: int, antichain: FrozenSet[int]) -> Dict[int, int]:
    """The order embedding B_d -> B_{d+1} avoiding the antichain."""
    U = up_closure(d, antichain)
    return {X: (X | (1 << d)) if X in U else X for X in range(1 << d)}


def draw(d: int = 2, antichain: FrozenSet[int] = frozenset({0b011, 0b100})) -> None:
    """Draw B_{d+1} with the antichain in red and the lifted copy of B_d in green."""
    D = d + 1
    pos = positions(D)
    emb = canonical_lift(d, antichain)
    image = set(emb.values())

    fig, ax = plt.subplots(figsize=(7.5, 6))
    for x in range(1 << D):
        for y in range(1 << D):
            if popcount(y) == popcount(x) + 1 and (x & ~y) == 0:
                ax.plot(
                    [pos[x][0], pos[y][0]],
                    [pos[x][1], pos[y][1]],
                    color="0.82",
                    lw=1.2,
                    zorder=1,
                )
    # edges of the lifted copy
    for X in range(1 << d):
        for Y in range(1 << d):
            if popcount(Y) == popcount(X) + 1 and (X & ~Y) == 0:
                a, b = emb[X], emb[Y]
                ax.plot(
                    [pos[a][0], pos[b][0]],
                    [pos[a][1], pos[b][1]],
                    color="#1b7f4f",
                    lw=2.6,
                    zorder=2,
                )
    for x in range(1 << D):
        if x in antichain:
            color, edge = "#e8564a", "#8c1c14"
        elif x in image:
            color, edge = "#7fd6a5", "#1b7f4f"
        else:
            color, edge = "white", "0.5"
        ax.scatter([pos[x][0]], [pos[x][1]], s=900, c=color, edgecolors=edge,
                   zorder=3, linewidths=1.6)
        ax.text(pos[x][0], pos[x][1], label(x, D), ha="center", va="center",
                fontsize=9, zorder=4)

    ax.set_title(
        f"Lifting Lemma: a copy of $B_{{{d}}}$ inside $B_{{{D}}}$ avoiding an antichain\n"
        "red = antichain, green = image of the lifted copy",
        fontsize=11,
    )
    ax.set_xticks([])
    ax.set_yticks(range(D + 1))
    ax.set_ylabel("cardinality")
    ax.set_frame_on(False)
    plt.tight_layout()
    plt.savefig("lifting_lemma.png", dpi=160)
    print("wrote lifting_lemma.png")


if __name__ == "__main__":
    draw()


"""
Antichains, height, and the strict growth of the Boolean-lattice extremal numbers
=================================================================================

Self-contained numerical companion to the paper

    "Adding an antichain: strict monotonicity of the Boolean-lattice
     extremal numbers La(n, B_d)".

Everything is computed from first principles: sets are bitmasks over the ground
set [n] = {0, ..., n-1}, the Boolean lattice B_d is the family of all subsets of
{0, ..., d-1}, and copies of B_d inside a set family are found by exhaustive
backtracking.

The script verifies, by brute force on small ground sets:

  1. The Lifting Lemma:  for every antichain A of B_{d+1} there is an order
     embedding B_d -> B_{d+1} whose image misses A; and the explicit "up-set"
     embedding X |-> X u {last atom} (on an up-set U), X |-> X (elsewhere)
     always works with U = { Y : some Z <= Y has Z-hat in A }.

  2. The Antichain Union Theorem:  F weak B_d-free and L an antichain imply
     F u L is weak B_{d+1}-free (and the same for strong copies).

  3. Strict monotonicity:  La(n, B_d) < La(n, B_{d+1}) exactly when d <= n,
     and likewise for the strong extremal number La*(n, B_d).

  4. The pigeonhole inequality  2^n + n * La(n, B_d) <= (n+1) * La(n, B_{d+1}).

  5. The height sandwich:  height <= d implies weak B_d-freeness, weak
     B_d-freeness implies height <= 2^d - 1, and both thresholds are sharp.

Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# Sets as bitmasks
# ----------------------------------------------------------------------------


def popcount(x: int) -> int:
    """Number of elements of the set encoded by the bitmask ``x``."""
    return bin(x).count("1")


def subset(x: int, y: int) -> bool:
    """Is the set ``x`` contained in the set ``y``?"""
    return x & ~y == 0


def strict_subset(x: int, y: int) -> bool:
    """Is the set ``x`` strictly contained in the set ``y``?"""
    return x != y and subset(x, y)


def all_sets(n: int) -> List[int]:
    """All subsets of the ground set [n], as bitmasks."""
    return list(range(1 << n))


def show(x: int, n: int) -> str:
    """Human-readable rendering of a bitmask as a set of ground elements."""
    elems = [str(i) for i in range(n) if (x >> i) & 1]
    return "{" + ",".join(elems) + "}"


# ----------------------------------------------------------------------------
# Copies of the Boolean lattice B_d inside a family
# ----------------------------------------------------------------------------


def boolean_lattice(d: int) -> List[int]:
    """Elements of B_d (all subsets of a d-element set), ordered by size."""
    return sorted(range(1 << d), key=popcount)


def _search_copy(
    lattice: Sequence[int],
    family: Sequence[int],
    strong: bool,
    idx: int,
    assign: Dict[int, int],
    used: FrozenSet[int],
) -> Optional[Dict[int, int]]:
    """Backtracking search for an (injective, order-respecting) embedding."""
    if idx == len(lattice):
        return dict(assign)
    p = lattice[idx]
    for A in family:
        if A in used:
            continue
        ok = True
        for q, B in assign.items():
            if strict_subset(q, p) and not strict_subset(B, A):
                ok = False
            elif strict_subset(p, q) and not strict_subset(A, B):
                ok = False
            elif strong and not strict_subset(q, p) and not strict_subset(p, q):
                # incomparable in B_d must stay incomparable in the family
                if subset(A, B) or subset(B, A):
                    ok = False
            if not ok:
                break
        if ok:
            assign[p] = A
            res = _search_copy(lattice, family, strong, idx + 1, assign, used | {A})
            if res is not None:
                return res
            del assign[p]
    return None


def find_copy(family: Iterable[int], d: int, strong: bool = False) -> Optional[Dict[int, int]]:
    """Return an embedding of B_d into ``family``, or ``None`` if there is none.

    A *weak copy* is an injection i : B_d -> family with X < Y  =>  i(X) < i(Y).
    A *strong copy* satisfies in addition i(X) < i(Y)  =>  X < Y.
    """
    fam = sorted(set(family), key=popcount)
    if len(fam) < (1 << d):
        return None
    return _search_copy(boolean_lattice(d), fam, strong, 0, {}, frozenset())


def is_weak_free(family: Iterable[int], d: int) -> bool:
    """Does ``family`` contain no weak copy of B_d?"""
    return find_copy(family, d, strong=False) is None


def is_strong_free(family: Iterable[int], d: int) -> bool:
    """Does ``family`` contain no strong copy of B_d?"""
    return find_copy(family, d, strong=True) is None


# ----------------------------------------------------------------------------
# Antichains, chains, height
# ----------------------------------------------------------------------------


def is_antichain(family: Iterable[int]) -> bool:
    """No two distinct members of ``family`` are nested."""
    fam = list(family)
    for i, A in enumerate(fam):
        for B in fam[i + 1:]:
            if subset(A, B) or subset(B, A):
                return False
    return True


def height(family: Iterable[int]) -> int:
    """Length of a longest chain A_1 < A_2 < ... < A_k inside ``family``."""
    fam = sorted(set(family), key=popcount)
    best: Dict[int, int] = {}
    top = 0
    for A in fam:
        h = 1 + max((best[B] for B in best if strict_subset(B, A)), default=0)
        best[A] = h
        top = max(top, h)
    return top


def max_sets(family: Iterable[int]) -> List[int]:
    """The maximal members of ``family`` (always an antichain)."""
    fam = list(set(family))
    return [A for A in fam if not any(strict_subset(A, B) for B in fam)]


# ----------------------------------------------------------------------------
# 1. The Lifting Lemma
# ----------------------------------------------------------------------------


def lift_up(d: int, up_set: FrozenSet[int]) -> Dict[int, int]:
    """The embedding B_d -> B_{d+1} attached to an up-set U of B_d.

    ``X`` is sent to ``X u {d}`` when ``X`` lies in ``U`` and to ``X`` otherwise.
    (Here the atom ``d`` is the extra atom of B_{d+1}.)
    """
    last = 1 << d
    return {X: (X | last) if X in up_set else X for X in range(1 << d)}


def canonical_up_set(d: int, antichain: FrozenSet[int]) -> FrozenSet[int]:
    """U = { Y in B_d : some Z <= Y already lies in the antichain }."""
    return frozenset(
        Y for Y in range(1 << d) if any(subset(Z, Y) and Z in antichain for Z in range(1 << d))
    )


def is_order_embedding(d: int, emb: Dict[int, int]) -> bool:
    """Does ``emb`` satisfy  X <= Y  <=>  emb(X) <= emb(Y)  and injectivity?"""
    if len(set(emb.values())) != len(emb):
        return False
    for X in emb:
        for Y in emb:
            if subset(X, Y) != subset(emb[X], emb[Y]):
                return False
    return True


def antichains_of_boolean_lattice(d: int) -> List[FrozenSet[int]]:
    """All antichains of B_d, by brute force over all subsets of B_d."""
    elems = list(range(1 << d))
    out: List[FrozenSet[int]] = []
    for mask in range(1 << len(elems)):
        sub = [elems[i] for i in range(len(elems)) if (mask >> i) & 1]
        if is_antichain(sub):
            out.append(frozenset(sub))
    return out


def check_lifting_lemma(d: int) -> Tuple[int, bool]:
    """Verify: every antichain of B_{d+1} is avoided by the canonical lift."""
    ok = True
    antis = antichains_of_boolean_lattice(d + 1)
    for A in antis:
        U = canonical_up_set(d, A)
        emb = lift_up(d, U)
        if not is_order_embedding(d, emb):
            ok = False
            break
        if any(v in A for v in emb.values()):
            ok = False
            break
    return len(antis), ok


# ----------------------------------------------------------------------------
# 2/3/4. Extremal numbers by exhaustive search
# ----------------------------------------------------------------------------


def all_families(n: int) -> Iterable[List[int]]:
    """Every family of subsets of [n] (there are 2^(2^n) of them)."""
    sets = all_sets(n)
    for mask in range(1 << len(sets)):
        yield [sets[i] for i in range(len(sets)) if (mask >> i) & 1]


def La(n: int, d: int, strong: bool = False) -> int:
    """Exhaustive extremal number: max size of a weak (or strong) B_d-free family."""
    best = 0
    test = is_strong_free if strong else is_weak_free
    for fam in all_families(n):
        if len(fam) > best and test(fam, d):
            best = len(fam)
    return best


def max_antichain(n: int) -> int:
    """Largest antichain in the subset lattice of [n] (Sperner's theorem)."""
    best = 0
    for fam in all_families(n):
        if len(fam) > best and is_antichain(fam):
            best = len(fam)
    return best


# ----------------------------------------------------------------------------
# Reporting
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_lifting_lemma() -> None:
    banner("1.  The Lifting Lemma:  B_d embeds into B_{d+1} avoiding any antichain")
    print("For every antichain A of B_{d+1} the up-set embedding")
    print("    X |-> X u {last atom}  if some subset of X is already hit by A,")
    print("    X |-> X                otherwise")
    print("is an order embedding of B_d into B_{d+1} whose image misses A.\n")
    for d in (1, 2, 3):
        count, ok = check_lifting_lemma(d)
        print(f"  d = {d}:  all {count:4d} antichains of B_{d+1} avoided : {ok}")

    print("\nWorked example (d = 2, antichain A = {{0}, {1,2}} inside B_3):")
    A = frozenset({0b001, 0b110})
    U = canonical_up_set(2, A)
    emb = lift_up(2, U)
    for X in sorted(emb, key=popcount):
        print(
            f"    {show(X, 2):>7} -> {show(emb[X], 3):>9}"
            f"   (in the up-set: {X in U})"
        )
    print(f"    image meets A ? {any(v in A for v in emb.values())}")


def demo_antichain_union(n: int = 3) -> None:
    banner(f"2.  The Antichain Union Theorem, checked exhaustively on [{n}]")
    print("If F is weak B_d-free and L is an antichain, then F u L is weak")
    print("B_{d+1}-free; the same holds verbatim for strong copies.\n")
    fams = [tuple(f) for f in all_families(n)]
    antichains = [f for f in fams if is_antichain(f)]
    for d in (1, 2):
        weak_bad = strong_bad = 0
        tested = 0
        for F in fams:
            if not is_weak_free(F, d):
                continue
            for L in antichains:
                tested += 1
                U = sorted(set(F) | set(L))
                if not is_weak_free(U, d + 1):
                    weak_bad += 1
        for F in fams:
            if not is_strong_free(F, d):
                continue
            for L in antichains:
                U = sorted(set(F) | set(L))
                if not is_strong_free(U, d + 1):
                    strong_bad += 1
        print(
            f"  d = {d}: {tested:6d} pairs (F, L) tested; "
            f"weak failures = {weak_bad}, strong failures = {strong_bad}"
        )


def demo_extremal_numbers(nmax: int = 3, dmax: int = 4) -> None:
    banner("3.  Extremal numbers La(n, B_d) and La*(n, B_d), computed exhaustively")
    print("  n   d    La(n,B_d)   La*(n,B_d)   2^n   (2^d-1)*C(n,floor(n/2))")
    table: Dict[Tuple[int, int], Tuple[int, int]] = {}
    for n in range(0, nmax + 1):
        for d in range(1, dmax + 1):
            w = La(n, d, strong=False)
            s = La(n, d, strong=True)
            table[(n, d)] = (w, s)
            bound = (2 ** d - 1) * comb(n, n // 2)
            print(f"  {n}   {d}      {w:4d}         {s:4d}     {2**n:4d}        {bound:6d}")
        print()

    banner("3a.  Strict monotonicity in d, and the exact strictness criterion")
    print("Theorem: La(n, B_d) < La(n, B_{d+1})  if and only if  d <= n;")
    print("for d > n both sides equal 2^n.  Same statement for La*.\n")
    for n in range(0, nmax + 1):
        for d in range(1, dmax):
            w1, s1 = table[(n, d)]
            w2, s2 = table[(n, d + 1)]
            predicted = d <= n
            print(
                f"  n={n}, d={d}:  La {w1:3d} < {w2:3d} ? {w1 < w2}"
                f"   La* {s1:3d} < {s2:3d} ? {s1 < s2}"
                f"   predicted strict: {predicted}"
                f"   {'OK' if (w1 < w2) == predicted == (s1 < s2) else 'MISMATCH'}"
            )
        print()

    banner("3b.  The pigeonhole inequality  2^n + n*La(n,B_d) <= (n+1)*La(n,B_{d+1})")
    for n in range(0, nmax + 1):
        for d in range(1, dmax):
            w1, _ = table[(n, d)]
            w2, _ = table[(n, d + 1)]
            lhs = 2 ** n + n * w1
            rhs = (n + 1) * w2
            print(
                f"  n={n}, d={d}:  {lhs:5d} <= {rhs:5d} ? {lhs <= rhs}"
                f"    guaranteed gain >= ceil((2^n - La)/(n+1)) = "
                f"{-((-(2**n - w1)) // (n + 1))},  actual gain = {w2 - w1}"
            )
        print()

    banner("3c.  Sperner's theorem and the exact value at n = d + 1")
    for n in range(1, nmax + 1):
        print(
            f"  n = {n}:  La(n, B_1) = {table[(n,1)][0]},  "
            f"C(n, floor(n/2)) = {comb(n, n // 2)},  "
            f"largest antichain = {max_antichain(n)}"
        )
    for d in range(1, nmax):
        n = d + 1
        print(
            f"  d = {d}:  La(d+1, B_d) = {table[(n,d)][0]},  2^(d+1) - 2 = {2**(d+1) - 2}"
        )


def demo_height() -> None:
    banner("4.  The height sandwich")
    print("Height <= d  =>  weak B_d-free  =>  height <= 2^d - 1,")
    print("and both thresholds are attained.\n")

    # (a) height <= d implies weak B_d-free, checked exhaustively on [3]
    bad = 0
    for fam in all_families(3):
        h = height(fam)
        for d in range(0, 4):
            if h <= d and not is_weak_free(fam, d):
                bad += 1
    print(f"  (a) 'height <= d => weak B_d-free' on [3]: counterexamples = {bad}")

    bad = 0
    for fam in all_families(3):
        for d in range(1, 4):
            if is_weak_free(fam, d) and height(fam) > 2 ** d - 1:
                bad += 1
    print(f"  (b) 'weak B_d-free => height <= 2^d - 1' on [3]: counterexamples = {bad}")

    # (c) sharpness of the lower threshold: a copy of B_d has height d + 1
    for d in (1, 2, 3):
        fam = list(range(1 << d))  # the lattice B_d itself
        print(
            f"  (c) d = {d}: the whole lattice B_{d} has height {height(fam)} = d+1 "
            f"and is not weak B_{d}-free: {not is_weak_free(fam, d)}"
        )

    # (d) sharpness of the upper threshold: a chain of 2^d - 1 sets is B_d-free
    for d in (1, 2, 3):
        m = 2 ** d - 1
        chain = [(1 << k) - 1 for k in range(m)]  # nested sets of sizes 0..m-1
        print(
            f"  (d) d = {d}: a chain of {m} sets has height {height(chain)} "
            f"and is weak B_{d}-free: {is_weak_free(chain, d)}"
        )


def demo_layers() -> None:
    banner("5.  Layer families: the benchmark to beat")
    print("The union of d consecutive layers of [n] is weak (indeed strong) B_d-free,")
    print("because it has height d.  Its size is the sum of d binomial coefficients,")
    print("maximised by the d central ones.\n")
    for n in range(3, 11):
        d = 3
        start = (n - d + 1) // 2
        sizes = [comb(n, start + i) for i in range(d)]
        central = comb(n, n // 2)
        print(
            f"  n = {n:2d}:  central layers {list(range(start, start+d))}"
            f"  total = {sum(sizes):5d}"
            f"  = {sum(sizes)/central:6.4f} x C(n, floor(n/2))"
            f"   [upper bound 7 x C = {7*central}]"
        )
    print("\nThe conjectured (3 + eps) constructions must therefore break the")
    print("symmetry of the cube: no family defined by a set of levels can exceed")
    print("the central three-layer value.")


def main() -> None:
    demo_lifting_lemma()
    demo_antichain_union(3)
    demo_extremal_numbers(3, 4)
    demo_height()
    demo_layers()
    print("\nAll checks completed.\n")


if __name__ == "__main__":
    main()
