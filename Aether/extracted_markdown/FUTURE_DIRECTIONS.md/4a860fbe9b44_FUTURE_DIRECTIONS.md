# Future Directions: Inverse Stereographic Renormalization Group

## Synthesis

This cycle establishes, in fully machine-checked Lean 4, a bridge between renormalization-group
(RG) flow for the exactly solvable 1D Ising model and stereographic/conformal geometry. Working
in the natural variable `x = tanh K`, Kadanoff decimation (block size `b = 2`) is exactly the
quadratic map `isingRG x = x²`, whose discrete beta function is `betaIsing x = x² − x`. The
central physical payoff is the correlation-length exponent: the RG multiplier at the ordered fixed
point `x = 1` is exactly the rescaling factor `2`, so `ν = logb 2 (deriv isingRG 1) = 1`. The
decisive structural observation is that this is not a numerical accident but a *logarithm
tautology* `logb b b = 1` — the multiplier equals the block size **by construction**. That
observation immediately generalized into a genuine universality theorem
(`correlation_length_exponent_universal`): for *every* block size `b ≥ 2`, the decimation
`x ↦ x^b` has ordered multiplier `b` and therefore `ν = 1`, independent of `b`. A one-off
computation became a theorem schema.

Two further structural insights emerged. First, the linear-response identity
`deriv isingRG x = 1 + deriv betaIsing x` holds *everywhere*, not only at fixed points — the RG
eigenvalue is literally "one plus the beta-velocity". Second, the beta function has a watershed:
`betaIsing_watershed` proves `β'(x) = 0 ↔ x = 1/2`, exactly the unstable separatrix between the
disordered basin (`x → 0`) and the ordered basin (`x → 1`). The Critic's boundary analysis here
is sharp: the *conformal* picture is more robust than the *flow* picture. We proved
`invStereo_isingRG_on_circle` for **all** real `x` (the decimated coupling always lands on `S¹`),
while the monotone RG-flow reading is only valid on the physical region `x ∈ [0,1]`. The Cayley
identity `stereo_snd_isingRG` makes the geometric content explicit: the projected second
coordinate is the Cayley transform `(1−y)/(1+y)` at `y = x⁴`.

What failed/was avoided: a direct `deriv_sub`/`fun_prop` attack on `betaIsing` stalled on the
lambda binder; the explicit `HasDerivAt` builder `(hasDerivAt_pow 2 x).sub (hasDerivAt_id x)`
succeeded and is the recommended pattern for the next cycle's chain-rule compositions. The
deepest open structural question that this cycle could not close is whether decimation is
*conjugate* to a fixed Möbius map on the projected circle — the squaring-as-angle-doubling
conjecture below — which would linearize the entire RG semigroup.

## Results Summary

- `deriv_isingRG`: proved — the decimation multiplier is `2x`, the engine of every eigenvalue computation.
- `isingRG_eigenvalue_ordered`: proved — the ordered-fixed-point multiplier is exactly the block size `2`.
- `ising_correlation_length_exponent`: proved — the 1D Ising correlation-length exponent is `ν = 1`.
- `correlation_length_exponent_universal`: proved — `ν = 1` for **every** block size `b ≥ 2`; block-size independence is a universality theorem, not a coincidence.
- `deriv_betaIsing`: proved — the discrete beta function has derivative `2x − 1`.
- `eigenvalue_eq_one_add_beta_deriv`: proved — the RG multiplier equals `1 + β'(x)` globally, a coordinate-free linear-response identity.
- `betaIsing_watershed`: proved — `β'(x) = 0 ↔ x = 1/2`, locating the basin separatrix exactly at the midpoint.
- `isingRG_fixed_points`: proved — the RG fixed set is exactly `{0, 1}`, the pre-images of the stereographic special points `(0,1)` and `(1,0)`.
- `invStereo_isingRG_on_circle`: proved — the decimated coupling projects onto `S¹` for all real `x`; the conformal picture is robust beyond the physical region.
- `stereo_snd_isingRG`: proved — Cayley identity: the projected second coordinate is `(1 − x⁴)/(1 + x⁴)`.

## Research Directions

