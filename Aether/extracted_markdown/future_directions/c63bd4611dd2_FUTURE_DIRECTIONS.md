# Future Directions: Parametric Fixed-Point Theory

## Synthesis

This cycle isolated the *quantitative engine* of parametric Banach theory: a single
stability estimate `dist xf xg ≤ dist (f xg) (g xg) / (1 - K)`
(`contraction_fixedPoint_stability`). The decisive structural insight is that this bound
needs only **one** of the two maps to be a contraction — `g` is completely arbitrary, and
even `0 ≤ K` is unnecessary. Once isolated, every parametric phenomenon in the seed
document reduces to plugging a hypothesis into this one inequality: uniform Lipschitz
dependence (`lipschitz_parametric_fixedPoint`, Direction 1 of the seed) becomes a literal
one-liner with the *exact* advertised constant `L/(1-K)`.

The second theme is that **uniqueness does the algebra for free**. Equivariance under
symmetries (`equivariant_fixedPoint`) is not an extra hypothesis to be imposed but a
*forced* consequence: any intertwining map `φ` sends a fixed point to a fixed point, and
uniqueness (`eq_of_fixedPoints_of_contraction` from the catalog `Core`) collapses the two.
The same uniqueness principle is what makes the non-autonomous composition rate
(`iteratedComp_contraction`, generalizing the catalog's two-map `contraction_comp` to the
product `∏ K i`) interesting rather than tautological.

The Critic's contribution — `contraction_K_eq_one_no_fixedPoint` — pins down the exact
failure locus: the translation `x ↦ x+1` is a `1`-Lipschitz isometry of ℝ with no fixed
point, so the denominator `1-K` genuinely cannot vanish. Nothing surprising *failed* this
cycle; the main lesson was negative-engineering: stating each corollary directly (rather
than routing through the stability bound) would have duplicated the triangle-inequality
argument three times. Centralizing it is what made the batch tractable.

## Results Summary

- `contraction_fixedPoint_stability`: proved — the fundamental bound `dist xf xg ≤ dist (f xg) (g xg)/(1-K)`, requiring only that `f` contracts; the engine for everything below.
- `lipschitz_parametric_fixedPoint`: proved — a uniformly `L`-Lipschitz family of `K`-contractions has an `L/(1-K)`-Lipschitz fixed-point map (explicit constant).
- `equivariant_fixedPoint`: proved — an intertwining symmetry `φ` of two contractions maps fixed point to fixed point, i.e. symmetries are inherited by self-consistent solutions.
- `iteratedComp_contraction`: proved — composition of `n` maps with constants `K i` contracts with factor `∏ i∈range n, K i`, generalizing the catalog two-map rule.
- `contraction_K_eq_one_no_fixedPoint`: disproved (the `K=1` existence claim) — `x ↦ x+1` is a `1`-Lipschitz map on ℝ with no fixed point, proving `K<1` is sharp.

## Research Directions

### Direction 1: Hölder fixed points for degenerating contraction factors
**Hypothesis**: If a family of contractions satisfies `K(t) ≤ 1 - c · dist(t,t₀)^β` (with
`β > 0`, `c > 0`) rather than a uniform `K < 1`, then the fixed-point map is Hölder
continuous near `t₀` with an exponent determined by `β` (conjecturally `1-β` for small `β`).
**Test**: Substitute the degenerating `K(t)` into `contraction_fixedPoint_stability`,
giving `dist(x⋆(t), x⋆(t₀)) ≤ dist(F t (x⋆ t₀), F t₀ (x⋆ t₀)) / (c · dist(t,t₀)^β)`; combine
with a Lipschitz family bound and check whether the resulting exponent matches Mathlib's
`HolderWith`. A single explicit family on ℝ (e.g. `F t x = (1 - |t|^β) x`) can confirm or
refute the predicted exponent computationally before formalization.
**Why now**: The exact stability denominator `1-K` is now an isolated, reusable lemma, so
the only new ingredient is controlling its degeneration — no triangle-inequality work
remains. The sharpness witness `contraction_K_eq_one_no_fixedPoint` shows precisely the
`K→1` singularity that Hölder regularity must tame.
**If true**: Bridges the smooth `K<1` theory to the sharp `K=1` boundary, supplying
regularity exactly in the transition region and connecting to implicit-function-theorem
style perturbation results.
**If false**: The counterexample would reveal that fixed-point regularity can be *strictly
worse* than Hölder near the contraction threshold, identifying a genuinely new failure mode.

