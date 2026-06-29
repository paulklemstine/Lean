import json, pathlib

base = pathlib.Path(__file__).parent

def rd(name):
    return (base / name).read_text()

article = rd("ARTICLE.md")
paper = rd("RESEARCH_PAPER.md")
demo = rd("demo.py")
viz = rd("visualize.py")
html = rd("interactive.html")
higher = rd("HigherPersistence.lean")
stability = rd("PersistenceStability.lean")

lean_proofs = (
    "/- ===== HigherPersistence.lean ===== -/\n\n" + higher +
    "\n\n/- ===== PersistenceStability.lean ===== -/\n\n" + stability
)

future_directions = """# Future Directions — The Boltzmann Bridge: Nerve Interleaving & the f-vector

## Synthesis

This cycle pushed the catalog's higher-dimensional persistence backbone
(HigherPersistence.lean's Filtration calculus, VRfaces, vr_mem_iff_diam_le,
and euler_char_full_simplex; PersistenceStability.lean's interleaving/stability
results) in two complementary directions and *closed* them with sorry-free proofs.

First, the **combinatorial Nerve Lemma** (CechNerve.lean). We introduced the
Cech filtration CechFaces e -- simplices whose vertices share a common closed
e-ball -- and proved it is a genuine filtration (downward closed cech_down_closed,
monotone cech_mono) interleaved with Vietoris-Rips: Cech(e) subset VR(2e) and,
on nonempty faces, VR(e) subset Cech(e), assembled into the classical sandwich
Cech(e) subset VR(2e) subset Cech(2e) (nerve_interleaving). The single piece of
metric input is the triangle inequality; everything else is the kind of forall
x in sigma bookkeeping the Filtration framework now makes routine. The structural
lesson is that the *only* place the constant 2 (the interleaving slack) enters is
the forward inclusion, and it is forced purely by dist x y <= dist x c + dist c y.

Second, the **Euler-Poincare / f-vector bridge** (FaceVector.lean). We defined
the dimension-graded face count fVector and the combinatorial Euler
characteristic eulerCharFin of an arbitrary finite complex, then proved the
bridge eulerChar_eq_alt_fVector: for any complex with a dimension bound, the
Euler characteristic equals the alternating sum of the f-vector. The proof is a
fibrewise regrouping (Finset.sum_fiberwise_of_maps_to) by dimension -- notably
this holds for *any* finite complex, not just the full simplex; the cancellation
that yields a *small* answer is a separate, complex-specific phenomenon.
Specializing via fVector_full_simplex (the f-vector of the full simplex is the
binomial row C(n,k)) recovers the catalog's euler_char_full_simplex now as a
statement about an actual simplicial complex (eulerChar_full_simplex). The
emergent insight tying both threads together: persistent topology is governed by
two orthogonal "ledgers" -- a *metric* ledger (distances, which control
interleaving slack) and a *combinatorial* ledger (face counts, which control the
Euler characteristic) -- and the Filtration abstraction lets each be reasoned
about without touching the other.

What did *not* happen this cycle: we deliberately did not attempt full persistent
*homology* (chain complexes, Betti numbers), because Mathlib's simplicial homology
API is not in a form that plugs into our Finset-of-faces model without
substantial scaffolding. The f-vector bridge is the honest, provable shadow of the
Euler-Poincare theorem available today, and it cleanly signposts what the homology
upgrade would require.

## Results Summary

- CechFaces: definition -- the Cech (nerve) filtration as the common-ball cover model.
- cech_down_closed: proved -- Cech faces form a complex (downward closed).
- cech_mono: proved -- the Cech filtration is nested in the radius.
- cech_subset_vr: proved -- Cech(e) subset VR(2e) via the triangle inequality.
- vr_subset_cech: proved -- nonempty VR(e) faces are Cech(e) faces.
- nerve_interleaving: proved -- the sandwich Cech(e) subset VR(2e) subset Cech(2e).
- fVector / eulerCharFin: definitions -- dimension-graded face count and Euler char.
- eulerChar_eq_alt_fVector: proved -- Euler characteristic equals alternating f-vector.
- fVector_full_simplex: proved -- the full simplex has C(n,k) faces of k vertices.
- eulerChar_full_simplex: proved -- the full simplex has Euler characteristic 1.

## Toward higher persistence

1. **f-vector / h-vector and shellability.** The alternating-binomial cancellation
   of euler_char_full_simplex is the shadow of d-squared = 0; the same identity
   computes the Euler characteristic of any shellable complex once its f-vector is
   known. Next: the dimension-graded face count over sublevelFaces as a monotone
   step function whose alternating sum jumps at simplex weights.

2. **Metric stability of diamWeight.** diamWeight is a Finset.sup', which is
   1-Lipschitz in its argument; hence |diamWeight_d - diamWeight_d'| <= delta when
   the pseudometrics are delta-close, giving a delta-interleaving of the two VR
   filtrations directly from stability_two_sided.

3. **Boltzmann-weighted filtrations.** Replace diamWeight by a Boltzmann weight
   w_beta(sigma) = -beta^{-1} log Z(sigma); monotonicity follows from
   supermultiplicativity of Z under inclusion, so the entire sublevel calculus
   applies, and as beta -> infinity the Boltzmann filtration converges to the
   min-plus (tropical) diameter filtration.

4. **Functoriality as a persistence module.** sublevel_mono already supplies the
   morphisms; recording that subset-inclusions form a thin category makes the
   filtration a genuine (R, <=)-indexed diagram, one definitional step from a
   persistence module after post-composing with a homology functor.

5. **Sharper nerve lemmas.** Beyond the combinatorial sandwich, formalize the
   Cech(e) subset VR(2e) interleaving as a quantitative bound on the bottleneck
   distance between the two persistence diagrams.
"""

