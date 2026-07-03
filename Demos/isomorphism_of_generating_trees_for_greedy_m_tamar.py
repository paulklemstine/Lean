def binom(n: int, k: int) -> int:
    """Exact integer binomial coefficient C(n, k)."""
    if k < 0 or k > n:
        return 0
    num = 1
    den = 1
    for i in range(k):
        num *= n - i
        den *= i + 1
    return num // den


def tamari_interval_count(m: int, n: int) -> int:
    """Number of m-Tamari intervals (= planar (m+1)-constellations) of size n.

    Uses the closed form  (m+1)/(n(mn+1)) * C((m+1)^2 n + m, n-1).
    The result is always a positive integer; the assertion certifies the exact
    division for the supplied (m, n).
    """
    top = (m + 1) * binom((m + 1) ** 2 * n + m, n - 1)
    bot = n * (m * n + 1)
    assert top % bot == 0, "closed form must divide exactly"
    return top // bot


from typing import Callable, TypeVar

L = TypeVar("L")


def level_labels(succ: Callable[[L], list[L]], root: L, k: int) -> list[L]:
    """Unfold a generating tree to depth k, returning the ordered label list.

    Realizes  level(0) = [root],  level(j+1) = flatMap(succ, level(j)).
    """
    level: list[L] = [root]
    for _ in range(k):
        nxt: list[L] = []
        for a in level:
            nxt.extend(succ(a))
        level = nxt
    return level


def counting_sequence(succ: Callable[[L], list[L]], root: L, kmax: int) -> list[int]:
    """Return [c_0, c_1, ..., c_kmax] where c_k is the number of depth-k nodes."""
    return [len(level_labels(succ, root, k)) for k in range(kmax + 1)]


from typing import Callable, TypeVar

L = TypeVar("L")
M = TypeVar("M")


def verify_iso(
    succ1: Callable[[L], list[L]],
    succ2: Callable[[M], list[M]],
    phi: Callable[[L], M],
    root1: L,
    root2: M,
    reachable: list[L],
) -> bool:
    """Certify a generating-tree isomorphism by checking the local hypotheses.

    Returns True iff phi(root1) == root2 and, for every label a in `reachable`,
    the intertwining identity  succ2(phi(a)) == [phi(x) for x in succ1(a)]
    holds. By the refined-equinumerosity theorem, a True result guarantees that
    counts and every phi-compatible statistic agree at all depths.
    """
    if phi(root1) != root2:
        return False
    for a in reachable:
        if succ2(phi(a)) != [phi(x) for x in succ1(a)]:
            return False
    return True


import json


def R(path: str) -> str:
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


future_directions = R("FUTURE_DIRECTIONS_snippet.txt")

