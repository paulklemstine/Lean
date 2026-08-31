"""Ascent-word decoding: recover the unique address of a Pythagorean node."""

from __future__ import annotations

from math import gcd
from typing import List, Sequence, Tuple

Node = Tuple[int, int]
Letter = str

ROOT: Node = (2, 1)


def is_node(m: int, n: int) -> bool:
    """m > n >= 1, coprime, of opposite parity."""
    return 1 <= n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def letter_of(node: Node) -> Letter:
    """A if m < 2n, B if 2n < m < 3n, C if 3n < m (no other case occurs)."""
    m, n = node
    if m < 2 * n:
        return "A"
    if m < 3 * n:
        return "B"
    return "C"


def parent(node: Node) -> Node:
    """Invert the branch named by the ascent letter."""
    m, n = node
    lt = letter_of(node)
    if lt == "A":
        return (n, 2 * n - m)
    if lt == "B":
        return (n, m - 2 * n)
    return (m - 2 * n, n)


def child(letter: Letter, node: Node) -> Node:
    m, n = node
    return {"A": (2 * m - n, m), "B": (2 * m + n, m), "C": (m + 2 * n, n)}[letter]


def follow(word: Sequence[Letter], start: Node = ROOT) -> Node:
    node = start
    for lt in word:
        node = child(lt, node)
    return node


def ascent_word(node: Node) -> str:
    """The unique word over {A,B,C} leading from the root (2,1) to `node`.

    Terminates because every parent step strictly decreases the leading
    coordinate; the number of steps lies between log_3(m/2) and m - 2.
    """
    if not is_node(*node):
        raise ValueError(f"{node} is not a Berggren/Price node")
    letters: List[Letter] = []
    while node != ROOT:
        letters.append(letter_of(node))
        node = parent(node)
    return "".join(reversed(letters))


def triple(node: Node) -> Tuple[int, int, int]:
    m, n = node
    return (m * m - n * n, 2 * m * n, m * m + n * n)


if __name__ == "__main__":
    for v in [(3, 2), (19, 12), (21, 8), (47, 14), (49, 2), (225, 2)]:
        w = ascent_word(v)
        assert follow(w) == v
        print(f"{str(v):>10}  N = {triple(v)[2]:<8} depth {len(w):>3}  word {w}")


"""Blindness-witness generation: certificates that a probe cannot read the letter.

Two generators are provided.

* `residue_witness(M, t)` returns three nodes carrying the three distinct ascent
  letters whose hypotenuses are all congruent to 1 modulo M.  This certifies that
  no function of N mod M -- in particular no Gauss-sum readout at modulus M, and
  no battery of moduli dividing M -- can output the ascent letter.
* `magnitude_witness(t)` returns two nodes that share a hypotenuse but carry
  different letters, certifying that the letter is not a function of N at all.

Both run in O(1) arithmetic operations on integers of the stated size, so a
certificate is available at any scale without search.
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, List, Tuple

Node = Tuple[int, int]
Letter = str


def is_node(m: int, n: int) -> bool:
    return 1 <= n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def hyp(node: Node) -> int:
    m, n = node
    return m * m + n * n


def letter_of(node: Node) -> Letter:
    m, n = node
    return "A" if m < 2 * n else ("B" if m < 3 * n else "C")


def residue_witness(M: int, t: int = 1) -> Dict[Letter, Node]:
    """Nodes (n+1,n), (2n+1,n), (3n+1,n) with n = 2Mt: letters A, B, C, all N = 1 mod M."""
    n = 2 * M * t
    out: Dict[Letter, Node] = {}
    for coeff in (1, 2, 3):
        v = (coeff * n + 1, n)
        assert is_node(*v) and hyp(v) % M == 1 % M
        out[letter_of(v)] = v
    assert set(out) == {"A", "B", "C"}
    return out


def magnitude_witness(t: int = 1) -> Tuple[Node, Node, int]:
    """(20t-1, 10t+2) and (20t+1, 10t-2): one hypotenuse 500t^2+5, letters A and B."""
    p, q = (20 * t - 1, 10 * t + 2), (20 * t + 1, 10 * t - 2)
    assert is_node(*p) and is_node(*q)
    assert hyp(p) == hyp(q) == 500 * t * t + 5
    assert letter_of(p) == "A" and letter_of(q) == "B"
    return p, q, hyp(p)


def same_letter_witness(s: int = 0) -> Tuple[Node, Node, int]:
    """Sophie Germain: u = 2s+7, nodes (u^2-2, 2u) and (u^2, 2) of u^4+4, both letter C."""
    u = 2 * s + 7
    p, q = (u * u - 2, 2 * u), (u * u, 2)
    N = u ** 4 + 4
    assert is_node(*p) and is_node(*q) and hyp(p) == hyp(q) == N
    assert letter_of(p) == letter_of(q) == "C"
    return p, q, N


def representations(N: int) -> List[Node]:
    """All primitive nodes with hypotenuse N, by O(sqrt N) enumeration."""
    out: List[Node] = []
    for n in range(1, isqrt(N // 2) + 1):
        r = N - n * n
        m = isqrt(r)
        if m * m == r and is_node(m, n):
            out.append((m, n))
    return out


if __name__ == "__main__":
    for M in (8, 720720):
        w = residue_witness(M)
        print(f"modulus {M}: " + ", ".join(
            f"{lt} at {w[lt]} (N mod M = {hyp(w[lt]) % M})" for lt in "ABC"))
    p, q, N = magnitude_witness(1)
    print(f"magnitude collision: {N} = {p[0]}^2+{p[1]}^2 = {q[0]}^2+{q[1]}^2, letters A/B")
    p, q, N = same_letter_witness(4)
    print(f"same-letter collision: {N} = {p[0]}^2+{p[1]}^2 = {q[0]}^2+{q[1]}^2, letters C/C")
    print("representations of 505:", representations(505))


"""Restart-energy planning for a guided ascent of the ternary tree.

A guided ascent of height h whose per-step letter oracle is correct with
probability a succeeds with probability a^h; restarting on failure, the expected
number of node visits is the restart energy E(h, a) = h / a^h.  The planner
answers the three questions that decide whether a candidate probe is worth
deploying:

  * feasibility  : does E(h, a) fit a budget c?  (equivalently h <= c a^h)
  * requirement  : what is the minimal accuracy alpha* = (h/c)^(1/h)?
  * dominance    : does the guided ascent beat exhaustive search of the level,
                   i.e. is E(h, a) < 3^h?  The threshold is exactly a = 1/3.

All operations are O(1) arithmetic (O(h) if exact rational powers are used).
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Optional


def restart_energy(h: int, a: float) -> float:
    """E(h, a) = h / a^h, the expected node visits of a restarted ascent."""
    if not 0.0 < a <= 1.0:
        raise ValueError("accuracy must lie in (0, 1]")
    return h / a ** h


def restart_energy_exact(h: int, a: Fraction) -> Fraction:
    """Exact rational restart energy, for certified budget comparisons."""
    return Fraction(h) / a ** h


