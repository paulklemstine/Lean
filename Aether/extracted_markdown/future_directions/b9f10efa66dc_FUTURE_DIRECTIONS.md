# FUTURE DIRECTIONS — Biological Topology: Protein Folding as Persistent-Homology Optimization

## Synthesis

This cycle is a **cold start** on the protein-folding-as-topology program. We laid the entire
foundation in a single self-contained file, `Novelty/ProteinFolding.lean`. The load-bearing
identity of the whole theory is the degree-`0` **elder rule**

```
totalPersistence (H0gap x) n = x n - x 0      (H0_totalPersistence_eq_extent)
```

which says that for a one–dimensional chain model the topological folding energy (the sum of
single-linkage merge gaps) is exactly the end-to-end *extent* of the fold. The structural
discovery is a duality/representation statement: because the right-hand side is a *linear
functional of the endpoint coordinates*, the `H₀` energy is the value of one fixed element of
the dual space `(ℕ → ℝ) →ₗ[ℝ] ℝ` (`H0_totalPersistence_eq_functional`). A topological invariant
is thereby *represented* as a linear evaluation — a Gelfand-style translation from geometry into
the dual of functions.

Once that representation is in hand, every physically meaningful statement about the energy
landscape collapses to one line of scalar arithmetic: additivity across protein domains
(`H0_totalPersistence_concat`), endpoint Lipschitz stability (`H0_totalPersistence_stable`),
affine equivariance under rescaling/translation (`H0_totalPersistence_affine`), affineness along
the folding-funnel **homotopy** `t ↦ (1-t)·x + t·y` (`H0_persistence_homotopy_affine`), and
strict decrease under hydrophobic compaction (`compaction_strict_lowers_persistence`). The
homotopy result is the formal core of the "folding funnel" picture: along the straight-line path
in function space between two folds the energy is affine, so the funnel carries **no spurious
internal barrier**.

The most informative *failure boundary* surfaced while developing the contour-length energy
`totalVariation x n = ∑ |x(i+1) − x i|`. On the sorted (monotone) locus it agrees exactly with
the signed extent energy (`totalVariation_eq_extent_of_monotone`); off that locus the two diverge
and only the inequality `|x n − x 0| ≤ totalVariation` survives (`extent_le_totalVariation`).
This is the mathematical shadow of folding: contour length is a conserved primary-structure
quantity, while spatial extent is the variable the fold compresses. The gap
`Δ = totalVariation − |extent|` is therefore a candidate *foldedness order parameter*
(`foldedness_nonneg`), zero iff the chain is fully extended/monotone.

The unifying narrative for the next cycle is dimensional and combinatorial lift: everything here
lives on a 1-D chain whose minimum spanning tree is trivially the path through consecutive atoms.
The frontier is (i) replacing the chain by a general finite metric, where the `H₀` energy becomes
a genuine MST weight, and (ii) climbing to `H₁` and higher, where loops (β-sheets, knots) appear
and the energy is no longer a linear functional of coordinates.

## Results Summary

All results live in `Novelty/ProteinFolding.lean`, compile with `sorry = 0`, and depend only on
`propext`, `Classical.choice`, `Quot.sound`.

- `H0_totalPersistence_eq_extent` — the elder rule; `H₀` total persistence of a chain equals its
  end-to-end extent.
- `H0_totalPersistence_eq_functional` — the energy is the value of a fixed linear functional
  `extentFunctional n = eval n − eval 0` (the duality/representation theorem).
- `H0_totalPersistence_concat` — energy is additive across any cut point (independent folding of
  domains), needing no order on the cut.
- `H0_totalPersistence_stable` — endpoint stability (native fold is a stable attractor under
  coordinate noise).
- `H0_totalPersistence_affine` — degree-`1` homogeneity and translation invariance under
  `x ↦ a·x + c`.
- `H0_persistence_homotopy_affine` — energy is affine along the straight-line folding-funnel
  homotopy; no spurious internal barrier.
- `compaction_strict_lowers_persistence` — a strictly more compact fold has strictly lower
  topological energy (strict hydrophobic collapse).
- `totalVariation_nonneg` — contour length is nonnegative.
- `extent_le_totalVariation` — spatial extent never exceeds contour length; folding can only
  compress.
- `totalVariation_eq_extent_of_monotone` — contour energy equals signed extent on the sorted
  locus.
- `foldedness_nonneg` — the order parameter `Δ = totalVariation − |extent|` is nonnegative.
- `bar_le_totalVariation` — no single residue–residue contact bar exceeds the contour length.

## Research Directions

