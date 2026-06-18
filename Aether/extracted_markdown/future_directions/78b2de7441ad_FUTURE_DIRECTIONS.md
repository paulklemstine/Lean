# FUTURE_DIRECTIONS — Biological Topology: Protein Folding as Persistent-Homology Optimization

This cycle established the *combinatorial / analytic* layer of the
"folding-as-topological-optimization" program in
`Geometry/ProteinFoldingBarcode.lean`. A persistence **barcode** is a finite
list of birth/death intervals `(bᵢ, dᵢ)`, and the central functional is **total
persistence** `T(B) = ∑ᵢ (dᵢ - bᵢ)`. We proved that `T` behaves like a genuine
physical energy: it is **extensive** (`totalPersistence_append`), **bounded
below by a ground state** of value `0` attained *exactly* by featureless
barcodes (`totalPersistence_nonneg`, `totalPersistence_eq_zero_iff`),
**homogeneous of degree one** under rescaling (`totalPersistence_scale`), and
**L¹-stable** under matched coordinate noise (`totalPersistence_stability`).
Existence of a global minimizer over a finite conformation space is immediate
(`nativeFold_exists`), giving the well-posedness half of Levinthal's paradox,
while `nativeFold_not_unique` refutes naive uniqueness with an explicit pair of
distinct minimizing configurations carrying distinct barcodes of equal energy.
The new strict variational law `totalPersistence_strictMono_cons` shows that
lengthening a single feature strictly raises the energy, and
`totalPersistence_neg_of_invalid` pins validity as necessary for nonnegativity.

The work decouples into two independent layers: (1) the barcode functional
itself (everything proved here, no homology required), and (2) the geometric
constructor turning a point cloud into a barcode (Vietoris–Rips / minimum
spanning tree), deliberately deferred. The directions below attack layer (2) and
sharpen layer (1), reusing the proved energy calculus as a black box.

## Direction 1: Degree-0 total persistence equals minimum-spanning-tree weight

**Conjecture.** For a finite metric space `d : Fin n → Fin n → ℝ`, define a
constructor `H0Barcode d` from the filtration of connected components (the bars
born at `0` and dying at successive merge heights, excluding the single infinite
bar). Then `totalPersistence (H0Barcode d) = mstWeight d`, the total edge weight
of a minimum spanning tree of the complete distance graph.

**The key insight is** that 0-dimensional persistence is not abstract homology at
all — it is exactly greedy single-linkage clustering whose merge heights are the
MST edge weights, so the topological energy collapses to a classical
combinatorial optimum reachable by Mathlib's order/graph theory.

**Test (falsifiable).** Prove the identity for `n ≤ 4` by explicit enumeration
first; mismatch there immediately falsifies the filtration convention. Then
prove the general statement by induction following Kruskal's algorithm.

**Why now?** This cycle proved the entire barcode-side calculus (additivity,
nonnegativity, ground-state characterization); the only missing piece is the
*constructor* `H0Barcode`, so the hard analytic lemmas are already done. If true,
degree-0 folding energy becomes computable and minimizable in polynomial time —
the first provably tractable instance of the folding energy.

## Direction 2: Strict monotonicity under the bar-wise partial order

**Conjecture.** Generalize `totalPersistence_strictMono_cons` from one bar to the
whole barcode: if `B'` dominates `B` bar-by-bar (`bᵢ' = bᵢ`, `dᵢ ≤ dᵢ'`) with at
least one strict inequality, then `totalPersistence B < totalPersistence B'`.
State it as `totalPersistence_lt_of_le_of_exists_lt`.

**The key insight is** that `totalPersistence_eq_zero_iff` already isolates the
minimum at the boundary; promoting this to global strict monotonicity converts
"the fold minimizes persistence" from a non-strict into a strict variational
principle — exactly the ingredient a symmetry-quotiented uniqueness theorem needs.

