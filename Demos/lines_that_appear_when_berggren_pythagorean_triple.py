"""Which fans a plot resolves: the Farey visibility census."""

from __future__ import annotations

from math import gcd, pi
from typing import List, Tuple

Star = Tuple[int, int]


def totient_sieve(qmax: int) -> List[int]:
    """phi(0..qmax) by a linear-in-log sieve."""
    phi = list(range(qmax + 1))
    for p in range(2, qmax + 1):
        if phi[p] == p:  # p is prime
            for multiple in range(p, qmax + 1, p):
                phi[multiple] -= phi[multiple] // p
    return phi


def resolved_denominator_bound(y: float, eps: float) -> int:
    """Largest denominator whose fan is resolved: Q = floor(y / eps)."""
    if y <= 0.0 or eps <= 0.0:
        raise ValueError("height and resolution must be positive")
    return int(y / eps)


def farey_stars(qmax: int) -> List[Star]:
    """Star centres in (0,1] of denominator at most qmax, in lowest terms."""
    return [(p, q) for q in range(1, qmax + 1)
            for p in range(1, q + 1) if gcd(p, q) == 1]


def visible_fans(y: float, eps: float) -> Tuple[int, List[Star], int]:
    """Return (Q, the resolved centres in (0,1], their count sum_{q<=Q} phi(q)).

    The adjacent rays of the fan at p/q are exactly y/q apart at plot height y,
    so the fan is resolved at resolution eps iff q <= y/eps.  The geometric
    question therefore collapses to a Farey enumeration; the count is the
    summatory totient, asymptotically 3 Q^2 / pi^2.
    """
    Q = resolved_denominator_bound(y, eps)
    stars = farey_stars(Q)
    phi = totient_sieve(Q)
    count = sum(phi[1:Q + 1])
    assert len(stars) == count
    return (Q, stars, count)


if __name__ == "__main__":
    Q, stars, count = visible_fans(0.5, 0.1)
    print(f"y = 0.5, eps = 0.1 -> Q = {Q}, {count} fans:",
          ", ".join(f"{p}/{q}" for (p, q) in stars))
    phi = totient_sieve(4000)
    for Q in (100, 500, 1000, 2000, 4000):
        s = sum(phi[1:Q + 1])
        print(f"Q = {Q:>5}: Phi = {s:>10}, Phi/Q^2 = {s / Q ** 2:.6f} "
              f"(limit 3/pi^2 = {3 / pi ** 2:.6f})")


"""Unimodular enumeration of the ray of a given charge at a rational ideal point."""

from __future__ import annotations

from math import gcd
from typing import Iterator, List, Tuple

Seed = Tuple[int, int]


def extended_bezout(p: int, q: int) -> Tuple[int, int]:
    """Return integers (a, b) with p*b - q*a = 1, assuming gcd(p, q) = 1."""
    old_r, r = p, q
    old_s, s = 1, 0
    old_t, t = 0, 1
    while r != 0:
        quot = old_r // r
        old_r, r = r, old_r - quot * r
        old_s, s = s, old_s - quot * s
        old_t, t = t, old_t - quot * t
    if old_r != 1:
        raise ValueError("p and q must be coprime")
    # old_s * p + old_t * q = 1  =>  b = old_s, a = -old_t
    return (-old_t, old_s)


def param_bound(k: int, a: int, b: int) -> int:
    """Smallest parameter past which the parametrised pair satisfies 0 < n < m."""
    return abs(k * a) + abs(k * b) + abs(k * (b - a)) + 1


def star_seed(p: int, q: int, k: int, a: int, b: int, s: int) -> Seed:
    """The unimodular parametrisation (m, n) = (k b + s q, k a + s p)."""
    return (k * b + s * q, k * a + s * p)


def is_euclid_seed(m: int, n: int) -> bool:
    """0 < n < m, coprime, of opposite parity."""
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def enumerate_ray(p: int, q: int, k: int, mmax: int) -> List[Seed]:
    """All Euclid seeds of charge k at p/q with first coordinate at most mmax.

    Runs the unimodular parametrisation upward from the explicit bound; the
    charge is constant equal to k along the whole family, so no charge is ever
    recomputed.  Cost O(mmax / q) arithmetic operations plus one extended gcd.
    """
    if k == 0:
        return [(q, p)] if is_euclid_seed(q, p) else []
    a, b = extended_bezout(p, q)
    out: List[Seed] = []
    s = param_bound(k, a, b)
    while True:
        m, n = star_seed(p, q, k, a, b, s)
        if m > mmax:
            return out
        if is_euclid_seed(m, n):
            out.append((m, n))
        s += 1


def charge(p: int, q: int, m: int, n: int) -> int:
    """The charge p*m - q*n."""
    return p * m - q * n


if __name__ == "__main__":
    for (p, q, k) in [(1, 3, 1), (1, 3, 3), (1, 5, 5), (1, 2, 4)]:
        nodes = enumerate_ray(p, q, k, 200)
        assert all(charge(p, q, m, n) == k for (m, n) in nodes)
        print(f"star {p}/{q}, charge {k}: {len(nodes)} nodes with m <= 200")
        print("   ", nodes[:8], "...")


"""Transport of star parameters under the three Berggren moves."""

from __future__ import annotations

from math import gcd
from typing import Iterable, List, Tuple

Star = Tuple[int, int]
Seed = Tuple[int, int]


def berggren_move(i: int, s: Seed) -> Seed:
    """B1, B2, B3 acting on a seed (m, n)."""
    m, n = s
    if i == 0:
        return (2 * m - n, m)
    if i == 1:
        return (2 * m + n, m)
    if i == 2:
        return (m + 2 * n, n)
    raise ValueError("index must be 0, 1 or 2")


def transport(i: int, v: Star) -> Star:
    """The induced action on the star parameter (p, q)."""
    p, q = v
    if i == 0:
        return (2 * p - q, p)
    if i == 1:
        return (2 * p - q, -p)
    if i == 2:
        return (p, q - 2 * p)
    raise ValueError("index must be 0, 1 or 2")


def transport_word(word: Iterable[int], v: Star) -> Star:
    """Apply a word of transports, leftmost letter first."""
    for i in word:
        v = transport(i, v)
    return v


def charge(v: Star, s: Seed) -> int:
    """The bilinear charge form p*m - q*n, unnormalised."""
    return v[0] * s[0] - v[1] * s[1]


def verify_covariance(v: Star, s: Seed) -> bool:
    """charge(v, B_i s) == charge(T_i v, s) for each of the three moves.

    This identity is the reason the tree permutes whole fans while conserving
    the charge; it is exact, with no sign ambiguity, because each transport is
    the signed transpose of the corresponding Berggren matrix.
    """
    return all(charge(v, berggren_move(i, s)) == charge(transport(i, v), s)
               for i in range(3))


def parity_class(v: Star) -> int:
    """The transport invariant: the parity of p + q."""
    return (v[0] + v[1]) % 2


def ladder_collapse(k: int) -> Star:
    """Apply B1 exactly k times to the star at k/(k+1); the result is (0, 1)."""
    return transport_word([0] * k, (k, k + 1))


if __name__ == "__main__":
    seed = (12, 5)
    for v in [(0, 1), (1, 1), (1, 2), (1, 3), (2, 5)]:
        assert verify_covariance(v, seed)
        print(f"star {v}: covariance ok, parity class {parity_class(v)}")
    for k in range(1, 7):
        assert ladder_collapse(k) == (0, 1)
        print(f"the fan at {k}/{k + 1} is the 0-fan transported by B1^{k}")
    v: Star = (2, 5)
    for i in [0, 2, 1, 1, 0, 2]:
        w = transport(i, v)
        assert parity_class(w) == parity_class(v)
        assert gcd(abs(w[0]), abs(w[1])) == 1
        v = w
    print("parity of p+q and primitivity survive every word:", v)


