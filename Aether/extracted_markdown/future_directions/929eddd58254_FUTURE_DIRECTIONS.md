# Future Directions — Impossible Geometries in the Tropical World

## Synthesis

The cycle "Impossible Geometries: Where Parallel Lines Converge AND Diverge"
formalized one-dimensional **tropical lines** `tropLine a b x = min (a + x) b`
(the min-plus evaluation of the degree-one tropical polynomial `(a ⊙ x) ⊕ b`)
and proved the paradox at the heart of the concept: two *distinct parallel*
tropical lines agree on an entire closed ray — they share infinitely many points
("converge") — while still being different functions ("diverge"). In Euclidean
geometry distinct lines meet in at most one point and parallel distinct lines
never meet; tropical geometry shatters both halves of this dichotomy
simultaneously.

The technical engine is a *local-to-global* (sheaf-flavoured) structure theorem:
the locus where any two tropical lines agree is always **convex**. We obtained it
by reducing the global statement to a single stalk-level invariant — the
*monotonicity of the difference* of two tropical lines (`tropDiff_antitone`) —
and then observing that a monotone function has a convex zero-set. This "reduce
the global gluing to a derivative-level inequality" pattern is exactly the
local-to-global methodology this engine targets, and it generalizes well.

## Results Summary (`Catalog/Tropical/ImpossibleGeometry.lean`, 0 sorries)

- `tropLine_of_le_corner` / `tropLine_of_corner_le` — piecewise description of a
  tropical line about its corner `x = b - a`.
- `tropLine_monotone` — tropical lines are nondecreasing.
- `parallel_converge` — parallel lines (`a` shared) coincide on the ray `x ≤ b₁ - a`.
- `parallel_diverge` — distinct parallel lines (`b₁ < b₂`) genuinely differ.
- `agreement_eq_ray` — the agreement locus of distinct parallel lines is *exactly*
  the closed ray `Set.Iic (b₁ - a)`.
- `tropDiff_antitone` — stalk-level glue: the difference of two tropical lines is
  monotone once the corners are ordered.
- `agreement_convex` — local-to-global theorem: any two tropical lines agree on a
  convex set.

## Bold, Falsifiable Directions

### 1. Tropical curves in the plane and the "stable intersection" sheaf
Lift the story from graphs of functions to genuine tropical plane curves
`V(min(a + x, b + y, c))` (tripods). Conjecture: two distinct tropical lines in
ℝ² intersect either in exactly one point or in a single common ray, and never in
two isolated points. **The key insight is** that the planar agreement/intersection
locus is the zero-set of a *concave piecewise-linear* function, so it inherits the
same convexity that drove `agreement_convex`. *Why now?* We already have the
1-D convexity machinery and the corner calculus; the planar case is the minimal
honest step toward tropical Bézout, and it is directly falsifiable by exhibiting
two lines meeting in two isolated points (we predict this is impossible).

### 2. Cohomological obstruction to global linearization
Define a presheaf assigning to each interval `I ⊆ ℝ` the set of affine functions
agreeing with a fixed tropical polynomial `p` on `I`. Conjecture: `p` is globally
affine iff this presheaf has a global section, and the *number of corners of `p`*
equals the rank of the first Čech obstruction of the cover by maximal linear
intervals. **The key insight is** that each corner is precisely a failure to glue
two local affine sections, so corners are literally 1-cocycles. *Why now?* The
piecewise lemmas (`tropLine_of_le_corner` / `tropLine_of_corner_le`) already
isolate the linear pieces; turning "corner count" into "obstruction rank" makes
the sheaf-theoretic framing of this engine concrete and computable.

### 3. Convexity of the agreement locus for arbitrary tropical polynomials
Generalize `agreement_convex` from lines (one corner) to tropical polynomials of
arbitrary degree (many corners). Conjecture: for two tropical polynomials the
agreement locus need NOT be convex, but it is always a *finite union of at most
`d₁ + d₂` intervals*, where `dᵢ` are the degrees. **The key insight is** that the
difference of two tropical polynomials is piecewise linear with at most
`d₁ + d₂` slope changes, so its zero-set has at most that many components. *Why
now?* This is the exact boundary where the clean line theorem fails; pinning the
component count quantifies *how badly* local-to-global gluing degrades with degree
— a falsifiable, testable refinement.

### 4. A metric/ultrametric "parallel postulate" dictionary
Quantify the convergence rate: for parallel lines define `gap(x) = |tropLine a b₁ x
− tropLine a b₂ x|` and conjecture `gap` is monotone nondecreasing with supremum
`|b₁ − b₂|`, reached for all `x ≥ b₂ − a`. **The key insight is** that the tropical
"angle" between parallel lines is concentrated entirely past the later corner — a
sharp contrast with Euclidean parallels whose gap is constant and with hyperbolic
ones whose gap grows without bound. *Why now?* `tropDiff_antitone` already gives
the monotonicity backbone; computing the exact supremum turns the qualitative
"diverge" into a quantitative invariant comparable across Euclidean / hyperbolic /
elliptic / tropical geometries.

### 5. Bridge to min-plus matrix algebra (catalog cross-domain link)
The catalog file `Catalog/Tropical/MinPlusAlgebra.lean` develops min-plus matrix
products and their 1-Lipschitz behaviour. Conjecture: the corner locus of the
tropical line `x ↦ min_k (A i k + x)` (a row of a min-plus matrix–vector product)
is governed by the same convexity, and the `inf_sub_inf_le_sup` bound there is the
matrix-level shadow of `tropDiff_antitone`. **The key insight is** that both
results say "min of affine functions has controlled increments"; unifying them
exhibits the tropical line theorems as the rank-one stalk of the matrix theory.
*Why now?* Both files already live in the same namespace and use min-plus over ℝ,
so the bridge lemma is low-friction and would connect tropical *geometry* to the
existing tropical *cryptography/algebra* catalog domain.
