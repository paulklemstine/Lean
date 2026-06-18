# FUTURE DIRECTIONS — Theorems as Phase Transitions in Proof Space

## Synthesis

This cold-start cycle turned the speculative slogan *"theorems are phase transitions
in proof space"* into two rigorous, fully machine-checked pillars. The first pillar
(`MachineLearning/ProofSpaceDimension.lean`) treats the space of statements as strings
over a `k`-symbol alphabet and computes the single scalar invariant of that space: its
**exponential growth exponent**. We proved `ProofSpaceModel.dimension`, that
`log(volume k n) / n → log k`, by pinning the geometric volume between two consecutive
powers `k^n ≤ volume ≤ k^(n+1)` and squeezing on the log scale. This is the honest,
provable core of the concept's "Hausdorff dimension of proof space" — a box-counting
growth rate — and it shows the proof-space volume genuinely follows a power law
`k^n = e^{n·log k}`.

The second pillar (`MachineLearning/ProofSpacePhaseTransition.lean`) builds an **order
parameter** on top of that space: the mean-field/logistic provability fraction
`ρ(β,nc,x) = 1/(1 + exp(β(x−nc)))`. We proved its critical value `1/2` at the threshold
`nc`, strict monotone decay in statement length, a reflection duality
`ρ(nc+t)+ρ(nc−t)=1`, and — the heart of the matter — that as the sharpness `β → ∞` the
order parameter converges to the Heaviside step (→1 below `nc`, →0 above `nc`). The
**Critic's boundary result** `orderParam_continuous` is the structural punchline: at every
*finite* `β` the order parameter is continuous, so the "sharp transition" is strictly an
emergent `β → ∞` limit, exactly as in mean-field statistical mechanics. Nothing was
disproved; the one statement we could not close this cycle, `orderParam_window` (the
`1/β` transition-width scaling), is recorded as an explicit conjecture with `sorry`.

The structural insight tying these together: a phase transition needs *both* an ambient
space with a well-defined size exponent (Pillar I) *and* an order parameter that becomes
singular only in a scaling limit (Pillar II). The natural next cycle fuses them — letting
the critical length `nc` and the sharpness `β` depend on the proof-space dimension `log k`
— which is what the directions below pursue.

## Results Summary

- `ProofSpaceModel.volume_lower`: proved — the proof-space volume dominates the top power `k^n`.
- `ProofSpaceModel.volume_upper`: proved — the geometric volume is bounded by `k^(n+1)`, the clean two-power sandwich.
- `ProofSpaceModel.volume_pos`: proved — proof-space volume is strictly positive for `k ≥ 2`.
- `ProofSpaceModel.dimension`: proved — the exponential growth rate `log(volume)/n` converges to `log k`, the proof-space dimension (power-law exponent).
- `ProofSpaceModel.orderParam_pos`: proved — the provability order parameter is strictly positive.
- `ProofSpaceModel.orderParam_at_critical`: proved — the order parameter equals `1/2` exactly at the critical length `nc`.
- `ProofSpaceModel.orderParam_antitone`: proved — provability strictly decreases with statement length for positive sharpness.
- `ProofSpaceModel.orderParam_reflection`: proved — duality `ρ(nc+t)+ρ(nc−t)=1` about the threshold.
- `ProofSpaceModel.orderParam_continuous`: proved (Critic boundary result) — at finite sharpness there is no singularity; the transition is an emergent limit.
- `ProofSpaceModel.orderParam_tendsto_one_sub`: proved — below `nc`, `ρ → 1` as `β → ∞` (subcritical phase).
- `ProofSpaceModel.orderParam_tendsto_zero_super`: proved — above `nc`, `ρ → 0` as `β → ∞` (supercritical phase); together with the previous result this is the Heaviside step / phase transition.
- `ProofSpaceModel.orderParam_window`: conjecture (`sorry`) — the transition window has radius `c/β`, i.e. the transition width scales as `1/β`.

## Research Directions

### Direction 1: Transition-width scaling law (closing `orderParam_window`)
**Hypothesis**: For every `0 < ε < 1` there is `c = log((1−ε)/ε) > 0` such that for all
`β > 0`, whenever `x > nc + c/β` we have `orderParam β nc x < ε` (and symmetrically
`> 1−ε` below `nc − c/β`). Hence the transition window has radius exactly `c/β`.
**Test**: Discharge the `sorry` in `orderParam_window`: from `x > nc + c/β` and `β > 0`
derive `β(x−nc) > c = log((1−ε)/ε)`, apply `Real.exp_lt_exp`/`Real.exp_log`, then bound
the sigmoid. A disproof would be any `(ε,β,x)` violating the bound.
**Why now**: This cycle already proved the `β → ∞` endpoint limits and monotonicity; the
window law is the quantitative *rate* interpolating them, and the logistic algebra is
identical to `orderParam_reflection`. The key insight is that the inverse logistic
`log((1−ε)/ε)` converts the abstract limit into an explicit `1/β` length scale.
**If true**: We obtain a genuine critical-exponent statement (`ν = 1` for this order
parameter), making "sharpness" a measurable length scale rather than a slogan.
**If false**: It would mean the logistic family is not the right universality class and a
heavier-tailed order parameter is needed.

