#!/usr/bin/env python3
"""Assemble PACKAGE.json from the source artefacts in the repository."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Geometry/HyperbolicBerggrenGeodesics.lean",
    "Catalog/Geometry/HyperbolicBerggrenGeodesicsII.lean",
    "Catalog/Geometry/HyperbolicBerggrenDensity.lean",
    "Catalog/Geometry/HyperbolicBerggrenResidual.lean",
    "Catalog/Geometry/HyperbolicBerggrenBranchExact.lean",
    "Catalog/Geometry/HyperbolicBerggrenSandwichExact.lean",
    "Catalog/Geometry/HyperbolicBerggrenTreeDepth.lean",
]

lean_proofs = "\n\n".join(
    f"/- ============================================================\n"
    f"   FILE: {f}\n"
    f"   ============================================================ -/\n\n"
    + read(ROOT / f)
    for f in LEAN_FILES
)

FUTURE_DIRECTIONS = r"""# Future Directions

Derived from the analysis and adversarial review of the hyperbolic-Pythagorean
geodesics development.

## What survived, what failed

**Survived (proved).**
The Berggren matrices `B1, B2, B3` are conjugate, via Euclid's parametrisation, to the
seed maps `(m,n) -> (2m-n, m), (2m+n, m), (m+2n, n)`; the seed conditions are preserved;
the half-plane point `z(m,n) = (n+i)/m` satisfies `cosh d(i, z) = (m^2+n^2+1)/(2m)`
exactly, whence the **logarithmic trajectory theorem**
`|d(i, z(m,n)) - (1/2) log c| <= log 2` with `c = m^2+n^2`; the Cauchy-Schwarz energy bound
`E >= d^2/k`; and Euler's two-representation factorisation, giving a non-trivial divisor
`gcd(N, m1 m2 + n1 n2)` from any collision of two Berggren nodes.

**Failed - and why.**
The literal mission statement, "`O(log N)` path length to factor `N`", is **false** if
"path length" means combinatorial depth in the Berggren tree: the left spine
`(2,1) -> (3,2) -> (4,3) -> ...` reaches hypotenuse `c = 2k^2 + 6k + 5` only at depth
`k ~ sqrt(c/2)`. This is *false*, not *hard*: it is formally refuted. What is true is the
geometric statement - the hyperbolic *distance* is `(1/2) log c + O(1)`. Equally, the
hoped-for algorithmic conclusion fails for a structural reason: the ball of radius `R`
already contains `Theta(e^{2R})` distinct nodes, i.e. the volume of the search region is
linear in the very number one is trying to factor. Short geodesics; exponentially many of
them.

## Conjectures

### C1. Exact volume asymptotics: the Berggren ball counts coprime lattice points
Let `B(R)` be the set of Euclid seeds whose half-plane points lie in the closed hyperbolic
ball of radius `R` about `i`. Then `#B(R) = C e^{2R} (1 + o(1))` as `R -> infinity`, and
consequently no geodesic-energy search can inspect a `(1-eps)`-fraction of the nodes with
hypotenuse `<= N` in time `N^{o(1)}`.
*The key insight is* that `cosh d = (m^2+n^2+1)/(2m)` turns the ball condition into the
region `m^2 + n^2 <= 2m cosh R - 1`, a Euclidean disc of radius `sinh R` centred at
`(cosh R, 0)` in the `(m,n)` plane, so the count is a coprimality-restricted lattice point
count. Rescaling by `cosh R` and intersecting with the seed cone `0 < n < m` gives a region
of area `pi/4 + 1/2`; Euclid seeds have density `4/pi^2` among integer pairs (coprime
density `6/pi^2`, times the `2/3` of coprime pairs with opposite parity); and
`cosh^2 R ~ e^{2R}/4`. The predicted constant is therefore
`C = (pi + 2) / (4 pi^2) = 0.130237...`, which direct enumeration confirms to five digits
(observed ratios `0.13024` at `R = 7, 8`). Only the error term needs new work.

### C2. Collision radius: two representations always live within `log 2` of each other
If `N = m1^2 + n1^2 = m2^2 + n2^2` with distinct Euclid seeds, then
`|d(i, z(m1,n1)) - d(i, z(m2,n2))| <= log 2`, and the *hyperbolic distance between the two
colliding nodes themselves* is at most `log N - log(4 m1 m2) + O(1)`.
*The key insight is* that both nodes lie on the same "isohypotenuse" curve
`m^2 + n^2 = N`, which the distance formula turns into the level set `2m cosh d = N + 1`;
the whole level set is an arc of controlled hyperbolic diameter.

### C3. Equidistribution on annuli
Do the nodes with hypotenuse in `[N, 2N]` equidistribute on the corresponding hyperbolic
annulus with respect to hyperbolic area? The slope model says the angular coordinate is
governed by the distribution of the slope `n/m` among Euclid seeds, which should be the
natural one; making this precise would upgrade the volume count to a genuine
equidistribution theorem.

### C4. The residual as a height
The residual `rho = d - (1/2) log c` is a bounded, explicitly computable function on the
tree that increases along `B1` and decreases along `B3` - a Lyapunov function for the tree
dynamics. Is there a natural interpretation of `rho` as an Arakelov-style local height, and
does the exact gap `n^2/c^2` have an arithmetic meaning?

### C5. Modular interpretation
The three Berggren moves generate a subgroup of `PGL_2(Z)` acting on slopes by
`t -> 1/(2-t)`, `1/(2+t)`, `t/(1+2t)`. Identifying the precise congruence subgroup, and
matching the seed trichotomy (thresholds `1/3` and `1/2`) against its fundamental domain,
would place the whole picture inside modular-curve geometry and might yield C3 for free.

### C6. Beyond the refuted continued-fraction law
There is no constant `lambda` for which the depth equals `lambda` times the sum of the
partial quotients of the slope, up to a bounded error: the right spine realises the ratio
`1/2` and the left spine the ratio `1`. A *weighted* law - counting a `B1` step as one
partial quotient and a `B3` step as half of one - may well hold; formulating and proving
the correct statement is open.
"""

demo_full = read(ROOT / "demo.py")
demo_boundary = read(A / "demo_boundary_layer.py")
algs = read(A / "algorithms.py")
viz_tree = read(A / "viz_disk_tree.py")
viz_resid = read(A / "viz_residual.py")
viz_nfl = read(A / "viz_nofreelunch.py")
w_disk = read(A / "widget_disk_explorer.html")
w_coll = read(A / "widget_collision_factoring.html")
layout = read(A / "interactive_layout.md")


def alg_slice(header: str, footer: str) -> str:
    """Extract one algorithm section from algorithms.py, with the shared
    preamble so that each entry is runnable on its own."""
    pre = ("from __future__ import annotations\n\n"
           "from math import acosh, gcd, isqrt, log, sqrt\n"
           "from typing import Dict, List, Optional, Tuple\n\n"
           "Seed = Tuple[int, int]\n"
           "ROOT: Seed = (2, 1)\n\n\n"
           "def is_euclid_seed(m: int, n: int) -> bool:\n"
           '    """0 < n < m, gcd(m,n) = 1, m + n odd."""\n'
           "    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1\n\n\n")
    i = algs.index(header)
    j = algs.index(footer, i)
    return pre + algs[i:j].rstrip() + "\n"


ALG_DESCENT = alg_slice("def berggren_children", "# =========="
                        "=================================================")
ALG_LOCALISE = alg_slice("class NodeGeometry", "# ================="
                         "==========================================")
ALG_ORACLE = alg_slice("def on_pell_boundary", "# ==================="
                       "========================================")
ALG_FACTOR = alg_slice("def primitive_representations", "# ================"
                       "===========================================")

package = {
    "title": "Hyperbolic-Pythagorean Geodesics: The Berggren Tree in the "
             "Poincare Half-Plane",
    "domain": "Geometry",
    "description": (
        "Embedding the Berggren ternary tree of primitive Pythagorean triples "
        "into the Poincare half-plane by z(m,n) = (n+i)/m yields the exact "
        "identity cosh d(i, z) = (m^2+n^2+1)/(2m), from which the hyperbolic "
        "radius of every node is determined to be half the logarithm of its "
        "hypotenuse up to an explicitly computed residual. The same geometry "
        "refutes the hoped-for sub-linear factoring algorithm: the ball that "
        "must contain a collision for N already contains Theta(N) nodes."),
    "authors": ["Aristotle"],
    "date": "2026-08-07",
    "key_results": [
        "Exact Distance Formula: the hyperbolic distance d from the base point "
        "i to the node z(m,n) = (n+i)/m of a primitive Pythagorean triple "
        "satisfies cosh d = (m^2 + n^2 + 1)/(2m), so the hypotenuse of the "
        "triple appears as the numerator of a hyperbolic cosine.",
        "Logarithmic Trajectory Theorem, in sharp form: every node with "
        "hypotenuse c lies at distance between (1/2) log c and "
        "(1/2) log(2(c+1)) from the base point, so the residual "
        "d - (1/2) log c is confined to an interval of width (1/2) log 2.",
        "Exact Residual Gap Theorem: the residual equals the slope function "
        "(1/2) log(1 + (n/m)^2) plus a gap satisfying "
        "n^2/(c^2+n^2) <= gap <= n^2/(c(c-1)); it follows from the identity "
        "exp(gap) = ((c+1) + sqrt((c+1)^2 - 4m^2))/(2c) and the factorisation "
        "(S - (c-1))(S + (c-1)) = 4n^2.",
        "Complete Branch Monotonicity: the exact hyperbolic residual increases "
        "along the branch (m,n) -> (2m-n, m) and decreases along "
        "(m,n) -> (m+2n, n) for every Euclid seed with no side condition, "
        "while along (m,n) -> (2m+n, m) it decreases exactly when "
        "m^2 < 2mn + n^2 (slope above sqrt(2)-1) and increases exactly when "
        "m^2 > 2mn + n^2, no seed sitting on the threshold; the remaining "
        "Pell family (m-n)^2 = 2n^2 + 1 is settled using integrality.",
        "No-Free-Lunch Theorem for geodesic factoring: the hyperbolic ball of "
        "radius R contains between e^{2R}/300 and 4 e^{2R} tree nodes, so "
        "although two representations of N as a sum of two squares split N "
        "completely by Euler's method and colliding nodes lie within 2 log 2 "
        "of one another, the ball guaranteed to contain a collision for N "
        "already holds Theta(N) candidates."
    ],
    "keywords": [
        "Pythagorean triples", "Berggren tree", "Poincare half-plane",
        "hyperbolic geometry", "Euler factorization", "Pell equation",
        "volume growth", "Euclid parametrization"
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": demo_full,
    "demos": [
        {
            "name": "Complete Numerical Verification of the "
                    "Hyperbolic-Pythagorean Dictionary",
            "description":
                "An end-to-end numerical companion that exercises every result "
                "in the development. It checks that the three Berggren "
                "matrices acting on triples agree with the affine seed maps "
                "(2m-n, m), (2m+n, m), (m+2n, n) and that all children remain "
                "Euclid seeds; verifies the exact distance formula "
                "cosh d = (m^2+n^2+1)/(2m) against a direct evaluation of the "
                "half-plane metric; confirms the sharp trajectory bounds "
                "(1/2) log c <= d <= (1/2) log(2(c+1)) on all 32495 seeds with "
                "m <= 400; tabulates the residual, its slope model, the exact "
                "gap identity and the certified interval "
                "[n^2/(c^2+n^2), n^2/(c(c-1))]; validates the complete branch "
                "dichotomy including the Pell boundary layer; runs the "
                "descent-to-root algorithm and contrasts the left spine "
                "(depth Theta(sqrt c)) with the middle Pell spine (depth "
                "Theta(log c)); measures the ball volume growth against the "
                "proved bracket [e^{2R}/300, 4 e^{2R}]; and factors a series "
                "of collisions by Euler's identity, ending with the "
                "no-free-lunch count that kills the geodesic factoring "
                "heuristic.",
            "code": demo_full
        },
        {
            "name": "The Middle-Branch Threshold and Its Pell Boundary Layer",
            "description":
                "A focused study of the most delicate result. Part 1 checks "
                "the full branch dichotomy exhaustively on all 73031 Euclid "
                "seeds with m <= 600 and reports the narrowest relative margin "
                "encountered (0.0019%, at the seed (408,169)). Part 2 confirms "
                "that no seed sits exactly on the threshold m^2 = 2mn + n^2, "
                "with the coprimality argument that forbids it. Part 3 "
                "generates the Pell family (m-n)^2 = 2n^2 + 1 from the "
                "recursion of the Pell equation, displays the vanishing "
                "margins along it, and then shows that the polynomial "
                "certificate used to close that family - "
                "mn(28n^4 - 96n^2 - 34) + (12n^6 - 30n^4 - 50n^2 - 8) >= 0 - "
                "is genuinely false over the reals, failing near "
                "(m,n) = (3.8, 1.48) and turning true exactly at n = 2, which "
                "is the integrality consequence the Pell equation supplies.",
            "code": demo_boundary
        }
    ],
    "algorithms": [
        {
            "name": "Berggren Descent: Recovering the Address Word and Depth "
                    "of a Primitive Pythagorean Triple",
            "description":
                "Given a Euclid seed (m,n), this recovers the unique word in "
                "{B1, B2, B3}* that leads to it from the root (2,1), and hence "
                "its depth in the tree. The mathematical content is the "
                "inverse-move trichotomy: the slope n/m falls in exactly one of "
                "(0,1/3), (1/3,1/2), (1/2,1), and this decides which of the "
                "three moves produced the node, with parents (m-2n, n), "
                "(n, m-2n) and (n, 2n-m) respectively. The parent map sends "
                "seeds to seeds and strictly decreases the first coordinate, "
                "so the loop terminates at the root; the two degenerate cases "
                "are excluded arithmetically, since m = 2n forces (2,1) by "
                "coprimality and m = 3n is impossible for a seed. Because a "
                "seed is reachable at exactly one depth, the returned word is "
                "unique and the Berggren graph really is a tree. Each "
                "iteration costs O(1) integer operations; the number of "
                "iterations is the depth, which is Theta(log m) along the "
                "middle (Pell) spine but as large as Theta(m) along the left "
                "spine (2,1) -> (3,2) -> (4,3) -> ... . That gap between "
                "Theta(log c) hyperbolic distance and Theta(sqrt c) "
                "combinatorial depth is exactly what defeats the naive "
                "'short geodesic implies shallow node' heuristic.",
            "pseudocode": """INPUT : a Euclid seed (m, n), i.e. 0 < n < m, gcd(m,n) = 1, m+n odd
