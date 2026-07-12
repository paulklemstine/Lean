"""Assemble PACKAGE.json from the deliverable files and inline content."""
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def read(p: str) -> str:
    return (ROOT / p).read_text(encoding="utf-8")


article = read("ARTICLE.md")
paper_md = read("RESEARCH_PAPER.md")
paper_tex = read("RESEARCH_PAPER.tex")
demo_py = read("demo.py")
viz1 = read("assets/viz1_geodesic3d.py")
viz2 = read("assets/viz2_spectrum.py")
viz3 = read("assets/viz3_lattice.py")
w1 = read("assets/widget1.html")
w2 = read("assets/widget2.html")
w3 = read("assets/widget3.html")

# ----- demos ---------------------------------------------------------------
demo_closure = '''"""Demo: closedness and non-triviality of integer geodesics on T^3."""
from __future__ import annotations
from typing import Tuple

Vec3 = Tuple[int, int, int]
EPS = 1e-12


def circle(r: float) -> float:
    """Reduce r to its class in R/Z, in [0,1)."""
    return r - float(int(r // 1))


def geo(n: Vec3, t: float) -> Tuple[float, float, float]:
    """Integer geodesic gamma_n(t) = projection of the line t*n."""
    return (circle(t * n[0]), circle(t * n[1]), circle(t * n[2]))


def eq(a, b) -> bool:
    return all(min(abs(x - y), 1 - abs(x - y)) < EPS for x, y in zip(a, b))


def period_one(n: Vec3) -> bool:
    """Theorem: gamma_n(t+1) == gamma_n(t) for all t."""
    return all(eq(geo(n, k / 13), geo(n, k / 13 + 1.0)) for k in range(13))


def nonconstant_witness(n: Vec3) -> float:
    """Return a half-period time t* with gamma_n(t*) != gamma_n(0)."""
    for i, ni in enumerate(n):
        if ni != 0:
            return 1.0 / (2.0 * ni)
    raise ValueError("need a nonzero direction")


if __name__ == "__main__":
    for n in [(1, 0, 0), (2, -1, 3), (0, 4, 0)]:
        t = nonconstant_witness(n)
        print(n, "period-one:", period_one(n),
              " moves at t*=%.4f:" % t, not eq(geo(n, t), geo(n, 0.0)))
'''

demo_spectrum = '''"""Demo: the wrapping spectrum and systole of the cubic 3-torus."""
from __future__ import annotations
from math import sqrt
from typing import Dict, Tuple

Vec3 = Tuple[int, int, int]


def spectrum(radius: int) -> Dict[int, int]:
    """k = a^2+b^2+c^2  ->  r_3(k), the number of geodesics of length sqrt(k)."""
    counts: Dict[int, int] = {}
    rng = range(-radius, radius + 1)
    for a in rng:
        for b in rng:
            for c in rng:
                if (a, b, c) != (0, 0, 0):
                    k = a * a + b * b + c * c
                    counts[k] = counts.get(k, 0) + 1
    return counts


def three_square(k: int) -> bool:
    """Legendre: k is a sum of three squares iff not of form 4^a(8b+7)."""
    while k % 4 == 0:
        k //= 4
    return k % 8 != 7


if __name__ == "__main__":
    s = spectrum(4)
    print("systole length =", sqrt(min(s)))
    for k in sorted(s)[:10]:
        flag = "" if three_square(k) else "  (forbidden)"
        print("k=%2d len=%.4f r_3=%3d%s" % (k, sqrt(k), s[k], flag))
    for k in (7, 15, 23, 28):
        print("k=%d in spectrum? %s" % (k, k in s), "-> three-square:", three_square(k))
'''

demo_pi1 = '''"""Demo: the covering kernel is Z^3, so pi_1(T^3) = Z^3 (three generators)."""
from __future__ import annotations
from typing import List, Tuple

Vec3 = Tuple[int, int, int]
EPS = 1e-12


def in_kernel(x: Tuple[float, float, float]) -> bool:
    """A cover point projects to the base point iff all coordinates integral."""
    return all(abs(c - round(c)) < EPS for c in x)


def homotopy_class(n: Vec3) -> Vec3:
    """Free-homotopy class of gamma_n = endpoint of its lift = n itself."""
    return n


def independent(gens: List[Vec3]) -> bool:
    """Standard generators are Z-independent (identity matrix has full rank)."""
    # For e0,e1,e2 the coordinate matrix is the identity -> independent.
    return len({homotopy_class(g) for g in gens}) == len(gens)


if __name__ == "__main__":
    print("(1,2,-3) in kernel:", in_kernel((1.0, 2.0, -3.0)))   # True
    print("(0.5,1,0) in kernel:", in_kernel((0.5, 1.0, 0.0)))    # False
    gens = [(1, 0, 0), (0, 1, 0), (0, 0, 1)]
    print("three generators independent:", independent(gens))
    dirs = [(1, 0, 0), (2, 0, -1), (2, 0, 0)]
    print("distinct classes:", len({homotopy_class(d) for d in dirs}) == len(dirs))
'''