pkg = {
    "title": "Isomorphisms of Generating Trees and Refined Equinumerosity for m-Tamari Intervals and (m+1)-Constellations",
    "domain": "Pythagorean",
    "description": (
        "A rigorous theory of generating-tree isomorphisms: a root-matching label map "
        "that intertwines two succession rules forces the two encoded families to agree "
        "level by level, in raw counts and in every label-borne statistic. This reduces "
        "the conjectural correspondence between m-Tamari intervals and planar "
        "(m+1)-constellations to a single local intertwining identity."
    ),
    "authors": ["Aristotle"],
    "date": "2026-07-03",
    "key_results": [
        "Level-correspondence theorem: under a root-matching, rule-intertwining label map, the label list at every depth of one generating tree is exactly the image of the other tree's label list.",
        "Equal-counts theorem: isomorphic generating trees have identical counting sequences at every depth.",
        "Refined-equinumerosity theorem: any statistic borne by the labels and compatible through the label map has the same size-refined distribution in both families.",
        "Reduction principle: the m-Tamari interval / planar (m+1)-constellation correspondence reduces to exhibiting one local label map intertwining the two succession rules.",
    ],
    "keywords": [
        "generating tree",
        "succession rule",
        "refined equinumerosity",
        "m-Tamari lattice",
        "planar constellation",
        "Fuss-Catalan numbers",
        "combinatorial bijection",
    ],
    "article": R("ARTICLE.md"),
    "research_paper": R("RESEARCH_PAPER.md"),
    "research_paper_tex": R("RESEARCH_PAPER.tex"),
    "demo": R("demo.py"),
    "demos": [
        {
            "name": "Catalan Generating Tree Unfolding and Counting Sequence",
            "description": (
                "Constructs the classical Catalan generating tree, in which a node labelled a "
                "has children labelled 2 through a+1, and unfolds it level by level. The demo "
                "tabulates the level counts and confirms they reproduce the Catalan numbers "
                "1, 1, 2, 5, 14, 42, 132, 429, illustrating how a succession rule encodes a "
                "counting sequence."
            ),
            "code": R("algo_unfold.py") + "\n\n"
            "def succ(a: int) -> list[int]:\n"
            "    return list(range(2, a + 2))\n\n\n"
            "if __name__ == \"__main__\":\n"
            "    print(counting_sequence(succ, 1, 7))  # -> [1, 1, 2, 5, 14, 42, 132, 429]\n",
        },
        {
            "name": "Transport of Refined Statistics Across a Generating-Tree Isomorphism",
            "description": (
                "Builds two differently-labelled generating trees related by an intertwining "
                "shift map phi(a) = a + 99, verifies the local intertwining identity on the "
                "reachable labels, and confirms that both the counting sequences and the full "
                "label distributions coincide at every depth, demonstrating the "
                "refined-equinumerosity theorem in action."
            ),
            "code": R("algo_verify.py") + "\n\n"
            "from collections import Counter\n\n"
            "def s1(a: int) -> list[int]:\n"
            "    return list(range(2, a + 2))\n\n"
            "def s2(b: int) -> list[int]:\n"
            "    return list(range(101, b + 2))\n\n"
            "def phi(a: int) -> int:\n"
            "    return a + 99\n\n"
            "def levels(succ, root, k):\n"
            "    L = [root]\n"
            "    for _ in range(k):\n"
            "        n = []\n"
            "        for a in L:\n"
            "            n.extend(succ(a))\n"
            "        L = n\n"
            "    return L\n\n\n"
            "if __name__ == \"__main__\":\n"
            "    reachable = list(range(1, 40))\n"
            "    assert verify_iso(s1, s2, phi, 1, 100, reachable)\n"
            "    for k in range(7):\n"
            "        assert len(levels(s1, 1, k)) == len(levels(s2, 100, k))\n"
            "        d1 = Counter(levels(s1, 1, k))\n"
            "        d2 = Counter(b - 99 for b in levels(s2, 100, k))\n"
            "        assert d1 == d2\n"
            "    print('counts and refined distributions coincide at every depth')\n",
        },
        {
            "name": "Integrality of the m-Tamari Interval / (m+1)-Constellation Count",
            "description": (
                "Evaluates the Fuss-Catalan-type closed form (m+1)/(n(mn+1)) * "
                "C((m+1)^2 n + m, n-1) that simultaneously counts m-Tamari intervals and "
                "planar (m+1)-constellations of size n, verifying the exact integer division "
                "for a range of m and n and reproducing the known m=1 sequence "
                "1, 3, 13, 68, 399, 2530."
            ),
            "code": R("algo_count.py") + "\n\n"
            "if __name__ == \"__main__\":\n"
            "    for m in (1, 2, 3):\n"
            "        print(f'm={m}:', [tamari_interval_count(m, n) for n in range(1, 7)])\n",
        },
    ],
    "algorithms": [
        {
            "name": "Level Unfolding of a Generating Tree",
            "description": (
                "Given a succession rule succ and a root label, this procedure computes the "
                "ordered list of node labels at depth k by iterating the recurrence "
                "level(j+1) = flatMap(succ, level(j)) starting from [root]. Its length is the "
                "term c_k of the counting sequence. The running time is proportional to the "
                "total number of nodes produced up to depth k, i.e. the partial sum "
                "c_0 + c_1 + ... + c_k, which for Catalan/Fuss-Catalan families grows "
                "exponentially in k; memory is proportional to the widest level c_k."
            ),
            "pseudocode": (
                "function LEVEL_LABELS(succ, root, k):\n"
                "    level <- [root]\n"
                "    repeat k times:\n"
                "        next <- empty list\n"
                "        for each label a in level:\n"
                "            next <- next ++ succ(a)\n"
                "        level <- next\n"
                "    return level\n\n"
                "function LEVEL_COUNT(succ, root, k):\n"
                "    return length(LEVEL_LABELS(succ, root, k))"
            ),
            "code": R("algo_unfold.py"),
        },
        {
            "name": "Intertwining Certificate Verification for Tree Isomorphisms",
            "description": (
                "Given two succession rules succ1, succ2, a candidate label map phi, the two "
                "roots, and a finite set of reachable labels, this procedure certifies that "
                "phi is a generating-tree isomorphism by checking the root condition "
                "phi(root1) = root2 and the local intertwining identity "
                "succ2(phi(a)) = map(phi, succ1(a)) for every reachable label a. Each check is "
                "a single list comparison, so the cost is linear in the number of reachable "
                "labels times the maximum child-list length. A positive result guarantees, by "
                "the refined-equinumerosity theorem, that counts and every phi-compatible "
                "statistic agree at all depths without any further computation."
            ),
            "pseudocode": (
                "function VERIFY_ISO(succ1, succ2, phi, root1, root2, reachable):\n"
                "    if phi(root1) != root2:\n"
                "        return FALSE\n"
                "    for each label a in reachable:\n"
                "        if succ2(phi(a)) != map(phi, succ1(a)):\n"
                "            return FALSE\n"
                "    return TRUE"
            ),
            "code": R("algo_verify.py"),
        },
        {
            "name": "Fuss-Catalan Interval Count Evaluation",
            "description": (
                "Evaluates the closed form (m+1)/(n(mn+1)) * C((m+1)^2 n + m, n-1) counting "
                "m-Tamari intervals and planar (m+1)-constellations of size n. The binomial "
                "coefficient is computed by an exact integer product/division loop in O(n) "
                "big-integer operations, and the final division by n(mn+1) is asserted to be "
                "exact, certifying integrality of the count for the given parameters. This is "
                "the arithmetic whose automatic integrality a generating-tree recursion would "
                "make manifest."
            ),
            "pseudocode": (
                "function BINOM(n, k):\n"
                "    if k < 0 or k > n: return 0\n"
                "    num, den <- 1, 1\n"
                "    for i in 0 .. k-1:\n"
                "        num <- num * (n - i)\n"
                "        den <- den * (i + 1)\n"
                "    return num / den\n\n"
                "function TAMARI_INTERVAL_COUNT(m, n):\n"
                "    top <- (m + 1) * BINOM((m + 1)^2 * n + m, n - 1)\n"
                "    bot <- n * (m * n + 1)\n"
                "    assert top mod bot == 0\n"
                "    return top / bot"
            ),
            "code": R("algo_count.py"),
        },
    ],
    "visualizations": [
        {
            "name": "Shared Growth Curves of Isomorphic Generating Trees",
            "description": (
                "Plots the level counts of two differently-labelled but intertwined generating "
                "trees on a logarithmic scale, showing the two curves coinciding exactly, a "
                "visual proof of the equal-counts theorem."
            ),
            "code": R("viz_growth.py"),
        },
        {
            "name": "Refined Label Distribution Heatmap Across Levels",
            "description": (
                "Renders, as a heatmap indexed by depth and label value, the number of nodes "
                "carrying each label at each depth of the Catalan generating tree, making "
                "visible the refined statistic that an isomorphism transports unchanged."
            ),
            "code": R("viz_distribution.py"),
        },
        {
            "name": "Recursive Structure of a Generating Tree",
            "description": (
                "Draws the first several levels of a generating tree with parent-to-child "
                "edges and labelled nodes, turning the abstract succession rule "
                "succ(a) = [2, ..., a+1] into a concrete branching picture."
            ),
            "code": R("viz_tree.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "Generating Tree Explorer",
            "description": (
                "An interactive widget for building a generating tree from an adjustable "
                "succession-rule family and root, showing the resulting counting sequence and "
                "the label distribution at each depth as the sliders move; the Catalan tree "
                "appears as a special case."
            ),
            "html": R("interactive_explorer.html"),
        },
        {
            "title": "Generating-Tree Isomorphism Verifier",
            "description": (
                "A live verifier for the intertwining hypothesis: adjust the shift map and the "
                "second tree's succession rule and watch the tool certify or reject the "
                "isomorphism, while a side-by-side table shows whether counts and refined "
                "distributions match, demonstrating that intertwining is exactly what is "
                "required."
            ),
            "html": R("interactive_iso.html"),
        },
        {
            "title": "m-Tamari Interval and Constellation Counter",
            "description": (
                "An interactive calculator for the Fuss-Catalan-type formula counting m-Tamari "
                "intervals and planar (m+1)-constellations, computing exact big-integer values "
                "for chosen m and n, confirming integrality, and tabulating the full array of "
                "counts."
            ),
            "html": R("interactive_tamari.html"),
        },
    ],
    "lean_proofs": R("lean_proofs.txt"),
    "future_directions": future_directions,
    "modules": {"demo": R("demo.py")},
    "lean_files": [
        "Catalog/Pythagorean/GeneratingTreeIso.lean",
        "Catalog/Pythagorean/MTamariConstellationTree.lean",
    ],
}

with open("PACKAGE.json", "w", encoding="utf-8") as f:
    json.dump(pkg, f, indent=2, ensure_ascii=False)

print("wrote PACKAGE.json")


"""Numerical demonstrations of generating-tree isomorphisms and refined equinumerosity.

This module is fully self-contained (standard library only). It realizes the theory:

  * A generating tree is a succession rule ``succ : L -> list[L]`` with a root.
  * Level unfolding produces the ordered label list at each depth.
  * An isomorphism is a label map ``phi`` that matches roots and *intertwines*
    the two succession rules:  succ2(phi(a)) == [phi(x) for x in succ1(a)].
  * Consequences (proved in the accompanying paper):
      - equal counting sequences,
      - equal *refined* counts for any label-borne statistic that agrees
        through ``phi``.

Run ``python demo.py`` to see the demonstrations.
"""

from __future__ import annotations

from typing import Callable, Hashable, TypeVar
from collections import Counter

L = TypeVar("L", bound=Hashable)
M = TypeVar("M", bound=Hashable)
A = TypeVar("A", bound=Hashable)


# --------------------------------------------------------------------------- #
# Core engine
# --------------------------------------------------------------------------- #
def level_labels(succ: Callable[[L], list[L]], root: L, k: int) -> list[L]:
    """Ordered list of labels of all nodes at depth ``k`` (Definition: level labels).

    ``level 0 = [root]`` and ``level (j+1) = flatMap succ (level j)``.
    """
    level: list[L] = [root]
    for _ in range(k):
        nxt: list[L] = []
        for a in level:
            nxt.extend(succ(a))
        level = nxt
    return level


def level_count(succ: Callable[[L], list[L]], root: L, k: int) -> int:
    """Number of nodes at depth ``k`` (the size-``k`` term of the counting sequence)."""
    return len(level_labels(succ, root, k))


def refined_count(
    succ: Callable[[L], list[L]],
    root: L,
    weight: Callable[[L], A],
    k: int,
) -> Counter[A]:
    """Distribution of the statistic ``weight`` over the depth-``k`` nodes."""
    return Counter(weight(a) for a in level_labels(succ, root, k))


def verify_iso(
    succ1: Callable[[L], list[L]],
    succ2: Callable[[M], list[M]],
    phi: Callable[[L], M],
    root1: L,
    root2: M,
    reachable: list[L],
) -> bool:
    """Verify (Root) and (Intertwining) of a candidate isomorphism ``phi``.

    Checks ``phi(root1) == root2`` and, for every label ``a`` in ``reachable``,
    the local identity ``succ2(phi(a)) == [phi(x) for x in succ1(a)]``.
    """
    if phi(root1) != root2:
        return False
    for a in reachable:
        if succ2(phi(a)) != [phi(x) for x in succ1(a)]:
            return False
    return True


# --------------------------------------------------------------------------- #
# Demo 1: the Catalan generating tree
# --------------------------------------------------------------------------- #
def demo_catalan() -> None:
    """Standard Catalan tree: label ``a`` has children labelled 2..a+1."""
    def succ(a: int) -> list[int]:
        return list(range(2, a + 2))

    counts = [level_count(succ, 1, k) for k in range(8)]
    print("Demo 1 - Catalan generating tree")
    print("  counting sequence:", counts)
    assert counts == [1, 1, 2, 5, 14, 42, 132, 429]
    print("  matches Catalan numbers 1,1,2,5,14,42,132,429\n")


# --------------------------------------------------------------------------- #
# Demo 2: an isomorphism transports counts and refined counts
# --------------------------------------------------------------------------- #
def demo_isomorphism() -> None:
    """Two differently-labelled trees related by an intertwining shift map.

    Tree 1 uses labels a >= 1 with succ1(a) = [2, ..., a+1].
    Tree 2 uses labels b >= 100 with succ2(b) = [101, ..., b+1], and
    phi(a) = a + 99. One checks succ2(phi(a)) = map phi (succ1(a)), so counts
    and every phi-compatible statistic must agree at every depth.
    """
    def succ1(a: int) -> list[int]:
        return list(range(2, a + 2))

    def succ2(b: int) -> list[int]:
        return list(range(101, b + 2))

    def phi(a: int) -> int:
        return a + 99

    reachable = list(range(1, 40))
    ok = verify_iso(succ1, succ2, phi, 1, 100, reachable)
    print("Demo 2 - Generating-tree isomorphism")
    print("  intertwining verified on reachable labels:", ok)
    assert ok

    for k in range(7):
        c1 = level_count(succ1, 1, k)
        c2 = level_count(succ2, 100, k)
        assert c1 == c2
    print("  counting sequences coincide at every depth (Equal-counts theorem)")

    # Refined: statistic = the label value itself, transported by phi.
    #   w1(a) = a,   w2(b) = b - 99,   so w2(phi(a)) = w1(a).
    for k in range(7):
        d1 = refined_count(succ1, 1, lambda a: a, k)
        d2 = refined_count(succ2, 100, lambda b: b - 99, k)
        assert d1 == d2
    print("  refined label distributions coincide (Refined-equinumerosity theorem)")
    print("    depth 4 distribution:", dict(sorted(
        refined_count(succ1, 1, lambda a: a, 4).items())), "\n")


# --------------------------------------------------------------------------- #
# Demo 3: intertwining is necessary (a bare bijection is not enough)
# --------------------------------------------------------------------------- #
def demo_intertwining_necessary() -> None:
    """A label map that is a bijection but does NOT intertwine fails the check,
    and the refined counts genuinely differ."""
    def succ1(a: int) -> list[int]:
        return list(range(2, a + 2))

    # succ2 with a *different* growth pattern (each label has a+1 children).
    def succ2(b: int) -> list[int]:
        return list(range(2, b + 3))

    def phi(a: int) -> int:
        return a  # identity: a bijection of label types, but not intertwining

    reachable = list(range(1, 20))
    ok = verify_iso(succ1, succ2, phi, 1, 1, reachable)
    print("Demo 3 - Intertwining is necessary")
    print("  intertwining verified:", ok, "(expected False)")
    assert not ok
    c1 = [level_count(succ1, 1, k) for k in range(6)]
    c2 = [level_count(succ2, 1, k) for k in range(6)]
    print("  tree 1 counts:", c1)
    print("  tree 2 counts:", c2)
    print("  counts differ, confirming a mere bijection carries no information\n")


# --------------------------------------------------------------------------- #
# Demo 4: Fuss-Catalan style counts and the m-Tamari interval formula
# --------------------------------------------------------------------------- #
def binom(n: int, k: int) -> int:
    if k < 0 or k > n:
        return 0
    num = 1
    den = 1
    for i in range(k):
        num *= n - i
        den *= i + 1
    return num // den


def tamari_interval_count(m: int, n: int) -> int:
    """Closed form  (m+1)/(n(mn+1)) * C((m+1)^2 n + m, n-1)  for m-Tamari intervals."""
    top = (m + 1) * binom((m + 1) ** 2 * n + m, n - 1)
    bot = n * (m * n + 1)
    assert top % bot == 0, "formula must be an integer"
    return top // bot


def demo_tamari_formula() -> None:
    print("Demo 4 - m-Tamari interval counts (always integers)")
    for m in (1, 2, 3):
        row = [tamari_interval_count(m, n) for n in range(1, 7)]
        print(f"  m={m}: {row}")
    # m=1 interval numbers: 1, 3, 13, 68, 399, 2530, ...
    assert [tamari_interval_count(1, n) for n in range(1, 7)] == [1, 3, 13, 68, 399, 2530]
    print("  m=1 row matches the known sequence 1,3,13,68,399,2530\n")


if __name__ == "__main__":
    demo_catalan()
    demo_isomorphism()
    demo_intertwining_necessary()
    demo_tamari_formula()
    print("All demonstrations passed.")


"""Visualization: refined statistic distribution across levels as a heatmap.

For the Catalan generating tree, the label of a node is a positive integer.
We plot, as a heatmap, the number of depth-k nodes carrying each label value,
illustrating the refined statistic that an isomorphism transports intact.
"""

from __future__ import annotations

from typing import Callable
from collections import Counter
import numpy as np
import matplotlib.pyplot as plt


def level_labels(succ: Callable[[int], list[int]], root: int, k: int) -> list[int]:
    level = [root]
    for _ in range(k):
        nxt: list[int] = []
        for a in level:
            nxt.extend(succ(a))
        level = nxt
    return level


def succ(a: int) -> list[int]:
    return list(range(2, a + 2))


def main() -> None:
    max_depth = 8
    max_label = 9
    grid = np.zeros((max_label, max_depth + 1), dtype=float)
    for k in range(max_depth + 1):
        dist = Counter(level_labels(succ, 1, k))
        for lbl, cnt in dist.items():
            if lbl <= max_label:
                grid[lbl - 1, k] = cnt

    fig, ax = plt.subplots(figsize=(8, 5))
    im = ax.imshow(grid, aspect="auto", origin="lower", cmap="viridis")
    ax.set_xlabel("depth k")
    ax.set_ylabel("label value")
    ax.set_yticks(range(max_label))
    ax.set_yticklabels(range(1, max_label + 1))
    ax.set_title("Refined label distribution of the Catalan tree")
    fig.colorbar(im, ax=ax, label="number of nodes")
    fig.tight_layout()
    fig.savefig("distribution.png", dpi=150)
    print("wrote distribution.png")


if __name__ == "__main__":
    main()


"""Visualization: counting-sequence growth of two isomorphic generating trees.

Plots the level counts of two differently-labelled but intertwined trees on a
log scale, showing that the two curves coincide exactly (Equal-counts theorem).
"""

from __future__ import annotations

from typing import Callable
import matplotlib.pyplot as plt


def level_count(succ: Callable[[int], list[int]], root: int, k: int) -> int:
    level = [root]
    for _ in range(k):
        nxt: list[int] = []
        for a in level:
            nxt.extend(succ(a))
        level = nxt
    return len(level)


def succ1(a: int) -> list[int]:
    return list(range(2, a + 2))


def succ2(b: int) -> list[int]:
    return list(range(101, b + 2))


def main() -> None:
    depths = list(range(9))
    c1 = [level_count(succ1, 1, k) for k in depths]
    c2 = [level_count(succ2, 100, k) for k in depths]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(depths, c1, "o-", label="tree 1 (labels a >= 1)", linewidth=2)
    ax.semilogy(depths, c2, "s--", label="tree 2 (labels b >= 100)", linewidth=2)
    ax.set_xlabel("depth k")
    ax.set_ylabel("number of nodes  c_k  (log scale)")
    ax.set_title("Isomorphic generating trees share a counting sequence")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("growth.png", dpi=150)
    print("wrote growth.png; counts:", c1)


if __name__ == "__main__":
    main()


"""Visualization: draw the first few levels of a generating tree.

Renders nodes level by level with edges from parents to children, annotating
each node with its label, to make the recursive succession rule tangible.
"""

from __future__ import annotations

from typing import Callable
import matplotlib.pyplot as plt


def succ(a: int) -> list[int]:
    return list(range(2, a + 2))


def build_levels(root: int, depth: int) -> list[list[int]]:
    levels = [[root]]
    for _ in range(depth):
        nxt: list[int] = []
        for a in levels[-1]:
            nxt.extend(succ(a))
        levels.append(nxt)
    return levels


def main() -> None:
    depth = 4
    levels = build_levels(1, depth)
    fig, ax = plt.subplots(figsize=(11, 6))

    positions: list[list[tuple[float, float]]] = []
    for d, level in enumerate(levels):
        n = len(level)
        xs = [(i - (n - 1) / 2) for i in range(n)]
        positions.append([(x, -d) for x in xs])

    # edges
    for d in range(depth):
        child_idx = 0
        for pi, a in enumerate(levels[d]):
            for _ in succ(a):
                x0, y0 = positions[d][pi]
                x1, y1 = positions[d + 1][child_idx]
                ax.plot([x0, x1], [y0, y1], color="gray", alpha=0.4, zorder=1)
                child_idx += 1

    # nodes
    for d, level in enumerate(levels):
        for (x, y), lbl in zip(positions[d], level):
            ax.scatter([x], [y], s=260, color="#1f77b4", zorder=2)
            ax.text(x, y, str(lbl), color="white", ha="center", va="center",
                    fontsize=8, zorder=3)

    ax.set_title("Generating tree with succ(a) = [2, ..., a+1]")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("tree.png", dpi=150)
    print("wrote tree.png; level sizes:", [len(l) for l in levels])


if __name__ == "__main__":
    main()