OUTPUT: the address word w in {B1,B2,B3}* with root -> ... -> (m,n)

 1  assert IsEuclidSeed(m, n)
 2  w <- empty list
 3  while (m, n) != (2, 1) do
 4      if m > 3n then                        // slope n/m in (0, 1/3)
 5          append "B3" to w
 6          (m, n) <- (m - 2n, n)
 7      else if m > 2n then                   // slope n/m in (1/3, 1/2)
 8          append "B2" to w
 9          (m, n) <- (n, m - 2n)
10      else                                  // slope n/m in (1/2, 1)
11          append "B1" to w
12          (m, n) <- (n, 2n - m)
13      end if
14  end while
15  reverse w
16  return w                                   // depth(m,n) = length(w)

INVARIANTS
  * every intermediate pair is again a Euclid seed
  * the first coordinate strictly decreases, so the loop terminates
  * the word is unique: a seed is reachable at exactly one depth""",
            "code": ALG_DESCENT
        },
        {
            "name": "Exact Hyperbolic Localisation of a Berggren Node with a "
                    "Certified Residual-Gap Interval",
            "description":
                "Computes, in constant time and with rigorously certified "
                "error bars, the complete hyperbolic geometry of the node "
                "z(m,n) = (n+i)/m. The engine is the exact identity "
                "cosh d(i, z(m,n)) = (m^2 + n^2 + 1)/(2m), obtained by "
                "substituting z = i and w = (n+i)/m into the half-plane "
                "formula cosh d = 1 + |z-w|^2/(2 Im z Im w). From it follow "
                "the sharp trajectory bounds (1/2) log c <= d <= "
                "(1/2) log(2(c+1)), so the residual rho = d - (1/2) log c "
                "always lies in [0, (1/2) log 2). The routine also returns the "
                "slope model (1/2) log(1 + (n/m)^2) and a certified interval "
                "for the gap between the two. That interval comes from the "
                "identity exp(gap) = ((c+1) + S)/(2c) with "
                "S = sqrt((c+1)^2 - 4m^2) = 2m sinh d, together with the "
                "factorisation (S - (c-1))(S + (c-1)) = 4n^2, which converts a "
                "catastrophically cancelling difference into a quotient and "
                "yields n^2/(c^2 + n^2) <= gap <= n^2/(c(c-1)) - two bounds "
                "differing only by the factor (c+1)/(c-1). All operations are "
                "O(1); the certified interval is far sharper than the naive "
                "O(1/c) estimate, by a factor of order m^2/n^2 at small slope.",
            "pseudocode": """INPUT : a Euclid seed (m, n)
OUTPUT: hypotenuse, slope, distance, residual, slope model,
        and a certified interval containing the residual gap

 1  c            <- m*m + n*n                      // hypotenuse
 2  t            <- n / m                          // slope, in (0,1)
 3  coshd        <- (c + 1) / (2m)                 // EXACT distance formula
 4  d            <- arcosh(coshd)
 5  idealRadius  <- (1/2) * log(c)
 6  rho          <- d - idealRadius                // residual, in [0, log2 / 2)
 7  rhoModel     <- (1/2) * log(1 + t*t)           // slope model
 8  gap          <- rho - rhoModel                 // >= 0
 9  gapLower     <- n*n / (c*c + n*n)              // certified
10  gapUpper     <- n*n / (c*(c - 1))              // certified
11  assert idealRadius <= d <= (1/2)*log(2*(c+1))
12  assert gapLower <= gap <= gapUpper
13  return (c, t, coshd, d, idealRadius, rho, rhoModel, gap,
14          gapLower, gapUpper)

CERTIFICATE
  with S = sqrt((c+1)^2 - 4 m^2) = 2 m sinh d,
      exp(gap) = ((c+1) + S) / (2c),
      (S - (c-1)) (S + (c-1)) = 4 n^2,
      c - 1 <= S <= c + 1,
  hence 2 n^2 / c <= S - (c-1) <= 2 n^2 / (c-1),
  and dividing by 2c gives the stated interval.""",
            "code": ALG_LOCALISE
        },
        {
            "name": "Branch Direction Oracle: Predicting Residual Monotonicity "
                    "from the Slope Threshold sqrt(2) - 1",
            "description":
                "Decides, using exact integer arithmetic alone and without "
                "evaluating a single transcendental function, which way each "
                "of the three Berggren moves shifts the exact hyperbolic "
                "residual of a node. The answers are theorems. The branch "
                "(m,n) -> (2m-n, m) raises the residual for every Euclid seed, "
                "and (m,n) -> (m+2n, n) lowers it for every Euclid seed, both "
                "with no side condition whatsoever; the underlying polynomial "
                "inequalities become coefficient-positive after the "
                "substitution n = a+1, m = a+b+2, which is exactly what makes "
                "the guard-free statements possible. The middle branch "
                "(m,n) -> (2m+n, m) obeys a sharp dichotomy: it lowers the "
                "residual precisely when m^2 < 2mn + n^2, that is when the "
                "slope exceeds sqrt(2) - 1, and raises it precisely when "
                "m^2 > 2mn + n^2. Equality is impossible for a seed, since it "
                "would force n = 1 and then m^2 - 2m - 1 = 0. The oracle also "
                "flags the Pell boundary layer (m-n)^2 = 2n^2 + 1, whose "
                "members (5,2), (29,12), (169,70), ... are the seeds where the "
                "generic argument runs out of room and the conclusion depends "
                "on the integrality consequence n >= 2. Complexity O(1); the "
                "prediction agrees with the true residuals on every seed "
                "tested.",
            "pseudocode": """INPUT : a Euclid seed (m, n)
OUTPUT: for each branch, whether the exact residual rises or falls,
        plus the regime the seed lies in

 1  lhs <- m*m
 2  rhs <- 2*m*n + n*n
 3  if lhs = rhs then
 4      raise "unreachable"          // no Euclid seed sits on the threshold:
 5                                    // n | m^2 and gcd(m,n)=1 force n = 1,
 6                                    // then m^2 - 2m - 1 = 0 has no root
 7  end if
 8  B1 <- "increases"                 // theorem: unconditional
 9  B3 <- "decreases"                 // theorem: unconditional