### Direction 1: The general-metric elder rule (H₀ total persistence = MST weight)
**Hypothesis.** For a finite metric space `(V, d)` the degree-`0` total persistence of the
Vietoris–Rips filtration equals the total edge weight of a minimum spanning tree of the complete
weighted graph `(V, d)`. The chain results are the special case where the MST is the path through
consecutive atoms. **The key insight is** that this cycle isolated the extent identity as the
*only* geometric fact the chain theory uses, so generalizing that one identity to MST weight
automatically lifts all of the downstream theorems (additivity, scaling, homotopy-affineness, the
single-bar bound) to arbitrary geometries. **Test.** Define the merge-death multiset of the
single-linkage dendrogram and prove it coincides with the MST edge-weight multiset; a first
falsifiable milestone is `totalPersistence (H0 d) ≤ (card V − 1) · diam d`, then upgrade `≤` to
exact equality. **Why now?** The representation theorem we just proved shows the energy is
determined by a small set of "merge" scalars; MST weight is the natural metric replacement for
those scalars, and Mathlib already has `SimpleGraph` and `Finset`-spanning-tree machinery to
anchor it. **If false**, the counterexample pinpoints where single-linkage `H₀` deviates from MST
weight (ties/degeneracies), sharpening the elder rule's hypotheses.

### Direction 2: The foldedness order parameter Δ = totalVariation − |extent|
**Hypothesis.** `Δ(x, n) := totalVariation x n − |x n − x 0|` is a faithful monotone measure of
compactness: `Δ ≥ 0` always (already proved as `foldedness_nonneg`), `Δ = 0` iff the chain is
monotone on `{0, …, n}`, and `Δ` is translation-invariant and scales by `a ≥ 0` under
`x ↦ a·x + c`. **The key insight is** that this cycle produced both halves of `Δ` —
`totalVariation_eq_extent_of_monotone` and `extent_le_totalVariation` — so the entire
`Δ = 0 ↔ monotone` characterization is within reach of the same telescoping toolkit.
**Test.** Prove the equality characterization and affine equivariance; then prove or disprove
monotonicity of `Δ` under a single "fold move" that reflects one suffix of the chain.
**Why now?** The order parameter is the cleanest bridge from this formal energy to
statistical-mechanics descriptions of folding, and every ingredient already exists in the file.
**If false**, the failing clause (likely fold-move monotonicity) shows 1-D contour data is too
weak to detect compaction, motivating genuine 2-D/3-D metrics.

### Direction 3: Quantitative bottleneck stability with explicit Lipschitz constant
**Hypothesis.** The contour energy is `2`-Lipschitz in the sup-norm:
`|totalVariation x n − totalVariation y n| ≤ 2 · n · (sup_{i ≤ n} |x i − y i|)`, with the constant
tight. **The key insight is** that `totalVariation_stable` already reduces the whole claim to the
termwise bound `∑ (|x_{i+1} − y_{i+1}| + |x_i − y_i|)`; collapsing that finite sum to the sup-norm
is the only missing mechanical step. **Test.** Bound the proved right-hand side by `2·n·‖x−y‖∞`
on `{0, …, n}` and construct an equality case (a sawtooth perturbation) for tightness.
**Why now?** Stability is the quantitative backbone of "the native fold is a stable attractor,"
and we already proved both the endpoint version (`H0_totalPersistence_stable`) and the termwise
contour version (`totalVariation_stable`). **If false**, a super-Lipschitz blow-up would be a
striking negative result for TDA-based fold scoring (persistence amplifies coordinate noise).

### Direction 4: Higher persistence — an H₁ loop energy and a topological isoperimetric bound
**Hypothesis.** For a planar polygonal (closed) fold the degree-`1` persistent homology has a
single dominant bar whose persistence is bounded above by the perimeter and below by a function
of the enclosed area, yielding a topological isoperimetric inequality
`(H₁ persistence)² ≤ C · perimeter²`, with equality approached by the regular polygon.
**The key insight is** that every current result is `H₀` (linear in coordinates), whereas `H₁`
energy is genuinely nonlinear, so this is exactly where Levinthal's paradox becomes substantive
rather than algebraic. **Test.** Define the closed-chain Rips/Čech `H₁` bar for a convex polygon,
compute birth/death from inradius/circumradius, prove the perimeter upper bound, and start the
area lower bound as a conjecture. **Why now?** The catalog already contains persistent-homology
and Čech-complex machinery (`MachineLearning/CechComplex`, `Tropical/PersistentHomology`,
`Pythagorean/*Persistence`); composing those with this file's energy formalism is the natural
cross-domain bridge. **If false**, it pinpoints that Rips `H₁` does not see geometric area (a
known subtlety vs. Čech), clarifying which filtration the folding energy should use.

### Direction 5: A robust Levinthal separation theorem
**Hypothesis.** If the energy gap between the native fold and the best decoy is `δ > 0`, then the
native fold remains the unique global minimizer under any coordinate perturbation of sup-norm
`< δ / (4·n)`. **The key insight is** that combining the stability modulus of Direction 3 with
the strict-ordering mechanism of `compaction_strict_lowers_persistence` upgrades a bare
uniqueness statement into a *robust* one with an explicit basin radius. **Test.** Show that
perturbed energies stay within `δ / 2` of their originals over a finite decoy ensemble (immediate
from `totalVariation_stable`), preserving the strict ordering and hence the argmin.
**Why now?** This cycle supplies the strict-ordering step (`compaction_strict_lowers_persistence`)
and the endpoint/contour stability seeds (`H0_totalPersistence_stable`, `totalVariation_stable`);
the only missing glue is the sup-norm collapse of Direction 3. **If false**, a degeneracy under
arbitrarily small perturbation would show the topological energy alone cannot single out a fold,
arguing for a regularized or multi-degree energy.
