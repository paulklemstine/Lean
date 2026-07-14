/-
# A Concrete Guesswork Model for the Exact Coset Exponent (maximal-entropy source)

## Overview

The companion development `CosetGuesswork` established the *exact exponent shift* for
constrained coset guesswork **abstractly**: it postulated an unconstrained `ρ`-th moment
sequence `Gunc(n)` with the Arıkan–Merhav growth rate and derived that the coset-density
compression `2^{-ρ(1-R)n}` lowers the exponent by exactly `ρ(1-R)`.

This file **deepens** that result by *removing the hypothesis* at the maximal-entropy
(symmetric) source `p = 1/2`: instead of assuming a sequence with the right growth rate,
we **construct** the guesswork moment from first principles and **prove** the growth rate.

For the symmetric Bernoulli(`1/2`) source all `2^n` noise vectors are equally likely, so an
optimal adversary guessing over a set of `N` equiprobable candidates realises the guessing
ranks `1, 2, …, N`, and the `ρ`-th moment is the exact average

  `M(N) = (1/N) · Σ_{k=1}^{N} k^ρ`.

*Unconstrained* guessing has `N = 2^m`; *constrained* coset guessing over a rate-`R` code has
`N = 2^{k_m}` with `k_m / m → R`. The elementary two-sided estimate

  `(N/2)^{ρ+1} ≤ Σ_{k=1}^{N} k^ρ ≤ N^{ρ+1}`

pins the growth rate of `Σ` at `ρ+1`, hence the moment `M(2^{k_m})` has growth rate

  `(1/m) log₂ M(2^{k_m}) → ρ · R`.

Since the Arıkan–Merhav exponent at `p = 1/2` equals `ρ` (`amExponent_half`), this is exactly

  `E_coset(ρ, R, 1/2) = ρR = amExponent ρ (1/2) - ρ(1-R)`,

i.e. the exact downward shift `ρ(1-R)`, now *derived* rather than *assumed*.

## The chain of results

* `amExponent_half`        — the Arıkan–Merhav exponent at `p = 1/2` is `ρ`.
* `powSum_pos`             — the power-sum `Σ_{k=1}^{N} k^ρ` is positive.
* `powSum_upper`           — `Σ_{k=1}^{2^j} k^ρ ≤ 2^{j(ρ+1)}`.
* `powSum_lower`           — `2^{(j-1)(ρ+1)} ≤ Σ_{k=1}^{2^j} k^ρ`.
* `powSum_logb_bounds`     — the logarithmic sandwich `(j-1)(ρ+1) ≤ log₂ Σ ≤ j(ρ+1)`.
* `cosetMoment_rate`       — **main theorem**: constrained coset moment has rate `ρR`.
* `unifMoment_rate`        — unconstrained moment has rate `ρ` (special case `R = 1`).
* `unifMoment_rate_am`     — the unconstrained rate equals `amExponent ρ (1/2)`.
* `cosetMoment_rate_am`    — the constrained rate equals `amExponent ρ (1/2) - ρ(1-R)`.
* `exact_exponent_shift`   — the unconstrained and constrained rates differ by exactly `ρ(1-R)`.
-/
import Mathlib

open Real Filter Topology
open scoped BigOperators

namespace CosetGuessworkExact

/-! ## The Arıkan–Merhav exponent at the symmetric source -/

/-- The Arıkan–Merhav guessing exponent for an i.i.d. Bernoulli(`p`) source,
`(1+ρ) log₂ (p^{1/(1+ρ)} + (1-p)^{1/(1+ρ)})`. -/
noncomputable def amExponent (ρ p : ℝ) : ℝ :=
  (1 + ρ) * Real.logb 2 (p ^ (1 / (1 + ρ)) + (1 - p) ^ (1 / (1 + ρ)))