algorithms = [
    {
        "name": "Diameter-Weight Birth-Time Computation for the Vietoris-Rips Filtration",
        "description": (
            "Computes diamWeight(sigma), the largest internal pairwise distance of a "
            "finite simplex sigma (floored at 0 for the empty face and singletons). By "
            "the verified theorem vr_mem_iff_diam_le, this single number is exactly the "
            "birth time of sigma: sigma enters the Vietoris-Rips filtration precisely at "
            "scale epsilon = diamWeight(sigma). The algorithm scans all ordered pairs of "
            "vertices, so it runs in O(k^2) distance evaluations for a face with k "
            "vertices. It is the metric primitive on which the entire sublevel filtration "
            "calculus is built."
        ),
        "pseudocode": (
            "function DIAM_WEIGHT(face):\n"
            "    best <- 0\n"
            "    for x in face:\n"
            "        for y in face:\n"
            "            d <- dist(x, y)\n"
            "            if d > best: best <- d\n"
            "    return best        # = birth time of `face` in VR filtration\n"
            "\n"
            "function IN_VR(face, eps):\n"
            "    return DIAM_WEIGHT(face) <= eps   # vr_mem_iff_diam_le"
        ),
        "code": (
            "from itertools import product\n"
            "from math import sqrt\n"
            "from typing import Sequence, Tuple\n\n"
            "Point = Tuple[float, ...]\n\n"
            "def euclidean(a: Point, b: Point) -> float:\n"
            "    return sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))\n\n"
            "def diam_weight(face: Sequence[Point]) -> float:\n"
            "    \"\"\"Birth time of `face`: max internal pairwise distance (0 if <2 pts).\"\"\"\n"
            "    best = 0.0\n"
            "    for x, y in product(face, repeat=2):\n"
            "        d = euclidean(x, y)\n"
            "        if d > best:\n"
            "            best = d\n"
            "    return best\n\n"
            "def in_vr(face: Sequence[Point], eps: float) -> bool:\n"
            "    \"\"\"VR membership; equivalent to diam_weight(face) <= eps.\"\"\"\n"
            "    return diam_weight(face) <= eps\n"
        ),
    },
    {
        "name": "Nerve-Interleaving Certificate Generator (Cech subset VR subset Cech)",
        "description": (
            "Given a simplex and a covering center, produces certificates for the verified "
            "sandwich Cech(eps) subset VR(2*eps) subset Cech(2*eps). The forward direction "
            "(cech_subset_vr) follows from the triangle inequality: if all vertices lie "
            "within eps of a common center c, then every pairwise distance is at most "
            "dist(x,c)+dist(c,y) <= 2*eps. The reverse direction (vr_subset_cech) uses any "
            "vertex of a nonempty VR face as a center. The constant 2 -- the interleaving "
            "slack -- enters at exactly one place, the triangle bound. Complexity O(k^2) for "
            "the pairwise check and O(k * grid^2) for the grid-based common-center search."
        ),
        "pseudocode": (
            "function CECH_VERTEX_CENTER(face, eps):       # reverse direction\n"
            "    for c in face:\n"
            "        if for all x in face: dist(x,c) <= eps: return c\n"
            "    return NONE\n"
            "\n"
            "function FORWARD_CERT(face, center, eps):     # Cech(eps) -> VR(2eps)\n"
            "    assert for all x in face: dist(x, center) <= eps\n"
            "    for x in face:\n"
            "        for y in face:\n"
            "            assert dist(x,y) <= dist(x,center) + dist(center,y) <= 2*eps\n"
            "    return 'face in VR(2*eps)'"
        ),
        "code": (
            "from math import sqrt\n"
            "from typing import Optional, Sequence, Tuple\n\n"
            "Point = Tuple[float, ...]\n\n"
            "def euclidean(a: Point, b: Point) -> float:\n"
            "    return sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))\n\n"
            "def cech_vertex_center(face: Sequence[Point], eps: float) -> Optional[Point]:\n"
            "    \"\"\"Reverse direction: a vertex covering the whole face within eps.\"\"\"\n"
            "    for c in face:\n"
            "        if all(euclidean(x, c) <= eps for x in face):\n"
            "            return c\n"
            "    return None\n\n"
            "def forward_certificate(face: Sequence[Point], center: Point,\n"
            "                        eps: float) -> bool:\n"
            "    \"\"\"Cech(eps) -> VR(2 eps): triangle inequality gives all pairs <= 2 eps.\"\"\"\n"
            "    if not all(euclidean(x, center) <= eps + 1e-12 for x in face):\n"
            "        return False\n"
            "    return all(euclidean(x, y) <= 2 * eps + 1e-12\n"
            "               for x in face for y in face)\n"
        ),
    },
    {
        "name": "Euler-Poincare Bridge via Fibrewise f-vector Aggregation",
        "description": (
            "Computes the Euler characteristic of a finite simplicial complex in two "
            "provably equal ways and checks the verified bridge eulerChar_eq_alt_fVector. "
            "Method 1 (eulerCharFin) sums (-1)^(dim) over all nonempty faces. Method 2 "
            "first builds the f-vector by bucketing faces according to their number of "
            "vertices, then takes the alternating sum. The proof of equality is a fibrewise "
            "regrouping by dimension, valid for ANY finite complex. Specialized to the full "
            "simplex on n vertices, whose f-vector is the binomial row C(n,k), both methods "
            "return 1 -- the combinatorial shadow of contractibility. Complexity linear in "
            "the number of faces."
        ),
        "pseudocode": (
            "function F_VECTOR(faces):\n"
            "    fv <- empty map\n"
            "    for f in faces if f nonempty:\n"
            "        fv[ |f| ] <- fv[ |f| ] + 1\n"
            "    return fv\n"
            "\n"
            "function EULER_CHAR_FIN(faces):\n"
            "    return sum over nonempty f of (-1)^(|f|-1)\n"
            "\n"
            "function EULER_FROM_FVECTOR(fv):\n"
            "    return sum over k of (-1)^(k-1) * fv[k]\n"
            "\n"
            "assert EULER_CHAR_FIN(faces) == EULER_FROM_FVECTOR(F_VECTOR(faces))"
        ),
        "code": (
            "from itertools import combinations\n"
            "from typing import Dict, List, Sequence, Tuple\n\n"
            "Face = Tuple[int, ...]\n\n"
            "def f_vector(faces: Sequence[Face]) -> Dict[int, int]:\n"
            "    fv: Dict[int, int] = {}\n"
            "    for f in faces:\n"
            "        if f:\n"
            "            fv[len(f)] = fv.get(len(f), 0) + 1\n"
            "    return fv\n\n"
            "def euler_char_fin(faces: Sequence[Face]) -> int:\n"
            "    return sum((-1) ** (len(f) - 1) for f in faces if f)\n\n"
            "def euler_from_fvector(fv: Dict[int, int]) -> int:\n"
            "    return sum((-1) ** (k - 1) * c for k, c in fv.items())\n\n"
            "def full_simplex_faces(n: int) -> List[Face]:\n"
            "    out: List[Face] = []\n"
            "    for k in range(1, n + 1):\n"
            "        out.extend(combinations(range(n), k))\n"
            "    return out\n"
        ),
    },
]