"""Assemble PACKAGE.json from the individual deliverables."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
A = os.path.join(ROOT, "assets")


def read(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


LEAN_FILES: List[str] = [
    "Catalog/Pythagorean/RationalStarPencil.lean",
    "Catalog/Pythagorean/RationalStarRealization.lean",
    "Catalog/Pythagorean/RationalStarDensity.lean",
    "Catalog/Pythagorean/RationalStarFarey.lean",
    "Catalog/Pythagorean/RationalStarVisibility.lean",
    "Catalog/Pythagorean/RationalStarTransport.lean",
]

lean_proofs = "\n\n".join(
    f"/- ============================================================\n"
    f"   {path}\n"
    f"   ============================================================ -/\n\n"
    + read(os.path.join(ROOT, path))
    for path in LEAN_FILES
)

demo_src = read(os.path.join(ROOT, "demo.py"))

package: Dict[str, Any] = {
    "title": "A Fan at Every Fraction: The Rational Star Pencils of the Berggren "
             "Tree in the Poincare Half-Plane",
    "domain": "Pythagorean",
    "description": (
        "Plotting the Berggren tree of primitive Pythagorean triples in the Poincare "
        "upper half-plane through the Euclid embedding z(m,n) = (n+i)/m produces radial "
        "fans at every rational boundary point, and this work determines all of them "
        "exactly: each fan is a quantised ladder of hypercycles indexed by the integer "
        "charge pm - qn, half its rays are extinguished precisely when p and q are both "
        "odd, the fans a plot resolves are the Farey fractions of level floor(y/eps), "
        "and each ray carries 2*phi(|k|) nodes per window of 2|k| parameters."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-11",
    "key_results": [
        "Star line theorem: for every rational ideal point p/q the seeds of a fixed charge "
        "chi = pm - qn satisfy p/q - Re z = (chi/q) Im z, so they lie on one Euclidean ray "
        "emanating from p/q; the visible radial lines are exactly the level sets of the charge.",
        "Hypercycle theorem: a node of charge chi at p/q lies at hyperbolic distance exactly "
        "arsinh(|chi|/q) from the complete geodesic over p/q, so the charge is a hyperbolic "
        "width and each fan is a quantised ladder of hypercycles.",
        "Parity quantisation and realisation: the charges realised by Euclid seeds at p/q are "
        "all of the integers when p+q is odd and exactly the odd integers when p+q is even, "
        "with every realised ray carrying infinitely many nodes.",
        "Axis theorem: the axis of a fan carries at most one node, namely (m,n) = (q,p), and "
        "does so precisely when p+q is odd; at p/q = 1/2 that node is the root (2,1) of the "
        "tree, the seed of the triple (3,4,5).",
        "Farey visibility law: adjacent rays of the fan at p/q are exactly y/q apart at plot "
        "height y, so the fans resolved at resolution eps are the Farey fractions of level "
        "floor(y/eps), a finite set of cardinality the summatory totient sum_{q<=Q} phi(q).",
        "Totient density law for a ray: on the ray of odd charge k at an odd/odd rational the "
        "parametrised node is a Euclid seed exactly when gcd(|k|, s) = 1, so every window of "
        "2|k| consecutive parameters carries exactly 2 phi(|k|) nodes and the ray has "
        "arithmetic density phi(|k|)/|k|.",
        "Transport invariant: the three tree moves act on the fan parameter (p,q) by an "
        "integral linear action that conserves the charge exactly, preserves primitivity, and "
        "preserves the parity of p+q, so the fan at 0 and the fan at 1 are permanently "
        "inequivalent while the fan at k/(k+1) is the fan at 0 transported k times.",
    ],
    "keywords": [
        "Pythagorean triples",
        "Berggren tree",
        "Poincare half-plane",
        "hypercycle",
        "Farey fractions",
        "Euler totient",
        "Diophantine approximation",
        "unimodular parametrisation",
    ],
    "article": read(os.path.join(ROOT, "ARTICLE.md")),
    "research_paper": read(os.path.join(ROOT, "RESEARCH_PAPER.md")),
    "research_paper_tex": read(os.path.join(ROOT, "RESEARCH_PAPER.tex")),
    "demo": demo_src,
    "demos": [
        {
            "name": "Fan Census: the Parity Quantisation Dichotomy and the Axis Theorem",
            "description": (
                "Enumerates every Euclid seed up to a size bound, computes its charge "
                "chi = p*m - q*n at a list of rational ideal points, and tabulates the "
                "multiplicity of each realised charge. The output makes both structural "
                "theorems visible at once: at a centre with p and q both odd every even "
                "charge column is identically zero, exhibiting the parity quantisation that "
                "empties half of the fan; at a centre with p+q odd every column is populated, "
                "including charge zero. A second pass isolates the axis of each fan and "
                "confirms that it holds at most the single node (q,p), and only when p+q is "
                "odd -- at p/q = 1/2 that node is (2,1), the root of the entire tree and the "
                "seed of (3,4,5). A third pass prints the hypercycle levels arsinh(k/q) of "
                "the first few rays, showing that they shrink like 1/q, which is why fans at "
                "large denominators are compressed into thin pencils."
            ),
            "code": read(os.path.join(A, "demo_fan_census.py")),
        },
        {
            "name": "Totient Density Law: How Thickly a Single Ray of a Fan Is Populated",
            "description": (
                "Verifies the exact periodic counting law for a ray and then measures its "
                "long-range consequence. Fixing a rational ideal point p/q with p and q both "
                "odd and an odd charge k, the ray of charge k is parametrised unimodularly by "
                "an integer s through (m,n) = (k b + s q, k a + s p) with p b - q a = 1; past "
                "an explicit bound the parametrised pair is a Euclid seed if and only if "
                "gcd(|k|, s) = 1, because the parity condition holds automatically. The "
                "script confirms that every window of 2|k| consecutive parameters contains "
                "exactly 2 phi(|k|) = 2 phi(2|k|) nodes, independently of where the window "
                "starts, and then walks each ray up to seed size 60000 to measure its "
                "arithmetic density against the prediction phi(K)/K, agreeing to four decimal "
                "places. Rays of highly composite charge are demonstrably sparser: charge 15 "
                "has density 8/15 while charge 1 has density 1."
            ),
            "code": read(os.path.join(A, "demo_totient_density.py")),
        },
    ],
    "algorithms": [
        {
            "name": "Unimodular Ray Enumeration at a Rational Ideal Point",
            "description": (
                "Enumerates every node of the tree lying on a prescribed ray -- all Euclid "
                "seeds of a fixed charge k at a fixed rational ideal point p/q -- without "
                "ever scanning the plane. The mathematical foundation is that, for coprime "
                "(p,q), the extended Euclidean algorithm supplies a,b with p b - q a = 1, "
                "after which (m,n) = (k b + s q, k a + s p) runs over the complete integral "
                "solution set of p m - q n = k as the single parameter s runs over the "
                "integers. The substitution has determinant one, so the charge is constant "
                "equal to k along the family and never has to be recomputed, coprimality of "
                "the node is equivalent to gcd(k,s) = 1, and the ordering condition 0 < n < m "
                "holds for every parameter past the explicit bound |k a| + |k b| + "
                "|k (b - a)| + 1. Complexity: one extended gcd, O(log q) arithmetic "
                "operations, followed by O(M/q) iterations to reach seed size M -- output "
                "sensitive and asymptotically optimal, against the O(M^2) cost of filtering "
                "the whole seed plane by charge. In the pipeline this is the routine that "
                "renders a single spoke, measures a spoke density, and supplies the witnesses "
                "for the realisation theorem."
            ),
            "pseudocode": (
                "INPUT   p, q coprime with 0 <= p < q; charge k; size bound M\n"
                "OUTPUT  all Euclid seeds (m, n) with p m - q n = k and m <= M\n"
                "\n"
                "1. if k = 0 then\n"
                "2.     if (q, p) is a Euclid seed then return [(q, p)] else return []\n"
                "3. (a, b) <- EXTENDED-BEZOUT(p, q)          // p b - q a = 1\n"
                "4. S0 <- |k a| + |k b| + |k (b - a)| + 1     // ordering bound\n"
                "5. out <- empty list ; s <- S0\n"
                "6. loop\n"
                "7.     m <- k b + s q ;  n <- k a + s p\n"
                "8.     if m > M then return out\n"
                "9.     if 0 < n < m and gcd(m, n) = 1 and (m + n) is odd then\n"
                "10.        append (m, n) to out\n"
                "11.    s <- s + 1\n"
                "\n"
                "REMARK  when p, q and k are all odd, line 9 may be replaced by the single\n"
                "        test gcd(|k|, s) = 1: the ordering and parity conditions are then\n"
                "        automatic, and a sieve of the parameter window makes the test\n"
                "        amortised O(1)."
            ),
            "code": read(os.path.join(A, "alg_ray_enumeration.py")),
        },
        {
            "name": "Farey Visibility Census at a Given Plot Resolution",
            "description": (
                "Decides which fans a rendering of the star map can actually resolve, and "
                "counts them. The mathematical foundation is the exact separation law: two "
                "nodes at the same plot height y whose charges at p/q differ by d are "
                "separated horizontally by exactly |d| y / q, so adjacent rays of the fan at "
                "p/q are y/q apart. The fan is therefore resolved at resolution eps precisely "
                "when q <= y/eps, with no error term whatsoever, and the geometric question "
                "collapses into an arithmetic one: the visible centres in (0,1] are exactly "
                "the fractions of denominator at most Q = floor(y/eps), that is, the Farey "
                "fractions of level Q, and their number is the summatory totient "
                "Phi(Q) = sum_{q<=Q} phi(q), asymptotically 3 Q^2 / pi^2. Complexity: the "
                "totient sieve is O(Q log log Q) and the enumeration of centres is O(Q^2), "
                "which is optimal since that is the output size; the count alone costs only "
                "the sieve. The routine both explains the visual impression -- a fan at 0.2 "
                "but not at 2/7 -- and predicts that doubling the resolution quadruples the "
                "number of visible fans."
            ),
            "pseudocode": (
                "INPUT   plot height y > 0, resolution eps > 0\n"
                "OUTPUT  Q, the resolved star centres in (0,1], and their count\n"
                "\n"
                "1. Q <- floor(y / eps)                       // resolution criterion q <= y/eps\n"
                "2. phi[0..Q] <- SIEVE-TOTIENT(Q)\n"
                "3.     phi[i] <- i for all i\n"
                "4.     for p <- 2 to Q do\n"
                "5.         if phi[p] = p then                 // p is prime\n"
                "6.             for each multiple j of p up to Q do\n"
                "7.                 phi[j] <- phi[j] - phi[j] / p\n"
                "8. centres <- [ (p, q) : 1 <= q <= Q, 1 <= p <= q, gcd(p, q) = 1 ]\n"
                "9. count <- sum of phi[q] for q = 1..Q\n"
                "10. assert |centres| = count                  // the Farey count\n"
                "11. return (Q, centres, count)"
            ),
            "code": read(os.path.join(A, "alg_farey_visibility.py")),
        },
        {
            "name": "Charge Transport under the Berggren Moves and its Parity Invariant",
            "description": (
                "Implements the action of the tree on the fans themselves, and certifies the "
                "conserved quantities that separate them. The mathematical foundation is the "
                "exact covariance identity: for each of the three moves B_i on seeds there is "
                "an integral linear map T_i on the fan parameter (p,q) -- namely "
                "T_1(p,q) = (2p-q, p), T_2(p,q) = (2p-q, -p), T_3(p,q) = (p, q-2p) -- such "
                "that the charge of the moved node at the fan (p,q) equals the charge of the "
                "original node at the transported fan T_i(p,q). Each T_i has determinant plus "
                "or minus one, so primitivity of (p,q) survives, and each preserves the parity "
                "of p+q, which is therefore a two-valued conserved quantity of the whole tree "
                "action. Two consequences follow immediately and are both verified by the "
                "routine: the fan at k/(k+1) collapses onto the fan at 0 under exactly k "
                "applications of the first move, so infinitely many of the visible fans are "
                "one and the same fan transported; and no word whatsoever carries the fan at "
                "0 (parameter sum 1) to the fan at 1 (parameter sum 2), which is why the "
                "picture's two conspicuous stars are permanently asymmetric. Complexity: O(1) "
                "per letter, O(|w|) for a word of length |w|, with integers growing at most "
                "geometrically."
            ),
            "pseudocode": (
                "INPUT   a fan parameter v = (p, q); a word w over {1, 2, 3}\n"
                "OUTPUT  the transported fan, with the invariants certified\n"
                "\n"
                "1. function TRANSPORT(i, (p, q))\n"
                "2.     if i = 1 then return (2p - q,  p)\n"
                "3.     if i = 2 then return (2p - q, -p)\n"
                "4.     if i = 3 then return (p, q - 2p)\n"
                "\n"
                "5. function VERIFY-COVARIANCE(v, seed s)\n"
                "6.     for i in {1, 2, 3} do\n"
                "7.         assert charge(v, B_i(s)) = charge(TRANSPORT(i, v), s)\n"
                "\n"
                "8. par <- (p + q) mod 2\n"
                "9. for each letter i of w do\n"
                "10.    v <- TRANSPORT(i, v)\n"
                "11.    assert (v.p + v.q) mod 2 = par        // parity is invariant\n"
                "12.    assert gcd(|v.p|, |v.q|) = 1          // primitivity is preserved\n"
                "13. return v\n"
                "\n"
                "LADDER  TRANSPORT(1, (k+1, k+2)) = (k, k+1), hence applying the first move\n"
                "        k times sends the fan at k/(k+1) to the fan at 0."
            ),
            "code": read(os.path.join(A, "alg_transport.py")),
        },
    ],
    "visualizations": [
        {
            "name": "The Pythagorean Star Map: Fans, Quantisation and the Root of the Tree",
            "description": (
                "Renders every Euclid seed with m up to 200 as the half-plane point "
                "z(m,n) = (n+i)/m and overlays the structures that explain the resulting "
                "picture: the fan at 0 (all charges) and the fan at 1 (odd charges only), the "
                "two conspicuous stars; the fans at 1/2, 1/3 and 1/5, each drawn along exactly "
                "its realised charges, so that the parity quantisation dichotomy is visible "
                "as the missing every-other-ray of the odd/odd centres; the nested hyperbolic "
                "circles about the base point i, which by the exact identity "
                "cosh d(i,z) = (m^2+n^2+1)/(2m) are ordinary Euclidean circles in the seed "
                "plane; and the axis node of the fan at 1/2, circled in white, which is the "
                "root (2,1) of the whole tree and the seed of the triple (3,4,5). Writes "
                "starmap.png."
            ),
            "code": read(os.path.join(A, "viz_starmap.py")),
        },
        {
            "name": "Two Quantitative Laws: Farey Visibility and Totient Ray Density",
            "description": (
                "A two-panel figure. The left panel plots the summatory totient ratio "
                "Phi(Q)/Q^2, where Phi(Q) = sum_{q<=Q} phi(q) counts the star centres in "
                "(0,1] that a plot of height y and resolution eps resolves, with "
                "Q = floor(y/eps); the curve converges visibly to 3/pi^2 = 0.30396..., so "
                "doubling the resolution quadruples the number of visible fans. The right "
                "panel measures the arithmetic density of individual rays by walking the "
                "unimodular parametrisation of each one up to seed size 40000 at three "
                "different star centres, and superimposes the exact prediction phi(k)/k: the "
                "measured points land on the prediction curve, and the dips at highly "
                "composite charges are exactly the faint spokes of the rendered star map. "
                "Writes starlaws.png."
            ),
            "code": read(os.path.join(A, "viz_laws.py")),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Rational Star Map Explorer",
            "description": (
                "A live rendering of the Berggren tree in the Poincare half-plane, with a "
                "movable star centre. Every dot is one primitive Pythagorean triple, placed "
                "at horizontal position n/m and height 1/m. Two sliders choose a rational "
                "boundary point p/q, whereupon the widget draws the fan there -- all rays of "
                "constant charge chi = p m - q n -- highlighting in green the nodes of the "
                "innermost rays |chi| <= 1, which are precisely the Farey neighbours of the "
                "centre. The side panel reports live whether the fan is full or half-empty "
                "according to the parity of p+q, whether its axis carries a node and which "
                "one, the innermost hypercycle level arsinh(1/q), and the adjacent-ray gap "
                "y/q. A separate resolution slider draws all fans that a plot of the given "
                "resolution would resolve, so the user can watch the Farey tiers appear one "
                "after another and read off the count sum_{q<=Q} phi(q). Hovering over any "
                "node reports its seed, its Pythagorean triple, its charge at the selected "
                "centre, the corresponding hypercycle level, and the Diophantine error "
                "n/m - p/q = -chi/(q m) -- three quantities that are the same integer in "
                "different clothes."
            ),
            "html": read(os.path.join(A, "widget_starmap.html")),
        },
        {
            "title": "Ray Laboratory: Unimodular Parameters, Coprimality and the Totient Density",
            "description": (
                "An interactive dissection of a single spoke of a fan. The user selects a "
                "rational centre p/q with both entries odd and an odd charge k; the widget "
                "computes a Bezout pair (a,b) with p b - q a = 1, the explicit starting bound, "
                "and then tabulates the unimodular parametrisation "
                "(m,n) = (k b + s q, k a + s p) over a window of 2|k| consecutive parameters. "
                "Each row shows the parameter, the resulting node, gcd(|k|, s), the parity of "
                "m+n, and the verdict: rows that produce a genuine Pythagorean triple are "
                "green, rows killed by a common factor with the charge are grey, and the "
                "parity column is uniformly odd, exhibiting that the parity condition is "
                "automatic and coprimality is the only obstruction. The running count is "
                "compared with the predicted 2 phi(|k|), and a window-offset slider lets the "
                "user confirm that the count is exactly periodic and independent of where the "
                "window begins. A companion plot shows the density phi(k)/k across all "
                "charges, with the selected ray highlighted, making visible why rays of "
                "highly composite charge are the faint ones in the rendered star map."
            ),
            "html": read(os.path.join(A, "widget_density.html")),
        },
    ],
    "interactive_layout": read(os.path.join(A, "interactive_layout.md")),
    "lean_proofs": lean_proofs,
    "future_directions": read(os.path.join(A, "future_directions.md")),
    "modules": {"demo": demo_src},
    "lean_files": LEAN_FILES,
}

with open(os.path.join(ROOT, "PACKAGE.json"), "w", encoding="utf-8") as fh:
    json.dump(package, fh, indent=2, ensure_ascii=False)

print("wrote PACKAGE.json",
      os.path.getsize(os.path.join(ROOT, "PACKAGE.json")), "bytes")


"""Fan census: the parity quantisation dichotomy and the axis theorem.

