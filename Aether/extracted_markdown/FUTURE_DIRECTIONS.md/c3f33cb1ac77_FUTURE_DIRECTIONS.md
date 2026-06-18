# FUTURE_DIRECTIONS — Tropicalized Neural Observation Pseudometric

Companion to `Catalog/Bridges/NeuralTropicalPseudometric.lean`.

## Synthesis

This cycle built a genuine **bridge from coalgebraic neural semantics to tropical /
ultrametric valuation geometry**. Starting from the catalog's `NeuralObservationSystem`
(`Bridges/CoalgebraicNeuralMyhillNerode.lean`), we defined a finite-depth observation
equivalence `obsEqAtDepth n x y` — "indistinguishable using `n` layers of coalgebraic
derivative look-ahead" — and proved it is reflexive, symmetric, transitive *at each fixed
depth*, and antitone in depth. The decisive structural fact is that transitivity holds
level-by-level: this is exactly what turns the "set of distinguishing depths" into an
upward-closed valuation. Tropicalizing that valuation as
`tdist x y = ⨆ₙ [x,y distinguished at depth n] · 2⁻ⁿ` yields a real-valued ultra-pseudometric
*without any* `WithTop`/`∞` bookkeeping: the `iSup` is automatically realized at the least
distinguishing depth, and infinite agreement (behavioral equality) collapses to distance `0`.

We proved the full pseudometric package: `tdist_self = 0`, symmetry, the **strong
(ultrametric) triangle law** `tdist x z ≤ max (tdist x y) (tdist y z)` — the analytic avatar
of `UltraNormObj.norm_add` from `Bridges/CategoricalTropicalUltrametric.lean` — the
zero-distance characterization `tdist x y = 0 ↔ behavioral equivalence`, positive-definiteness
on distinguishable states (separation), and a **certified-compression** bridge
(`obsEqAtDepth_iff_behavior`, `neural_compression_certified`): a finite `O(|α|ⁿ)` derivative
check soundly certifies agreement of the infinite truncated behavior.

The most instructive *failure* was the Hypothesizer's natural conjecture that the **derivative
map is nonexpansive**. The Critic disproved it: the derivative *peels* one valuation layer, so
separation depth drops by at most one and distance can therefore **double**. We proved the
correct sharp bound (`derivative_two_lipschitz`: factor `2`) and exhibited an explicit
3-state-tower counterexample (`derivative_not_nonexpansive`). This mirrors the classical
metric on streams, where `tail` is `2`-Lipschitz and the *contraction* lives in the inverse
`cons`/observation direction — a structural lesson that reshapes the next round of conjectures.

## Results Summary

- `neural_behavior_cons`: proved — behavior of a derivative = behavior after prepending the symbol; the structural glue for all depth/behavior inductions.
- `obsEqAtDepth_refl`: proved — depth-`n` observation equivalence is reflexive.
- `obsEqAtDepth_symm`: proved — depth-`n` observation equivalence is symmetric.
- `obsEqAtDepth_trans`: proved — depth-`n` observation equivalence is transitive; the engine behind the ultrametric inequality.
- `obsEqAtDepth_antitone`: proved — deeper agreement implies shallower agreement, making distinguishing-depths upward closed (a valuation).
- `obsEqAtDepth_iff_behavior`: proved — depth-`n` equivalence ⇔ agreement on all input words of length ≤ n (the catalog `neural_equiv_upto` bridge).
- `neural_compression_certified`: proved — depth-`N₀` agreement certifies agreement of all truncated behaviors; a sound finite state-merging criterion.
- `tdist_nonneg`, `tdist_le_one`: proved — the distance lands in `[0,1]`.
- `tdist_self`: proved — self-distance is zero.
- `tdist_comm`: proved — symmetry.
- `tdist_strong_triangle`: proved — the strong/ultrametric triangle law (analytic avatar of `UltraNormObj.norm_add`).
- `tdist_eq_zero_iff`: proved — zero distance ⇔ behavioral equivalence.
- `tdist_pos_of_distinguishable`: proved — distinguishable states have positive distance (separation / positive-definiteness on the quotient).
- `derivative_two_lipschitz`: proved — the derivative map is `2`-Lipschitz for `tdist`.
- `derivative_not_nonexpansive`: disproved (explicit counterexample) — the derivative is NOT nonexpansive; the sharp constant is exactly `2`.

## Research Directions

### Direction 1: Functorial separated-quotient object
**Hypothesis**: `tdist` descends to the quotient `σ / neural_equiv` as a genuine ultrametric
(positive-definite, strong triangle), and the assignment `N ↦ (quotient, descended tdist)` is a
functor into a category of ultra-pseudometric spaces with nonexpansive maps, sending every
`NeuralObservationSystem` morphism to a nonexpansive map.
**Test**: Build the `Quotient (neural_setoid N)`, prove `tdist` is `neural_equiv`-invariant in
each argument (immediate from `tdist_eq_zero_iff` + `tdist_strong_triangle`), then show
functoriality on the catalog's morphism notion; check positivity via
`tdist_pos_of_distinguishable`.
**Why now**: We already have the three lemmas the descent needs (`tdist_eq_zero_iff`,
`tdist_strong_triangle`, `tdist_pos_of_distinguishable`); only the `Quotient` plumbing and a
morphism definition remain. The key insight is that `{tdist = 0}` is *exactly* `neural_equiv`,
so the quotient is automatically separated.
**If true**: A clean functor `NeuralObservationSystem ⟶ UltraPseudoMetric`, connecting
behavioral minimization to the catalog's `UltraNormObj`/`TropObj` world as an honest functor,
not a dictionary.
**If false**: The obstruction would localize in morphism behavior, revealing that neural
morphisms are not uniformly nonexpansive — itself a sharp statement about what coalgebra maps
preserve metric structure.