demos = [
    {
        "name": "Birth Times and the Vietoris-Rips / diamWeight Equivalence",
        "description": (
            "Demonstrates vr_mem_iff_diam_le on the four corners of a unit square: the "
            "face's diamWeight equals its diagonal sqrt(2) ~ 1.414, and VR membership flips "
            "from False to True exactly as epsilon crosses that value. Confirms that the "
            "geometric pairwise-distance test and the single diameter inequality agree at "
            "every scale."
        ),
        "code": (
            "from itertools import product\n"
            "from math import sqrt\n\n"
            "def euclidean(a, b):\n"
            "    return sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))\n\n"
            "def diam_weight(face):\n"
            "    return max((euclidean(x, y) for x, y in product(face, repeat=2)),\n"
            "               default=0.0)\n\n"
            "def in_vr(face, eps):\n"
            "    return all(euclidean(x, y) <= eps for x, y in product(face, repeat=2))\n\n"
            "square = [(0,0),(1,0),(0,1),(1,1)]\n"
            "d = diam_weight(square)\n"
            "print('diamWeight =', round(d, 4))\n"
            "for eps in (0.9, 1.0, 1.4, 1.5):\n"
            "    print(eps, in_vr(square, eps), d <= eps)\n"
        ),
    },
    {
        "name": "Stability: a Bounded Perturbation Interleaves the Filtration",
        "description": (
            "Illustrates stability_interleaving and stability_two_sided. Each point of a "
            "small triangle is nudged by at most delta in a different direction; the maximum "
            "change in any pairwise distance is recorded, and the diameter (birth time) of "
            "the full simplex is shown to move by no more than that bound -- the algebraic "
            "core of the Cohen-Steiner-Edelsbrunner-Harer stability theorem."
        ),
        "code": (
            "from itertools import combinations\n"
            "from math import sqrt\n\n"
            "def euclidean(a, b):\n"
            "    return sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))\n\n"
            "def diam(face):\n"
            "    return max((euclidean(x, y) for x in face for y in face), default=0.0)\n\n"
            "pts = [(0,0),(1,0.05),(0.5,0.9)]\n"
            "delta = 0.15\n"
            "offsets = [(delta,0),(-delta,delta),(0,-delta)]\n"
            "pert = [(x+ox, y+oy) for (x,y),(ox,oy) in zip(pts, offsets)]\n"
            "maxd = max(abs(euclidean(pts[i],pts[j]) - euclidean(pert[i],pert[j]))\n"
            "           for i,j in combinations(range(3),2))\n"
            "print('max pairwise distance change =', round(maxd,4))\n"
            "print('diam moves by <= that bound:',\n"
            "      abs(diam(pts) - diam(pert)) <= maxd + 1e-9)\n"
        ),
    },
    {
        "name": "Euler Characteristic of the Full Simplex Equals One",
        "description": (
            "Verifies euler_char_full_simplex: the alternating sum sum_{k=1}^{n} "
            "(-1)^(k-1) C(n,k) equals 1 for every n >= 1, the combinatorial shadow of the "
            "contractibility of a solid simplex. Also cross-checks the Euler-Poincare bridge "
            "by recomputing the same value as the alternating f-vector of the explicit "
            "complex of all nonempty faces."
        ),
        "code": (
            "from itertools import combinations\n"
            "from math import comb\n\n"
            "def euler_full(n):\n"
            "    return sum((-1)**(k-1) * comb(n, k) for k in range(1, n+1))\n\n"
            "for n in range(1, 9):\n"
            "    print('n =', n, '-> chi =', euler_full(n))\n\n"
            "# cross-check via explicit faces (Euler-Poincare bridge)\n"
            "n = 5\n"
            "faces = [c for k in range(1, n+1) for c in combinations(range(n), k)]\n"
            "chi = sum((-1)**(len(f)-1) for f in faces)\n"
            "print('explicit complex on', n, 'vertices: chi =', chi)\n"
        ),
    },
]

