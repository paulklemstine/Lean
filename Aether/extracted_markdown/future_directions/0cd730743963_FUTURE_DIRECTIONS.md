# Future Directions: General Legendre–Fenchel Duality and Idempotent Probability

## Synthesis

This cycle lifted the catalog's *special-case* Legendre–Fenchel results to the
**general** convex-conjugate operator `legendreTransform f y = sSup {x·y − f x}`.
Previously the catalog only knew duality facts for the quadratic seed `x²/2`
(`legendre_half_sq`, `legendre_biconjugate_half_sq` in
`Catalog.Tropical.LegendreDuality`) and a finite-type tropical biconjugate
inequality (`tropical_biconjugate_le` in `Catalog.Bridges.TropicalRateDistortion`).
We proved, for *arbitrary* `f : ℝ → ℝ` (under the natural `BddAbove` hypotheses
that make the supremum genuine), the four structural pillars of convex duality —
the Fenchel–Young inequality, order-reversal, the Fenchel–Moreau inequality
`f★★ ≤ f`, and **full convexity** of the conjugate — plus the two exact functional
transformation laws (argument shift under adding a linear term; value shift under
adding a constant).

The structural insight that emerged is that *every* duality pillar is a one-line
consequence of a single primitive: `le_csSup` applied to the membership
`x·y − f x ∈ range`. Fenchel–Young is that membership directly; the biconjugate
inequality is Young applied uniformly over `y`; convexity is Young split across a
convex combination of the dual variable. This collapses what is usually a chapter
of convex analysis into a small, reusable algebraic core. In particular,
`legendreTransform_convexOn` *upgrades* the catalog's `rateFunction_convex_epigraph`
(which proved only that sublevel sets are convex) to the genuine `ConvexOn`
predicate, and therefore applies verbatim to the large-deviation `rateFunction`
of `Catalog.Bridges.LargeDeviationPrinciple`.

What did **not** close is the converse, `f★★ = f`. The Critic identified exactly
why: the inequality is tight only for proper convex *lower-semicontinuous* `f`.
A convex function perturbed upward at a single point has the *same* conjugate,
hence the same biconjugate, so `f★★` recovers the lsc convex envelope and sits
strictly below `f` at that point. This boundary case shows lsc is essential and
seeds the central open target below (Direction 1).

## Results Summary

- `legendreTransform_fenchel_young`: proved — general Fenchel–Young inequality `x·y ≤ f x + f★ y`, generalizing the catalog's quadratic `fenchel_young_quadratic`.
- `legendreTransform_antitone`: proved — the conjugate is order-reversing in its function argument (`f ≤ g ⟹ g★ ≤ f★`), a duality fact absent from the catalog.
- `legendreTransform_biconjugate_le`: proved — the Fenchel–Moreau inequality `f★★ ≤ f` for all real `f`, generalizing both `tropical_biconjugate_le` (finite types) and `legendre_biconjugate_half_sq` (quadratic).
- `legendreTransform_convexOn`: proved — the conjugate of *any* function is convex (full `ConvexOn`), upgrading `rateFunction_convex_epigraph` from sublevel-convexity to `ConvexOn`.
- `legendreTransform_add_linear`: proved — exact law `(f + a·id)★(y) = f★(y − a)`; the two defining sets literally coincide, so no boundedness is needed.
- `legendreTransform_add_const`: proved — exact law `(f + c)★(y) = f★(y) − c`.
- `legendreTransform_biconjugate_eq_of_convex_lsc`: conjecture (sorry) — the Fenchel–Moreau *equality* `f★★ = f` for proper convex lsc `f`.

## Research Directions

### Direction 1: The Fenchel–Moreau equality `f★★ = f`
**Hypothesis**: For proper convex lower-semicontinuous `f : ℝ → ℝ`, the biconjugate
satisfies `legendreTransform (legendreTransform f) x = f x` for all `x`.
**Test**: Discharge the `sorry` in `legendreTransform_biconjugate_eq_of_convex_lsc`.
The `≤` half is already `legendreTransform_biconjugate_le`; the `≥` half needs an
epigraph separation argument. Confirm by also producing the explicit
counterexample (a one-point-perturbed convex function) witnessing that lsc cannot
be dropped.
**Why now**: We have the inequality direction and full `ConvexOn` of the conjugate;
Mathlib supplies `LowerSemicontinuous`, `ConvexOn`, and `geometric_hahn_banach_point_closed`.
The key insight is that `f★★` is precisely the lsc convex envelope of `f`, so the
gap `f − f★★` is a *measure of non-lsc-convexity* — separating the epigraph from a
point below the graph closes the loop.
**If true**: Conjugation becomes an involution on proper convex lsc functions,
making the catalog's `legendreTransform` a genuine duality and unlocking Cramér's
theorem lower bound and Varadhan's lemma constructively.
**If false**: The counterexample would pinpoint the minimal regularity at which
duality breaks, refining the hypothesis set.