### Direction 1: Conjugacy of decimation to angle-doubling on the circle
**Hypothesis**: There is an explicit smooth conjugacy `h` and a fixed Möbius/rotation map `D` of
`S¹` with `h ∘ isingRG = D ∘ h`, so that the RG semigroup `isingRG^[n]` is linearized to iterated
composition of a single circle map.
**Test**: Construct `h` (the half-tangent / arctan change of variables) and verify the functional
equation `h (x²) = D (h x)` as a finite algebraic identity via `field_simp`/`ring`; disproof would
be a real `x` where the identity fails.
**Why now**: `stereo_snd_isingRG` already exhibits decimation as the Cayley transform at `y = x⁴`,
i.e. as motion on `S¹`; only the explicit angle coordinate is missing.
**If true**: The entire 1D RG flow becomes a single linear circle dynamic, giving closed forms for
all multi-step flows.
**If false**: Squaring is genuinely nonlinear on the circle and the conformal dictionary is only
infinitesimal, which would itself sharpen the scope of the bridge.

### Direction 2: Non-integer and continuous block sizes
**Hypothesis**: `correlation_length_exponent_universal` extends from `b : ℕ` to real `b > 1`:
`deriv (fun x => x ^ (b:ℝ)) 1 = b` (real rpow power rule) and hence `logb b (deriv …) = 1`.
**Test**: Replace `Monoid.npow` by `Real.rpow`, prove the derivative-at-1 with
`Real.hasDerivAt_rpow_const`, and reuse `logb_self_eq_one`.
**Why now**: The proof of the natural-number version is a two-line schema; only the power rule
lemma changes for real exponents.
**If true**: `ν = 1` holds on a continuum of block sizes, the cleanest possible statement of 1D
block-size independence.
**If false**: The integer structure of decimation is essential, pinpointing where universality
needs discreteness.

### Direction 3: Beta as a circle-velocity (coordinate-free linear response)
**Hypothesis**: `deriv (fun x => (invStereo (isingRG x)).2) x` factors as a conformal factor
times `β'`-data, giving a coordinate-free "beta equals projection derivative" identity.
**Test**: Differentiate `stereo_snd_isingRG`'s right-hand side `(1−x⁴)/(1+x⁴)` and compare with
`deriv_betaIsing` multiplied by the conformal factor of `S¹`; confirm or refute the factorization
pointwise.
**Why now**: Both `stereo_snd_isingRG` and `deriv_betaIsing` are in hand; the chain rule via the
`HasDerivAt` builder pattern is the only remaining step.
**If true**: `β` is recognized as the velocity of the projected point on `S¹`, a fully geometric
reading of the RG flow.
**If false**: The conformal factor carries extra scale information not reducible to `β`, which
would reveal a second invariant of the flow.

### Direction 4: Multi-step cocycle for iterated decimation
**Hypothesis**: `isingRG^[n] x = x^(2^n)`, and under the Cayley change of variables this `n`-step
flow is a composition of fixed circle maps with a closed-form accumulated conformal factor
`∏ conformalFactor`.
**Test**: Prove `isingRG^[n] x = x ^ (2 ^ n)` by induction (base `rfl`, step uses `pow_mul`), then
push through `invStereo` to read off the product cocycle.
**Why now**: The single-step Cayley identity and fixed points are proved; the induction skeleton is
immediate from `Function.iterate_succ`.
**If true**: The RG semigroup embeds as an explicit sub-semigroup of the Möbius group with a
multiplicative multiplier `2^n`.
**If false**: Iteration introduces corrections beyond pure squaring, isolating the failure of the
semigroup embedding.

### Direction 5: Failure boundary for `x < 0` and the watershed
**Hypothesis**: For `x < 0` the decimation orbit still lands on `S¹` (so
`invStereo_isingRG_on_circle` is robust) **yet** the monotone RG-flow interpretation fails because
`betaIsing` changes sign at the watershed `x = 1/2`; characterize the two basins of attraction of
`isingRG^[n]` as `(−1,1) → 0` and `{±1} → 1`, with `|x| > 1` escaping to `+∞`.
**Test**: Prove `|x| < 1 → isingRG^[n] x → 0` and `|x| > 1 → isingRG^[n] x → ∞` (geometric decay
/ growth of `x^(2^n)`); the watershed `betaIsing_watershed` marks where the *physical* monotone
reading breaks.
**Why now**: `betaIsing_watershed` pins the separatrix at `x = 1/2` and `invStereo_isingRG_on_circle`
already shows geometric robustness for all `x`; the convergence claims are standard `x^(2^n)` limits.
**If true**: Exactly delimits where the conformal/RG dictionary is a genuine flow versus a purely
geometric projection.
**If false**: The flow interpretation survives outside `[0,1]`, extending the physical region of the
bridge.
