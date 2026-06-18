# Future Directions: Inverse Stereographic Renormalization Group

The file `Catalog/Geometry/IsingStereoRG.lean` establishes the first rigorous, machine-checked
bridge between renormalization-group (RG) flow and stereographic/conformal geometry, in the
exactly solvable 1D Ising model. It proves that Kadanoff decimation is the quadratic map
`x ↦ x²` in the variable `x = tanh K`, that its eigenvalue at the ordered fixed point is exactly
the rescaling factor `2` (hence `ν = 1`), and that the second stereographic coordinate is the
Cayley transform of the decimation map. These results extend the Möbius/pole-map theory in
`Catalog/Geometry/StereographicRG.lean` (`moebiusF'`, `deriv_moebiusF'_formula`,
`conformal_factor_le_two`) and the projection identities in
`Catalog/Geometry/InverseStereoResearch.lean` (`inv_stereo_on_circle`, `inv_stereo_injective`).
Below are concrete, falsifiable directions that the next cycle should attack.

## 1. Conjugacy of decimation to angle-doubling on the projected circle

The decimation map `x ↦ x²` becomes, on the projected circle, a genuine conformal map. We
conjecture there is an explicit smooth conjugacy `h` with `h ∘ isingRG = D ∘ h`, where `D` is a
fixed Möbius/rotation-type map of `S¹` drawn from the `moebiusF'` family of `StereographicRG.lean`,
so that decimation is *linearized* on the circle. **The key insight is** that squaring in the
half-tangent variable is exactly angle-related on the circle, so the RG semigroup `rgIter` should
be conjugate to iterated composition of a single `moebiusF'` map with fixed poles. **Why now?**
Both halves now exist and are formalized in the same library — the Ising recursion here and the
two-pole Möbius calculus in `StereographicRG.lean` — so the conjugacy is a finite algebraic
identity well within reach of the existing `grind`/`field_simp` machinery.

## 2. Universality: every quadratic decimation gives `ν = 1` via `logb` of the multiplier

We proved `ising_correlation_length_exponent : Real.logb 2 (deriv isingRG 1) = 1`. Conjecture: for
*any* rescaling factor `b ≥ 2`, the corresponding decimation map (`x ↦ x^b`) has ordered-fixed-point
multiplier `b`, hence `Real.logb b (deriv (fun x => x^b) 1) = 1` and `ν = 1` independent of `b`.
**The key insight is** that `deriv (x^b) 1 = b` exactly, so the thermal exponent `log_b(b) = 1` is a
`logb_self_eq_one` tautology, proving block-size independence of the 1D exponent rigorously.
**Why now?** The `deriv_isingRG`/`Real.logb_self_eq_one` proof pattern generalizes verbatim, so a
single parametric theorem `correlation_length_exponent_universal (b : ℕ) (hb : 2 ≤ b)` is a small
extension that turns a one-off computation into a universality statement.

## 3. The beta-function/projection-derivative identity beyond the fixed point

`eigenvalue_eq_one_add_beta_deriv` proves the RG multiplier equals `1 + β'(x)` everywhere, not just
at fixed points. Conjecture: the *conformal factor* of the projected flow, `conformalFactor`, is the
geometric carrier of `β` — specifically that `deriv (fun x => (invStereo (isingRG x)).2) x` factors
through `conformalFactor (isingRG x)` times `β'`-data, giving a coordinate-free "beta equals
projection derivative" statement. **The key insight is** that the Cayley identity
`stereo_snd_eq_cayley_isingRG` turns RG flow into motion on `S¹`, where the only scale is the
conformal factor, so `β` must reappear as a circle-velocity. **Why now?** `deriv_stereo_fst_at_zero`
shows the conformal factor is already computable as a derivative in Lean; chaining it with
`deriv_betaIsing` via the chain rule is the natural next composition.

## 4. Möbius cocycle for multi-step decimation matches `rgUpdate_composition`

Iterating decimation `n` times sends `x ↦ x^(2^n)`. Conjecture: under the Cayley/stereographic
change of variables this `n`-step flow equals a *composition* of `moebiusF'` maps obeying the
transitivity law `rgUpdate_composition` already proven in `StereographicRG.lean`, so the RG
semigroup embeds as a sub-semigroup of the two-pole Möbius group with a closed-form cocycle for the
accumulated conformal factor `∏ conformalFactor`. **The key insight is** that decimation eigenvalues
multiply (`2^n`) exactly as Möbius multipliers compose, matching `rgUpdate_det = (1+a²)(1+b²)`.
**Why now?** `rgIter` and `rgUpdate_composition` are formalized and `rgIter_zero/one` give the base
cases, so an induction on `n` connecting `isingRG^[n]` to iterated `moebiusF'` is structurally ready.

## 5. Failure boundary: the bridge breaks for `x < 0` and complex couplings

The Cayley identity and circle membership hold for all real `x`, but the *physical* coupling region
is `x ∈ [0,1]`. Conjecture (falsifiable boundary case): for `x < 0` the decimation orbit still lands
on `S¹` (so `invStereo_on_circle` is robust) yet the monotone RG-flow interpretation fails because
`betaIsing` changes sign at `x = 1/2` (the zero of `deriv_betaIsing`), marking the crossover between
the two basins. **The key insight is** that `deriv betaIsing x = 2x − 1` vanishes exactly at the
midpoint `x = 1/2`, which is the geometric watershed between the disordered and ordered basins.
**Why now?** `deriv_betaIsing` is already proven, so locating and characterizing the `x = 1/2`
watershed — and showing the projected picture survives where the flow interpretation does not — is an
immediate, sharply testable corollary that delimits exactly where the conformal/RG dictionary holds.