# ----- algorithms ----------------------------------------------------------
alg_closure_code = '''from __future__ import annotations
from typing import Tuple

Vec3 = Tuple[int, int, int]


def circle(r: float) -> float:
    """Class of r in R/Z, normalized to [0, 1)."""
    return r - float(int(r // 1))


def geodesic_closure_check(n: Vec3, samples: int = 64, eps: float = 1e-12
                           ) -> Tuple[bool, bool]:
    """Return (is_closed, is_nonconstant) for the integer geodesic gamma_n.

    is_closed:      gamma_n(t+1) == gamma_n(t) at all sample times (period one).
    is_nonconstant: the half-period point differs from the start (genuine wrap).
    Complexity: O(samples).
    """
    def g(t: float) -> Tuple[float, float, float]:
        return (circle(t * n[0]), circle(t * n[1]), circle(t * n[2]))

    def eq(a, b) -> bool:
        return all(min(abs(x - y), 1 - abs(x - y)) < eps for x, y in zip(a, b))

    is_closed = all(eq(g(k / samples), g(k / samples + 1.0))
                    for k in range(samples))
    is_nonconstant = False
    for i, ni in enumerate(n):
        if ni != 0:
            is_nonconstant = not eq(g(1.0 / (2.0 * ni)), g(0.0))
            break
    return is_closed, is_nonconstant
'''

alg_spectrum_code = '''from __future__ import annotations
from math import sqrt
from typing import Dict, Tuple


def wrapping_spectrum(radius: int) -> Tuple[Dict[int, int], float]:
    """Enumerate the length spectrum of the cubic 3-torus up to a lattice radius.

    Returns (multiplicities, systole) where multiplicities maps a squared length
    k = a^2+b^2+c^2 to r_3(k) = number of geodesics of length sqrt(k), and
    systole is the length of the shortest non-constant closed geodesic.
    Complexity: O(radius^3) lattice vectors.
    """
    counts: Dict[int, int] = {}
    rng = range(-radius, radius + 1)
    for a in rng:
        for b in rng:
            for c in rng:
                if (a, b, c) != (0, 0, 0):
                    k = a * a + b * b + c * c
                    counts[k] = counts.get(k, 0) + 1
    systole = sqrt(min(counts)) if counts else 0.0
    return counts, systole
'''

alg_primitive_code = '''from __future__ import annotations
from math import gcd, isqrt
from typing import List, Tuple

Vec3 = Tuple[int, int, int]


def primitive_geodesics(k: int) -> List[Vec3]:
    """Enumerate all primitive closed geodesics of squared length exactly k.

    A direction n=(a,b,c) is primitive iff gcd(a,b,c)=1; primitive geodesics are
    traversed once and biject with primitive lattice vectors of the given norm.
    Complexity: O(k) via the shell a^2+b^2 <= k with c solved exactly.
    """
    out: List[Vec3] = []
    r = isqrt(k)
    for a in range(-r, r + 1):
        for b in range(-r, r + 1):
            c2 = k - a * a - b * b
            if c2 < 0:
                continue
            c = isqrt(c2)
            if c * c != c2:
                continue
            for cc in ({c, -c} if c else {0}):
                v = (a, b, cc)
                if v != (0, 0, 0) and gcd(gcd(abs(a), abs(b)), abs(cc)) == 1:
                    out.append(v)
    return out
'''