visualizations = [
    {
        "name": "The Boltzmann Bridge Triptych: Filtration, Nerve Sandwich, Euler Cancellation",
        "description": (
            "A three-panel matplotlib figure. Panel A draws the Vietoris-Rips complex of a "
            "point cloud at a chosen scale, with edges appearing exactly when their "
            "diamWeight crosses epsilon. Panel B shows the Nerve sandwich on an equilateral "
            "triangle: the VR(2 eps) edges together with the common Cech ball of radius "
            "2 eps that covers all three vertices. Panel C plots the signed binomial terms "
            "(-1)^(k-1) C(n,k) of the full simplex's f-vector as red/green bars that cancel "
            "to a total height of exactly 1, the Euler characteristic."
        ),
        "code": viz,
    },
]

interactive_demos = [
    {
        "title": "The Boltzmann Bridge — Interactive Persistence Explorer",
        "description": (
            "A live, draggable canvas widget. Place and move points, sweep the scale "
            "epsilon, and watch the Vietoris-Rips complex grow in real time -- edges and "
            "filled triangles are born exactly when their diamWeight crosses epsilon "
            "(vr_mem_iff_diam_le). Toggle the Cech epsilon-balls to see the covering model, "
            "and watch the live readout verify two theorems on every frame: the "
            "Euler-Poincare bridge (Euler characteristic equals the alternating f-vector "
            "f0 - f1 + f2) and the Nerve sandwich (every nonempty VR(eps) face is a "
            "Cech(eps) face, with the forward Cech(eps) subset VR(2eps) inclusion guaranteed "
            "by the triangle inequality). A 'Ring' preset shows a 1-cycle whose Euler "
            "characteristic drops to 0."
        ),
        "html": html,
    },
]

