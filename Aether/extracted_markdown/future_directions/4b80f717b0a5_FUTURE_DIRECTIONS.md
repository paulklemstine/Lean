# Future Directions — Stereographic Neural Attention

## Synthesis

This cycle replaced the softmax score `exp⟨q,k⟩` with the **Cauchy kernel**
`K(q,k) = 1/(1 + ‖q − k‖²)` and asked whether the resulting *stereographic attention*
is intrinsically sparse and geometrically grounded. Two pillars emerged. The first is
**geometric**: `K` is exactly the conformal factor of stereographic projection. We
formalized the projection `σ : E → E × ℝ` by its components `(stereoProj, stereoHeight)`
and proved `stereo_on_sphere` (`σ` really lands on the unit sphere) and the headline
identity `stereo_chordal_eq_kernel`: the squared chordal distance from `σ(x)` to the
north pole equals `4·K(x,0)`. So a Cauchy score *is* a distance on the Riemann sphere,
not a heuristic. The second pillar is **analytic sparsity**: `cauchyKernel_active_iff`
shows the set of keys scoring `≥ τ` is *exactly* a Euclidean ball of radius `√(1/τ − 1)`
around the query, and `cauchy_sparsity_markov` gives the Markov bound
`τ·#active ≤ Σ scores`, refined by `cauchy_total_weight_le` to `τ·#active ≤ N`.

What failed/was deliberately weakened: the program's marquee claim is `O(√N)` sparsity,
but `Σ scores ≤ N` is the only *unconditional* total-mass bound (and it is tight when all
keys coincide with the query). The √N improvement is therefore **not** a theorem about
arbitrary key sets — it must be a statement about *geometrically spread* keys. The honest
decomposition we found is: sparsity = (geometry: activity ⇔ ball membership) ∘ (analysis:
Markov on nonnegative scores). The √N gap lives entirely in bounding `Σ scores` for spread
keys, which is a packing/shell-counting problem on the sphere.