/-
**The Arıkan–Merhav exponent at `p = 1/2` is `ρ`.** At the maximal-entropy source the
guessing task is hardest and the exponent saturates.
-/
theorem amExponent_half (ρ : ℝ) (hρ : 0 < ρ) : amExponent ρ (1 / 2) = ρ := by
  unfold amExponent;
  norm_num [ Real.div_rpow ];
  rw [ show ( 2 ^ ( 1 + ρ ) ⁻¹ : ℝ ) ⁻¹ + ( 2 ^ ( 1 + ρ ) ⁻¹ : ℝ ) ⁻¹ = 2 ^ ( 1 - ( 1 + ρ ) ⁻¹ ) by rw [ Real.rpow_sub two_pos ] ; norm_num ; ring, Real.logb_rpow ] <;> norm_num ; nlinarith [ inv_mul_cancel₀ ( by linarith : ( 1 + ρ ) ≠ 0 ) ]

/-! ## The power-sum `Σ_{k=1}^{N} k^ρ` -/

/-- The power-sum `Σ_{k=1}^{N} k^ρ`, indexed as `Σ_{k=0}^{N-1} (k+1)^ρ`. -/
noncomputable def powSum (ρ : ℝ) (N : ℕ) : ℝ :=
  ∑ k ∈ Finset.range N, ((k : ℝ) + 1) ^ ρ

/-
The power-sum over a nonempty range is positive.
-/
theorem powSum_pos (ρ : ℝ) (N : ℕ) (hN : 1 ≤ N) : 0 < powSum ρ N := by
  exact Finset.sum_pos ( fun _ _ => by positivity ) ( by aesop )

/-
**Upper bound.** Every one of the `2^j` terms is at most `(2^j)^ρ`, so
`Σ_{k=1}^{2^j} k^ρ ≤ 2^{j(ρ+1)}`.
-/
theorem powSum_upper (ρ : ℝ) (hρ : 0 ≤ ρ) (j : ℕ) :
    powSum ρ (2 ^ j) ≤ (2 : ℝ) ^ ((j : ℝ) * (ρ + 1)) := by
  refine' le_trans ( Finset.sum_le_sum fun i hi => Real.rpow_le_rpow ( by positivity ) ( show ( i + 1 : ℝ ) ≤ 2 ^ j by exact_mod_cast Finset.mem_range.mp hi ) ( by positivity ) ) _ ; norm_num [ pow_add, pow_mul ];
  rw [ ← Real.rpow_natCast, ← Real.rpow_mul, ← Real.rpow_add ] <;> norm_num ; ring_nf ; norm_num