package = {
    "title": "The Boltzmann Bridge: A Verified Filtration Calculus for Persistent Topology",
    "domain": "Applications",
    "description": (
        "A fully formalized calculus of one-parameter filtrations of abstract simplicial "
        "complexes for persistent homology: from a single monotone-weight primitive it "
        "derives the Vietoris-Rips filtration, its stability under perturbation, the "
        "combinatorial Nerve interleaving Cech(e) subset VR(2e) subset Cech(2e), and the "
        "Euler-Poincare / f-vector bridge."
    ),
    "authors": ["Aristotle (Harmonic)"],
    "date": "2026-06-13",
    "key_results": [
        "Vietoris-Rips membership equals the diameter-weight sublevel condition: sigma in VR(eps) iff diamWeight(sigma) <= eps (vr_mem_iff_diam_le).",
        "Any monotone weight yields a nested family of genuine simplicial complexes (sublevelComplex, sublevel_mono).",
        "Stability/interleaving: uniformly delta-close weights give delta-interleaved sublevel families, and interleavings compose additively (stability_interleaving, stability_compose, stability_two_sided).",
        "Combinatorial Nerve interleaving Cech(e) subset VR(2e) subset Cech(2e), with the constant 2 forced solely by the triangle inequality (nerve_interleaving).",
        "Euler-Poincare bridge: the Euler characteristic equals the alternating f-vector for any finite complex, and equals 1 for the full simplex (eulerChar_eq_alt_fVector, euler_char_full_simplex).",
    ],
    "keywords": [
        "persistent homology", "topological data analysis", "Vietoris-Rips complex",
        "Cech complex", "Nerve lemma", "filtration", "interleaving distance",
        "stability theorem", "Euler characteristic", "f-vector", "simplicial complex",
        "formal verification",
    ],
    "article": "ARTICLE.md",
    "research_paper": "RESEARCH_PAPER.md",
    "demo": "demo.py",
    "demos": demos,
    "algorithms": algorithms,
    "visualizations": visualizations,
    "interactive_demos": interactive_demos,
    "lean_proofs": lean_proofs,
    "future_directions": future_directions,
    "modules": {"demo": demo},
    "lean_files": [
        "Catalog/Applications/BoltzmannBridge/HigherPersistence.lean",
        "Catalog/Applications/BoltzmannBridge/PersistenceStability.lean",
    ],
}

(base / "PACKAGE.json").write_text(json.dumps(package, indent=2, ensure_ascii=False))
print("wrote PACKAGE.json", (base / "PACKAGE.json").stat().st_size, "bytes")