Enumerates every Euclid seed with first coordinate up to a bound, computes its
charge chi = p*m - q*n at a list of rational ideal points, and tabulates which
charges actually occur.  The output exhibits, empirically, the two theorems
that determine the shape of every fan in the star map:

  * when p and q are both odd (equivalently p + q is even) only ODD charges
    occur -- half of the rays of the fan are empty;
  * when p + q is odd every charge occurs, including 0, and the unique node of
    charge 0 is (m, n) = (q, p), the node sitting exactly on the axis.

At p/q = 1/2 that axis node is (2, 1), the root of the whole tree, whose
Pythagorean triple is (3, 4, 5).
"""

from __future__ import annotations

from math import asinh, gcd
from typing import Dict, List, Tuple

Seed = Tuple[int, int]


def is_seed(m: int, n: int) -> bool:
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def seeds_up_to(mmax: int) -> List[Seed]:
    return [(m, n) for m in range(2, mmax + 1) for n in range(1, m) if is_seed(m, n)]


def charge(p: int, q: int, m: int, n: int) -> int:
    return p * m - q * n


def census(p: int, q: int, mmax: int, bound: int) -> Dict[int, int]:
    """Multiplicity of each charge of absolute value <= bound, among seeds m <= mmax."""
    counts: Dict[int, int] = {}
    for (m, n) in seeds_up_to(mmax):
        k = charge(p, q, m, n)
        if abs(k) <= bound:
            counts[k] = counts.get(k, 0) + 1
    return counts


def main() -> None:
    mmax, bound = 500, 6
    stars = [(0, 1), (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (2, 5), (3, 5), (3, 7)]
    print(f"Fan census over Euclid seeds with m <= {mmax}\n")
    header = "  star  p+q   " + "".join(f"{k:>7}" for k in range(-bound, bound + 1))
    print(header)
    print("  " + "-" * (len(header) - 2))
    for (p, q) in stars:
        counts = census(p, q, mmax, bound)
        parity = "odd " if (p + q) % 2 == 1 else "even"
        cells = "".join(f"{counts.get(k, 0):>7}" for k in range(-bound, bound + 1))
        print(f"{f'{p}/{q}':>6} {parity:>4}   {cells}")
        if (p + q) % 2 == 0:
            assert all(k % 2 != 0 for k in counts), "even charge at an odd/odd star"
    print("\n  A zero column at every even charge is the parity quantisation theorem.")
    print()

    print("Axis census (charge exactly 0):")
    for (p, q) in stars:
        if p == 0:
            continue
        axis = [(m, n) for (m, n) in seeds_up_to(mmax) if charge(p, q, m, n) == 0]
        expected = [(q, p)] if (p + q) % 2 == 1 else []
        assert axis == expected
        tag = f"{axis[0]}" if axis else "empty"
        print(f"  star {p}/{q}: {tag:>10}   (p+q {'odd' if (p+q)%2 else 'even'})")
    print()

    print("Hypercycle levels arsinh(|chi|/q) of the first few rays:")
    for (p, q) in [(0, 1), (1, 1), (1, 2), (1, 3), (1, 5)]:
        levels = [f"{asinh(k / q):.4f}" for k in range(1, 6)]
        print(f"  star {p}/{q}: " + ", ".join(levels))
    print("\n  Ray levels shrink like 1/q: fans at large denominators are thin,")
    print("  which is exactly why only small-denominator fans are visible.")


if __name__ == "__main__":
    main()


"""The totient density law: how thickly a single ray of a fan is populated.