/-
**Lower bound.** The top half of the range (`2^{j-1}` terms, each at least `(2^{j-1})^ρ`)
already gives `2^{(j-1)(ρ+1)} ≤ Σ_{k=1}^{2^j} k^ρ`.
-/
theorem powSum_lower (ρ : ℝ) (hρ : 0 ≤ ρ) (j : ℕ) (hj : 1 ≤ j) :
    (2 : ℝ) ^ (((j : ℝ) - 1) * (ρ + 1)) ≤ powSum ρ (2 ^ j) := by
  refine' le_trans _ ( Finset.sum_le_sum_of_subset_of_nonneg _ fun _ _ _ => Real.rpow_nonneg ( by positivity ) _ );
  case refine'_2 => exact Finset.Ico ( 2 ^ ( j - 1 ) ) ( 2 ^ j );
  · refine' le_trans _ ( Finset.sum_le_sum fun i hi => Real.rpow_le_rpow ( by positivity ) ( show ( i : ℝ ) + 1 ≥ 2 ^ ( j - 1 ) by exact_mod_cast le_trans ( by aesop ) ( Nat.succ_le_succ ( Finset.mem_Ico.mp hi |>.1 ) ) ) ( by positivity ) ) ; norm_num;
    rw [ Nat.cast_sub ( Nat.pow_le_pow_right ( by decide ) ( Nat.sub_le _ _ ) ) ] ; cases j <;> norm_num [ pow_succ' ] at * ; ring_nf;
    rw [ ← Real.rpow_natCast, ← Real.rpow_mul ( by positivity ), ← Real.rpow_add ( by positivity ) ] ; ring_nf ; norm_num;
  · exact fun x hx => Finset.mem_range.mpr ( Finset.mem_Ico.mp hx |>.2 )

/-
**Logarithmic sandwich for the power-sum.** Combining the two bounds:
`(j-1)(ρ+1) ≤ log₂ Σ_{k=1}^{2^j} k^ρ ≤ j(ρ+1)`.
-/
theorem powSum_logb_bounds (ρ : ℝ) (hρ : 0 ≤ ρ) (j : ℕ) (hj : 1 ≤ j) :
    ((j : ℝ) - 1) * (ρ + 1) ≤ Real.logb 2 (powSum ρ (2 ^ j)) ∧
      Real.logb 2 (powSum ρ (2 ^ j)) ≤ (j : ℝ) * (ρ + 1) := by
  grind +suggestions

/-! ## The guesswork moment and its exponential growth rate -/

/-- The `ρ`-th guesswork moment for a uniform source guessing over `2^k` equiprobable
candidates: `M = 2^{-k} · Σ_{j=1}^{2^k} j^ρ`. For the symmetric Bernoulli(`1/2`) source with
a rate-`R` code, `k = k_m ≈ Rm` is the number of message bits (coset dimension). -/
noncomputable def cosetMoment (ρ : ℝ) (kn : ℕ → ℕ) (m : ℕ) : ℝ :=
  (2 : ℝ) ^ (-(kn m : ℝ)) * powSum ρ (2 ^ kn m)

/-
**Main theorem: exact constrained coset exponent at the symmetric source.**

Let `kn m` be the coset dimension of a rate-`R` code (so `kn m / m → R` and `kn m → ∞`).
Then the constrained coset guesswork moment has exponential growth rate exactly `ρ · R`:

  `(1/m) log₂ ( 2^{-k_m} Σ_{j=1}^{2^{k_m}} j^ρ ) → ρ R`.

This *constructs* the moment sequence and *proves* its rate, replacing the abstract hypothesis
of the companion development.
-/
theorem cosetMoment_rate (ρ R : ℝ) (hρ : 0 < ρ) (kn : ℕ → ℕ)
    (htop : Tendsto kn atTop atTop)
    (hR : Tendsto (fun m : ℕ => (kn m : ℝ) / (m : ℝ)) atTop (𝓝 R)) :
    Tendsto (fun m : ℕ => (1 / (m : ℝ)) * Real.logb 2 (cosetMoment ρ kn m)) atTop
      (𝓝 (ρ * R)) := by
  -- By definition of $f_m$, we have:
  have hf_def : ∀ m, 1 ≤ (kn m) → (1 / (m : ℝ)) * Real.logb 2 (cosetMoment ρ kn m) ≤ ((kn m : ℝ)) / (m : ℝ) * ρ ∧ ((kn m : ℝ)) / (m : ℝ) * ρ - (ρ + 1) * (1 / (m : ℝ)) ≤ (1 / (m : ℝ)) * Real.logb 2 (cosetMoment ρ kn m) := by
    intro m hm
    have h_log : Real.logb 2 (cosetMoment ρ kn m) = -(kn m : ℝ) + Real.logb 2 (powSum ρ (2 ^ kn m)) := by
      unfold cosetMoment;
      rw [ Real.logb_mul ( by positivity ) ( by exact ne_of_gt ( powSum_pos _ _ ( Nat.one_le_pow _ _ ( by positivity ) ) ) ), Real.logb_rpow ] <;> norm_num;
    have := powSum_logb_bounds ρ ( by linarith ) ( kn m ) hm; ( ring_nf at *; constructor <;> nlinarith [ inv_nonneg.2 ( show ( 0 :ℝ ) ≤ m by positivity ) ] ; );
  -- By the squeeze theorem, it follows that:
  have h_squeeze : Filter.Tendsto (fun m => ((kn m : ℝ)) / (m : ℝ) * ρ) Filter.atTop (nhds (R * ρ)) ∧ Filter.Tendsto (fun m => ((kn m : ℝ)) / (m : ℝ) * ρ - (ρ + 1) * (1 / (m : ℝ))) Filter.atTop (nhds (R * ρ)) := by
    exact ⟨ hR.mul tendsto_const_nhds, by simpa using hR.mul tendsto_const_nhds |> Filter.Tendsto.sub <| tendsto_const_nhds.mul tendsto_inv_atTop_nhds_zero_nat ⟩;
  rw [ mul_comm ρ R ] ; exact tendsto_of_tendsto_of_tendsto_of_le_of_le' h_squeeze.2 h_squeeze.1 ( Filter.eventually_atTop.mpr <| by rcases Filter.eventually_atTop.mp ( htop.eventually_ge_atTop 1 ) with ⟨ m, hm ⟩ ; exact ⟨ m, fun n hn ↦ by linarith [ hf_def n <| hm n hn ] ⟩ ) ( Filter.eventually_atTop.mpr <| by rcases Filter.eventually_atTop.mp ( htop.eventually_ge_atTop 1 ) with ⟨ m, hm ⟩ ; exact ⟨ m, fun n hn ↦ by linarith [ hf_def n <| hm n hn ] ⟩ ) ;

/-- **Unconstrained rate (special case `R = 1`).** Guessing over the full noise space
(`kn m = m`, coset dimension equal to the block length) has growth rate exactly `ρ`. -/
theorem unifMoment_rate (ρ : ℝ) (hρ : 0 < ρ) :
    Tendsto (fun m : ℕ => (1 / (m : ℝ)) * Real.logb 2 (cosetMoment ρ id m)) atTop
      (𝓝 ρ) := by
  have hR : Tendsto (fun m : ℕ => ((id m : ℕ) : ℝ) / (m : ℝ)) atTop (𝓝 1) := by
    apply Tendsto.congr' _ (tendsto_const_nhds)
    filter_upwards [eventually_gt_atTop 0] with m hm
    have : (m : ℝ) ≠ 0 := by exact_mod_cast hm.ne'
    simp [id, div_self this]
  have h := cosetMoment_rate ρ 1 hρ id tendsto_id hR
  simpa using h

/-- The unconstrained growth rate equals the Arıkan–Merhav exponent at `p = 1/2`. -/
theorem unifMoment_rate_am (ρ : ℝ) (hρ : 0 < ρ) :
    Tendsto (fun m : ℕ => (1 / (m : ℝ)) * Real.logb 2 (cosetMoment ρ id m)) atTop
      (𝓝 (amExponent ρ (1 / 2))) := by
  rw [amExponent_half ρ hρ]
  exact unifMoment_rate ρ hρ

/-- The constrained coset growth rate equals the Arıkan–Merhav exponent at `p = 1/2` shifted
down by exactly the coding redundancy `ρ(1-R)`. -/
theorem cosetMoment_rate_am (ρ R : ℝ) (hρ : 0 < ρ) (kn : ℕ → ℕ)
    (htop : Tendsto kn atTop atTop)
    (hR : Tendsto (fun m : ℕ => (kn m : ℝ) / (m : ℝ)) atTop (𝓝 R)) :
    Tendsto (fun m : ℕ => (1 / (m : ℝ)) * Real.logb 2 (cosetMoment ρ kn m)) atTop
      (𝓝 (amExponent ρ (1 / 2) - ρ * (1 - R))) := by
  have h := cosetMoment_rate ρ R hρ kn htop hR
  have heq : ρ * R = amExponent ρ (1 / 2) - ρ * (1 - R) := by
    rw [amExponent_half ρ hρ]; ring
  rwa [heq] at h

/-- **Exact exponent shift.** The unconstrained rate `ρ` and the constrained rate `ρR` differ
by exactly the coding redundancy `ρ(1-R)`, independently of the source (here `p = 1/2`). -/
theorem exact_exponent_shift (ρ R : ℝ) : ρ - ρ * R = ρ * (1 - R) := by ring

/-! ## Sanity checks -/

-- The shift vanishes at full rate `R = 1`.
example (ρ : ℝ) : ρ - ρ * 1 = ρ * (1 - 1) := exact_exponent_shift ρ 1

-- Second moment, rate `R = 1/2`: constrained exponent `2 · (1/2) = 1`.
example : (2 : ℝ) * (1 / 2) = 1 := by norm_num

#check @cosetMoment_rate
#check @unifMoment_rate_am
#check @cosetMoment_rate_am

end CosetGuessworkExact