"""
The Boltzmann Bridge — Numerical Demonstrations
================================================

Self-contained numerical illustrations of the verified results in the
Boltzmann Bridge filtration calculus for persistent topology. Every function
is inlined and depends only on the Python standard library.

Results demonstrated
---------------------
1. diamWeight / VR membership          (vr_mem_iff_diam_le)
2. Sublevel filtration is nested       (sublevel_mono, vr_mono)
3. Stability / interleaving            (stability_interleaving, two_sided)
4. Nerve interleaving sandwich         (cech_subset_vr, vr_subset_cech)
5. Euler characteristic of full simplex(euler_char_full_simplex = 1)
6. Euler-Poincare / f-vector bridge    (eulerChar_eq_alt_fVector)

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations, product
from math import comb, sqrt
from typing import Dict, List, Sequence, Tuple

Point = Tuple[float, ...]


# ---------------------------------------------------------------------------
# Metric helpers
# ---------------------------------------------------------------------------
def euclidean(a: Point, b: Point) -> float:
    """Euclidean distance between two points of equal dimension."""
    return sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))


# ---------------------------------------------------------------------------
# 1. Diameter weight and Vietoris-Rips membership  (vr_mem_iff_diam_le)
# ---------------------------------------------------------------------------
def diam_weight(face: Sequence[Point]) -> float:
    """Largest internal pairwise distance of a face (0 for empty/singleton).

    This is `diamWeight`; by `vr_mem_iff_diam_le` it is the birth time of the
    simplex in the Vietoris-Rips filtration.
    """
    best = 0.0
    for x, y in product(face, repeat=2):
        d = euclidean(x, y)
        if d > best:
            best = d
    return best


def in_vr(face: Sequence[Point], eps: float) -> bool:
    """Vietoris-Rips membership: every pairwise distance <= eps."""
    return all(euclidean(x, y) <= eps for x, y in product(face, repeat=2))


def demo_vr_birth() -> None:
    print("=" * 70)
    print("1. diamWeight as birth time  (vr_mem_iff_diam_le)")
    print("=" * 70)
    square = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)]
    d = diam_weight(square)
    print(f"  unit square face, diamWeight = {d:.4f}  (= sqrt(2) diagonal)")
    for eps in (0.9, 1.0, 1.4, 1.5):
        lhs = in_vr(square, eps)
        rhs = d <= eps
        flag = "OK" if lhs == rhs else "MISMATCH"
        print(f"    eps={eps:<4}  in_VR={lhs!s:<5}  diam<=eps={rhs!s:<5}  [{flag}]")
    print()


# ---------------------------------------------------------------------------
# 2. Nestedness of the filtration  (sublevel_mono / vr_mono)
# ---------------------------------------------------------------------------
def vr_complex(points: List[Point], eps: float, max_dim: int = 3) -> List[Tuple[int, ...]]:
    """All VR faces (as index tuples) up to dimension max_dim at scale eps."""
    faces: List[Tuple[int, ...]] = []
    n = len(points)
    for k in range(1, max_dim + 2):
        for combo in combinations(range(n), k):
            if in_vr([points[i] for i in combo], eps):
                faces.append(combo)
    return faces


def demo_nesting() -> None:
    print("=" * 70)
    print("2. Filtration is nested in the scale  (vr_mono / sublevel_mono)")
    print("=" * 70)
    pts = [(0.0, 0.0), (1.0, 0.0), (2.0, 0.0), (1.0, 1.0)]
    scales = [0.5, 1.0, 1.5, 2.5]
    prev: set = set()
    for eps in scales:
        cur = set(vr_complex(pts, eps))
        nested = prev <= cur
        print(f"  eps={eps:<4} #faces={len(cur):<3} previous subset of current? {nested}")
        prev = cur
    print()


# ---------------------------------------------------------------------------
# 3. Stability / interleaving  (stability_interleaving, two_sided)
# ---------------------------------------------------------------------------
def demo_stability(delta: float = 0.15) -> None:
    print("=" * 70)
    print("3. Stability: a delta perturbation interleaves the filtration")
    print("=" * 70)
    pts = [(0.0, 0.0), (1.0, 0.05), (0.5, 0.9)]
    # perturbed copy: nudge each point by at most delta, in different directions
    offsets = [(delta, 0.0), (-delta, delta), (0.0, -delta)]
    pert = [(x + ox, y + oy) for (x, y), (ox, oy) in zip(pts, offsets)]
    # max change in any pairwise distance (theory guarantees <= 2*delta here)
    max_diff = 0.0
    for i, j in combinations(range(len(pts)), 2):
        d0 = euclidean(pts[i], pts[j])
        d1 = euclidean(pert[i], pert[j])
        max_diff = max(max_diff, abs(d0 - d1))
    print(f"  per-point shift <= {delta}, max change of pairwise distance = {max_diff:.4f}")
    # Verify diam' <= diam + max_diff on the full simplex (interleaving bound)
    full = list(range(len(pts)))
    t = diam_weight([pts[i] for i in full])
    t_pert = diam_weight([pert[i] for i in full])
    interleaved = t_pert <= t + max_diff + 1e-9
    print(f"  diam(original)={t:.4f}, diam(perturbed)={t_pert:.4f}")
    print(f"  interleaving  diam' <= diam + delta_observed : {interleaved}")
    print()


# ---------------------------------------------------------------------------
# 4. Nerve interleaving  (cech_subset_vr, vr_subset_cech)
# ---------------------------------------------------------------------------
def in_cech_vertex_centered(face: Sequence[Point], eps: float) -> bool:
    """Reverse-direction Cech test: some VERTEX covers the face within eps.

    By vr_subset_cech, any nonempty VR(eps) face passes this test.
    """
    for center in face:
        if all(euclidean(x, center) <= eps for x in face):
            return True
    return False


def in_cech(face: Sequence[Point], eps: float, grid: int = 25) -> bool:
    """Cech membership approximated by a grid search for a common center."""
    if not face:
        return True
    xs = [p[0] for p in face]
    ys = [p[1] for p in face]
    lo_x, hi_x = min(xs) - eps, max(xs) + eps
    lo_y, hi_y = min(ys) - eps, max(ys) + eps
    for i in range(grid + 1):
        for j in range(grid + 1):
            cx = lo_x + (hi_x - lo_x) * i / grid
            cy = lo_y + (hi_y - lo_y) * j / grid
            if all(euclidean(p, (cx, cy)) <= eps for p in face):
                return True
    return False


def demo_nerve() -> None:
    print("=" * 70)
    print("4. Nerve interleaving:  Cech(e) subset VR(2e) subset Cech(2e)")
    print("=" * 70)
    # equilateral triangle, side 1: a classic Cech vs VR discrepancy
    face = [(0.0, 0.0), (1.0, 0.0), (0.5, sqrt(3) / 2)]
    eps = 0.55
    cech_e = in_cech(face, eps)
    vr_2e = in_vr(face, 2 * eps)
    cech_2e = in_cech(face, 2 * eps)
    print(f"  equilateral triangle (side 1), eps={eps}")
    print(f"    in Cech(eps)   = {cech_e}")
    print(f"    in VR(2 eps)   = {vr_2e}   (forward inclusion: Cech(e) -> VR(2e))")
    print(f"    in Cech(2 eps) = {cech_2e} (reverse inclusion holds at 2e)")
    # forward inclusion certificate must hold:
    print(f"    Cech(e) => VR(2e) holds: {(not cech_e) or vr_2e}")
    # reverse via vertex center
    print(f"    VR(eps) => Cech(eps) (vertex-centered): "
          f"{(not in_vr(face, eps)) or in_cech_vertex_centered(face, eps)}")
    print()


# ---------------------------------------------------------------------------
# 5. Euler characteristic of the full simplex  (= 1)
# ---------------------------------------------------------------------------
def euler_char_full_simplex(n: int) -> int:
    """sum_{k=1}^{n} (-1)^(k-1) C(n,k);  proved equal to 1 for n >= 1."""
    return sum((-1) ** (k - 1) * comb(n, k) for k in range(1, n + 1))


def demo_euler_full() -> None:
    print("=" * 70)
    print("5. Euler characteristic of the full simplex equals 1")
    print("=" * 70)
    for n in range(1, 9):
        chi = euler_char_full_simplex(n)
        print(f"  n={n}: sum (-1)^(k-1) C({n},k) = {chi}  "
              f"{'OK' if chi == 1 else 'FAIL'}")
    print()


# ---------------------------------------------------------------------------
# 6. Euler-Poincare / f-vector bridge  (eulerChar_eq_alt_fVector)
# ---------------------------------------------------------------------------
def f_vector(faces: Sequence[Tuple[int, ...]]) -> Dict[int, int]:
    """Count faces by number of vertices: f_vector[k] = #faces with k vertices."""
    fv: Dict[int, int] = {}
    for face in faces:
        if face:  # ignore empty face
            fv[len(face)] = fv.get(len(face), 0) + 1
    return fv