A second structural insight is the cross-domain bridge to the catalog's
`Catalog/MachineLearning/Attention.lean`, where attention is studied *algebraically* as a
matrix commuting with all morphisms (Schur's lemma, `attention_natural_iff_scalar`). Here
attention is studied *geometrically* as a conformal kernel. The two pictures meet on the
diagonal: `cauchyKernel_eq_one_iff` (geometric self-attention maximum) is the kernel analogue
of the scalar-identity fixed point that algebraic naturality forces.

## Results Summary

- `cauchyKernel_pos`: proved — the Cauchy score is strictly positive, so every key always receives some attention (no hard zeros, unlike top-k masking).
- `cauchyKernel_le_one`: proved — scores are bounded by 1, giving a clean total-mass budget `Σ ≤ N`.
- `cauchyKernel_eq_one_iff`: proved — the score saturates at 1 exactly on the diagonal `q = k`, an absolute (not merely relative) self-attention maximum.
- `stereo_on_sphere`: proved — the stereographic image lands on the unit sphere, so "project to the Riemann sphere" is well-typed.
- `stereo_chordal_eq_kernel`: proved — the squared chordal distance from `σ(x)` to the north pole is `4·K(x,0)`; the Cauchy score IS sphere distance.
- `cauchyKernel_active_iff`: proved — the τ-active key set is exactly a Euclidean ball of radius `√(1/τ − 1)` around the query.
- `cauchyKernel_antitone`: proved — closer keys score at least as high; the score is monotone in query–key distance.
- `cauchy_total_weight_le`: proved — total attention mass over `N` keys is at most `N`.
- `cauchy_sparsity_markov`: proved (MAIN) — `τ·#active ≤ Σ scores`, the rigorous sparsity backbone.
- `cauchy_sparsity_card_le`: proved — combined bound `τ·#active ≤ N`, i.e. at most `N/τ` keys are ever active.
- `cauchy_sublinear_mass_conjecture` (spread keys): conjecture (in Lean, `sorry`) — for `δ`-separated keys in `ℝ^d` (`d ≥ 3`), `Σ scores = O(N^{(d-2)/d})` uniformly in `N`, hence `#active = O(N^{(d-2)/d}/τ)`; the advertised `O(√N)` is exactly the `d = 4` case.

## Research Directions

### Direction 1: The sublinear total-mass law for separated keys (`cauchy_sublinear_mass_conjecture`)
**Hypothesis**: If keys `k₁,…,k_N` are `δ`-separated (pairwise `‖kᵢ − kⱼ‖ ≥ δ`) and lie in
`ℝ^d` with `d ≥ 3`, then there is a constant `C(d,δ)` *uniform in `N`* with
`Σᵢ K(q, kᵢ) ≤ C(d,δ)·N^{(d-2)/d}` for every query `q`. The advertised `O(√N)` sparsity is
the **`d = 4` special case** (`(d-2)/d = 1/2`), NOT a dimension-free law.
**Test**: Formalize a shell-counting argument: partition keys by distance band `[rₘ, rₘ₊₁)`;
`δ`-separation caps the count per band by a volume ratio `≈(r/δ)^{d-1}`, and `K` decays like
`1/r²`; integrate `∫ r^{d-1}/(1+r²) dr ≈ ρ^{d-2}` over the filled radius `ρ ≈ δ·N^{1/d}`.
**Disproofs already identified**: (a) in a general/infinite-dimensional normed space the bound
FAILS — infinitely many `δ`-separated unit vectors can be equidistant from `q`, forcing
`Σ = Θ(N)`; (b) as `d → ∞` the exponent `(d-2)/d → 1`, so high-dimensional embeddings erase
the sparsity benefit. Both are concrete falsifications of a naive dimension-free `√N` claim.
**Why now**: `cauchyKernel_active_iff` reduces "active" to ball membership and
`cauchy_total_weight_le` isolates `Σ scores` as the *only* missing ingredient — the entire
claim is now a single, clearly-stated packing lemma. The Lean statement
`cauchy_sublinear_mass_conjecture` already pins down the exact (corrected) exponent.
**If true**: stereographic attention provably beats dense `O(N²)` attention to
`O(N^{1+(d-2)/d})` on geometrically spread tokens in low/moderate dimension, with a fully
verified guarantee — best near `d = 3,4`.
**If false**: the failing configuration pinpoints exactly which token geometries and dimensions
defeat Cauchy sparsity, guiding when to fall back to softmax.

### Direction 2: Lipschitz / robustness of stereographic attention
**Hypothesis**: The map `q ↦ Σᵢ K(q,kᵢ)·vᵢ / Σᵢ K(q,kᵢ)` (Cauchy-normalized value mixture)
is globally Lipschitz in `q` with a constant depending only on `max‖vᵢ‖` and the key
configuration, *without* the exponential blow-up softmax suffers at large logits.
**Test**: Bound `‖∇_q K(q,k)‖ = ‖2(q−k)/(1+‖q−k‖²)²‖ ≤ 3√3/8` (a universal constant!) and
propagate through the quotient rule; compare to softmax's temperature-dependent constant.
**Why now**: `cauchyKernel_pos` guarantees the normalizer never vanishes (the quotient is
always defined), and the closed-form kernel makes the gradient elementary — softmax lacks
both a universal gradient bound and a nonvanishing-denominator guarantee.
**If true**: connects to the catalog's `ResNetLipschitz.lean` line, giving certified-robust
attention layers.
**If false**: locates the configurations where Cauchy attention is as brittle as softmax.

### Direction 3: Universal approximation with Cauchy kernels
**Hypothesis**: Finite Cauchy-kernel attention layers are dense (uniformly on compacts) in
continuous permutation-equivariant maps — matching softmax's universal approximation property.
**Test**: Cauchy kernels `{1/(1+‖·−k‖²)}` are a strictly-positive-definite radial family;
invoke/realize a Stone–Weierstrass or RKHS-density argument that the span separates points and
is closed under the attention pooling. Disproof: a continuous equivariant target provably
outside the closure.
**Why now**: `stereo_chordal_eq_kernel` identifies the kernel as a genuine sphere distance,
so density reduces to density of chordal-distance features on a compact manifold — a setting
where Stone–Weierstrass applies cleanly.
**If true**: stereographic attention loses nothing in expressivity while gaining sparsity.
**If false**: quantifies the expressivity price of built-in sparsity.

### Direction 4: Sharpness of the Markov bound and a two-sided sparsity law
**Hypothesis**: `cauchy_sparsity_markov` is tight: for each `τ ∈ (0,1)` and `N` there exist
keys making `τ·#active` within a `1−o(1)` factor of `Σ scores`; conversely a *lower* bound
`#active ≥ c·(volume of the radius-√(1/τ−1) ball ∩ key support)` holds.
**Test**: Construct the extremal family (keys clustered just inside the activity ball) for
tightness; for the lower bound, combine `cauchyKernel_active_iff` with a counting hypothesis
on key density inside the ball.
**Why now**: the active set is now an *exact* ball (`cauchyKernel_active_iff`), so both the
upper Markov bound and a matching geometric lower bound are expressible with the same primitive.
**If true**: upgrades the one-sided Markov inequality to a genuine sparsity *law* `#active = Θ(...)`.
**If false**: reveals slack in Markov, suggesting a better (e.g. second-moment / Chebyshev) bound.

### Direction 5: Spherical softmax–Cauchy interpolation
**Hypothesis**: The family `K_β(q,k) = 1/(1+‖q−k‖²)^β` interpolates between near-uniform
attention (`β→0`) and a hard nearest-neighbor selector (`β→∞`), with `cauchy_sparsity_markov`
generalizing to `τ·#active ≤ Σ K_β` and the active region remaining a ball of radius
`√((1/τ)^{1/β} − 1)`.
**Test**: Re-run `cauchyKernel_active_iff` and the Markov proof with the exponent `β`;
identify the `β` at which the activity-ball radius matches a target sparsity `√N`.
**Why now**: every lemma this cycle used only `positivity`, monotonicity, and a single
algebraic rearrangement — all of which survive the substitution `(·)²ᵝ`, so the generalization
is low-risk and immediately testable.
**If true**: gives a *tunable* sparsity knob with a closed-form active-radius, unifying soft
and hard attention under one verified geometry.
**If false**: the breakdown exponent marks the boundary of the Cauchy/ball correspondence.