Fix a rational ideal point p/q with p and q both odd, and an odd charge k.  The
ray of charge k is parametrised unimodularly by an integer s through

    (m, n) = (k b + s q,  k a + s p),      p b - q a = 1,

and past an explicit bound the parametrised pair is a Euclid seed if and only
if gcd(|k|, s) = 1: the parity condition is automatic, so coprimality is the
only obstruction.  Counting coprime residues in a window of length 2|k| gives
exactly 2 phi(|k|) nodes, so the ray has arithmetic density phi(|k|)/|k|.

This script verifies the exact window count for many (p/q, k), then measures
the long-range density in the seed size m and compares with phi(K)/K.
"""

from __future__ import annotations

from math import gcd
from typing import List, Tuple

Seed = Tuple[int, int]


def totient(n: int) -> int:
    result, x, d = n, n, 2
    while d * d <= x:
        if x % d == 0:
            while x % d == 0:
                x //= d
            result -= result // d
        d += 1
    if x > 1:
        result -= result // x
    return result


def bezout(p: int, q: int) -> Tuple[int, int]:
    """(a, b) with p*b - q*a = 1."""
    old_r, r, old_s, s, old_t, t = p, q, 1, 0, 0, 1
    while r != 0:
        quo = old_r // r
        old_r, r = r, old_r - quo * r
        old_s, s = s, old_s - quo * s
        old_t, t = t, old_t - quo * t
    return (-old_t, old_s)


def star_seed(p: int, q: int, k: int, a: int, b: int, s: int) -> Seed:
    return (k * b + s * q, k * a + s * p)


def param_bound(k: int, a: int, b: int) -> int:
    return abs(k * a) + abs(k * b) + abs(k * (b - a)) + 1


def is_seed(m: int, n: int) -> bool:
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def window_count(p: int, q: int, k: int, offset: int = 0) -> int:
    a, b = bezout(p, q)
    N = param_bound(k, a, b) + offset
    return sum(1 for s in range(N, N + 2 * abs(k))
               if is_seed(*star_seed(p, q, k, a, b, s)))


def ray_density(p: int, q: int, k: int, mmax: int) -> Tuple[int, float]:
    a, b = bezout(p, q)
    s, count = param_bound(k, a, b), 0
    while True:
        m, n = star_seed(p, q, k, a, b, s)
        if m > mmax:
            break
        if is_seed(m, n):
            count += 1
        s += 1
    return (count, count / (mmax / q))


def main() -> None:
    print("Exact window count: 2*phi(|k|) nodes per 2|k| consecutive parameters\n")
    print(f"{'star':>7} {'k':>5} {'offset':>7} {'nodes':>7} {'2 phi(|k|)':>11} "
          f"{'2 phi(2|k|)':>12}")
    for (p, q) in [(1, 3), (1, 5), (3, 5), (5, 7), (3, 7)]:
        for k in (1, 3, 5, 7, 9, 15, 21, 35):
            for offset in (0, 4, 17):
                got = window_count(p, q, k, offset)
                want = 2 * totient(abs(k))
                assert got == want == 2 * totient(2 * abs(k)), (p, q, k, offset, got)
            print(f"{f'{p}/{q}':>7} {k:>5} {'0,4,17':>7} {got:>7} {want:>11} "
                  f"{2 * totient(2 * abs(k)):>12}")
    print("\n  The count is independent of the window offset: the ray is exactly")
    print("  periodic in the parameter with period 2|k|.\n")

    mmax = 60000
    print(f"Long-range density of a ray (seeds with m <= {mmax}):\n")
    print(f"{'star':>7} {'k':>5} {'nodes':>8} {'nodes/(M/q)':>13} {'phi(K)/K':>10} "
          f"{'ratio':>8}")
    for (p, q) in [(1, 3), (1, 5), (3, 5)]:
        for k in (1, 3, 5, 9, 15, 21):
            count, dens = ray_density(p, q, k, mmax)
            pred = totient(abs(k)) / abs(k)
            print(f"{f'{p}/{q}':>7} {k:>5} {count:>8} {dens:>13.5f} {pred:>10.5f} "
                  f"{dens / pred:>8.4f}")
    print("\n  A ray of highly composite charge is visibly sparser: charge 15 has")
    print("  density 8/15 = 0.5333 while charge 1 has density 1.")


if __name__ == "__main__":
    main()


"""Two quantitative laws of the star map, plotted.