### Direction 2: Conjugate of a sum is the inf-convolution of conjugates
**Hypothesis**: With `infConv f g z = sInf {f x + g (z − x)}`, one has
`legendreTransform (infConv f g) = legendreTransform f + legendreTransform g`,
the additive law that drives Cramér's theorem via independence.
**Test**: Define `infConv` and prove the identity by the reindexing
`sup_z (z·y − inf_{x}(f x + g(z−x))) = sup_{x,w}((x+w)·y − f x − g w)`, which factors
into the two single conjugates. Validate numerically on `f = g = x²/2` (expect
`(x²/4)★ = y²`).
**Why now**: We now have `legendreTransform_add_linear` and `legendreTransform_add_const`,
the algebraic substitution lemmas needed to manipulate the inner argument `z − x`.
The key insight is that inf-convolution is *addition in the conjugate domain*, so
the `n`-fold convolution of a single-step rate function is just `n·Λ`, which is
exactly Cramér's scaling.
**If true**: The Cramér rate function for `Sₙ/n` becomes the single-step conjugate
`Λ★`, completing the bridge to `Catalog.Bridges.LargeDeviationPrinciple.rateFunction`.
**If false**: The boundedness conditions on `infConv` (it may fail to be `BddBelow`)
would reveal where idempotent integration needs properness assumptions.

### Direction 3: Tropical Varadhan lemma as an idempotent integral
**Hypothesis**: For a rate function `I`, the value `sup_x (φ x − I x)` equals the
"tropical integral" of `φ` against the idempotent measure `exp(−I)`, and equals the
limiting log-moment generating functional.
**Test**: Define `tropicalIntegral I φ = legendreTransform I` evaluated appropriately
and prove `tropicalIntegral I φ = legendreTransform (fun x => I x − φ x) 0` style
identities; connect to `ArithLDP.rateFunction`.
**Why now**: `legendreTransform_antitone` and `legendreTransform_add_const` give the
monotonicity and translation behaviour an integral must satisfy. The key insight is
that `sup_x(φ − I)` is literally a conjugate, so Varadhan's lemma is a *change of
the linear test functional* inside `legendreTransform`.
**If true**: Large-deviation expectations become constructive tropical integrals,
making the LDP/tropical correspondence computational rather than merely algebraic.
**If false**: A failure would distinguish the max-plus expectation from the genuine
conjugate, identifying where σ-additivity is truly needed.

### Direction 4: Idempotent (max-plus) measures and a tropical Fatou lemma
**Hypothesis**: A set function `μ` with `μ(A ∪ B) = max(μ A, μ B)` admits a density
`−I`, and for `fₙ → f` pointwise, `sup_x(f x + μ x) ≤ liminf sup_x(fₙ x + μ x)`.
**Test**: Define `IdempotentMeasure` as an `sSup`-valued monotone set function,
prove the density representation via `legendreTransform`, and prove the Fatou
inequality using `Filter.liminf` monotonicity plus `legendreTransform_antitone`.
**Why now**: `legendreTransform_antitone` is exactly the monotonicity backbone a
Fatou-type inequality needs. The key insight is that tropical integration is the
conjugate operator, so "lower semicontinuity of integration" is monotonicity of
`sSup` under pointwise limits — a property we can now state precisely.
**If true**: A standalone idempotent measure theory emerges, mirroring Mathlib's
`MeasureTheory` but in the max-plus semiring.
**If false**: The obstruction would show which Mathlib measure axioms have no
idempotent analogue.

### Direction 5: Max-plus spectral characterization of random-walk rate functions
**Hypothesis**: For the max-plus random walk `Sₙ = max(X₁,…,Xₙ)`, the LDP rate
function equals the Legendre–Fenchel transform of the max-plus Perron–Frobenius
eigenvalue of the transition operator.
**Test**: Bridge `Catalog/Tropical/PerronFrobenius` (max-plus eigenvalue theory) to
`ArithLDP.rateFunction` by showing the eigenvalue is the exponential growth rate and
applying `legendreTransform`/`legendreTransform_convexOn` to obtain a convex rate
function.
**Why now**: `legendreTransform_convexOn` guarantees the resulting rate function is
convex regardless of the spectral input. The key insight is that the max-plus
eigenvalue *is* the cumulant generating function of the walk, so its conjugate is
the rate function by definition.
**If true**: Two independent catalog formalizations (tropical spectral theory and
LDP) unify into one tropical spectral characterization of rare-event geometry.
**If false**: The mismatch would reveal that the eigenvalue captures only the bulk
growth rate, not the full large-deviation profile.