10  if lhs < rhs then                 // slope n/m > sqrt(2) - 1
11      B2 <- "decreases"
12      regime <- "above the threshold"
13  else                              // slope n/m < sqrt(2) - 1
14      B2 <- "increases"
15      regime <- "below the threshold"
16  end if
17  if (m - n)^2 = 2*n*n + 1 then
18      regime <- "Pell boundary layer"   // (5,2), (29,12), (169,70), ...
19  end if
20  return (B1, B2, B3, regime)""",
            "code": ALG_ORACLE
        },
        {
            "name": "Collision-Based Euler Factorisation from Two Berggren "
                    "Nodes Sharing a Hypotenuse",
            "description":
                "Factors an odd integer N by locating two distinct Euclid "
                "seeds with m^2 + n^2 = N - equivalently, two distinct nodes "
                "of the Berggren tree carrying the same hypotenuse - and "
                "applying Euler's two-representation identity. If "
                "N = a^2 + b^2 = c^2 + d^2 with both representations "
                "primitive, then (ac+bd)(ad+bc) = (a^2+b^2)cd + (c^2+d^2)ab = "
                "N(ab+cd), so N divides the product; oddness and primitivity "
                "force gcd(N, ac+bd) and gcd(N, ad+bc) to be coprime, whence "
                "their product is exactly N and both factors lie strictly "
                "between 1 and N. For a semiprime N = pq the two factors are "
                "precisely p and q, so a single collision is a complete "
                "factorisation. Collisions exist at every scale: the seeds "
                "(20j+9, 10j+2) and (20j+7, 10j+6) share the hypotenuse "
                "500 j^2 + 400 j + 85 for every j. Complexity is O(sqrt N) for "
                "the representation search plus O(log N) for the two gcds - "
                "and no better is available from the geometry, since the "
                "hyperbolic ball of radius (1/2) log N + log 2 that is "
                "guaranteed to contain the collision already holds Theta(N) "
                "nodes.",
            "pseudocode": """INPUT : an odd integer N > 1
OUTPUT: a nontrivial splitting N = g * h, or FAIL

 1  if N is even then return FAIL
 2  R <- empty list
 3  for m from 1 to floor(sqrt(N)) do              // enumerate the fibre
 4      r <- N - m*m
 5      n <- integer square root of r
 6      if n*n = r and IsEuclidSeed(m, n) then
 7          append (m, n) to R
 8      end if
 9  end for
10  if |R| < 2 then return FAIL                    // no collision: N is a
11                                                  // prime power p^k, p = 1 mod 4
12  (a, b) <- R[0];  (c, d) <- R[1]
13  g <- gcd(N, a*c + b*d)
14  h <- gcd(N, a*d + b*c)
15  assert g * h = N  and  1 < g < N  and  1 < h < N
16  return (g, h)

WHY IT WORKS
  (ac+bd)(ad+bc) = (a^2+b^2) cd + (c^2+d^2) ab = N (ab+cd), so N | the product;
  a common prime of g and h would divide (a+-b)(c+-d), contradicting
  primitivity; hence gcd(g,h) = 1, g h | N and N | g h.

WHY IT DOES NOT HELP ASYMPTOTICALLY
  the guaranteed search radius is R = (1/2) log N + log 2, and the hyperbolic
  ball of that radius contains Theta(e^{2R}) = Theta(N) Berggren nodes.""",
            "code": ALG_FACTOR
        }
    ],
    "visualizations": [
        {
            "name": "The Berggren Tree in the Poincare Disk and in "
                    "Slope-Size Coordinates",
            "description":
                "A two-panel portrait of the tree. The left panel draws the "
                "nodes and true hyperbolic geodesic edges inside the Poincare "
                "disk, obtained from the half-plane by the Cayley transform "
                "w = (z-i)/(z+i), which sends the base point i to the centre; "
                "dashed circles are the hyperbolic spheres of radius "
                "R = 1,...,6, and the view is zoomed onto the wedge the tree "
                "occupies, since every node has imaginary part 1/m and so "
                "accumulates on the boundary arc corresponding to the slope "
                "interval (0,1). The right panel plots the slope t = n/m "
                "against the hypotenuse on a logarithmic vertical axis, which "
                "by the Logarithmic Trajectory Theorem is twice the hyperbolic "
                "radius; the dashed red line marks the threshold slope "
                "sqrt(2)-1 that governs the middle branch, and the dotted "
                "lines at 1/3 and 1/2 show how the three branch images tile "
                "the slope interval. Nodes are coloured by tree depth.",
            "code": viz_tree
        },
        {
            "name": "Collapse of the Residual onto a Universal Curve, and the "
                    "Two-Sided Gap Bounds",
            "description":
                "The left panel plots the residual rho = d - (1/2) log c "
                "against the slope for all 18281 Euclid seeds with m <= 300. "
                "The points collapse onto the single universal curve "
                "(1/2) log(1 + t^2), with visible spread only at small "
                "hypotenuse; the horizontal band [0, (1/2) log 2] is the "
                "trajectory window, and the dotted vertical line is the "
                "threshold sqrt(2)-1. The right panel plots the gap between "
                "the residual and its slope model against the hypotenuse on "
                "log-log axes, together with the certified bounds "
                "n^2/(c^2+n^2) and n^2/(c(c-1)) - which the script verifies "
                "numerically on every seed plotted - and, for comparison, the "
                "older O(1/c) estimate. The picture makes visible that the "
                "true gap is of size n^2/c^2, smaller than 1/c by a factor of "
                "order m^2/n^2 at small slope, and that the two certified "
                "bounds differ only by the factor (c+1)/(c-1).",
            "code": viz_resid
        },
        {
            "name": "No Free Lunch: Ball Volume Growth and the Divergence of "
                    "Depth from Distance",
            "description":
                "The left panel counts, exactly, the Berggren nodes inside the "
                "hyperbolic ball of radius R for R from 2 to 8, and plots the "
                "count against e^{2R} on log-log axes inside the proved "
                "bracket [e^{2R}/300, 4 e^{2R}]. The measured ratio settles at "
                "0.13024, matching the disc-area heuristic constant "
                "(pi+2)/(4 pi^2) = 0.130237 to five digits. Since a collision "
                "for N is only guaranteed inside the ball of radius about "
                "(1/2) log N + log 2, the search region already contains "
                "Theta(N) nodes. The right panel plots combinatorial depth "
                "against hyperbolic distance for every node down to depth 9, "
                "with three curves overlaid: the proved inequality "
                "2d <= log 32 + k log 9, showing that distance is dominated by "
                "depth; the left spine (k+2, k+1), whose depth is "
                "Theta(sqrt c) while its distance is only Theta(log c); and "
                "the middle Pell spine, where the reverse inequality "
                "d >= k log 2 does hold. Together they show that no reverse "
                "of the depth bound is possible.",
            "code": viz_nfl
        }
    ],
    "interactive_demos": [
        {
            "title": "The Berggren Tree in the Poincare Disk: A Node Explorer",
            "description":
                "A live, clickable rendering of the tree of primitive "
                "Pythagorean triples inside the Poincare disk. Every seed "
                "(m,n) is drawn at the image of z(m,n) = (n+i)/m under the "
                "Cayley transform, so the base point i sits at the centre and "
                "the dashed circles are honest hyperbolic spheres of radius "
                "R = 1,...,7; the edges are true hyperbolic geodesics, "
                "computed as circular arcs orthogonal to the boundary. Click "
                "any node, or walk the tree with the B1/B2/B3 and parent "
                "buttons, and the panel reports the Euclid seed, the "
                "Pythagorean triple, the hypotenuse, the slope, "
                "cosh d = (c+1)/(2m), the distance, the ideal radius "
                "(1/2) log c, the residual, the slope model, the exact gap and "
                "its certified interval, the tree depth, and the full address "
                "word from the root. A verdict badge announces which way the "
                "middle branch will move the residual - decided purely by "
                "whether the slope exceeds sqrt(2)-1 - and lights up when the "
                "node lies on the Pell boundary layer (m-n)^2 = 2n^2 + 1, "
                "where that dichotomy is decided by the narrowest of margins. "
                "The selected node's geodesic to the centre and its whole path "
                "back to the root (3,4,5) are highlighted, the tree depth "
                "shown is adjustable, and an optional colouring by residual "
                "makes the slope dependence of the geometry immediately "
                "visible.",
            "html": w_disk
        },
        {
            "title": "Collisions Factor: Euler's Splitting and the "
                     "No-Free-Lunch Count",
            "description":
                "An interactive laboratory for the arithmetic pay-off of the "
                "geometry, and for its decisive limitation. Enter any odd "
                "integer, pick one of the suggested examples, or generate a "
                "random semiprime built from two primes congruent to 1 mod 4. "
                "The widget enumerates every primitive representation "
                "N = m^2 + n^2 with (m,n) a Euclid seed - equivalently, every "
                "Berggren node carrying the hypotenuse N - lists each with its "
                "triple, hyperbolic distance and residual, and, when two or "
                "more exist, applies Euler's identity to display "
                "gcd(N, ac+bd) and gcd(N, ad+bc) and verify that their product "
                "is exactly N. An annulus diagram shows the representations "
                "sitting inside the band of width (1/2) log 2 to the right of "
                "the ideal radius (1/2) log N, making visible why colliding "
                "nodes are always hyperbolic neighbours. The right-hand panel "
                "then performs the count that defeats the whole approach: for "
                "the given N it displays the guaranteed search radius "
                "R = (1/2) log N + log 2, the volume scale e^{2R} = 4N, the "
                "proved bounds e^{2R}/300 and 4 e^{2R} on the number of nodes "
                "in that ball, the empirical count 0.13024 e^{2R}, and the "
                "sqrt(N) cost of plain trial division - with a logarithmic bar "
                "chart contrasting the length of the geodesic against the size "
                "of the haystack it leads into.",
            "html": w_coll
        }
    ],
    "interactive_layout": layout,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": demo_full,
        "demo_boundary_layer": demo_boundary,
        "algorithms": algs,
        "viz_disk_tree": viz_tree,
        "viz_residual": viz_resid,
        "viz_nofreelunch": viz_nfl
    },
    "lean_files": LEAN_FILES
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False),
               encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size/1024:.1f} KB)")


#!/usr/bin/env python3
"""
Focused demonstration: the middle-branch dichotomy and its Pell boundary layer.

The exact hyperbolic residual of a Berggren node (m,n) is

    rho(m,n) = arcosh((m^2+n^2+1)/(2m)) - (1/2) log(m^2+n^2),