Left panel -- the visibility law.  Adjacent rays of the fan at p/q are exactly
y/q apart at plot height y, so the fans resolved at resolution eps are those
with q <= Q = y/eps.  Their number in (0,1] is the summatory totient
Phi(Q) = sum_{q<=Q} phi(q); the plot shows Phi(Q)/Q^2 converging to 3/pi^2, so
that doubling the resolution quadruples the number of visible fans.

Right panel -- the totient density law.  The ray of odd charge k at an odd/odd
rational carries exactly 2 phi(|k|) nodes per window of 2|k| parameters, hence
has arithmetic density phi(|k|)/|k|.  The plot compares the measured density of
each ray, obtained by walking the unimodular parametrisation, against that
prediction.

Requires matplotlib and numpy.  Writes starlaws.png.
"""

from __future__ import annotations

from math import gcd, pi
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def totient_sieve(qmax: int) -> List[int]:
    phi = list(range(qmax + 1))
    for p in range(2, qmax + 1):
        if phi[p] == p:
            for multiple in range(p, qmax + 1, p):
                phi[multiple] -= phi[multiple] // p
    return phi


def bezout(p: int, q: int) -> Tuple[int, int]:
    old_r, r, old_s, s, old_t, t = p, q, 1, 0, 0, 1
    while r != 0:
        quo = old_r // r
        old_r, r = r, old_r - quo * r
        old_s, s = s, old_s - quo * s
        old_t, t = t, old_t - quo * t
    return (-old_t, old_s)


def is_seed(m: int, n: int) -> bool:
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def ray_density(p: int, q: int, k: int, mmax: int) -> float:
    a, b = bezout(p, q)
    s = abs(k * a) + abs(k * b) + abs(k * (b - a)) + 1
    count = 0
    while True:
        m, n = (k * b + s * q, k * a + s * p)
        if m > mmax:
            break
        if is_seed(m, n):
            count += 1
        s += 1
    return count / (mmax / q)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.4))
    fig.patch.set_facecolor("#070b18")
    for ax in (ax1, ax2):
        ax.set_facecolor("#0b1024")
        ax.tick_params(colors="#93a0c0")
        for s in ax.spines.values():
            s.set_color("#2a3558")

    # --- visibility law ---
    QMAX = 3000
    phi = totient_sieve(QMAX)
    running = np.cumsum(phi[1:QMAX + 1])
    Qs = np.arange(1, QMAX + 1)
    ax1.plot(Qs, running / Qs ** 2, color="#4cc9f0", lw=1.2,
             label=r"$\Phi(Q)/Q^2$")
    ax1.axhline(3 / pi ** 2, color="#f72585", ls="--", lw=1.2,
                label=r"$3/\pi^2 = 0.30396\ldots$")
    ax1.set_xscale("log")
    ax1.set_xlabel("resolvable denominator  Q = y / eps", color="#93a0c0")
    ax1.set_ylabel("visible fans per unit of $Q^2$", color="#93a0c0")
    ax1.set_ylim(0.28, 0.45)
    ax1.set_title("Visibility law: how many fans a plot resolves",
                  color="#e8edf7", fontsize=12)
    leg1 = ax1.legend(frameon=False)
    for t in leg1.get_texts():
        t.set_color("#e8edf7")

    # --- totient density law ---
    mmax = 40000
    ks = [k for k in range(1, 40) if k % 2 == 1]
    for (p, q, colour) in [(1, 3, "#ffd166"), (1, 5, "#b5e48c"), (3, 5, "#c77dff")]:
        measured = [ray_density(p, q, k, mmax) for k in ks]
        ax2.plot(ks, measured, "o", ms=5, color=colour, label=f"measured, star {p}/{q}")
    pred = [totient_of(k) / k for k in ks]
    ax2.plot(ks, pred, color="#4cc9f0", lw=1.3, label=r"$\varphi(k)/k$")
    ax2.set_xlabel("charge k of the ray", color="#93a0c0")
    ax2.set_ylabel("arithmetic density of the ray", color="#93a0c0")
    ax2.set_title("Totient density law: how thick a single ray is",
                  color="#e8edf7", fontsize=12)
    leg2 = ax2.legend(frameon=False, fontsize=9)
    for t in leg2.get_texts():
        t.set_color("#e8edf7")

    fig.tight_layout()
    fig.savefig("starlaws.png", dpi=170, facecolor=fig.get_facecolor())
    print("wrote starlaws.png")


def totient_of(n: int) -> int:
    result, x, d = n, n, 2
    while d * d <= x:
        if x % d == 0:
            while x % d == 0:
                x //= d
            result -= result // d
        d += 1
    if x > 1:
        result -= result // x
    return result


if __name__ == "__main__":
    main()


"""The Pythagorean star map: the Berggren tree in the Poincare half-plane.

Plots every Euclid seed (m, n) as the point z(m,n) = (n + i)/m, and overlays the
structures that explain the picture:

  * the fan at 0 (rays of charge -n) and the fan at 1 (rays of charge m - n),
    the two conspicuous stars;
  * the fans at 1/2, 1/3 and 1/5, drawn only along their realised charges --
    all charges at 1/2 (p + q odd) and only odd charges at 1/3 and 1/5
    (p + q even), which is the parity quantisation dichotomy made visible;
  * the axis node of the fan at 1/2, which is the root (2,1) of the tree;
  * hyperbolic circles about i, which by the exact identity
    cosh d(i, z) = (m^2 + n^2 + 1)/(2m) are Euclidean circles in the (m, n)
    plane and appear here as the nested arcs of the picture.