### Direction 2: Coupling the order parameter to the proof-space dimension
**Hypothesis**: If the sharpness scales with the ambient dimension, `β = γ·log k`, then the
half-width of the transition window measured in *symbols* is `c/(γ log k)`, so richer
alphabets (larger `log k`) produce sharper transitions; in particular the limit
`k → ∞` reproduces a step function at fixed `γ`.
**Test**: Combine `ProofSpaceModel.dimension` with Direction 1's window law to prove a
joint statement quantifying window radius as a function of `k`; computationally sanity-check
for `k ∈ {2,3,10}`.
**Why now**: Both ingredients now exist in the same `ProofSpaceModel` namespace and import
cleanly. The key insight is that `log k` is the only scalar the ambient space exposes, so
it is the natural unit in which to measure the transition width.
**If true**: It unifies Pillars I and II into a single dimension-controlled transition,
the genuine cross-domain bridge the concept asked for.
**If false**: It would show provability sharpness is independent of statement-encoding
richness, an interesting decoupling.

### Direction 3: Length distribution of "provable" statements is a power law
**Hypothesis**: Weighting the `k^n` statements of length `n` by the order-parameter mass
`ρ(β,nc,n)` yields a normalizable distribution whose tail decays like `k^n·exp(−βn)`, i.e.
a (sub)exponential/power-law-in-`exp` profile with exponent governed by `log k − β`; it is
summable iff `β > log k`.
**Test**: Define `weight β nc k n := (k^n : ℝ) * orderParam β nc n` and prove the series
`∑ n, weight …` converges iff `β > log k` (ratio/`summable_geometric`-style argument).
**Why now**: `dimension` gives the `k^n` growth and `orderParam` gives the `exp(−βn)`
suppression; multiplying them is immediate. The key insight is that the competition between
proof-space growth `log k` and provability suppression `β` is exactly a radius-of-convergence
threshold.
**If true**: It realizes the concept's predicted "power law for theorem lengths" with an
exponent tied to the dimension `log k`, a falsifiable empirical prediction.
**If false**: The naive product model is wrong and correlations between length and
provability must be modeled explicitly.

### Direction 4: Non-monotone / multi-threshold order parameters (boundary of universality)
**Hypothesis**: Replacing the single threshold `nc` by a finite set `{nc₁ < … < nc_m}` via a
sum/product of logistics produces an order parameter that is *not* monotone yet still
converges, as `β → ∞`, to a multi-step staircase — modeling multiple independent
"Gödel-type" obstructions appearing at distinct lengths.
**Test**: Define `multiOrderParam` and prove (a) it is continuous at finite `β`
(generalizing `orderParam_continuous`) and (b) its `β → ∞` limit equals the staircase
`#{i : nc_i < x}/m`. A counterexample at any single step disproves it.
**Why now**: The single-threshold limits are now proven and reusable per-factor. The key
insight is that independent obstructions superpose additively in the limit even though the
finite-`β` object is genuinely non-monotone.
**If true**: It extends the framework from one phase transition to a phase *diagram*,
matching the concept's list of distinct landmark theorems (Gödel, FLT, ABC).
**If false**: It would reveal that obstructions interact rather than superpose, demanding a
correlated model.

### Direction 5: Free-energy / variational characterization of the critical length
**Hypothesis**: There is a strictly convex "free energy" `F(β,nc,x)` (e.g.
`log(1 + exp(β(x−nc)))/β`, the softplus) whose `x`-derivative is `1 − ρ` and whose
`β → ∞` limit is the ramp `max(x−nc,0)`; the critical length `nc` is exactly the unique
non-smooth point of that limiting free energy.
**Test**: Prove `deriv (F β nc) x = 1 − orderParam β nc x`, convexity of `F` in `x`, and
the pointwise limit `F β nc x → max (x−nc) 0` as `β → ∞`; identify `nc` as the kink.
**Why now**: `orderParam` is literally the logistic derivative of softplus, so the analytic
link is one `deriv` lemma away. The key insight is that a phase transition is the loss of
analyticity of a free energy, and softplus → ramp is the cleanest place to *prove* that loss.
**If true**: It anchors the whole program in the standard physics definition of a phase
transition (non-analytic free energy), elevating the metaphor to a theorem schema.
**If false**: The order parameter would fail to be a true gradient flow and the
thermodynamic analogy would break, itself an informative negative result.