def euler_char_fin(faces: Sequence[Tuple[int, ...]]) -> int:
    """eulerCharFin: signed count over nonempty faces, sign (-1)^(card-1)."""
    return sum((-1) ** (len(face) - 1) for face in faces if face)


def euler_char_from_fvector(fv: Dict[int, int]) -> int:
    """Alternating sum of the f-vector: sum_k (-1)^(k-1) f_vector[k]."""
    return sum((-1) ** (k - 1) * count for k, count in fv.items())


def full_simplex_faces(n: int) -> List[Tuple[int, ...]]:
    """All nonempty subsets of {0,...,n-1} as the full simplex on n vertices."""
    faces: List[Tuple[int, ...]] = []
    for k in range(1, n + 1):
        faces.extend(combinations(range(n), k))
    return faces


def demo_euler_bridge() -> None:
    print("=" * 70)
    print("6. Euler-Poincare bridge: eulerCharFin = alternating f-vector")
    print("=" * 70)
    # (a) full simplex on 4 vertices
    faces = full_simplex_faces(4)
    fv = f_vector(faces)
    lhs = euler_char_fin(faces)
    rhs = euler_char_from_fvector(fv)
    print(f"  Full simplex on 4 vertices:")
    print(f"    f-vector (by #vertices)        = {dict(sorted(fv.items()))}")
    print(f"    eulerCharFin (signed faces)    = {lhs}")
    print(f"    alternating sum of f-vector    = {rhs}")
    print(f"    bridge holds: {lhs == rhs}; value = {lhs} (= 1 for full simplex)")
    # (b) a hollow triangle (boundary only) -- chi = 0 (a loop)
    hollow = [(0,), (1,), (2,), (0, 1), (1, 2), (0, 2)]
    fv2 = f_vector(hollow)
    print(f"  Hollow triangle (a 1-cycle):")
    print(f"    f-vector = {dict(sorted(fv2.items()))}, "
          f"eulerCharFin = {euler_char_fin(hollow)} "
          f"(= V - E = 3 - 3 = 0)")
    print(f"    bridge holds: "
          f"{euler_char_fin(hollow) == euler_char_from_fvector(fv2)}")
    print()


