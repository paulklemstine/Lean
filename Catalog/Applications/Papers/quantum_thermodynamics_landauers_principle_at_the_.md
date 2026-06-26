# THEOREM TRACE (internal — anti-hallucination ledger)

Every theorem/definition referenced in ARTICLE.md and RESEARCH_PAPER.md is listed
here with its exact Lean name and mathematical statement. No result is stated in the
prose that does not appear below.

## Catalog/Logic/JarzynskiLandauer.lean
- `expect` (def): `expect p f = ∑ ω, p ω * f ω`.
- `IsPMF` (def): `(∀ ω, 0 ≤ p ω) ∧ ∑ ω, p ω = 1`.
- `JarzynskiCondition` (def): `E[exp(-α W)] = exp(-α ΔF)`.
- `shannonEntropy` (def): `∑ ω, negMulLog (p ω)`, i.e. `-∑ p log p`.
- `uniformBool` (def): `fun _ => 1/2`.
- `erasedBool` (def): `fun b => if b then 0 else 1`.
- `erasure` (def): `fun _ => false`.
- `entropy_uniformBool`: `shannonEntropy uniformBool = log 2`.
- `entropy_erasedBool`: `shannonEntropy erasedBool = 0`.
- `erasure_not_injective`: `¬ Injective erasure`.
- `entropy_loss`: `shannonEntropy uniformBool - shannonEntropy erasedBool = log 2`.
- `jarzynski_correction`: `E[W] = ΔF + α⁻¹ log E[exp(-α(W-E[W]))]`.
- `landauer_identity`: same with `ΔF = (H(uniform)-H(erased))/α`.

## Catalog/Physics/LandauerSecondLaw.lean
- `expect_add_one_le_expect_exp`: `1 + E[g] ≤ E[exp g]`.
- `expect_centered_zero`: `E[-α(W-E[W])] = 0`.
- `work_fluctuation_ge_one`: `1 ≤ E[exp(-α(W-E[W]))]`.
- `work_correction_nonneg`: `0 ≤ log E[exp(-α(W-E[W]))]`.
- `jarzynski_second_law`: `α>0 ⇒ ΔF ≤ E[W]`.
- `landauer_kT_bound`: `k,T>0 ⇒ k·T·log 2 ≤ E[W]`.
- `landauer_cost_eq_entropy_loss`: `k·T·log 2 = k·T·(H(uniform)-H(erased))`.
- `logical_to_thermodynamic_irreversibility`: `¬Injective erasure ∧ 0 < E[W]`.

## Catalog/Physics/LandauerThermodynamicLimit.lean
- `entropy_uniform`: uniform on N states has entropy `log N`.
- `entropy_uniform_pow_two`: uniform on `2^n` states has entropy `n log 2`.
- `entropy_uniform_bits`: uniform on `Fin n → Bool` has entropy `n log 2`.
- `landauer_nbit_work_bound`: `n·k·T·log 2 ≤ E[W]`.
- `landauer_per_bit_cost`: `(n·k·T·log 2)/n = k·T·log 2`.

## Catalog/Computation/LandauerLowerBound.lean
- `pushforwardFun` (def): image measure `f∗p (y) = ∑_{f x = y} p x`.
- `pushforwardFun_apply_ge`: `p x ≤ f∗p (f x)`.
- `pushforwardFun_isDistribution`: pushforward of a distribution is a distribution.
- `shannonEntropy_pushforward_le`: data-processing `H(f∗p) ≤ H(p)`.
- `shannonEntropy_pushforward_of_injective`: injective `f ⇒ H(f∗p) = H(p)`.
- `landauer_lower_bound`: `0 ≤ k·T·(H(p) - H(f∗p))`.
- `landauer_lower_bound_zero_of_injective`: injective `f ⇒` cost `= 0`.

## Catalog/Physics/LandauerRelativeEntropy.lean (Phase A new file)
- `relativeEntropy` (def): `D(p‖q) = ∑ ω, p ω · log(p ω / q ω)`.
- `relativeEntropy_self`: `D(p‖p) = 0`.
- `relativeEntropy_nonneg`: Gibbs' inequality `0 ≤ D(p‖q)` for PMFs with `q>0`.
- `relativeEntropy_erased_uniform`: `D(erased‖uniform) = log 2`.
- `relativeEntropy_eq_entropy_loss`: `D(erased‖uniform) = H(uniform) - H(erased)`.
- `landauer_cost_eq_relative_entropy`: `k·T·log 2 = k·T·D(erased‖uniform)`.
- `landauer_work_nonneg_via_gibbs`: `0 ≤ k·T·D(p‖q)`.

## Catalog/Physics/LandauerSaturation.lean (Phase A new file; partially shown)
- `expect_add_one_lt_expect_exp`: strict Jensen `1 + E[g] < E[exp g]` when `g`
  is nonzero somewhere on the support.
- `work_correction_zero_iff` (named in Future Directions): the Jarzynski
  fluctuation correction vanishes iff the work has no fluctuations on the support
  (W almost surely constant) — i.e. Landauer's bound is saturated iff reversible.