and its slope model is rho_as(m,n) = (1/2) log(1 + (n/m)^2).  The middle
Berggren branch B2 : (m,n) -> (2m+n, m) lowers the slope model exactly when
the slope n/m exceeds sqrt(2)-1, i.e. when m^2 < 2mn + n^2.  Since the exact
residual differs from its model by a gap of size n^2/c^2, one might expect the
exact statement to fail near the threshold.  It does not.  This script
verifies the three parts of the picture:

  1. Exhaustive check of the full dichotomy over all Euclid seeds with
     m <= 600: B1 always raises rho, B3 always lowers it, and B2 moves it in
     exactly the direction the threshold m^2 vs 2mn+n^2 predicts.

  2. The threshold is never attained: no Euclid seed has m^2 = 2mn + n^2.

  3. The boundary layer.  The seeds with m^2 = 2mn + n^2 + 1, equivalently
     (m-n)^2 = 2n^2 + 1, form the Pell family (5,2), (29,12), (169,70), ....
     There the ordinary argument runs out of room, and the proof falls back
     on a polynomial certificate which, substituted onto the Pell locus,
     reads
         P(m,n) = mn(28n^4 - 96n^2 - 34) + (12n^6 - 30n^4 - 50n^2 - 8) >= 0.
     We show that this certificate is FALSE over the reals -- it fails near
     (m,n) = (3.8, 1.48) -- and becomes true exactly at n = 2, which is the
     integrality consequence the Pell equation supplies.  So the arithmetic
     of the problem is doing real work here.

Run with:  python3 demo_boundary_layer.py
"""

from __future__ import annotations

from math import acosh, gcd, log, sqrt
from typing import Iterator, List, Tuple

Seed = Tuple[int, int]
SEP = "=" * 74


def is_seed(m: int, n: int) -> bool:
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def seeds(max_m: int) -> Iterator[Seed]:
    for m in range(2, max_m + 1):
        for n in range(1, m):
            if is_seed(m, n):
                yield (m, n)


def residual_real(m: float, n: float) -> float:
    """rho as a function of two POSITIVE REALS with n < m (no integrality)."""
    c = m * m + n * n
    return acosh((c + 1) / (2 * m)) - 0.5 * log(c)


def residual(p: Seed) -> float:
    return residual_real(float(p[0]), float(p[1]))


def slope_model(p: Seed) -> float:
    return 0.5 * log(1 + (p[1] / p[0]) ** 2)


def b1(p: Seed) -> Seed:
    return (2 * p[0] - p[1], p[0])


def b2(p: Seed) -> Seed:
    return (2 * p[0] + p[1], p[0])


def b3(p: Seed) -> Seed:
    return (p[0] + 2 * p[1], p[1])


def pell_family(count: int) -> List[Seed]:
    """Solutions of (m-n)^2 = 2n^2 + 1 that are Euclid seeds.

    Writing u = m - n, the equation is u^2 - 2n^2 = 1, the classical Pell
    equation; its solutions are generated by (u,n) -> (3u+4n, 2u+3n) from
    (u,n) = (3,2), and m = u + n.
    """
    out: List[Seed] = []
    u, n = 3, 2
    while len(out) < count:
        m = u + n
        assert (m - n) ** 2 == 2 * n * n + 1
        if is_seed(m, n):
            out.append((m, n))
        u, n = 3 * u + 4 * n, 2 * u + 3 * n
    return out


def part1(max_m: int = 600) -> None:
    print(SEP)
    print(f"1. THE FULL DICHOTOMY, CHECKED ON EVERY EUCLID SEED WITH m <= "
          f"{max_m}")
    print(SEP)
    tot = above = below = 0
    worst_b2 = (1e9, None)
    for p in seeds(max_m):
        tot += 1
        r = residual(p)
        assert r <= residual(b1(p)) + 1e-15, ("B1", p)
        assert residual(b3(p)) <= r + 1e-15, ("B3", p)
        m, n = p
        rc = residual(b2(p))
        if m * m < 2 * m * n + n * n:
            above += 1
            assert rc <= r + 1e-15, ("B2 above", p)
            margin = (r - rc) / max(r, 1e-30)
        else:
            below += 1
            assert r <= rc + 1e-15, ("B2 below", p)
            margin = (rc - r) / max(r, 1e-30)
        if margin < worst_b2[0]:
            worst_b2 = (margin, p)
    print(f"   seeds tested                        : {tot}")
    print(f"   B1 raised the residual every time   : yes")
    print(f"   B3 lowered the residual every time  : yes")
    print(f"   B2 obeyed the threshold every time  : yes "
          f"({above} above, {below} below)")
    print(f"   narrowest relative B2 margin        : "
          f"{worst_b2[0]*100:.4f}%  at {worst_b2[1]}")


def part2(max_m: int = 4000) -> None:
    print()
    print(SEP)
    print("2. NO EUCLID SEED SITS EXACTLY ON THE THRESHOLD")
    print(SEP)
    hits = [p for p in seeds(max_m)
            if p[0] * p[0] == 2 * p[0] * p[1] + p[1] * p[1]]
    print(f"   seeds with m^2 = 2mn + n^2 among m <= {max_m}: {len(hits)}")
    print("   Reason: m^2 = 2mn + n^2 forces n | m^2, so coprimality gives")
    print("   n = 1 and then m^2 - 2m - 1 = 0, which has no integer root.")
    print(f"   threshold slope sqrt(2)-1 = {sqrt(2)-1:.12f}")


def part3() -> None:
    print()
    print(SEP)
    print("3. THE PELL BOUNDARY LAYER  (m-n)^2 = 2n^2 + 1")
    print(SEP)
    fam = pell_family(6)
    print(f"   {'seed':>16} {'c':>14} {'slope':>10} {'rho':>11} "
          f"{'rho(B2 child)':>14} {'margin':>10}")
    for p in fam:
        r, rc = residual(p), residual(b2(p))
        print(f"   {str(p):>16} {p[0]**2+p[1]**2:>14} {p[1]/p[0]:>10.7f}"
              f" {r:>11.7f} {rc:>14.7f} {(rc-r)/r*100:>9.4f}%")
    print("\n   Every one of these lies just BELOW the threshold, and on every")
    print("   one of them the exact residual rises along B2 -- as the")
    print("   dichotomy demands.")

    print("\n   WHY INTEGRALITY IS NEEDED.  The proof of the boundary-layer")
    print("   case supplies a *sufficient polynomial certificate*: it suffices")
    print("   that")
    print("       P(m,n) = mn(28n^4 - 96n^2 - 34) + (12n^6 - 30n^4 - 50n^2 - 8)")
    print("   be non-negative on the Pell locus m^2 = 2mn + n^2 + 1.  Both")
    print("   brackets turn non-negative exactly at n = 2, and the Pell")
    print("   equation forces n >= 2 (n = 1 would need m^2 = 2m + 2).")
    print()
    print(f"   {'n':>8} {'m = n+sqrt(2n^2+1)':>21} {'28n^4-96n^2-34':>17}"
          f" {'P(m,n)':>16} {'ok?':>6}")
    n = 0.20
    bad = []
    while n <= 3.0001:
        m = n + sqrt(2 * n * n + 1)
        br1 = 28 * n ** 4 - 96 * n ** 2 - 34
        P = m * n * br1 + (12 * n ** 6 - 30 * n ** 4 - 50 * n ** 2 - 8)
        if P < 0:
            bad.append(n)
        if abs(n * 10 - round(n * 10)) < 1e-9 and round(n * 10) % 2 == 0:
            print(f"   {n:>8.2f} {m:>21.6f} {br1:>17.3f} {P:>16.3f}"
                  f" {('yes' if P >= 0 else 'NO'):>6}")
        n += 0.001
    if bad:
        lo, hi = min(bad), max(bad)
        mlo = lo + sqrt(2 * lo * lo + 1)
        mhi = hi + sqrt(2 * hi * hi + 1)
        print(f"\n   The certificate FAILS for real n in [{lo:.3f}, {hi:.3f}],")
        print(f"   i.e. for (m,n) from ({mlo:.2f}, {lo:.2f}) to "
              f"({mhi:.2f}, {hi:.2f}) -- it fails, in particular, near")
        print("   (m,n) = (3.80, 1.48).  Every INTEGER point of the family has")
        print("   n >= 2 and so lies safely past the bad window.")
    print("\n   The two sides of the certified inequality at (5,2):")
    m, n = 5, 2
    lhs = (n * n + 1) * 2 * (((2 * m + n) ** 2 + m * m) * m * m)
    rhs = (((2 * m + n) ** 2 + m * m) * m * m
           - (2 * m + n) ** 2 * (m * m + n * n)) \
        * ((m * m + n * n) * (m * m + n * n + 1))
    print(f"       left = {lhs},   right = {rhs},   "
          f"margin = {(rhs - lhs) / lhs * 100:.2f}%")


def main() -> None:
    print()
    print("  THE MIDDLE BRANCH B2, ITS THRESHOLD, AND THE PELL BOUNDARY LAYER")
    print()
    part1()
    part2()
    part3()
    print()
    print(SEP)
    print("  Done.")
    print(SEP)
    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 1: two portraits of the Berggren tree in hyperbolic space.

Every primitive Pythagorean triple is written in Euclid coordinates (m,n)
with 0 < n < m, gcd(m,n) = 1 and m+n odd, and placed at the upper half-plane
point z(m,n) = (n+i)/m.  The three Berggren moves become
    B1(m,n) = (2m-n, m),   B2(m,n) = (2m+n, m),   B3(m,n) = (m+2n, n),
and the exact distance formula reads  cosh d(i, z(m,n)) = (m^2+n^2+1)/(2m).

LEFT PANEL: the tree inside the Poincare disk (Cayley transform
w = (z-i)/(z+i), which sends the base point i to the origin), with the
hyperbolic spheres of radius R = 1,...,6 shown as dashed circles.  Edges are
true hyperbolic geodesics.  The view is zoomed onto the occupied wedge: since
every node has imaginary part 1/m, the whole tree accumulates on the boundary
arc corresponding to the slope interval (0,1).

RIGHT PANEL: the same tree in slope-vs-size coordinates -- horizontal axis
the slope t = n/m, vertical axis the hypotenuse c = m^2+n^2 on a log scale,
which by the Logarithmic Trajectory Theorem is (twice) the hyperbolic radius.
The vertical dashed line marks the threshold slope sqrt(2)-1, which decides
the direction of the middle branch B2.  The three visible "fans" are the
slope images of B1 (into (1/2,1)), B2 (into (1/3,1/2)) and B3 (into (0,1/3)).

Output: berggren_disk_tree.png
"""

from __future__ import annotations

import math
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.collections import LineCollection

Seed = Tuple[int, int]
MAX_DEPTH = 7


def children(p: Seed) -> List[Seed]:
    m, n = p
    return [(2 * m - n, m), (2 * m + n, m), (m + 2 * n, n)]


def half_plane_point(p: Seed) -> complex:
    m, n = p
    return complex(n / m, 1 / m)


def to_disk(z: complex) -> complex:
    """Cayley transform of the upper half-plane onto the unit disk, i -> 0."""
    return (z - 1j) / (z + 1j)