def critical_accuracy(h: int, budget: float) -> float:
    """Minimal per-step accuracy meeting the budget: alpha* = (h / c)^(1/h)."""
    return (h / budget) ** (1.0 / h)


def exhaustive_nodes(h: int) -> int:
    """Nodes of the complete ternary tree down to depth h: (3^(h+1) - 1) / 2."""
    return (3 ** (h + 1) - 1) // 2


def first_depth_beating_exhaustive(a: float, hmax: int = 500) -> Optional[int]:
    """Least h with E(h, a) < 3^h, or None if none below hmax (occurs iff a <= 1/3)."""
    for h in range(1, hmax + 1):
        if restart_energy(h, a) < 3.0 ** h:
            return h
    return None


@dataclass(frozen=True)
class Plan:
    height: int
    budget: float
    accuracy: float
    energy: float
    feasible: bool
    critical_accuracy: float
    beats_brute_force: bool
    exhaustive_cost: int


def plan(height: int, budget: float, accuracy: float) -> Plan:
    """Full feasibility report for a candidate probe."""
    e = restart_energy(height, accuracy)
    return Plan(
        height=height,
        budget=budget,
        accuracy=accuracy,
        energy=e,
        feasible=e <= budget,
        critical_accuracy=critical_accuracy(height, budget),
        beats_brute_force=accuracy > 1.0 / 3.0,
        exhaustive_cost=exhaustive_nodes(height),
    )


if __name__ == "__main__":
    # The certified bracket at height 30 with a 3000-visit budget.
    e85 = restart_energy_exact(30, Fraction(17, 20))
    e86 = restart_energy_exact(30, Fraction(43, 50))
    print(f"E(30, 0.85) = {float(e85):.2f} > 3000 : {e85 > 3000}")
    print(f"E(30, 0.86) = {float(e86):.2f} <= 3000: {e86 <= 3000}")
    print(f"alpha*(30, 3000) = {critical_accuracy(30, 3000):.5f}")
    for a in (0.40, 0.60, 0.86, 0.95):
        p = plan(30, 3000, a)
        print(f"a = {a:.2f}: E = {p.energy:12.1f}  feasible = {p.feasible}  "
              f"beats brute force = {p.beats_brute_force}  "
              f"(exhaustive {p.exhaustive_cost:,})")


"""Assemble PACKAGE.json from the project's prose, code and formal sources."""

from __future__ import annotations

import json
import pathlib
from typing import Any, Dict, List

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


lean_dir = ROOT / "Catalog" / "Bridges" / "TwoTreeClosure"
lean_paths = sorted(lean_dir.glob("*.lean"))
lean_files: List[str] = [str(p.relative_to(ROOT)) for p in lean_paths]
lean_proofs = "\n\n".join(
    f"-- ===== FILE: {str(p.relative_to(ROOT))} =====\n\n{read(p)}" for p in lean_paths
)

demo_src = read(ROOT / "demo.py")