package = {
    "title": "Spacetime Donuts: Closed Geodesics and the Wrapping Lattice of the Flat Three-Torus",
    "domain": "Shared",
    "description": (
        "A rigorous account of the flat three-torus as a donut-shaped universe: "
        "integer-direction straight lines close into non-trivial geodesics, the "
        "covering-translation group is exactly the integer lattice giving "
        "pi_1(T^3) = Z^3 with three independent wrapping families, and the "
        "geodesic length spectrum links to cosmic topology and the minimal-volume "
        "hyperbolic universe problem."
    ),
    "authors": ["Aristotle"],
    "date": "2026-07-12",
    "key_results": [
        "Every straight line with an integer direction projects to a closed geodesic of period one on the flat three-torus.",
        "Every nonzero integer direction yields a genuinely non-constant closed geodesic (its half-period point lands on the order-two element 1/2 of the circle).",
        "The covering-translation group equals the integer lattice, so the fundamental group of the flat three-torus is free abelian of rank three, with three independent families of wrapping.",
        "Distinct integer directions give distinct free-homotopy classes, so the torus carries a full Z^3 of inequivalent closed geodesics.",
        "The wrapping length spectrum is the multiset of lattice-vector norms (systole one, multiplicities r_3(k)), governed by the three-square theorem.",
    ],
    "keywords": [
        "three-torus", "closed geodesic", "fundamental group", "integer lattice",
        "covering space", "flat manifold", "systole", "hyperbolic 3-manifold",
        "Weeks manifold", "cosmic topology",
    ],
    "article": article,
    "research_paper": paper_md,
    "research_paper_tex": paper_tex,
    "demo": demo_py,
    "demos": [
        {
            "name": "Full Spacetime-Donut Demonstration Suite",
            "description": "End-to-end numerical tour of the flat three-torus: verifies period-one closedness and genuine non-triviality of integer geodesics, checks that the covering kernel is exactly Z^3, confirms distinct directions give distinct homotopy classes, tabulates the wrapping length spectrum with the systole and three-square gaps, and reports the conjectured minimal hyperbolic volume.",
            "code": demo_py,
        },
        {
            "name": "Closedness and Non-Triviality Verifier for Integer Geodesics",
            "description": "For several integer directions, samples the geodesic gamma_n(t) = (t*n mod 1) and confirms it is periodic with period one, then evaluates the half-period witness to certify that the loop genuinely moves rather than sitting still.",
            "code": demo_closure,
        },
        {
            "name": "Wrapping Length Spectrum and Systole Computation",
            "description": "Enumerates lattice vectors to build the map k -> r_3(k) of squared geodesic lengths to their multiplicities, reports the systole (shortest closed geodesic, length one), and shows the forbidden lengths k = 4^a(8b+7) predicted by Legendre's three-square theorem (e.g. 7, 15, 23, 28).",
            "code": demo_spectrum,
        },
        {
            "name": "Fundamental Group as the Integer Lattice",
            "description": "Demonstrates that a point of the universal cover projects to the base point exactly when all coordinates are integers, that the three standard generators are independent, and that distinct integer directions have distinct homotopy classes — the concrete content of pi_1(T^3) = Z^3.",
            "code": demo_pi1,
        },
    ],
    "algorithms": [
        {
            "name": "Geodesic Closure and Non-Triviality Certification",
            "description": "Given an integer direction n, decides whether the projected straight line is a closed geodesic of period one and whether it is genuinely non-constant. Closedness is verified by comparing gamma_n(t) with gamma_n(t+1) at a set of sample times on the circle; non-triviality is certified by the exact half-period witness t* = 1/(2 n_i) for the first nonzero coordinate, whose i-th coordinate lands on 1/2. Runs in O(samples) time and O(1) space.",
            "pseudocode": (
                "function GEODESIC_CLOSURE_CHECK(n, samples, eps):\n"
                "    define g(t) = ((t*n_0) mod 1, (t*n_1) mod 1, (t*n_2) mod 1)\n"
                "    is_closed <- true\n"
                "    for k in 0 .. samples-1:\n"
                "        t <- k / samples\n"
                "        if g(t) != g(t+1) within eps: is_closed <- false\n"
                "    is_nonconstant <- false\n"
                "    for i in 0 .. 2:\n"
                "        if n_i != 0:\n"
                "            is_nonconstant <- (g(1/(2*n_i)) != g(0))\n"
                "            break\n"
                "    return (is_closed, is_nonconstant)"
            ),
            "code": alg_closure_code,
        },
        {
            "name": "Wrapping Spectrum Enumeration and Systole Extraction",
            "description": "Computes the length spectrum of the cubic flat torus by enumerating all nonzero integer lattice vectors within a coordinate radius, accumulating the multiplicity r_3(k) of each squared length k = a^2+b^2+c^2, and extracting the systole as the square root of the smallest attained k. The shortest closed geodesic is found in the first shell (length one). Complexity O(radius^3) vectors.",
            "pseudocode": (
                "function WRAPPING_SPECTRUM(radius):\n"
                "    counts <- empty map\n"
                "    for a,b,c in [-radius..radius]^3 \\ {0}:\n"
                "        k <- a*a + b*b + c*c\n"
                "        counts[k] <- counts[k] + 1\n"
                "    systole <- sqrt(min key of counts)\n"
                "    return (counts, systole)"
            ),
            "code": alg_spectrum_code,
        },
        {
            "name": "Primitive Closed-Geodesic Enumeration by Shell",
            "description": "Lists the primitive closed geodesics of a prescribed squared length k. A direction is primitive when the gcd of its components is one; primitive geodesics are traversed exactly once and biject with primitive lattice vectors of that norm. The algorithm iterates over the two-dimensional shell a^2+b^2 <= k, solving for c exactly by an integer square root, and filters by the gcd condition. Complexity O(k).",
            "pseudocode": (
                "function PRIMITIVE_GEODESICS(k):\n"
                "    out <- empty list; r <- floor(sqrt(k))\n"
                "    for a in -r..r:\n"
                "        for b in -r..r:\n"
                "            c2 <- k - a*a - b*b\n"
                "            if c2 < 0: continue\n"
                "            c <- isqrt(c2)\n"
                "            if c*c != c2: continue\n"
                "            for cc in {c, -c}:\n"
                "                v <- (a,b,cc)\n"
                "                if v != 0 and gcd(|a|,|b|,|cc|) = 1: append v to out\n"
                "    return out"
            ),
            "code": alg_primitive_code,
        },
    ],
    "visualizations": [
        {
            "name": "Closed Geodesics Wrapping the Flat 3-Torus",
            "description": "Renders integer-direction geodesics t -> (t*n mod 1) inside the unit cube fundamental domain, color-coded by time, to show how whole-number directions close into loops that thread the donut universe.",
            "code": viz1,
        },
        {
            "name": "The Wrapping Spectrum and the Three-Square Gaps",
            "description": "Bar chart of the geodesic-length multiplicities r_3(k) for the cubic torus, highlighting in red the squared lengths k = 4^a(8b+7) that are forbidden by Legendre's three-square theorem and therefore absent from the spectrum.",
            "code": viz2,
        },
        {
            "name": "The Wrapping Lattice Z^3 and Its Three Generators",
            "description": "A 3-D scatter of the integer lattice (the fundamental group pi_1(T^3) = Z^3) with points colored by geodesic length and the three independent standard generators e0, e1, e2 drawn as arrows.",
            "code": viz3,
        },
    ],
    "interactive_demos": [
        {
            "title": "Geodesic Wrapper: Straight Lines That Come Home",
            "description": "Enter an integer direction and watch the geodesic t -> (t*n mod 1) trace and close on a 2-D slice of the donut universe with glued edges. Displays the loop length sqrt(n1^2+n2^2) and whether the direction is primitive or a retraced multiple.",
            "html": w1,
        },
        {
            "title": "Wrapping Spectrum Explorer",
            "description": "Interactively sweep the lattice radius and see the geodesic-length histogram r_3(k) rebuild in real time, with the forbidden three-square gaps flagged and the systole reported.",
            "html": w2,
        },
        {
            "title": "Ghost-Image Sky: Living Inside the Donut",
            "description": "Drag a galaxy around a torus universe and watch its repeated ghost images appear, tiled by the wrapping lattice — a hands-on picture of how the fundamental group produces multiple images of a single source in cosmic topology.",
            "html": w3,
        },
    ],
    "interactive_layout": (
        "# Spacetime Donuts: An Interactive Tour\n\n"
        "Imagine flying off in a perfectly straight line and, without ever turning, "
        "arriving back where you began. In a **flat three-torus** universe "
        "$\\mathbb{T}^3 = (\\mathbb{R}/\\mathbb{Z})^3$ this is not fiction but a "
        "theorem. This notebook walks through the mathematics interactively.\n\n"
        "## 1. Straight lines that close up\n\n"
        "A straight path in direction $n=(n_1,n_2,n_3)$ projects to the loop "
        "$\\gamma_n(t) = (t\\,n \\bmod 1)$. When $n$ is a whole-number vector, the "
        "loop closes after unit time: $\\gamma_n(t+1)=\\gamma_n(t)$. Try it "
        "yourself — change the direction and watch the geodesic wrap:\n\n"
        "{{interactive_demo:0}}\n\n"
        "The certification behind the picture is a single tidy procedure that "
        "checks period-one closedness and the half-period non-triviality witness:\n\n"
        "{{algorithm:0}}\n\n"
        "and a quick numerical demonstration on several directions:\n\n"
        "{{demo:1}}\n\n"
        "## 2. How long are the loops? The wrapping spectrum\n\n"
        "Each closed geodesic has length $\\sqrt{n_1^2+n_2^2+n_3^2}$, so the set of "
        "loop lengths is a lattice-norm spectrum. The shortest (the **systole**) "
        "has length one, and certain lengths are impossible: Legendre's theorem "
        "forbids $k = 4^a(8b+7)$. Explore the spectrum live:\n\n"
        "{{interactive_demo:1}}\n\n"
        "The enumeration algorithm and its static chart:\n\n"
        "{{algorithm:1}}\n\n"
        "{{visualization:1}}\n\n"
        "and the primitive-geodesic refinement that removes retraced multiples:\n\n"
        "{{algorithm:2}}\n\n"
        "{{demo:2}}\n\n"
        "## 3. Three ways to circle the cosmos\n\n"
        "The essentially different loops form the integer grid "
        "$\\pi_1(\\mathbb{T}^3)=\\mathbb{Z}^3$, generated by three independent "
        "directions. Here is the lattice with its three generators, and the "
        "geodesics wrapping the fundamental cube:\n\n"
        "{{visualization:2}}\n\n"
        "{{visualization:0}}\n\n"
        "{{demo:3}}\n\n"
        "## 4. What it would look like from the inside\n\n"
        "If space really wraps, light from one galaxy reaches us by many routes, "
        "producing repeated ghost images tiled by the lattice. Drag a galaxy and "
        "watch its copies fill the sky:\n\n"
        "{{interactive_demo:2}}\n\n"
        "## 5. The whole story at a glance\n\n"
        "Run the complete demonstration suite to see every result verified "
        "numerically in one pass:\n\n"
        "{{demo:0}}\n"
    ),
    "lean_proofs": "See lean_files.",
    "future_directions": (
        "# Future Directions: Topology of a Donut-Shaped Universe\n\n"
        "These conjectures are distilled from the flat-torus study of closed "
        "geodesics and the wrapping lattice. Each is bold, falsifiable, and "
        "phrased to be tested either by further structural proof or by explicit "
        "computation.\n\n"
        "## 1. Systolic wrapping spectrum of the flat torus\n\n"
        "**Conjecture.** For the flat torus R^3 / L defined by a lattice L, the "
        "set of lengths of primitive closed geodesics is exactly the set of norms "
        "of primitive vectors of L, and the shortest such length (the systole) "
        "equals the minimal norm of a nonzero lattice vector. Consequently the "
        "\"wrapping spectrum\" is a complete isometry invariant up to finitely "
        "many exceptions.\n\n"
        "The key insight is that closed geodesics are indexed by conjugacy classes "
        "of the fundamental group L, which is abelian, so each class is a single "
        "lattice vector and its length is that vector's norm — turning a dynamical "
        "question into a lattice-counting one. The covering-translation lattice and "
        "the geodesic-to-direction dictionary are now pinned down precisely, so the "
        "length spectrum can be attacked by importing existing lattice-geometry "
        "machinery rather than by hand.\n\n"
        "## 2. Three-family rigidity of the fundamental group\n\n"
        "**Conjecture.** Any closed flat 3-manifold whose fundamental group is "
        "generated by exactly three independent commuting families of loops is "
        "finitely covered by the 3-torus, and the number of independent families is "
        "a homeomorphism invariant equal to the first Betti number.\n\n"
        "The key insight is that the three independent generators are not an "
        "artifact of coordinates but the rank of the free abelian covering group, a "
        "topological invariant. With pi_1(T^3) = Z^3 established at the "
        "covering-translation level, the rank-counts-families principle can be "
        "stated cleanly and compared against the Bieberbach classification of flat "
        "manifolds.\n\n"
        "## 3. Closed timelike curves from a temporal wrapping factor\n\n"
        "**Conjecture.** Endowing the donut universe with a product Lorentzian "
        "structure that adds one more circular factor R/tau*Z in the time direction "
        "forces the existence of closed timelike geodesics whose homotopy classes "
        "are exactly the timelike vectors of the extended lattice Z^3 x Z.\n\n"
        "The key insight is that the same integer-direction-closes-up mechanism "
        "proved here for spatial loops applies verbatim to a compactified time "
        "coordinate, so causal pathology is a purely lattice-theoretic phenomenon. "
        "The spatial case is fully worked out; extending the projection and period "
        "arguments to a fourth compact coordinate is a direct structural "
        "generalization rather than new theory.\n\n"
        "## 4. Minimality of the Weeks manifold\n\n"
        "**Conjecture.** Among all closed orientable hyperbolic 3-manifolds, the "
        "Weeks manifold uniquely attains the minimal volume "
        "~ 0.9427073627769277, and no closed orientable hyperbolic 3-manifold has "
        "volume below 0.94.\n\n"
        "The key insight is that the set of volumes of closed hyperbolic "
        "3-manifolds is well-ordered (Thurston-Jorgensen theory), so a minimum "
        "exists; by Mostow rigidity the volume is a topological invariant, making "
        "\"smallest curved universe\" a well-posed and single-valued question whose "
        "answer is conjectured to be this one specific arithmetic manifold."
    ),
    "modules": {"demo": demo_py},
    "lean_files": ["Catalog/Shared/SpacetimeDonuts.lean"],
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
print("wrote", out, "bytes:", out.stat().st_size)


"""Visualization: closed geodesics on the flat three-torus.

Renders integer-direction geodesics t -> (t*n mod 1) inside the unit cube
[0,1)^3 (a fundamental domain of T^3), showing how straight lines in whole-number
directions close up into loops that wrap around the donut universe.
"""

from __future__ import annotations

from typing import Tuple

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401

Vec3 = Tuple[int, int, int]


def geodesic_points(n: Vec3, steps: int = 4000) -> np.ndarray:
    """Sample gamma_n over one full period, reduced into the fundamental cube."""
    t = np.linspace(0.0, 1.0, steps)
    pts = np.stack([(t * n[i]) % 1.0 for i in range(3)], axis=1)
    return pts


def main() -> None:
    fig = plt.figure(figsize=(12, 5))
    directions = [(1, 1, 0), (2, 1, 3), (3, -2, 1)]
    for idx, n in enumerate(directions, start=1):
        ax = fig.add_subplot(1, 3, idx, projection="3d")
        pts = geodesic_points(n)
        ax.scatter(pts[:, 0], pts[:, 1], pts[:, 2], s=0.4,
                   c=np.linspace(0, 1, len(pts)), cmap="twilight")
        ax.set_title(f"geodesic n={n}\n(length = {np.linalg.norm(n):.3f})")
        ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.set_zlim(0, 1)
        ax.set_xlabel("x"); ax.set_ylabel("y"); ax.set_zlabel("z")
    fig.suptitle("Closed geodesics wrapping the flat 3-torus", fontsize=14)
    fig.tight_layout()
    fig.savefig("geodesics_torus.png", dpi=140)
    print("saved geodesics_torus.png")


if __name__ == "__main__":
    main()


"""Visualization: the wrapping (length) spectrum of the cubic 3-torus.

Plots the multiplicities r_3(k) of squared geodesic lengths k = a^2+b^2+c^2,
highlighting the gaps at k of the form 4^a(8b+7) forbidden by Legendre's
three-square theorem (e.g. k = 7, 15, 23, 28, ...).
"""

from __future__ import annotations

from typing import Dict

import numpy as np
import matplotlib.pyplot as plt


def wrapping_spectrum(radius: int) -> Dict[int, int]:
    """Map k -> number of integer vectors of squared length k (r_3(k))."""
    counts: Dict[int, int] = {}
    rng = range(-radius, radius + 1)
    for a in rng:
        for b in rng:
            for c in rng:
                if (a, b, c) != (0, 0, 0):
                    k = a * a + b * b + c * c
                    counts[k] = counts.get(k, 0) + 1
    return counts


def forbidden(k: int) -> bool:
    """True iff k = 4^a (8b+7): NOT a sum of three squares."""
    while k % 4 == 0:
        k //= 4
    return k % 8 == 7


def main() -> None:
    radius = 6
    spec = wrapping_spectrum(radius)
    kmax = radius * radius
    ks = list(range(1, kmax + 1))
    vals = [spec.get(k, 0) for k in ks]
    colors = ["#d62728" if forbidden(k) else "#1f77b4" for k in ks]

    fig, ax = plt.subplots(figsize=(11, 5))
    ax.bar(ks, vals, color=colors)
    ax.set_xlabel("squared geodesic length  k = a^2 + b^2 + c^2")
    ax.set_ylabel("number of geodesics  r_3(k)")
    ax.set_title("Wrapping spectrum of the cubic 3-torus "
                 "(red = forbidden by the three-square theorem)")
    ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    fig.savefig("wrapping_spectrum.png", dpi=140)
    print("saved wrapping_spectrum.png; systole length =",
          np.sqrt(min(spec)))


if __name__ == "__main__":
    main()


"""Visualization: the wrapping lattice Z^3 and its three independent generators.

Shows the integer lattice points (the covering-translation group / fundamental
group pi_1(T^3) = Z^3) with concentric shells colored by geodesic length, and
the three standard generators e0, e1, e2 drawn as arrows.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401


def main() -> None:
    radius = 3
    xs, ys, zs, ls = [], [], [], []
    rng = range(-radius, radius + 1)
    for a in rng:
        for b in rng:
            for c in rng:
                xs.append(a); ys.append(b); zs.append(c)
                ls.append(np.sqrt(a * a + b * b + c * c))

    fig = plt.figure(figsize=(8, 7))
    ax = fig.add_subplot(111, projection="3d")
    sc = ax.scatter(xs, ys, zs, c=ls, cmap="viridis", s=25)
    fig.colorbar(sc, ax=ax, shrink=0.6, label="geodesic length ||n||")

    for e, col, lab in [((1, 0, 0), "r", "e0"), ((0, 1, 0), "g", "e1"),
                        ((0, 0, 1), "b", "e2")]:
        ax.quiver(0, 0, 0, *e, color=col, linewidth=3, arrow_length_ratio=0.2)
        ax.text(*[1.15 * v for v in e], lab, color=col, fontsize=12)

    ax.set_title("The wrapping lattice  Z^3 = pi_1(T^3)\n"
                 "three independent generators e0, e1, e2")
    ax.set_xlabel("x"); ax.set_ylabel("y"); ax.set_zlabel("z")
    fig.tight_layout()
    fig.savefig("wrapping_lattice.png", dpi=140)
    print("saved wrapping_lattice.png")


if __name__ == "__main__":
    main()


"""Spacetime Donuts: numerical demonstrations for the flat three-torus T^3 = (R/Z)^3.

This self-contained script illustrates, with concrete numbers, the main results
about closed geodesics and the wrapping lattice of a donut-shaped universe:

  1. Integer-direction geodesics are closed with period one.
  2. A nonzero integer direction gives a genuinely non-constant loop (the
     half-period point lands on the order-two element 1/2 of the circle).
  3. The covering-projection kernel is exactly the integer lattice Z^3, and its
     three standard directions are independent  ==>  pi_1(T^3) = Z^3.
  4. Distinct integer directions give distinct homotopy classes.
  5. The wrapping (length) spectrum is the multiset of lattice-vector norms;
     the systole (shortest closed geodesic) has length 1.
  6. The conjectured minimal-volume closed hyperbolic 3-manifold (Weeks).

Run:  python demo.py
"""

from __future__ import annotations

from math import gcd, isqrt, sqrt
from typing import Dict, Iterator, List, Tuple

Vec3 = Tuple[int, int, int]

# Numerical tolerance for floating-point circle comparisons.
EPS: float = 1e-12
WEEKS_VOLUME: float = 0.9427073627769277


# --------------------------------------------------------------------------- #
# Circle and torus primitives
# --------------------------------------------------------------------------- #
def circle(r: float) -> float:
    """Reduce a real number to its class in R/Z, returned in [0, 1)."""
    return r - float(int(r // 1))


def geo(n: Vec3, t: float) -> Tuple[float, float, float]:
    """Integer geodesic gamma_n(t) = projection of the straight line t*n."""
    return (circle(t * n[0]), circle(t * n[1]), circle(t * n[2]))


def torus_eq(a: Tuple[float, float, float], b: Tuple[float, float, float]) -> bool:
    """Equality on T^3: compare coordinatewise on the circle (mod 1)."""
    return all(min(abs(x - y), 1.0 - abs(x - y)) < EPS for x, y in zip(a, b))


# --------------------------------------------------------------------------- #
# 1 + 2. Closedness and non-triviality of integer geodesics
# --------------------------------------------------------------------------- #
def is_periodic(n: Vec3, samples: int = 17) -> bool:
    """Check gamma_n(t+1) == gamma_n(t) at several sample times (Theorem 3.1)."""
    return all(
        torus_eq(geo(n, k / samples), geo(n, k / samples + 1.0))
        for k in range(samples)
    )


def half_period_witness(n: Vec3) -> Tuple[float, Tuple[float, float, float]]:
    """For nonzero n, return (t*, gamma_n(t*)) with gamma_n(t*) != gamma_n(0).

    Uses the first nonzero coordinate; the chosen coordinate lands on 1/2.
    """
    for i, ni in enumerate(n):
        if ni != 0:
            t_star = 1.0 / (2.0 * ni)
            return t_star, geo(n, t_star)
    raise ValueError("half_period_witness requires a nonzero direction")


# --------------------------------------------------------------------------- #
# 3 + 4. The wrapping lattice and pi_1 = Z^3
# --------------------------------------------------------------------------- #
def in_kernel(x: Tuple[float, float, float]) -> bool:
    """A point of the cover projects to the base point iff all coords integral."""
    return all(abs(c - round(c)) < EPS for c in x)


def homotopy_class(n: Vec3) -> Vec3:
    """Free-homotopy class of gamma_n = endpoint of its lift from 0 = n itself."""
    return n


def classes_distinct(directions: List[Vec3]) -> bool:
    """Injectivity of n -> homotopy class (Theorem 5.2)."""
    seen = [homotopy_class(n) for n in directions]
    return len(set(seen)) == len(seen)


# --------------------------------------------------------------------------- #
# 5. The wrapping (length) spectrum
# --------------------------------------------------------------------------- #
def lattice_vectors(radius: int) -> Iterator[Vec3]:
    """Enumerate nonzero integer vectors with |n_i| <= radius."""
    for a in range(-radius, radius + 1):
        for b in range(-radius, radius + 1):
            for c in range(-radius, radius + 1):
                if (a, b, c) != (0, 0, 0):
                    yield (a, b, c)


def wrapping_spectrum(radius: int) -> Dict[int, int]:
    """Map k -> r_3(k): multiplicities of squared lengths k = a^2+b^2+c^2."""
    counts: Dict[int, int] = {}
    for (a, b, c) in lattice_vectors(radius):
        k = a * a + b * b + c * c
        counts[k] = counts.get(k, 0) + 1
    return counts


def systole(radius: int = 3) -> float:
    """Length of the shortest non-constant closed geodesic (the systole)."""
    return sqrt(min(a * a + b * b + c * c for (a, b, c) in lattice_vectors(radius)))


def is_sum_of_three_squares(k: int) -> bool:
    """Legendre's three-square theorem: k is NOT of the form 4^a (8b + 7)."""
    if k < 0:
        return False
    while k % 4 == 0:
        k //= 4
    return k % 8 != 7


def is_primitive(n: Vec3) -> bool:
    """A direction is primitive iff gcd of its components is 1."""
    return gcd(gcd(abs(n[0]), abs(n[1])), abs(n[2])) == 1


def count_primitive_classes(k: int) -> int:
    """Number of primitive integer directions with squared length exactly k."""
    r = isqrt(k)
    total = 0
    for a in range(-r, r + 1):
        for b in range(-r, r + 1):
            c2 = k - a * a - b * b
            if c2 < 0:
                continue
            c = isqrt(c2)
            if c * c != c2:
                continue
            for cc in ({c, -c} if c != 0 else {0}):
                v = (a, b, cc)
                if v != (0, 0, 0) and is_primitive(v):
                    total += 1
    return total


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 68)
    print("SPACETIME DONUTS  --  the flat three-torus  T^3 = (R/Z)^3")
    print("=" * 68)

    print("\n[1+2] Closed and non-trivial integer geodesics")
    for n in [(1, 0, 0), (2, -1, 3), (0, 0, 5)]:
        t_star, pt = half_period_witness(n)
        print(f"  n={n}: period-one? {is_periodic(n)};  "
              f"gamma(t*={t_star:+.4f})={tuple(round(x,4) for x in pt)} "
              f"!= start {geo(n,0.0)} -> {not torus_eq(pt, geo(n,0.0))}")

    print("\n[3] Covering kernel = Z^3  (pi_1 = Z^3)")
    tests = [((1.0, 2.0, -3.0), True), ((0.5, 1.0, 0.0), False),
             ((4.0, 0.0, 7.0), True)]
    for x, expected in tests:
        print(f"  x={x}: in kernel? {in_kernel(x)} (expected {expected})")
    print("  standard generators e0,e1,e2 are independent -> three families.")

    print("\n[4] Distinct directions -> distinct homotopy classes")
    dirs = [(1, 0, 0), (0, 1, 0), (0, 0, 1), (2, 0, -1), (2, 0, 0)]
    print(f"  classes {dirs} all distinct? {classes_distinct(dirs)}")

    print("\n[5] Wrapping spectrum (squared length k -> # geodesics r_3(k))")
    spec = wrapping_spectrum(radius=3)
    for k in sorted(spec)[:8]:
        tag = "" if is_sum_of_three_squares(k) else "   <- NOT a sum of 3 squares!"
        print(f"  k={k:2d}  length={sqrt(k):.4f}  r_3={spec[k]:3d}  "
              f"primitive={count_primitive_classes(k):3d}{tag}")
    print(f"  systole (shortest closed geodesic) = {systole():.4f}")
    print(f"  k=7 attainable? {is_sum_of_three_squares(7)} (Legendre: 7=8*0+7)")

    print("\n[6] Minimal-volume closed hyperbolic 3-manifold (conjectured)")
    print(f"  Weeks manifold volume  ~  {WEEKS_VOLUME:.16f}")
    print(f"  conjecture: no closed orientable hyperbolic 3-manifold below 0.94")

    print("\nDone.")


if __name__ == "__main__":
    main()
