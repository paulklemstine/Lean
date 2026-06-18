# Future Directions — Stereographic Neural Attention

This cycle replaced the softmax score `exp⟨q,k⟩` with the **Cauchy kernel**
`K(q,k) = 1/(1 + ‖q − k‖²)` and proved, in `MachineLearning/StereographicAttention/Core.lean`,
two intertwined structures. The **geometric** pillar identifies `K` with the conformal factor
of stereographic projection: `stereo_on_sphere` shows the projection lands on the unit sphere
of `E × ℝ`, and `stereo_chordal_eq_kernel` proves the squared chordal distance from `σ(x)` to
the north pole equals `4·K(x,0)` — a Cauchy score literally *is* a distance on the Riemann
sphere. The **analytic** pillar shows sparsity is geometric: `cauchyKernel_active_iff` /
`cauchyKernel_active_closedBall` prove the τ-active key set is *exactly* a Euclidean ball of
radius `√(1/τ − 1)` around the query, while `cauchy_sparsity_markov` (`τ·#active ≤ Σ scores`)
and `cauchy_total_weight_le` (`Σ ≤ N`) combine into `cauchy_sparsity_card_le`
(`τ·#active ≤ N`). The single unproven statement, `cauchy_sublinear_mass_conjecture`, isolates
the entire `√N` gap into one packing inequality. The directions below are testable, falsifiable,
and each builds directly on a proven lemma.

## Direction 1 — The sublinear total-mass law for separated keys

**Conjecture.** If keys `k₁,…,k_N` are `δ`-separated and lie in `ℝ^d` with `d ≥ 3`, there is a
constant `C(d,δ)` *uniform in `N`* with `Σᵢ K(q,kᵢ) ≤ C·N^{(d−2)/d}` for every query `q`; the
advertised `O(√N)` sparsity is the **`d = 4` special case** (`(d−2)/d = 1/2`), not a
dimension-free law. **Test.** Formalize a shell-counting argument: partition keys by distance
band `[rₘ, rₘ₊₁)`; `δ`-separation caps the per-band count by a volume ratio `≈ (r/δ)^{d−1}`,
and `K` decays like `1/r²`, so `∫ r^{d−1}/(1+r²) dr ≈ ρ^{d−2}` over the filled radius
`ρ ≈ δ·N^{1/d}`. **Falsifiers already identified.** (a) In an infinite-dimensional normed space
the bound fails — infinitely many `δ`-separated unit vectors can be equidistant from `q`,
forcing `Σ = Θ(N)`; (b) as `d → ∞` the exponent `(d−2)/d → 1`, erasing the benefit. **The key
insight is** that `cauchyKernel_active_iff` reduces "active" to ball membership and
`cauchy_total_weight_le` isolates `Σ scores` as the *only* missing ingredient, so the whole
claim collapses to a single packing lemma whose exponent is already pinned down in
`cauchy_sublinear_mass_conjecture`. **Why now:** the Lean scaffolding already states the exact
corrected exponent and reduces the problem to bounding `Σ scores`; nothing else stands in the
way. **If true:** stereographic attention provably beats dense `O(N²)` attention to
`O(N^{1+(d−2)/d})` on spread tokens in low/moderate dimension, with a verified guarantee.

## Direction 2 — Lipschitz robustness of stereographic attention

**Conjecture.** The Cauchy-normalized value mixture `q ↦ Σᵢ K(q,kᵢ)·vᵢ / Σᵢ K(q,kᵢ)` is
globally Lipschitz in `q` with constant depending only on `max‖vᵢ‖` and the key configuration —
*without* the exponential blow-up softmax suffers at large logits. **Test.** Bound the kernel
gradient `‖∇_q K(q,k)‖ = ‖2(q−k)/(1+‖q−k‖²)²‖ ≤ 3√3/8` (a universal constant) and propagate
through the quotient rule, comparing against softmax's temperature-dependent constant. **The key
insight is** that `cauchyKernel_pos` guarantees the normalizer never vanishes, so the quotient
is everywhere differentiable and the gradient is elementary and globally bounded — two
properties softmax lacks. **Why now:** the closed-form kernel and the proven strict positivity
make the gradient bound a finite calculus computation rather than a limiting argument.
**If true:** connects to the catalog's `ResNetLipschitz.lean` line, yielding certified-robust
attention layers. **If false:** the failing configuration locates exactly when Cauchy attention
is as brittle as softmax.

## Direction 3 — Universal approximation with Cauchy kernels

**Conjecture.** Finite Cauchy-kernel attention layers are dense (uniformly on compacts) in
continuous permutation-equivariant maps, matching softmax's universal approximation property.
**Test.** Cauchy kernels `{1/(1+‖·−k‖²)}` form a strictly-positive-definite radial family;
realize a Stone–Weierstrass / RKHS-density argument that their span separates points and is
closed under attention pooling, and disprove by exhibiting a continuous equivariant target
outside the closure. **The key insight is** that `stereo_chordal_eq_kernel` identifies the
kernel as a genuine sphere distance, so density reduces to density of chordal-distance features
on a compact manifold — exactly where Stone–Weierstrass applies cleanly. **Why now:** the
geometric identity proved this cycle converts an opaque approximation question into a classical
density statement on a compact metric space. **If true:** built-in sparsity costs no
expressivity. **If false:** quantifies the expressivity price of sparsity.

## Direction 4 — Sharpness of the Markov bound and a two-sided sparsity law

**Conjecture.** `cauchy_sparsity_markov` is tight: for each `τ ∈ (0,1)` and `N` there exist keys
making `τ·#active` within a `1−o(1)` factor of `Σ scores`; conversely a *lower* bound
`#active ≥ c·(vol of the radius-√(1/τ−1) ball ∩ key support)` holds. **Test.** Build the
extremal family (keys clustered just inside the activity ball) for tightness, and combine
`cauchyKernel_active_iff` with a key-density hypothesis inside the ball for the lower bound.
**The key insight is** that the active set is now an *exact* ball, so both the upper Markov
bound and a matching geometric lower bound speak about the same primitive and can be glued into
a genuine sparsity law `#active = Θ(...)`. **Why now:** with the active region pinned to a metric
ball this cycle, the lower bound becomes a volume/counting statement rather than an analytic
one. **If true:** upgrades the one-sided Markov inequality to a two-sided law. **If false:**
reveals slack in Markov, pointing to a second-moment (Chebyshev) refinement.

## Direction 5 — Spherical softmax–Cauchy interpolation

**Conjecture.** The family `K_β(q,k) = 1/(1+‖q−k‖²)^β` interpolates between near-uniform
attention (`β→0`) and a hard nearest-neighbor selector (`β→∞`), with `cauchy_sparsity_markov`
generalizing to `τ·#active ≤ Σ K_β` and the active region remaining a ball of radius
`√((1/τ)^{1/β} − 1)`. **Test.** Re-run `cauchyKernel_active_iff` and the Markov proof with the
exponent `β`, then solve for the `β` whose activity-ball radius matches a target sparsity `√N`.
**The key insight is** that every lemma this cycle used only positivity, monotonicity, and a
single algebraic rearrangement — all of which survive the substitution `(·)^{2β}`, so the
generalization is low-risk and immediately testable. **Why now:** the proofs are structurally
robust to the exponent change, so a tunable sparsity knob with a closed-form active radius is
within immediate reach. **If true:** unifies soft and hard attention under one verified
geometry with a single dial. **If false:** the breakdown exponent marks the boundary of the
Cauchy/ball correspondence.