def from_disk(w: complex) -> complex:
    """Inverse Cayley transform, disk -> upper half-plane."""
    return 1j * (1 + w) / (1 - w)


def hyp_dist(p: Seed) -> float:
    m, n = p
    return math.acosh((m * m + n * n + 1) / (2 * m))


def geodesic_arc(za: complex, zb: complex, steps: int = 40) -> np.ndarray:
    """Polyline for the hyperbolic geodesic between two half-plane points,
    pushed forward into the disk."""
    xa, ya, xb, yb = za.real, za.imag, zb.real, zb.imag
    pts: List[complex] = []
    if abs(xa - xb) < 1e-13:
        for t in np.linspace(0.0, 1.0, steps):
            pts.append(complex(xa, ya * (yb / ya) ** t))
    else:
        c = ((xb ** 2 + yb ** 2) - (xa ** 2 + ya ** 2)) / (2 * (xb - xa))
        r = math.hypot(xa - c, ya)
        ta, tb = math.atan2(ya, xa - c), math.atan2(yb, xb - c)
        for t in np.linspace(ta, tb, steps):
            pts.append(complex(c + r * math.cos(t), r * math.sin(t)))
    return np.array([[to_disk(z).real, to_disk(z).imag] for z in pts])


def build_edges() -> Dict[int, List[Tuple[Seed, Seed]]]:
    edges: Dict[int, List[Tuple[Seed, Seed]]] = {}
    level: List[Seed] = [(2, 1)]
    for d in range(1, MAX_DEPTH + 1):
        nxt: List[Seed] = []
        edges[d] = []
        for p in level:
            for q in children(p):
                edges[d].append((p, q))
                nxt.append(q)
        level = nxt
    return edges


def main() -> None:
    edges = build_edges()
    cmap = plt.get_cmap("plasma")
    fig, (axL, axR) = plt.subplots(1, 2, figsize=(15.5, 7.4))

    # ---------------- left: Poincare disk ----------------
    axL.set_aspect("equal")
    axL.axis("off")
    th = np.linspace(0, 2 * math.pi, 900)
    axL.plot(np.cos(th), np.sin(th), color="#222222", lw=1.6, zorder=5)
    for R in [1, 2, 3, 4, 5, 6]:
        rr = math.tanh(R / 2)
        axL.plot(rr * np.cos(th), rr * np.sin(th),
                 color="#bbbbbb", lw=0.7, ls="--", zorder=0)

    for d, elist in edges.items():
        segs = [geodesic_arc(half_plane_point(p), half_plane_point(q))
                for p, q in elist]
        axL.add_collection(LineCollection(
            segs, colors=[cmap(d / MAX_DEPTH)],
            linewidths=max(0.2, 1.6 - 0.20 * d), alpha=0.8, zorder=2))

    xs, ys, cs, ss = [], [], [], []
    seen = {(2, 1)}
    for d, elist in edges.items():
        for _, q in elist:
            if q in seen:
                continue
            seen.add(q)
            w = to_disk(half_plane_point(q))
            xs.append(w.real)
            ys.append(w.imag)
            cs.append(d)
            ss.append(max(0.8, 22 - 3.0 * d))
    axL.scatter(xs, ys, c=cs, cmap=cmap, vmin=0, vmax=MAX_DEPTH, s=ss,
                zorder=3, edgecolors="none")

    w0 = to_disk(half_plane_point((2, 1)))
    axL.scatter([w0.real], [w0.imag], s=80, color="#1f77b4", zorder=4)
    axL.annotate("(2,1) = (3,4,5)", (w0.real, w0.imag),
                 textcoords="offset points", xytext=(9, 7),
                 fontsize=10, color="#1f77b4", weight="bold")
    axL.scatter([0], [0], s=45, marker="+", color="#000000", zorder=4)
    axL.annotate("base point $i$", (0, 0), textcoords="offset points",
                 xytext=(7, -14), fontsize=9)
    for R, lab in [(1, "R=1"), (3, "R=3"), (5, "R=5")]:
        rr = math.tanh(R / 2)
        axL.text(-rr * 0.70, -rr * 0.70, lab, color="#999999", fontsize=8)

    pad = 0.06
    axL.set_xlim(min(xs + [0]) - pad, max(xs + [0]) + pad)
    axL.set_ylim(min(ys + [0]) - pad, max(ys + [0]) + pad)
    axL.set_title("Poincar\u00e9 disk: geodesic edges, dashed hyperbolic "
                  "spheres\n(zoomed on the occupied wedge)", fontsize=12)

    # ---------------- right: slope vs hypotenuse ----------------
    segs, colors = [], []
    for d, elist in edges.items():
        for p, q in elist:
            segs.append([[p[1] / p[0], p[0] ** 2 + p[1] ** 2],
                         [q[1] / q[0], q[0] ** 2 + q[1] ** 2]])
            colors.append(cmap(d / MAX_DEPTH))
    axR.add_collection(LineCollection(segs, colors=colors,
                                      linewidths=0.55, alpha=0.55, zorder=1))
    sx = [q[1] / q[0] for q in seen]
    sy = [q[0] ** 2 + q[1] ** 2 for q in seen]
    sc = [len(_address(q)) for q in seen]
    axR.scatter(sx, sy, c=sc, cmap=cmap, vmin=0, vmax=MAX_DEPTH, s=6,
                zorder=2, edgecolors="none")
    axR.axvline(math.sqrt(2) - 1, color="#d62728", lw=1.4, ls="--", zorder=3)
    axR.text(math.sqrt(2) - 1 + 0.008, 3.5, r"$t=\sqrt{2}-1$",
             color="#d62728", fontsize=11, rotation=90, va="bottom")
    for x, lab in [(1 / 3, "1/3"), (1 / 2, "1/2")]:
        axR.axvline(x, color="#888888", lw=0.8, ls=":", zorder=0)
        axR.text(x + 0.006, 3.2, lab, color="#888888", fontsize=9)
    axR.set_yscale("log")
    axR.set_xlim(0, 1)
    axR.set_xlabel("slope  $t = n/m$", fontsize=11)
    axR.set_ylabel("hypotenuse  $c = m^2+n^2$   (log scale $\\;\\approx\\; 2d$)",
                   fontsize=11)
    axR.set_title("Slope vs. size: $\\log c$ is twice the hyperbolic radius;\n"
                  "the three branch images tile $(0,1)$ at $1/3$ and $1/2$",
                  fontsize=12)
    axR.grid(alpha=0.25, which="both")

    sm = plt.cm.ScalarMappable(cmap=cmap,
                               norm=plt.Normalize(vmin=0, vmax=MAX_DEPTH))
    cb = fig.colorbar(sm, ax=axR, pad=0.015)
    cb.set_label("tree depth", fontsize=10)

    fig.suptitle("The Berggren tree of primitive Pythagorean triples in the "
                 "hyperbolic plane", fontsize=14, y=0.995)
    fig.tight_layout(rect=(0, 0, 1, 0.965))
    fig.savefig("berggren_disk_tree.png", dpi=165)
    print(f"wrote berggren_disk_tree.png ({len(seen)} nodes, "
          f"depths 0-{MAX_DEPTH})")


def _address(p: Seed) -> List[str]:
    word: List[str] = []
    while p != (2, 1):
        m, n = p
        if m > 3 * n:
            word.append("B3")
            p = (m - 2 * n, n)
        elif 2 * n < m <= 3 * n:
            word.append("B2")
            p = (n, m - 2 * n)
        else:
            word.append("B1")
            p = (n, 2 * n - m)
    return word


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 3: why short geodesics do not make factoring cheap.

LEFT PANEL -- volume growth.  #B(R), the number of Berggren nodes inside the
hyperbolic ball of radius R about the base point, plotted against e^{2R} on
log-log axes.  The proved bracket e^{2R}/300 <= #B(R) <= 4 e^{2R} is shaded,
and the heuristic asymptote (pi+2)/(4 pi^2) * e^{2R} is drawn.  Since a
collision for N is only guaranteed inside the ball of radius about
(1/2) log N + log 2, the search region already holds Theta(N) nodes.

RIGHT PANEL -- depth versus distance.  For every node of the tree up to depth
9, the combinatorial depth k is plotted against the hyperbolic distance d.
The proved inequality 2d <= log 32 + k log 9 (distance is dominated by depth)
appears as the lower envelope.  There is no reverse inequality: the LEFT
SPINE (k+2, k+1), highlighted, has depth k but distance only about
log k + 2, so depth there is Theta(sqrt(c)) while distance is Theta(log c).
The MIDDLE SPINE (consecutive Pell numbers), also highlighted, is the
opposite extreme, with d >= k log 2.