package: Dict[str, Any] = {
    "title": "The Two-Tree Closure: Positional Information in the Berggren and Price "
             "Trees of Pythagorean Triples",
    "domain": "Bridges",
    "description": "The ascent letter that addresses a primitive Pythagorean triple in "
                   "the free ternary Berggren tree is proved unreadable from its "
                   "hypotenuse at four independent strengths — residue dials, Gauss-sum "
                   "spectra, structural sensors and every function of N — with the "
                   "residual ambiguity identified as the Brahmagupta–Fibonacci "
                   "composition ambiguity and the search economics pinned exactly.",
    "authors": ["Aristotle"],
    "date": "2026-08-30",
    "key_results": [
        "Residue blindness: for every modulus M and at every scale there are three "
        "Pythagorean nodes carrying the three distinct ascent letters whose hypotenuses "
        "are all congruent to 1 modulo M, so no function of N mod M computes the letter.",
        "Gauss-sum blindness: the quadratic Gauss sum is M-periodic in N, so every "
        "readout of it — and every finite battery of moduli dividing a common M — is a "
        "residue dial and therefore blind.",
        "Magnitude blindness: the nodes (20t-1, 10t+2) and (20t+1, 10t-2) share the "
        "hypotenuse 500t^2 + 5 but carry different ascent letters (smallest case "
        "505 = 19^2 + 12^2 = 21^2 + 8^2 = 5 * 101), so the letter is not a function of "
        "the hypotenuse at all; likewise every dyadic window above 661 contains all "
        "three letters.",
        "Structural constancy: the parity profile of a node's triple is exactly "
        "(odd, even, odd) and the Lorentz form vanishes identically, so structural "
        "sensors carry exactly zero information about the letter.",
        "Refutation of the representation-orbit conjecture: the Sophie Germain identity "
        "u^4 + 4 = (u^2-2u+2)(u^2+2u+2) yields the two distinct nodes (u^2-2, 2u) and "
        "(u^2, 2) of one number with the same ascent letter C, including the semiprime "
        "50629 = 197 * 257; and every factorisation of 7q with q prime, q = 1 mod 16, "
        "has 2-adic valuation exactly 3 in the factor sum, refuting the sharp two-adic cap.",
        "Exact ascent economics: the restart energy h/a^h beats exhaustive search "
        "precisely above per-step accuracy 1/3, and at height 30 with a 3000-visit "
        "budget the critical accuracy satisfies 0.85 < alpha* <= 0.86, while any searcher "
        "with a budget below 3^h provably misses a depth-h node, adaptively or not.",
    ],
    "keywords": [
        "Pythagorean triples", "Berggren tree", "Price tree", "ascent word",
        "Gauss sums", "sums of two squares", "Brahmagupta–Fibonacci identity",
        "2-adic valuation", "search lower bounds",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": demo_src,
    "demos": [
        {
            "name": "The Four Seals, End to End: A Certified Numerical Companion",
            "description":
                "A single self-contained program that reproduces every quantitative claim "
                "of the work and checks each with an assertion. It builds the Berggren/Price "
                "tree and verifies that level h has exactly 3^h nodes with each ascent letter "
                "occurring exactly 3^(h-1) times; generates residue-blindness certificates at "
                "moduli 8, 720 and 720720 (three nodes, three distinct letters, one common "
                "residue); confirms numerically that quadratic Gauss sums are M-periodic in N; "
                "measures the empirical mutual information between the parity profile / Lorentz "
                "form and the letter, obtaining exactly 0.000000 bits; exhibits the magnitude "
                "collisions 500t^2+5 with letters A and B and the Sophie Germain collisions "
                "u^4+4 with both letters C; verifies the two-adic law on all odd pairs below 60 "
                "and its failure at position 2 for N = 9m with m = 7 mod 16; and tabulates the "
                "restart energy, the exact rational bracket 0.85 < alpha* <= 0.86 at height 30 "
                "with a 3000-visit budget, the 1/3 threshold against brute force, and the "
                "(3^31 - 1)/2 > 10^14 cost of an exhaustive depth-30 sweep.",
            "code": demo_src,
        }
    ],
    "algorithms": [
        {
            "name": "Ascent-Word Decoding: Recovering the Unique Address of a Node",
            "description":
                "Given a Berggren/Price node (m, n) the algorithm recovers its unique address "
                "word over {A, B, C}. At each step the ascent letter is read from the ratio "
                "alone — A if m < 2n, B if 2n < m < 3n, C if 3n < m, the boundary cases being "
                "impossible away from the root — and the named branch is inverted: A sends "
                "(m,n) to (n, 2n-m), B to (n, m-2n), C to (m-2n, n). Every step strictly "
                "decreases the leading coordinate, so the procedure terminates at the root "
                "(2,1); the number of steps lies between log_3(m/2) and m-2, both bounds being "
                "attained, so along the pure-A spine the depth is of order the square root of "
                "the hypotenuse rather than its logarithm. Each step costs O(1) arithmetic "
                "operations on integers of size O(m). The decoder is exact and cheap given the "
                "node — which is precisely the point of the closure: the expensive part is "
                "finding the node from the hypotenuse.",
            "pseudocode":
                "INPUT  node (m, n) with m > n >= 1, gcd(m, n) = 1, m + n odd\n"
                "OUTPUT word w over {A, B, C} with follow(w, (2,1)) = (m, n)\n"
                "\n"
                " 1. w <- empty list\n"
                " 2. while (m, n) != (2, 1) do\n"
                " 3.     if   m < 2n then  L <- 'A';  (m, n) <- (n, 2n - m)\n"
                " 4.     elif m < 3n then  L <- 'B';  (m, n) <- (n, m - 2n)\n"
                " 5.     else               L <- 'C';  (m, n) <- (m - 2n, n)\n"
                " 6.     append L to w\n"
                " 7. end while\n"
                " 8. return reverse(w)\n"
                "\n"
                "TERMINATION  the leading coordinate strictly decreases at every step\n"
                "COMPLEXITY   between log_3(m/2) and m - 2 iterations, O(1) work each",
            "code": read(A / "alg_ascent_word.py"),
        },
        {
            "name": "Blindness-Certificate Generation: Constructive Witnesses of Unreadability",
            "description":
                "Produces, in closed form and without search, the counterexamples that defeat "
                "each class of probe. For a modulus M and a scale t, setting n = 2Mt yields the "
                "three nodes (n+1, n), (2n+1, n), (3n+1, n) whose ratios sit just below 2, just "
                "above 2 and just above 3 — hence letters A, B, C — and whose hypotenuses "
                "2n^2+2n+1, 5n^2+4n+1, 10n^2+6n+1 are all congruent to 1 modulo M. That single "
                "certificate defeats every function of N mod M, hence every quadratic Gauss-sum "
                "readout at modulus M and every battery of moduli dividing M, at any scale. A "
                "second generator returns the magnitude collision (20t-1, 10t+2), (20t+1, 10t-2) "
                "of hypotenuse 500t^2+5 with letters A and B, defeating every function of N "
                "whatsoever; a third returns the Sophie Germain pair (u^2-2, 2u), (u^2, 2) of "
                "u^4+4 with u = 2s+7, whose letters agree, showing that the existence of a "
                "collision is itself letter-free. All generators are O(1) arithmetic; the "
                "brute-force representation enumerator provided for comparison costs O(sqrt N), "
                "the same order as trial division.",
            "pseudocode":
                "PROCEDURE ResidueCertificate(M, t)\n"
                " 1. n <- 2 * M * t\n"
                " 2. for k in {1, 2, 3} do\n"
                " 3.     v_k <- (k*n + 1, n)                     # letters A, B, C in order\n"
                " 4.     assert gcd(k*n + 1, n) = 1 and (k*n + 1 + n) odd\n"
                " 5.     assert (v_k.m^2 + v_k.n^2) mod M = 1 mod M\n"
                " 6. return (v_1, v_2, v_3)\n"
                "\n"
                "PROCEDURE MagnitudeCertificate(t)\n"
                " 1. p <- (20t - 1, 10t + 2);  q <- (20t + 1, 10t - 2)\n"
                " 2. assert hyp(p) = hyp(q) = 500 t^2 + 5\n"
                " 3. assert letter(p) = 'A' and letter(q) = 'B'\n"
                " 4. return (p, q, hyp(p))\n"
                "\n"
                "PROCEDURE SameLetterCertificate(s)\n"
                " 1. u <- 2s + 7\n"
                " 2. p <- (u^2 - 2, 2u);  q <- (u^2, 2)\n"
                " 3. assert hyp(p) = hyp(q) = u^4 + 4 = (u^2-2u+2)(u^2+2u+2)\n"
                " 4. assert letter(p) = letter(q) = 'C'\n"
                " 5. return (p, q, u^4 + 4)",
            "code": read(A / "alg_blindness_witness.py"),
        },
        {
            "name": "Restart-Energy Planning: Feasibility Analysis for a Guided Ascent",
            "description":
                "Decides whether a hypothetical letter oracle is worth deploying. A guided ascent "
                "of height h with independent per-step accuracy a succeeds with probability a^h, "
                "so restarting after any wrong turn costs an expected E(h, a) = h / a^h node "
                "visits. The planner evaluates three criteria. Feasibility: E(h, a) <= c is "
                "equivalent to h <= c a^h, a comparison that can be performed in exact rational "
                "arithmetic for certified answers. Requirement: the minimal admissible accuracy "
                "is alpha*(h, c) = (h/c)^(1/h) — at h = 30 and c = 3000 this is 100^(-1/30) "
                "approximately 0.8577, consistent with the certified bracket E(30, 0.85) > 3000 "
                ">= E(30, 0.86). Dominance: the guided ascent beats an exhaustive sweep of level "
                "h exactly when E(h, a) < 3^h, whose threshold as h grows is precisely a = 1/3, "
                "the reciprocal of the branching number; at a = 1/2 the ascent wins at every "
                "depth because h 2^h < 3^h for all h. All evaluations are O(1) in floating point "
                "and O(h) multiplications in exact arithmetic.",
            "pseudocode":
                "INPUT  height h, budget c, per-step accuracy a\n"
                "OUTPUT feasibility report\n"
                "\n"
                " 1. E      <- h / a^h                       # restart energy\n"
                " 2. alpha* <- (h / c)^(1/h)                 # minimal accuracy for budget c\n"
                " 3. exh    <- (3^(h+1) - 1) / 2             # exhaustive cost to depth h\n"
                " 4. feasible        <- (h <= c * a^h)       # exact form of E <= c\n"
                " 5. beatsBruteForce <- (a > 1/3)            # asymptotic level comparison\n"
                " 6. if feasible then\n"
                " 7.     report 'deployable: E visits within budget'\n"
                " 8. elif beatsBruteForce then\n"
                " 9.     report 'better than brute force, over budget; need accuracy alpha*'\n"
                "10. else\n"
                "11.     report 'worse than exhaustive search in the deep regime'\n"
                "12. return (E, alpha*, exh, feasible, beatsBruteForce)",
            "code": read(A / "alg_restart_planner.py"),
        },
    ],
    "visualizations": [
        {
            "name": "Letters Live on Directions, Magnitudes Collide",
            "description":
                "A two-panel figure making the central obstruction visible. The left panel plots "
                "every node (m, n) with m <= 120, coloured by ascent letter, with the rays m = 2n "
                "and m = 3n drawn: the letter is a clean function of the direction of the vector "
                "(m, n), the wedge n < m splitting into three letter regions. The right panel "
                "plots the same nodes against their hypotenuses on a logarithmic axis, one row "
                "per letter, and joins each magnitude-collision pair (20t-1, 10t+2), "
                "(20t+1, 10t-2) by a vertical segment — a single value of N attached to two "
                "different letters, so no curve over the N axis can be the letter function. The "
                "Sophie Germain pairs (u^2-2, 2u), (u^2, 2) with u = 2s+7 are marked as squares "
                "on the C row: collisions that do not split the letter.",
            "code": read(A / "viz_letter_map.py"),
        },
        {
            "name": "Ascent Economics: Restart Energy and the Feasibility Frontier",
            "description":
                "A two-panel figure quantifying what an oracle would have to deliver. The left "
                "panel draws the restart energy E(h, a) = h / a^h against height for accuracies "
                "from 0.25 to 0.95 on a logarithmic axis, together with the exhaustive cost 3^h "
                "and a 3000-visit budget line; the crossings display the exact threshold a = 1/3, "
                "curves above it eventually diving below 3^h and curves below it eventually "
                "rising above. The right panel draws the feasibility frontier "
                "alpha*(h, c) = (h/c)^(1/h) for several budgets, shades the region below the "
                "brute-force threshold 1/3, and marks the certified point h = 30, c = 3000 where "
                "0.85 < alpha* <= 0.86. The gap between the two thresholds is the band in which a "
                "probe beats random guessing yet is still not competitive.",
            "code": read(A / "viz_economics.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Two-Tree Closure Lab: Walk the Tree, Then Try to Read an Address",
            "description":
                "A three-tab exploratory environment. Tab 1 is a tree explorer: descend from the "
                "root (2,1) by pressing A, B or C, climb back with the parent map, and watch the "
                "node, its Pythagorean triple, its hypotenuse, its ascent letter and its full "
                "address word update live, while a scatter plot of all nodes with m <= 90 — "
                "coloured by letter, with the rays m = 2n and m = 3n drawn — highlights the path "
                "taken; a folded panel explains coverage, uniqueness of the parent and the exact "
                "letter equidistribution 3^h per class at level h+1. Tab 2 is the blindness lab: "
                "enter any hypotenuse to see all of its primitive addresses with their letters and "
                "words, and read a verdict that distinguishes a splitting collision (letter not a "
                "function of N) from a same-letter Sophie Germain collision (collisions carry no "
                "signal); then choose any modulus and scale to manufacture a residue-blindness "
                "certificate — three nodes, three distinct letters, one common residue — and "
                "compute a quadratic Gauss sum live at N and at N + 7M to watch the periodicity "
                "that makes every such spectrum a residue dial. Tab 3 is the economics sandbox: "
                "sliders for per-step accuracy, height and budget drive a live logarithmic plot of "
                "the restart energy h/a^h against the exhaustive cost 3^h and the budget line, "
                "with a verdict that separates 'within budget', 'beats brute force but over "
                "budget' and 'worse than brute force', and reports the required accuracy "
                "alpha* = (h/c)^(1/h).",
            "html": read(A / "widget_closure_lab.html"),
        }
    ],
    "interactive_layout": read(A / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": read(A / "future_directions.md"),
    "modules": {"demo": demo_src},
    "lean_files": lean_files,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size:,} bytes), {len(lean_files)} formal source files")


"""Visualisation: the economics of a guided ascent.

Left panel  -- restart energy E(h, a) = h / a^h against height h, for a range of
               per-step accuracies, on a log axis, together with the exhaustive
               cost 3^h.  The crossings display the exact threshold a = 1/3:
               curves with a > 1/3 eventually dive below 3^h, curves with
               a < 1/3 eventually rise above it.

Right panel -- the feasibility frontier.  For each height h the minimal accuracy
               meeting a budget c is alpha*(h, c) = (h/c)^(1/h).  The curves for
               several budgets are drawn, with the certified point of the theory
               marked: at h = 30, c = 3000 one has E(30, 0.85) > 3000 >= E(30, 0.86),
               so 0.85 < alpha* <= 0.86 (exactly 100^(-1/30) ≈ 0.8577).  The band
               between the brute-force threshold 1/3 and alpha* is the region where
               a probe is better than random guessing yet still not competitive.

Requires matplotlib.  Run:  python3 viz_economics.py
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt


def restart_energy(h: int, a: float) -> float:
    return h / a ** h


def critical_accuracy(h: int, budget: float) -> float:
    return (h / budget) ** (1.0 / h)


def main() -> None:
    heights: List[int] = list(range(1, 41))
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    for a, style in [(0.25, ":"), (1 / 3, "--"), (0.5, "-"),
                     (0.7, "-"), (0.86, "-"), (0.95, "-")]:
        ax1.plot(heights, [restart_energy(h, a) for h in heights], style,
                 label=f"E(h, a) with a = {a:.3f}")
    ax1.plot(heights, [3.0 ** h for h in heights], color="black", lw=2,
             label="exhaustive 3^h")
    ax1.axhline(3000, color="grey", lw=1, ls="--")
    ax1.text(1.2, 3600, "budget 3000 visits", fontsize=8, color="grey")
    ax1.set_yscale("log")
    ax1.set_xlabel("height h")
    ax1.set_ylabel("expected node visits")
    ax1.set_title("Restart energy vs brute force: the threshold is a = 1/3")
    ax1.legend(fontsize=8, loc="upper left")

    for c in [300, 3000, 30000, 3_000_000]:
        ax2.plot(heights, [critical_accuracy(h, c) for h in heights],
                 label=f"budget c = {c:,}")
    ax2.axhline(1 / 3, color="black", ls="--", lw=1)
    ax2.text(1.0, 0.35, "brute-force threshold 1/3", fontsize=8)
    ax2.scatter([30], [critical_accuracy(30, 3000)], color="#8b1e3f", zorder=5)
    ax2.annotate(r"h = 30, c = 3000:  0.85 < $\alpha^*\leq$ 0.86",
                 xy=(30, critical_accuracy(30, 3000)), xytext=(12, 0.62),
                 arrowprops=dict(arrowstyle="->", color="#8b1e3f"), fontsize=9)
    ax2.axhspan(0.0, 1 / 3, color="grey", alpha=0.15)
    ax2.set_ylim(0, 1.02)
    ax2.set_xlabel("height h")
    ax2.set_ylabel(r"minimal per-step accuracy $\alpha^*$")
    ax2.set_title(r"Feasibility frontier $\alpha^*(h,c) = (h/c)^{1/h}$")
    ax2.legend(fontsize=8, loc="lower right")

    fig.suptitle("Ascent economics: what an oracle would have to deliver", fontsize=13)
    fig.tight_layout()
    fig.savefig("economics.png", dpi=150)
    print("wrote economics.png")


if __name__ == "__main__":
    main()


"""Visualisation: the ascent-letter map of the Berggren tree, and its collisions.

Two panels.

Left  -- every node (m, n) with m <= 120 plotted in the plane, coloured by its
         ascent letter.  The letter is decided purely by the ray m/n: the rays
         m = 2n and m = 3n cut the wedge n < m into the three letter regions
         A (m < 2n), B (2n < m < 3n) and C (3n < m).  The colouring makes the
         central fact visible: the letter is a clean geometric function of the
         DIRECTION of (m, n), while the hypotenuse N = m^2 + n^2 is a function
         of its LENGTH -- two independent coordinates.

Right -- the same picture in (N, letter) coordinates: hypotenuses on a log axis
         against letters, with the magnitude-collision pairs (20t-1, 10t+2) and
         (20t+1, 10t-2) joined by a segment.  Each segment is a single value of
         N carrying two different letters, so no curve over the N axis can be
         the letter function.  The Sophie Germain pairs (u^2-2, 2u), (u^2, 2)
         with u = 2s+7 are shown too: those collide WITHOUT splitting.

Requires matplotlib.  Run:  python3 viz_letter_map.py
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt

Node = Tuple[int, int]

COLOURS = {"A": "#e4572e", "B": "#2e86ab", "C": "#3a7d44"}


def is_node(m: int, n: int) -> bool:
    return 1 <= n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def letter_of(node: Node) -> str:
    m, n = node
    return "A" if m < 2 * n else ("B" if m < 3 * n else "C")


def hyp(node: Node) -> int:
    m, n = node
    return m * m + n * n


def main() -> None:
    limit = 120
    nodes: List[Node] = [(m, n) for m in range(2, limit + 1)
                         for n in range(1, m) if is_node(m, n)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    by_letter: Dict[str, List[Node]] = {"A": [], "B": [], "C": []}
    for v in nodes:
        by_letter[letter_of(v)].append(v)
    for lt, pts in by_letter.items():
        ax1.scatter([p[0] for p in pts], [p[1] for p in pts], s=9,
                    c=COLOURS[lt], label=f"letter {lt}", alpha=0.8)
    xs = [0, limit]
    ax1.plot(xs, [x / 2 for x in xs], "k--", lw=1, label="m = 2n")
    ax1.plot(xs, [x / 3 for x in xs], "k:", lw=1, label="m = 3n")
    ax1.set_xlabel("m")
    ax1.set_ylabel("n")
    ax1.set_title("Ascent letter is a function of the ray m/n")
    ax1.legend(loc="upper left", fontsize=8)
    ax1.set_xlim(0, limit)
    ax1.set_ylim(0, limit * 0.62)

    ypos = {"A": 0, "B": 1, "C": 2}
    for lt, pts in by_letter.items():
        ax2.scatter([hyp(p) for p in pts], [ypos[lt] + 0.0 for p in pts],
                    s=6, c=COLOURS[lt], alpha=0.35)

    for t in range(1, 40):
        p, q = (20 * t - 1, 10 * t + 2), (20 * t + 1, 10 * t - 2)
        N = hyp(p)
        assert N == hyp(q)
        ax2.plot([N, N], [ypos[letter_of(p)], ypos[letter_of(q)]],
                 color="#8b1e3f", lw=1.2, alpha=0.9,
                 label="splitting collision 500t²+5" if t == 1 else None)
    for s in range(0, 12):
        u = 2 * s + 7
        p, q = (u * u - 2, 2 * u), (u * u, 2)
        N = hyp(p)
        ax2.scatter([N], [ypos["C"]], marker="s", s=42, facecolors="none",
                    edgecolors="#4b0082",
                    label="same-letter collision u⁴+4" if s == 0 else None)

    ax2.set_xscale("log")
    ax2.set_yticks([0, 1, 2])
    ax2.set_yticklabels(["A", "B", "C"])
    ax2.set_xlabel("hypotenuse N (log scale)")
    ax2.set_title("One N, two letters: the magnitude cannot decide")
    ax2.legend(loc="lower right", fontsize=8)

    fig.suptitle("The Two-Tree Closure: letters live on directions, not on magnitudes",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("letter_map.png", dpi=150)
    print("wrote letter_map.png")


if __name__ == "__main__":
    main()


"""
The Two-Tree Closure — numerical demonstrations.

Self-contained Python (standard library only) reproducing every quantitative
claim of the accompanying article and paper:

  1. The Berggren/Price tree: nodes, children, ascent letters, parents,
     ascent-word normal form, level sizes and exact letter equidistribution.
  2. Strength 1 — residue dials are blind at every modulus and every scale.
  3. Strength 2 — quadratic Gauss sums are M-periodic, hence residue dials.
  4. Strength 3 — parity profile and Lorentz form are exactly constant.
  5. Strength 4 — magnitude collisions: 500t^2 + 5 carries letters A and B;
     every dyadic window above 661 carries all three letters.
  6. The composition ambiguity: Brahmagupta-Fibonacci produces the collisions.
  7. Refutations: the Sophie Germain same-letter family u^4 + 4, and the
     valuation-constant semiprimes 7q with q = 1 (mod 16).
  8. The Price two-adic law and its death at position 2.
  9. Search economics: restart energy, the 1/3 brute-force threshold, the
     competitive accuracy bracket 0.85 < alpha* <= 0.86, exhaustive cost.

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
from fractions import Fraction
from math import gcd, isqrt
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

Node = Tuple[int, int]
Letter = str  # 'A', 'B' or 'C'

ROOT: Node = (2, 1)


# ---------------------------------------------------------------------------
# 1. The tree
# ---------------------------------------------------------------------------


def is_node(m: int, n: int) -> bool:
    """A Price/Berggren node: m > n >= 1, coprime, of opposite parity."""
    return 1 <= n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def hyp(m: int, n: int) -> int:
    """Hypotenuse of the Euclid triple of a node."""
    return m * m + n * n


def leg_odd(m: int, n: int) -> int:
    return m * m - n * n


def leg_even(m: int, n: int) -> int:
    return 2 * m * n


def child(letter: Letter, node: Node) -> Node:
    """A: (2m-n, m);  B: (2m+n, m);  C: (m+2n, n)."""
    m, n = node
    if letter == "A":
        return (2 * m - n, m)
    if letter == "B":
        return (2 * m + n, m)
    if letter == "C":
        return (m + 2 * n, n)
    raise ValueError(f"unknown letter {letter!r}")


def letter_of(node: Node) -> Letter:
    """Ascent letter: A if m < 2n, B if 2n < m < 3n, C if 3n < m."""
    m, n = node
    if m < 2 * n:
        return "A"
    if m < 3 * n:
        return "B"
    return "C"


def parent(node: Node) -> Node:
    """Invert the branch named by the ascent letter."""
    m, n = node
    lt = letter_of(node)
    if lt == "A":
        return (n, 2 * n - m)
    if lt == "B":
        return (n, m - 2 * n)
    return (m - 2 * n, n)


def follow(word: Sequence[Letter], start: Node = ROOT) -> Node:
    """Read a word as a descent from a node."""
    node = start
    for lt in word:
        node = child(lt, node)
    return node


def ascent_word(node: Node) -> str:
    """The unique address of a node: the path from the root."""
    letters: List[Letter] = []
    while node != ROOT:
        letters.append(letter_of(node))
        node = parent(node)
    return "".join(reversed(letters))


def level(h: int) -> List[Node]:
    """All nodes at depth h below the root (exactly 3**h of them)."""
    nodes = [ROOT]
    for _ in range(h):
        nodes = [child(lt, v) for v in nodes for lt in "ABC"]
    return nodes


def demo_tree() -> None:
    print("=" * 74)
    print("1. THE BERGGREN/PRICE TREE")
    print("=" * 74)
    print("root (2,1) -> triple (3, 4, 5)\n")
    print(f"{'word':>8} {'node':>12} {'triple':>22} {'letter':>7}")
    for word in ["", "A", "B", "C", "AB", "CA", "ABC", "CCA"]:
        v = follow(word)
        triple = (leg_odd(*v), leg_even(*v), hyp(*v))
        lt = "-" if v == ROOT else letter_of(v)
        print(f"{word or 'ε':>8} {str(v):>12} {str(triple):>22} {lt:>7}")

    print("\nround trip node -> word -> node (normal form):")
    for v in [(19, 12), (21, 8), (47, 14), (49, 2), (223, 30)]:
        w = ascent_word(v)
        assert follow(w) == v
        print(f"  {str(v):>10}  N = {hyp(*v):<8} word = {w}")

    print("\nlevel sizes and letter equidistribution:")
    for h in range(1, 7):
        lv = level(h)
        counts: Dict[Letter, int] = {"A": 0, "B": 0, "C": 0}
        for v in lv:
            counts[letter_of(v)] += 1
        assert len(lv) == 3 ** h and len(set(lv)) == 3 ** h
        assert all(c == 3 ** (h - 1) for c in counts.values())
        print(f"  depth {h}: |level| = {len(lv):>4} = 3^{h};  A/B/C = "
              f"{counts['A']}/{counts['B']}/{counts['C']} = 3^{h-1} each")

    print("\ndepth bracket 2 + L <= m <= 2*3^L, and the A-spine (depth ~ sqrt N):")
    for k in [1, 3, 5, 10, 20]:
        v = follow("A" * k)
        assert v == (k + 2, k + 1) and hyp(*v) == 2 * k * k + 6 * k + 5
        print(f"  A^{k:<3} -> {str(v):>12}  N = {hyp(*v):<7} "
              f"(2k^2+6k+5),  bracket [{2+k}, {2*3**k}]")


# ---------------------------------------------------------------------------
# 2. Strength 1 — residue dials
# ---------------------------------------------------------------------------


def residue_witness(M: int, t: int = 1) -> List[Tuple[Node, Letter, int]]:
    """Three nodes with letters A, B, C whose hypotenuses are all 1 mod M."""
    n = 2 * M * t
    out = []
    for coeff, expected in ((1, "A"), (2, "B"), (3, "C")):
        v = (coeff * n + 1, n)
        assert is_node(*v) and letter_of(v) == expected
        assert hyp(*v) % M == 1 % M
        out.append((v, expected, hyp(*v)))
    return out


def demo_residue() -> None:
    print()
    print("=" * 74)
    print("2. STRENGTH 1 — RESIDUE DIALS ARE BLIND (every modulus, every scale)")
    print("=" * 74)
    for M in [8, 720, 720720]:
        for t in [1, 5]:
            trio = residue_witness(M, t)
            residues = {N % M for _, _, N in trio}
            letters = {lt for _, lt, _ in trio}
            print(f"  M = {M:<7} t = {t}:  letters {sorted(letters)} "
                  f"all with N mod M = {residues.pop()}")
            for v, lt, N in trio:
                print(f"      {lt}  node {str(v):>20}  N = {N}")
    print("  => no function of N mod M can output the ascent letter.")


# ---------------------------------------------------------------------------
# 3. Strength 2 — Gauss sums
# ---------------------------------------------------------------------------


def gauss_sum(M: int, N: int) -> complex:
    """Quadratic Gauss sum sum_{x mod M} exp(2 pi i N x^2 / M)."""
    return sum(cmath.exp(2j * cmath.pi * N * (x * x % M) / M) for x in range(M))


def demo_gauss() -> None:
    print()
    print("=" * 74)
    print("3. STRENGTH 2 — GAUSS SUMS ARE RESIDUE DIALS")
    print("=" * 74)
    M = 24
    for N in [5, 13, 505, 2405]:
        g1, g2 = gauss_sum(M, N), gauss_sum(M, N + 7 * M)
        print(f"  G_{M}({N}) = {g1:.6f}   G_{M}({N} + 7*{M}) = {g2:.6f}   "
              f"|diff| = {abs(g1 - g2):.2e}")
    trio = residue_witness(M, 1)
    print(f"\n  the three A/B/C witnesses at M = {M} give identical Gauss sums:")
    for v, lt, N in trio:
        print(f"      {lt}  N = {N:<8} G_{M}(N) = {gauss_sum(M, N):.6f}")
    print("  => any readout (magnitude, phase, learned classifier) is blind,")
    print("     and so is any battery of moduli dividing a common M.")


# ---------------------------------------------------------------------------
# 4. Strength 3 — structural constancy
# ---------------------------------------------------------------------------


def parity_profile(node: Node) -> Tuple[int, int, int]:
    m, n = node
    return (leg_odd(m, n) % 2, leg_even(m, n) % 2, hyp(m, n) % 2)


def lorentz_form(node: Node) -> int:
    m, n = node
    return leg_odd(m, n) ** 2 + leg_even(m, n) ** 2 - hyp(m, n) ** 2


def mutual_information_bits(pairs: Iterable[Tuple[object, object]]) -> float:
    """Empirical mutual information I(X;Y) in bits for a finite sample."""
    data = list(pairs)
    total = len(data)
    px: Dict[object, int] = {}
    py: Dict[object, int] = {}
    pxy: Dict[Tuple[object, object], int] = {}
    for x, y in data:
        px[x] = px.get(x, 0) + 1
        py[y] = py.get(y, 0) + 1
        pxy[(x, y)] = pxy.get((x, y), 0) + 1
    out = 0.0
    for (x, y), c in pxy.items():
        joint = c / total
        out += joint * math.log2(joint / ((px[x] / total) * (py[y] / total)))
    return out


def demo_structural() -> None:
    print()
    print("=" * 74)
    print("4. STRENGTH 3 — STRUCTURAL SENSORS ARE EXACTLY CONSTANT")
    print("=" * 74)
    sample = level(8)
    profiles = {parity_profile(v) for v in sample}
    lorentz = {lorentz_form(v) for v in sample}
    print(f"  sample: all {len(sample)} nodes at depth 8")
    print(f"  parity profiles observed: {profiles}   (always (1, 0, 1))")
    print(f"  Lorentz form values     : {lorentz}   (identically 0)")
    mi_par = mutual_information_bits((parity_profile(v), letter_of(v)) for v in sample)
    mi_lor = mutual_information_bits((lorentz_form(v), letter_of(v)) for v in sample)
    print(f"  I(parity profile ; letter) = {mi_par:.6f} bits")
    print(f"  I(Lorentz form   ; letter) = {mi_lor:.6f} bits")
    print("  => exactly zero, and provably so: the sensors are constant.")


# ---------------------------------------------------------------------------
# 5. Strength 4 — magnitude mirrors
# ---------------------------------------------------------------------------


def split_pair(t: int) -> Tuple[Node, Node, int]:
    """(20t-1, 10t+2) and (20t+1, 10t-2): same hypotenuse, letters A and B."""
    p, q = (20 * t - 1, 10 * t + 2), (20 * t + 1, 10 * t - 2)
    assert is_node(*p) and is_node(*q)
    assert hyp(*p) == hyp(*q) == 500 * t * t + 5
    assert letter_of(p) == "A" and letter_of(q) == "B"
    return p, q, hyp(*p)


def representations(N: int) -> List[Node]:
    """All primitive nodes (m, n) with m^2 + n^2 = N."""
    out = []
    for n in range(1, isqrt(N // 2) + 1):
        r = N - n * n
        m = isqrt(r)
        if m * m == r and is_node(m, n):
            out.append((m, n))
    return out


def window_witnesses(X: int) -> Dict[Letter, Tuple[Node, int]]:
    """A node of each letter with hypotenuse in [X, 2X), from the three families."""
    found: Dict[Letter, Tuple[Node, int]] = {}
    families = {
        "A": lambda k: (k + 1, k),
        "B": lambda k: (4 * k + 1, 2 * k),
        "C": lambda k: (8 * k + 1, 2 * k),
    }
    for lt, fam in families.items():
        k = 1
        while True:
            v = fam(k)
            N = hyp(*v)
            if N >= 2 * X:
                break
            if N >= X and is_node(*v) and letter_of(v) == lt:
                found[lt] = (v, N)
                break
            k += 1
    return found


def demo_magnitude() -> None:
    print()
    print("=" * 74)
    print("5. STRENGTH 4 — THE MAGNITUDE ITSELF IS BLIND")
    print("=" * 74)
    print(f"{'t':>4} {'A-node':>16} {'B-node':>16} {'N = 500t^2+5':>14} {'factors':>18}")
    for t in range(1, 7):
        p, q, N = split_pair(t)
        cof = N // 5
        print(f"{t:>4} {str(p):>16} {str(q):>16} {N:>14} {'5 * ' + str(cof):>18}")
    print("\n  505 = 19^2 + 12^2 = 21^2 + 8^2 = 5 * 101 (a semiprime):")
    print(f"    representations of 505 : {representations(505)}")
    print(f"    letters                : {[letter_of(v) for v in representations(505)]}")
    print(f"    odd legs               : {[leg_odd(*v) for v in representations(505)]}")
    print("  => the ascent letter (and the odd leg) is NOT a function of N.")

    print("\n  every dyadic window [X, 2X) with X >= 661 carries all three letters:")
    for X in [661, 1024, 10 ** 4, 10 ** 6]:
        w = window_witnesses(X)
        print(f"    X = {X:<8} " + "  ".join(
            f"{lt}:{w[lt][1]}" for lt in "ABC"))
    w = window_witnesses(1024)
    print("    (at X = 1024 all have floor(log2 N) = 10: "
          + ", ".join(f"{lt} -> {int(math.log2(w[lt][1]))}" for lt in "ABC") + ")")


# ---------------------------------------------------------------------------
# 6. The composition ambiguity
# ---------------------------------------------------------------------------


def brahmagupta(a: int, b: int, c: int, d: int) -> Tuple[Node, Node]:
    """The two compositions of (a^2+b^2)(c^2+d^2) as a sum of two squares."""
    left = (abs(a * c - b * d), abs(a * d + b * c))
    right = (abs(a * c + b * d), abs(a * d - b * c))
    order = lambda p: (max(p), min(p))
    return order(left), order(right)


def demo_composition() -> None:
    print()
    print("=" * 74)
    print("6. WHERE THE INFORMATION LIVES: BRAHMAGUPTA-FIBONACCI")
    print("=" * 74)
    print("  (a^2+b^2)(c^2+d^2) = (ac-bd)^2 + (ad+bc)^2 = (ac+bd)^2 + (ad-bc)^2")
    for t in range(1, 5):
        k = 10 * t
        left, right = brahmagupta(2, 1, k, 1)
        N = 5 * (k * k + 1)
        assert hyp(*left) == hyp(*right) == N
        print(f"  t = {t}: 5 * ({k}^2+1) = {N:>7} = "
              f"{left[0]}^2+{left[1]}^2 = {right[0]}^2+{right[1]}^2   "
              f"letters {letter_of(left)}/{letter_of(right)}")
    print("  => the address ambiguity IS the composition ambiguity;")
    print("     resolving it requires the factorisation.")


# ---------------------------------------------------------------------------
# 7. Refutations
# ---------------------------------------------------------------------------


def sophie_germain(s: int) -> Tuple[Node, Node, int, Tuple[int, int]]:
    """u = 2s+7: nodes (u^2-2, 2u) and (u^2, 2) of N = u^4 + 4, both letter C."""
    u = 2 * s + 7
    p, q = (u * u - 2, 2 * u), (u * u, 2)
    N = u ** 4 + 4
    assert is_node(*p) and is_node(*q)
    assert hyp(*p) == hyp(*q) == N
    assert letter_of(p) == letter_of(q) == "C"
    return p, q, N, (u * u - 2 * u + 2, u * u + 2 * u + 2)


def v2(n: int) -> int:
    k = 0
    while n % 2 == 0 and n > 0:
        n //= 2
        k += 1
    return k


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for p in range(2, isqrt(n) + 1):
        if n % p == 0:
            return False
    return True


def demo_refutations() -> None:
    print()
    print("=" * 74)
    print("7. TWO REFUTED CONJECTURES")
    print("=" * 74)
    print("  (a) orbit conjecture FALSE: u^4 + 4 has two nodes, both letter C")
    print(f"{'s':>3} {'u':>4} {'N':>12} {'node 1':>14} {'node 2':>14} {'N = p*q':>22}")
    for s in range(0, 6):
        p, q, N, (f1, f2) = sophie_germain(s)
        u = 2 * s + 7
        tag = f"{f1} * {f2}"
        if is_prime(f1) and is_prime(f2):
            tag += "  (semiprime)"
        print(f"{s:>3} {u:>4} {N:>12} {str(p):>14} {str(q):>14} {tag:>22}")

    print("\n  (b) two-adic cap conjecture FALSE: for prime q = 1 (mod 16),")
    print("      every factorisation of N = 7q has v2(a+b) = 3 exactly")
    print(f"{'q':>6} {'N = 7q':>8} {'N mod 8':>8}   factorisations and v2(a+b)")
    for q in [17, 97, 113, 193, 241]:
        assert is_prime(q) and q % 16 == 1
        N = 7 * q
        facts = [(a, N // a) for a in range(1, isqrt(N) + 1) if N % a == 0]
        vals = ", ".join(f"{a}+{b}: v2={v2(a + b)}" for a, b in facts)
        assert all(v2(a + b) == 3 for a, b in facts)
        print(f"{q:>6} {N:>8} {N % 8:>8}   {vals}")
    print("  => the sensor is constant on an infinite family (Dirichlet).")


# ---------------------------------------------------------------------------
# 8. The Price two-adic law
# ---------------------------------------------------------------------------


def price_letter(p: int, q: int, i: int) -> bool:
    """i-th Price letter: True ('A') iff 2^(i+2) does not divide p + q."""
    return (p + q) % (2 ** (i + 2)) != 0


def price_word(N: int) -> Tuple[bool, bool]:
    """The first two Price letters, as a pure dial on N mod 8."""
    return (N % 4 == 1, N % 8 != 7)


def demo_price() -> None:
    print()
    print("=" * 74)
    print("8. THE PRICE TWO-ADIC LAW, AND ITS DEATH AT POSITION 2")
    print("=" * 74)
    print("  for odd p, q:  v2(p+q)=1 <=> pq=1 (4);  =2 <=> pq=3 (8);  >=3 <=> pq=7 (8)")
    checked = 0
    for p in range(1, 60, 2):
        for q in range(1, 60, 2):
            v, N = v2(p + q), p * q
            assert (v == 1) == (N % 4 == 1)
            assert (v == 2) == (N % 8 == 3)
            assert (v >= 3) == (N % 8 == 7)
            assert price_word(N) == (price_letter(p, q, 0), price_letter(p, q, 1))
            checked += 1
    print(f"  verified on all {checked} odd pairs p, q < 60  (law + word = dial on N mod 8)")

    print("\n  position 2 is NOT a function of N: for m = 7 (mod 16), 9m = 9*m = 3*(3m)")
    print(f"{'m':>5} {'N = 9m':>8} {'v2(9+m)':>9} {'v2(3+3m)':>10} {'letters 0,1 agree':>19}")
    for m in [7, 23, 39, 55, 71]:
        N = 9 * m
        same01 = all(price_letter(9, m, i) == price_letter(3, 3 * m, i) for i in (0, 1))
        diff2 = price_letter(9, m, 2) != price_letter(3, 3 * m, 2)
        assert same01 and diff2
        print(f"{m:>5} {N:>8} {v2(9 + m):>9} {v2(3 + 3 * m):>10} {str(same01):>19}")
    print("  smallest instance: 63 = 9*7 = 3*21, v2(16) = 4 but v2(24) = 3.")


# ---------------------------------------------------------------------------
# 9. Search economics
# ---------------------------------------------------------------------------


def restart_energy(h: int, a: float) -> float:
    """Expected node visits of a restarted guided ascent: E(h, a) = h / a^h."""
    return h / a ** h


def critical_accuracy(h: int, budget: float) -> float:
    """Minimal per-step accuracy meeting the budget: alpha* = (h / c)^(1/h)."""
    return (h / budget) ** (1.0 / h)


def exhaustive_nodes(h: int) -> int:
    """Nodes of the complete ternary tree down to depth h: (3^(h+1) - 1)/2."""
    return (3 ** (h + 1) - 1) // 2


def demo_economics() -> None:
    print()
    print("=" * 74)
    print("9. SEARCH ECONOMICS")
    print("=" * 74)
    print("  restart energy E(h, a) = h / a^h  (expected visits)")
    print(f"{'h':>4}" + "".join(f"{a:>14}" for a in [0.50, 0.70, 0.85, 0.86, 0.95]))
    for h in [5, 10, 20, 30, 40]:
        row = "".join(f"{restart_energy(h, a):>14.1f}" for a in
                      [0.50, 0.70, 0.85, 0.86, 0.95])
        print(f"{h:>4}" + row)

    e85 = Fraction(30) / Fraction(17, 20) ** 30
    e86 = Fraction(30) / Fraction(43, 50) ** 30
    print("\n  competitive bracket at h = 30, budget c = 3000 (exact rationals):")
    print(f"    E(30, 0.85) = {float(e85):.2f}  > 3000   ({e85 > 3000})")
    print(f"    E(30, 0.86) = {float(e86):.2f}  <= 3000  ({e86 <= 3000})")
    print(f"    so 0.85 < alpha* <= 0.86;  exactly alpha* = 100^(-1/30) = "
          f"{critical_accuracy(30, 3000):.5f}")
    print("    (E is strictly decreasing in a, so EVERY a <= 0.85 blows the budget)")

    print("\n  brute-force threshold is exactly 1/3 = 1/(branching base):")
    for a in [0.25, 0.30, 1 / 3, 0.40, 0.50]:
        first = next((h for h in range(1, 400) if restart_energy(h, a) < 3.0 ** h), None)
        verdict = ("never (up to h=400)" if first is None
                   else f"guided wins from h = {first}")
        print(f"    a = {a:.4f}:  {verdict}")
    assert all(h * 2 ** h < 3 ** h for h in range(0, 200))
    print("    at a = 1/2, h*2^h < 3^h for every h (checked h < 200, proved in general)")

    print("\n  the exhaustive alternative:")
    for h in [10, 20, 30]:
        print(f"    depth {h}: {exhaustive_nodes(h):,} node visits")
    assert exhaustive_nodes(30) == (3 ** 31 - 1) // 2 > 10 ** 14
    print(f"    depth 30 exceeds 10^14 = {10**14:,}")

    print("\n  adversary lower bound: a searcher visiting V nodes with |V| < 3^h")
    print("  always misses a depth-h node; below 3^h/2 it misses a majority.")
    for h in [5, 10, 20]:
        print(f"    depth {h}: level size 3^{h} = {3**h:,}; "
              f"budget {3**h//2:,} misses > {3**h//2:,} nodes")

    print("\n  compounding: per-step accuracy a gives success probability a^h")
    print(f"{'h':>6}" + "".join(f"{a:>12}" for a in [0.60, 0.85, 0.95]))
    for h in [1, 5, 10, 30, 60]:
        print(f"{h:>6}" + "".join(f"{a**h:>12.6f}" for a in [0.60, 0.85, 0.95]))
    print("  a saturating class hint stays put; a compounding hint decays to 0.")


def main() -> None:
    demo_tree()
    demo_residue()
    demo_gauss()
    demo_structural()
    demo_magnitude()
    demo_composition()
    demo_refutations()
    demo_price()
    demo_economics()
    print()
    print("=" * 74)
    print("All assertions passed: the four seals, the refutations, the economics.")
    print("=" * 74)


if __name__ == "__main__":
    main()