Requires matplotlib and numpy.  Writes starmap.png.
"""

from __future__ import annotations

from math import cosh, gcd, sinh
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np

MMAX: int = 200
YMAX: float = 0.55


def is_seed(m: int, n: int) -> bool:
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def seeds(mmax: int) -> List[Tuple[int, int]]:
    return [(m, n) for m in range(2, mmax + 1) for n in range(1, m) if is_seed(m, n)]


def draw_fan(ax, p: int, q: int, colour: str, kmax: int, alpha: float,
             label: str | None = None) -> None:
    """Draw the rays of the fan at p/q: the lines p/q - x = (k/q) y."""
    odd_only = (p + q) % 2 == 0
    centre = p / q
    first = True
    for k in range(-kmax, kmax + 1):
        if odd_only and k % 2 == 0:
            continue
        # p/q - x = (k/q) y  =>  x = p/q - (k/q) y
        xs = [centre, centre - (k / q) * YMAX]
        ys = [0.0, YMAX]
        ax.plot(xs, ys, color=colour, lw=0.55,
                alpha=alpha, label=label if first else None)
        first = False


def main() -> None:
    fig, ax = plt.subplots(figsize=(13.5, 7.6))
    ax.set_facecolor("#060a16")
    fig.patch.set_facecolor("#070b18")

    draw_fan(ax, 0, 1, "#f72585", 160, 0.22, "fan at 0  (all charges)")
    draw_fan(ax, 1, 1, "#4cc9f0", 160, 0.26, "fan at 1  (odd charges only)")
    draw_fan(ax, 1, 2, "#ffd6a5", 30, 0.35, "fan at 1/2  (all charges)")
    draw_fan(ax, 1, 3, "#b5e48c", 21, 0.40, "fan at 1/3  (odd charges only)")
    draw_fan(ax, 1, 5, "#c77dff", 15, 0.40, "fan at 1/5  (odd charges only)")

    # hyperbolic circles about i
    theta = np.linspace(0.0, np.pi, 900)
    for R in np.arange(0.9, 5.4, 0.45):
        m = cosh(R) + sinh(R) * np.cos(theta)
        n = sinh(R) * np.sin(theta)
        keep = m > 0.5
        x, y = n[keep] / m[keep], 1.0 / m[keep]
        keep2 = y <= YMAX
        ax.plot(x[keep2], y[keep2], color="#80ed99", lw=0.8, alpha=0.30, ls="--")

    pts = seeds(MMAX)
    xs = [n / m for (m, n) in pts]
    ys = [1.0 / m for (m, n) in pts]
    sz = [max(1.0, 30.0 / m ** 0.6) for (m, n) in pts]
    ax.scatter(xs, ys, s=sz, color="#ffd166", zorder=4, linewidths=0)

    # the axis node of the fan at 1/2 is the root of the tree
    ax.scatter([0.5], [0.5], s=90, facecolor="none", edgecolor="white",
               lw=1.6, zorder=6)
    ax.annotate("the root (2,1) -> (3,4,5)\nsits on the axis of the fan at 1/2",
                xy=(0.5, 0.5), xytext=(0.60, 0.44), color="white", fontsize=10,
                arrowprops=dict(color="white", arrowstyle="->", lw=1.1))

    ax.set_xlim(-0.03, 1.03)
    ax.set_ylim(0.0, YMAX)
    ax.set_xlabel("Re z = n/m", color="#93a0c0")
    ax.set_ylabel("Im z = 1/m", color="#93a0c0")
    ax.tick_params(colors="#93a0c0")
    for s in ax.spines.values():
        s.set_color("#2a3558")
    leg = ax.legend(loc="upper right", frameon=False, fontsize=9)
    for text in leg.get_texts():
        text.set_color("#e8edf7")
    ax.set_title("The Berggren tree in the Poincare half-plane: a fan at every "
                 "rational, quantised by parity", color="#e8edf7", fontsize=13)

    fig.tight_layout()
    fig.savefig("starmap.png", dpi=170, facecolor=fig.get_facecolor())
    print("wrote starmap.png")


if __name__ == "__main__":
    main()


"""
Numerical demonstration of the rational star pencils of the Berggren tree.

The Berggren ternary tree of primitive Pythagorean triples is embedded in the
Poincare upper half-plane through the Euclid map

    z(m, n) = (n + i) / m ,          Re z = n/m ,   Im z = 1/m ,

where (m, n) is a Euclid seed:  0 < n < m,  gcd(m, n) = 1,  m + n odd.

For a rational boundary point p/q in lowest terms the CHARGE of a seed is

    chi(p, q, m, n) = p*m - q*n .

This single integer controls the whole picture, and this script verifies every
claim numerically:

  1. Ray identity      p/q - Re z = (chi/q) * Im z.
  2. Hypercycle level  d(z, geodesic over p/q) = arsinh(|chi| / q).
  3. Parity quantisation:  p, q both odd  =>  every charge is odd.
  4. Realisation:  charges realised = Z if p+q odd, odd integers if p+q even.
  5. Axis:  charge 0 only for (m, n) = (q, p), and only when p+q is odd.
  6. Visibility:  adjacent rays are y/q apart; resolved iff q <= y/eps;
                  number of resolved centres in (0,1] is sum_{q<=Q} phi(q).
  7. Diophantine dictionary:  n/m - p/q = -chi/(q m); innermost rays are
                  Farey neighbours, and the mediant realises the Farey bound.
  8. Totient density law:  2*phi(|k|) nodes per window of 2|k| parameters.
  9. Transport:  the three tree moves permute the fans, conserve the charge,
                  preserve primitivity, and preserve the parity of p + q.

Pure standard library.  Run:  python3 demo.py
"""

from __future__ import annotations

from math import asinh, gcd, isclose, log, pi
from typing import Dict, Iterable, List, Sequence, Tuple

Seed = Tuple[int, int]
Star = Tuple[int, int]


# --------------------------------------------------------------------------
# Basic arithmetic of Euclid seeds and the Berggren tree
# --------------------------------------------------------------------------


def is_seed(m: int, n: int) -> bool:
    """A Euclid seed: 0 < n < m, coprime, of opposite parity."""
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def seeds_up_to(mmax: int) -> List[Seed]:
    """All Euclid seeds with first coordinate at most mmax."""
    return [(m, n) for m in range(2, mmax + 1) for n in range(1, m) if is_seed(m, n)]


def triple(m: int, n: int) -> Tuple[int, int, int]:
    """The primitive Pythagorean triple of a seed, even leg listed second."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def berggren_moves(s: Seed) -> Tuple[Seed, Seed, Seed]:
    """The three children of a seed: B1, B2, B3."""
    m, n = s
    return ((2 * m - n, m), (2 * m + n, m), (m + 2 * n, n))


def embed(m: int, n: int) -> Tuple[float, float]:
    """The half-plane point z(m,n) = (n + i)/m, returned as (Re, Im)."""
    return (n / m, 1.0 / m)


# --------------------------------------------------------------------------
# Charge, rays, hypercycles
# --------------------------------------------------------------------------


def charge(p: int, q: int, m: int, n: int) -> int:
    """The charge of the pair (m,n) at the ideal point p/q."""
    return p * m - q * n


def hypercycle_level(p: int, q: int, m: int, n: int) -> float:
    """Hyperbolic distance from z(m,n) to the vertical geodesic over p/q."""
    return asinh(abs(charge(p, q, m, n)) / q)


def cosh_dist(z: Tuple[float, float], w: Tuple[float, float]) -> float:
    """cosh of the Poincare half-plane distance between two points."""
    dx = z[0] - w[0]
    dy = z[1] - w[1]
    return 1.0 + (dx * dx + dy * dy) / (2.0 * z[1] * w[1])


def dist_to_vertical_geodesic(m: int, n: int, p: int, q: int, samples: int = 400001) -> float:
    """Numerical minimisation of the distance from z(m,n) to the geodesic over p/q."""
    z = embed(m, n)
    best = float("inf")
    # the optimum height is Im(z) * sqrt(1 + u^2); scan a generous range
    for j in range(1, samples):
        s = z[1] * (0.001 * j)
        c = cosh_dist(z, (p / q, s))
        if c < best:
            best = c
    # arcosh
    return log(best + (best * best - 1.0) ** 0.5)