Output: berggren_nofreelunch.png
"""

from __future__ import annotations

import math
from math import acosh, gcd, log
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

Seed = Tuple[int, int]


def is_seed(m: int, n: int) -> bool:
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def hyp_dist(m: int, n: int) -> float:
    return acosh((m * m + n * n + 1) / (2 * m))


def all_seeds(max_m: int) -> List[Seed]:
    return [(m, n) for m in range(2, max_m + 1) for n in range(1, m)
            if is_seed(m, n)]


def tree_by_depth(max_depth: int) -> Dict[int, List[Seed]]:
    levels: Dict[int, List[Seed]] = {0: [(2, 1)]}
    for d in range(1, max_depth + 1):
        nxt: List[Seed] = []
        for m, n in levels[d - 1]:
            nxt += [(2 * m - n, m), (2 * m + n, m), (m + 2 * n, n)]
        levels[d] = nxt
    return levels


def main() -> None:
    fig, (axL, axR) = plt.subplots(1, 2, figsize=(15.0, 6.4))

    # ---------------- left: volume growth ----------------
    max_m = 4000
    dists = np.sort(np.array([hyp_dist(m, n) for m, n in all_seeds(max_m)]))
    Rs = np.arange(2.0, 8.01, 0.25)
    Rs = Rs[np.exp(Rs) < 0.9 * max_m]
    counts = np.array([np.searchsorted(dists, R, side="right") for R in Rs],
                      dtype=float)
    e2r = np.exp(2 * Rs)

    axL.fill_between(e2r, e2r / 300, 4 * e2r, color="#cfe3f7", alpha=0.7,
                     label=r"proved bracket $[\,e^{2R}/300,\ 4e^{2R}\,]$")
    pred = (math.pi + 2) / (4 * math.pi ** 2)
    axL.plot(e2r, pred * e2r, color="#d62728", lw=1.8, ls="--",
             label=r"heuristic $\frac{\pi+2}{4\pi^2}e^{2R}=0.13024\,e^{2R}$")
    axL.plot(e2r, counts, color="#1f77b4", lw=2.4, marker="o", ms=3.4,
             label=r"$\#\mathcal{B}(R)$, counted exactly")
    axL.set_xscale("log")
    axL.set_yscale("log")
    axL.set_xlabel(r"$e^{2R}$", fontsize=11)
    axL.set_ylabel(r"number of nodes in the ball of radius $R$", fontsize=11)
    axL.set_title("Volume growth: the ball of radius $R$ holds\n"
                  r"$\Theta(e^{2R})$ nodes - as many as there are "
                  "hypotenuses of that size", fontsize=12)
    axL.legend(loc="upper left", fontsize=9)
    axL.grid(alpha=0.25, which="both")

    # ---------------- right: depth vs distance ----------------
    levels = tree_by_depth(9)
    kk, dd = [], []
    for k, ps in levels.items():
        for m, n in ps:
            kk.append(k)
            dd.append(hyp_dist(m, n))
    axR.scatter(dd, kk, s=4, color="#999999", alpha=0.35, edgecolors="none",
                label="Berggren nodes, depth $\\leq 9$")

    ks = np.arange(0, 60)
    dmax = (math.log(32) + ks * math.log(9)) / 2
    axR.plot(dmax, ks, color="#d62728", lw=2.0,
             label=r"proved: $2d \leq \log 32 + k\log 9$")

    kl = np.arange(1, 4000)
    dl = np.array([hyp_dist(k + 2, k + 1) for k in kl])
    axR.plot(dl, kl, color="#2ca02c", lw=2.2,
             label=r"left spine $(k{+}2,k{+}1)$: depth $\Theta(\sqrt{c})$")

    km, dm, p = [], [], (2, 1)
    for k in range(0, 40):
        if k:
            p = (2 * p[0] + p[1], p[0])
        km.append(k)
        dm.append(hyp_dist(*p))
    axR.plot(dm, km, color="#9467bd", lw=2.2, marker="s", ms=2.6,
             label=r"middle (Pell) spine: $d \geq k\log 2$")

    axR.set_yscale("log")
    axR.set_xlim(0, 30)
    axR.set_ylim(0.8, 4000)
    axR.set_xlabel(r"hyperbolic distance  $d(i, z(m,n))$", fontsize=11)
    axR.set_ylabel(r"combinatorial depth  $k$  (log scale)", fontsize=11)
    axR.set_title("Distance is dominated by depth, but not conversely:\n"
                  "the left spine is exponentially deeper than it is far",
                  fontsize=12)
    axR.legend(loc="upper left", fontsize=9)
    axR.grid(alpha=0.25, which="both")

    fig.suptitle("No free lunch: short geodesics, exponentially many of them",
                 fontsize=14, y=0.995)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("berggren_nofreelunch.png", dpi=165)
    print("wrote berggren_nofreelunch.png "
          f"(ratios #B(R)/e^2R from {counts[0]/e2r[0]:.5f} "
          f"to {counts[-1]/e2r[-1]:.5f}; predicted {pred:.5f})")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 2: the residual collapses onto a single universal curve.

For a Euclid seed (m,n) with hypotenuse c = m^2+n^2 and slope t = n/m, the
residual is
    rho(m,n) = d(i, z(m,n)) - (1/2) log c,        cosh d = (c+1)/(2m),
and the Slope Model says rho is the universal function
    rho_as(t) = (1/2) log(1 + t^2)
up to a gap that is squeezed between n^2/(c^2+n^2) and n^2/(c(c-1)).

LEFT PANEL: rho plotted against the slope for every seed with m <= 300.  The
points collapse onto the curve (1/2) log(1+t^2) (black) with a visible spread
only at small c.  The horizontal band [0, (1/2) log 2] is the trajectory
window.

RIGHT PANEL: the gap rho - rho_as against the hypotenuse c, on log-log axes,
with the certified upper and lower bounds.  The gap decays like n^2/c^2, and
the two bounds differ by the factor (c+1)/(c-1), which is why the shaded
region is invisibly thin for large c.

Output: berggren_residual.png
"""

from __future__ import annotations

import math
from math import acosh, gcd, log
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np

Seed = Tuple[int, int]


def is_seed(m: int, n: int) -> bool:
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def seeds(max_m: int) -> List[Seed]:
    return [(m, n) for m in range(2, max_m + 1) for n in range(1, m)
            if is_seed(m, n)]


def residual(m: int, n: int) -> float:
    c = m * m + n * n
    return acosh((c + 1) / (2 * m)) - 0.5 * log(c)


def slope_model(m: int, n: int) -> float:
    return 0.5 * log(1 + (n / m) ** 2)