### Direction 2: Infinite non-autonomous products and the divergence criterion
**Hypothesis**: For maps `g i` with constants `K i < 1`, the iterates `iteratedComp g n x₀`
converge (Cauchy) iff the partial products `∏_{i<n} K i → 0`, which holds in particular
when `∑ i (1 - K i) = ∞` even if every individual `K i → 1`.
**Test**: Strengthen `iteratedComp_contraction` to a Cauchy statement using
`cauchySeq_of_le_geometric`-style telescoping, with the geometric ratio replaced by the
running product; then prove the analytic lemma `∑(1-K i)=∞ → ∏ K i → 0` via
`Real.tendsto_prod` / `HasProd` API and `log`-summation.
**Why now**: `iteratedComp_contraction` supplies the exact per-step product bound that the
telescoping argument consumes; the base case (two maps) is already in the catalog as
`contraction_comp`.
**If true**: Gives convergence guarantees for adaptive schemes whose contraction factor
drifts toward 1 (e.g. decaying learning-rate schedules), a regime the stationary `K^n`
theory cannot reach.
**If false**: A non-autonomous sequence with `∏ K i → 0` but non-Cauchy orbits would show
the product rate alone is insufficient and that a uniform displacement bound is also needed.

### Direction 3: Nadler's set-valued contraction theorem
**Hypothesis**: A map `F : α → Closeds α` that is `K`-contracting (`K<1`) in the Hausdorff
metric on a complete space has a point `x` with `x ∈ F x`.
**Test**: Build the Banach iteration `x_{n+1} ∈ F(x_n)` choosing an approximately closest
point (`hausdorffDist` + `EMetric.exists_dist_lt` selection), show the orbit is Cauchy by
the Hausdorff contraction, and pass to the limit; the existing
`exists_fixedPoint_of_approx_fixedPoint_compactness` from `Core` is the template for the
limit step.
**Why now**: Mathlib already provides `EMetric.hausdorffDist` and
`TopologicalSpace.Closeds`; the only gap is the "choose closest point" selection, which the
single-valued iteration in `Core` shows how to organize.
**If true**: Lifts the entire parametric framework to nondeterministic/set-valued dynamics,
the natural setting for differential inclusions and control.
**If false**: The obstruction would localize exactly in the measurable-selection step,
flagging which choice principle the set-valued theory actually requires.

### Direction 4: Equivariance as a genuine `MulAction` statement
**Hypothesis**: If a group `G` acts by isometries on both a parameter space and `α`, and a
contraction family is equivariant (`F (g•t) (g•x) = g • F t x`), then the fixed-point map is
`G`-equivariant: `x⋆(g•t) = g • x⋆(t)`.
**Test**: Specialize `equivariant_fixedPoint` with `f := F t`, `f' := F (g•t)`, `φ := (g • ·)`;
the intertwining hypothesis `φ (f x) = f' (φ x)` is exactly the family-equivariance axiom, so
the abstract lemma should discharge it after unfolding `MulAction.toFun`.
**Why now**: `equivariant_fixedPoint` already proves the bare intertwining version; promoting
it to `MulAction` is a packaging exercise that connects to Mathlib's large equivariance API.
**If true**: Formalizes "symmetries of the dynamics are inherited by self-consistent
solutions" at the level of group actions, reusable across physics and learning models.
**If false**: A failure would mean the group action interacts with completeness/uniqueness in
a subtle way (e.g. non-isometric actions), narrowing the correct hypothesis.

### Direction 5: Stability under perturbation of the contraction constant
**Hypothesis**: If `f` is a `K`-contraction and `g` is a `K'`-contraction with both `K,K'<1`,
then their fixed points satisfy a *two-sided* bound
`dist xf xg ≤ min ( dist (f xg) (g xg)/(1-K), dist (g xf) (f xf)/(1-K') )`,
strictly improving the one-sided `contraction_fixedPoint_stability` when both maps contract.
**Test**: Apply `contraction_fixedPoint_stability` in both directions (swapping the roles of
`f`,`g`) and take the minimum; verify on a 1-D example that the min is genuinely tighter than
either single bound.
**Why now**: `contraction_fixedPoint_stability` is asymmetric by design; the symmetric upgrade
is immediate once the asymmetric core exists, and it is the right tool for comparing two
*different* algorithms (not just two parameter values of one family).
**If true**: Yields sharper a-posteriori error bounds for comparing competing fixed-point
solvers.
**If false**: Would expose that the two one-sided bounds are never simultaneously tight,
clarifying the geometry of the fixed-point displacement.