# --------------------------------------------------------------------------
# 1 & 2.  The ray identity and the hypercycle theorem
# --------------------------------------------------------------------------


def demo_rays_and_hypercycles() -> None:
    print("=" * 74)
    print("1-2.  Ray identity and hypercycle level")
    print("=" * 74)
    stars: List[Star] = [(0, 1), (1, 1), (1, 2), (1, 3), (1, 5), (2, 5)]
    print(f"{'seed':>10} {'star':>6} {'chi':>5} {'p/q - Re z':>13} "
          f"{'(chi/q)*Im z':>14} {'arsinh|chi|/q':>15}")
    for (m, n) in [(2, 1), (3, 2), (4, 1), (7, 4), (12, 5)]:
        for (p, q) in stars:
            k = charge(p, q, m, n)
            re, im = embed(m, n)
            lhs = p / q - re
            rhs = (k / q) * im
            assert isclose(lhs, rhs, abs_tol=1e-12), "ray identity failed"
            print(f"{str((m, n)):>10} {f'{p}/{q}':>6} {k:>5} {lhs:>13.8f} "
                  f"{rhs:>14.8f} {hypercycle_level(p, q, m, n):>15.8f}")
    print()
    # confirm the hypercycle level against a brute-force minimisation
    for (m, n, p, q) in [(3, 2, 1, 2), (7, 4, 1, 3), (12, 5, 1, 1)]:
        exact = hypercycle_level(p, q, m, n)
        numeric = dist_to_vertical_geodesic(m, n, p, q, samples=200001)
        print(f"  seed {(m, n)} at {p}/{q}: exact arsinh = {exact:.8f}, "
              f"scanned minimum = {numeric:.8f}")
    print()


# --------------------------------------------------------------------------
# 3, 4, 5.  Parity quantisation, realisation, the axis
# --------------------------------------------------------------------------


def realised_charges(p: int, q: int, mmax: int, bound: int = 8) -> List[int]:
    """Charges of absolute value <= bound realised by seeds with m <= mmax."""
    found = set()
    for (m, n) in seeds_up_to(mmax):
        k = charge(p, q, m, n)
        if abs(k) <= bound:
            found.add(k)
    return sorted(found)


def demo_quantisation() -> None:
    print("=" * 74)
    print("3-5.  Parity quantisation, realisation, and the axis")
    print("=" * 74)
    print(f"{'star':>6} {'p+q':>5} {'realised charges with |chi| <= 8':>44}")
    for (p, q) in [(0, 1), (1, 1), (1, 2), (1, 3), (1, 5), (2, 5), (3, 5)]:
        ks = realised_charges(p, q, 400)
        parity = "odd" if (p + q) % 2 == 1 else "even"
        if (p + q) % 2 == 0:
            assert all(k % 2 != 0 for k in ks), "even charge at an odd/odd star!"
        print(f"{f'{p}/{q}':>6} {parity:>5} {str(ks):>44}")
    print()
    print("  axis (charge 0) census:")
    for (p, q) in [(1, 2), (1, 3), (1, 4), (1, 5), (2, 5), (3, 5)]:
        axis = [(m, n) for (m, n) in seeds_up_to(400) if charge(p, q, m, n) == 0]
        expect = [(q, p)] if (p + q) % 2 == 1 else []
        assert axis == expect, "axis theorem failed"
        note = "occupied by (q,p)" if axis else "EMPTY (p+q even)"
        print(f"    star {p}/{q}: {str(axis):>10}   {note}")
    print("  note: the axis node of the star at 1/2 is (2,1), the root of the tree,")
    print("        whose triple is", triple(2, 1))
    print()


# --------------------------------------------------------------------------
# 6.  Visibility: adjacent gaps and the Farey count
# --------------------------------------------------------------------------


def totient(n: int) -> int:
    """Euler's totient function."""
    result = n
    x = n
    d = 2
    while d * d <= x:
        if x % d == 0:
            while x % d == 0:
                x //= d
            result -= result // d
        d += 1
    if x > 1:
        result -= result // x
    return result


def farey_stars(qmax: int) -> List[Star]:
    """Star centres in (0,1] of denominator at most qmax, in lowest terms."""
    return [(p, q) for q in range(1, qmax + 1) for p in range(1, q + 1) if gcd(p, q) == 1]


def demo_visibility() -> None:
    print("=" * 74)
    print("6.  The visibility law and the Farey count")
    print("=" * 74)
    # adjacent-ray gap at a fixed height
    m = 60
    for (p, q) in [(1, 2), (1, 3), (1, 5), (3, 7)]:
        y = 1.0 / m
        # two integral pairs at the same height whose charges differ by d are
        # separated in real part by exactly |d| * y / q; take d = 1
        n_lo, n_hi = 1, 1 + q
        d = charge(p, q, m, n_lo) - charge(p, q, m, n_hi)
        separation = abs(n_lo / m - n_hi / m)
        assert isclose(separation, abs(d) * y / q, abs_tol=1e-12)
        gap = y / q
        print(f"  star {p}/{q}: adjacent rays at height y = {y:.5f} are "
              f"{gap:.8f} apart  ( = y/q );  charges differing by {abs(d)} give "
              f"separation {separation:.8f}")
    print()
    for (y, eps) in [(0.5, 0.1), (0.5, 0.05), (0.25, 0.01)]:
        Q = int(y / eps)
        stars = farey_stars(Q)
        count = sum(totient(q) for q in range(1, Q + 1))
        assert len(stars) == count, "Farey count failed"
        print(f"  height y = {y}, resolution eps = {eps}  =>  Q = {Q}, "
              f"{count} resolved centres in (0,1]")
        if Q <= 6:
            print("     ", ", ".join(f"{p}/{q}" for (p, q) in stars))
    print()
    print("  Phi(Q) = sum_{q<=Q} phi(q) and Phi(Q)/Q^2  (limit 3/pi^2 = "
          f"{3 / pi ** 2:.6f}):")
    for Q in [10, 50, 100, 500, 1000, 2000]:
        phi_sum = sum(totient(q) for q in range(1, Q + 1))
        print(f"    Q = {Q:>5}:  Phi = {phi_sum:>9}   Phi/Q^2 = {phi_sum / Q ** 2:.6f}")
    print()


# --------------------------------------------------------------------------
# 7.  Diophantine dictionary, Farey neighbours, mediants
# --------------------------------------------------------------------------


def demo_diophantine() -> None:
    print("=" * 74)
    print("7.  Charges measure Diophantine approximation")
    print("=" * 74)
    p, q = 1, 3
    print(f"  star {p}/{q}:   n/m - p/q  versus  -chi/(q m)")
    for (m, n) in [(4, 1), (5, 2), (7, 4), (8, 3), (11, 4), (16, 5)]:
        if not is_seed(m, n):
            continue
        k = charge(p, q, m, n)
        lhs = n / m - p / q
        rhs = -k / (q * m)
        assert isclose(lhs, rhs, abs_tol=1e-12)
        print(f"    seed {str((m, n)):>8}  chi = {k:>4}   {lhs:>12.8f} = {rhs:>12.8f}")
    print()
    print("  innermost rays (|chi| = 1) are Farey neighbours; the mediant realises")
    print("  the Farey bound q + m:")
    for (p, q) in [(1, 3), (2, 5), (3, 7)]:
        for (m, n) in seeds_up_to(60):
            if charge(p, q, m, n) == -1:
                med_num, med_den = p + n, q + m
                assert p / q < med_num / med_den < n / m
                # nothing of smaller denominator lies strictly between
                worst = min(
                    (s for s in range(1, q + m)
                     for r in range(0, s + 1)
                     if p / q < r / s < n / m),
                    default=None)
                assert worst is None, "Farey theorem violated"
                print(f"    star {p}/{q}, node {(m, n)}: slope {n}/{m}, "
                      f"mediant {med_num}/{med_den}, bound q+m = {q + m} is sharp")
                break
    print()
    print("  every seed is an innermost node of two fans of smaller denominator:")
    for (m, n) in [(3, 2), (5, 2), (8, 3), (12, 5), (16, 5)]:
        found = []
        for q in range(1, m):
            for p in range(0, q + 1):
                if gcd(p, q) == 1 and charge(p, q, m, n) in (-1, 1):
                    found.append(((p, q), charge(p, q, m, n)))
        minus = [s for (s, c) in found if c == -1][0]
        plus = [s for (s, c) in found if c == 1][0]
        print(f"    seed {str((m, n)):>8}: charge -1 at {minus[0]}/{minus[1]}, "
              f"charge +1 at {plus[0]}/{plus[1]}")
    print()