def main() -> None:
    S = seeds(300)
    t = np.array([n / m for m, n in S])
    c = np.array([m * m + n * n for m, n in S], dtype=float)
    nn = np.array([n for _, n in S], dtype=float)
    rho = np.array([residual(m, n) for m, n in S])
    rho_as = np.array([slope_model(m, n) for m, n in S])
    gap = rho - rho_as

    fig, (axL, axR) = plt.subplots(1, 2, figsize=(15.0, 6.4))

    # -------- left: collapse onto the universal curve --------
    sc = axL.scatter(t, rho, c=np.log10(c), cmap="viridis", s=7,
                     alpha=0.75, edgecolors="none")
    tt = np.linspace(0, 1, 400)
    axL.plot(tt, 0.5 * np.log(1 + tt ** 2), color="black", lw=2.2,
             label=r"slope model $\frac{1}{2}\log(1+t^2)$")
    axL.axhline(0.5 * math.log(2), color="#d62728", ls="--", lw=1.3,
                label=r"$\frac{1}{2}\log 2 = 0.34657$")
    axL.axhline(0.0, color="#d62728", ls="--", lw=1.3)
    axL.axvline(math.sqrt(2) - 1, color="#888888", ls=":", lw=1.2)
    axL.text(math.sqrt(2) - 1 + 0.008, 0.015, r"$\sqrt{2}-1$",
             fontsize=10, color="#555555", rotation=90)
    axL.set_xlabel(r"slope  $t = n/m$", fontsize=11)
    axL.set_ylabel(r"residual  $\rho = d - \frac{1}{2}\log c$", fontsize=11)
    axL.set_title("Every node's residual is a function of its shape alone\n"
                  "(all Euclid seeds with $m\\leq 300$)", fontsize=12)
    axL.set_xlim(0, 1)
    axL.set_ylim(-0.01, 0.37)
    axL.legend(loc="upper left", fontsize=10)
    axL.grid(alpha=0.25)
    cb = fig.colorbar(sc, ax=axL, pad=0.015)
    cb.set_label(r"$\log_{10} c$", fontsize=10)

    # -------- right: the gap and its certified bounds --------
    lo = nn ** 2 / (c ** 2 + nn ** 2)
    hi = nn ** 2 / (c * (c - 1))
    order = np.argsort(c)
    axR.scatter(c, hi, s=9, color="#d62728", alpha=0.30,
                edgecolors="none", label=r"upper bound $n^2/(c(c-1))$")
    axR.scatter(c, lo, s=9, color="#2ca02c", alpha=0.30,
                edgecolors="none", label=r"lower bound $n^2/(c^2+n^2)$")
    axR.scatter(c, gap, s=2, color="#1f77b4", alpha=0.85,
                edgecolors="none", label=r"true gap $\rho-\rho_{as}$")
    cs = np.sort(c)
    axR.plot(cs, 1.0 / cs, color="#888888", lw=1.5, ls="--",
             label=r"the old $O(1/c)$ bound")
    axR.set_xscale("log")
    axR.set_yscale("log")
    axR.set_xlabel(r"hypotenuse  $c = m^2+n^2$", fontsize=11)
    axR.set_ylabel(r"gap  $\rho - \rho_{\mathrm{as}}$", fontsize=11)
    axR.set_title("The gap is pinned to within the factor $(c+1)/(c-1)$;\n"
                  r"it is of size $n^2/c^2$, not $1/c$", fontsize=12)
    axR.legend(loc="lower left", fontsize=9)
    axR.grid(alpha=0.25, which="both")

    assert np.all(lo - 1e-15 <= gap) and np.all(gap <= hi + 1e-15)
    _ = order

    fig.suptitle("The residual of a Berggren node, exactly", fontsize=14,
                 y=0.995)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("berggren_residual.png", dpi=165)
    print(f"wrote berggren_residual.png ({len(S)} seeds; "
          "certified bounds verified on all of them)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Hyperbolic-Pythagorean Geodesics: numerical demonstration
=========================================================

Self-contained numerical companion to "Hyperbolic-Pythagorean Geodesics:
The Berggren Tree in the Poincare Half-Plane".

Everything is verified numerically here:

  1. Euclid seeds <-> primitive Pythagorean triples, and the three Berggren
     moves B1, B2, B3 in seed coordinates.
  2. The exact distance formula  cosh d(i, z(m,n)) = (m^2+n^2+1)/(2m).
  3. The logarithmic trajectory law  (1/2)log c <= d <= (1/2)log(2(c+1)).
  4. The residual  rho = d - (1/2)log c  and its slope model
     (1/2)log(1 + (n/m)^2), together with the exact gap identity and the
     two-sided bounds  n^2/(c^2+n^2) <= gap <= n^2/(c(c-1)).
  5. Branch monotonicity: B1 always raises rho, B3 always lowers it, and B2
     is governed by the threshold slope sqrt(2)-1, including the Pell
     boundary layer (m-n)^2 = 2n^2 + 1.
  6. Tree structure: the descent-to-root algorithm, depth vs distance on the
     left and middle spines.
  7. Volume growth Theta(e^{2R}) of hyperbolic balls of nodes.
  8. Euler's two-representation factorization from a Berggren collision, and
     the no-free-lunch count.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import math
from math import acosh, gcd, isqrt, log, sqrt
from typing import Dict, Iterator, List, Tuple

Seed = Tuple[int, int]

SEP = "=" * 74
SUB = "-" * 74


# ----------------------------------------------------------------------------
# 1. Euclid seeds and the Berggren moves
# ----------------------------------------------------------------------------

def is_seed(m: int, n: int) -> bool:
    """A Euclid seed: 0 < n < m, gcd(m,n) = 1, m + n odd."""
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def euclid_triple(m: int, n: int) -> Tuple[int, int, int]:
    """The primitive Pythagorean triple (m^2-n^2, 2mn, m^2+n^2)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def hypotenuse(m: int, n: int) -> int:
    """c = m^2 + n^2."""
    return m * m + n * n


def slope(m: int, n: int) -> float:
    """t = n/m, always in (0,1) for a seed."""
    return n / m


def b1(p: Seed) -> Seed:
    """Berggren move B1 in seed coordinates: (m,n) -> (2m-n, m)."""
    m, n = p
    return (2 * m - n, m)


def b2(p: Seed) -> Seed:
    """Berggren move B2 in seed coordinates: (m,n) -> (2m+n, m)."""
    m, n = p
    return (2 * m + n, m)


def b3(p: Seed) -> Seed:
    """Berggren move B3 in seed coordinates: (m,n) -> (m+2n, n)."""
    m, n = p
    return (m + 2 * n, n)


BRANCHES = {"B1": b1, "B2": b2, "B3": b3}
ROOT: Seed = (2, 1)


def bstep_matrix(name: str, t: Tuple[int, int, int]) -> Tuple[int, int, int]:
    """The original 3x3 Berggren matrices acting on a triple (a,b,c)."""
    a, b, c = t
    if name == "B1":
        return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)
    if name == "B2":
        return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)
    if name == "B3":
        return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)
    raise ValueError(name)


# ----------------------------------------------------------------------------
# 2. The hyperbolic geometry
# ----------------------------------------------------------------------------

def cosh_dist(m: int, n: int) -> float:
    """cosh of the hyperbolic distance from i to z(m,n) = (n+i)/m.

    Exact Distance Formula:  cosh d = (m^2 + n^2 + 1) / (2m).
    """
    return (m * m + n * n + 1) / (2 * m)


def hyp_dist(m: int, n: int) -> float:
    """The hyperbolic distance d(i, z(m,n)) itself."""
    return acosh(cosh_dist(m, n))


def hyp_dist_direct(m: int, n: int) -> float:
    """Same distance computed straight from the half-plane metric formula
    cosh d(z,w) = 1 + |z-w|^2 / (2 Im z Im w), as an independent check."""
    zx, zy = 0.0, 1.0            # z = i
    wx, wy = n / m, 1 / m        # w = (n+i)/m
    d2 = (zx - wx) ** 2 + (zy - wy) ** 2
    return acosh(1 + d2 / (2 * zy * wy))


def residual(m: int, n: int) -> float:
    """rho(m,n) = d(i, z(m,n)) - (1/2) log c."""
    return hyp_dist(m, n) - 0.5 * log(hypotenuse(m, n))


def slope_model(m: int, n: int) -> float:
    """rho_as(m,n) = (1/2) log(1 + (n/m)^2)."""
    return 0.5 * log(1 + (n / m) ** 2)


def gap(m: int, n: int) -> float:
    """gap = rho - rho_as >= 0."""
    return residual(m, n) - slope_model(m, n)


def gap_identity(m: int, n: int) -> float:
    """gap computed from the exact identity exp(gap) = ((c+1)+S)/(2c),
    S = sqrt((c+1)^2 - 4m^2)."""
    c = hypotenuse(m, n)
    S = sqrt((c + 1) ** 2 - 4 * m * m)
    return log(((c + 1) + S) / (2 * c))


def gap_bounds(m: int, n: int) -> Tuple[float, float]:
    """Certified interval  [ n^2/(c^2+n^2),  n^2/(c(c-1)) ]  for the gap."""
    c = hypotenuse(m, n)
    return (n * n / (c * c + n * n), n * n / (c * (c - 1)))


# ----------------------------------------------------------------------------
# 3. Tree structure: parent, depth, address
# ----------------------------------------------------------------------------

def parent_seed(p: Seed) -> Seed:
    """The inverse Berggren move, selected by the slope trichotomy
    n/m in (0,1/3), (1/3,1/2), (1/2,1)."""
    m, n = p
    if m > 3 * n:
        return (m - 2 * n, n)      # undo B3
    if 2 * n < m <= 3 * n:
        return (n, m - 2 * n)      # undo B2
    return (n, 2 * n - m)          # undo B1


def address(p: Seed) -> List[str]:
    """The word in {B1,B2,B3}* leading from the root (2,1) to p."""
    word: List[str] = []
    while p != ROOT:
        m, n = p
        if m > 3 * n:
            word.append("B3")
        elif 2 * n < m <= 3 * n:
            word.append("B2")
        else:
            word.append("B1")
        p = parent_seed(p)
    word.reverse()
    return word


def depth(p: Seed) -> int:
    """The unique depth at which p occurs in the Berggren tree."""
    return len(address(p))


def enumerate_seeds(max_m: int) -> Iterator[Seed]:
    """All Euclid seeds with m <= max_m."""
    for m in range(2, max_m + 1):
        for n in range(1, m):
            if is_seed(m, n):
                yield (m, n)


# ----------------------------------------------------------------------------
# 4. Euler factorization from a collision
# ----------------------------------------------------------------------------

def representations(N: int) -> List[Seed]:
    """All Euclid seeds (m,n) with m^2 + n^2 = N."""
    out: List[Seed] = []
    for m in range(1, isqrt(N) + 1):
        r = N - m * m
        n = isqrt(r)
        if n * n == r and is_seed(m, n):
            out.append((m, n))
    return out


def euler_split(N: int, p1: Seed, p2: Seed) -> Tuple[int, int]:
    """Euler's two-representation factorization of N from two seeds."""
    (a, b), (c, d) = p1, p2
    return (gcd(N, a * c + b * d), gcd(N, a * d + b * c))


def collision_family(j: int) -> Tuple[Seed, Seed, int]:
    """The explicit family (20j+9, 10j+2), (20j+7, 10j+6) with common
    hypotenuse 500 j^2 + 400 j + 85."""
    p1 = (20 * j + 9, 10 * j + 2)
    p2 = (20 * j + 7, 10 * j + 6)
    return p1, p2, 500 * j * j + 400 * j + 85


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_conjugation() -> None:
    print(SEP)
    print("1. THE BERGGREN MATRICES, CONJUGATED TO SEED COORDINATES")
    print(SEP)
    print("   B1(m,n) = (2m-n, m)   B2(m,n) = (2m+n, m)   B3(m,n) = (m+2n, n)\n")
    ok = True
    for m, n in [(2, 1), (3, 2), (4, 1), (5, 2), (8, 1), (7, 4), (12, 5)]:
        t = euclid_triple(m, n)
        for name, move in BRANCHES.items():
            child = move((m, n))
            lhs = bstep_matrix(name, t)
            rhs = euclid_triple(*child)
            ok &= lhs == rhs
        print(f"   seed ({m},{n}) -> triple {t};  children "
              f"{b1((m,n))}, {b2((m,n))}, {b3((m,n))}")
    print(f"\n   matrix action == seed action on all tested nodes: {ok}")
    print("   all children are Euclid seeds:",
          all(is_seed(*mv((m, n)))
              for m, n in enumerate_seeds(30) for mv in BRANCHES.values()))


def demo_distance_formula() -> None:
    print()
    print(SEP)
    print("2. THE EXACT DISTANCE FORMULA   cosh d(i, z(m,n)) = (c+1)/(2m)")
    print(SEP)
    print(f"   {'seed':>10}  {'c':>7}  {'cosh d (formula)':>18}"
          f"  {'d (formula)':>13}  {'d (metric)':>13}")
    worst = 0.0
    for m, n in [(2, 1), (3, 2), (4, 1), (5, 2), (8, 1), (7, 4),
                 (12, 5), (29, 12), (169, 70)]:
        d1, d2 = hyp_dist(m, n), hyp_dist_direct(m, n)
        worst = max(worst, abs(d1 - d2))
        print(f"   {f'({m},{n})':>10}  {hypotenuse(m,n):>7}"
              f"  {cosh_dist(m,n):>18.9f}  {d1:>13.9f}  {d2:>13.9f}")
    print(f"\n   max |formula - direct metric| = {worst:.3e}")


def demo_trajectory_law() -> None:
    print()
    print(SEP)
    print("3. THE LOGARITHMIC TRAJECTORY LAW")
    print("   (1/2) log c  <=  d  <=  (1/2) log(2(c+1))")
    print(SEP)
    lo_ok = hi_ok = True
    max_resid = 0.0
    for m, n in enumerate_seeds(400):
        c = hypotenuse(m, n)
        d = hyp_dist(m, n)
        lo_ok &= d >= 0.5 * log(c) - 1e-12
        hi_ok &= d <= 0.5 * log(2 * (c + 1)) + 1e-12
        max_resid = max(max_resid, d - 0.5 * log(c))
    n_seeds = sum(1 for _ in enumerate_seeds(400))
    print(f"   tested {n_seeds} seeds with m <= 400")
    print(f"   lower bound  d >= (1/2) log c              : {lo_ok}")
    print(f"   upper bound  d <= (1/2) log(2(c+1))        : {hi_ok}")
    print(f"   largest residual observed                  : {max_resid:.6f}")
    print(f"   theoretical window width  (1/2) log 2      : {0.5*log(2):.6f}")
    print("\n   A 100-digit hypotenuse sits at distance only "
          f"{0.5*log(10**100):.2f} from the root.")


def demo_residual_and_gap() -> None:
    print()
    print(SEP)
    print("4. THE RESIDUAL, ITS SLOPE MODEL, AND THE EXACT GAP")
    print(SEP)
    print(f"   {'seed':>10} {'c':>6} {'rho':>10} {'slope model':>12}"
          f" {'gap':>11} {'lower bnd':>11} {'upper bnd':>11}")
    for m, n in [(2, 1), (3, 2), (4, 1), (5, 2), (7, 4), (8, 1),
                 (9, 4), (12, 5), (29, 12), (169, 70)]:
        g = gap(m, n)
        lo, hi = gap_bounds(m, n)
        print(f"   {f'({m},{n})':>10} {hypotenuse(m,n):>6} {residual(m,n):>10.6f}"
              f" {slope_model(m,n):>12.6f} {g:>11.3e} {lo:>11.3e} {hi:>11.3e}")

    print("\n   Checking the exact identity exp(gap) = ((c+1)+S)/(2c)"
          " and the certified bounds:")
    worst_id, bounds_ok = 0.0, True
    for m, n in enumerate_seeds(300):
        g = gap(m, n)
        worst_id = max(worst_id, abs(g - gap_identity(m, n)))
        lo, hi = gap_bounds(m, n)
        bounds_ok &= (lo - 1e-14 <= g <= hi + 1e-14)
    print(f"   max |gap - identity| over all seeds m<=300 : {worst_id:.3e}")
    print(f"   n^2/(c^2+n^2) <= gap <= n^2/(c(c-1))       : {bounds_ok}")
    print("\n   At (4,1): naive 1/c bound = "
          f"{1/17:.6f}, intermediate (n^2+1)/(c(c+1)) = {2/(17*18):.6f},")
    lo, hi = gap_bounds(4, 1)
    print(f"   sharp sandwich = [{lo:.6f}, {hi:.6f}], true gap = {gap(4,1):.7f}")


def demo_branch_monotonicity() -> None:
    print()
    print(SEP)
    print("5. BRANCH MONOTONICITY OF THE EXACT RESIDUAL")
    print(SEP)
    threshold = sqrt(2) - 1
    b1_ok = b3_ok = b2_ok = True
    n_above = n_below = 0
    for m, n in enumerate_seeds(300):
        r = residual(m, n)
        b1_ok &= r <= residual(*b1((m, n))) + 1e-15
        b3_ok &= residual(*b3((m, n))) <= r + 1e-15
        rc = residual(*b2((m, n)))
        if m * m < 2 * m * n + n * n:        # slope above sqrt(2)-1
            n_above += 1
            b2_ok &= rc <= r + 1e-15
        else:                                # slope below
            n_below += 1
            b2_ok &= r <= rc + 1e-15
    print(f"   threshold slope sqrt(2)-1 = {threshold:.9f}\n")
    print(f"   B1 always increases rho                    : {b1_ok}")
    print(f"   B3 always decreases rho                    : {b3_ok}")
    print(f"   B2 follows the threshold dichotomy exactly : {b2_ok}")
    print(f"   ({n_above} seeds above the threshold, {n_below} below)")

    print("\n   No seed satisfies m^2 = 2mn + n^2 (coprimality forbids it):",
          not any(m * m == 2 * m * n + n * n for m, n in enumerate_seeds(2000)))

    print("\n   The smallest seed on the 'wrong side' for B2:")
    print(f"     (4,1) slope 0.25 < {threshold:.6f};  "
          f"rho(4,1) = {residual(4,1):.6f} < rho(9,4) = {residual(9,4):.6f}")

    print("\n   The Pell boundary layer  (m-n)^2 = 2n^2 + 1"
          "  (closed only via the integrality n >= 2):")
    print(f"   {'seed':>12} {'(m-n)^2':>10} {'2n^2+1':>10}"
          f" {'rho(m,n)':>11} {'rho(B2)':>11} {'margin':>11}")
    for m, n in [(5, 2), (29, 12), (169, 70), (985, 408)]:
        r, rc = residual(m, n), residual(*b2((m, n)))
        print(f"   {f'({m},{n})':>12} {(m-n)**2:>10} {2*n*n+1:>10}"
              f" {r:>11.7f} {rc:>11.7f} {(rc-r)/r*100:>10.2f}%")


def demo_tree_structure() -> None:
    print()
    print(SEP)
    print("6. TREE STRUCTURE: DESCENT, DEPTH, AND THE TWO SPINES")
    print(SEP)
    print("   Descent to the root by the slope trichotomy:\n")
    for p in [(2, 1), (3, 2), (12, 5), (8, 1), (7, 4), (20, 9)]:
        print(f"     {str(p):>9}  depth {depth(p)}  address "
              f"{' '.join(address(p)) or '(root)'}")

    print("\n   Every seed with m <= 120 is reachable at exactly one depth,")
    print("   and its address reconstructs it:", all(
        _walk(address(p)) == p for p in enumerate_seeds(120)))

    print("\n   LEFT spine  (all B1): depth k, hypotenuse 2k^2+6k+5")
    print(f"   {'k':>4} {'seed':>12} {'c':>10} {'distance d':>12} {'d/k':>9}")
    for k in [1, 4, 16, 64, 256, 1024]:
        p = (k + 2, k + 1)
        print(f"   {k:>4} {str(p):>12} {hypotenuse(*p):>10}"
              f" {hyp_dist(*p):>12.5f} {hyp_dist(*p)/k:>9.5f}")
    print("   -> depth grows like sqrt(c): distance is NOT a proxy for depth.")

    print("\n   MIDDLE spine (all B2): consecutive Pell numbers, c >= 4^(k+1)")
    print(f"   {'k':>4} {'seed':>18} {'c':>16} {'distance d':>12} {'d/k':>9}")
    p = ROOT
    for k in range(0, 9):
        if k:
            p = b2(p)
        dk = hyp_dist(*p)
        r = f"{dk/k:.5f}" if k else "   -"
        print(f"   {k:>4} {str(p):>18} {hypotenuse(*p):>16} {dk:>12.5f} {r:>9}")
    print("   -> here depth and distance ARE commensurable (d >= k log 2 ="
          f" {log(2):.5f} k).")

    print("\n   Logarithmic reach: for every N there is a node of hypotenuse")
    print("   >= N at depth floor(log2 N).")
    for N in [10, 1000, 10 ** 6, 10 ** 9]:
        k = N.bit_length() - 1
        q = ROOT
        for _ in range(k):
            q = b2(q)
        print(f"     N = {N:<12} depth {k:>3}   hypotenuse {hypotenuse(*q)}"
              f"   ({'>=' if hypotenuse(*q) >= N else '<'} N)")


def _walk(word: List[str]) -> Seed:
    p = ROOT
    for w in word:
        p = BRANCHES[w](p)
    return p


def demo_volume_growth() -> None:
    print()
    print(SEP)
    print("7. VOLUME GROWTH OF HYPERBOLIC BALLS:  #B(R) = Theta(e^{2R})")
    print(SEP)
    # Heuristic constant.  cosh d <= cosh R is the disc (m - cosh R)^2 + n^2
    # <= sinh^2 R in the (m,n) plane; rescaling by cosh R it becomes the unit
    # disc centred at (1,0), intersected with 0 < n < m.  That region has area
    # pi/4 + 1/2.  Euclid seeds have density 4/pi^2 among all integer pairs
    # (coprime density 6/pi^2, times the 2/3 of coprime pairs with opposite
    # parity).  Hence #B(R) ~ (4/pi^2)(e^{2R}/4)(pi/4 + 1/2) = (pi+2)/(4 pi^2).
    predicted = (math.pi + 2) / (4 * math.pi ** 2)
    print(f"   {'R':>6} {'#B(R)':>10} {'e^{2R}':>14} {'#B(R)/e^{2R}':>14}"
          f" {'lower 1/300':>12} {'upper 4':>9}")
    max_m = 4000
    seeds = list(enumerate_seeds(max_m))
    dists = sorted(hyp_dist(m, n) for m, n in seeds)
    for R in [3.0, 4.0, 5.0, 6.0, 7.0, 8.0]:
        if math.exp(R) > max_m * 0.9:
            break
        cnt = sum(1 for d in dists if d <= R)
        e2r = math.exp(2 * R)
        print(f"   {R:>6.1f} {cnt:>10} {e2r:>14.1f} {cnt/e2r:>14.5f}"
              f" {1/300:>12.5f} {4.0:>9.1f}")
    print(f"\n   The ratio settles near (pi+2)/(4 pi^2) = {predicted:.6f},")
    print("   the constant predicted by the disc-area heuristic above.")
    print("   The proved bounds 1/300 = 0.00333 and 4 bracket it comfortably;")
    print("   the exact asymptotic constant remains conjectural.")


def demo_factoring() -> None:
    print()
    print(SEP)
    print("8. COLLISIONS FACTOR, AND WHY THAT DOES NOT HELP")
    print(SEP)
    print("   A collision is a hypotenuse carried by two distinct nodes.")
    print("   Euler:  gcd(N, ac+bd) * gcd(N, ad+bc) = N.\n")

    found: Dict[int, List[Seed]] = {}
    for m, n in enumerate_seeds(60):
        found.setdefault(hypotenuse(m, n), []).append((m, n))
    colls = sorted(N for N, ps in found.items() if len(ps) >= 2)

    print(f"   {'N':>8} {'reps':>22} {'g':>6} {'h':>6} {'g*h':>8} {'ok':>5}")
    for N in colls[:12]:
        p1, p2 = found[N][0], found[N][1]
        g, h = euler_split(N, p1, p2)
        print(f"   {N:>8} {f'{p1} {p2}':>22} {g:>6} {h:>6} {g*h:>8}"
              f" {str(g*h == N):>5}")

    print("\n   Colliding nodes are hyperbolic neighbours (|d1 - d2| <= 2 log 2"
          f" = {2*log(2):.5f}):")
    for N in colls[:6]:
        p1, p2 = found[N][0], found[N][1]
        print(f"     N = {N:>6}: d1 = {hyp_dist(*p1):.6f}, "
              f"d2 = {hyp_dist(*p2):.6f}, |diff| = "
              f"{abs(hyp_dist(*p1)-hyp_dist(*p2)):.6f}")

    print("\n   Collisions at every scale: (20j+9, 10j+2) and (20j+7, 10j+6)")
    print(f"   {'j':>4} {'seed 1':>14} {'seed 2':>14} {'N':>12}"
          f" {'g':>5} {'h':>8}")
    for j in range(6):
        p1, p2, N = collision_family(j)
        assert hypotenuse(*p1) == N == hypotenuse(*p2)
        assert is_seed(*p1) and is_seed(*p2)
        g, h = euler_split(N, p1, p2)
        print(f"   {j:>4} {str(p1):>14} {str(p2):>14} {N:>12} {g:>5} {h:>8}")

    print("\n   Semiprime example: N = 65 = 5 * 13")
    reps = representations(65)
    g, h = euler_split(65, reps[0], reps[1])
    print(f"     representations {reps} -> factors {g} and {h}")

    print("\n   THE NO-FREE-LUNCH COUNT.  To be sure of catching a collision")
    print("   for N one must search the ball of radius ~ (1/2) log N + log 2,")
    print("   which already contains Theta(e^{2R}) = Theta(N) nodes:\n")
    print(f"   {'N':>14} {'R = (1/2)logN + log2':>22}"
          f" {'e^{2R} (~ 4N)':>18}")
    for N in [10 ** 3, 10 ** 6, 10 ** 9, 10 ** 12]:
        R = 0.5 * log(N) + log(2)
        print(f"   {N:>14} {R:>22.4f} {math.exp(2*R):>18.3e}")
    print("\n   Short geodesics -- but exponentially many of them.")


def main() -> None:
    print()
    print("  HYPERBOLIC-PYTHAGOREAN GEODESICS")
    print("  The Berggren tree of Pythagorean triples in the Poincare"
          " half-plane")
    print(SUB)
    demo_conjugation()
    demo_distance_formula()
    demo_trajectory_law()
    demo_residual_and_gap()
    demo_branch_monotonicity()
    demo_tree_structure()
    demo_volume_growth()
    demo_factoring()
    print()
    print(SEP)
    print("  All numerical checks completed.")
    print(SEP)
    print()


if __name__ == "__main__":
    main()