# ---------------------------------------------------------------------------
if __name__ == "__main__":
    print("\nTHE BOLTZMANN BRIDGE -- numerical demonstrations\n")
    demo_vr_birth()
    demo_nesting()
    demo_stability()
    demo_nerve()
    demo_euler_full()
    demo_euler_bridge()
    print("All demonstrations completed.")


"""
The Boltzmann Bridge — Visualizations
=====================================

Standalone matplotlib script producing three figures:

  (A) The Vietoris-Rips filtration of a point cloud at growing scales, with the
      birth time (diamWeight) of edges shown as they appear.
  (B) The Nerve interleaving sandwich Cech(e) subset VR(2e) subset Cech(2e) on
      an equilateral triangle, drawing the covering balls.
  (C) The Euler characteristic of the full simplex pinned at 1 across n, next to
      the alternating binomial bars that cancel to 1.

Run:  python visualize.py   ->   writes boltzmann_bridge.png
"""

from __future__ import annotations

from itertools import combinations
from math import comb, sqrt
from typing import List, Tuple

import matplotlib.pyplot as plt
from matplotlib.patches import Circle

Point = Tuple[float, float]


def dist(a: Point, b: Point) -> float:
    return sqrt((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2)


def diam(face: List[Point]) -> float:
    return max((dist(x, y) for x in face for y in face), default=0.0)


def make_figure() -> None:
    fig = plt.figure(figsize=(15, 5))

    # ---- (A) VR filtration at growing scales -----------------------------
    pts: List[Point] = [(0, 0), (1, 0.1), (1.8, 0.9), (0.9, 1.6), (-0.1, 0.9)]
    axA = fig.add_subplot(1, 3, 1)
    eps = 1.1
    for i, j in combinations(range(len(pts)), 2):
        if dist(pts[i], pts[j]) <= eps:
            axA.plot([pts[i][0], pts[j][0]], [pts[i][1], pts[j][1]],
                     color="#3b6fb5", lw=2, alpha=0.7)
    xs, ys = zip(*pts)
    axA.scatter(xs, ys, s=80, color="#d1495b", zorder=3)
    axA.set_title(f"Vietoris-Rips complex at scale eps={eps}\n(edge born when diamWeight <= eps)")
    axA.set_aspect("equal")
    axA.grid(alpha=0.3)

    # ---- (B) Nerve sandwich ---------------------------------------------
    axB = fig.add_subplot(1, 3, 2)
    tri: List[Point] = [(0, 0), (1, 0), (0.5, sqrt(3) / 2)]
    e = 0.55
    # VR(2e) edges
    for i, j in combinations(range(3), 2):
        axB.plot([tri[i][0], tri[j][0]], [tri[i][1], tri[j][1]],
                 color="#3b6fb5", lw=2)
    # common ball at radius 2e (circumcenter)
    cx, cy = 0.5, sqrt(3) / 6
    axB.add_patch(Circle((cx, cy), 2 * e, fill=True, alpha=0.12,
                         color="#2a9d8f", label="Cech ball radius 2e"))
    axB.add_patch(Circle((cx, cy), 2 * e, fill=False, color="#2a9d8f", lw=1.5))
    xs, ys = zip(*tri)
    axB.scatter(xs, ys, s=90, color="#d1495b", zorder=3)
    axB.set_title("Nerve sandwich:\nCech(e) subset VR(2e) subset Cech(2e)")
    axB.set_aspect("equal")
    axB.grid(alpha=0.3)
    axB.legend(loc="upper right", fontsize=8)

    # ---- (C) Euler characteristic = 1 -----------------------------------
    axC = fig.add_subplot(1, 3, 3)
    n = 6
    ks = list(range(1, n + 1))
    terms = [(-1) ** (k - 1) * comb(n, k) for k in ks]
    colors = ["#2a9d8f" if t > 0 else "#d1495b" for t in terms]
    axC.bar(ks, terms, color=colors, alpha=0.8)
    chi = sum(terms)
    axC.axhline(0, color="black", lw=0.8)
    axC.set_title(f"Alternating f-vector of full simplex (n={n})\n"
                  f"sum = {chi}  (Euler characteristic = 1)")
    axC.set_xlabel("k (number of vertices)")
    axC.set_ylabel("(-1)^(k-1) C(n,k)")
    axC.grid(alpha=0.3, axis="y")

    fig.tight_layout()
    fig.savefig("boltzmann_bridge.png", dpi=130)
    print("Wrote boltzmann_bridge.png")


if __name__ == "__main__":
    make_figure()