# --------------------------------------------------------------------------
# 8.  The totient density law on a ray
# --------------------------------------------------------------------------


def bezout(p: int, q: int) -> Tuple[int, int]:
    """Return (a, b) with p*b - q*a = 1, assuming gcd(p, q) = 1."""
    # extended Euclid on (p, q)
    old_r, r = p, q
    old_s, s = 1, 0
    old_t, t = 0, 1
    while r != 0:
        quot = old_r // r
        old_r, r = r, old_r - quot * r
        old_s, s = s, old_s - quot * s
        old_t, t = t, old_t - quot * t
    # old_s * p + old_t * q = 1  =>  b = old_s, a = -old_t
    return (-old_t, old_s)


def star_seed(p: int, q: int, k: int, a: int, b: int, s: int) -> Tuple[int, int]:
    """The unimodular parametrisation of the ray of charge k at p/q."""
    return (k * b + s * q, k * a + s * p)


def param_bound(k: int, a: int, b: int) -> int:
    """The explicit bound past which the parametrised pair satisfies 0 < n < m."""
    return abs(k * a) + abs(k * b) + abs(k * (b - a)) + 1


def demo_totient_density() -> None:
    print("=" * 74)
    print("8.  The totient density law for a ray")
    print("=" * 74)
    print(f"{'star':>6} {'k':>4} {'window':>22} {'nodes':>7} {'2*phi(|k|)':>11}")
    for (p, q) in [(1, 3), (1, 5), (3, 5)]:
        a, b = bezout(p, q)
        assert p * b - q * a == 1
        for k in [1, 3, 5, 9, 15]:
            N = param_bound(k, a, b)
            count = 0
            for s in range(N, N + 2 * abs(k)):
                m, n = star_seed(p, q, k, a, b, s)
                if is_seed(m, n):
                    count += 1
            expect = 2 * totient(abs(k))
            assert count == expect, (p, q, k, count, expect)
            assert count == 2 * totient(2 * abs(k))
            print(f"{f'{p}/{q}':>6} {k:>4} {f'[{N}, {N + 2 * abs(k)})':>22} "
                  f"{count:>7} {expect:>11}")
    print()
    print("  arithmetic density of a ray, phi(K)/K, seen at scale m <= 20000:")
    M = 20000
    print(f"{'star':>6} {'k':>4} {'count':>7} {'count/(M/q)':>13} {'phi(K)/K':>10}")
    for (p, q, k) in [(1, 3, 1), (1, 3, 3), (1, 5, 5), (1, 2, 3), (1, 2, 6)]:
        # counting over all seeds up to M would be O(M^2); walk the ray instead
        a, b = bezout(p, q)
        count = 0
        s = param_bound(k, a, b)
        while True:
            m, n = star_seed(p, q, k, a, b, s)
            if m > M:
                break
            if is_seed(m, n):
                count += 1
            s += 1
        dens = count / (M / q)
        print(f"{f'{p}/{q}':>6} {k:>4} {count:>7} {dens:>13.4f} "
              f"{totient(abs(k)) / abs(k):>10.4f}")
    print("  (the rows with p+q odd lose an extra factor 2 when k is odd: there the")
    print("   parity of the node is not automatic and only one residue class of the")
    print("   parameter survives.)")
    print()


# --------------------------------------------------------------------------
# 9.  Transport: the tree permutes the fans
# --------------------------------------------------------------------------


def trans(i: int, v: Star) -> Star:
    """Transport of the star parameter (p,q) under the i-th Berggren move."""
    p, q = v
    if i == 0:
        return (2 * p - q, p)
    if i == 1:
        return (2 * p - q, -p)
    return (p, q - 2 * p)


def demo_transport() -> None:
    print("=" * 74)
    print("9.  Transport: the tree permutes the fans and conserves the charge")
    print("=" * 74)
    seed = (12, 5)
    children = berggren_moves(seed)
    for (p, q) in [(1, 3), (2, 5), (1, 1), (0, 1)]:
        for i in range(3):
            child = children[i]
            lhs = charge(p, q, child[0], child[1])
            tp, tq = trans(i, (p, q))
            rhs = charge(tp, tq, seed[0], seed[1])
            assert lhs == rhs, (p, q, i, lhs, rhs)
        print(f"  star {p}/{q}: covariance verified for all three moves "
              f"(transports {trans(0, (p, q))}, {trans(1, (p, q))}, {trans(2, (p, q))})")
    print()
    print("  parity of p+q is invariant under every word of transports:")
    v: Star = (2, 5)
    word = [0, 2, 1, 1, 0, 2, 0]
    par0 = (v[0] + v[1]) % 2
    for i in word:
        v = trans(i, v)
        assert (v[0] + v[1]) % 2 == par0
        assert gcd(abs(v[0]), abs(v[1])) == 1
    print(f"    (2,5) --{word}--> {v};  p+q parity {par0} throughout, gcd stays 1")
    print()
    print("  the ladder: B1^k transports the star at k/(k+1) onto the star at 0.")
    for k in range(1, 7):
        v = (k, k + 1)
        for _ in range(k):
            v = trans(0, v)
        assert v == (0, 1)
        print(f"    star {k}/{k + 1}  --B1^{k}-->  {v}   (full fan: p+q = {2 * k + 1} is odd)")
    print()
    print("  no word of transports connects the 0-star to the 1-star:")
    print(f"    parity of p+q at (0,1) is {1 % 2}, at (1,1) is {2 % 2} -- invariant, "
          "so the two classical fans are permanently inequivalent.")
    print()


# --------------------------------------------------------------------------
# Bonus: the radial law and the tree itself
# --------------------------------------------------------------------------


def demo_radial() -> None:
    print("=" * 74)
    print("Bonus.  The radial coordinate: cosh d(i, z) = (c+1)/(2m)")
    print("=" * 74)
    print(f"{'seed':>10} {'triple':>20} {'c':>7} {'d(i,z)':>10} "
          f"{'0.5 log c':>11} {'residual':>10}")
    node: Seed = (2, 1)
    row: List[Seed] = [node]
    for _ in range(3):
        nxt: List[Seed] = []
        for s in row:
            nxt.extend(berggren_moves(s))
        row = nxt
    for (m, n) in [(2, 1), (3, 2), (4, 1), (5, 2), (7, 4), (8, 1), (12, 5), (29, 12)]:
        c = m * m + n * n
        ch = (c + 1) / (2 * m)
        d = log(ch + (ch * ch - 1) ** 0.5)
        print(f"{str((m, n)):>10} {str(triple(m, n)):>20} {c:>7} {d:>10.6f} "
              f"{0.5 * log(c):>11.6f} {d - 0.5 * log(c):>10.6f}")
    assert all(0 <= (lambda m, n: (lambda c: (lambda ch: log(ch + (ch * ch - 1) ** 0.5)
                                              - 0.5 * log(c))((c + 1) / (2 * m)))(m * m + n * n))(m, n)
               <= 0.5 * log(2) + 1e-9
               for (m, n) in seeds_up_to(200))
    print("  every residual lies in [0, 0.5 log 2) = [0, 0.346574).")
    print()


def main() -> None:
    demo_rays_and_hypercycles()
    demo_quantisation()
    demo_visibility()
    demo_diophantine()
    demo_totient_density()
    demo_transport()
    demo_radial()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