### Direction 2: The sharp constant `2` and a contractive inverse
**Hypothesis**: For every system, `tdist (step x a) (step y a) ≤ 2 · tdist x y` is tight (the
constant `2` cannot be lowered), and there is a dual **contraction**: the "one-step assembly"
map sending observations-plus-derivatives back to a state is `1/2`-Lipschitz, so the behavior
functor is the unique fixed point of a Banach-style contraction on the ultrametric.
**Test**: Strengthen `derivative_not_nonexpansive` to show the supremum of
`tdist(step x a, step y a) / tdist x y` equals `2` over all systems; then formalize the
assembly map and prove a `1/2`-Lipschitz bound, aiming at a Banach fixed-point statement for
the final coalgebra in the ultrametric `tdist`.
**Why now**: `derivative_two_lipschitz` already gives the upper bound and the cex gives a ratio
`> 1`; pushing the cex to ratio exactly `2` is a finite computation. The key insight is that
the derivative expands and its inverse contracts by the same factor `2⁻¹`, the hallmark of a
metric final-coalgebra.
**If true**: Places neural state compression inside the metric-coalgebra / Banach fixed-point
framework, giving convergence guarantees for iterative refinement.
**If false**: A super-doubling example would mean the valuation is not a clean `2⁻ⁿ` grading,
forcing a base other than `2` and reshaping the tropical codomain.

### Direction 3: Parametric tropical base and a true metric on a complete codomain
**Hypothesis**: Replacing `2⁻ⁿ` by `c⁻ⁿ` for any `c > 1` yields the *same* topology and the
same strong triangle law, and choosing the codomain `ℝ≥0∞` (ENNReal) with `tdist = c^{-sepDepth}`
makes `(σ/≈, tdist)` a **complete** ultrametric space.
**Test**: Generalize `tdist` to a base parameter `c`, re-prove the package (the proofs only use
`0 < cⁿ` and monotonicity), then prove completeness via the standard "Cauchy ⇒ stabilizing
finite prefixes" argument enabled by antitonicity (`obsEqAtDepth_antitone`).
**Why now**: Every current proof factors through `pow_pos` and `obsEqAtDepth_antitone`, both
base-agnostic; the key insight is that the *combinatorics* of the valuation tower, not the
numeric base, carries all the content.
**If true**: A canonical complete ultrametric realization of neural behavior, ready to host
fixed-point and contraction theorems (feeds Direction 2).
**If false**: A base-dependent topology would expose a hidden non-archimedean subtlety in the
depth grading worth isolating.

### Direction 4: Quantitative compression with a budget/error trade-off
**Hypothesis**: For systems with finite input alphabet `α`, truncating exploration at depth `N`
merges exactly the classes of `obsEqAtDepth N`, and the induced approximation error in `tdist`
is at most `2⁻⁽ᴺ⁺¹⁾`; hence a target error `ε` is achievable with budget `O(|α|^⌈log₂(1/ε)⌉)`.
**Test**: Prove `|tdist x y − tdistₙ x y| ≤ 2⁻⁽ᴺ⁺¹⁾` where `tdistₙ` caps the `iSup` at `N`
(a finite max), using `obsEqAtDepth_antitone` to bound the tail terms; then derive the budget
bound for finite `α`.
**Why now**: The certified-compression bridge (`neural_compression_certified`) already gives
soundness; the key insight is that the discarded `iSup` tail is geometrically small
(`≤ 2⁻⁽ᴺ⁺¹⁾`), turning sound merging into a *quantitative* approximation guarantee.
**If true**: A formally certified pipeline from derivative computation to `ε`-approximate state
minimization — the algorithmic payoff promised by the concept.
**If false**: A non-geometric tail would mean some systems hide arbitrarily late
distinctions, refuting bounded-budget compressibility and characterizing the "hard" systems.

### Direction 5: Cross-domain transport to p-adic valuation depth
**Hypothesis**: The neural valuation `sepDepth` and the p-adic valuation depth of
`Computation/PadicValuationDepth.lean` are instances of one abstract "ultrametric from a
transitive graded equivalence" construction, and `vdepth_sum_le`-style subadditivity is the
*same theorem* as `tdist_strong_triangle` after the dictionary.
**Test**: Define an abstract `GradedEquivTower` (a family of equivalences, antitone, transitive
at each level) and prove the strong triangle law once; then exhibit both the neural `tdist` and
the p-adic depth as instances and check `vdepth_sum_le` follows.
**Why now**: `tdist_strong_triangle` used *only* `obsEqAtDepth_trans` + antitonicity — exactly
the abstract hypotheses. The key insight is that ultrametricity is a property of *graded
transitive equivalences*, independent of whether the grading comes from neural derivatives or
prime powers.
**If true**: One reusable ultrametric-construction theorem unifying a Bridges result with a
Computation result, exactly the cross-domain consolidation the catalog rewards.
**If false**: A mismatch in how the two gradings interact with their additive structures would
pinpoint where number theory and coalgebra genuinely diverge.
