# Future Directions: Tropical Compactification of Moduli Spaces

The file `Catalog/Tropical/TropicalModuliCompactification.lean` formalizes the
combinatorial core of the tropical moduli space of genus-0 curves
`M_{0,n}^trop`, realized as the space of phylogenetic trees and, equivalently,
the tropical Grassmannian `Gr(2,n)`. We proved that ultrametrics (the
equidistant / rooted locus) are isosceles, are genuine metrics, and satisfy the
four-point / tropical Plücker condition (`ultrametric_four_point` and its
"attained-twice" strengthening), together with max-plus homogeneity
(`tropical_homogeneity`) that gives the moduli object its fan/cone structure.

These results connect to existing catalog material: the min-plus monotonicity of
`Catalog/Tropical/TropicalFormula.lean` (`TropFormula`) is the order-theoretic
companion of `tropical_homogeneity`, and the Plücker-style certificates in
`Catalog/Bridges/TropicalProofCertificates` and `AlgebraTropicalGeometry` are
candidate consumers of the four-point relation proved here. Below are concrete,
falsifiable next steps.

## Direction 1 — A full Buneman recovery theorem (metric ⇒ tree)

Conjecture: a symmetric nonnegative `d : ι → ι → ℝ` on a finite type satisfies
the four-point condition `ultrametric_four_point_attained_twice` for *every*
quadruple **if and only if** there is a weighted tree (a finite graph metric)
realizing `d` exactly. The forward direction generalizes our `ultrametric_*`
lemmas from the equidistant locus to all tree metrics; the converse is the
constructive heart of `M_{0,n}^trop`.

The key insight is that the four-point condition is not merely *necessary* for an
ultrametric — it is the exact tropical Plücker locus, so the "attained-twice"
disjunction we proved is precisely the gluing data of the Buneman split system,
and a tree can be reconstructed split-by-split from the equality cases.

Why now? We have already isolated the attained-twice relation as a clean,
machine-checked disjunction; the remaining work is a finite induction on the
number of leaves, which is exactly the regime where Lean's `Finset` and
`grind`-style case analysis are now strong enough to discharge the splits.

## Direction 2 — The tropical Grassmannian `Gr(2,n)` as a balanced fan

Conjecture: the set of `d` satisfying `ultrametric_four_point` is closed under
the max-plus cone operations (tropical scaling by nonnegative `c` and tropical
addition), i.e. it is a *tropical (max-plus) submodule*, and modulo the lineality
space of "tree-additive" functions it is a balanced polyhedral fan of pure
dimension `n - 3`.

The key insight is that `tropical_homogeneity` already certifies closure under
scaling, so the only missing ingredient is closure under coordinatewise `max`,
which reduces to a *single* three-term inequality between quartet sums — the same
shape of statement `grind +splitIndPred` dispatched for the four-point lemma.

Why now? The dimension `n-3` is the classical statement of Speyer–Sturmfels;
having the defining inequalities as Lean lemmas means the fan structure can be
assembled from them mechanically rather than re-derived from scratch.

## Direction 3 — Strong-triangle stability under tropical limits

Conjecture: if `d_k` is a sequence of ultrametrics converging pointwise to `d`,
then `d` is again an ultrametric; consequently the ultrametric locus is *closed*
inside the space of all symmetric nonnegative functions, giving the
compactification a genuine closed-boundary structure.

The key insight is that each defining inequality (`symm`, `nonneg`, `strong`) is
a closed condition (a non-strict inequality), and pointwise limits preserve
non-strict inequalities — so closedness is a finite conjunction of limit-stable
facts rather than a delicate analytic argument.

Why now? Mathlib's order-limit API (`le_of_tendsto`, `isClosed_le`) is mature,
and our `IsUltrametric` structure is phrased entirely with `≤` and `max`, which
are continuous — the proof is essentially a transport of our existing fields
through `Filter.Tendsto`.

## Direction 4 — Quantitative isosceles defect and almost-ultrametrics

Conjecture: define the *isosceles defect* `δ(x,y,z)` as the gap between the two
largest of `d x y, d y z, d x z`. Then `d` is within additive `ε` of an
ultrametric (in the sup norm) **iff** `δ ≤ Cε` uniformly, with an explicit
universal constant `C` independent of the number of points.

The key insight is that our exact lemma `ultrametric_two_largest_equal` is the
`ε = 0` boundary case; perturbing the strong triangle inequality by `ε` turns the
squeeze argument into a two-sided estimate, so the qualitative equality becomes a
quantitative Lipschitz bound on the defect.

Why now? Robustness/`ε`-stability statements are exactly where the catalog's
tropical robustness files (e.g. `Tropical_Certified_Robustness_for_Multi_Class_ReLU_Networks`)
already invest effort; a clean defect bound would bridge the pure-moduli side
with those quantitative applications.

## Direction 5 — Cross-domain bridge: ultrametrics ⇒ p-adic and hierarchical clustering certificates

Conjecture: every ultrametric on a finite set arises (up to monotone
reparametrization) from a hierarchical clustering / single-linkage dendrogram,
and conversely; formalize the bijection and use it to give the
`PAdicTropical`-style valuations of the catalog a verified ultrametric semantics.

The key insight is that `ultrametric_isosceles` is the dendrogram merge rule in
disguise — the two larger distances coinciding is exactly the statement that two
points enter the same cluster at the same height — so the clustering tree is a
*canonical* witness for the four-point data we proved.

Why now? The catalog already contains `PAdicTropical` and tropical clustering-
adjacent material; with the four-point and isosceles lemmas in hand, the
dendrogram bijection becomes a finite recursion whose invariant is precisely
`ultrametric_two_largest_equal`, ready for `grind`-assisted induction.