**Test (falsifiable).** Derive it from `totalPersistence_append` plus a single
strict summand. A flat direction (energy constant under a genuine extension)
would falsify it and expose degenerate directions sharpening
`nativeFold_not_unique`.

**Why now?** Additivity and nonnegativity, both proved this cycle, are precisely
the lemmas a strict-monotonicity argument decomposes into, and the single-bar
case `totalPersistence_strictMono_cons` is already in hand as the base step.

## Direction 3: Bottleneck vs. L¹ stability — which metric controls robustness?

**Conjecture.** The L¹ stability constant of `totalPersistence_stability` is *not*
improvable to the bottleneck (L∞) metric: there is a family `B_n, B'_n` with
`bottleneck B_n B'_n → 0` yet `|T(B_n) - T(B'_n)| ≥ c` for a fixed `c > 0`
(indeed growing with the number of bars).

**The key insight is** that the classical Cohen-Steiner–Edelsbrunner theorem
controls *bottleneck* distance whereas total persistence is an *L¹* quantity;
this cycle's matched-perturbation bound is L¹-tight, so the two notions must
diverge, and the size of the divergence says which experimental errors actually
threaten a fold prediction.

**Test (falsifiable).** Construct `B_n` with `n` bars each perturbed by `1/n` and
prove the two limits; if instead `|T(B_n) - T(B'_n)| → 0`, total persistence
inherits bottleneck stability and the conjecture is false (a *better* outcome
for the energy).

**Why now?** We have an exact L¹ bound to compare against, and the counterexample
is a finite-list construction in the same idiom as `nativeFold_not_unique`.

## Direction 4: Weighted / p-total persistence and a Hölder stability hierarchy

**Conjecture.** For `p ≥ 1` define `T_p(B) = (∑ᵢ (dᵢ - bᵢ)^p)^{1/p}`. Then `T_p`
is monotone decreasing in `p`, satisfies `T_p ≤ T_1`, and admits an L^p matched
stability bound generalizing `totalPersistence_stability` (the `p = 1` case),
with `p → ∞` limit the single longest bar.

**The key insight is** that the proof of `totalPersistence_stability` used only a
bar-by-bar triangle inequality; replacing it with Minkowski's inequality should
lift the whole argument to every `p`, yielding a one-parameter family of folding
energies interpolating between "all features matter" (`p=1`) and "only the
deepest feature matters" (`p=∞`) — matching the intuition that one
hydrophobic-core loop dominates the fold.

**Test (falsifiable).** Prove `T_p` monotonicity via Mathlib power-mean
inequalities, then port the stability induction using `abs_rpow` and Minkowski.
The `p` at which convexity fails (if any) bounds the usable range and falsifies
the uniform claim.

**Why now?** The `p = 1` theorems are complete and modular, so the generalization
is a controlled stress test of exactly which steps are `p`-specific.

## Direction 5: Symmetry-quotient uniqueness — recovering the conjecture's intent

**Conjecture.** Although `nativeFold_not_unique` refutes naive uniqueness, the
minimizer *is* unique modulo a symmetry group `G` acting on configurations: with
`bar (g • x) = bar x`, one has
`∀ x y, IsMin x → IsMin y → bar x = bar y → ∃ g, y = g • x`.

**The key insight is** that this cycle separated "minimal energy" (canonical)
from "minimizing configuration" (non-canonical); the right invariant lives on the
quotient, and the counterexample shows the quotient is unavoidable rather than a
bug.

**Test (falsifiable).** Formalize a group action `G ↷ Config` with the invariance
`bar (g • x) = bar x`, then attempt the orbit statement. A pair of
topologically identical but `G`-inequivalent minimizers would falsify it — itself
a striking statement about the limits of contact-map-based structure prediction.

**Why now?** We have a precise, *proved* statement of non-uniqueness to react to,
and the degree-1 homogeneity `totalPersistence_scale` already shows invariance
under the most basic symmetry (global scaling), the seed of the action `G`.
